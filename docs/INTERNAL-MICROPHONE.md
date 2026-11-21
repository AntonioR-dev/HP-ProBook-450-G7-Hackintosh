# HP ProBook 450 G7 — Internal Microphone and LatSOFAudio

## The problem

Working speakers or headphones under macOS do not necessarily mean the **internal digital microphone (DMIC)** will work. The project's microphone required a **custom HP-specific build of LatSOFAudio**, separate from the ordinary OpenCore audio-output setup.

On the project laptop, internal microphone capture was reported working with a modified LatSOFAudio kext. The precise build used for that success is not yet associated with a reproducible public source commit and firmware revision.

## Technical approach

The HP-specific work explored the Intel **Sound Open Firmware (SOF)** DSP microphone-capture path on the Comet Lake generation, while avoiding interference with the AppleHDA-managed audio-output path.

The experimental source trees developed for this laptop include these approaches:

| Variant / area | Purpose | Caution |
| --- | --- | --- |
| DSP/DMIC capture | Provide an input path for the internal digital microphone | Needs compatible SOF firmware and hardware-specific configuration |
| PCI / stream guards | Protect shared controller state and avoid reusing an active HDA playback stream | Source guards cannot guarantee all runtime combinations are safe |
| Capture-only variant | Prevent RT5682/I2C and LatSOFAudio playback paths from interfering with working macOS audio outputs | Access-path blocking is not proof of a capture-only SOF topology |
| Gain-safe experiment | Test a default **0 dB** capture gain instead of **+30 dB** to investigate clipping and distortion | Diagnostic only; not proof of a distortion fix |
| Wake-guarded experiment | Delay and limit SOF firmware reinitialization after real sleep/wake, using controller-state safety checks | May fail closed; microphone capture may require a reboot after sleep |

### Capture-only design

In the inspected HP **capture-only experimental source**, calls to RT5682 / I2C initialization and LatSOFAudio playback operations were explicitly blocked, while retaining the DMIC capture route. This was intended to avoid disturbing working output devices managed through AppleHDA.

### SOF firmware dependency

The experimental source packages refer to the SOF firmware image **`sof-cml.ri`**, which must match the environment. Source-only packages do not necessarily include that binary. The exact firmware file and exact working kext source revision should be published together before describing a build as reproducible.

### Shared HDA controller and sleep/wake

LatSOFAudio and AppleHDA can interact with the same underlying controller. DSP firmware loading or reset can affect HDA state, so forcing initialization is not risk-free. In the conservative capture-only approach, microphone capture may stop after sleep and require a reboot. A separate wake-guarded experiment attempted recovery only when safety checks passed; it is **not** a proven universal sleep/wake fix.

## Project status

- **Confirmed by project testing:** the internal microphone worked using an adapted LatSOFAudio build; ordinary audio output also worked.
- **Not established in the public release:** which precise LatSOFAudio source revision, build settings and SOF firmware produce the known-working binary.
- **Not claimed:** stable microphone wake recovery, an independently confirmed gain/distortion fix, or compatibility with every HP ProBook 450 G7 hardware revision.

## Installation precautions

Do not install an arbitrary experimental LatSOFAudio build just because its source compiles. Preserve a known-good EFI and audio configuration, avoid installing duplicate versions of the same kext, and use a recoverable test environment. If contributing a tested build, provide its source revision, binary hash, firmware version, macOS version, and before/after sleep results.

This custom microphone work is based on **LatSOFAudio / Intel SOF** efforts. Please retain upstream authorship, licenses and notices in any redistribution.
