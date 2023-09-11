echo Hello and welcome my Don !
read -p 'flake-config name:  ' flake_config
read -p 'user: ' user
read -p 'install xf86-video-vese ? (y/n): ' install_video_drivers rest_of_words

if [[ $rest_of_words != "" ]]; then
    echo 'Too many arguments'
elif [[ $install_video_drivers = "y" ]] || [[ $install_video_drivers = "n" ]]; then
    echo "Correct input"
else
    echo $install_video_drivers
fi
