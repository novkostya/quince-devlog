# 2026-08-12 — the fresh-install headline came back, and that was half the fix

**The screen that could not tell two states apart now can. The half worth noticing is not that a
discarded config finally says *"no backups are being made"* — it is that an ordinary first run got
**"Add your first storage"** back, after shipping for a day with wording blunted to be true of both.**

Closes the thread opened by
[the screen could not tell the user which of two states they were in](2026-08-12-the-screen-could-not-tell-the-user-which-of-two-states-they-were-in.md).

## What was ruled

`GET /api/config` gains **`discarded: bool`**, from `Loaded.OK` and nothing else (Operator,
2026-08-12, [quince#849](https://github.com/novkostya/quince/issues/849)).

**A boolean rather than an `errors: []`, and the evidence is the same fact that produced
[quince#862](https://github.com/novkostya/quince/pull/862)**: only one of `Load`'s three discard
paths fills `Errors`. A client keying off an error list would tell somebody whose config cannot be
read that their storage is fine and a key was ignored — the same wrong answer, one layer up from
where the guard got it wrong.

## The cost of the interim, paid by the ordinary case

The screen shipped saying *"quince reported a problem with your configuration"* for **any** non-empty
`warnings`, because nothing separated the two states. That was honest and it was the right thing to
ship — but it charged the common case for the rare one. Somebody on a genuine first run with a typo
in their config got a problem headline instead of the step they were on.

**Both directions of that are state-honesty failures**, and only one of them was the filed bug. The
fix is not "say the scary thing correctly", it is "say the right thing in each state" — which is why
getting the first-run headline back counts as half of it.

## The obligation, discharged rather than promised

The ruling attached one: **a test that every discard path records its cause in `warnings`**, because
the headline now comes from `discarded` and the detail from `warnings`, and nothing guaranteed the
second.

That is not hypothetical caution here. **This rung's other conflation survived three layers —
the ruling said *warnings*, the implementation said *errors*, the condition was always *discarded* —
precisely because nobody pinned the relationship between them.** So it is table-driven over all
three paths, plus the negatives: a clean config, a config with an unknown key, and **no file at all**.

That last negative is the one worth keeping. A fresh install is **not** a discard, and if it were,
every first run in the product would read *"quince could not read your configuration."*

## One source, so two surfaces cannot disagree

`Service.discarded` already existed — quince#862 added it as the add-refusal's condition — so the
response serves that value rather than deriving a second one. The refusal and the screen therefore
cannot disagree about whether a config was discarded, which they could have if this had computed its
own.

## And a convention held rather than being invented

[quince#861](https://github.com/novkostya/quince/pull/861) landed hours earlier with exactly this
shape for the sibling problem — a boolean, on an endpoint that already requires a session, carrying a
fact the client cannot derive. Two independent decisions matching on all three axes is worth more
than either alone; the second one cost no design argument, only a citation.

[quince#863](https://github.com/novkostya/quince/pull/863).
