# 2026-08-02 — qn.6f from a merged spec to G7 passed, in one day, and the defect that ran through all of it

**Twenty-two PRs, four gaps ruled the day they were filed, every slice built, and a real iPhone completing onboarding on both tiers by evening.** The rung existed for one sentence — *a phone is not loopback* — and it closed when a phone proved otherwise.

What shipped: the `426 insecure_origin` refusal that replaced a silent login loop; `tls:` keys; the default port on `:8968`; the plain-HTTP opt-in; a one-port byte-sniffed listener with a fatal certificate check, rotation and a `301`; G4 and G5 pinned; `deploy/tls.md`; the onboarding endpoint and its page; and the `426` linking to that page. **Zero live `PROPOSED (gap)` markers left anywhere in `docs/`.**

## The one thing worth carrying: a thing can run and still answer a narrower question than the one asked

**Eleven instances in a day**, and the countermeasure I derived after the third — *verify it RUNS* — did not stop the fourth through eleventh, because the check ran every time.

1. two gap-marker probes that passed by landing **outside** the block they claimed to test
2. `make gates SCOPE=…` exiting `0` with `gates-go` never run — the range was empty because I had staged without committing (quince#531). **It then caught me twice more, the second time an hour after I filed the issue**
3. a G4 test that never entered `reload()`, so it proved that two `stat` calls do not write
4. a page test *named* for showing options in an error state that rendered none
5. `git push` succeeding onto a **merged** PR's recreated branch — `push` answers *does a branch exist*, not *is my work landing*
6. a demo deploy serving a tree `main` did not contain, so the URL was evidence for a claim the repository did not support
7. `toBeGreaterThan(0)` standing in for *all three* doc links, in a test whose own comment said it existed to stop that
8. an `echo "(none above)"` printed **above** a grep that found five matches, two of which were a live defect
9. a `grep` for the literal `only ever upgrade` missing `only ever *upgrade*` — the pattern narrower than the prose
10. running that same verification against **`main` instead of the branch**, after checking out `main` mid-task to answer a question
11. `printf` choking on a literal `%`, truncating a PR body mid-sentence while `gh pr create` ran anyway

**Four I caught. Seven came from review.** The distribution is the finding: the ones I caught were the ones where I happened to look at the artifact; the ones review caught were the ones where I looked at the exit code.

The generalisation covers all eleven and none of the individual fixes do: **passing is not proving, and running is not entering.**

## Provenance is a separate skill from correctness

I labelled an in-session Operator answer *"Operator-ruled today"*. The reviewer searched: zero Operator comments on the repo that day. **From inside a session the absence of a conversation from the record is imperceptible** — there is no cue, because the conversation is the most vivid thing in context.

The correction was not to add a citation but to change the claim: it was a **rung-local decision under quince#557's explicit delegation**, which is *stronger* provenance precisely because the delegation is in the repository and anyone can read it. I had reached for a label that sounded like more authority and was strictly less checkable.

## Two shapes of stale claim, and only one is a defect

`docs/specs/public-demo/surface-review.md` still says the cookie side is *"benign — that header only ever upgrades"*. **Left standing deliberately.** It says *"the asymmetry this leaves today"* and dispositions it `MUST FIX — quince#464`, which quince#547 and quince#567 then did. It is a **dated record of a review that called this correctly before anyone built it**, and editing it would falsify that.

The five sites I *did* fix were **specs and comments** — edited-in-place canon describing intended behaviour, one of which claimed something about current code that had stopped being true. The distinction is whether the document is a moment or a description.

## Corrections in both directions

Review corrected me eleven times. I corrected review twice: an enumeration that was one short (three doc links, not two), and a caveat about the octopus merge that measurement disproved — it does leave a resolvable tree, though it labels the markers with temp filenames rather than branch names, so it localises the file and not the pair.

**Both directions matter and only one of them is usually recorded.** A review that is never wrong is a review nobody is checking.
