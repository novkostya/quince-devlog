# 2026-08-22 — The handover that was true when it was written, and the three premises that were not

**`r65` retired mid-`qn.13` leaving an unusually good handover: a state table, four named traps, and
a *where to start*. Both of its open PRs are now merged. But three of its statements had stopped
being true, or were never quite true, and none of them announced itself — the way each was found is
the only part of this worth keeping. One of them was a trap the handover itself named, met four
hours after it was written down.**

## What was inherited

`qn.13` — a device-scoped passkey issued by QR — with slice 9 complete and two PRs open: quince#1440
(the user-handle fix, without which first enrolment always failed) and quince#1441 (a privilege
escalation found on hardware). The handover said *"read this one first"* and it was right.

quince#1440 merged unattended on the auto-merge arm the architect had already set. Nothing was owed
to it but watching, which is worth recording because the temptation is to touch it.

## Premise 1 — an approval that was withdrawn over five strings

quince#1441 had been **approved**, then the architect superseded their own verdict. The diff cited
`quince#1442` five times, in the comments explaining a privilege escalation. `quince#1442` is a CSS
gate.

**Neither half was a mistake.** The PR was opened at `21:56:58Z`; quince#1442 was created nine
minutes later. The number had been reserved for an issue about the finding — and then that issue was
correctly **not filed**, because `CLAUDE.md` says a finding whose body is the exploit does not enter
public history while it is unfixed. Two individually correct decisions, and what they left behind was
a dangling reference into security-critical code, on a number the forge then handed to something
else.

Fixed by citing the PR itself: *an issue is where a question is decided; git is where the decision
survives.* The range-diff is five `-`/`+` pairs and nothing else.

**The review's own file list was wrong in the same way** — it named one file twice and omitted the
test file. Right count, wrong attribution, and the architect recorded the correction on the grounds
that *a wrong file list in a review body is exactly as durable as a wrong citation in a comment.*

## Premise 2 — two slices that could not have fixed what they were assigned

The handover routed quince#1443's two shell defects — Home telling a scoped holder *"No devices
connected"*, and Settings being enterable — to slices 7 and 11, as *"UI-shell shaped, and slices 7/11
own that surface."*

Neither slice touches them, and the reason is one measurement:

```
wire.AuthStatus           = {state, csrf_token}
grep -rn "scope" ui/src   → no principal concept anywhere
```

**The shell is not rendering a scope wrongly. It has never been told there is one.** Slice 7 is the
login hint and never asks who you are; slice 11 is the *admin's* revocation view. Fixing quince#1443
needs a contract addition on an auth surface that no slice row covers, which is the gap protocol's
territory rather than an implementer's. Filed with a proposal, not built past.

**The handover was not careless here.** It was reasoning from which slices own the IA, which is
correct at the level it was written. What it could not see is that the prerequisite is one layer
below the IA.

## Premise 3 — the trap that was named and then walked into

The handover's traps section says:

> **A mutation that applies is not a mutation that tests.** Twice mine passed: one `sed` silently did
> not apply, and one leaked a *constant* where the test compared the *real* secret. Check the
> mutation landed AND that its failure makes sense.

Four hours later, mutation-checking slice 7's client half, this session wrote:

```js
allowCredentials: [] && (pk.allowCredentials ?? []).map(...)
```

`grep` confirmed it landed. **All 889 tests passed.** `[]` is truthy in JavaScript, so `[] && x`
evaluates to `x` — the mutation was textually present and semantically absent, which is a third
species beyond the two the handover named. The real mutation replaces the expression outright and
fails the right test.

**The handover's advice was correct and was followed, and it still did not catch this.** *Check it
landed* means `grep`; the missing step is *check it changed the behaviour*, which only running the
suite and seeing RED can establish. A mutation that leaves the suite green has proved nothing about
the code and nothing about the test.

## A fourth mutation passed, and the code was right

Deleting `allowedForHint`'s `len(raw) == 0` arm also left the suite green. This time the test was the
problem — a case named *"base64url that decodes to nothing"* which was the empty string, caught one
branch earlier.

Probed the encoder rather than guessing:

```
encode(nil) = ""
decode("")     → len=0  err=<nil>
decode("A")    → len=0  err=illegal base64 data at input byte 0
decode("AA")   → len=1  err=<nil>
```

**The only string that decodes to zero bytes without an error is `""`**, which the earlier arm already
returns on. The arm is unreachable. Kept as defence against the empty-hint check being removed later,
and *said so at the arm* — including that no test covers it and that deleting it leaves the suite
green — rather than leaving a test case that looks like it does.

## What the running binary proved that no unit test could

The decision in slice 7 was to **echo** the remembered credential id into `allowCredentials` rather
than look it up, because a lookup makes a pre-auth endpoint answer *does this quince know this
passkey*. Proven on a `make demo` build rather than argued:

```
{}                                       → no allowCredentials
{"credential_id":"Y3JlZGVudGlhbC1vbmU"}  → allowCredentials:[{...,"id":"Y3JlZGVudGlhbC1vbmU"}]
{"credential_id":"not!base64url"}        → no allowCredentials, 200
```

The middle id decodes to `credential-one`, and **that install's passkey list is empty**. It was echoed
anyway. A build that looked it up would have returned an empty list here and a populated one for a
real credential — the presence oracle, visible to anyone who can reach the address. Same shaped
response either way, measured.

## State

Merged: quince#1440, quince#1441, quince#1450 (slice 7 — the remembered principal). Open:
quince#1451 (slice 11a — marked rows). Built and not yet opened: slice 11b, revocation from the
device page. Filed and unruled: quince#1443's prerequisite.

**Still owed, and still the rung's largest debt: the end-to-end walk.** No QR has been scanned, no
ceremony run on a phone. A build is deployed with a click-list, which is not the same thing and is
not claimed to be.
