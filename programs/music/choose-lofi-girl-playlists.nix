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
in
{
  home.packages = [
    (writeScriptBin "choose-lofi-girl-playlists" ''
      CACHE_DIR="${cacheDir}"
      mkdir -p "$CACHE_DIR"

      CLIENT_ID=$(cat ${clientIdPath})
      CLIENT_SECRET=$(cat ${clientSecretPath})

      # Get access token via client credentials flow
      TOKEN=$(${curl} -s -X POST https://accounts.spotify.com/api/token \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "grant_type=client_credentials&client_id=$CLIENT_ID&client_secret=$CLIENT_SECRET" \
        | ${jq} -r '.access_token')

      if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
        notify-send "Lofi Girl" "Failed to get Spotify token"
        exit 1
      fi

      # Fetch all playlists (paginated, max 50 per request)
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

      # Extract playlist data sorted by track count, with image URL
      # Format: "name\tid\timage_url"
      SORTED=$(echo "$ALL_PLAYLISTS" | ${jq} -r '
        sort_by(-.tracks.total)
        | .[]
        | "\(.name)\t\(.id)\t\(.images[0].url // "")"
      ')

      if [[ -z "$SORTED" ]]; then
        notify-send "Lofi Girl" "No playlists found"
        exit 1
      fi

      # Download cover images to cache (skip if already cached)
      echo "$SORTED" | while IFS=$'\t' read -r name id image_url; do
        if [[ -n "$image_url" && ! -f "$CACHE_DIR/$id.jpg" ]]; then
          ${curl} -s -o "$CACHE_DIR/$id.jpg" "$image_url"
        fi
      done

      # Build rofi menu with icons
      MENU_INPUT=""
      while IFS=$'\t' read -r name id image_url; do
        ICON_PATH="$CACHE_DIR/$id.jpg"
        if [[ -f "$ICON_PATH" ]]; then
          MENU_INPUT+="$name\0icon\x1f$ICON_PATH\n"
        else
          MENU_INPUT+="$name\n"
        fi
      done <<< "$SORTED"

      SELECTION=$(echo -en "$MENU_INPUT" | ${rofiGrid})

      if [[ -z "$SELECTION" ]]; then
        exit 0
      fi

      # Find the playlist ID matching the selection
      PLAYLIST_ID=$(echo "$SORTED" | while IFS=$'\t' read -r name id image_url; do
        if [[ "$name" == "$SELECTION" ]]; then
          echo "$id"
          break
        fi
      done)

      if [[ -n "$PLAYLIST_ID" ]]; then
        xdg-open "spotify:playlist:$PLAYLIST_ID"
      fi
    '')
  ];
}
