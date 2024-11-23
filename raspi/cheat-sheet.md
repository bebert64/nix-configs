Raspi

Build image
nix build .#nixosConfigurations.raspi.config.system.build.sdImage

copy img to SD card (can also use rpi-imager)
sudo dd if=nixos-sd-image-23.05pre482417.9c7cc804254-aarch64-linux.img of=/dev/sdX r

backup sd card
sudo dd if=/dev/sdX of=raspi.img bs=4096 conv=fsync status=progress

deploy remotely (might need to also git pull from nix-configs to update symlinks)
nix-rebuild switch --target-host raspi --build-host localhost --use-remote-sudo --flake .#raspi