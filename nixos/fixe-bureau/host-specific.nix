{
  wifi = false;
  bluetooth = false;
  lock-before-sleep = false;
  minutes-before-lock = 30;
  minutes-from-lock-to-sleep = 30;
  screens = {
    screen1 = "HDMI-1";
  };
  polybar_config = ./polybar_config.ini;
  autorandr = {
    enable  = true;
    profiles = {
      "bureau-maison" = {
        fingerprint = {
          "HDMI-1" = "00ffffffffffff0026cd64661907000025200103803c22782af615a6564da4260c5054254b00a9c0e100a940b3009500d100d1c00101565e00a0a0a029503020350055502100001a000000ff0031313739383233373131383137000000fd00374c1e781e000a202020202020000000fc00504c3237343051530a20202020019802032df14f90050403020111121314060715161f230907078301000067030c001000383c681a00000101304be6023a801871382d40582c450055502100001ed84c0070a0a022501820480455502100001a9774006ea0a034501720680855502100001e00000000000000000000000000000000000000000000000000000000a8";
        };
        config = {
          "HDMI-1" = {
            enable = true;
            crtc = 0;
            mode = "2560x1440";
            position = "0x0";
            primary = true;
            rate = "59.95";
          };
        };
        hooks.postswitch = ''
          pkill polybar
          while pgrep -u $UID -x polybar > /dev/null; do sleep 1; done
          polybar HDMI1-tray-on -c /home/romain/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar.log & disown
          feh --bg-max --random "$HOME/Wallpapers/Single screen/"
        '';
        };
    };
  };
}
