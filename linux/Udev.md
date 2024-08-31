[[arch]]: https://wiki.archlinux.org/title/Udev

to define access for devices without using of sudo. 

udev rules written by Administrator are in `/etc/udev/rules.d/` .their file name has to end with *.rules*.
udev rules shipped with various packages are in `/usr/lib/udev/rules.d/`

*if rules have same name, `/etc` wins over `/etc/lib`*