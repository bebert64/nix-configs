{
  config,
  home-manager,
  lib,
  pkgs,
  ...
}:

let
  comfyuiHome = "/home/${config.by-db.user.name}/SD/comfyui";
  containerName = "comfyui";
  imageName = "ghcr.io/comfyanonymous/comfyui:latest";
  updateAndRun = pkgs.writeScriptBin "update-and-run" ''
    #!/usr/bin/env bash
    IMAGE="${imageName}"
    CONTAINER_NAME="${containerName}"

    # Stop and remove existing container if running
    if podman ps -a --format "{{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
        podman stop $CONTAINER_NAME
        podman rm $CONTAINER_NAME
    fi

    # Run container (foreground, logs to systemd)
    podman run \
      --name $CONTAINER_NAME \
      --security-opt=label=disable \
      --hooks-dir=/usr/share/containers/oci/hooks.d/ \
      -p 8188:8188 \
      -v ~/comfyui/models:/root/ComfyUI/models \
      -v ~/comfyui/outputs:/root/ComfyUI/outputs \
      $IMAGE
  '';
  updateImage = pkgs.writeScriptBin "update-image" ''
    #!/usr/bin/env bash
    IMAGE="${imageName}"
    CONTAINER_NAME="${containerName}"

    # Pull latest image
    OUTPUT=$(podman pull $IMAGE)

    # Restart container only if a new image was pulled
    if echo "$OUTPUT" | grep -q "Downloaded newer image"; then
        echo "New image detected, restarting container..."
        if podman ps -a --format "{{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
            podman stop $CONTAINER_NAME
            podman rm $CONTAINER_NAME
        fi
        ${updateAndRun}/bin/update-and-run
    else
        echo "No new image, container remains running."
    fi
  '';
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

    virtualisation.podman = {
      enable = true;
      dockerCompat = true; # optional
    };

    environment.systemPackages = with pkgs; [
      podman
      nvidia-container-toolkit
    ];

    home-manager.users.${config.by-db.user.name} = {
      programs.zsh.shellAliases = {
        mnas = "mount-nas";
        umnas = "unmount-nas";
      };
      home.activation = {
        symlinkMountDirNas = home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p ${comfyuiHome}/models
          mkdir -p ${comfyuiHome}/outputs
        '';
      };
    };

    # -------------------------------
    # 2. User-level systemd services
    # -------------------------------
    systemd.user.services.comfyui = {
      description = "ComfyUI Container Service";
      after = [ "network.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${updateAndRun}/bin/update-and-run";
        ExecStop = "/run/current-system/sw/bin/podman stop ${containerName}";
        ExecStopPost = "/run/current-system/sw/bin/podman rm ${containerName}";
        Restart = "always";
        RestartSec = 10;
        StandardOutput = "journal";
        StandardError = "journal";
        TimeoutStopSec = 30;
      };
      wantedBy = [ "default.target" ];
    };

    systemd.user.services.comfyui-update = {
      description = "Update ComfyUI Container Image if needed";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${updateImage}/update-image";
      };
    };

    systemd.user.timers.comfyui-update = {
      description = "Run ComfyUI Image Update Daily";
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
      };
      wantedBy = [ "timers.target" ];
    };
  };
}
