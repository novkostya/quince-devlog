# 2026-08-15 — the gates were run, and the architect was wrong

**Two hardware gates owed since `qn.6n` shipped seven green slices were finally run, and the first
thing they did was falsify a constraint the architect had ruled into two PRs. The prediction was
sound, it was labelled UNMEASURED, and that label is why anybody ran the experiment.**

The work ran on 2026-08-14: quince#998, closing a thread that began at quince#930 and passed through
quince#976, quince#988 and quince#991.

## What was owed

`qn.6n` shipped **seven green slices** without its two hardware gates. `qn.6o` then shipped five
more — spec, `accepts` on the wire, the shared challenge, the add row, removal — and declared the
same two gates unrun in **six consecutive pull requests**. Every suite was green throughout. Nothing
in either rung had met a real authenticator.

## The prediction

Reviewing `qn.6o`'s spec (quince#972), the architect asked for a constraint on slice 4: `create()`
needs transient user activation, so it must not sit behind an extra round trip. Reviewing slice 3
(quince#986) it followed that constraint one step further and found it unsatisfiable as written —
**proving with a passkey in order to create a passkey spends the gesture on the proof's own
authenticator sheet.** Completing a sheet grants no new activation, so `create()` would arrive three
awaits and one sheet past the last real click.

The corrected rule (quince#988): *do not chain `create()` off a passkey proof without a fresh
click.* quince#991 built it — the proof is parked and a distinct **Create the passkey** button
supplies the gesture.

**The spec recorded it as UNMEASURED**, naming both directions: Chrome is lenient about activation
for `create()`, Safari is strict, and nobody had run either.

## What the hardware said

`quince auth reset` → passkey-only install set up on an iPhone → signed in on a Mac by QR → added a
passkey → confirmed with the iPhone's passkey by QR → **the creation prompt appeared by itself.**

The mandatory extra tap was removed the same day (quince#998).

## The part worth keeping

**The reasoning was not deleted.** It stands in the spec with the measurement beside it, because the
`UNMEASURED` label is what made the experiment obvious to run — a prediction that flags its own
evidence is worth more than one that happens to be right.

**And the replacement is better than either alternative.** `registerPasskey` cannot tell a lost
activation from a dismissed sheet — both answer `false` — but the **caller knows whether a human
just clicked**. So the chained attempt runs first, and a refusal renders the button instead of
resetting the row. Where the measurement holds nobody sees a second press; where it does not, the
user is one real click away. What was measured is one engine and one transport, and the design says
so rather than generalising from it.

**It also closed a silent failure found on the way to the gate.** A refused chained attempt used to
reset the row and show nothing, so pressing **Add** on a device already holding the credential
looked like a dead button. The gate did not only pass — it found something.

## How the gates were confirmed

Not from anybody's recollection of what they clicked. **G8**: `reauth_passkey` in the audit log at
`18:44:48`, the new credential created at `18:45:00` — an assertion authorised the write, not the
password. **G7**: the new passkey is named `mac`, which the setup-screen offer cannot produce
because it hardcodes `This device`, and the audit window holds **no** `reauth_passkey` — so the proof
was the password on an install with no passkeys.

G7's first attempt was genuinely ambiguous until the passkey's *name* separated the two code paths.

**A gate whose pass can be read off the database afterwards is a different kind of gate from one
that rests on a report** — and that sentence is the reusable half of this entry.

## What it cost to get here

Six pull requests declared these gates unrun, each time noting the gap was widening rather than
closing, because every slice added mechanism that the gates were the only way to check. That is the
argument for running a hardware gate early rather than at the end of a rung: `qn.6o` existed partly
to make G8 *reachable from a UI at all*, and the rung had to be nearly complete before the gate it
was owed could be attempted.
