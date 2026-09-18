
running kalix linux

sudo systemctl start postrgersql

systemctl status postgresql

-------------------------

#MetaSpoint DB & konwol3

sudo `msfdb init`

`msfconsole`

msf > `db_status`

msf > `msfupdate`

msf > `show expoits`

------------------------

WIFI: `PinkManner`    5Ghz
`PinkMannerLegacy`  2.4Ghz

Target: `192.168.1.42`

----

`nmap -sS -Pn 192.168.1.42`

also work for ip range. 

---------

`nmap -T4 -sV --version-all --osscan-guess -A 192.168.1.42`

`nmap -sV --osscan-guess -p 1-10000 192.168.1.42`

* http://192.168.1.42:8585/wordpress
open in browser to find out withch plugins this wordpress instance is using. 
can you find ouy the wordpress version using only your webbrowser.

-----

crtl+u to show the source code. on browser. 





