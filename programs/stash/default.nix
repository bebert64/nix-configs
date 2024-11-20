{ nixpkgs-unstable, pkgs, ... }:
let
  overlay-unstable = final: prev: {
    unstable = nixpkgs-unstable.legacyPackages.aarch64-linux;
  };
in
{
  home.packages = [ pkgs.unstable.stash ];

  nixpkgs.overlays = [ overlay-unstable ];

  # systemd.user =  {
  #           enable = true;
  #           services = {
  #             test = {
  #               Unit = {
  #                 Description = "Chooses walpaper(s) based on the number of monitors connected";
  #               };
  #               Service = {
  #                 Type = "exec";
  #                 ExecStart = "${package}/bin/wallpapers-manager change ${cfg.service.commandArgs}";
  #               };

  #             };
  #           };
  #           timers = {
  #             wallpapers-manager = {
  #               Unit = {
  #                 Description = "Timer for wallpapers-manager";
  #               };
  #               Timer = {
  #                 Unit = "wallpapers-manager.service";
  #                 OnUnitInactiveSec = "1h";
  #               };
  #               Install = {
  #                 WantedBy = [ "timers.target" ];
  #               };
  #             };
  #           };
  #         };
}
