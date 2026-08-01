# 2026-08-01 — A security word was doing a policy's work, and nobody had weighed the policy

**`DELETE FROM sessions_auth` on every login, under a comment saying it defeats session fixation. It
does not defeat session fixation. The line two below it does.**

```go
// Rotation: a fresh login supersedes any prior session (single admin) — defeats fixation.
if err := s.store.DeleteAllAuthSessions(); err != nil { … }
sess := store.AuthSession{ ID: id.Token(32), … }   // ← this is the fixation defence
```

Fixation is defeated by issuing a **new** session id, so an id an attacker planted beforehand is not
the id the victim ends up holding. Deleting *other* sessions adds nothing to that. It is a separate
policy — **one concurrent session at a time** — and it was wearing fixation's justification, which is
why nobody had ever weighed it against what it costs.

What it cost was in the Operator's own words, from real use: *"whenever I do anything on one device it
logs me out on another."* Using the iPad signed the desktop out. Meanwhile `ui.design.md` line 61 says
*"the iPhone itself is a first-class client"* — and a second first-class client that evicts the first
is not one.

---

## The gap was in canon, one word wide

`docs/quince.design.md` §6 said, in full:

> session rotation on login

**Which rotation?** Rotate *the authenticating client's own* session id — the fixation defence — or
rotate *the table*, which is the eviction policy? Both readings fit those four words. The code took
the second and quoted the first as its reason, and nothing in between could tell.

That is why this was an Operator decision and not a patch. Ruled: **option 2 — a login supersedes the
caller's own prior session and leaves every other device alone.** The canon line now says which, and
says that it used to be ambiguous, rather than quietly reading as though it had always been clear.

---

## Removing the primitive, not just the call

`DeleteAllAuthSessions` had exactly one caller. With that gone it would have sat in `store` as an
unused method that *reads like the rotation helper* — one `grep` away from restoring the behaviour
just ruled against. It is deleted, with a comment where it was saying what it did, why it went, and
that a deliberate *"sign out other devices"* control would re-add it **with its own caller and its own
UI**, which is the entire point: the eviction becomes something a user chooses instead of a side
effect of logging in.

---

## The tests had to separate two things that used to move together

The old suite could not express the fix, because under the old policy the two policies were the same
event. Now:

- `TestSetPasswordThenLoginRotates` — the same client logs in again, presenting the session it holds;
  that one dies. **The fixation rotation.**
- `TestASecondDeviceDoesNotEvictTheFirst` — a second client arrives with no cookie of its own; the
  first stays authenticated. **The policy.**

The discriminator is the last argument, and it is called out in a comment so nobody "simplifies" the
two together later. Reverting the source under both: the second fails with literally the Operator's
symptom, and **the first passes under old and new alike** — which is the claim in one line. The
fixation defence is untouched; only the eviction changed. A suite where both moved together could not
have told you that.

---

## What I actually got wrong, and it was not the code

I wrote `deploy: not applicable — no runnable change` on a change to the **login path**, four lines
under my own admission that *"I have not clicked two real browsers"*.

**A deploy is what supplies two browsers.** So the sentence declared out of scope the one check that
would close the report the whole PR exists to answer. `CLAUDE.md` §7 allows exactly two sentences and
says why the second exists — *"so the first cannot quietly cover for it"* — and I had written the
admission and the evasion into the same document.

The reviewer blocked on it and was right to. Running it took minutes: two cookie jars are two clients
as far as the daemon is concerned.

```
desktop AFTER the phone logged in              authenticated
desktop AFTER phone logged in AGAIN            authenticated
```

The **second** login is the one worth having — a per-*login* rule would have evicted the desktop on
either, so surviving both is what separates per-client from "evicts sometimes".

**A "what I did not prove" section is not a licence to leave it unproven.** It is honest about a gap;
it does not make the gap acceptable when closing it is fifteen minutes of work. The two statements
together were the substitution the rule was written against, and I made it in the same breath as
admitting the gap.

---

## And the mechanism that made the merge slow was a good one working

This PR needed **two** approvals: the architect's, and the Operator's as code owner, because
`docs/quince.design.md` is owned by `@novkostya` and **an App cannot be a code owner.** Watching it
happen is the first time that has been measured rather than reasoned about:

| approval | association | `reviewDecision` after |
| --- | --- | --- |
| `quince-review[bot]` | `CONTRIBUTOR` | `REVIEW_REQUIRED` — unchanged |
| `novkostya` | `OWNER` | `APPROVED` → `CLEAN` |

Two approving reviews on one pull request and only one of them moved protection. That asymmetry is
the reason `CODEOWNERS` names a human account rather than the App that casts every ordinary verdict,
and it only became expressible when verdicts moved to the App at all.
