# HP ProBook 450 G7 — OpenCore Hackintosh for macOS Tahoe

[![macOS](https://img.shields.io/badge/macOS-Tahoe-333333?logo=apple)](https://github.com/AntonioR-dev/HP-ProBook-450-G7-Hackintosh/releases/tag/v1.0.0)
[![OpenCore](https://img.shields.io/badge/Bootloader-OpenCore-blue)](https://github.com/acidanthera/OpenCorePkg)
[![Release](https://img.shields.io/badge/Release-v1.0.0-brightgreen)](https://github.com/AntonioR-dev/HP-ProBook-450-G7-Hackintosh/releases/tag/v1.0.0)

An OpenCore EFI configuration developed and tested on an **HP ProBook 450 G7** with **Intel Core i7-10610U**, targeting **macOS Tahoe 26.x**. The project aims to make the laptop practical as a daily-use macOS machine: working graphics, networking, external displays, audio, Apple ecosystem features, and custom fixes for HP-specific hardware.

> **Hardware-specific project:** this is not a universal HP ProBook EFI. Review every ACPI patch, kext, and SMBIOS setting before using it on another machine.

## Project at a glance

| Item | Configuration |
| --- | --- |
| Laptop | HP ProBook 450 G7 |
| CPU | Intel Core i7-10610U |
| Operating system | macOS Tahoe 26.x (tested project installation: 26.7.3) |
| Bootloader | OpenCore |
| SMBIOS | MacBookPro16,2 |
| Wireless adapter | **Intel AX210** — replacement for the original Wi-Fi card |
| Wireless integration | ForbiddenItlwm-based configuration |

The original Wi-Fi module was replaced with an **Intel AX210** both to improve wireless/Bluetooth stability and to make use of the **ForbiddenItlwm** project. The published EFI is intended for this modified hardware configuration; do not assume it will work with the factory wireless card.

## Feature status

Results reported for the project laptop, not guaranteed for other hardware revisions.

| Feature | Status / notes |
| --- | --- |
| macOS boot | OpenCore boots macOS; 5-second picker timeout |
| Internal display | Working, including macOS brightness adjustment |
| Brightness shortcuts | Project includes a dedicated **F3/F4 ACPI hotkey patch**; see the verification note below |
| Keyboard | Internal keyboard with Italian PC layout |
| Ethernet | Realtek Gigabit Ethernet, negotiated at **1000BASE-T full duplex**; a faulty cable was the cause of earlier link issues |
| Wi-Fi and Bluetooth | Stable after Intel AX210 replacement |
| HDMI | External video output tested |
| USB-C DisplayPort | External DisplayPort output tested |
| Audio output | Working |
| Internal microphone | Working with a **separately built, HP-adapted LatSOFAudio kext**, not simply the standard audio configuration |
| Apple services | iCloud, App Store, iMessage, FaceTime, AirDrop (both directions), and Handoff tested |
| Continuity | Reported working on this installation |

### Important: brightness patch verification

The published project's original v1.0.0 README describes **F3 = brightness down** and **F4 = brightness up** without Fn. Earlier experimental WMI patches did **not** fix these keys on the same laptop. The source below documents the later `SSDT-HPBRT` implementation; the exact released binary's behavior has not been independently reverified during this documentation update. Please test F3/F4 on your own device and report discrepancies. macOS brightness control through **Fn+C / Fn+W** was independently reported working.

## Custom fixes

### 1. HP F3/F4 brightness hotkeys — `SSDT-HPBRT`

HP firmware exposes embedded-controller queries `_Q87` and `_Q86`. The project-specific SSDT replaces the macOS-side handling of these methods (using ACPI method renaming to preserve the firmware methods as `ZQ87` and `ZQ86`).

- **F3 / `_Q87`** sends `Notify (\\_SB.PCI0.LPCB.PS2K, 0x0346)`, emulating the already-working **Fn+C / brightness down** path.
- **F4 / `_Q86`** sends `Notify (\\_SB.PCI0.LPCB.PS2K, 0x0445)`, emulating **Fn+W / brightness up**.
- Outside macOS, the original renamed firmware methods remain callable through the `Else` branches.

Source: [`Sorgente/SSDT-HPBRT.dsl`](Sorgente/SSDT-HPBRT.dsl). For the logic and testing limitations, see [Brightness hotkeys documentation](docs/BRIGHTNESS-HOTKEYS.md).

**This patch is hardware-specific.** It relies on the correct OpenCore ACPI rename configuration, device paths and the existing PS/2 keyboard driver. Do not combine it with earlier WMI test SSDTs.

### 2. Internal digital microphone — custom LatSOFAudio

The internal microphone needed a **modified LatSOFAudio implementation**: ordinary audio-output support alone did not provide a working internal digital microphone.

The HP-specific development focused on enabling the **Intel SOF digital-microphone capture path**, including firmware and DSP initialization, protecting coexistence with macOS **AppleHDA**, and preventing unsupported playback / RT5682 paths from interfering with working speaker and headphone audio. Development included *capture-only*, PCI/coexistence guards, and later experimental gain and sleep/wake variants.

**Distribution caveat:** the exact tested LatSOFAudio binary is **separate from the EFI**, and the repository does not yet identify a reproducible source revision plus matching firmware for that known-working binary. The source experiments are not interchangeable with a verified production build, especially for sleep/wake handling.

Read [Internal microphone and LatSOFAudio notes](docs/INTERNAL-MICROPHONE.md) before rebuilding or installing this kext.

## Download and installation

Download the [**v1.0.0 release**](https://github.com/AntonioR-dev/HP-ProBook-450-G7-Hackintosh/releases/tag/v1.0.0) and inspect its EFI folder before copying it to your ESP.

1. **Back up** your current working EFI and prepare a bootable USB recovery option.
2. Inspect your hardware configuration. This project uses an **Intel AX210**, not the factory Wi-Fi module.
3. In `EFI/OC/config.plist`, populate `PlatformInfo -> Generic` with **your own** `MLB`, `ROM`, `SystemSerialNumber` and `SystemUUID`, appropriate for the configured SMBIOS.
4. Test the EFI **from USB first**; then verify boot, graphics, networking, audio, sleep and hotkeys.
5. Do not install an experimental microphone kext or experimental brightness SSDT on top of the working configuration without confirming compatibility and keeping a rollback path.

**Never reuse someone else's serialized Apple platform identifiers.**

## Repository structure

```text
README.md                         Project overview and feature matrix
Sorgente/SSDT-HPBRT.dsl           Source for the HP brightness hotkey patch
docs/BRIGHTNESS-HOTKEYS.md        ACPI method mapping and verification notes
docs/INTERNAL-MICROPHONE.md       Custom LatSOFAudio technical notes
docs/RELEASE-v1.0.0.md            English summary and release notes
```

The EFI binary distribution is attached to [GitHub Releases](https://github.com/AntonioR-dev/HP-ProBook-450-G7-Hackintosh/releases).

## Limitations and ongoing work

- F3/F4 behavior must be validated against the exact released EFI and hardware revision.
- The exact **working** modified LatSOFAudio binary, source commit and SOF firmware version still need to be linked together for a reproducible audio build.
- Microphone behavior **after sleep/wake**, input gain and distortion may vary by experimental LatSOFAudio version and must not be assumed solved.
- Final boot-log review and broader testing on other HP ProBook 450 G7 configurations remain open.

## Credits and upstream projects

Built using work from the OpenCore and macOS Hackintosh communities, including [OpenCorePkg](https://github.com/acidanthera/OpenCorePkg), [Lilu](https://github.com/acidanthera/Lilu), [WhateverGreen](https://github.com/acidanthera/WhateverGreen), [AppleALC](https://github.com/acidanthera/AppleALC), [VoodooPS2](https://github.com/acidanthera/VoodooPS2), [BrightnessKeys](https://github.com/acidanthera/BrightnessKeys), [OpenIntelWireless](https://github.com/OpenIntelWireless), and the upstream LatSOFAudio authors. Original licenses and credits remain applicable to redistributed components.

This is an independent, community-maintained configuration and is **not affiliated with HP or Apple**.
