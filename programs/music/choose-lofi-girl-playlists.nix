{
  pkgs,
  config,
  ...
}:
let
  inherit (pkgs) writeScriptBin;
  rofiGrid = config.rofi.gridCmd;
  jq = "${pkgs.jq}/bin/jq";
  curl = "${pkgs.curl}/bin/curl";

  clientIdPath = config.sops.secrets."spotify/client_id".path;
  clientSecretPath = config.sops.secrets."spotify/client_secret".path;
  userId = "chilledcow";
  cacheDir = "$HOME/.cache/lofi-girl-playlists";
  cacheTtlSeconds = toString (24 * 3600); # 24 hours

  refreshScript = writeScriptBin "refresh-lofi-girl-playlists" ''
    CACHE_DIR="${cacheDir}"
    CACHE_FILE="$CACHE_DIR/playlists.tsv"
    LOCK_FILE="$CACHE_DIR/.refresh.lock"
    mkdir -p "$CACHE_DIR"

    # Prevent concurrent refreshes
    exec 9>"$LOCK_FILE"
    ${pkgs.flock}/bin/flock -n 9 || exit 0

    CLIENT_ID=$(cat ${clientIdPath})
    CLIENT_SECRET=$(cat ${clientSecretPath})

    TOKEN=$(${curl} -s -X POST https://accounts.spotify.com/api/token \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET" \
      | ${jq} -r '.access_token')

    if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
      exit 1
    fi

    ALL_PLAYLISTS="[]"
    OFFSET=0
    LIMIT=50

    while true; do
      PAGE=$(${curl} -s "https://api.spotify.com/v1/users/${userId}/playlists?limit=$LIMIT&offset=$OFFSET" \
        -H "Authorization: Bearer $TOKEN")

      ITEMS=$(echo "$PAGE" | ${jq} '.items')
      COUNT=$(echo "$ITEMS" | ${jq} 'length')

      if [[ "$COUNT" -eq 0 ]]; then
        break
      fi

      ALL_PLAYLISTS=$(echo "$ALL_PLAYLISTS $ITEMS" | ${jq} -s '.[0] + .[1]')
      OFFSET=$((OFFSET + LIMIT))

      TOTAL=$(echo "$PAGE" | ${jq} '.total')
      if [[ "$OFFSET" -ge "$TOTAL" ]]; then
        break
      fi
    done

    # Write cache: name\tid\timage_url, sorted by track count
    echo "$ALL_PLAYLISTS" | ${jq} -r '
      sort_by(-.tracks.total)
      | .[]
      | "\(.name)\t\(.id)\t\(.images[0].url // "")"
    ' > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"

    # Download cover images (skip already cached)
    while IFS=$'\t' read -r name id image_url; do
      if [[ -n "$image_url" && ! -f "$CACHE_DIR/$id.jpg" ]]; then
        ${curl} -s -o "$CACHE_DIR/$id.jpg" "$image_url"
      fi
    done < "$CACHE_FILE"
  '';
in
{
  home.packages = [
    (writeScriptBin "choose-lofi-girl-playlists" ''
      CACHE_DIR="${cacheDir}"
      CACHE_FILE="$CACHE_DIR/playlists.tsv"

      # On very first run, we must fetch synchronously
      if [[ ! -s "$CACHE_FILE" ]]; then
        ${refreshScript}/bin/refresh-lofi-girl-playlists
      fi

      if [[ ! -s "$CACHE_FILE" ]]; then
        notify-send "Lofi Girl" "Failed to fetch playlists"
        exit 1
      fi

      # Trigger background refresh if cache is stale
      CACHE_AGE=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE") ))
      if [[ "$CACHE_AGE" -gt ${cacheTtlSeconds} ]]; then
        ${refreshScript}/bin/refresh-lofi-girl-playlists &
      fi

      # Build rofi menu from cache
      MENU_INPUT=""
      while IFS=$'\t' read -r name id image_url; do
        ICON_PATH="$CACHE_DIR/$id.jpg"
        if [[ -f "$ICON_PATH" ]]; then
          MENU_INPUT+="$name\0icon\x1f$ICON_PATH\n"
        else
          MENU_INPUT+="$name\n"
        fi
      done < "$CACHE_FILE"

      SELECTION=$(echo -en "$MENU_INPUT" | ${rofiGrid})

      if [[ -z "$SELECTION" ]]; then
        exit 0
      fi

      # Find the playlist ID matching the selection
      PLAYLIST_ID=$(while IFS=$'\t' read -r name id image_url; do
        if [[ "$name" == "$SELECTION" ]]; then
          echo "$id"
          break
        fi
      done < "$CACHE_FILE")

      if [[ -n "$PLAYLIST_ID" ]]; then
        xdg-open "spotify:playlist:$PLAYLIST_ID"
      fi
    '')
  ];
}
