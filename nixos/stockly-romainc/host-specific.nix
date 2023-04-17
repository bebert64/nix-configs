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
    launch_script = ''
      killall -q polybar
      while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done
      polybar eDP1-tray-off 2>&1 | tee -a /tmp/polybar.log & disown
      polybar HDMI-1-tray-on 2>&1 | tee -a /tmp/polybar.log & disown
      '';
  };
  autorandr = {
    enable  = true;
    profiles = {
      "solo" = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0009e58a0a000000001a1f0104a5221378032dc5975c5b92292050540000000101010101010101010101010101010147798018713860403020360058c21000001a000000fd0030788d8d1f010a202020202020000000fe0057334d5243804e5631354e3455000000000002410f99000000000b010a202001017013790000030114a43c00047f0717012f001f0037045f00020005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eb90";
        };
        config = {
          "eDP-1" = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            position = "0x0";
            primary = true;
            rate = "120.00";
          };
        };
        hooks.postswitch = ''
          systemctl --user restart polybar.service
          feh --bg-max --random "$HOME/Wallpapers/Single screen/"
        '';
        };
      "bureau-maison" = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0009e58a0a000000001a1f0104a5221378032dc5975c5b92292050540000000101010101010101010101010101010147798018713860403020360058c21000001a000000fd0030788d8d1f010a202020202020000000fe0057334d5243804e5631354e3455000000000002410f99000000000b010a202001017013790000030114a43c00047f0717012f001f0037045f00020005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eb90";
          "HDMI-1" = "00ffffffffffff0026cd64661907000025200103803c22782af615a6564da4260c5054254b00a9c0e100a940b3009500d100d1c00101565e00a0a0a029503020350055502100001a000000ff0031313739383233373131383137000000fd00374c1e781e000a202020202020000000fc00504c3237343051530a20202020019802032df14f90050403020111121314060715161f230907078301000067030c001000383c681a00000101304be6023a801871382d40582c450055502100001ed84c0070a0a022501820480455502100001a9774006ea0a034501720680855502100001e00000000000000000000000000000000000000000000000000000000a8";
        };
        config = {
          "eDP-1" = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            position = "0x360";
            primary = true;
            rate = "120.00";
          };
          "HDMI-1" = {
            enable = true;
            crtc = 1;
            mode = "2560x1440";
            position = "1920x0";
            rate = "59.95";
          };
        };
        hooks.postswitch = ''
          systemctl --user restart polybar.service
          feh --bg-max --random "$HOME/Wallpapers/Single screen/"
        '';
        };
    };
  };
}
