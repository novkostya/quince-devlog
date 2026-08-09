# 2026-08-09 — the key is always the same size, and the clock does not tick that fast

**Two `tlsx` rotation tests failed 13 and 10 times in 300, and on every failure the `Keeper` was
right: nothing observable had changed. An EC private key PEM is always exactly the same size, and
Linux stamps inodes from the coarse clock — so a rewrite microseconds later can move neither half of
`(mtime, size)`. Filed as quince#786, fixed on quince#792.**

Found the ordinary way: `make gates-go GO_TEST_ARGS='-count=3 ./...'` went red while proving
something else (quince#784, a diff touching `core/internal/backup` only). The tempting response was
the one quince#644 warns about — re-run, get `ok (cached)`, call it flaky, move on.

**The mechanism, measured rather than argued.** `Keeper.changed()` compares `(mtime, size)` per file
and reloads if either moved. A standalone probe over 3000 iterations in the pinned toolchain
container:

```
BOTH stamps unchanged (the failing case)  421  (14.03%)
  key  SIZE identical                     3000  (100%)
  key  MTIME identical                    2320  (77%)
  cert SIZE identical                      553  (18%)
```

Two facts combine. **An EC private key PEM is always exactly the same size** — P-256, fixed-length
DER, 3000 out of 3000 — so the key file can only ever signal a renewal through its mtime. And
**mtime is identical 77% of the time**, because Linux stamps inodes from the coarse clock, which
advances once per timer tick. The cert usually rescues it, since the ECDSA signature's DER length
varies (70/71/72 bytes) and the PEM size differs ~82% of the time. When it does not, and the tick
has not advanced, nothing has changed and the test is asserting an event that did not happen.

**The seam existed. Nothing used it.** `keeper.go` carries a `statFn` indirection whose own comment
says it is there so *"tests drive rotation without sleeping and without depending on the filesystem's
mtime granularity — one second on some backends, which would make a fast test flaky rather than
wrong."* `grep -n statFn tlsx_test.go` returns nothing. A guard was designed, written, documented
and never wired, and the flake it was built to prevent has been live ever since.

It also **understated itself**. Not *one second on some backends* — one **timer tick**, on Linux,
everywhere. The filesystem stores nanoseconds; the granularity is the tick, not the precision. That
is a more common failure than the comment's own worst case, and it is why the seam mattered more than
its author thought.

**The fix does not use the seam, deliberately.** `renewInPlace` moves the mtime forward after the
rewrite. That restores the test's *timing* to something production-like rather than faking the
mechanism — a real renewal lands hours or months after the previous load — so `statFile` and the real
`(mtime, size)` trigger stay under test. Reaching for `statFn` would have made the test deterministic
by replacing the thing it exists to exercise.

**Production was never affected**, and saying so was part of the work. A renewal is never
microseconds after the load, so `changed()` always sees the new mtime. A test fix landing in a
package can imply a shipped bug if nobody says otherwise.

**Two things the issue did not know, both found by not stopping at the first answer.**

`TestCertificateDirectoryIsNeverWrittenTo` shares the helper, so it shared the flake — 10 in 300, and
its own *"guard on the guard"* was what fired. One helper, one cause, two tests; the second was never
reported because nobody had run the pair together.

And `snapshotDir`'s doc justified its modtime check *"because nothing in tlsx calls os.Chtimes"* —
which the fix falsifies. Nothing breaks, because the snapshot is taken after the rotation and the
sha256 carries that claim anyway. But the sentence doing the reassuring outlived its truth by exactly
one commit, so it is corrected in the same diff. **That is the argument for the hash, arriving on
schedule**: the review that added it (quince#556) said a claim about what the code does *"is the kind
of claim that stops being true without anyone noticing."*

**The new assertion earns its place, which was measured too.** With the mtime bump removed and
everything else in place, over 300 runs the premise assertion fired **13 times and the old
certificate-name assertion fired 0**. It intercepts every failure and reports *the rewrite left both
stamps unchanged* instead of *still the old certificate* — and the second message sends a reader to
`Keeper`, which is not where the fault is. quince#782's point, applied where it was already costing
something.

**Result: 13/300 and 10/300 → 0/500 and 0/500.**

**Not established.** No CI-history sweep — every rate here is one box and one toolchain container, so
whether this has been reddening CI unnoticed is unknown. And nothing here touches quince#529,
quince#644 or quince#709; the architect's observation on quince#784 stands, that four flakes in this
tree have now been classified one at a time and nobody has looked at them as a set.
