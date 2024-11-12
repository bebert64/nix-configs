{
  wifi = true;
  bluetooth = true;
  screens = {
    screen1 = "eDP-1";
    screen2 = "HDMI-1";
  };
  zsh-aliases = {
    update-dirty = "cd ~/nix-config && sudo nixos-rebuild switch --flake .#stockly-romainc ";
    upgrade = "cd ~/nix-config && git pull && nix flake update && apply-nix";
  };
  autorandr = {
    enable = true;
    profiles = {
      "solo" = {
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
        hooks.postswitch = ''
          echo "eDP-1-tray-on" > $HOME/.config/polybar/bars
          systemctl --user restart polybar
        '';
      };

      "bureau-maison" = {
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
        hooks.postswitch = ''
          echo "eDP-1-tray-off HDMI-1-battery" > $HOME/.config/polybar/bars
          systemctl --user restart polybar
        '';
      };
    };
  };
}
