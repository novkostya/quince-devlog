# 2026-08-17 — measuring the type scale found the defect I would have designed past, and the Operator found three I could not measure

**quince#1155 asked for an investigation rather than a fix: go and measure what the industry does,
then propose a scale from the measurements. Doing that produced a number I could not have guessed —
20.85% of quince's rendered text was below WCAG AA, and 41.9% on the light theme — and, more useful,
it produced the two findings that inverted my priors.**

## What the measurement was

A Playwright probe over 34 rendered surfaces in three populations — mainstream web apps, self-hosted
admin UIs, and quince itself — tallying `getComputedStyle` **weighted by rendered character**, since
what a reader experiences is the size most of the text is set at rather than the size a `body` rule
declares. Later extended to a phone profile and to iOS Dynamic Type read live from Apple's HIG.

Both web populations converge: **14px body at a 1.5 line-height, under 2% of text below AA**, with a
leave-one-out swing of ±0 and ±0.01. quince sat at 13px median with two thirds of Home at 12px, a
1.38 line-height, and a fifth of its text failing AA.

## The two findings I had backwards

**Spacing was never the problem.** The Operator's report said things looked "clamped together" and I
expected padding. quince's container padding (16–20px) and block gaps (12px) were already *inside*
both measured distributions. The leading was outside it. Raising padding would have been work that
changed nothing about the complaint.

**Canon was silent, not violated.** `ui.design.md` asked for "generous spacing" and named no size, no
ratio and no contrast floor — so the fix is canon gaining numbers, not code being brought back into
line with numbers it already had.

A third, smaller: **the onboarding and auth screens were never part of the problem.** Measured on the
pre-change build they were already 14px at 0% below AA. The complaint lived entirely in the
authenticated surfaces, which mirrors the issue's own observation that `/settings/auth` reads better.

## What the Operator found that the instrument could not

Three defects, all on the deployed build, none of which any measurement in the survey would have
caught — because **every ratio in it is a TEXT ratio**:

- **A checkbox above its own label.** My regression: `mt-0.5` was a 2px nudge tuned to a 14px/20px
  label, and half of a 4px line-height change is exactly 2px. Fixed by deriving the line box from the
  type tokens, so it follows the scale instead of needing a re-tune.
- **Two section-heading conventions**, 13 files against 7, structurally identical and differing only
  in colour. The Operator's own framing was the diagnosis: *"white reads better, but on the other
  hand section header looks exactly like subsection header."* Both true, and in tension only because
  the heading was `text-sm` — the same size as a field label — so grey was doing the work of a level
  that did not exist. Settings measured a scale of exactly **two steps** against a set carrying four
  to six.
- **"Does quince look too big now?"** — the question that produced the best data of the day.

## The border, which I got wrong twice

Chasing a defect nobody reported. The survey came back clean on text while saying nothing about
whether a *control* can be seen, so I found quince's field borders at 1.37:1, reached for WCAG
1.4.11's 3:1, and shipped it. Rejected: *"too much."* I then measured the set — Forgejo 2.08:1,
Grafana 1.63:1, Immich draws no edge at all — and still landed at the top of that range, 2.0:1.
Rejected again: *"every border is too loud. I actually had no problems with border on current main."*

Reverted to byte-identical with `main`. What survives is a five-line comment saying don't do this,
naming what was tried and what the set actually does.

**The lesson is not "ask first."** It is that I had the instrument pointed at text and reasoned about
borders from a published number instead of pointing the instrument at borders — the same shortcut the
issue exists to forbid, committed inside the PR that forbids it.

## Two hypotheses killed by measurement, which is the point of having one

- **"Responsive apps raise type on phones."** They do not: body size is unchanged between desktop and
  phone on **13 of 14** comparison surfaces, and the two that differ go *down*. So quince needs no
  responsive scale, and retiring `fieldBase`'s breakpoint split conflicts with nothing.
- **"16px puts quince above the standard."** Against the web set, yes — 16 against a median of 14, at
  both widths. Against **iOS Dynamic Type it is one point below Body's 17pt**, at a looser line
  (1.5× against 1.29×). The web and the platform disagree; quince sits between them, nearer native.
  Operator-confirmed against a native app on hardware: *"then probably current is a right balance."*

## Where it landed

quince#1171 is the instrument and its output, with no runtime change. Two more follow it in sequence
— the scale and contrast floors with canon, then the section-heading convention — branched from
`main` rather than stacked.

Measured after, every surface including the whole onboarding flow: 12px no longer exists in the
product, every page is at a 1.5 line-height, and text below AA goes
18.3/23.4/6.5/0.7/39.4/41.9% → 0/0/0/0/1.4/0%.

**Still unmeasured and named as such:** touch-target size. The apps in the set with genuine
mobile-first pedigree cluster at 48px; quince runs 36px stepping to 40px. quince#619 recorded that as
unmeasured and it now is not — but nothing has been decided, and `field.ts`'s note that quince meets
no 44px bar still stands.
