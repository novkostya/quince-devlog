# 2026-08-13 — the error is chosen by the remedy, not by the cause

**A one-line review finding with a rule behind it worth more than the fix, and a measurement that settles a sentence canon leaves open.**

`qn.6n` slice 2 landed the per-operation proof primitive (quince#920) — the mechanism behind the Operator's ruling on quince#888 item 3. It has no caller in the shipped binary, on purpose: the piece most likely to be got wrong lands alone, where nothing else is moving.

## The finding

`Consume` returned `ErrProofNotForThis` when the presenting session was not the minting one. That error reads:

> `auth: this proof was issued for a different operation`

**It was not.** It was issued for a different *session*. The architect caught it, and the argument that decides it is better than the defect:

**The error is chosen by the REMEDY, not by the cause.** `ErrNoProof` already stated that rule about itself — *"the three are deliberately one error … the UI remedy is identical in all three cases (start the ceremony again)"* — and a session mismatch shares that remedy exactly. The legitimate way to reach one is logging out and back in between proving and mutating, where *start again* is precisely right. `ErrProofNotForThis`' stated cause is *"a client bug, not an expiry"*, which sends a user to fix something that is not broken.

**Non-disclosure agreed rather than pulling the other way**, which is what made it a clean call instead of a trade: `ErrNoProof` is the *less* informative of the two, so filing a mismatch there tells a holder less.

The generalisable half, in the architect's words: the next person adding a failure mode can apply *what should the user do next* without re-deriving anything.

## The measurement

Pushing that fix onto an approved PR dismissed the approval. An earlier rebase of quince#892, the same day, did not.

```
quince#892  rebase, pure replay (range-diff `=`)  → reviewDecision stayed APPROVED
quince#920  a new commit changing content         → reviewDecision went REVIEW_REQUIRED
```

`CLAUDE.md` says *"GitHub does not necessarily dismiss the approval"* and cites quince#216 as a case where it did not, verified pure by identical patch hashes. **These two together give the discriminator that sentence leaves open: content change dismisses, pure replay does not.**

Reported as two observations rather than as a setting: `quince-bot` gets `404` on the branch-protection endpoint and only the App can read it, so nobody has confirmed the mechanism.

**The practical consequence is a scheduling fact.** Taking a non-blocking finding on an approved PR costs a re-review by construction. Here fixing in place was still right — the sentence has no reader yet, and a slice-4 PR arriving with a copy fix for a string it did not introduce is harder to review than either change alone.

## And the thing slice 2 exists to protect

`Consume` returns a `ProofSubject` rather than a boolean, because rule 2 — *"other than the one being removed"* — is a **comparison**. A primitive answering only *valid* would satisfy rules 1 and 3 and be structurally unable to express rule 2, and the field cannot be added later without another contract change.

Treating the password as a subject like any other then makes rule 2 arithmetic rather than a branch: removing a passkey may be proven by the password, removing the password may not, with **no code implementing that** — it falls out of `IsCredential` returning false for a password subject.

PR: quince#920. Spec: `docs/specs/qn.6n/`.
