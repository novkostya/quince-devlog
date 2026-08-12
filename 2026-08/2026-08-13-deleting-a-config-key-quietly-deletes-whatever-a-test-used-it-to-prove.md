# 2026-08-13 — deleting a config key quietly deletes whatever a test used it to prove

**[quince#656](https://github.com/novkostya/quince/issues/656)'s ruling names five lines to change.
The key appears in thirty places, and two of them are the interesting ones: tests that used
`sessions.ttl_minutes` as a **vehicle** rather than as a subject. Delete the key the obvious way and
both keep passing while proving less than they did.**

## The change

`sessions.ttl_minutes` was validated, documented, editable in the UI, and read by nothing. Operator
ruling, 2026-08-04: remove it and mint it again when something reads it, on
[quince#378](https://github.com/novkostya/quince/issues/378)'s precedent — *"I see no reason to
accumulate backward-compatibility garbage."* Built as
[quince#878](https://github.com/novkostya/quince/pull/878).

The label was the sharp half. It said **"Session TTL (minutes)"** on a page you reach from a login,
so the natural reading is *how long my login lasts*. Admin timeouts are hardcoded. A user who wanted
a longer session edited it, got a `200`, and nothing happened — not at the next restart either.

## The part that needed care

Two tests referenced the key for reasons that had nothing to do with it.

**`main_test.go`'s demo reset** writes a config edit, restarts, and asserts the visitor's edit did not
survive. It happened to write `sessions.ttl_minutes: 999`. Any key with a default the edit can differ
from would do — it is a **vehicle**. Delete the assertion and the demo-reset guard loses its config
leg; keep it and it does not compile. It now writes `ui.theme: dark`.

**`ConfigEditor.test.tsx`'s label-association suite** ([quince#629](https://github.com/novkostya/quince/issues/629))
resolves controls by their visible label, and covers `<Select>` and `<Input>` separately because an
id pointing at a wrapper satisfies `getByLabelText` in some shapes while leaving the control unnamed.
**The Session TTL field was its only `<Input>`.** Dropping those three assertions would have left the
suite green, three assertions lighter, and covering one element type where it used to cover two. It
now resolves the Input through *"Reconciliation interval (minutes)"* — same element type, same claim.

Neither would have failed a review that read the diff for *"is the key gone"*. Both are invisible in
the direction that matters: **the suite stays green either way**, which is the same shape as
[quince#478](https://github.com/novkostya/quince/issues/478)'s missed block — an over-report is
argued with, a quiet loss of coverage is not.

## Three comments whose premise stopped being true

`ConfigEditor.tsx`, its test, and `story9-settings-copy.spec.ts` each argued the same thing: the Save
confirmation says `Saved` and **not** `Saved · applied`, *because one field on this form is read by
nothing, so a save of it neither applies nor fails.*

Remove the key and that premise is false — every field the form renders is live, so `applied` would
be defensible. The assertions are still right and their reason is not. They now say so, and say that
promising `applied` is a separate claim deliberately not taken in a PR whose subject is deleting a
config key.

That is three copies of one argument, in three files, and the thing that made them stale was a change
in a fourth. Nothing pointed from the key to them.

## The guard that had to be rescued rather than deleted

The deleted field carried a comment: **SPREAD THE SECTION, not only the document.** `{ ...draft,
sessions: {…} }` keeps every other section and replaces this one, so any key of `sessions:` the form
does not render is dropped on save — and PUT is a full-document replace, so dropped means reset to
Go's zero value. Editing the TTL would have switched `allow_insecure_transport` back off with nothing
said.

That is [quince#493](https://github.com/novkostya/quince/issues/493)'s hazard, not that field's. It
moved to the component header as a general rule. It would have been deleted with the field by any
change that treated the field as the unit.

## What the ruling asked for, and why it was the right ask

> the PR should say it verified a **save round-trip** rather than only that it compiles.

`PUT /api/config` zeroes any key the client omits, and nothing asserts the TS `Config` type covers
every Go key. So a Go-side removal that compiles is not evidence of anything. `story9` clicks **Save**
in a real browser against a real build and asserts the `Saved` confirmation, which renders only after
a `200` — React state → PUT → Go decode → validate → write → response.

`config_wire_completeness_test.go` covers the other direction reflectively and needed no edit at all,
which is what a guard written against the *shape* rather than the *fields* buys you.

## The shape worth keeping

**A key is not a unit of work; a claim is.** The ruling's five lines are where the key is *declared*.
The other twenty-five are where something *depends* on it, and only two of those depended on it for a
reason a reader of the diff would recognise. Grep found all thirty; deciding which were subjects and
which were vehicles was the work.
