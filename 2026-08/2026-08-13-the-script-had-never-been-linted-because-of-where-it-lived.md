# 2026-08-13 — the script had never been linted because of where it lived

**`quince-zfs-helper` is a forced command that runs as root on the operator's storage host, and it
had gone through rungs without shellcheck ever opening it — not because anyone excluded it, but
because it lived inside a fenced block in `deploy/storage.md`, and a coverage gate can only see
files.**

quince#818 piece C — the half deferred on quince#884 — needed the script served from the UI with the
operator's `parent_dataset` already substituted. That needs `go:embed`, `go:embed` cannot reach
outside its module, and the module root is `core/`. So the file's location was decided by a mechanism
rather than by taste, and the move to `core/internal/storage/zfshelper/` was the whole of quince#887.

**Three things fell out that were not the point of the change.**

`bin/sh-lint-coverage` asserts that every shell file on disk is in a lint list — a totality gate built
after quince#200 found `deploy/e2e-run.sh` had never been shellchecked. It demanded the new file be
listed, and shellcheck immediately reported `SC2086` on `set -- $SSH_ORIGINAL_COMMAND`. That one is a
false positive by design — a forced command receives its request as one string, so the split *is* the
argument parsing, and quoting it would make every verb fall through to the refusal — but **nothing
had ever asked the question**, and the answer is now written next to the line. The gate's own comment
had said the risk was a file being *"INVISIBLE"* rather than skipped with a warning. This was a third
instance, hiding in a document.

The Go gate stopped parsing prose. `hookcheck_test.go` had found the script by splitting the markdown
on fences and matching two content markers, plus a `PARENT="…"` string replacement — three couplings
to a document's shape, each with its own loud `G8 CANNOT RUN` failure, because a fence has no other
handle. All three are gone, and **a prose edit can no longer take a gate down**.

And a new test asserts the embedded bytes equal the file the suite executes, so *"the script quince
serves is the script the gate proves"* is checked rather than claimed in a comment.

**Then the Operator read the diff and asked the question nobody in the loop had.** The file is
displayed verbatim in the UI and installed from there — so who is it written for? It was **90 lines,
65 of them comment**, mostly this project talking to itself: rung citations, a `CTUID=` history, verb
changes for an upgrader, measurement dates. Two rounds of trimming took it to **31 lines with the
code byte-identical**, and the rule that emerged is worth more than the diff: **every comment that
survived says something the code cannot show.** Two are absences — *cannot destroy a dataset*, *no
`-r` on rollback* — which a reader would otherwise have to prove by exhausting the `case` arms. Two
guard against a change that breaks things silently. One answers *why does this script chown anything*,
which is what an auditor asks. Everything that restated the line beside it went.

The sharpest note was the smallest: **a file saying `Install as /usr/local/sbin/…` addresses somebody
who has not installed it, and every reader of the installed copy has.** Those instructions moved to
`deploy/storage.md`, and the screen carries them beside the copy button, which is where somebody
about to paste is actually looking.

**Identity was verified twice rather than eyeballed**, because this is a security boundary: comments
stripped from both versions, whitespace normalised, diffed → identical; and the G8 suite executes the
script through an ssh-shaped shim across every arm plus the refusal fall-through.

**What piece C then closes** (quince#891): the zfs branch used to show an `authorized_keys` line
whose forced command names a script the screen never mentioned. Install only the key and every verb
is refused on the far side, which surfaces as `unreachable` — indistinguishable from a wrong key, a
wrong host, or a missing host key. The substitution is done **server-side**, because whoever
substitutes must also validate: the value lands inside a double-quoted assignment in a script run as
root on another machine, so `tank"; rm -rf /; x="` is a `422` naming the field. Refused rather than
escaped — every legal ZFS name already passes `datasetPattern`, so nothing valid is lost, and a
refusal cannot have the bug an escaping routine can.

The failure worth guarding is silent: rename the `PARENT=` line and `strings.Replace` becomes a
no-op, so quince would serve a helper still pointing at `pool/path/to/iphone-backup`. That script is
valid, installs cleanly, and backs up to the wrong place. Guarded at build time and at run time, both
verified red.

**Not proven, and it cannot be here:** nothing has run against a real pool — quince#730 records that
no agent seat has a live ZFS host — and the rendered script has never been installed and pinned as an
actual forced command end to end. The gate proves control flow against a stubbed `zfs`. The effect on
a pool is the Operator's to measure.

quince#887, quince#891.
