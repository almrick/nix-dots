# nix-dots

## Install
```
##
## Partitioning the disk
##
- sudo gdisk /dev/sdX
    - o (Create a new GPT)
    - n (Create the EFI partition)
        - <default>
        - <default>
        - +300M
        - ef00
    - n (Create the LVM partition)
        - <default>
        - <default>
        - <default>
        - 8e00
    - w (Save the changes)

##
## Setting up LUKS encryption and opening it
##
- sudo cryptsetup -v -y -c aes-xts-plain64 -s 512 -h sha512 -i 8000 \
    --use-random --label=NIXOS_LUKS luksFormat --type luks2 /dev/sdX2
- sudo cryptsetup open --type luks /dev/sdX2 cryptroot

##
## Partition the LVM volume
##
- sudo pvcreate /dev/mapper/cryptroot
- sudo vgcreate lvmroot /dev/mapper/cryptroot
- sudo lvcreate -L16G lvmroot -n swap
- sudo lvcreate -L96G lvmroot -n root
- sudo lvcreate -l 100%FREE lvmroot -n home

##
## Formattting the partitions
##
- sudo mkfs.fat -n NIXOS_BOOT -F32 /dev/sdX1
- sudo mkfs.ext4 -L NIXOS_ROOT /dev/mapper/lvmroot-root
- sudo mkfs.ext4 -L NIXOS_HOME /dev/mapper/lvmroot-home
- sudo mkswap -L NIXOS_SWAP /dev/mapper/lvmroot-swap

##
## Mounting the partitions
##
- sudo mount /dev/disk/by-label/NIXOS_ROOT /mnt
- sudo mkdir /mnt/boot
- sudo mkdir /mnt/home
- sudo mount -o umask=0077 /dev/disk/by-label/NIXOS_BOOT /mnt/boot
- sudo mount /dev/disk/by-label/NIXOS_HOME /mnt/home
- sudo swapon -L NIXOS_SWAP

##
## Installing NixOS
##
- sudo nixos-install --root /mnt --no-root-passwd --flake github:almrick/nix-dots#cave
- sudo nixos-enter --root /mnt -c 'passwd almrick'

##
## Cleanup
##
- sudo umount -R /mnt
- sudo swapoff -L NIXOS_SWAP
- sudo vgchange -a n lvmroot
- sudo cryptsetup close /dev/mapper/cryptroot
- reboot
```
