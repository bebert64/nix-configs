# Setup a new raspberry

Build image

```
nix build .#nixosConfigurations.raspi.config.system.build.sdImage
```

Check the correct dev identifier with `lsblk`

Copy img to SD card (can also use rpi-imager)

```
sudo dd if=/path/to/image.img of=/dev/sdX r bs=4096 conv=fsync status=progress
```
