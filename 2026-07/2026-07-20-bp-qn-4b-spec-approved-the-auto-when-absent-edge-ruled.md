# 2026-07-20 — (bp) qn.4b spec APPROVED; the `auto`-when-absent edge RULED: refuse actionably

(bp) **qn.4b spec APPROVED; the `auto`-when-absent edge RULED: refuse actionably.**
Architect ratification of the spec's flagged proposal, encoded into design §4: `auto` resolves
against current presence only; a device on neither transport → actionable 422, no job minted
(a guessed transport would persist a dishonest `Job.transport` — the contract stores only
concrete values; the frozen automation contract's `device_not_visible` no-go shows canon
already thinks this way; and default-wifi-and-wait would contradict "prefers USB when
plugged" the moment a cable appears). Explicit `usb`/`wifi` keeps start-then-connect. One
spec amendment: design §4 DOES change (the absent clause was silent canon — now explicit;
the spec's "nothing changes" docs line updates accordingly). Everything else approved as
written, incl. the demo JobControl flip (its own qn.4a-named condition met), the CLI-only
escape hatches, and the netmuxd started-not-supervised split (the qn.2→qn.2b precedent).
The consolidated hardware day closes M3: qn.4a gate 15 (CLI USB + kill matrix +
mirror/iMazing/syncoid) then qn.4b gate 11 (UI both-transports + honest Wi-Fi disconnect) +
gate 12c (the destructive matrix) in one Operator session.
