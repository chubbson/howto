# Kernel Update Prompt

Use this prompt with Claude Code after running `sudo pacman -Syu` or `yay -Syu` when a new kernel version is installed.

---

**Prompt:**

```
I just ran a system update and the kernel changed from X.X.X to X.X.X.

Please update linux/kernel.md:
1. Update the "Current Version" line with the new version and today's date
2. If this is a new major/minor version (e.g. 7.0 → 7.1 or 7.x → 8.x):
   - Look up the release highlights on https://kernelnewbies.org/Linux_X.X
   - Replace the major release highlights section with the new version's highlights
3. If this is a patch release (e.g. 7.0.9 → 7.0.12):
   - Look up the changelogs at https://cdn.kernel.org/pub/linux/kernel/vX.x/ChangeLog-X.X.Y
     for each new patch version between old and new
   - Add the notable fixes as new entries under "Patch History"
```

---

Replace both `X.X.X` placeholders with the old and new kernel versions from the pacman output.

---

## TODO

- [ ] Write a Claude Code agent (hook) that runs automatically after `pacman -Syu` / `yay -Syu`, detects if the kernel version changed, and updates `linux/kernel.md` without manual intervention.
