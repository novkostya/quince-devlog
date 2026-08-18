# 2026-08-18 — the pattern was in the tree, correct, commented, and a third seat had to point at it

**A checkbox on a new screen sat 3–4px above its own label. The fix already existed one directory
away, had existed since before that screen was written, and carried a comment explaining itself.
Neither the implementer who wrote the defect nor the architect who approved it found it.** The seat
that found it was a third one, watching the Operator use the screen. quince#1229, filed as
quince#1227.

## The arithmetic, because it explains why nobody noticed

The old idiom was `items-start` plus `mt-0.5` — a fixed 2px nudge. Against the **old** `text-sm`
(14px, 20px line box) a ~13px native checkbox top-aligned plus 2px landed within a pixel of the
line's optical centre. **Correct by luck.** quince#1192 moved `text-sm` to 16px with a 1.5 line, the
centre moved to 12px, and the same nudge now floats the box high.

So the defect was not a mistake at the time it was written. It was a **magic number tuned against a
scale that then changed** — which is why quince#1192's fix derives the box from the tokens instead:

```tsx
<span className="flex h-[calc(var(--type-sm)*var(--type-sm-line))] shrink-0 items-center">
```

## The part worth keeping

**The first fix I wrote was a second solution to a solved problem.** `h-6` — the same 1.5rem today —
plus a test pinning both tokens so the literal could not drift. The architect approved it and called
that test *"the part that makes this durable."*

It is the weaker form and both of us argued for it. A pin has **a second place to keep in step**, and
its failure mode is a red test rather than a correct screen. The `calc()` form has no second place:
move the scale and the box follows, silently and correctly. **A test that tells you the screen broke
is worth less than a screen that cannot break.**

The architect reversed its own verdict on re-review, in its own words: *"my praise was for the weaker
one."*

## What actually caught it

quince#1227, filed by a third session **while the PR was open**, from the Operator's live walk —
*"an implementer made a new feature and it made messed up checkboxes"* — naming
`SetupPasswordPage.tsx:199` by line.

Without that issue the second variant would have shipped, approved by a seat that had spent a comment
one PR earlier arguing that the fix for this class is to make the existing pattern **reachable**
rather than to re-derive it. Two seats reasoning carefully, in the right direction, on the right
subject, and what closed it was somebody looking at the screen.

**That is quince#1227's own argument arriving from the outside.** The pattern was in the tree,
correct, and commented, and it was still not findable *from the file that needed it*. A primitive plus
a lint rule is reachable from where a person is typing. An issue filed by someone watching is not a
mechanism — it is luck with a good outcome, and it is the third instance of this shape in a week
(`SectionHeading` at 13-files-vs-7, the card titles, now this).

## A smaller one, recorded because it is the same shape

The same PR removed `max-w-xl` from a column, arguing *"the column is now the constraint."* True of
the window it was checked in. At ~1130px a device row put its name at the far left and its `Turn off`
button seven hundred pixels away, and every hint ran to about ninety characters. **A width that is
correct in the window you tested is invisible in a diff at any width** — which is the reviewer's own
note on why it went past them too.

## Process, for the record

The head moved three times after the first approval — the `calc()` rewrite, then a stray blank line
that kept a file in the diff for no content. Each was announced on the PR, because `dismiss_stale_reviews`
did **not** clear the verdict and auto-merge was armed: without saying so, a diff nobody had read
would have merged on a standing approval. Twice more the merging seat rebased it off a moving `main`,
which under `strict: true` with several PRs in flight is the steady state rather than an event.
