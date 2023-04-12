
play_youtube() {
    url_stream=$(yt-dlp -g $url_youtube)
    strawberry --play-playlist Youtube  # Loads the playlist so that the current one doesn't get erased by the following 'load' command
    strawberry --load $url_stream
    sleep 1
    strawberry --play-playlist Youtube
}

play_radio() {
    strawberry --play-playlist Radios
    strawberry --play-track $track
}
# track=0 && play_radio
MENU="$(echo -n 'FIP|Jazz Radio|Radio Nova|Oui Fm|Chillhop Radio|Classical Piano Music' | rofi -no-config -no-lazy-grab -sep "|" -dmenu -i -p 'radio' \
-theme /home/romain/.config/rofi/theme/styles.rasi)"
            case "$MENU" in
				FIP) track=0 && play_radio ;;
				"Jazz Radio") track=1 && play_radio ;;
				"Radio Nova") track=2 && play_radio ;;
				"Oui Fm") track=3 && play_radio ;;
				"Chillhop Radio") url_youtube=https://www.youtube.com/watch?v=5yx6BWlEVcY && play_youtube && echo "Chillhop Radio" > /home/romain/.config/polybar/.radio_title ;;
				"Classical Piano Music") url_youtube=https://www.youtube.com/watch?v=tSlOlKRuudU && play_youtube && echo "Classical Piano Music" > /home/romain/.config/polybar/.radio_title;;
            esac

echo "now playing $url_youtube"
