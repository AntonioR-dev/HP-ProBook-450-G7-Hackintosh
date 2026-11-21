# HP ProBook 450 G7 — F3/F4 Brightness Hotkey Patch

## Background

macOS can control the internal display backlight on this laptop. The original alternative keyboard shortcuts **Fn+C** (decrease brightness) and **Fn+W** (increase brightness) were verified, but the dedicated F3/F4 keys required HP-specific handling.

Several earlier WMI-based test patches were tried and **did not restore F3/F4**. They are not the implementation documented here.

## Implemented SSDT

The repository contains [`SSDT-HPBRT.dsl`](../Sorgente/SSDT-HPBRT.dsl), targeting these device paths:

- Embedded controller: `\\_SB.PCI0.LPCB.EC0`
- Internal PS/2 keyboard: `\\_SB.PCI0.LPCB.PS2K`

The logic requires suitable OpenCore ACPI rename patches so that the firmware's original `_Q87` and `_Q86` methods are available as `ZQ87` and `ZQ86`. The SSDT then defines macOS-specific methods:

| Key | EC method | Notification | Intended result |
| --- | --- | --- | --- |
| F3 | `_Q87` | `Notify (PS2K, 0x0346)` | Lower brightness (same functional path as Fn+C) |
| F4 | `_Q86` | `Notify (PS2K, 0x0445)` | Raise brightness (same functional path as Fn+W) |

The source uses an `_OSI ("Darwin")` branch for macOS and invokes the original renamed firmware method from its non-macOS branch. This is a targeted **EC-to-PS/2 notification mapping**, not a change to macOS backlight hardware support.

## Why this approach?

The existing `BrightnessKeys`, `VoodooPS2Controller` / PS/2 keyboard handling and `SSDT-PNLF` support already provided backlight control. The problem was to translate the physical HP hotkey events into a keyboard notification understood by the current input stack.

## Integration and verification

1. Ensure that the compiled `SSDT-HPBRT.aml` is actually included and enabled under `ACPI -> Add`.
2. Check that the **specific** ACPI rename rules are enabled, correctly scoped, and do not rename unrelated devices.
3. Keep the PS/2 keyboard implementation and brightness support kexts compatible with the SSDT.
4. Boot from a test USB and confirm **F3 = down**, **F4 = up**. Verify other function keys and the previously working Fn+C / Fn+W shortcuts.
5. Keep a backup EFI and remove conflicting experimental WMI brightness SSDTs.

**Verification caveat:** The original published README reports F3/F4 functioning without Fn, but this documentation update does not independently validate the released AML or the tested hardware outcome. The two earlier WMI trials failed; they must not be mistaken for confirmation of the newer SSDT-HPBRT implementation. If the released EFI behaves differently, report the exact OpenCore configuration and tested results.

## Source and portability

Read [`Sorgente/SSDT-HPBRT.dsl`](../Sorgente/SSDT-HPBRT.dsl) before rebuilding. Path names, EC methods and notification values are specific to the project's HP ProBook 450 G7 configuration. Never apply the patch blindly to other HP models or different DSDTs.
