{
    wifi = true;
    bluetooth = false;
    lock-before-sleep = false;
    minutes-before-sleep = 10;
    screens = {
        screen1 = "HDMI-1";
        screen2 = "";
    };
    polybar = {
        config_file = ./polybar_config.ini;
        launch_script = import ./launch_polybar.sh;
    };
}
