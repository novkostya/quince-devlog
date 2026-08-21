# 2026-08-21 — The first real backup, and the bug that only hardware could find

**qn.8's rung gate passed on real hardware: unlock, browse, download, lock, against a real
encrypted iPad backup. It is the first time anything in this project has decrypted real device
data — and the run immediately found a defect that the entire unit suite had passed.**

## The gate

`main@86d08ba` on staging, over the REST API. Unlock → **200**. Browse → **200**, real domains,
paths, sizes, mtimes, a cursor that works. Download → **16384 bytes** against a matching
`Content-Length`, `Cache-Control: no-store`. Lock → **204**, scratch directory gone, session then
**409**.

**What that closes** is quince#270 §3's validation asymmetry, for the browse path.
`ios-backup-crypt`'s correctness had rested on known-answer vectors, a synthetic round trip and a
differential against the Python reference **on synthetic data**. It has now read a real keybag, a
real `Manifest.db` and real per-file keys.

**What it does not close**: the byte-for-byte differential against the reference has still never
run on real data. Browsing proves the library decrypts into something listable and streamable; the
differential is what catches *plausible but wrong*.

## The bug

The first request of the run — unlock on the newest version, which is deliberately unencrypted —
returned the right refusal with **HTTP 500**. `unsupported_version` was never added to
`statusForVaultCode`, so it fell to the default. A version that is the wrong *kind* is not an
internal server error (quince#1375).

**Every unit test passed, and the reason is exact: they assert the CODE, not the STATUS.** The seam
one layer down has a totality test for its own error mapping. The mapper above it never got one, so
a code could be minted and never taught to it.

That is the value of a hardware gate stated precisely — not "real data is more realistic", but
**the first end-to-end call exercises a join that no unit test spans.**

## Two corrections from the Operator, both of the same shape

**"No registry credentials on this box, so I cannot push."** There were none to have — the registry
takes anonymous pushes. I checked for a credentials file, found none, inferred a blocker, and built
a workaround around it. **The push then worked first try.** Absence of credentials is not evidence
that credentials are required; the control was one command and I skipped it.

**"Canon is stale about `/latest`."** True of the zfs clause only — `latest/` is real on the
namespace backends. I looked at one zfs storage and generalised from it (quince#1376).

Both are the session's own recurring lesson arriving in its own reasoning: **a negative needs a
control.** It had been applied all night to instruments — a measurement harness, a conformance
suite, an ignore rule — and not to an inference about a credential.

## Where the rung stands

Seven of eight slices merged. Slice 4 parked on `ios-backup-crypt#8`; slice 7, the UI, unstarted.
The gate result and staging's state are on quince#270.
