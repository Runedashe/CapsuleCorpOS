# CapsuleCorpOS v2.0

**Standalone Linux OS by Crystal Globe Pty Ltd**
**Inventor: Shabeen Ashfak (Android #23) | ABN 52 635 620 343**

---

## What is CapsuleCorpOS?

CapsuleCorpOS is a custom Debian-based standalone operating system built for the Crystal Globe ecosystem. It features a cyberpunk-themed RUBY terminal, AVIS-S G347 mother vessel integration, and a full suite of Crystal Globe tools.

## Features

- RUBY Terminal Shell v3.2.0 -- cyberpunk themed, full command environment
- TUI Dashboard -- 13 panels including Grid status, G347 telemetry, patent tracker
- ccpkg -- Crystal Globe package manager (install, remove, update, store)
- ccos-monitor -- real-time CPU, RAM, disk, network monitor
- ccos-vault -- AES-256 encrypted file storage
- avis-connector -- live G347 Crystal Globe mother vessel telemetry
- udev peripheral auto-registration (REG_A001 through REG_B004)
- CG-SIL v1.0 Disk Itemisation Law
- Plymouth boot splash
- i3 window manager

## Build

Run on Ubuntu 22.04 / 24.04 or Debian 12:

```bash
sudo bash BUILD.sh
```

Output: `CapsuleCorpOS-v2.0.iso`

## Structure

```
capsulecorp_os/
  BUILD.sh                          -- ISO build script
  UPGRADES.md                       -- v2.0 upgrade log
  tui/ccos-dashboard.sh             -- TUI dashboard (13 panels)
  rootfs/opt/capsulecorp/bin/
    ccpkg                           -- Package manager
    ccos-monitor                    -- System monitor
    ccos-vault                      -- Encrypted vault
    avis-connector                  -- G347 telemetry
    ruby-shell.sh                   -- RUBY terminal
  rootfs/opt/capsulecorp/terminal/
    ruby-shell.sh                   -- RUBY shell entry
```

## Crystal Globe Ecosystem

| Component | Status |
|-----------|--------|
| G347 Mother Vessel | Specced, ESA BIC submission June 10 |
| AVIS-S AI | 8 modules, source code complete |
| RRA Androids | Firmware v0.4.9, 25 modules |
| Patents Filed | 12 provisional (IP Australia) |

## License

Crystal Globe Pty Ltd -- All Rights Reserved
Inventor: Shabeen Ashfak | ABN 52 635 620 343
