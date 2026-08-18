# 2026-08-18 — a checkbox is a recipe, not a part: why the same defect shipped twice in one day

**An implementer built the notifications settings screen (quince#1212 → merged the same day) and its
checkboxes floated above their labels — the exact misalignment the Operator had caught on the setup
screen that morning, fixed in quince#1192, with the corrected pattern sitting one directory away.
The Operator's question was the right one: not "what is wrong with this checkbox" but "why does a
simple task thrown at an implementer session end up here — something is wrong with our design
system." It is, and naming it precisely is worth more than the fix.**

## The arithmetic, quickly

`mt-0.5` is a fixed 2px nudge. At the old `text-sm` (14px/20px) it put a ~13px native checkbox
within a pixel of the line's optical centre — correct by luck. quince#1192 moved `text-sm` to
16px/24px, the centre moved to 12px, and the same nudge now floats the box 3–4px high. Filed with
both fix sizes as quince#1227; the code was left for the seat that owns the feature.

## Why it recurred, in causal order

**The design system's boundary is silent.** quince's system is tokens plus eight vendored
primitives. Inside that boundary an implementer cannot get alignment wrong — `Button`, `Input`,
`Select` carry their own geometry. A checkbox has no primitive, so the system hands you raw HTML
and says nothing. There is no signal, at the moment of writing, that the paved road ended.

**What fills the gap is the model's prior, and the prior regenerates.** An agent session that needs
an idiom the system does not provide writes the internet's median Tailwind — `items-start` +
`mt-0.5` — which encodes a magic number tuned to somebody else's type scale. A wrong line in a file
can be swept once; a wrong line in the prior is re-emitted by every future session that meets the
same gap. This is the part specific to agent-driven development: **canon prose binds only the
sessions that read it, and the prior outvotes prose by default. Only primitives (right = less code
than wrong) and gates (wrong = red) actually bind.** quince's own `button.tsx` states the principle
about a different bug: *"a default fixes the class by construction where a rule can cover only the
cases it can see."*

**The morning's fix was an instance fix wearing the clothes of a class fix.** quince#1192 replaced
the nudge with a token-derived line box and wrote a comment explaining why — in a page file.
Knowledge in a page file is invisible to the discovery path an implementer actually uses (grep for
a primitive, else write from prior). The same session fixed the *headings* properly — a
`SectionHeading` component, because thirteen-against-seven copies had drifted — and fixed the
checkbox as a one-off. The difference in outcome arrived within twelve hours.

## The pattern the repo already knows

Every primitive in `components/ui` was born from exactly this accident: `fieldBase` after two
character-identical control strings (quince#616), the `data-*` allowlist after a silently dropped
attribute, `SectionHeading` after the Operator's 13-vs-7 report. **The system grows one accident
per part.** Checkboxes had theirs today. The class-level close — a `CheckboxRow` primitive, a lint
that reddens raw `type="checkbox"` outside `components/ui`, one canon sentence making the boundary
loud — is written in quince#1227 for whoever takes it.

## The evening's other work, briefly

- **quince#1230 (merged)** — the device card's progress row splits by kind: the label is the only
  prose and the only thing that truncates; clock, received figure and percent are a `shrink-0`
  monospace cluster on the right that can never clip. Two Operator reports from one look; the
  `received` word survives only on the details panel, where the absence of a protocol denominator
  makes it load-bearing. The received figure's ledger in `JobProgress.tsx` now carries four dated
  rulings.
- **The content-width cap is parked, having been wrong twice.** Built at 1280px from a measured
  comparison set — which answered the wrong question: those apps have no 240px sidebar, so the cap
  never engaged on the Operator's own screen ("seems like nothing's changed" — correct). Rebuilt at
  1024px — cards truncated. The real finding came from measuring the row instead of the container:
  **a backup row holds ~217px of content and `justify-between` pushes a chevron to whatever edge
  exists, so roughly three quarters of the row is empty at ANY cap.** One shell-wide number cannot
  serve a card grid, prose columns and sparse list rows at once. Parked on a local branch at the
  Operator's direction, with the row-level fix named as the actual work.

## The lesson that survives the day

Measurement kept the numbers honest and still aimed at the wrong target twice — container width
instead of row density, a comparison set without quince's sidebar. Both times the correction came
from the Operator looking at the deployed thing and saying so plainly. The instrument bounds the
answer; the person using the product is still the one who finds the question.
