# 2026-07-22 — (ce) qn.4c LAB GATE 11 — the DAILY-DRIVER bar is met on real hardware; 6 of 8 legs passed, 1 mislabelled, 1 declared unrunnable

(ce) **qn.4c LAB GATE 11 — the DAILY-DRIVER bar is met on real hardware; 6 of 8 legs
passed, 1 mislabelled, 1 declared unrunnable.** One Operator hardware day on the staging CT
(managed profile, zfs hook backend, real iPhone 16 Pro + iPad). **PASSED:** **(b) Wi-Fi from the
browser on SUPERVISED netmuxd** — `compose up` alone brought both muxers up; a pre-flight proved
the only netmuxd on the box was the container's supervised child with the ruled argv (a
hand-started leftover was found squatting on 27015 and retired first — refuse-loudly would
otherwise have made the gate prove nothing, exactly the (by) concern). An encrypted incremental
committed, then a device's **first-ever full backup — 33.3 GB — committed over the same path** at
a measured **16–24 MiB/s**; Wi-Fi beat the Operator's USB path, which was VirtualHere USB-over-IP
across the same Wi-Fi. **(a) USB from the browser** — a cabled incremental committed, with
`transport: auto` **resolving to USB because the cable was plugged** (qn.4b policy, first hardware
proof), no `-n`, the supervised usbmuxd socket, and the lab-finding target fix live in argv.
**(c) survives a restart** (the redeploy: both daemons back unaided, device back on `wifi`,
backup immediately after). **(e) real last-backup line** on a device with pre-existing versions.
**(g) secrets** — `BACKUP_PASSWORD` count 0 and no password in argv, captured live on BOTH
transports. **(h) iMazing-opens** — the committed `latest/` tree (the reflink mirror) shared over
SMB opened natively in iMazing: device info, `Current Backup Encrypted: Yes`, and decrypted photo
enumeration. **That also retires the last unverified leg of qn.4a's gate 15 ((bw)).** **CANCEL**
passed too: `cancelled`, child reaped, stub cleaned, honest discard note naming the fallback
version, no phantom, slot released. **Storage held throughout:** verify+commit of 33 GB took
**36 s** (A1 is structural, the commit is a snapshot + block clone — neither scales with the
tree); `bclonesaved` **46.5 → 80.1 GiB** across two consecutive commits, i.e. `latest/` genuinely
reflinked, never copied; version rotation exact (one `is_latest` per device, always).
**NOT TICKED — (d) mid-backup Wi-Fi disconnect: landed SAFELY but MISLABELLED.** Everything
protective held (work discarded, `latest/` untouched, no phantom), but the job ended
`failed`/`backup_failed` rather than `connection_lost`/`device_disconnected`, because taking the
device off the LAN produced an immediate receive error (`Could not receive from mobilebackup2
(-256)`, terminal in 2.5 min, `liveness: active` throughout) instead of a stall — the sampler
never participated. **Interface fact 2 is INCOMPLETE, not wrong:** a Wi-Fi loss has two shapes
(the lab's frozen `Heartbeat(SleepyTime)` stall, which quince handles correctly, and this clean
error exit, which it mislabels). Filed with a fixture-first fix direction. **DECLARED UNRUNNABLE
— (f)'s unencrypted half:** finding (i)-A needs a device that has NEVER had a backup password (no
`WillEncrypt` key at all); both lab devices have had one, so disabling encryption yields a
*present* `false` — the branch that already worked — while changing the Operator's real device
state and producing a permanently-incomplete version. Declared CI-covered only (story 7 +
`enc_never_set`), accepted debt with a stated reason; a factory-fresh device belongs to qn.6's
onboarding gate anyway. **Live progress: PARTIAL** — the WS path updates card and details with no
reload (confirmed repeatedly), but the percentage moves in jumps and the byte pair beside it is
wrong, so the leg is recorded honestly rather than ticked clean. **SEVEN findings filed, all
diagnosed, none blocking:** the gate-blocking target-filesystem bug (fixed in-session, (cd)); a
Wi-Fi drop mislabelled `failed`; the dashboard card staying silent when the newest attempt failed
(the most daily-driver-relevant UI gap — `last_backup` semantics are right, the card needs a
companion affordance); 12 KB progress blobs that mangle the log pane AND make the parser read the
oldest frame (measured: UI showed `1.6 KB / 2.9 GB` while the tool was at `2.5 GB/2.7 GB` of a
different file); current-file bytes presented as overall; every version reading `incremental`
because the device writes `IsFullBackup: false` even for a first 33 GB backup; two `latest` badges
until reload (client-side staleness, server verified correct); crash-orphaned target stubs unswept.
**Operational note for the deployment:** the host's `zfs-auto-snap` is snapshotting quince's
datasets (mid-backup snapshots pinned 15.7 → 67.6 GB), which contradicts stack decision (b)
("quince relies only on snapshots it creates") and sits outside quince's retention model — the
Operator will exclude the parent dataset. **M3's daily-driver goal is met:** both transports
UI-driven, live updates without a refresh, real last-backup lines, and the major bugs fixed.
