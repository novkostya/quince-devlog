# 2026-07-25 — (do) The 2026-07-24 storage-thread discussion BANKED (the space-scare's productive tail): the `zfs-native` lifecycle is now epic-(cl) candidate mode #8; the clone-promote/…

(do) **The 2026-07-24 storage-thread discussion BANKED (the space-scare's productive
tail): the `zfs-native` lifecycle is now epic-(cl) candidate mode #8; the clone-promote/
snapshot-as-latest alternative recorded beside it; the cp-would-not-help/births-not-sharing
fact added to the (dl) stack note.** Chain of the discussion, for the record: the (dl) send-cost
finding → Operator asked whether a genuine `cp` seed would spare the replica (NO — send size is
driven by block births, not physical sharing; both cp and reflink mint newborn trees per
generation; reflink is origin-side-win, send-neutral; levers = retention / replica-side
`dedup=on` / content-addressed channel — now in stack D5) → Operator asked whether the newest
snapshot could BE the mounted read surface (possible; clone-promote is the full form; rejected
for THIS topology: per-backup privileged mount choreography through host→LXC→OCI, EXDEV seeding
from snapshot mounts (gate-12 measured), unprivileged `.zfs` automount minefield — recorded in
the epic block as the harder-rejected sibling) → Operator proposed the straightforward
backup-over-live-dataset model (SOUND on zfs: no seed latency, delta sends, honest accounting,
Finding-B-moot, CoW-free version isolation; costs: re-splits the unified lifecycle — the
portable exchange model stays the floor for non-snapshotting backends and the qn.6b gate stays
THEIR answer; `.zfs` browse becomes load-bearing (probe); epic-scale) → ruled ((dn) confirming
the discussion): does NOT meet the insert bar, home = the multi-storage epic as a first-class
MODE, with a btrfs-native twin noted for DSM. Nothing pre-freeze changes; the soak + qn.7's
chaos work feed the mode decision with real evidence.
