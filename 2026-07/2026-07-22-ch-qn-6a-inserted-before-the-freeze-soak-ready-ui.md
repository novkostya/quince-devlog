# 2026-07-22 — (ch) `qn.6a` inserted before the freeze — soak-ready UI. Sequence: qn.5b → qn.6a → freeze + revamp (app soaking)

(ch) **`qn.6a` inserted before the freeze — soak-ready UI. Sequence: qn.5b → qn.6a →
freeze + revamp (app soaking).** The Operator broadened the goal from "usable for me" toward "a
first alpha tester," and — decisively — gave the reason: **they want the app in real-world use on
staging *while the process revamp runs*.** The architect had argued for freeze-first and
**conceded**: that argument assumed the revamp and the soak compete for time, and they don't. The
revamp is *process* work, so the codebase is idle throughout; a usable app converts that idle
stretch into **soak time, which cannot be compressed or backfilled**. And **mobile is the
precondition, not polish** — if you must be at a desktop, the daily use (hence the soak) never
happens at all. **Three architect challenges, all accepted:** (1) **don't conflate "my soak" with
"ready for a friend"** — the soak justifies mobile + offline devices + labels; it does NOT justify
the DSM feasibility spike, storage onboarding, or gate **12c** (which un-defers the moment a
non-zfs tester appears, since a Synology lands on btrfs/ext4 → reflink or the **currently
disabled-to-copy hardlink tier**). Those wait for after the revamp. (2) **5b runs first** — it
changes the `working/` lifecycle and Retry semantics, i.e. precisely the behaviour a soak
observes; soaking on a model about to change wastes the findings. (3) **"offline devices" needs
its shape pinned or it silently becomes the biggest item** — minimal form is a union of live muxd
presence with UDIDs already in the versions registry, plus persisting the identity already
fetched at enrichment, not a new subsystem. **Operator-specified offline-card behaviour:** same
card shape with a **disabled "Back up now"** so layout stays aligned with online cards — the
architect added the one constraint that it be **disabled *with a reason***, never a dead button
(the qn.4b pattern and the (bq) lesson). **Forward note recorded, explicitly NOT scope:** a
post-qn.12 **"Wake up"** spike — an offline device may just be *asleep on the same LAN*, and a Web
Push to its PWA might rouse it so mDNS resumes and netmuxd rediscovers it. Fits the assisted model
(quince cannot back up unattended but may *nudge*) and needs no new infrastructure beyond a push
kind, but it is unproven that waking the screen restores Wi-Fi-sync visibility and it can only
work on the same network — so it stays a spike with honest UI ("wake attempt sent"), never a
success claim. **qn.6a is the LAST rung under the current process:** its implementer records
process friction as it goes (letter collisions, doc drift, gate-ownership seams, spec overhead)
and hands it to the revamp as evidence, so the process isn't redesigned from memory.
