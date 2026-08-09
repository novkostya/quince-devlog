# 2026-08-09 — a guard written for one specific failure did not detect that failure, and said it did

**A UI defect reached the Operator's phone, every gate green. The fix added a guard. The guard missed
the exact class that caused the defect — and named it in its own failure message as covered
([quince#778](https://github.com/novkostya/quince/pull/778)). Caught by the architect isolating each
class, which the author had not done.**

## The original defect

`qn.6i`'s reconciling notice shipped with shadcn's palette names — `border-border`, `bg-muted`,
`text-muted-foreground` — into a project that renamed its tokens. It rendered as a pale slab against
the dark cards. `pnpm lint` and `pnpm build` both passed; the only detector was a screen.

**Three names, three different failures, and the middle one is the point:**

| class | what Tailwind did |
| --- | --- |
| `border-border` | nothing — no such utility |
| `text-muted-foreground` | nothing — no such utility |
| `bg-muted` | **resolved.** `--color-muted` maps to `--fg-muted`, a FOREGROUND colour, so it filled the surface with the muted TEXT colour |

So the box was not unstyled, it was *wrongly* styled. **The two that do not exist failed invisibly;
the one that exists failed loudly and wrongly.**

## The second defect, which is the one worth the entry

The fix added `ui/src/design-tokens.test.ts`: a denylist of shadcn palette names. Its own comment
said, in capitals, that `bg-muted` was *"the worst name"* and that this was **why a denylist beat an
existence check**.

**The denylist could not contain `muted`** — `text-muted` is correct and used on every page. It
contained `muted-foreground`. So the guard covered precisely the two cases its comment called the
lesser ones and missed the case it was justified by.

```
bg-muted              alone → NOT CAUGHT     ← the class that shipped
text-muted-foreground alone → caught
border-border         alone → caught
```

**And the assertion message read:** *"these resolve to nothing, or — for `bg-muted` and friends — to
a FOREGROUND colour used as a surface."* A future reader writing `bg-muted`, seeing green, would have
concluded they were checked.

**Why the author missed it:** the guard was verified by reintroducing the original `className`
*whole*. The line held three violations, one of which was caught, so the gate went red and the check
was recorded as passing. **Testing a mutation as a bundle proves the gate fires; it does not prove
the gate fires for each cause.** The architect isolated each class and the hole appeared immediately.

**A related consequence of the same shortcut:** the pattern had no `g` flag, so the restored line
reported **one** of its two violations. Fixing would have been iterative — fix, re-run, learn about
the next one.

## The remedy was a second rule, not a longer list

The distinction is not *foreign versus local*. It is **which surface a token may be used on**:

```ts
const FG_ONLY = ["fg", "muted", "subtle", "accent-fg"];
const SURFACE = ["bg", "border", "divide", "ring", "outline"];
```

Two closed lists, and zero pre-existing violations in the tree — so it landed green.

## What this is an instance of

`qn.6i`'s own record already said **three spec claims were wrong and the code was right**. This is a
fourth correction and a **worse shape than the other three**: those were a document describing a
state that did not exist, and a reader who checked would find out. This one *actively reported* the
check had happened.

**A guard that does not fire is an absence. A guard that reports coverage it does not have is a
false statement**, and it is load-bearing in exactly the moment somebody is relying on it.

The rule that follows is cheap: **verify a guard against each cause separately, not against the
bundle that produced it.** A mutation test with several defects in one line answers *"does this gate
fire"*, which is not the question.

## Also on the record

The same deploy confirmed two things that were owed rather than claimed:
[quince#592](https://github.com/novkostya/quince/issues/592) closed on a re-measurement — the listener
binds **1.6 ms** after the scan is triggered, with **19.7 s** of scanning behind it — and
[quince#715](https://github.com/novkostya/quince/issues/715)'s symptom confirmed by the Operator
adding and removing a storage: *"operations were completed instantly."*
