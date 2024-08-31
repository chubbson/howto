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
get script with `solo2 completion zsh > ~/.oh-my-zsh/custom/plugins/solo2-completion/solo2-completion.plugin.zsh`

