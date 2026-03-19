#Archlinux

Upgrade system 
--------------

`pacman -Syu`

never run `pacman -Sy` alway usse  `pacman -Syu`  
`pacman -Syyu` force upgrade even if up to date. 

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

Folgendes scheint nicht zu funktionieren: 
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

Troubleshooting
---------------

Gnome broken. Stuck on boot.

If you get stuck on boot for graphical.target you can enhance logging on boot.

Followin options: 

1. On GNU Grub screen - press e on `Archlinux linux` to modify set params. Look for linux /vmlinuz/linux root=UUID=xxxx-xxxx rw loglevel=3

you can modify it in several ways. add what you want. 

* `loglevel=3 quiet` remove quiet, to get output.
* `loglevel=7` gives you full log output.
* `system.debug_shell=1` gives you debug tty accessable with ctrl+alt F9. 
* `system.unit=rescue.target` you start in maintenance/rescue mode where you can fix configs.
* `system.unit=multi-user.target` starts in console mode without Graphics but with Network and everything you need. i guess with Bluetoot as well. but if it doesnt word try to start the service with `systemctl start bluetooth.service.
* `init=/bin/bash` you directly start a bash without loading stuff. (i guess)

2. It you want modify grup default config permanent you can try following

* open grup config `sudo nano /etc/default/grub`
* edit `GRUB_CMDLINE_LINUX_DEFAULT`
* update grub by make from cfg `sudo grub-mkconfig -o /boot/grub/grub.cfg`

3. if you have debug console enabled you can enter it with `ctrl+alt+F9`

4. changing to other tty by `ctrl+alt`+`F1`-`F6` multi-user mode. 

5. `systemctl get-default` returns current type. 

6. `systemctl set-default` can be used to change default mode like `multi-user.target`

7. `sudo journalctl -b -1` analise logs from last (which failed). 

20251030 - Broken GDM (GnomeDesktopManager)
-------------------------------------------

after `pacman -Syu` gnome didnt started. i had to add gdm-greeter to `etc/shadow` file. 

* `sudo nano /etc/shadow`
* add at the end `gdm-greeter:!*:0::::::` - `*!` means user needs no password. `0` means days since 1970.

