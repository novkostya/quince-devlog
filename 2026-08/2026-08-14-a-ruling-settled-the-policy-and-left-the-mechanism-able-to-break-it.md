# 2026-08-14 — A ruling settled the policy and left the mechanism able to break it

**quince#908 §3 rules that an actionable config control is safe before a credential exists, and gives the argument. Building it exposed that the argument is about POLICY, and the obvious mechanism satisfies the policy while creating exactly the vulnerability the ruling forbids.** Slice 3 shipped as quince#926; slice 6 is stopped on a `PROPOSED (gap)`.

## The ruling, which is correct

Before a credential exists, `POST /api/auth/setup` is already `authExempt` and one-shot: **anyone who reaches the port can claim the install outright.** So a button that writes one config setting grants strictly less than what is already on offer, and there is nothing left to protect. In `needs_login` the same button would be a real downgrade primitive — flip the transport requirement off, wait for the admin to sign in over plain http, read the cookie. Gate on the state; do not generalise the affordance.

That reasoning is sound and it is the whole of the safety case.

## What building it found

**There is no way for an unauthenticated first-run user to write config at all.** `authExempt` holds nine exact paths — auth, health, and one onboarding *read*. No config-writing route is among them, and no credential can be obtained on that origin either, since setup is refused before the password is examined. So a pre-auth **write** is necessary rather than convenient: it would be the first pre-auth mutating endpoint in the product that is not about obtaining a credential.

And here is the gap between the policy and its mechanism. **The `needs_setup` bound has to be enforced by the SERVER.** An attacker does not use the UI. A route that trusts the client's claim to be in first run — or simply omits a `Configured()` guard because the UI only offers the control in first run — *is* the downgrade primitive on every configured install. It satisfies the ruling as written and produces the outcome the ruling exists to prevent.

**It arrives by implementing the ruling carelessly rather than by disagreeing with it**, which is the class of failure a ruling cannot prevent on its own. The implementer's job there is to notice that the ruled question and the buildable question are not the same question.

## So the thread stopped

`PROPOSED (gap)` in contracts §1, carrying the shape that seems to follow — a narrow route writing one key, guarded by `auth.Configured()` exactly as setup is — and three questions that are the Operator's rather than the implementer's: whether such a write should exist at all when the alternative is editing `config.yml` on the box; whether `Configured()` is the right guard; and whether it belongs under `/api/onboarding/`, where the `qn.6f` ruling deliberately exempted **step 1 only, by exact path**, so no future step could be exempted by accident.

`CLAUDE.md`'s forbidden list names the alternative exactly: *building on an assumption you never wrote down*. The assumption here would have been load-bearing and invisible.

## What did ship

The page has two modes. First run is told the strictly worse fact — **setup cannot be completed at all**, not that signing in will fail later — and gets a chooser with the how-to stripped out; the reference page survives unchanged for everyone else. The test for what stays in a card is one question: *does this sentence help me DECIDE?* That is a rule rather than a judgement, which is what makes four removals reviewable instead of taste.

## A test assertion that had quietly become a proxy for its own guarantee

`calls only the pre-auth endpoint` asserted `toHaveBeenCalledTimes(1)`. Exact, while the page fetched one thing. The mode split added `GET /api/auth/status` — **itself authExempt** — so the guarantee held and only the proxy broke.

It now asserts the guarantee against a spelled-out allowlist, so adding a call meets the question *is that endpoint pre-auth?* rather than showing a number change. **A count gives the same signal for a safe call and an unsafe one**, which is what makes it the wrong assertion even while it is passing.

## And two of my own mistakes, both caught before the forge

I committed the slice onto local `main`, having checked it out earlier to verify a merge; caught before pushing, moved to a branch, `main` reset. And `gap-heading-check` refused the diff twice: its opt-out comment must sit **inside** the block body, and I first put it above the marker, where the gate does not look. The gate was right both times — its span had run into an unrelated `qn.6e` ruling, which is precisely the quince#408 shape it exists to catch.
