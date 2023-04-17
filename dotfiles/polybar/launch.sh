# #!/bin/bash



# Terminate already running bar instances

killall -q polybar

# If all your bars have ipc enabled, you can also use

# polybar-msg cmd quit



# Launch Polybar, using default config location ~/.config/polybar/config.ini

polybar HDMI1-tray-on -c /home/romain/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar.log & disown
polybar eDP1-tray-off -c /home/romain/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar.log & disown



echo "Polybar launched..."
