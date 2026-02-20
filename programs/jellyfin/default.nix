{
  pkgs,
  config,
  ...
}:
let
  homeDirectory = config.byDb.hmUser.home.homeDirectory;

  # Instance names
  jellyfinInstance1 = "guitar";
  jellyfinInstance2 = "media";

  # Helper function to create a Jellyfin service
  mkJellyfinService =
    instanceName: port:
    let
      dataDir = "${homeDirectory}/.local/share/${instanceName}";
      configDir = "${homeDirectory}/.config/${instanceName}";
    in
    {
      Unit = {
        Description = "Jellyfin ${instanceName}";
      };
      Service = {
        Type = "simple";
        Restart = "on-failure";
        ExecStart = "${pkgs.jellyfin}/bin/jellyfin --configdir ${configDir}";
        Environment = [
          "PATH=/run/current-system/sw/bin/:${homeDirectory}/.nix-profile/bin/"
          "JELLYFIN_DATA_DIR=${dataDir}"
        ];
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
in
{
  home.packages = with pkgs; [
    jellyfin
    jellyfin-web
    ffmpeg
    yt-dlp
  ];

  systemd.user = {
    enable = true;
    services.${jellyfinInstance1} = mkJellyfinService jellyfinInstance1 8096;
    services.${jellyfinInstance2} = mkJellyfinService jellyfinInstance2 8097;
  };

}
