# v1.0.0 — HP ProBook 450 G7 OpenCore EFI for macOS Tahoe

## Summary

The first public release of an HP ProBook 450 G7 OpenCore configuration targeting **macOS Tahoe 26.x**. It documents a working daily-use installation with **Intel Core i7-10610U**, **MacBookPro16,2 SMBIOS**, a replacement **Intel AX210** wireless card, working graphics and external display outputs, and integrated Apple services. The project also includes a custom **F3/F4 brightness hotkey SSDT** and describes a separately modified **LatSOFAudio** driver for the internal microphone.

## Release highlights

- **OpenCore:** configured boot for the HP ProBook 450 G7.
- **Graphics:** internal display brightness control plus tested HDMI and USB-C DisplayPort.
- **Wireless:** original Wi-Fi card replaced with Intel AX210 for improved stability and ForbiddenItlwm integration.
- **Networking:** Realtek 1 Gbit/s full-duplex Ethernet; earlier link issue traced to the cable.
- **Audio:** working outputs; internal DMIC capture achieved through an adapted LatSOFAudio build, distributed separately from the EFI.
- **HP brightness keys:** `SSDT-HPBRT` source maps EC methods `_Q87` / `_Q86` to PS/2 notifications `0x0346` / `0x0445` for F3 / F4.
- **Apple ecosystem:** iCloud, App Store, iMessage, FaceTime, AirDrop, Handoff and Continuity reported working on the project installation.

## Installation notes

Before booting, set **your own** `MLB`, `ROM`, `SystemSerialNumber` and `SystemUUID` in `EFI/OC/config.plist -> PlatformInfo -> Generic`. Do not reuse another machine's Apple identifiers. Back up your EFI and test the release from a bootable USB before installing it to the internal drive.

## Known limitations

The exact released EFI's F3/F4 behavior has not been independently reverified in this documentation update; earlier **WMI** brightness experiments were unsuccessful and differ from the published `SSDT-HPBRT` mapping. The exact source/binary/firmware combination of the **known-working LatSOFAudio microphone build** still needs to be identified. Sleep/wake capture recovery and gain/distortion behavior must not be assumed fixed.

**Compatibility:** this EFI is hardware-specific, particularly because the factory Wi-Fi module was replaced with an Intel AX210.

## Additional documentation

- [Project overview](../README.md)
- [F3/F4 brightness patch](BRIGHTNESS-HOTKEYS.md)
- [LatSOFAudio internal microphone implementation](INTERNAL-MICROPHONE.md)
- [SSDT-HPBRT source](../Sorgente/SSDT-HPBRT.dsl)
- [Download the v1.0.0 release](https://github.com/AntonioR-dev/HP-ProBook-450-G7-Hackintosh/releases/tag/v1.0.0)
