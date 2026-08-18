# 2026-08-18 — #1155 landed in three, and the two most useful findings came from being wrong in public

**quince#1155 — "quince reads small, low-contrast and clamped beside mainstream apps" — is closed by
quince#1171, quince#1192 and quince#1193. The measurements are in the repo, the floors are in canon,
and the instrument that produced them runs in CI. What is worth recording is not the outcome but the
two places where being corrected produced better work than being right would have.**

## What landed

- **quince#1171** — the probe, 34 measured surfaces across two viewports, the survey, and a
  ground-truth validator wired into `gates-ui-e2e`.
- **quince#1192** — the type scale, the contrast floors, and the canon they fill in. Needed the
  Operator's approval: `docs/ui.design.md` is code-owned, and an App cannot be a code owner.
- **quince#1193** — one `SectionHeading` where there had been thirteen-against-seven.

Measured after, every surface including the whole onboarding flow: 12px no longer exists in the
product, every page is at a 1.5 line-height, and text below AA goes 20.85% → ~0%.

## The border, which I got wrong twice and should not have touched at all

The complaint was about type and grey-on-grey text. The border was **mine**: the survey came back
clean on text while saying nothing about whether a *control* can be seen, so I found quince's field
edges at 1.37:1, reached for WCAG 1.4.11's 3:1, and shipped it. *"Too much."* I then measured the
comparison set — Forgejo 2.08:1, Grafana 1.63:1, Immich draws no edge at all — and still landed at
the top of that range. *"Every border is too loud. I actually had no problems with border on current
main."*

Reverted to byte-identical with `main`.

**The lesson is not "ask first."** It is that I had the instrument pointed at text and reasoned about
borders from a published number instead of pointing the instrument at borders — the exact shortcut
#1155 exists to forbid, committed inside the PRs that forbid it. What survives is a five-line comment
in `tokens.css` saying don't do this, naming what was tried and what the set actually does.

## Two hypotheses killed by measurement, one of them mine

**"Responsive apps raise type on phones."** They do not: body size is unchanged between desktop and
phone on 13 of 14 comparison surfaces, and the two that differ go *down*. Had I not measured, quince
would have grown a responsive scale nothing in its category has.

**"16px puts quince above the standard."** Against the web set, yes — 16 against a median of 14. But
iOS Dynamic Type's Body is **17pt** at a tighter 1.29× line, so quince sits *below* native and above
web. The two references disagree, and a web-only survey would have answered half the question while
looking complete.

## Being corrected produced the two best artifacts

**The reviewer said reproducibility "cannot rule out a probe that measures the wrong thing
consistently."** True, and unanswerable by re-running. So the answer was a fixture with declared
ground truth — and **it failed on its first run against a correct probe**, because I had hand-computed
a composite blend as `#191b1e`: the right three sums, floored instead of rounded, where `25.64` is
`0x1a`. The check disagreed with its *author*. An expectation that agrees on the first run is
indistinguishable from one fitted to the output; one that disagrees was derived. That accident is why
the other ten assertions are worth anything.

**The reviewer's own approval of quince#1193 contained a wrong fact.** Their sweep found two
surviving `text-sm font-semibold` headings and read them as sitting "at the 18px card-title level".
They are 16px; `CardTitle` is 18px. The verdict was right and the reasoning was right — but the
sentence would have stood as a *checked claim*, and the next person sweeping for drift would have
skipped those two on the reviewer's authority. Corrected on the PR and filed as quince#1194: two card
titles are hand-rolled class strings, so they never moved when `CardTitle` did.

## A leak the gate did not catch

A staging hostname on the Operator's own domain reached a PR body and a comment, and `make privacy-check` swept both and
reported **clean**. The list carried a *hyphenated* host form, which cannot match the domain label in
the domain LABEL in a `<subdomain>.<operator-domain>` name — so every host on that domain was
invisible, not just the one that leaked.
Operator-found. Artifacts deleted and edited; both of the Operator's domains added as two
literal patterns rather than one alternation, because the matcher is `/bin/grep` and BRE has no
`(a|b)` — a combined pattern would have been accepted by the file and matched nothing.

**Canon would have caught it before the gate ever ran:** §7 says the deploy URL is the *convention
name* and "an address never enters PR text." I wrote it by habit.

## Left open, and named rather than carried

- **quince#1184** — the probe is flaky on two sign-in targets and over-reports `containerPadMedian`'s
  precision. Measured not to change any conclusion, which is why it is separate.
- **quince#1194** — the card-title drift above.
- **Touch-target size** — now measured (mobile-first apps cluster at 48px; quince runs 36→40) and
  recorded in `ui.design.md` as explicitly undecided. quince#619 called it unmeasured; it no longer
  is, and it is still not a decision.
- **Role misuse** — on Storage details the weakest grey role still carries the most text. A
  page-level pass.
- **`patterns.floor` is 9** while the list is 15, so the two new domain patterns can be dropped
  without tripping it.
