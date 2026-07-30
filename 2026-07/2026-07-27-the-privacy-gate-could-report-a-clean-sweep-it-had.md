# 2026-07-27 — The privacy gate could report a clean sweep it had never performed, and the fix was not the three-line hardening but the twenty-seven fixtures that assert it now fails

**The privacy gate could report a clean sweep it had never performed, and the fix was
not the three-line hardening but the twenty-seven fixtures that assert it now fails.**
[quince#41](https://github.com/novkostya/quince/issues/41), landed as
[quince#73](https://github.com/novkostya/quince/pull/73) (`ff955e1`). `make privacy-check` printed
`no local/privacy-patterns.txt (contributor/CI box) — skipped` and **exited 0**; a checklist cannot
tell that from clean, so the gate ticked itself on precisely the boxes unable to sweep — which,
once work moved off the Operator's machine, was every box where work happens. Every PR in the
2026-07-26 cycle had to hand-declare *"the sweep did not really run"* to stop that `0` being read
as clean. **Now three exit codes**, because *nothing matched* and *I did not look* are different
facts: `0` clean, `1` violation, **`2` DID NOT RUN**. Also landed: a **whole-branch mode** —
`--ref` sweeps the diff, every **commit message** and the branch name, `--text` sweeps PR text —
which is the command `/land`'s *"re-check the whole branch before a merge"* had been instructing
people to run without one existing; a second, **case-sensitively** matched list, since run wholesale
under `-i` a pattern relying on case discrimination is not merely noisy but meaningless (the
device-name heuristic had matched ordinary product prose in two consecutive sweeps); and a matcher
that is **named, versioned and proven to compile** every pattern, with an optional canary proving it
*matches* rather than merely parses. The logic moved out of the Makefile, because a recipe of
backslash continuations can be neither shellchecked nor tested and here **the untested path was the
entire defect**. **The fixtures are the deliverable, not the hardening.** Twenty-seven, each
asserting an exit code *and* its reason, every one synthetic — own throwaway git repos, own fake
pattern lists — so the failure mode of a gate only some boxes can run is testable on **all** of
them, including CI and a contributor's laptop. Mutation-tested rather than trusted, seven mutants
and seven caught, one of which restores the original silent skip verbatim. That repairs
[quince#64](https://github.com/novkostya/quince/issues/64)'s class for this gate; the issue **stays
open**, because `bin/forge-watch replay` is still run by nothing (measured at 23.4 s for 28
fixtures, host-side, which is the answer that issue was waiting for). **Five defects in the change
were found by running it rather than reading it** — two by the author before review, two by the
architect's, and one by writing the fixture for one of the architect's: busybox's `unrecognized
option` error reported *as a version string*; an empty scope called `clean`; an unterminated final
canary line silently skipped **while `canary ok` printed**; `git log A...B` being a *symmetric*
difference, so one `$REF` handed to two commands that read three-dot notation differently swept
commits **not on the branch** — safe direction, but it fires whenever `main` is ahead, the normal
state of a queued PR under strict up-to-date protection and the state `/land` deliberately creates;
and a canary of only comments testing zero probes and still announcing success. Every one is the
PR's own thesis violated inside its own implementation. **The most useful finding was not a defect
at all: an agent measuring its own environment with its own tooling.** Both sessions independently
reported *"`grep` in PATH is ugrep 7.5.0, `/bin/grep` is busybox"* and concluded three
implementations were in play across the workflow — the architect wrote it into
[quince#44](https://github.com/novkostya/quince/issues/44) as a standing fact about the boxes.
`type grep` says **function**: the harness installs a `grep` shell function routing through a binary
that bundles ugrep, and **ugrep is installed on neither box**. Two implementations actually run the
gate — busybox on the boxes, GNU grep 3.11 in CI — and the suite is now green under both, by hand
and then by the ladder. `type` before `--version`, whenever the claim is about a box rather than
about a session. **Owed and not advanced:** quince#44's requirement 1 is **blocked on a ruling**,
because its stated premise is false as measured — the bot token resolves exactly `quince` and
`quince-devlog`, and `quince-local` does not resolve at all, so `provision` cannot clone what the
issue says it should; since the artifact is *the list of sensitive strings*, choosing another
transport is a security decision and three options are filed there rather than one being invented.
The Operator still owes the two pattern-list edits this PR can only **enable** — the case-sensitive
split, and the private layer's own path, so the symlink that *enables* the sweep stops being
invisible to it. ([quince#73](https://github.com/novkostya/quince/pull/73),
[#41](https://github.com/novkostya/quince/issues/41),
[#44](https://github.com/novkostya/quince/issues/44),
[#64](https://github.com/novkostya/quince/issues/64))
