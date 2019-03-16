#Archlinux

Upgrade system 
--------------

`pacman -Syu`

alternattive check for upgrade, upgrade
`pacman -Sy`, `pacman -Syy` force upgrade even if up to date 
`pacman -Su` upgrade

Fix VM Broke Archlinux grub
---------------------------

`mount /dev/sda3 /mnt` 
`mount /dev/sda1 /mnt/boot` 
`grub-install --target=x86_64-efi --efi-directory=/mnt/boot 
--root-directory=/mnt --recheck`

originaly I just made 
`grub-install --target=x86_64-efi --efi-directory=/boot`
