`ssh -w 0:0`  layer2 connectoin 

`ssh root@router`

`ssh-audit root@router` 
`ssh-audit github.com`
check encryption , sec breaches, fingerprints and so on. 


`~/.s/config` config for ssh. 

`TCPKeepAive` 
`ServerAliveInterval`
`ObscureKeystrokeTiming` interval:80, you can attack via statistical analisis. with this setting we obfuscate sending packages to avoid thes attack vector. 

Adding aliases
```
Host sharebox
  HostName               gitlab...com
```

vim ~/.ssh/config

Windosws

`mobaXterm` win ssh client better than putty
included xserver
czgwin, with portableserver
builtin clickybased filebrowsing client

ipsec is waste of time, use wireguard. 


another program. 
`ssh tummel` 


terminal sharing

share terminal sessaion, `upterm`, `tmate`


MOSH, not recommendet, because of systemd
- traveling much, and have shitty internet, check it out. 


2fa, resident key. 

yubiky 
github.com drduh/yubikey-guide



