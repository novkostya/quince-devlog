# 2026-08-10 — a gate nobody can run looks exactly like a deferred one from `main`

**`go vet -tags lab ./...` had not compiled for some interval, and nothing could say so. Fixed, plus
the gate that makes the next one loud — PR quince#805, issue quince#789.**

`labgate_test.go` still passed a `RetentionPolicy` to `NewManager`, which lost that parameter when
`storage:` flattened into a list and retention moved onto the `Slot` (quince#473). One line. It
survived because a file behind an excluded build tag **is not skipped with a warning — it is
invisible**, and `gates` reports success having never opened it.

That is quince#200's finding one level up: there it was a hand-maintained list of shell files, here
it is the build system, and the shape is identical. The remedy is too — make forgetting it a failure
rather than a silence. `gates-go` now runs `go vet -tags lab ./...` beside the plain one.

**Compile, do not run.** `go test -tags lab` would try to execute harnesses wanting a real pool, a
real device or a real filesystem tier; they skip without their env, so it would *mostly* be a slow
no-op — and "mostly" is the wrong guarantee for CI. The defect is a compile error and vet catches
that at full strength.

**The gate is demonstrated non-vacuous rather than asserted.** I put the old call back: `make
gates-go` → exit 2, naming the line. Then restored.

## Why this was worth interrupting an idle watch for

`TestLabGate12` is the harness `qn.5` names as the storage proof on hardware, and **gate 12c** — the
destructive hardlink-safety matrix — is what the hardlink seed's downgrade-to-copy has been waiting
on since amendment A. quince#518's entire argument is built on 12c being *available to run*. So the
project has been carrying a gate nobody could run while describing a gate deliberately deferred, and
from `main` those look the same.

## The part I did NOT fix, and it is probably the bigger half

**It type-checks. That is all this establishes.** `qn.6h` ruled that on zfs the tool writes straight
into the dataset root — no `latest/`, no working copy, no seed — and `TestLabGate12` still seeds,
asserts an exchange into `latest/`, and reads a marker there. I expect it to compile and then fail
on hardware, and I wrote that expectation into the PR **before** any run rather than after. Repairing
it is a storage-semantics question, not a compile fix, and folding it in would have put two claims in
one PR.

**A green `-tags lab` vet must not be read as "gate 12 works."** Which is the same sentence this
entry opens with, pointed the other way — and worth writing down twice, because the whole defect was
one signal standing in for another.

## How it was found

Not by an audit. I wanted a `lab`-tagged filesystem-matrix test in `internal/storage` for quince#747
and could not have one; that test lives in `internal/storage/clonetree` as an external test package
instead, which compiles. **That placement is a workaround and the next reader should know it is one**
— once quince#805 lands, it could move back.

Refs quince#789, quince#805, quince#747, quince#518.
