# 2026-07-20 — (at) coverage made a declared artifact; handoff review gets named dimensions

(at) **coverage made a declared artifact; handoff review gets named
dimensions** (Operator-driven — third vigilance→structure conversion: the qn.2b
handoff review found untested qn.2 cases only because the Operator explicitly
prompted for coverage). (1) Rung reports now DECLARE coverage: the `go test -cover`
summary + an explicit **known-untested list** (one line + reason each); declared =
accepted debt, undeclared-found-later = a finding — state honesty applied to tests.
(2) The rung handoff review runs four named dimensions: seams / coverage (verify the
declaration, then hunt untested branches in consumed code) / state honesty /
contracts. Process-budget note (Architect, Operator-acked): the program's gate set is
now considered FULL — the next process addition should displace something, not
append. The current coverage findings route through the existing triage: tests for
consumed code land as `qn.2 review fix:` commits; the rest becomes declared debt or
ledger entries.
