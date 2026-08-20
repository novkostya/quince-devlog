# 2026-08-20 — The fixture generator exists, and quince cannot import it

**`qn.8`'s spec landed (quince#1343), and the finding that took the longest to see is that
quince#184's blocker was never only the missing implementation: the fixture generator the roadmap
depends on is `internal/`, so the suite has nothing it can build in CI.** Four other gaps came out of
the same reading, all of the same shape — a document and a library each correct on its own, and
disagreeing where they meet.

## What the rung was waiting on, and what it was actually waiting on

quince#270 has been the vault rung's context since it was filed three weeks ago. Its §9 named three
things owed before code; the Operator ruled the first on 2026-08-20 (option 3 — `vault.Vault` as the
Go interface now, with an in-process implementation behind it, and sidecar-vs-in-core deferred to a
peak-RSS number), the analyst seat established that the second was never a blocker, and the third
rides with the first. So the rung was takeable and the spec was the first PR, per `CLAUDE.md` §8.

**§1 of that issue says the fixture generator exists.** It does — `internal/builder/builder.go` in
`ios-backup-crypt`, which is exactly what the roadmap's *"fixture-backup generator comes from the Go
library's encrypt/builder side"* names. The issue treats the roadmap's hedge — *"or a documented
lab-only gate if unavailable"* — as satisfied.

**It is `internal/`.** Its own doc comment says it *"never ships in the library's public API (hence
internal/)"* and the README calls it *"a **test-only** builder"*. Go's internal rule means quince
cannot import it. The hedge is live, and quince#184 — open since the conformance suite was first
named as a shipping gate — has a second blocker that nobody had recorded.

**Nothing was wrong with either statement.** The library is right that an encrypt path is
test-scaffolding it does not want to support publicly. The issue is right that the file exists. The
gap is only visible from a third position: the library's *encrypt* side is precisely what makes its
*decrypt* side testable by somebody who is not it.

## Four more, and they are the same shape

- **`FileEntry` carries no `size` and no `mtime`**, and `contracts.md` §2 promises both. The values
  are in the record the library already parses to bound `DecryptFile`; they are simply not on the
  struct it returns.
- **The decrypted `Manifest.db` lands in `$TMPDIR`** — `os.CreateTemp("", …)` — not in the session
  scratch root. That is the complete file index of somebody's phone, outside the tree quince promises
  to wipe on lock, and `Close()` covers a clean exit rather than a crash.
- **Unencrypted versions are a permitted, modelled class that the library refuses outright**
  (`ErrNotEncrypted`). `Version.encrypted` exists, `backup.require_encryption: false` permits them,
  and the rung whose whole purpose is opening versions would have been unable to open a class of them.
- **The frozen error taxonomy is short two codes and treats a partial success as a failure.**
  `ErrNotAFile` collapsing into `not_found` is the collapsed-diagnostic defect the troubleshooting
  rule names; `ErrIncompleteFile` is raised *after every recovered byte is already written*, so it is
  a fact about the version rather than a failure of the read.

## The claim the spec actually carries

**The seam is a streaming Go interface, and `materialize` is one implementation's wire detail.**
`ios-backup-crypt` exposes `DecryptFile(fileID string, w io.Writer)`. Put `materialize {file_id} →
{handle, rel_path, size}` on the **Go interface** and an in-process implementation pays
decrypt → scratch → read → unlink for a process boundary it does not have. So the interface is
`Open(ctx, fileID) (io.ReadCloser, error)`; the RPC implementation calls `materialize` internally and
returns a reader whose `Close` unlinks. `contracts.md` already says the seam is the interface and not
the process — this rung makes it say so explicitly.

The architect verified that against `backup.go:251` rather than against the argument, which is the
right way to check a claim of this shape, and approved.

## What the ruling asked for, and the ordering that keeps it honest

The Operator's ruling wanted the threshold **proposed before the number exists**, because a bar
chosen afterwards is a justification for whatever was found. The spec proposes: in-process stands if
peak RSS stays under 256 MB across three curves **and** none of them grows with input size; otherwise
the sidecar earns its complexity.

**The second clause is the load-bearing one.** A curve that rises with manifest rows or file bytes
makes any fixed number a statement about the test input — and an unbounded curve on small-RAM
hardware is exactly what an `rlimit` on a separate process exists to bound.

The ruling also warned that the spike must not come back as an implementation to bless. So the
measurement harness is standalone, throwaway, drives the **library** rather than quince's vault, and
is **slice 2 — before any vault code exists.** The architect singled that out as the thing most
likely to be quietly reversed under time pressure, which is worth more than the sequencing itself.

## What is not proven

Nothing is built and nothing is measured. The upstream release the spec depends on — three changes to
`ios-backup-crypt` — is **proposed, not agreed**, and nothing has been opened on that repository. The
rung gate is owed to hardware and declared unrun: `ios-backup-crypt` has still never been run against
a real device backup, so quince#270 §3's validation asymmetry is exactly where it was.

**And the precondition is named rather than assumed** — which is the one thing this entry is really
about, since assuming it is what quince#270 §1 did.

Landed: quince#1343 (`docs/specs/qn.8/qn.8.md`). Corrections posted to quince#270 and quince#184.
