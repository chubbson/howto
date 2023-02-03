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

if delay is unavoidable and system upgrade gets delayed for an extended period, manually sync the package database and upgrade the [archlinux-keyring](https://archlinux.org/packages/?name=archlinux-keyring) package before system upgrade:
https://wiki.archlinux.org/title/Pacman/Package_signing

`pacman -Sy archlinux-keyring`
`pacman -Su`
alternative 

`pacman -Sy archlinux-keyring && pacman -Su`

Folgendes schient nicht zu funktionieren: 
---
1. Clean cached packages 
   https://wiki.archlinux.org/title/Pacman/Package_signing
   `pacman -Sc`
2. Refresh keyring
   `pacman-key --refresh-keys`

An alternative is resetting all keys
https://wiki.archlinux.org/title/Pacman/Package_signing#Resetting_all_the_keys

1. remove `/etc/pacman.d/gnupg`
2. `pacman-key --init
3. `pacman-key --populate`



Fix VM Broke Archlinux grub
---------------------------

`mount /dev/sda3 /mnt`   
`mount /dev/sda1 /mnt/boot`   
`grub-install --target=x86_64-efi --efi-directory=/mnt/boot 
--root-directory=/mnt --recheck`

originaly I just made  
`grub-install --target=x86_64-efi --efi-directory=/boot`

[[Install]]

