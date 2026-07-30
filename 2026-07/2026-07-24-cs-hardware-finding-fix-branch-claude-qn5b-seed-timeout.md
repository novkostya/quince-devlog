# 2026-07-24 — (cs) HARDWARE FINDING + FIX (branch `claude/qn5b-seed-timeout-fix`): the 60 s ZFS metadata timeout was applied to the qn.5b `seed`, which is O(file count) — it SIGKILLed the real 34…

(cs) **HARDWARE FINDING + FIX (branch `claude/qn5b-seed-timeout-fix`): the 60 s ZFS
metadata timeout was applied to the qn.5b `seed`, which is O(file count) — it SIGKILLed the real
34 GB iPhone seed mid-clone and made the primary device un-backup-able.** First real qn.5b iPhone
backup on the lab box failed at *exactly* 60 s with `seed work area: … zfs seed …: signal: killed`.
Root cause: `zfsOpTimeout = 60s` was written for the metadata verbs (`snapshot`/`create`/`list`/
`destroy`, all O(1)) and qn.5b reused it to bound the `seed` verb — which reflink-clones an ENTIRE
backup tree. **Measured on the real pool:** an iOS backup is ~133 k files (256 blob shards); reflink
is **per-FILE**, so cost is O(file count), NOT O(bytes) — ~7 600 files/s → 34 GB/133 k-file seed =
**17.5 s clone alone, ~32 s warm / >60 s cold**; the 3 GB/94 k-file iPad seed = 5.3 s (which is why
the iPad sailed through and the iPhone died). Reflink buys SPACE, not syscalls. **Fix (this branch,
gates-green):** a distinct `zfsSeedTimeout = 30 min` (generous backstop only — the JOB context
already cancels, the liveness sampler owns stall detection) via a new `seedCtx()`, leaving the 60 s
bound for the metadata verbs; regression test `TestSeedUsesItsOwnGenerousTimeout` inspects the
deadline the hook verb actually receives and fails if it is ≤ the metadata timeout (discriminates:
the old code gives *exactly* 60 s). **Also (2):** dropped a redundant `chown -R` from the hook
`seed` verb — `cp -a` already preserves `latest/`'s (container-uid) ownership, so only the mkdir'd
parent needs chowning; re-timed on hardware **70 s → 22.9 s**, no file left mis-owned. `deploy/
storage.md` carries the sizing note (budget minutes for large devices). Extends memory
[[zfs-reflink-clone-facts]] (mirror→seed; seed timing). Precedent for an in-session hardware fix:
the qn.4a free-space bug (cd).
