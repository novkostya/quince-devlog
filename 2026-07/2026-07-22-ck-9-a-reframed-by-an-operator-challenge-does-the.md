# 2026-07-22 — (ck) #9(a) REFRAMED by an Operator challenge ("does the `incremental` label bring any user value?") — it doesn't, and it mildly MISLEADS: drop it from the UI, keep it internal

(ck) **#9(a) REFRAMED by an Operator challenge ("does the `incremental` label bring
any user value?") — it doesn't, and it mildly MISLEADS: drop it from the UI, keep it internal.**
The `full`/`incremental` label describes the *transfer* (idevicebackup2 sent deltas), not the
*result* — and **every quince version is a complete, independently-restorable backup** (a zfs
snapshot is the whole tree; a namespace version is a complete dir). So "incremental" imports the
fragile-chain mental model from Time Machine/Borg/restic/Veeam — "delete the full and it breaks"
— which is FALSE here and undercuts D5's central guarantee that versions are independent, never a
chain. Verified: displayed at `VersionList.tsx:24`, a frozen `Version.kind` (§2), and internally
it gates the encrypted-verify shard check (assert "all 256 shards present" only on a full
transfer, where absence is definitely a bug — on a small incremental it could false-fail). So it
has real INTERNAL value and near-zero USER value. **Ruling:** (1) **qn.6a drops `kind` from the
version card** — show what the user acts on instead: date, size, the **delta size** ("added 1.2
GB" is genuinely useful, unlike "incremental"), encrypted, verified. (2) **`kind` stays internal +
in the contract** (non-breaking; CLI/power-user/debug), derived honestly per #9(a)'s qn.5b home —
which the verify shard-check still needs (a first backup mislabeled `incremental` today means the
full-only check silently never runs, so a broken first backup could pass). The Operator's
challenge thus flipped the user-facing half of #9(a) from "make the label accurate" to "stop
showing a label that misleads," while preserving the internal-honesty half for verification
correctness.
