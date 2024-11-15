#!/usr/bin/env bash
set -euo pipefail

loadkeys fr
mount /dev/sda4 /mnt
mount /dev/sda3 /mnt/boot
swapon /dev/sda2
arch-chroot /mnt
