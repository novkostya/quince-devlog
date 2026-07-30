# 2026-07-27 — A box that cannot run the privacy gate now refuses to start — and getting there took three review rounds, every one of which found a claim the change made about itself that it…

**A box that cannot run the privacy gate now refuses to start — and getting there took
three review rounds, every one of which found a claim the change made about itself that it had not
established.** [quince#44](https://github.com/novkostya/quince/issues/44) requirements 2 and 3,
landed as [quince#79](https://github.com/novkostya/quince/pull/79) (`a03fd0d`). Ruled by the
Operator: **hard-fail now** rather than waiting on requirement 1, accepting deliberately that a box
rebuilt before `provision` can place the layer will refuse to start — hand-placement is a step a
rebuild needs anyway, and *a box that starts and silently cannot gate* is the worse failure and the
one the issue was filed about. Two constraints came with it, and both are now **pinned by
fixtures rather than honoured by memory**: the message **names the fix that exists at the time**
(hand-placement today; correcting it to name `provision` belongs to requirement 1's PR, and the
fixture asserting today's wording is what will fail and force that), and it **does not claim to
know why** — a private repository 404s identically for *does not exist* and *not granted*, so a
guess sends the next reader to recreate a repo when the fix is a one-click grant. That second one
is asserted by an unusual fixture: it greps the refusal for `does not exist`, `lack permission`,
`access denied` and **fails if any appear** — a test for what a message must *not* claim.
**Round 1 found the change failing its own title.** A pattern list of only comments has bytes, so
`test -s` passed it: the box came up asserting *"the privacy gate can run on this box"* while
`privacy-check` returned **2** on the identical file, so every sweep afterwards would say DID NOT
RUN. The fix was structural rather than a third condition — `preflight` now **runs the gate's own
validator and takes its exit code**, because two implementations of one predicate about one file
is how the two answers diverge. **Round 2 corrected an assumption stated as fact in two places and
never run:** the claim that exit `1` *"cannot occur here — no `--ref` means an empty scope"*. No
`--ref` means the **staged diff of the current directory**, and `preflight` inherits the service's
cwd — `runner_dir`, the launchpad, a real repo sessions work in. An interrupted commit there made
`preflight` refuse while the gate had just run perfectly, and print a fix telling someone to
replace a **healthy** pattern list; in `start_pre` that is a box that will not boot, pointing at
the one artifact that must not be casually replaced. Fixed with `-ne 2`, which is exact rather
than a workaround: `0` and `1` both prove the gate ran, and `2` is the only code meaning *did not
look*, which is the only thing preflight asks — quince#41's three-code contract used as designed.
**A leak was caught while writing that fixture, and it is the more serious of the two:** on exit
`1` the gate's stderr carries **the matched lines**, and `preflight`'s output goes to
`/var/log/quince-runner.log`, so printing it would have had preflight publish exactly what the
gate exists to contain. A fixture now asserts the matched string never appears in its output.
**Two further defects were found in the fixing, both in text written hours earlier by the people
reading it:** `privacy-check`'s absent-list message said the layer *"is placed by
`deploy/runner/provision`"* — naming a capability nobody had built, the exact thing the ruling's
first constraint forbids, in the file that exists to close that class; and the `grep -c` trap
(prints `0` **and** exits 1, so `|| echo 0` fires too) was re-implemented one directory away from
the comment warning about it. The architect recorded reading that first message during an earlier
review and pasting its output into an approval without noticing: **reading output for *whether it
refused* is not the same as reading it for *whether what it said is true*.**
**Requirement 1 remains blocked, and the block is a measurement rather than a preference.** The
ruling's rationale — *"both boxes already hold this file, so cloning adds no new exposure"* — is
false twice over: the bot holds **`write`**, not read, so the implementer identity can weaken the
pattern list that constrains it; and the boxes hold exactly one 107-byte file while the repository
holds eight, ~600 KB, including four `chatgpt-*.md` transcripts that `CLAUDE.md` names as
Operator-private and `.gitignore` carries a dedicated rule to exclude. `git clone` takes all of it.
A narrow clone (`--filter=blob:none --sparse`) was proposed and **neither variant built**;
escalated as a credential-scope question, which is the Operator's.
([quince#79](https://github.com/novkostya/quince/pull/79),
[#44](https://github.com/novkostya/quince/issues/44))
