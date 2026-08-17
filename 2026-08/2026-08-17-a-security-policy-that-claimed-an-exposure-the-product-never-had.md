# 2026-08-17 — a security policy that claimed an exposure the product never had

**quince had no `SECURITY.md`, so a reporter's only visible channel was a public issue — which for
an unfixed finding is the exploit's own announcement. The policy landed; its first draft asserted
that the backup password may travel in `BACKUP_PASSWORD`, and accepted the same-uid exposure that
follows. quince has never done this. The line was transcribed faithfully from `docs/quince.design.md`
§6, which is the only document in the repository that says it.**

quince#1144, merged `2026-08-17T18:07:11Z` by `app/quince-review`. The canon divergence underneath
is quince#1146, open.

## The reporting route was measured before it was documented

```
GET /repos/novkostya/quince/private-vulnerability-reporting  →  {"enabled": false}
```

**Off.** So the obvious sentence — *report through GitHub's private advisory form* — would have
named a route that does not exist, which is this project's most-filed defect wearing a security
policy. The Operator enabled it mid-work and the file now points at something real; the check was
re-run with the implementer's own credential rather than taken from a paste.

Worth keeping: the **web** URL `.../security/advisories/new` returns `302` to an unauthenticated
`curl`, which is a login redirect and is evidence of nothing. The API endpoint is the one that
answers the question.

## The finding

The *already known, and accepted rather than overlooked* section — seven documented decisions, each
cited to design §6 so a reporter can argue with the reasoning instead of rediscovering it — carried
this:

> The backup password reaches `idevicebackup2` over a pty, **or via `BACKUP_PASSWORD` in the
> environment of a short-lived child.** Same-uid exposure is accepted.

`BACKUP_PASSWORD` appears in **zero Go files**. `core/internal/deviceops/pty.go:12` says the
password never reaches the tool *"via argv … **or an env var**"*, unprompted, and calls itself the
load-bearing secret path. `CLAUDE.md`'s hard rule says *"never argv, env, or logs."*

**The tell was that the truth is the stronger posture.** Nobody overstates their own attack surface
on purpose, so a policy that does is a transcription error rather than a judgement — which is how
the reviewer classified it without needing to ask.

## Where it came from, and the part the review got one file too wide

The review named design §6 and `docs/contracts.md`. **`contracts.md` is correct, and it holds the
precise formulation:**

| Location | Says | |
| --- | --- | --- |
| `docs/contracts.md:1116` | *"the `BACKUP_PASSWORD` env fallback exists **in the CLI** but **quince does not use it**"* | correct |
| `docs/specs/qn.3/qn.3.md:379` | *"the env fallback is unused"* | correct |
| `qn.4a`, `qn.4b`, `qn.4c` | *"`BACKUP_PASSWORD` env count **0**"* | correct — hardware measurements of the negative |
| `docs/quince.design.md:87`, `:696` | pty **or** env, exposure accepted | **wrong** |

So the divergence is **two lines in one file**, and everything downstream of the implementation
already says the true thing. That is exactly why it survived: §6 compressed *"the CLI offers pty or
env; we take pty"* into *"the password reaches the subprocess by pty or env"*, dropping the clause
that carried the decision. Every document written **after** the code measured reality; §6 kept the
**pre-decision** shape and nothing pointed back at it.

## The defect class, which is not the one the guard was written for

`bin/gate-scope-test`'s registration comment for `SECURITY.md` — written in the same PR, before any
of this — named the hazard:

> Gate `X-Forwarded-Proto` unconditionally, or **move the backup password off the pty**, and the
> file still asserts the old shape with every gate green.

**It was right about the mechanism and wrong about the direction, and the instance arrived inside
the PR that wrote it.** That paragraph imagines code drifting *away* from a documented shape. What
happened is that the code **declined to build** a documented shape, and the new document copied the
documentation. A doc can be born wrong rather than go stale, and every gate is green for that too.
The comment now says so.

## Two decisions worth citing later

**No response times.** One maintainer, no on-call, pre-release. A deadline nobody is rostered to
meet is worse than none, so the file states the shape instead — and says that an unanswered report
was missed rather than declined, because the other reading is the one that makes people stop
reporting.

**No email address.** Permanent in public history and a personal contact detail; not an
implementer's call. The advisory form is the whole route.

## And the routing hole in `CLAUDE.md`

Its issue list said product bugs go to public issues *"sanitized at filing"* and nothing else —
which reads as covering **a security finding a session makes about quince itself**. Sanitizing
strips the Operator's data from an issue and does nothing about a finding whose *body is the
exploit*. The new bullet routes those to a draft advisory, and its load-bearing clause is that it
binds a **session's** finding, not only an outside reporter's.

## The seat mechanics, which worked

The architect reviewed twice and cast neither the blocking verdict's resolution nor the merge
authority it did not have: `CLAUDE.md` is code-owned by `@novkostya`, an App cannot be a code owner,
and `enforce_admins: true` closes the bypass — so `BLOCKED` after an architect approval is correct
rather than a fault. The Operator approved as code owner at `17:53:51Z`; the App merged at
`18:07:11Z`.

**The author declined one convenience on purpose.** The branch sat `BEHIND` after three PRs merged
during review, and quince#216 measured that `update-branch --rebase` does not dismiss an approval —
one measurement, against a **code-owner** approval that only the Operator can re-cast. Left to the
merging seat, which is where §5 puts it.
