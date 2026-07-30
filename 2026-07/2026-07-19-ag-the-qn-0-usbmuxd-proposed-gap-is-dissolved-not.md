# 2026-07-19 — (ag) the qn.0 usbmuxd `PROPOSED` gap is dissolved, not chosen between

(ag) **the qn.0 usbmuxd `PROPOSED` gap is dissolved, not chosen between**:
the architect verified live that `usbmuxd` IS packaged in Alpine community on every
branch v3.21–v3.24 — the session's probe was faulty. Runtime ships it via `apk add`;
profiles unchanged (simple = in-container daemon + USB mapping, hardened = host
socket). Operator's netmuxd-only question ruled alongside: netmuxd alone fully serves
**pre-paired, Wi-Fi-sync-enabled** devices, so netmuxd-first sequencing inside
qn.2/qn.3 is encouraged — but initial pairing and enabling Wi-Fi sync are USB-only at
the protocol level, so USB stays in scope with hardware validation in the lab CT, and
fresh-device USB pairing must work by the qn.6 gate. Lesson added to D2: verify
package existence with `apk search` against the target repo, never assume.
