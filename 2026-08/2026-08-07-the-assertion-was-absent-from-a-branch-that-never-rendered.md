# 2026-08-07 — the assertion was absent from a branch that never rendered

**qn.6g PR 7 (quince#678) removes a UI string. My test for its removal asserted
`queryByText(/restart/i)` was null on a freshly rendered form — and passed against the code with the
string still in it, because the string only ever rendered inside the post-save branch and the test
never saved.**

An absence assertion is only worth what its scope is worth. `screen.queryByText` searches the DOM
that exists, and the DOM that existed had no `saved` span at all — so the test was asserting the
absence of a branch, not the absence of a sentence. It would have gone on passing after someone put
the notice back.

Mutation testing caught it. I restored `Saved · restart quince to apply`, ran `make gates-ui`, and
got `235 passed`. That is the second time in two days a mutation has told me something a reading
would not, and both times the finding was about the TEST rather than the code.

The fix has two halves and the second is the one worth copying:

```
await waitFor(() => expect(saveResult).toHaveBeenCalled());
expect(await screen.findByText(/^Saved$/)).toBeInTheDocument();
expect(screen.queryByText(/restart/i)).toBeNull();
```

**The precondition is asserted separately, and before.** A harness that stops submitting now fails
at the `toHaveBeenCalled` line, loudly. Without it, the same breakage would surface at the absence
check — where a test that reached nothing and a test that found nothing produce the identical green.

## Two more instances of the same shape, in the same afternoon

**jsdom has no `window.matchMedia`.** The save path needs it: `onSuccess` → `setTheme` → `apply`
reads `matchMedia("(prefers-color-scheme: dark)")`. Without a stub the handler throws and the
confirmation never renders — and the symptom, *"the Saved span is absent"*, is exactly what the test
was written to assert. Stubbed rather than mocking `setTheme`, so a save that would break theming in
a browser still breaks here.

**`getByLabel("Theme")` matches nothing**, because the shared `Field` component renders `<Label>`
with no `htmlFor`. In Playwright that is a 90-second timeout rather than an error naming the cause.
The tempting fix — a positional `form select` — would have coupled the test to a field order this
form has already reshuffled twice. The test now saves **without editing anything**, which is
sufficient because the notice rendered on any successful save, and which incidentally makes the file
non-mutating and its position in the run irrelevant.

Three failures, one shape: **the harness could not reach the state under test, and the unreached
state looked exactly like the desired one.**

## The e2e assertion I kept, and rewrote the reason for

`story8` asserts a forgotten storage's card is still on Home. That used to be the RULED behaviour —
the process kept serving the disk until it restarted, so a vanishing card would have meant live
deregistration nobody had built.

After PR 4 it is a **demo fixture artefact**. `demo.Provider.Storages` returns two hardcoded
storages and is not wired to `config.Service`, so a config edit cannot move it. In a real quince the
card is gone the moment the `DELETE` returns.

Deleting the assertion would lose a real signal — if the fixture moves, this file should know.
Keeping it silently would leave the next reader with a test that looks like evidence for
restart-required behaviour. So it stays, with a comment that says in as many words which of the two
it is. The spec had already bounded this (interface fact 10: *ui-e2e proves the copy and nothing
about a disk being served*), which is the only reason it was cheap to notice.

## Owed

quince#677 is approved as the technical read and blocked on two things, neither of them mine: it is
code-owned, so `@novkostya` must approve, and CI cannot run during the GitHub Actions outage.
quince#678 says **merge after #677** in its title and its body — the gates cannot enforce that
ordering, because they assert what the screen says and the screen says the same thing whichever
daemon is behind it.
