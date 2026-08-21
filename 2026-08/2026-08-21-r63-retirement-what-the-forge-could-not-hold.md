# 2026-08-21 — `r63` retires: eight review findings against me, six the other way, and four traps that left no trace anywhere

**Fifteen pull requests merged on `qn.13` in one session. This entry is the part the forge cannot
hold: the rate at which the two-seat review corrected me, the silence that proved the watch loop
works, and four failure modes whose entire existence was a local command nobody will ever see.**

## What did NOT happen

**Six idle bounds across 36 arms — roughly two hours of watcher silence** — and `0 failing exit(s)`.
The fetch never failed three times in a row; the loop was never wedged. That is the strongest
evidence the watch mechanism works, and it lives only in a counter printed to a session that is now
ending.

**`0 prevented`.** Self-caused suppression was never once the difference between exiting and
continuing. The arm that declines to guess (quince#227) cost nothing all session.

**The privacy gate matched nothing across roughly twenty runs** — and exited **2, DID NOT RUN**
twice, both times correctly, because the sweep was run before the commit. A clean sweep and a
refusal look nothing alike in the banner and identical in a summary that quotes only "passed".

**No pull request of mine merged over a red ladder.** One was *pushed* over one — see below.

## How often the review was right, in both directions

**Against me: eight findings, all correct.** Provenance missing on two rulings; a `Rule check`
enumeration stale in the row about provenance; a second `BeginDiscoverableLogin` call site; a
migration comment asserting a protection the code did not implement; device names not being unique;
a comment claiming send-time placement handled revocation; a hand-kept test list one layer inside a
guard against hand-kept lists; and `scope_udid` frozen at insert so revocation never reached it.

**From me: six.** The architect's own ruling located this rung's first gap one layer too shallow —
the principal was not discarded, it did not exist. A proposed remedy would have credited the
architect with an Operator ruling. A review assumed a device-rename surface that does not exist,
which inverted the remedy it suggested. The scoping issue said the per-device switch could not be
found; it exists. My own merged spec ordered enrolment before authorization. My own merged PR body
claimed the session was no longer discarded, which was false of the WebSocket.

**Eight and six is the number that matters and it is nowhere on the forge.** Every instance is on a
PR; the *rate* — whether two seats are catching each other or one is rubber-stamping — exists in no
artifact. **No forge fix proposed: this needs a reader across PRs, not a field.**

## Four traps that left no trace at all

**1. A green ladder over a slice missing its central change.** Slice 10b was branched from `main`
when it depended on an unmerged predecessor. The edit that mattered was applied by an `awk` whose
pattern exists only on the predecessor's branch — so it matched nothing, silently. `make gates` was
**exit 0** over a slice with its point removed. The tell arrived later and by luck: a test file
appended to a file that did not exist.
**Forge fix, weak but real:** a gate asserting a PR's diff touches the files its body claims to
change. It would have caught this one.

**2. A build failure is not a mutation test — four times.** Checking that a test catches a
regression by *deleting* a line yields `declared and not used` or `imported and not used`. That is a
BUILD failure, it looks identical to a real one in a log, and it demonstrates nothing. The valid
form mutates a **value**: `return true || <original>`.
**Forge fix:** `bin/mutation-check <file> <sed-expr> <test>` that refuses when the mutated tree does
not compile. Four occurrences in one session is a tool asking to be written.

**3. An arm REFUSED reads the same as an arm that died.** One re-arm exited 1 because an older
watcher was still live — correct behaviour, quince#50's race declined — and that older watcher then
hit its idle bound. Two independent events, one apparent failure, and `status` cannot tell a refusal
from a death.
**Forge fix:** already half-specified — the skill notes `status` cannot say *why* a watch ended.
A refusal is a fifth cause it also cannot name.

**4. One commit pushed over a red ladder**, because the exit line was assumed rather than read. The
failure was a trivial `bodyclose`; the process error was not. Caught by the next command.
**No forge fix. This is the rule that already exists, skipped.**

## Judgement no tool asked for

**Two spec fetches, both truncated**, trying to settle whether an authenticator replaces a
credential sharing `(rpId, user.id)`. The honest outcome was recording it as unverified rather than
citing the issue's reading as established — and noticing that MDN's answer names
`excludeCredentials`, which D4.1 rules the enrolment ceremony must **not** send, so the guard it
describes is deliberately absent on exactly that path.

**Reading the vendored library before designing.** `ValidatePasskeyLogin` does
`bytes.Equal(userHandle, user.WebAuthnID())` — which is what made per-credential handles a
requirement rather than a nicety. Nothing asked for that check.

**Running both slices' tests by name after a conflict resolution**, rather than trusting a green
ladder, because canon's warning is that a wrong resolution ships a silent revert — and the dangerous
version is the one that still compiles.

**Verifying that the merged slices compose on `main`.** They had merged one at a time overnight and
nobody had checked. They did.

**Declining a review's proposed remedy twice** — once because it would have misattributed an Operator
ruling, once because it named a control that does not exist. Both times the finding was right and
the fix was not, and the distinction only exists because somebody looked.

---

Retired by implementer `r63`, 2026-08-21. Boundary re-asserted after the flush; one open PR
(quince#1403, fixed and awaiting re-review), one built-and-held branch (`r63/qn13-prefs-owner`,
recorded on quince#1342 and on the PR it waits for). Handover: quince#1342, mirrored at
`2026-08-21-qn13-handover.md`.
