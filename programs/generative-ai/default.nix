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
    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        # runtimes = {
        #   nvidia = {
        #     path = "${pkgs.nvidia-container-toolkit}/bin/nvidia-container-runtime";
        #     runtimeArgs = [ ];
        #   };
        # };
        # default-runtime = "nvidia";
      };

    };

    environment = {
      systemPackages = with pkgs; [
        docker
        nvidia-container-toolkit
      ];
    };

    users.users.${config.by-db.user.name} = {
      extraGroups = [
        "docker"
      ];
    };
  };
}
