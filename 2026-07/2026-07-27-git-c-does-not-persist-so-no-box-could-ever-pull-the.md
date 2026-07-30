# 2026-07-27 — `git -c` does not persist, so no box could ever pull the private layer — and the box that quietly worked was the one hiding it

**`git -c` does not persist, so no box could ever pull the private layer — and the box
that quietly worked was the one hiding it.**
`deploy/runner/provision` cloned with `git -c credential.helper=…`, which applies to that
invocation and is **never written to `.git/config`**. Every clone authenticated once and then
carried no helper: present, readable, and unable to advance.
[quince#124](https://github.com/novkostya/quince/pull/124) persists it with `git config` on every
path — including the already-cloned branch, which is what **repairs boxes in the field**.
**The issue was filed as arch-box-specific and was not.** The runner was equally unwired; it worked
only because a session hand-configured the helper in order to push and **did not register that it
was patching a bug rather than doing setup**. A hand-fix that works is indistinguishable from a
system that works, from inside the session that made it — and volunteering that turned a one-box
mystery into a one-line root cause. The issue was retitled rather than corrected in a comment,
because a comment eight deep does not reach a reader who meets it in a list.
**It was found because somebody refused to infer.** The implementer asked for a one-line
confirmation that the architect box reported `canary ok` and declined to assume it; the architect
went to get it, and the answer was *no, and unobtainable*. The same refusal recurred twice more:
a hollow *"arch confirmed"* was declined because the box was wired by hand rather than by the code
under test.
**That refusal is the one that paid, and it is the entry's strongest single fact.** Declining to
report the box as confirmed exposed *how* it was wired — URL-scoped, `credential.https://…​.helper`
— and the follow-up `preflight` check read the **unscoped** `credential.helper`, a different config
key that returns nothing there. **The check written to stop a frozen layer would have refused to
START a healthy box**, in the one gate that decides whether a machine boots. `--get-urlmatch` is the
resolution git itself performs for a remote, so it answers *will a fetch from this url find a
helper*; the narrow read encoded one of two correct wirings as the only correct one — the same class
as rejecting `ls-remote` for gating on a fact it cannot establish, arrived at from the other side.
**The confirmation was made meaningful by removing the hand-fix first** (`git config --unset
credential.helper`) so the run exercised the repair path rather than finding the work already done —
a control the acceptance criteria had not asked for.
Owed and named: the arch box holds an implementer-role service installed by a `provision` run that
defaulted its `--role` (**`QUINCE_RUNNER_ROLE` is not read as input** — the published step-2
sequence omitted the flag, and *a procedure carries the box it was written on* exactly as a
measurement does). [quince#125](https://github.com/novkostya/quince/pull/125) makes that refuse
**before touching anything**; the artifact itself needs removing by hand, and one
`provision --role arch` still gates both the `preflight` refusal and
[quince#108](https://github.com/novkostya/quince/issues/108)'s canary flip. **And
[quince#123](https://github.com/novkostya/quince/pull/123) is cited here as landed, not as closed:**
the identity table it added omits the identity whose approval satisfied protection on it
([quince#130](https://github.com/novkostya/quince/issues/130), open), with a review-timestamp
question on [quince#110](https://github.com/novkostya/quince/issues/110).
([quince#124](https://github.com/novkostya/quince/pull/124),
[quince#125](https://github.com/novkostya/quince/pull/125),
[quince#121](https://github.com/novkostya/quince/issues/121),
[quince#108](https://github.com/novkostya/quince/issues/108),
[quince#123](https://github.com/novkostya/quince/pull/123),
[quince#130](https://github.com/novkostya/quince/issues/130))
