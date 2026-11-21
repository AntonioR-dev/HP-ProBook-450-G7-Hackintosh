# HP ProBook 450 G7 · OpenCore · macOS Tahoe

Configurazione verificata sul mio HP ProBook 450 G7. Ho sostituito la scheda Wi-Fi originale con una Intel AX210 per migliorare la stabilità della connessione e poter utilizzare ForbiddenItlwm.

| Funzione | Risultato sul portatile |
| --- | --- |
| Avvio | OpenCore, timeout di 5 secondi |
| Tastiera e luminosità | Layout Italiano PC. F3 abbassa e F4 aumenta la luminosità senza Fn |
| Ethernet Realtek | 1 Gbit/s full-duplex in autoselezione con EEE attivo. La sostituzione del cavo ha risolto il problema di collegamento |
| Wi-Fi e Bluetooth | Stabili con Intel AX210 |
| Video esterno | HDMI e DisplayPort via USB-C verificati |
| Audio | Uscite audio funzionanti. Il microfono interno funziona con una build di LatSOFAudio modificata per questo progetto, distribuita separatamente dalla EFI |
| Servizi Apple | iCloud, App Store, iMessage, FaceTime, AirDrop bidirezionale e Handoff verificati |

## Uso della EFI

Prima di avviare, compilare i campi MLB, ROM, SystemSerialNumber e SystemUUID in EFI/OC/config.plist → PlatformInfo → Generic con valori propri, coerenti con il modello SMBIOS configurato. Conservare una copia della propria EFI e provare questa configurazione da USB. I risultati sopra si riferiscono alla macchina del progetto.

## Tasti luminosità

SSDT-HPBRT intercetta le query ACPI _Q87 (F3) e _Q86 (F4). Le notifiche al dispositivo PS2K sono rispettivamente 0x0346 e 0x0445. Riproducono gli scancode delle combinazioni Fn+C e Fn+W già funzionanti sulla tastiera interna. Il sorgente DSL si trova nella cartella Sorgente.

## Stato del progetto

Il controllo finale dei log di avvio resta aperto. La build esatta di LatSOFAudio utilizzata per la verifica del microfono deve ancora essere associata alla relativa revisione del sorgente.
