{
  pkgs,
  config,
  ...
}:
let
  inherit (pkgs) writeScriptBin libnotify;
  rofiGrid = config.rofi.gridCmd;
  jq = "${pkgs.jq}/bin/jq";
  curl = "${pkgs.curl}/bin/curl";
  notifySend = "${libnotify}/bin/notify-send";

  clientIdPath = config.sops.secrets."spotify/client_id".path;
  clientSecretPath = config.sops.secrets."spotify/client_secret".path;
  refreshTokenPath = config.sops.secrets."spotify/refresh_token".path;
  userId = "chilledcow";
  cacheDir = "$HOME/.cache/lofi-girl-playlists";
  cacheTtlSeconds = toString (7 * 24 * 3600); # 7 days
  searchLimit = "10"; # Spotify API max for search

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
    REFRESH_TOKEN=$(cat ${refreshTokenPath})

    TOKEN=$(${curl} -s -X POST https://accounts.spotify.com/api/token \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "grant_type=refresh_token&refresh_token=$REFRESH_TOKEN&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET" \
      | ${jq} -r '.access_token')

    if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
      exit 1
    fi

    # Collect all known playlist IDs: from existing cache + from cached images
    KNOWN_IDS=""
    if [[ -s "$CACHE_FILE" ]]; then
      KNOWN_IDS=$(cut -f2 "$CACHE_FILE")
    fi
    for img in "$CACHE_DIR"/*.jpg; do
      [[ -f "$img" ]] || continue
      ID=$(basename "$img" .jpg)
      if ! echo "$KNOWN_IDS" | grep -qx "$ID"; then
        KNOWN_IDS="$KNOWN_IDS"$'\n'"$ID"
      fi
    done

    # Discover new playlists via search
    for OFFSET in $(seq 0 ${searchLimit} 200); do
      PAGE=$(${curl} -s "https://api.spotify.com/v1/search?q=lofi+girl&type=playlist&limit=${searchLimit}&offset=$OFFSET" \
        -H "Authorization: Bearer $TOKEN")
      NEW_IDS=$(echo "$PAGE" | ${jq} -r '.playlists.items[]? | select(.owner.id == "${userId}") | .id')
      for ID in $NEW_IDS; do
        if ! echo "$KNOWN_IDS" | grep -qx "$ID"; then
          KNOWN_IDS="$KNOWN_IDS"$'\n'"$ID"
        fi
      done
    done

    # Remove empty lines
    KNOWN_IDS=$(echo "$KNOWN_IDS" | sed '/^$/d' | sort -u)

    # Fetch each playlist individually and build the TSV
    > "$CACHE_FILE.tmp"
    while IFS= read -r PLAYLIST_ID; do
      DATA=$(${curl} -s "https://api.spotify.com/v1/playlists/$PLAYLIST_ID" \
        -H "Authorization: Bearer $TOKEN")

      OWNER=$(echo "$DATA" | ${jq} -r '.owner.id // ""')
      if [[ "$OWNER" != "${userId}" ]]; then
        continue
      fi

      LINE=$(echo "$DATA" | ${jq} -r '"\(.name)\t\(.id)\t\(.images[0].url // "")"')
      echo "$LINE" >> "$CACHE_FILE.tmp"
    done <<< "$KNOWN_IDS"

    # Sort by name and replace cache
    sort -t$'\t' -k1,1 "$CACHE_FILE.tmp" > "$CACHE_FILE.tmp2" && mv "$CACHE_FILE.tmp2" "$CACHE_FILE"
    rm -f "$CACHE_FILE.tmp"

    # Download cover images (skip already cached)
    while IFS=$'\t' read -r name id image_url; do
      if [[ -n "$image_url" && ! -f "$CACHE_DIR/$id.jpg" ]]; then
        ${curl} -s -o "$CACHE_DIR/$id.raw" "$image_url"
        ${pkgs.imagemagick}/bin/convert "$CACHE_DIR/$id.raw" "$CACHE_DIR/$id.jpg"
        rm -f "$CACHE_DIR/$id.raw"
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
        ${notifySend} "Lofi Girl" "Failed to fetch playlists"
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
        PLAYERCTL="${pkgs.playerctl}/bin/playerctl -p spotify"
        $PLAYERCTL stop || true
        $PLAYERCTL shuffle On || true
        ${pkgs.dbus}/bin/dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify \
          /org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player.OpenUri \
          "string:spotify:playlist:$PLAYLIST_ID"
        sleep 2
        $PLAYERCTL next
      fi
    '')
  ];
}
