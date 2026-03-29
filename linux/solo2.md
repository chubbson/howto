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

### Enroll additional SoloKey

```bash
pamu2fcfg -n >> ~/.config/Yubico/u2f_keys
# touch SoloKey when prompted
```

> Always enroll at least 2 keys. Running on a single key means a dead/locked key locks you out.

### Check enrolled keys

```bash
cat ~/.config/Yubico/u2f_keys
# count entries: each key = one colon-separated block ending in es256,+presence
fido2-token -L   # list physically connected tokens
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

> **Warning:** Use `sufficient`, not `required`, unless you are certain both keys work. `required` with a broken/locked key = locked out of sudo.
> **Warning:** Test in a separate terminal before closing your session — a broken PAM config can lock you out.

## If a key is lost/bricked — re-enroll checklist

- [x] Gmail
- [x] Proton
- [x] GitHub
- [ ] Microsoft
- [ ] GitLab
- [x] PAM (`pamu2fcfg -n >> ~/.config/Yubico/u2f_keys`)

## Diagnostics

```bash
fido2-token -L                    # list detected FIDO2 tokens
fido2-token -I /dev/hidrawX       # show token info, PIN retries, capabilities
```

Key PIN retry count is shown as `pin retries: N`. When it hits 0 the key is locked and must be reset.

## PIN Locked / Reset

If `pin retries: 0` — the key is fully locked and must be factory reset. **Reset wipes all resident credentials on the key.** External service registrations (websites, PAM) are unaffected but the key must be re-enrolled everywhere.

### Reset procedure

The Solo2 only allows reset within ~10 seconds of plugging in. Run the command immediately after plugging in and touch the key when it waits:

```bash
# Unplug, replug, then immediately:
fido2-token -R /dev/hidraw0
# touch the key when it waits
```

### Set new PIN after reset

After reset there is no PIN — use `-S` (set), not `-C` (change):

```bash
fido2-token -S /dev/hidraw0
# minimum 4 characters
```

### Re-enroll in PAM after reset

```bash
pamu2fcfg -n >> ~/.config/Yubico/u2f_keys
```

### Test

```bash
sudo echo test
# should prompt for touch, not password (if PAM configured)
```
