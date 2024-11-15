let
  hooks-postswitch = bars: ''
    echo "${bars}" > $HOME/.config/polybar/bars
    systemctl --user restart polybar
  '';
in
{
  config = {
    programs.autorandr = {
      enable = true;
      profiles = {
        stockly-romainc = {
          fingerprint = {
            "eDP-1" = "00ffffffffffff000daee71500000000211a0104a52213780228659759548e271e505400000001010101010101010101010101010101b43b804a713834405036680058c110000018000000fe004e3135364843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3135364843412d4541420a2000b2";
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
          hooks.postswitch = hooks-postswitch "eDP-1-tray-on";
        };
        stockly-romainc-bureau = {
          fingerprint = {
            "eDP-1" = "00ffffffffffff000daee71500000000211a0104a52213780228659759548e271e505400000001010101010101010101010101010101b43b804a713834405036680058c110000018000000fe004e3135364843412d4541420a20000000fe00434d4e0a202020202020202020000000fe004e3135364843412d4541420a2000b2";
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
          hooks.postswitch = hooks-postswitch "eDP-1-tray-off HDMI-1-battery";
        };
        fixe-bureau = {
          fingerprint = {
            "HDMI-2" = "00ffffffffffff0026cd64661907000025200103803c22782af615a6564da4260c5054254b00a9c0e100a940b3009500d100d1c00101565e00a0a0a029503020350055502100001a000000ff0031313739383233373131383137000000fd00374c1e781e000a202020202020000000fc00504c3237343051530a20202020019802032df14f90050403020111121314060715161f230907078301000067030c001000383c681a00000101304be6023a801871382d40582c450055502100001ed84c0070a0a022501820480455502100001a9774006ea0a034501720680855502100001e00000000000000000000000000000000000000000000000000000000a8";
            "HDMI-1" = "00ffffffffffff004c2d171051394e3004210103803f24782ac8b5ad50449e250f5054bfef80714f810081c081809500a9c0b300010108e80030f2705a80b0588a0078682100001e000000fd00324b1e873c000a202020202020000000fc004c5532385235350a2020202020000000ff00484e4d573130343832390a202001bd020335f04961120313041f10605f2309070783010000e305c0006b030c001000b8442000200167d85dc40178800be3060501e20f81023a801871382d40582c450078682100001e023a80d072382d40102c458078682100001e04740030f2705a80b0588a0078682100001e565e00a0a0a029503020350078682100001a000049";
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
          hooks.postswitch = hooks-postswitch "HDMI-1 HDMI-2";
        };
      };
    };

    xsession.windowManager.i3.config.startup = [
      {
        command = "autorandr --change";
        notification = false;
        always = true;
      }
    ];
  };
}
