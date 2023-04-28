{
  wifi = true;
  bluetooth = true;
  lock-before-sleep = true;
  minutes-before-lock = 3;
  minutes-from-lock-to-sleep = 7;
  screens = {
    screen1 = "eDP-1";
    screen2 = "HDMI-1";
  };
  polybar_config = ./polybar_config.ini;
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
          echo "
pkill polybar; \
while pgrep -u $UID -x polybar > /dev/null; \
  do sleep 1; \
done; \
\
polybar eDP1-tray-on -c /home/romain/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar.log & disown; \
\
          " > $HOME/.config/polybar/launch.sh
          chmod +x $HOME/.config/polybar/launch.sh
          $HOME/.config/polybar/launch.sh

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
            rate = "120.00";
          };
          "HDMI-1" = {
            enable = true;
            crtc = 1;
            mode = "2560x1440";
            primary = true;
            position = "1920x0";
            rate = "59.95";
          };
        };
        hooks.postswitch = ''
          echo " \
pkill polybar; \
while pgrep -u $UID -x polybar > /dev/null; \
  do sleep 1; \
done; \
\
polybar HDMI1-tray-on -c /home/romain/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar.log & disown; \
polybar eDP1-tray-off -c /home/romain/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar.log & disown; \
\
          " > $HOME/.config/polybar/launch.sh
          chmod +x $HOME/.config/polybar/launch.sh
          $HOME/.config/polybar/launch.sh

          feh --bg-max --random "$HOME/Wallpapers/Single screen/"
        '';
        };

      "bureau-stockly" = {
        fingerprint = {
          "eDP-1" = "00ffffffffffff0009e58a0a000000001a1f0104a5221378032dc5975c5b92292050540000000101010101010101010101010101010147798018713860403020360058c21000001a000000fd0030788d8d1f010a202020202020000000fe0057334d5243804e5631354e3455000000000002410f99000000000b010a202001017013790000030114a43c00047f0717012f001f0037045f00020005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000eb90";
          "HDMI-1" = "00ffffffffffff0005e30127e0790300161f0103803c22782a8671a355539d250d5054bfef00d1c0b30095008180814081c001010101565e00a0a0a029503020350055502100001e000000ff00474e584d364841323237383038000000fc005132375031420a202020202020000000fd00324c1e631e000a20202020202001cd02031ef14b101f051404130312021101230907078301000065030c001000023a801871382d40582c450055502100001e011d007251d01e206e28550055502100001e8c0ad08a20e02d10103e96005550210000188c0ad090204031200c405500555021000018f03c00d051a0355060883a0055502100001c00000000000000f7";
        };
        config = {
          "eDP-1" = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            position = "2560x360";
            rate = "120.00";
          };
          "HDMI-1" = {
            enable = true;
            primary = true;
            crtc = 1;
            mode = "2560x1440";
            position = "0x0";
            rate = "59.95";
          };
        };
        hooks.postswitch = ''
          echo " \
pkill polybar; \
while pgrep -u $UID -x polybar > /dev/null; \
  do sleep 1; \
done; \
\
polybar HDMI1-tray-on -c /home/romain/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar.log & disown; \
polybar eDP1-tray-off -c /home/romain/.config/polybar/config.ini 2>&1 | tee -a /tmp/polybar.log & disown; \
\
          " > $HOME/.config/polybar/launch.sh
          chmod +x $HOME/.config/polybar/launch.sh
          $HOME/.config/polybar/launch.sh

          feh --bg-max --random "$HOME/Wallpapers/Single screen/"
        '';
        };
    };
  };
}
