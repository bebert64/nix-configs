{
  pkgs,
  lib,
  config,
  ...
}:
let
  hooks-postswitch = bars: profile-name: ''
    echo "${bars}" > $HOME/.config/polybar/bars
    systemctl --user restart wallpapers-manager
    systemctl --user restart polybar
    echo "${profile-name}" > $HOME/.config/autorandr/current
  '';
  autorandr-force = "${pkgs.writeScriptBin "autorandr-force" ''
    echo "" > $HOME/.config/autorandr/current && autorandr -c
  ''}/bin/autorandr-force";
in
{
  programs.autorandr = {
    enable = true;
    hooks.preswitch = {
      cmd = ''
        if [[ $(cat $HOME/.config/autorandr/current) == $AUTORANDR_CURRENT_PROFILE ]]; then
          pkill autorandr
        fi
      '';
    };
    profiles = {
      stockly-jeanne = {
        fingerprint = {
          HDMI-1 = "00ffffffffffff0005e30127def50100031e0103803c22782a8671a355539d250d5054bfef00d1c0b30095008180814081c001010101565e00a0a0a029503020350055502100001e000000ff00474e584c314841313238343738000000fc005132375031420a202020202020000000fd00324c1e631e000a202020202020016c02031ef14b101f051404130312021101230907078301000065030c001000023a801871382d40582c450055502100001e011d007251d01e206e28550055502100001e8c0ad08a20e02d10103e96005550210000188c0ad090204031200c405500555021000018f03c00d051a0355060883a0055502100001c00000000000000f7";
          eDP-1 = "00ffffffffffff000daee71500000000211a0104a52213780228659759548e271e505400000001010101010101010101010101010101b43b804a713834405036680058c110000018000000fe004e3135364843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3135364843412d4541420a2000b2";
        };
        config = {
          HDMI-1 = {
            enable = true;
            crtc = 1;
            mode = "2560x1440";
            position = "0x0";
            primary = false;
            rate = "59.95";
          };

          eDP-1 = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            position = "2560x360";
            primary = true;
            rate = "60.01";
          };
        };
        hooks.postswitch = hooks-postswitch "eDP-1-tray-off HDMI-1-battery" "stockly-jeanne";
      };
      stockly-olivierm = {
        fingerprint = {
          HDMI-1 = "00ffffffffffff0026cd6466d00500000f210103803c22782af615a6564da4260c5054254b00a9c0e100a940b3009500d100d1c00101565e00a0a0a029503020350055502100001a000000ff0031313739383331353131343838000000fd00374c1e781e000a202020202020000000fc00504c3237343051530a2020202001f702032df14f90050403020111121314060715161f230907078301000067030c001000383c681a00000101304be6023a801871382d40582c450055502100001ed84c0070a0a022501820480455502100001a9774006ea0a034501720680855502100001e00000000000000000000000000000000000000000000000000000000a8";
          eDP-1 = "00ffffffffffff000daee71500000000211a0104a52213780228659759548e271e505400000001010101010101010101010101010101b43b804a713834405036680058c110000018000000fe004e3135364843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3135364843412d4541420a2000b2";
        };
        config = {
          HDMI-1 = {
            enable = true;
            crtc = 1;
            mode = "2560x1440";
            position = "0x0";
            primary = false;
            rate = "59.95";
          };

          eDP-1 = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            position = "2560x360";
            primary = true;
            rate = "60.01";
          };
        };
        hooks.postswitch = hooks-postswitch "eDP-1-tray-off HDMI-1-battery" "sotckly-bureau-4";
      };
      thomasb = {
        fingerprint = {
          HDMI-1 = "00ffffffffffff0005e3012753040300081f0103803c22782a8671a355539d250d5054bfef00d1c0b30095008180814081c001010101565e00a0a0a029503020350055502100001e000000ff00474e584d324841313937373135000000fc005132375031420a202020202020000000fd00324c1e631e000a20202020202001de02031ef14b101f051404130312021101230907078301000065030c001000023a801871382d40582c450055502100001e011d007251d01e206e28550055502100001e8c0ad08a20e02d10103e96005550210000188c0ad090204031200c405500555021000018f03c00d051a0355060883a0055502100001c00000000000000f7";
          eDP-1 = "00ffffffffffff000daee71500000000211a0104a52213780228659759548e271e505400000001010101010101010101010101010101b43b804a713834405036680058c110000018000000fe004e3135364843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3135364843412d4541420a2000b2";
        };
        config = {
          HDMI-1 = {
            enable = true;
            crtc = 1;
            mode = "2560x1440";
            position = "0x0";
            primary = false;
            rate = "59.95";
          };

          eDP-1 = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            position = "2560x360";
            primary = true;
            rate = "60.01";
          };
        };
        hooks.postswitch = hooks-postswitch "eDP-1-tray-off HDMI-1-battery" "thomasb";
      };
      stockly-romainc = {
        fingerprint = {
          "eDP-1" =
            "00ffffffffffff000daee71500000000211a0104a52213780228659759548e271e505400000001010101010101010101010101010101b43b804a713834405036680058c110000018000000fe004e3135364843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3135364843412d4541420a2000b2";
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
        hooks.postswitch = hooks-postswitch "eDP-1-tray-on" "stockly-romainc";
      };
      stockly-romainc-bureau = {
        fingerprint = {
          "eDP-1" =
            "00ffffffffffff000daee71500000000211a0104a52213780228659759548e271e505400000001010101010101010101010101010101b43b804a713834405036680058c110000018000000fe004e3135364843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3135364843412d4541420a2000b2";
          "HDMI-1" =
            "00ffffffffffff0026cd64661907000025200103803c22782af615a6564da4260c5054254b00a9c0e100a940b3009500d100d1c00101565e00a0a0a029503020350055502100001a000000ff0031313739383233373131383137000000fd00374c1e781e000a202020202020000000fc00504c3237343051530a20202020019802032df14f90050403020111121314060715161f230907078301000067030c001000383c681a00000101304be6023a801871382d40582c450055502100001ed84c0070a0a022501820480455502100001a9774006ea0a034501720680855502100001e00000000000000000000000000000000000000000000000000000000a8";
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
        hooks.postswitch = hooks-postswitch "eDP-1-tray-off HDMI-1-battery" "stockly-romainc-bureau";
      };
      stockly-romainc-bureau-2 = {
        fingerprint = {
          HDMI-1 = "00ffffffffffff00410c56c1b10000002b1f0103803c22782abe95ae5045a7260f5054bfef00d1c0b30095008180814081c001010101023a801871382d40582c450056502100001e2a4480a0703827403020350056502100001a000000fc0050484c2032373356370a202020000000fd00324c1e5311000a202020202020018902031ef14b101f051404130312021101230907078301000065030c0010008c0ad08a20e02d10103e9600565021000018011d007251d01e206e28550056502100001e8c0ad08a20e02d10103e96005650210000188c0ad090204031200c4055005650210000180000000000000000000000000000000000000000000000000011";
          eDP-1 = "00ffffffffffff000daee71500000000211a0104a52213780228659759548e271e505400000001010101010101010101010101010101b43b804a713834405036680058c110000018000000fe004e3135364843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3135364843412d4541420a2000b2";
        };
        config = {
          HDMI-1 = {
            enable = true;
            crtc = 1;
            mode = "1920x1080";
            position = "0x0";
            primary = false;
            rate = "60.00";
          };

          eDP-1 = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            position = "1920x0";
            primary = true;
            rate = "60.01";
          };
        };
        hooks.postswitch = hooks-postswitch "eDP-1-tray-off eDP-1-tray-on-on-hdmi" "stockly-romainc-bureau-2";
      };
      stockly-romainc-bureau-3 = {
        fingerprint = {
          HDMI-1 = "00ffffffffffff00410c56c1860200002b1f0103803c22782abe95ae5045a7260f5054bfef00d1c0b30095008180814081c001010101023a801871382d40582c450056502100001e2a4480a0703827403020350056502100001a000000fc0050484c2032373356370a202020000000fd00324c1e5311000a20202020202001b202031ef14b101f051404130312021101230907078301000065030c0010008c0ad08a20e02d10103e9600565021000018011d007251d01e206e28550056502100001e8c0ad08a20e02d10103e96005650210000188c0ad090204031200c4055005650210000180000000000000000000000000000000000000000000000000011";
          eDP-1 = "00ffffffffffff000daee71500000000211a0104a52213780228659759548e271e505400000001010101010101010101010101010101b43b804a713834405036680058c110000018000000fe004e3135364843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3135364843412d4541420a2000b2";
        };
        config = {
          eDP-1 = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            position = "0x0";
            primary = true;
            rate = "60.01";
          };

          HDMI-1 = {
            enable = true;
            crtc = 1;
            mode = "1920x1080";
            position = "1920x0";
            primary = false;
            rate = "60.00";
          };
        };
        hooks.postswitch = hooks-postswitch "eDP-1-tray-off HDMI-1-battery" "stockly-romainc-bureau-3";
      };
      fixe-bureau = {
        fingerprint = {
          "HDMI-2" =
            "00ffffffffffff0026cd64661907000025200103803c22782af615a6564da4260c5054254b00a9c0e100a940b3009500d100d1c00101565e00a0a0a029503020350055502100001a000000ff0031313739383233373131383137000000fd00374c1e781e000a202020202020000000fc00504c3237343051530a20202020019802032df14f90050403020111121314060715161f230907078301000067030c001000383c681a00000101304be6023a801871382d40582c450055502100001ed84c0070a0a022501820480455502100001a9774006ea0a034501720680855502100001e00000000000000000000000000000000000000000000000000000000a8";
          "HDMI-1" =
            "00ffffffffffff004c2d171051394e3004210103803f24782ac8b5ad50449e250f5054bfef80714f810081c081809500a9c0b300010108e80030f2705a80b0588a0078682100001e000000fd00324b1e873c000a202020202020000000fc004c5532385235350a2020202020000000ff00484e4d573130343832390a202001bd020335f04961120313041f10605f2309070783010000e305c0006b030c001000b8442000200167d85dc40178800be3060501e20f81023a801871382d40582c450078682100001e023a80d072382d40102c458078682100001e04740030f2705a80b0588a0078682100001e565e00a0a0a029503020350078682100001a000049";
        };
        config = {
          "HDMI-2" = {
            enable = true;
            crtc = 0;
            mode = "2560x1440";
            position = "0x0";
            primary = true;
            rate = "59.95";
          };
          "HDMI-1" = {
            enable = true;
            crtc = 0;
            mode = "2560x1440";
            position = "2560x0";
            primary = true;
            rate = "59.96";
          };
        };
        hooks.postswitch = hooks-postswitch "HDMI-1 HDMI-2" "fixe-bureau";
      };
    };
  };

  xsession.windowManager.i3.config =
    let
      modifier = config.xsession.windowManager.i3.config.modifier;
    in
    {
      keybindings = lib.mkOptionDefault {
        "${modifier}+Shift+a" = "exec ${autorandr-force}";
      };
      startup = [
        # Force refresh at boot, in case the config stored on disk is not the one currently applied
        {
          command = "${autorandr-force}";
          notification = false;
        }
        {
          command = "sleep 5 && ${pkgs.srandrd}/bin/srandrd -n autorandr -c";
          notification = false;
        }
      ];
    };
}
