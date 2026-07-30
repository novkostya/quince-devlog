# 2026-07-22 — (cn) Spike banked: enable/disable Wi-Fi discoverability ("Wi-Fi sync") from inside quince

(cn) **Spike banked: enable/disable Wi-Fi discoverability ("Wi-Fi sync") from inside
quince** (Operator-raised; full note on the qn.7 roadmap entry). **Why it's bigger than it looks:**
Wi-Fi is the PRIMARY transport (ruling (h)), but enabling Wi-Fi sync currently requires
**Finder/iTunes** ("Show this device when on Wi-Fi") — so today's self-contained onboarding (D12
"everything in quince") is **broken for the primary transport**: a fresh user pairs over USB in
quince, then must reach for a Mac to turn Wi-Fi backups on. **Likely mechanism — to VERIFY, not
assume (interface-facts rule):** a lockdown `SetValue` on `com.apple.mobile.wireless_lockdown`
(`EnableWifiConnections`-ish), which libimobiledevice's `lockdownd_set_value` supports; it is a
USB-trusted op, and since pairing is USB-only anyway (D2) the natural moment is *during the qn.3
USB pair* — plug → Trust → pair **and** enable Wi-Fi sync → unplug → Wi-Fi works. Read-back yields a
`wifi_sync: on|off|unknown` device property to show + toggle beside pairing/encryption. Spike
answers: exact key, whether SetValue takes effect (reboot/respring?), USB-required, unlock/Trust
needed. Home: qn.7 (Wi-Fi) or a small device-ops add folded into qn.6 onboarding; if infeasible,
onboarding documents the Finder step honestly. Post-freeze.
