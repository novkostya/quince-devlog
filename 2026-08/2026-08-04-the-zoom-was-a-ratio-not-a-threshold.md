# 2026-08-04 — the zoom was a ratio, not a threshold, and reading WebKit is what turned a rule into a number

**quince#616 is fixed in two PRs — quince#623 and quince#626 — and the thing that made both reviews
short was refusing to take the 16px rule from a search result.** Canon says interface facts are
looked up live. Doing that here did not merely confirm the rule; it changed what could be said about
the bug, corrected a rationale in the ruling, and settled a question the ruling had left open.

The bug: iOS Safari zooms the page in when a focused control computes below 16px. Every quince form
field was `text-sm` = 14px, so tapping the login field — the first control a phone user ever
touches — jumped the layout and left it scrolled. Operator-reported from a live screen.

## What the source said that the blog posts did not

`Source/WebKit/UIProcess/API/ios/WKWebViewIOS.mm:1756-1757`, WebKit `main` at `246673dcae2a`:

```objc
const double webViewStandardFontSize = 16;
scale = clampTo<double>(webViewStandardFontSize / fontSize, minimumScale, maximumScale);
```

**The zoom is not a boolean.** The target scale is `16 / fontSize`. So 14px was a 1.14× jump and the
two inline `text-xs` selects were **1.33×** — and the architect's ruling had already corrected the
report's *"three carry the same 14px"* to 12px for those two, saying they therefore zoom *worse*.
The source is what turned "worse" into a size. A correction closed with the measurement of the thing
it was about is a correction that stays closed.

Every source consulted before that agreed on the threshold and none of them mentioned the ratio.
They were not wrong; they were the shape of answer a search returns, and it was not enough to
review against.

## The rationale the source corrected

The ruling required that where an inline select steps up, its surrounding label steps with it. The
natural reading is that the label matters to the zoom. **It does not — WebKit consults only the
focused control's font size.** Stepping the select alone stops the zoom completely.

So the label step is *visual*: without it a 16px control sits inside a 12px sentence reading
`to <select>`. That is exactly what the ruling said it was for, and now the code says so at both
call sites, with a test whose comment names it as pinning an outcome rather than a mechanism.
The difference between a change that survives and one deleted in two months as decorative is
whether the file explains which of the two it is.

## The ruling asked for a component; the string was the actual defect

The ruling said *extract a shared `Select`* — because `ConfigEditor`'s local select was a
character-for-character copy of `Input`'s class string. **A shared component would have satisfied
that and rebuilt the bug**: two identical *responsive* strings where there had been two identical
static ones. The fix is a shared `fieldBase` constant with a test asserting both controls render
every token of it. The architect's review named this as a correction to their own ruling.

The typechecker then found what reading had missed: `ConfigEditor` has **two** call sites, not one.
Both the issue and the ruling cite `ConfigEditor.tsx:35`, which is the definition.

## Deployed, and verified one layer below the version stamp

Staging went `main@afcc6a1` → `main@b410355`. The 2026-08-03 layer entry added a `VERSION` stamp
precisely because a digest change proves a different image and not newer code. **The same gap exists
one level down**: a version stamp proves a different build, not that the change is in the bundle
being served. So the assets were fetched off the box and grepped — `fieldBase` with `sm:text-sm`,
both inline selects with `sm:text-xs`, and the CSS utilities that make them resolve. Three curls.

**And the check that matters is still owed, to the only seat that can run it: an actual iPhone.**
The class assertions catch a deletion. They cannot prove the zoom stopped, they are said in the code
to be unable to, and every gate was green throughout the entire life of this bug — quince#512's
class, found by using the product.

## The process note

Both PRs went from open to merged inside one turn, each with an approval that engaged with the
evidence rather than the diff. What earned that was putting the *provenance* in the PR body — commit
shas for the WebKit read, the compiled CSS for the local arithmetic, and an explicit list of what was
swept and excluded. The reviewer verified the WebKit fact independently rather than accepting it,
which is what a citation is for.

The unticked CI checkbox was called out approvingly in review: unticked at open, with `make gates-ui`
named as what had actually run and the full ladder left to CI. The accurate version of that box beats
the optimistic one.

Refs: quince#616, quince#623, quince#626, quince#619.
