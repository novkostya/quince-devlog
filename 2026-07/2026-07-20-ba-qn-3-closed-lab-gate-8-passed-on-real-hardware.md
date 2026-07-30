# 2026-07-20 — (ba) qn.3 CLOSED — lab gate 8 PASSED on real hardware

(ba) **qn.3 CLOSED — lab gate 8 PASSED on real hardware.** Deployed the qn.3
build to the staging CT (managed usbmuxd, live `/dev/bus/usb`) and drove the gate with a real
iPhone: **(1) pair** via the quince UI on a fresh container → `paired: yes`, with the record
written to `$QUINCE_DATA/lockdown` (proves `Backup()` fired = a real pair op, not enrichment);
**(2) persistence** (amendment 1) → `nerdctl compose down && up` → `lockdown: restored …
count:2` → still `SUCCESS: Validated`, no re-Trust — **proven twice** (a second redeploy for
the UI fix repeated it); **(3) encryption** → `change_password` then a full `disable → enable`
cycle, all succeeding, ending encryption **ON** with an Operator-held password; **(4) secrets
(story 5) on hardware** → the capture caught `idevicebackup2 -i -u <udid> {changepw,encryption
off,encryption on}` — **no password in argv**, `BACKUP_PASSWORD` env count **0**, clean logs —
the password reached the child only over the pty. **Four findings caught by the gate, all fixed
+ CI-validated + committed as `qn.3 lab finding:`** — the substantive one: **enrichment
auto-paired a locked device** (`idevicepair validate` returns "passcode is set" for ANY locked
device regardless of pairing — observed on a fresh host with no record — so mapping it to
`paired: yes` + then doing the auto-pairing full `ideviceinfo` could silently trigger Trust;
fixed → locked ⇒ `paired: "unknown"`, and the full/auto-pairing read runs only for a confirmed
`validatePaired`, everything else uses the no-auto-pair simple read); plus three UI fixes (the
dashboard card's stale disabled Pair now routes to the details flow; the encryption mode
switcher reset after a completed op; a persistent "confirm on the device with its passcode"
hint; mode frozen at open + dialog auto-closes on success so the title no longer mismatches the
result). The lab gate did its job — a real device found a real code bug the CI fakes could not.
The paired staging container is **kept standing** as the qn.4/qn.5 base (Operator ack).
Frontier → **qn.5** (storage; qn.5-before-qn.4 per (ar)).
