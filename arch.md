#Archlinux

Upgrade system 
--------------

`pacman -Syu`

never run `pacman -Sy` alway usse  `pacman -Syu`  
`pacman -Syyu` force upgrade even if up to date  

Import PGP key 
-----------

`:: Import PGP key 7AABBEEFF11225C, "Simon Salz <salz@archlinux.org>"? [Y/n]`

Never import keyring. 
1. Clean cached packages 
   https://wiki.archlinux.org/title/Pacman/Package_signing
   `pacman -Sc`
2. Refresh keyring
   `pacman-key --refresh-keys`
3. 

Fix VM Broke Archlinux grub
---------------------------

`mount /dev/sda3 /mnt`   
`mount /dev/sda1 /mnt/boot`   
`grub-install --target=x86_64-efi --efi-directory=/mnt/boot 
--root-directory=/mnt --recheck`

originaly I just made  
`grub-install --target=x86_64-efi --efi-directory=/boot`

[[Install]]

