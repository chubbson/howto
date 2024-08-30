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

`mobaxterm` win ssh client better than putty
