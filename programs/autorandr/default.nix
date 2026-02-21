{
  pkgs,
  lib,
  config,
  ...
}:
let
  homeDir = config.home.homeDirectory;
  hooksPostswitch = bars: profileName: ''
    echo "${bars}" > ${homeDir}/.config/polybar/bars
    systemctl --user restart wallpapers-manager
    systemctl --user restart polybar
    echo "${profileName}" > ${homeDir}/.config/autorandr/current
  '';
  autorandrForce = "${pkgs.writeShellScriptBin "autorandr-force" ''
    echo "" > ${homeDir}/.config/autorandr/current && autorandr -c
  ''}/bin/autorandr-force";
  xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
  grep = "${pkgs.gnugrep}/bin/grep";
  cut = "${pkgs.coreutils}/bin/cut";
  fixScreens = "${pkgs.writeShellScriptBin "fix-screens" ''
    for OUTPUT in $(${xrandr} --query | ${grep} ' connected' | ${cut} -d' ' -f1); do
      ${xrandr} --output "$OUTPUT" --off
    done
    sleep 2
    for OUTPUT in $(${xrandr} --query | ${grep} ' connected' | ${cut} -d' ' -f1); do
      ${xrandr} --output "$OUTPUT" --auto
    done
    sleep 1
    ${autorandrForce}
  ''}/bin/fix-screens";
in
{
  programs.autorandr = {
    enable = true;
    hooks.preswitch = {
      cmd = ''
        if [[ $(cat ${homeDir}/.config/autorandr/current) == $AUTORANDR_CURRENT_PROFILE ]]; then
          pkill autorandr
        fi
      '';
    };
    profiles = {
      stockly-tom = {
        fingerprint = {
          HDMI-1 = "00ffffffffffff0005e30227150100000f200103803c22782ae445a554529e260d5054bfef00d1c0b30095008180814081c001010101565e00a0a0a029503020350055502100001e000000ff005452504e344841303030323737000000fc005132375032570a202020202020000000fd00304b1e721e000a20202020202001c502031ef14b101f051404130312021101230907078301000065030c001000a073006aa0a029500820350055502100001a2a4480a0703827403020350055502100001a023a801871382d40582c450055502100001e011d007251d01e206e28550055502100001ef03c00d051a0355060883a0055502100001c0000000000000097";
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
            position = "2560x0";
            primary = true;
            rate = "60.01";
          };
        };
        hooks.postswitch = hooksPostswitch "eDP-1-tray-off HDMI-1-battery" "stockly-tom";
      };
      zizou = {
        fingerprint = {
          HDMI-1 = "00ffffffffffff0026cd6466d20500000f210103803c22782af615a6564da4260c5054254b00a9c0e100a940b3009500d100d1c00101565e00a0a0a029503020350055502100001a000000ff0031313739383331353131343930000000fd00374c1e781e000a202020202020000000fc00504c3237343051530a2020202001fc02032df14f90050403020111121314060715161f230907078301000067030c001000383c681a00000101304be6023a801871382d40582c450055502100001ed84c0070a0a022501820480455502100001a9774006ea0a034501720680855502100001e00000000000000000000000000000000000000000000000000000000a8";
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
            mode = "2560x1440";
            position = "1920x0";
            primary = false;
            rate = "59.95";
          };
        };
        hooks.postswitch = hooksPostswitch "eDP-1-tray-off HDMI-1-battery" "zizou";
      };
      factory-s = {
        fingerprint = {
          HDMI-1 = "00ffffffffffff0005e30127e0790300161f0103803c22782a8671a355539d250d5054bfef00d1c0b30095008180814081c001010101565e00a0a0a029503020350055502100001e000000ff00474e584d364841323237383038000000fc005132375031420a202020202020000000fd00324c1e631e000a20202020202001cd02031ef14b101f051404130312021101230907078301000065030c001000023a801871382d40582c450055502100001e011d007251d01e206e28550055502100001e8c0ad08a20e02d10103e96005550210000188c0ad090204031200c405500555021000018f03c00d051a0355060883a0055502100001c00000000000000f7";
          eDP-1 = "00ffffffffffff000daee71500000000211a0104a52213780228659759548e271e505400000001010101010101010101010101010101b43b804a713834405036680058c110000018000000fe004e3135364843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3135364843412d4541420a2000b2";
        };
        config = {
          HDMI-1 = {
            enable = true;
            crtc = 1;
            mode = "2560x1440";
            position = "1920x0";
            primary = false;
            rate = "59.95";
          };

          eDP-1 = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            position = "0x360";
            primary = true;
            rate = "60.01";
          };
        };
        hooks.postswitch = hooksPostswitch "eDP-1-tray-off HDMI-1-battery" "factory-s";
      };
      bureau = {
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
        hooks.postswitch = hooksPostswitch "HDMI-1 HDMI-2" "bureau";
      };
      salon0 = {
        fingerprint = {
          HDMI-0 = "00ffffffffffff004c2d5c73000e000101210103806f3e780aa833ab5045a5270d4848bdef80714f81c0810081809500a9c0b300d1c008e80030f2705a80b0588a00501d7400001ecfcb0080f5403a6020a03a50501d7400001c000000fd00184b0f873c000a202020202020000000fc0053414d53554e470a2020202020018702035bf05561101f041305142021225d5e5f606566626403125a2f0d5707090707150750570700675400830f0000e2004fe305c3016e030c001000b8442800800102030468d85dc40178800b02e3060d01e30f01e0e5018b8490011a6800a0f0381f4030203a00a9504100001a000000000000000000000000000000000000a0";
        };
        config = {
          HDMI-0 = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            position = "0x0";
            primary = true;
            rate = "60.00";
          };
        };
        hooks.postswitch = hooksPostswitch "HDMI-0" "salon0";
      };
      salon2 = {
        fingerprint = {
          HDMI-2 = "00ffffffffffff004c2d5c73000e000101210103806f3e780aa833ab5045a5270d4848bdef80714f81c0810081809500a9c0b300d1c008e80030f2705a80b0588a00501d7400001ecfcb0080f5403a6020a03a50501d7400001c000000fd00184b0f873c000a202020202020000000fc0053414d53554e470a2020202020018702035bf05561101f041305142021225d5e5f606566626403125a2f0d5707090707150750570700675400830f0000e2004fe305c3016e030c001000b8442800800102030468d85dc40178800b02e3060d01e30f01e0e5018b8490011a6800a0f0381f4030203a00a9504100001a000000000000000000000000000000000000a0";
        };
        config = {
          HDMI-2 = {
            enable = true;
            crtc = 0;
            mode = "1920x1080";
            position = "0x0";
            primary = true;
            rate = "59.95";
          };
        };
        hooks.postswitch = hooksPostswitch "HDMI-2" "salon2";
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
        hooks.postswitch = hooksPostswitch "eDP-1-tray-on" "stockly-romainc";
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
        hooks.postswitch = hooksPostswitch "eDP-1-tray-off HDMI-1-battery" "stockly-romainc-bureau";
      };
      stockly-bureau-1 = {
        fingerprint = {
          HDMI-1 = "00ffffffffffff0005e30127213f0300141f0103803c22782a8671a355539d250d5054bfef00d1c0b30095008180814081c001010101565e00a0a0a029503020350055502100001e000000ff00474e584d354841323132373639000000fc005132375031420a202020202020000000fd00324c1e631e000a20202020202001c902031ef14b101f051404130312021101230907078301000065030c001000023a801871382d40582c450055502100001e011d007251d01e206e28550055502100001e8c0ad08a20e02d10103e96005550210000188c0ad090204031200c405500555021000018f03c00d051a0355060883a0055502100001c00000000000000f7";
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
            mode = "2560x1440";
            position = "1920x0";
            primary = false;
            rate = "59.95";
          };
        };
        hooks.postswitch = hooksPostswitch "eDP-1-tray-off HDMI-1-battery" "stockly-bureau-1";
      };
      grenoble-yohan = {
        fingerprint = {
          HDMI-1 = "00ffffffffffff0026cd10560101010113130103a0341e782aeed5a555489b26125054bfef8001010101950001018180950f714f0101023a801871382d40582c4500a05a0000001e000000ff0031313033323931393032343732000000fd00374c1d5011000a202020202020000000fc00504c4532343037484453560a20010a020323f14b101f8413000002030000002309070783010000e2000f67030c002000802d011d007251d01e206e28550010090000001e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ce";
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
        hooks.postswitch = hooksPostswitch "eDP-1-tray-on eDP-1-tray-off-on-hdmi1" "grenoble-yohan";
      };
    };
  };

  xsession.windowManager.i3.config =
    let
      modifier = config.xsession.windowManager.i3.config.modifier;
    in
    {
      keybindings = lib.mkOptionDefault {
        "${modifier}+Shift+a" = "exec ${autorandrForce}";
        "${modifier}+Control+Shift+a" = "exec ${fixScreens}";
      };
      startup = [
        # Force refresh at boot, in case the config stored on disk is not the one currently applied
        {
          command = "${autorandrForce}";
          notification = false;
        }
        {
          command = "sleep 5 && ${pkgs.srandrd}/bin/srandrd -n autorandr -c";
          notification = false;
        }
      ];
    };
}
