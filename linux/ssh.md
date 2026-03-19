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

## FIDO2 SSH Key (ed25519-sk)

Uses [[solo2]] hardware key. Non-resident (key file stored on disk).
Both SoloKeys work with the same key file.

### Generate key

```bash
ssh-keygen -t ed25519-sk -O verify-required
# PIN prompt → touch SoloKey
# saves to ~/.ssh/id_ed25519_sk
```

### Enroll second SoloKey

```bash
ssh-keygen -t ed25519-sk -O verify-required -O application=ssh: -u -f ~/.ssh/id_ed25519_sk
# touch second SoloKey when prompted
```

### Add to GitHub

```bash
cat ~/.ssh/id_ed25519_sk.pub
# paste into GitHub → Settings → SSH keys
```

### Test

```bash
ssh -T git@github.com
```

### ssh-agent + passphrase

```bash
# Start agent
eval $(ssh-agent)

# Add key (prompts for passphrase + SoloKey touch)
ssh-add ~/.ssh/id_ed25519_sk
```

Auto-start ssh-agent via `~/.bashrc` or `~/.zshrc`:
```bash
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval $(ssh-agent -s)
fi
```



