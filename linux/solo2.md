Tags: #Instalation, #HardwareKey, #solo2

Links: [[HardareKey]] 

[[Install]]ation:

## define [[Udev]] rule

* Define rules for solo2: https://github.com/solokeys/solo2-cli/blob/main/70-solo2.rules 
* Define these rule on administrator level `/etc/udev`
* with:
  `sudo curl -L -o /etc/udev/rules.d/70-solo2.rules https://raw.githubusercontent.com/solokeys/solo2-cli/main/70-solo2.rules`

## add solo2 completion script

### oh-my-zsh

use `/.oh-my-zsh/custom/plugins/my_completion/` my script. 
get script with `mkdir ~/.oh-my-zsh/custom/plugins/solo2-completion && solo2 completion zsh > ~/.oh-my-zsh/custom/plugins/solo2-completion/solo2-completion.plugin.zsh`

add plugin into .zshrc
`plugins=(... solo2-completion)`

## PAM FIDO2 (login / sudo)

Use SoloKey to authenticate for login and sudo. See [[ssh]] for SSH key setup.

### Install

```bash
sudo pacman -S pam-u2f
```

### Register key

```bash
mkdir -p ~/.config/Yubico
pamu2fcfg > ~/.config/Yubico/u2f_keys
# PIN prompt → touch SoloKey
```

### Enroll second SoloKey

```bash
pamu2fcfg -n >> ~/.config/Yubico/u2f_keys
# touch second SoloKey when prompted
```

### Configure PAM

Edit `/etc/pam.d/sudo` to require SoloKey:

```
auth required pam_u2f.so
```

Or use `sufficient` to allow either SoloKey OR password:

```
auth sufficient pam_u2f.so
```

Do the same for `/etc/pam.d/login` for console login.

> **Warning:** Test in a separate terminal before closing your session — a broken PAM config can lock you out.

