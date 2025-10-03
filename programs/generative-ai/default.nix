{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfgUser = config.home-manager.users.${config.by-db.user.name};
  homeDir = cfgUser.home.homeDirectory;
  comfyuiDir = "${homeDir}/ai/comfyui";
in
{
  config = lib.mkIf config.by-db.generativeAi.enable {
    services = {
      ollama = {
        enable = true;
        acceleration = "cuda";
        loadModels = [
          "llama3"
          "codellama"
        ];
      };
    };

    virtualisation.docker.enable = true;

    environment = {
      systemPackages = with pkgs; [
        docker
        nvidia-container-toolkit
      ];
    };

    users = {
      groups.comfyshare = { };
      users = {
        ${config.by-db.user.name} = {
          extraGroups = [
            "docker"
            "comfyshare"
          ];
        };
        comfyui = {
          uid = 10001;
          isSystemUser = true;
          group = "comfyshare";
        };
      };
    };

    systemd.services.comfyui = {
      description = "ComfyUI Docker container";
      after = [
        "docker.service"
        "network.target"
      ];
      requires = [ "docker.service" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.docker}/bin/docker run \
            --rm \
            --device nvidia.com/gpu=all \
            -p 8188:8188 \
            -v ${comfyuiDir}:/opt/comfyui \
            --group-add 1000 \
            --name comfyui \
            jamesbrink/comfyui
        '';
        ExecStop = "${pkgs.docker}/bin/docker stop comfyui";
        Restart = "always";
        RestartSec = 10;
      };

      wantedBy = [ "multi-user.target" ];
    };

    system.activationScripts.comfyShareDirs = {
      text = ''
        shared="${comfyuiDir}"

        mkdir -p "$shared"
        chown -R 10001:comfyshare "$shared"
        chmod -R 2770 "$shared"
        chmod -R g+rwX "$shared"
      '';
    };

  };

}
