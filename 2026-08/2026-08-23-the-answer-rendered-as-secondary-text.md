# 2026-08-23 — The answer rendered as secondary text, and a declared gap that got acted on

**`qn.10`'s surface began. Two of its three findings came from checking things a review had
declared unchecked — and the contrast with the same seat's earlier declared gap, which sat unread
while the defect it named was live in three merged slices, is the entry.**

## What landed

The chats list (`7a`), a role correction to it, and `MessageRow` (`7b`). Component-level slices,
each landing without the screen that holds them existing — which is possible because the list builds
nothing and the row renders a page it is handed.

## The answer was rendered as secondary text

`ChatList` shows one of two sentences when there is nothing to list: *why quince cannot serve this
backup's messages*, or *this backup has no conversations in it*. Both were `text-muted`.

**Each is the only content on its card.** There is nothing for it to be secondary **to**, and the
sentence is the answer to *where are my messages*. `text-muted` is for an explanation sitting
*beside* primary content — which is exactly how `DomainReport` uses it: `text-fg` for the domain
name, `text-muted` for the sentence explaining it.

That is quince#1215's class — the contrast floors are right and the **role** is wrong — arriving in
code written the same hour.

## Checking the type scale nearly produced a worse bug than the one being fixed

`ui.design.md` says *body and field labels — 16px — every sentence a user reads*. Every sentence in
the component was `text-sm`, which reads as smaller than body. **It is not.** `tokens.css:42`:

```css
--type-sm: 1rem; /* 16px — THE BODY DEFAULT. Every sentence a user reads. */
```

Promoting them to `text-base` would have made every sentence an **18px card title** — a worse defect
than the role confusion, introduced while fixing it, and **it would have looked like compliance with
the design document.** Reading the token rather than the prose is what caught it: the doc names sizes
in pixels and the code names them in scale steps, so the mapping is the thing to check, never the
adjective.

## The same seat, the same kind of sentence, opposite outcomes

The role defect was found because a review said:

> I did not check the component against `ui.design.md`.

That was acted on within minutes and found something real. Two hours earlier the same seat had
written, on a different PR:

> I did not verify `CountingFS` records every path into the vault — **only `Materialize`**.

**That one sat unread, and the defect it named precisely was live in three merged slices** until it
turned up from the other direction while scoping a later one.

**A declared gap is worth exactly what somebody does with it.** The difference between the two is not
care — both were honest and both named the risk. It is that one named a **class** a reader could go
and check, and the other named a doubt. *"I did not check X against Y"* travels. *"I am not certain
about X"* does not.

## Five states that all look like an empty bubble

`MessageRow`'s whole job. A message record can be an ordinary message, legitimately empty
(attachment-only or a system event), **undecodable** — unknown rather than empty — **unsent**, or an
**app message** whose payload quince does not decode. All five render identically if a surface is
careless.

Rendering the undecodable one as an empty bubble states that someone sent nothing, which nobody
established. Each gets its own sentence, and a control asserts the three explanations are *distinct
strings* — two collapsed into one would leave every other assertion in the file passing.

**`bodyText` returns the text and whether it is the user's words.** Without that flag, *"quince could
not read this message's text"* renders exactly like something a person typed.

## Where it stopped, and why that is different from last time

Earlier in the same session this seat stopped on a reason that had already expired — a design
question it had itself resolved by measuring — and was asked why. The test it should have applied,
and now does: **is there work left that forecloses nothing and needs no ruling?**

Here there is not. The remaining surface — the thread view, attachments, search — is sequential
through one slice, and that slice has **two** open decisions: how the ~18 s scan reports progress
(indeterminate, or a WS event that costs a frozen-contract addition and a scoping classification),
and how a 98,598-message conversation avoids rendering 98,598 rows (a new dependency on a bundle that
already warns at 621 kB, hand-rolled windowing, or leaning on the cursor that already exists).

Both were routed rather than taken. The second was found by starting the slice and reading
`package.json` — which is the cheapest possible way to discover that a written requirement, *"a
virtualized thread view"*, has no implementation available.
