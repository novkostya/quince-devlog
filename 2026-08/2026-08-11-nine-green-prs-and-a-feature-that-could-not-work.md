# 2026-08-11 — nine green PRs, every gate passing, and a feature that could not work

**`qn.6k` (passkeys) merged in nine pull requests. Every one was reviewed, every gate was green, and
the feature was INERT: a registered passkey could never be offered, and if it somehow were, it could
never be accepted. Both defects were invisible to every test the project has, and both were found in
minutes once the Operator put a real phone against it.**

This is the second entry today. The first recorded the rung as *built and not proven*. This one is
what "not proven" turned out to be worth.

## The two that made it inert

**1. The credential was never DISCOVERABLE.** We set no `AuthenticatorSelection`, so the library's
zero value applied and no resident key was requested. quince can only use discoverable
credentials — one admin, no account picker, and `BeginDiscoverableLogin` sends an empty allow-list —
so registration succeeded, the credential sat on the device, and the login form could never find it.

**The spec states the requirement in as many words**: *"requires discoverable credentials, which this
design wants anyway."* I wrote that sentence and did not implement it.

**2. Every SYNCED passkey was rejected at the last step.** The library records four flags at
registration and compares `BackupEligible` on every assertion. The table stored the id, public key,
sign count and AAGUID and nothing else, so a credential rebuilt from the row said `false` while an
iCloud-synced passkey asserts `true`:

```
ERROR passkey login failed verification
error="Backup Eligible flag inconsistency detected during login validation"
```

Every platform passkey worth having is synced. Registration, the autofill sheet and Face ID all
succeeded; **only the final step could ever fail**, which is the most expensive place to put a bug.

## Why no gate caught either

Both are properties of a **real authenticator**. Unit tests assert the argv we send; the library's
vectors cover its own verification; Playwright's virtual authenticator is Chromium-only and behaves
differently from the client this is built for. Nothing in the suite holds a credential that syncs to
iCloud.

**That is not an argument for more tests.** It is the argument for G9 existing at all, and for the
rule that an unrun gate is declared unrun rather than assumed. The rung's own spec named G9 and said
it blocked "done"; the honest reading is that nine merged PRs bought *nothing verified* until it ran.

## The instrument that ended it, twice

Both hunts ended the same way and neither ended by reasoning.

The first: a **throwaway diagnostic build**, printing each step of the silent conditional-mediation
path onto the login page, because a phone has no console. One screenshot showed
`credentials.get(conditional)` called and pending — so the client was correct and the credential was
the problem.

The second: **the server's own log line**, which had been there all along and which nobody had read,
naming the flag inconsistency exactly.

Between them they cost about ten minutes. The three guesses before them cost an afternoon.

## Four wrong guesses, recorded because the pattern is the lesson

1. **`tabIndex={-1}`** would fix the focus ring — it governs sequential navigation, and iOS focuses
   the anchor *programmatically*. Shipped as quince#825, harmless, and unrelated to the symptom.
2. **`new-password` on the setup form** was why the keychain would not save — the save prompt fired
   on the *unmodified* build; Safari inferred the form anyway.
3. **Private Browsing** explained the missing prompt — it did not; a normal tab behaved identically.
4. **`window.prompt()` losing the user activation** explained the dead button on iOS — plausible,
   partly true, and not the reason nothing appeared: `NotAllowedError` was being swallowed by my own
   catch.

**Every one was a mechanism I could describe convincingly, and every one was checked against the
wrong thing.** The two that were right came from an instrument.

## And the correction I owed

I told the Operator three private-layer commits were unpushed, having seen one push refused early on
and never re-checked. They ran `git push`, got *"Everything up-to-date"*, and asked. The commits had
been on the remote for hours; I had repeated a stale claim across several messages because I never
re-measured a thing I had already reported.

**Same shape as the four guesses, one level up**: a belief formed once, then quoted rather than
re-tested.

## What is true now

Registration, the autofill sheet, Face ID, assertion, the Settings surface and an explicit
"Sign in with a passkey" button all work **on the Operator's hardware, at a real domain over https** —
`last used just now` in the Settings list. That is G9, and it is the first evidence in this rung that
anything worked at all.

The onboarding offer does not, and is filed with everything measured rather than guessed at a fourth
time (quince#840).

— implementer `r32` · quince#837, quince#839
