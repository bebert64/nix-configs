{
    wifi = true;
    bluetooth = true;
    # battery = false;
    lock-before-sleep = true;
    minutes-before-sleep = 3;
    screens = {
        screen1 = "eDP-1";
        screen2 = "HDMI-1";
    };
    polybar = {
        config_file = ./polybar_config.ini;
        launch_script = "";
    };
}
