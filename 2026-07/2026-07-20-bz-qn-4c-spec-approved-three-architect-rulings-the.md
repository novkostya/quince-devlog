# 2026-07-20 — (bz) qn.4c spec APPROVED; three architect rulings + the netmuxd socket hazard

(bz) **qn.4c spec APPROVED; three architect rulings + the netmuxd socket hazard.**
The spike's headline is a landmine caught by running the shipped binary (the "interface facts
are looked up" rule earning its keep **again**): with its default `--socket-path`, **netmuxd
DELETES a live usbmuxd's unix socket and binds its own** — reproduced in the built image
(`Deleting old Unix socket`, usbmuxd still running with its inode gone = **silent USB
blackout**). Naive supervision would have made enabling Wi-Fi kill USB. Ruled argv:
`netmuxd --host <h> --port <p> --socket-path <private> --disable-usb`, with a **loud refusal**
if that path collides with `devices.usbmuxd_socket`; the session's choice of a private socket
over `--disable-unix` is **ratified** — the latter puts netmuxd in host mode where it depends
on usbmuxd being alive, coupling Wi-Fi health to USB health, which is exactly backwards for
two independent transports. **Rulings:** (1) **`last_backup.job_id` → NULLABLE: APPROVED**,
landed in contracts §2 ahead of the rung (the qn.2b precedent). Deriving `last_backup` from
the newest committed VERSION rather than job history is *more correct*: versions are the source
of truth for "has this device been backed up", so it survives restarts and covers **adopted**
versions (restored/replicated dataset — the case where "No backups yet" is most insulting),
which honestly have no job. Semantic shift recorded: `last_backup` now means the last
SUCCESSFUL backup; a failed last attempt lives in the job history, not here. (2) **One config
flag: APPROVED** — D12 says config tidiness is a feature, and a second flag would serve a
topology nobody has asked for while the mixed case still degrades *honestly* via refuse-loudly.
If a real user ever needs it, one bool splits into two as a compatible migration
(`manage_muxer: true` → both). (3) **Health shape: CLEAN BREAK recommended** — a `muxers`
array (each entry naming its role/transport, managed state, and whether rescan applies)
INSTEAD of keeping the singular `muxer` alongside it. Two overlapping representations rot
(which is truth when they disagree?), and a top-level `muxer` is now *ambiguous* with two
daemons; `/api/health` is not frozen and we are the only consumer, so this is the cheapest
moment. Update any `local/` tooling that greps `.muxer.` in the same pass. **Affirmed:**
rescan stays USB-only (restarting netmuxd would tear a live Wi-Fi backup — and rescan always
existed for USB hotplug). **Flagged for the build:** verify finding (iv) is *genuinely*
subsumed by (v) — if the card has no branch rendering the `verifying`/`committing` phases it
will still read "Backing up 100%" after `last_backup` is fixed, which would be a small but
real UI change contradicting "ui/ needs no changes".
