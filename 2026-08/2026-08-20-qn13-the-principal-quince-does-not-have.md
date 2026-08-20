# 2026-08-20 — the qn.13 spec, and the discovery that quince has no principal to discard

**quince#1347 opens `qn.13` — a device-scoped passkey issued by QR — as a spec, per `CLAUDE.md` §8.
The scoping issue and the architect's ruling both located the rung's first slice at
`middleware.go`'s `authGuard`, which discards the value `Authenticate` returns. Reading the type
underneath moves it one layer down: `store.AuthSession` is `{ID, CreatedAt, LastSeenAt, ExpiresAt}`.
The discarded value carries no identity to begin with, so the first slice is a migration on
`sessions_auth`, not a fix to a line that throws something away.**

## The correction, and why it changes the shape of the work

quince#1342 §1 states it as *"nothing in the session or middleware layer distinguishes a caller's
rights"*, and the architect's ruling sharpened that to *"the authenticated principal is DISCARDED"*
at a named line. Both are true. Neither is the whole of it: there is no principal **in the session
row**, so nothing upstream of that line has an identity to hand over. `sessions_auth` (`0001_init.sql:10`)
records a session's lifetime and nothing about what created it.

The consequence is not rhetorical. *Stop discarding the principal* is a one-line change; *the session
must record what authenticated it* is a migration, a change to `Authenticate`'s return, and a
request-context binding — and it must land **before** anything can mint a scoped credential, or the
predicates in the next paragraph start counting a set they do not understand. The spec's slices 3 and
4 are ordered on exactly that, borrowing `0008_passkeys.sql`'s own reasoning for shipping
`quince auth reset` before any credential could be issued.

## Three Operator rulings, transcribed rather than cited

An issue is where a question is decided; git is where the decision survives — 196 of `quince-bot`'s
commits stayed readable when the account was suspended, and 0 of its issues did.

1. **The backup encryption password is the scoped holder's to change.** This *reverses* the issue
   body's own recommendation and contradicts the architect's capability rule, which yields the
   opposite answer from *may not affect the admin's ability to restore*. The generalisation is what
   makes it more than one row: **a control the platform trivially bypasses is not a control, it is
   an inconvenience** — Finder changes the backup password without asking quince anything.
   So the spec writes the rule **with its exception beside it**, because a rule that generates the
   wrong answer for a case already ruled will generate wrong answers for the next route somebody
   adds.
2. **A scoped passkey must not satisfy any admin-credential predicate.** A lockout, not a
   preference: zero admin passkeys plus one scoped passkey would let the admin password be removed,
   after which nobody can administer quince and only `quince auth reset` — which destroys every
   credential — gets back in. Three sites count credentials today and all three fail **permissively**
   on a new kind of row, so the spec carries it as a rung-wide invariant with a gate written for the
   fourth site nobody has added yet.
3. **`device_notification_prefs` is the ADMIN's preference** (Operator, mid-session). The owner
   column `0013`'s comment anticipates is therefore added with existing rows **backfilled
   admin-owned rather than global**. An admin who muted device X keeps their mute; the scoped holder
   of X still gets their notifications. Read as global instead, the admin's preference would be
   silently imported into a principal who never expressed it — and it fails in the direction where
   the feature looks broken with nothing on screen saying why.

## What reading the tree corrected in the issue

- **The `qn.12` per-device switch exists.** Issue §5 asked for it to be located first and reported a
  grep finding no `notifications_enabled` column. It is `device_notification_prefs`
  (`0013_device_notification_prefs.sql`), and its comment already instructs this rung — *"the row
  gains an owner column… DO NOT ADD THAT COLUMN NOW."* The item is closed by measurement, not by
  memory.
- **`roadmap.md` carries a 2026-08-17 Operator ruling the issue does not cite**: the enrolment
  credential is a passkey rather than a scoped token, and **restore is a dangerous scope**. Restore
  appears in no capability list in the issue; the architect's rule pre-answers it, and the spec says
  so rather than leaving a gap where a dangerous default would sit.
- **The enrolment ceremony has a structural sibling already in the tree.**
  `POST /api/auth/setup/passkey/*` is pre-auth and issues a session; the only difference is what
  authorizes it. Specifying against it beats inventing a second shape.

## The measurement this box cannot take

Whether two discoverable credentials sharing one `user_handle` on one rpId present as **one entry or
two** on iOS decides whether the no-account-picker property survives. It needs a real iPhone; no
session box has one, so it is declared unrun with the Operator named as owner.

The spec assumes the property survives **and marks the assumption as reasoning rather than
measurement**: a picker can only appear on a phone holding two credentials for one rpId at once, and
in the household case each phone holds one — the admin's phone has the admin credential, the scoped
holder's phone has theirs. That most likely reduces the fork from *two specs* to *one spec plus a
named UX consequence in a narrow case*, because the mechanism — scope on the credential row, resolved
from `credential_id` after assertion — never consults `user_handle` at all.

Whether that reasoning is good enough to build on is the Operator's call at review, which is why it
is written down as reasoning instead of quietly becoming the design.

---

## Annotation, added after review — an Operator ruling that is real and uncitable at once

*Appended rather than rewritten (`decisions/0006`). The entry above was written when quince#1347
opened; it merged at `7d2e4b22` after one `CHANGES_REQUESTED` round, and the finding is worth more
than the spec change it produced.*

**The architect blocked on D7's attribution and was right about the evidence.** The spec cited
*"`device_notification_prefs` is the ADMIN's preference — Operator, 2026-08-20"*, and no such ruling
is on the forge: not in either comment on quince#1342, and not in any Operator comment in the
repository. The proposed remedy was to cite quince#1270 — which carries the same reasoning — and
mark it architect-decided, quince#1270 being authored by `app/quince-review`.

**The remedy would have been a second misattribution, in the other direction.** The ruling *is* the
Operator's. It was given **in the implementer's session**, in these words — *"device notification
prefs is what admin sets up, scoped account should not be affected by this setting"* — and a
reviewing seat cannot see a session. Crediting the architect would have taken a real Operator ruling
and handed it to the seat that merely agreed with it earlier.

**So what was wrong was the provenance, not the attribution**, and that is the distinction worth
keeping. The spec now states the ruling as the Operator's *and* states that this sentence is the
whole of what backs it — in session, relayed, not findable on the forge — then cites quince#1270's
body as prior reasoning that agrees rather than as the source. A reader who searches and comes up
empty now learns why from the spec instead of concluding it was invented.

**The general shape, which canon does not currently have a route for.** *An issue is where a question
is decided; git is where the decision survives* assumes the decision passed through the forge. An
Operator ruling given in session passes through neither: it is genuine, it is binding, and it is
uncitable. The spec is then the only artifact, so it has to **carry its own provenance** rather than
borrow a citation that looks stronger than what it has. Filed as process friction on the devlog.

**A second thing the round cost, and it is the cheaper half that gets remembered.** The architect
confirmed all four proposed items, which flipped a `PROPOSED` heading to `RULED` — quince#408's rule.
The heading was one line. **Six references would have gone stale with it**: an inline marker in D3
and its cross-reference, a `Rule check` row citing *"proposal 2"*, and three `gated?` cells in the
slice table. All moved in the same commit. A `RULED` section above a slice table still saying *gated
on proposal 1* is quince#409's defect one indirection out — the heading fixed and the status table
stale in four of five rows.
