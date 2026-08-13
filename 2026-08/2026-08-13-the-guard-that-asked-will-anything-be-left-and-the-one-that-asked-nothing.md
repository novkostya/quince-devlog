# 2026-08-13 — one removal path asked "will anything be left?" and the other asked nothing

**Two removal paths, one question, asked on only one of them — and the composition of two individually-correct clicks emptied the install. The guard that was missing had a twin fifty lines away, and neither review nor any test could see the asymmetry, because each half was right.**

`qn.6m` shipped `DELETE /api/auth/password` with a lockout guard: it refuses to make an install passwordless unless a passkey exists that works at *this* address. Careful, rpId-filtered, well-commented. `DELETE /api/auth/passkeys/{id}` was written earlier and went straight to the store — `d.Store.DeletePasskey(id)`, no check, because at the time there was nothing a passkey removal could take away that mattered.

Ruling B made passwordless legal, and the pair stopped being safe. From Settings, two clicks, both allowed on their own terms: remove the password (a passkey exists ✔), then remove that passkey (nothing is checked ✘). The credential set is now empty, `Configured()` is false, `GET /api/auth/status` answers `needs_setup`, and `POST /api/auth/setup` is pre-auth by exact path. Whoever reaches the address next completes first run and owns the backups.

The Operator found it by doing it (quince#888), on a staging stand, minutes after the rung was called code-complete.

## The part worth keeping is where the defect lived

`qn.6m`'s D3 exists because the *same* takeover was caught during specification, before any code — `configured = a password OR a passkey`, written specifically so a passwordless install would not offer first run to a stranger. That guard is correct and does its job. Nobody asked what happens when the user **empties** the set, at which point the install is genuinely unclaimed and the pre-auth route opens exactly as designed.

So the bug is not in either function. It is in the pair, and the tell is the asymmetry: one of them asks *will anything be left?* and the other asks nothing. A reviewer reading either file finds nothing wrong, because nothing in either file is wrong.

The test written for it is a **sequence**, not two unit cases, for that reason.

## The phrasing turned out to carry more than the check

The architect's read (quince#888) raised a question the issue had not: `DELETE /api/auth/passkeys/{id}` returns 204 whether or not a row went — deliberately, so a retry or a second tab does not look like a failure — and a refusal now lands on the same handler. Do *already gone* and *this is the last one* stay distinguishable?

They do, and no special case implements it. Phrasing the guard as a claim about the **resulting state** rather than about the row being deleted makes an unknown id leave the state unchanged, therefore not the last credential, therefore still a 204. The two rules never meet.

The same phrasing does a second thing. It makes the guard **strictly stronger** than *the set must not empty*: a passkey bound to another address leaves the set non-empty — takeover shut — and still locks you out here. A mirror written against `Configured()`'s unfiltered rule would have passed every other test in the file and let that through.

**One sentence, chosen for one reason, answering a question asked for another.** That is not luck so much as what happens when a guard is stated as a property rather than as a procedure — but it is worth writing down, because the procedural version was the obvious one to write.

## And the refusal had nowhere to land

The passkey list rendered `remove.error` nowhere. It never needed to: until today this mutation could not fail in a way a user was meant to act on. Adding a 409 without noticing would have made the Remove button **silently do nothing** — row stays, no message, user retries forever. Invisible to every server-side test, and the exact silent-fallback shape the hard rules forbid.

## A second finding, from the other end of the same day

The Operator also spotted, from a screenshot, that `PasswordControls.tsx` carried its credential anchor as `className="hidden" aria-hidden="true"` — which is `display:none` plus removal from the accessibility tree, the one variant quince#819 explicitly ruled against. The other two password surfaces carry the ruled shape. One of three had drifted, and each had its own test suite that could not see it.

**It landed on the surface where it costs most, and on the measurement that was about to be taken.** quince#819's follow-up names the change flows as still owed a device — does Safari *update* the saved entry or make a second one? That measurement was about to be taken against the most-likely-to-be-ignored variant, so a duplicate would have read as *the anchor does not work* rather than *this one was hidden*.

The guard for it (quince#893) is cross-feature on purpose, and fires `submit` rather than `click` — the assertion a `<div>` with an `onClick` cannot pass, which is the tidy-up that would silently kill the browser's save prompt while every existing test stayed green.

**And `toBeVisible()` cannot express any of this.** jsdom loads no Tailwind stylesheet, so `className="hidden"` computes to nothing and the obvious assertion passes happily on the exact markup it was written to reject. The accessibility tree is what jsdom can actually see, so the check is structural.

## Still open, and it is the interesting half

Item 3 of quince#888 — requiring a *present* authentication for credential mutation — is unruled, and the architect found the thing that makes it a ruling rather than an implementation: **the recovery path and the persistence attack are the same operation.** *Set a credential when the set is empty or unusable* is simultaneously the owner's only way back and a stolen session's route to durable access. After item 1 and item 3 both land, a state a user can reach by themselves becomes console-only.

Left standing rather than designed around.

PRs: quince#892 (item 1), quince#893 (the anchor). Issue: quince#888.
