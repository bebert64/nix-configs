{ config, lib, pkgs, ... }:

{
  services.kanshi = {
    enable = true;
    settings = [
      {
        profile.name = "bureau";
        profile.outputs = [
          { criteria = "HDMI-A-2"; mode = "2560x1440"; position = "0,0"; }
          { criteria = "HDMI-A-1"; mode = "2560x1440"; position = "2560,0"; }
        ];
        profile.exec = [
          ''systemctl --user restart waybar''
          ''systemctl --user restart wallpapers-manager''
          ''sh -c "echo bureau > ${config.home.homeDirectory}/.config/kanshi/current"''
        ];
      }
      {
        profile.name = "stockly-romainc";
        profile.outputs = [
          { criteria = "eDP-1"; mode = "1920x1080"; position = "0,0"; status = "enable"; }
        ];
        profile.exec = [
          ''systemctl --user restart waybar''
          ''systemctl --user restart wallpapers-manager''
          ''sh -c "echo stockly-romainc > ${config.home.homeDirectory}/.config/kanshi/current"''
        ];
      }
      {
        profile.name = "stockly-romainc-bureau";
        profile.outputs = [
          { criteria = "eDP-1"; mode = "1920x1080"; position = "0,360"; }
          { criteria = "HDMI-A-1"; mode = "2560x1440"; position = "1920,0"; }
        ];
        profile.exec = [
          ''systemctl --user restart waybar''
          ''systemctl --user restart wallpapers-manager''
          ''sh -c "echo stockly-romainc-bureau > ${config.home.homeDirectory}/.config/kanshi/current"''
        ];
      }
      {
        profile.name = "stockly-bureau-1";
        profile.outputs = [
          { criteria = "eDP-1"; mode = "1920x1080@60Hz"; position = "0,0"; }
          { criteria = "HDMI-A-1"; mode = "2560x1440"; position = "1920,0"; }
        ];
        profile.exec = [
          ''systemctl --user restart waybar''
          ''systemctl --user restart wallpapers-manager''
          ''sh -c "echo stockly-bureau-1 > ${config.home.homeDirectory}/.config/kanshi/current"''
        ];
      }
      {
        profile.name = "stockly-tom";
        profile.outputs = [
          { criteria = "HDMI-A-1"; mode = "2560x1440"; position = "0,0"; }
          { criteria = "eDP-1"; mode = "1920x1080"; position = "2560,0"; }
        ];
        profile.exec = [
          ''systemctl --user restart waybar''
          ''systemctl --user restart wallpapers-manager''
          ''sh -c "echo stockly-tom > ${config.home.homeDirectory}/.config/kanshi/current"''
        ];
      }
      {
        profile.name = "zizou";
        profile.outputs = [
          { criteria = "eDP-1"; mode = "1920x1080"; position = "0,0"; }
          { criteria = "HDMI-A-1"; mode = "2560x1440"; position = "1920,0"; }
        ];
        profile.exec = [
          ''systemctl --user restart waybar''
          ''systemctl --user restart wallpapers-manager''
          ''sh -c "echo zizou > ${config.home.homeDirectory}/.config/kanshi/current"''
        ];
      }
      {
        profile.name = "factory-s";
        profile.outputs = [
          { criteria = "eDP-1"; mode = "1920x1080"; position = "0,360"; }
          { criteria = "HDMI-A-1"; mode = "2560x1440"; position = "1920,0"; }
        ];
        profile.exec = [
          ''systemctl --user restart waybar''
          ''systemctl --user restart wallpapers-manager''
          ''sh -c "echo factory-s > ${config.home.homeDirectory}/.config/kanshi/current"''
        ];
      }
      {
        profile.name = "salon0";
        profile.outputs = [
          { criteria = "HDMI-A-0"; mode = "1920x1080"; position = "0,0"; }
        ];
        profile.exec = [
          ''systemctl --user restart waybar''
          ''systemctl --user restart wallpapers-manager''
          ''sh -c "echo salon0 > ${config.home.homeDirectory}/.config/kanshi/current"''
        ];
      }
      {
        profile.name = "salon2";
        profile.outputs = [
          { criteria = "HDMI-A-2"; mode = "1920x1080"; position = "0,0"; }
        ];
        profile.exec = [
          ''systemctl --user restart waybar''
          ''systemctl --user restart wallpapers-manager''
          ''sh -c "echo salon2 > ${config.home.homeDirectory}/.config/kanshi/current"''
        ];
      }
      {
        profile.name = "grenoble-yohan";
        profile.outputs = [
          { criteria = "eDP-1"; mode = "1920x1080"; position = "0,0"; }
          { criteria = "HDMI-A-1"; mode = "1920x1080"; position = "1920,0"; }
        ];
        profile.exec = [
          ''systemctl --user restart waybar''
          ''systemctl --user restart wallpapers-manager''
          ''sh -c "echo grenoble-yohan > ${config.home.homeDirectory}/.config/kanshi/current"''
        ];
      }
    ];
  };

  wayland.windowManager.sway.config.keybindings = lib.mkOptionDefault {
    "${config.byDb.modifier}+Shift+a" = "exec kanshictl reload";
  };
}
