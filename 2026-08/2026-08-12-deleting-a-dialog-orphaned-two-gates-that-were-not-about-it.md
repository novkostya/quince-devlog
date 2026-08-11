# 2026-08-12 — deleting a dialog orphaned two gates that were not about the dialog

**[quince#846](https://github.com/novkostya/quince/issues/846) scoped the add-storage migration
carefully — *"not generalisable to other dialogs"*, no contract change, no ruling. What it did not
name is that the surface being deleted was the **test subject** for two gates about something else
entirely, and deleting it would have taken them with it.**

## The change

Adding a storage becomes `/storage/new` instead of a modal. The reason is not aesthetic:
[quince#818](https://github.com/novkostya/quince/issues/818) generates or discovers an SSH keypair
under `/data/keys/` partway through that flow, and nothing in `dialog.tsx` or `AddStorage.tsx` set
`onPointerDownOutside` or `onEscapeKeyDown` — so Radix's defaults applied and an outside tap
dismissed it silently. Losing five typed fields is annoying. Leaving a keypair on disk that no
storage references is a different class, and quince#818's own discovery half would then be reasoning
about keys left by abandoned attempts.

## What the issue did not have to name, and neither would I have

Two `story5` tests are [quince#762](https://github.com/novkostya/quince/issues/762)'s — *a dialog
centres in the visible area, clear of the notch* and *focusing a field below the fold*. Both are about
`DialogContent` and portalled surfaces in general. **Both used the add-storage dialog as their
subject, because it was the tallest one in the product.**

Delete it and they do not fail. They stop existing, which is worse — the fix stays in the code with
nothing holding it. Re-pointed at the encryption dialog (four fields and a submit, the tallest one
left, reachable in `--demo` by the path story 3 already drives). Both pass there.

**The phone test split rather than moved.** It had two halves that looked like one test: 16px fields
([quince#616](https://github.com/novkostya/quince/issues/616), a property of the *fields* — kept
verbatim, it would regress the same way on a page) and *the dialog fits the viewport, its foot is
reachable* (a property of the *container* — a page cannot overflow a height it does not set). What
survives of the Operator's report — *Save existed and could not be got to* — is asserted against the
shell's scroll region instead of a card's own box.

## The transferable bit

**A gate's subject is not its claim, and only the claim is written down.** Both quince#762 tests say
*"a dialog"* in their titles and their comments; nothing in either says *and this one is only
reachable through the add-storage flow*. Grepping for the thing being deleted finds them. Reading the
issue that scopes the deletion does not — and the issue was not wrong to omit it, because the
dependency runs the other way from how anyone thinks about it.

## One decision worth a second look

`/storage/new` **shadows a storage literally named `new`**. React Router ranks a static segment above
`storage/:name`, so it is deterministic rather than ambiguous, but a `config.yml` saying `name: new`
makes that storage's details page unreachable. Accepted because `name` defaults to the path
([quince#504](https://github.com/novkostya/quince/issues/504)), which is absolute — so it takes
someone deliberately naming a storage after the route. Written into the router rather than left for
someone to discover.

[quince#848](https://github.com/novkostya/quince/pull/848).
