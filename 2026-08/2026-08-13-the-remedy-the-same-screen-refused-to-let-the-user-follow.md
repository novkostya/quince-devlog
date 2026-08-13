# 2026-08-13 — the copy offered a remedy the same screen refused to let the user follow

**A surface can be self-consistent, correct against its own tests, and still lie — because the sentence it renders is contradicted by a component ten lines above it. Neither file's suite could see it, and the defect existed only in their composition.**

`/settings/auth` said *"This quince has no password — you sign in with a passkey"* whenever `has_password` was false. That field means three different things:

| state | what is true |
| --- | --- |
| **passwordless** | a passkey works at THIS address |
| **elsewhere-only** | passkeys exist, none bound here — **nothing can sign in at this address** |
| **unconfigured** | no credentials at all |

The screen rendered the first for all three. Fixing that is quince#895, item 2 of quince#888.

## The state that survives the security fix

quince#892 stopped the credential set being emptied, so *unconfigured* is now hard to reach through the UI. **`elsewhere-only` is untouched by it**, because you do not reach that state by removing anything — you reach it by being *at a different address*. A quince reached by a second name holds passkeys that cannot sign anybody in there, which is `qn.6k` D2's hazard arriving on the settings screen rather than at the login form.

The Operator demonstrated the mechanism the same day from the other side, testing http against https: on a bare IP the passkey affordances correctly vanish, because an rpId must be a domain and no certificate changes that.

## And then the fix repeated the bug one level up

The new `elsewhere-only` copy said: *"Set a password to fix that, or add a passkey for this address."*

`Passkeys`, rendered **ten lines above it on the same page**, says *"an address like this cannot hold a passkey"* — with its **Add a passkey** button disabled.

The architect reproduced it rather than reasoning about it: a probe appended to the suite in a scratch clone, `1 failed | 405 passed`, file restored. And the part that turns it from a corner case into the default:

> `RPIDFromRequest` returns the IP, not `""`, so your `!rpID` fallback does not fire; `isUsableRPID` refuses an IP, so no row can ever match; therefore **every** passwordless install with any passkey, reached at its IP, lands in `elsewhere-only` and gets the unfollowable half of the sentence.

**The author's own fallback was written against a belief about the code that was wrong.** I added `if (!rpID) return "passwordless"` specifically so a bare IP would not produce a false lockout warning — and a bare IP never produces an empty rpId, so the branch guarding against exactly that case is dead on exactly that input.

`qn.6g`'s rule is the one this breaks: **a remedy the user cannot follow is the same defect as a silent failure.**

## What made it invisible

Three separate rpId comparisons on one page — the per-row warning, and twice inside `PasswordControls`. Each self-consistent; two of them disagreeing is the bug. They now go through one exported predicate beside the type both surfaces already import, so they *cannot* answer differently.

The test that catches it mounts **both components in one tree**. Either alone passes under the broken code.

## The fixture was ambiguous in exactly the way the code was

`renderControls(false)` passed `passkeys: []` — which is *unconfigured* — while every test below read it as *passwordless*. **Code and tests assumed the reassuring reading together**, which is why no existing test could have caught the original defect. Two of them failed the moment the distinction became real, and were fixed by making the fixture say what it had always meant.

The reviewer found a second instance of the same shape in the repair: `passkeys: hasPassword ? [] : passkeys` silently discarded an argument. Harmless today, and precisely the class of thing being fixed.

## A pattern worth naming: a probe that does not compile is not a red test

Five probes across this batch, **three of which never executed a single test**:

- an early `return` left the rest of a function unreachable, losing type narrowing → `'data' is possibly 'undefined'`;
- deleting a JSX block left its import unused → `TS6133`;
- forcing a condition true → eslint `Unexpected constant condition`.

Every one exited non-zero, which is what a *red test* also does. **The exit code does not distinguish "the guard failed as designed" from "the build never got that far"** — only reading the output does. The non-vacuity discipline is worth nothing if the red is coming from the compiler.

## What is still open

Item 3 of quince#888 — requiring a *present* authentication for credential mutation — remains unruled, including the architect's finding that the recovery path and the persistence attack are the same operation.

PRs: quince#892, quince#893, quince#895. Issue: quince#888.
