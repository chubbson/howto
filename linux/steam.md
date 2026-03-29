# Steam on Arch Linux

Tags: #steam #gaming #nvidia #prime

## Installation

### With NVIDIA eGPU (580xx AUR driver)

The standard `lib32-nvidia-utils` from multilib conflicts with `nvidia-580xx-utils`. Install the AUR equivalent first:

```
yay -S lib32-nvidia-580xx-utils
sudo pacman -S steam
```

If you install Steam first and get prompted for `lib32-vulkan-driver`, pick `lib32-nvidia-580xx-utils` from the list — but it won't be listed unless already installed.

> `lib32-nvidia-utils` (multilib) conflicts with `nvidia-580xx-utils` (AUR) via `nvidia-libgl`. Do **not** replace — it will break the eGPU driver.

### Without eGPU / with standard nvidia driver

```
sudo pacman -S steam
```

Pick `lib32-nvidia-utils` when prompted for `lib32-vulkan-driver`.

## Running Games on eGPU (PRIME Offload)

Set per-game launch option in Steam:

```
prime-run %command%
```

Or run Steam itself on the eGPU:

```
prime-run steam
```

`prime-run` sets `__NV_PRIME_RENDER_OFFLOAD=1`, `__GLX_VENDOR_LIBRARY_NAME=nvidia`, `__VK_LAYER_NV_optimus=NVIDIA_only` — forces the process onto the NVIDIA GPU, rendered output goes through the iGPU display pipeline (laptop screen).

## Related

- [[egpu]] - eGPU setup and PRIME configuration
- [[p14s]] - system overview
