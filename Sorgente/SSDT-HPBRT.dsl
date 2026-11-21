DefinitionBlock ("", "SSDT", 2, "HPG7", "HPBRT", 1)
{
    External (\_SB.PCI0.LPCB.EC0, DeviceObj)
    External (\_SB.PCI0.LPCB.EC0.ZQ86, MethodObj)
    External (\_SB.PCI0.LPCB.EC0.ZQ87, MethodObj)
    External (\_SB.PCI0.LPCB.PS2K, DeviceObj)
    Scope (\_SB.PCI0.LPCB.EC0)
    {
        Method (_Q87, 0, NotSerialized)
        {
            If (_OSI ("Darwin")) { Notify (\_SB.PCI0.LPCB.PS2K, 0x0346) }
            Else { ZQ87 () }
        }
        Method (_Q86, 0, NotSerialized)
        {
            If (_OSI ("Darwin")) { Notify (\_SB.PCI0.LPCB.PS2K, 0x0445) }
            Else { ZQ86 () }
        }
    }
}
