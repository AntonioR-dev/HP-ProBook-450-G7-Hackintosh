# HP ProBook 450 G7 — Internal Microphone and LatSOFAudio

## Working configuration with SIP enabled

On the project HP ProBook 450 G7 running macOS Tahoe, the internal Intel digital microphone works with System Integrity Protection fully enabled. OpenCore loads the HP build of LatSOFAudio 1.1.6. A Core Audio HAL plug-in makes its capture stream available to applications. These two downloads supplement the original v1.0.0 EFI.

| Component | Install location |
| --- | --- |
| [LatSOFAudio 1.1.6 kext](../audio/LatSOFAudio-1.1.6.kext.zip) | `EFI/OC/Kexts/LatSOFAudio.kext` |
| [LatSOFAudio HAL plug-in](../audio/LatSOFAudioPlugin.driver.zip) | `/Library/Audio/Plug-Ins/HAL/LatSOFAudioPlugin.driver` |

### Installation on Tahoe

1. Start with a USB copy of your working EFI. Extract both ZIP files. Copy the kext bundle into the USB EFI at the path above.
2. In the USB `EFI/OC/config.plist`, enable a single entry for the bundle under `Kernel → Add`. Set `BundlePath` to `LatSOFAudio.kext`, `ExecutablePath` to `Contents/MacOS/LatSOFAudio`, `PlistPath` to `Contents/Info.plist`, `Arch` to `x86_64`, `MinKernel` to `25.0.0` and leave `MaxKernel` empty.
3. In the working configuration, `NVRAM → Add → 7C436110-AB2A-4BBB-A880-FE41995C9F82 → csr-active-config` is four zero bytes (Data, `00000000`). The same GUID under `NVRAM → Delete` lists `csr-active-config` so the previous value is replaced at boot.
4. In Finder choose **Go → Go to Folder**, enter `/Library/Audio/Plug-Ins/HAL/` and copy the extracted `LatSOFAudioPlugin.driver` bundle there. Authenticate when prompted. When building the plug-in from source, `make install` performs this copy and verifies the signature. If it prints `SEAL-OK` followed by error 150 while restarting `coreaudiod`, the installation has completed. Reboot for Core Audio to load the plug-in.
5. Boot Tahoe from the USB EFI. Run `csrutil status` and `kmutil showloaded | grep -i LatSOF`. The working configuration reports `enabled` and `com.hackintosh.LatSOFAudio (1.1.6)`. An older 1.1.5 copy remained in `/Library/Extensions` during the project test. The loaded version distinguishes the EFI build.
6. Select **LatSOF Internal Microphone** under **System Settings → Sound → Input**. Select the same input for a short QuickTime audio recording and play it back.

### Why both components are needed

The HP build embeds the IOAudioFamily code it uses and gives those classes distinct names. This removes the external `com.apple.iokit.IOAudioFamily` dependency that blocked the previous OpenCore injection attempt. With the kext alone, IORegistry showed `LatSOFKernelAudioEngine` publishing **LatSOF DMIC capture** at 48 kHz. The engine was absent from the standard `IOAudioEngine` class listing. The built-in input at 44.1 kHz belonged to AppleHDA.

The HAL plug-in connects to `LatSOFAudioDevice` through its user client and exposes the Intel input to Core Audio. Microphone operation with SIP enabled was confirmed on the project laptop after installing the plug-in and rebooting. Capture after sleep/wake remains unverified for this configuration.

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

- **Working on the project laptop:** internal microphone capture with OpenCore-injected LatSOFAudio 1.1.6, the HAL plug-in and SIP enabled.
- **Not established in the public release:** which precise LatSOFAudio source revision, build settings and SOF firmware produce the known-working binary.
- **Not claimed:** stable microphone wake recovery, an independently confirmed gain/distortion fix, or compatibility with every HP ProBook 450 G7 hardware revision.

## Installation precautions

Do not install an arbitrary experimental LatSOFAudio build just because its source compiles. Preserve a known-good EFI and audio configuration, avoid installing duplicate versions of the same kext, and use a recoverable test environment. If contributing a tested build, provide its source revision, binary hash, firmware version, macOS version, and before/after sleep results.

This custom microphone work is based on **LatSOFAudio / Intel SOF** efforts. Please retain upstream authorship, licenses and notices in any redistribution.
