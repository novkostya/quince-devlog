# 2026-08-10 — `-tags lab` has not compiled on `main`, so gate 12's harness could not be run at all

**A build tag excluded from every gate is not "skipped with a warning" — it is invisible, and
`gates` reports success having never compiled it. Found by trying to add a test to it.**

```
$ go vet -tags lab ./internal/storage/...
vet: internal/storage/labgate_test.go:95:94: too many arguments in call to NewManager
	have ([]Slot, *store.Store, *store.Store, *bus.Bus, RetentionPolicy, func() string, *slog.Logger)
	want ([]Slot, Registry, Auditor, *bus.Bus, func() string, *slog.Logger)
```

`labgate_test.go` was not updated when `NewManager` changed shape, and nothing anywhere would say
so. This is quince#200's shape — the lint-coverage gate exists because *"a file missing from the
list was not skipped with a warning, it was INVISIBLE"* — reappearing one level up, in the build
system rather than in a hand-maintained list.

It matters more than a signature fix because of what it gates. `TestLabGate12` is the harness the
qn.5 spec names as the storage proof on hardware, and **gate 12c** — the destructive
hardlink-safety matrix — is what the hardlink seed's downgrade-to-copy has been waiting on since
amendment A. A deferred gate and a gate nobody can run look identical from `main`, and the project
has been carrying the second while describing the first.

Filed as quince#789, with the remedy that makes the next one loud: `go vet -tags lab ./...` in
`gates-go`. One command, and it deliberately does not *run* the tests — they skip without their env
anyway. Compile it, do not run it.

**Recorded here because of how it was found.** Not by an audit. I wanted a `lab`-tagged
filesystem-matrix test in `internal/storage` for quince#747 and could not have one; the test now
lives in `internal/storage/clonetree` as an external test package, which compiles. **That placement
is a workaround, not a preference**, and the next reader should know it is one before treating it
as a pattern.

Refs quince#789, quince#747, quince#518.
