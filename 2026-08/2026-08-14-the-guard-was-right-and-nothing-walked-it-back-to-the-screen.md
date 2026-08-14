# 2026-08-14 — The guard was right, and nothing walked it back to the screen that calls it

**`qn.6n` rule 1 shipped correct and broke the first-run flow, because the guard was verified where it was written and never at the one screen that calls it. The review that found this named the shape exactly — and then the fix for it repeated the shape one level down, inside the same review.** Slices 5b, 6a, 6b and 7: quince#930, quince#937, quince#945.

## The defect

Rule 1 says adding a credential requires presenting one. `register/begin` enforces it. On a **password-first** install the first-run screen sets a password and then, on the same click, offers to add a passkey — at which point the install is `Configured()` with a password and no credentials, so `RequirePresent` verified an empty `current_password`, answered `bad_password`, and the client rethrew it.

The user was told **"current password is incorrect"** about a field that screen never shows.

The password was in scope two statements above the call. `register/begin` had grown a `current_password` field for exactly this case, `contracts.md` documented it, the handler read it — and **no client sent it.**

## Why every gate was green

Three layers mocked past it, each reasonably on its own:

- `auth.test.ts` mocked the first `begin` as `reauth_required` — the answer a **passwordless** install gives, not the one this flow's install gives. The test encoded the assumed server behaviour.
- `SetupPasswordPage.test.tsx` spied on `registerPasskey` wholesale, so the guard was invisible to it.
- The e2e asserts the passkey checkbox is **absent**, because Playwright runs over http and passkeys need a secure context.

**And the hardware gate this rung worried most about would not have caught it either.** G7 is assert-then-create on iOS; this fails before any authenticator sheet exists.

## The part worth keeping

The review's diagnosis was *"a claim about behaviour verified at the mechanism and not at the destination."* The fix presented the password at the call site and added a test proving `registerPasskey` sends one when given one.

**That test pins the function. The function was never wrong — the screen was.** Reverting the call site to the line that shipped broken left the suite green: `Tests 431 passed`. `expect(reg).toHaveBeenCalled()` was true of the broken call, which is why it never fired.

So the substitution survived one round *inside the review that identified it*, with the sentence already written. It is not carelessness; it is that "verify the guard" and "verify the caller" feel like the same task and are not.

## What it changed downstream

Rule 2's removal paths have call sites too, and `remove_passkey` carries a **target** — so the argument there is not present-or-absent but *which credential*. The tests assert the id:

```ts
expect(del).toHaveBeenCalledWith("/api/auth/passkeys/a", { current_password: "hunter2" });
```

A laxer check would pass a call that deleted the wrong row.

## Two smaller things the rung turned up

**An enumeration was short by its most dangerous entry.** *"A ceremony key is only ever produced by a guarded begin"* counted two producers; there are three, and the third — `passkeys/login/begin` — is pre-auth in all three allowlists. Nothing was exploitable, but only because `go-webauthn` refuses the cross-use on session shape: an invariant in a **dependency**, which nothing here tested and a version bump could have changed silently. A ceremony now records what it was begun for.

**A spec's own analysis was one remedy short.** D8 concluded that `quince auth reset` was the only truth left for a user whose passkeys are bound elsewhere. A passkey registered for another address still works *at* that address, and a password set from there is not rpId-bound — so it works everywhere. Sending somebody to a console to clear every credential they own, when a different URL would have fixed it, is the same *"more expensive direction"* that decision was written to avoid, one level down.

## The habit this is an argument for

**A probe that exits non-zero has not proved anything; a probe that fails on its assertion has.** Three times this session a non-vacuity probe failed for the wrong reason — an unused variable, an unused function, a lint error — and each looked exactly like a red test. Reading the failure rather than the exit code is the whole of the discipline.
