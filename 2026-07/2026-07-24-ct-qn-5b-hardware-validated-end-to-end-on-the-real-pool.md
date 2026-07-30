# 2026-07-24 — (ct) qn.5b HARDWARE-VALIDATED end-to-end on the real pool + real iPhone/iPad over Wi-Fi — every owed lab leg now proven

(ct) **qn.5b HARDWARE-VALIDATED end-to-end on the real pool + real iPhone/iPad over
Wi-Fi — every owed lab leg now proven.** Session on the lab box: the deployed hook was upgraded
(`mirror`→`seed` verb) and the `seed` proven live (verdict `SHARED`, pool `bclonesaved` +3.07 GB on
the 3 GB iPad tree). Legs: **G-exchange-live PASS** — the in-container `renameat2(RENAME_EXCHANGE)`
works in the *deployed* nested-OCI/unprivileged-LXC shape, and a SAME-layer contrast showed FICLONE
still `EPERM`s there → the (co) privilege split is now proven **empirically** (exchange in-container,
seed host-side), no host-side fallback verb needed. **G-snapshot PASS** (775 probe-snapshots, 0 with
a missing/torn `latest/`) — with the honest caveat that a ~0.1 Hz probe loop has little power to
catch a microsecond window, so this proves real-pool integration, NOT atomicity (the atomicity proof
stays the exchange primitive + the CI concurrent-reader test). **G-rclone PASS** (continuous sync
across commits; the remote `latest/` never deleted or torn). **Reset op PASS** (discarded a 34 GB
orphan cleanly). **keep-dirty-working-on-FAILURE PASS** (a failed backup left a resumable 37 GB
`working/`, `latest/` untouched, exactly one snapshot — no partial commit). **resume-without-re-seed
PASS** (`"resuming dirty working (zfs)"`, no re-clone). **iPad 3 GB full cycle PASS** and — after the
(cs) fix + moving the phone closer to the AP — **iPhone 34 GB full cycle PASS** (version
01KY970TC…, honest `incremental` kind, clean `latest/`-only baseline). Both devices proven.
**Wi-Fi failure root-cause dive (owner = qn.7, NOT qn.5b, NOT netmuxd).** Early iPhone attempts
failed `Could not receive from mobilebackup2 (-4/-256)` / netmuxd `Heartbeat(Timeout)`. A deep
pcap + `ss -tinoe` + netmuxd-DEBUG dive (tcpdump via `nsenter` into the CT netns; `RUST_LOG=debug`
via a compose env override — quince honours it, `muxsup` only injects `info` when unset) established:
**(1)** real Wi-Fi packet loss + link drops (exponential-backoff retransmits into a silent phone);
**(2)** netmuxd EXONERATED — no backpressure (0 real zero-window), nothing logged even at DEBUG, the
phone stopped ACKing raw TCP *below* netmuxd; **(3)** NOT a message-size/64 KiB bug (failure timing
varied). **Honest correction recorded (the implementer over-concluded a root cause TWICE under live
pressure):** a multi-minute `app_limited` idle window — iOS doing its own local snapshot/file-prep,
socket legitimately idle — was misread as a "deterministic deadlock at ~264 MB"; the backup actually
SUCCEEDED. **Durable lesson for qn.7:** iOS Wi-Fi backups have long LEGITIMATE idle pauses, so
quince's liveness thresholds must not panic on them, and the real fix is qn.7's planned patched
libimobiledevice timeout (30 s → 15 min, upstream #1413) so a backup rides out BOTH the pause and a
transient Wi-Fi flap. Two real-world captures preserved as qn.7 chaos-suite fixtures (a genuine
Wi-Fi failure + a success-with-pause) — **local-only on the lab host; they contain LAN IPs and must
NEVER enter git** (privacy gate). **Finding B (open, architect to route): a partial/killed seed
leaves an orphaned `working/` that the next `WorkDir` silently RESUMES into** — because the seed
sentinel (`.quince-work.json`) is written only AFTER a successful seed. Today it only bit us because
the (cs) timeout SIGKILLed a seed mid-clone, but any crash mid-seed reproduces it, and the failure
mode is a version that could pass structural verify while missing blobs. Proposed fix: write the
sentinel BEFORE seeding with `seed_complete:false`, flip true on success; `WorkDir` refuses to
resume anything not marked complete (re-seeds). Small, but a state-honesty/correctness fix.
