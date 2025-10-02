{
  config,
  home-manager,
  lib,
  pkgs,
  ...
}:
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
          ];
        };
        comfyui = {
          uid = 10001;
          isSystemUser = true;
          group = 10001;
          extraGroups = [ "comfyshare" ];
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
            -v /home/romain/SD/shared/user:/opt/comfyui/user \
            -v /home/romain/SD/shared/models:/opt/comfyui/models \
            -v /home/romain/SD/shared/output:/opt/comfyui/output \
            -v /home/romain/SD/shared/input:/opt/comfyui/input \
            -v /home/romain/SD/shared/temp:/opt/comfyui/temp \
            -v /home/romain/SD/shared/custom_nodes:/opt/comfyui/custom_nodes \
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
        shared="/home/romain/SD/shared"
        subdirs="user models output input temp custom_nodes"

        mkdir -p "$shared"
        chown 10001:comfyshare "$shared"
        chmod 2770 "$shared"

        for d in $subdirs; do
          mkdir -p "$shared/$d"
          chown 10001:comfyshare "$shared/$d"
          chmod 2770 "$shared/$d"
        done
      '';
    };

  };

}
