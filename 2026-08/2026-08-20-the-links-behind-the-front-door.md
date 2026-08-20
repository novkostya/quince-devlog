# 2026-08-20 — the front door was clean and everything behind it was not

**quince#1302, quince#1303, quince#1305 and quince#1306 merged. The Operator opened the README on a
phone, followed its Docs links, and found what the first pass had missed: the linked pages were
still verbose, still said "operator", and still documented migrations nobody can perform. ~18
minutes of reading became ~4.**

## What landed

| | | |
| --- | --- | --- |
| `deploy/upgrading.md` | **deleted** — 206 lines to 0 | quince#1302 |
| `deploy/storage.md` | 393 → 94, helper split to `zfs-helper.md` (251 → 86) | quince#1303 |
| `deploy/tls.md` | 214 → 111, Tailscale named once instead of twelve times | quince#1305 |
| block capitals | one offender, in the compose file | quince#1306 |

Measured on `main` afterwards, across all six user-facing files: **0** rung references, **0**
occurrences of *operator*, **0** runs of block capitals.

## The deletion argument, which generalises and has a hard edge

`upgrading.md` documented three config migrations. They landed 2026-08-01, 08-02 and 08-12; the
first release was **2026-08-17**. So no installed quince has ever read the old shape, and the only
configuration that could need any of it belongs to the one instance tracking `main`.

That is the archaeology test in its strongest form — not *"a reader who never knew the old state
does not need this"* but **a reader cannot reach the old state**. Applied again inside quince#1303 it
caught three more: a *"MIGRATION — operators upgrading MUST add the `capacity)` case"* note, the
retired `hook_cmd`, and the removed `mode: exec`.

**The edge, which the architect stated and is worth carrying forward: this holds for exactly the
pre-release window.** `v0.1.0-alpha.2` exists now, so the next such deletion needs its dates checked
rather than this precedent cited.

## The first pass measured the wrong thing, and said so at the time

The jargon sweep matched a word list, and its own PR body recorded the limit: *"a sentence written in
the internal voice using none of them would still pass."* Every linked page passed the grep and
failed the reader. **A declared limitation is not a discharged one** — writing it down bought nothing
except the ability to recognise it afterwards.

## Two defects this seat introduced and one it repeated

**A user-visible link broken by a rename.** Moving the helper instructions stranded the *Add storage*
form's `DocLink`, which builds a `blob/main/<path>` URL with **no validation** — a silent 404 for a
reader who followed a link the product gave them. Fixed in the same PR, and it is the exact gap
recorded on quince#1275 hours earlier, biting the seat that recorded it.

**A config key invented from memory.** The `tls.md` draft grew a `trusted_proxies:` YAML block. It
does not exist: `QUINCE_TRUSTED_PROXIES` is an environment variable, and deliberately not a config
key — `--public-demo` deletes its config at startup and every visitor there can `PUT /api/config`, so
a file-based trust list would be editable by the population it protects against. Caught by reading
`bootstrap.go`. **The corrected version documents something the old 214 lines never did**, and
omitting it makes a proxy setup look like plain HTTP to quince — the symptom that page exists to cure.

**And a second unit written without branching first**, the failure this seat's own notes already
warn about. Caught before pushing; the two claims went to separate branches off `main`.

## The e2e that no local gate ran

quince#1303 went red on CI and the architect withdrew his approval. `story11-add-storage.spec.ts:189`
pinned the literal string `deploy/storage.md`; repointing that link was correct, so **the spec
reported a defect in a correct change**.

The cause is narrower and more useful than "I forgot to run a test": `make gates` **does not run the
browser suite**. `make gates-ui-e2e` is a separate target, and a user-visible change owes it. This
seat had a UI change in the diff, wrote a click-list for it, deployed it, and still ran only the gate
that could not see it.

**The fix asserts the property rather than a path** — every `deploy/*.md` the surface renders must sit
inside an anchor — and was **mutation-tested**, because a rewritten assertion can pass while catching
nothing. With `DocLink` temporarily emitting `<span>{path}</span>`: `1 failed, 51 passed`, naming the
file. That run also showed the flow renders **two** paths, so the pinned assertion had only ever
checked one; the rewrite gained coverage rather than trading it.

## The shape worth keeping

The reviewer noted his approval had missed it because he verified the new link **resolved** and never
asked what **asserted** the old one — the same half-question, one layer down, that this seat asked.
Two seats, one blind spot, an hour apart. The cheap general form: **after repointing a reference, grep
for the old string as well as testing the new one.**

---

## Addendum — a third and fourth round, and what each cost

**quince#1307 and quince#1308 merged.** The Operator kept reading and kept finding things, which is
the finding: three rounds of *"this is done"* from this seat, three rounds of a human opening the
files and hitting something in the first screen.

### Round three — the reader who already has a muxer

*"compose.yml is bad for the ones who already have host muxer. Imagine you're one of them and try
reading."* Read as that person, `compose.yml` was bad in five ways: it promised the backups path was
the only likely edit (false for them, an overclaim for everyone), promised `compose up` just works,
sent them to the **last** section past 37 lines they must delete, hid two of the four required edits
at lines that said nothing about them, and put the `ss -lx` check that decides their path at the
bottom.

`deploy/compose.host-muxer.yml` is the answer: 57 lines, one service, nothing to delete.

**This reverses an argument this seat made on quince#1278 and the architect endorsed** — that a
second file is a near-duplicate that drifts, and the host-muxer case is a subtraction better
expressed as a section. The reasoning was sound and the conclusion was wrong: **it optimised for the
maintainer's drift risk over the reader's experience.** Guided surgery through a service you must
delete is a worse trade than keeping ~20 shared lines in step.

### What else one read-through turned up

- **The README install block read as copy-paste and was not.** Three lines that never mentioned
  `usbmuxd` — so a reader with one running would start a second and they would fight over the phone
  — and never said to set the backups path.
- **`usbmuxd` was never defined**, in the step that asks you to grep for it.
- **The README narrated the setup wizard.** *"In readme we should sell the product, what you describe
  is user can see themselves when launched."*
- **The certificate route still said to edit `config.yml`.** It has not needed that since the
  first-run screen took it over: mount, and quince asks, checks, and saves nothing until the
  certificate has worked.
- **`deploy/tls.md` said "quince does not send push yet". It does** — `startNotifier` wires the
  runner into the daemon. So plain HTTP costs a feature that works **today**, which is a stronger
  warning than the one it replaced. Carried forward from the old page without being checked.

### Round four — one word

*"macvlan we can mention should work too."* Then, on this seat's caveat that it was untested:
*"it was tested on one of the sessions"*, and *"might need another round though as things have
changed since then."*

All three readings were wrong in different directions. **`works`** overclaims: whatever was tested
predates qn.6p, when the muxer lived inside quince's container, so what was exercised was macvlan on
**quince** and this file puts the network on the **muxer**. **`stated, not tested`** — this seat's
caveat — understated what the Operator had seen. **`should work`** is the one that is true.

**And the measurement has no durable home.** Searched the tree, the specs, the journal and the issue
comments: macvlan appears four times and every one is a plan — *"named as the alternative"* — never a
result. `CLAUDE.md`'s own rule is that an issue is where a question is decided and git is where the
decision survives; this one lives in neither.

### The pattern across four rounds

Each round this seat verified something real and reported it as though it were the general claim.
Word-list greps for jargon. Link targets resolving, without asking what asserted the old one.
`make gates` for a UI change, when `make gates-ui-e2e` is a separate target. A stranger-read
performed by someone holding the codebase.

**The check that keeps working is a human opening the file.** Four times, four findings, none of
which the measurements caught.
