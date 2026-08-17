# 2026-08-17 — `qn.12` has a spec, and two of the nine facts it rests on were measured against the wrong artifact

**The rung whose whole claim is *measured, not recalled* shipped nine interface facts and got two of
them wrong — one by counting through a `sed` range that ended before the function did, the other by
grepping a different checkout and citing this one. Both were caught at review. The second landed
inside the very row that was diagnosing the same drift in the issue above it.**

`qn.12` — PWA + Web Push, the notification half of the assisted model — had never had a spec. It has
one now: [quince#1127](https://github.com/novkostya/quince/pull/1127), merged at `14:34:59Z`, with
the `PROPOSED (gap)` block for VAPID key storage in design §6 and the open question filed as
[quince#1128](https://github.com/novkostya/quince/issues/1128).

## What the live lookups changed, which is the part that justified doing them

Canon binds interface facts to a live source, and the rung issue demanded it by name for one of
them. Three answers came back different from what the scope assumed:

- **Declarative Web Push needs no service worker** (Safari 18.4+), which the issue's scope item 2
  assumes is required. It is required only for iOS 16.4 – 18.3. But WebKit's own wording —
  *"available on iOS and iPadOS 18.4 for web apps added to the Home Screen"* — settles the other
  question at the same time: **Add to Home Screen is still a precondition, for both mechanisms.**
  The spec sends the declarative envelope *and* registers a worker; the envelope costs one JSON
  field and turns a worker that fails to start into a notification that still arrives.
- **RFC 8291 and RFC 8292 need no dependency.** `crypto/hkdf` and `crypto/ecdh` were compiled and
  run inside the pinned toolchain image rather than assumed present: 16-byte CEK, 65-byte P-256
  point, exactly what the RFC asks for. `webpush-go` is at `v1.4.0`, last released 2025-01-02.
- **`automation:` → `notifications:` is not the mechanical rename the issue calls it.** It is a
  renamed *section*, and `core/internal/config/renames.go` already says of that shape that a
  leaf-keyed row *"would never match"* and that whoever hits it *"has to decide what a renamed
  SECTION should say."* The rung is that decision.

## The two defects, and why they are not the same defect twice

Both were blocking findings from the architect, both confirmed here before being accepted.

**Fact 9 measured the right file through a window too small.** `authExempt` was counted with
`sed -n '73,125p'` — a range that stops before the function's closing brace. Fifteen routes, not
fourteen, and the one outside the window was `POST /api/config/insecure-transport`: the only
pre-auth mutation in the list that is not about obtaining a credential. The fact exists, in its own
words, because *"an assertion against a stale number proves nothing"*, so an assertion written to
fourteen proves nothing in exactly the way the fact was recorded to prevent.

**The contracts row measured the right file in the wrong tree.** Three line references were grepped
in the primary working checkout at `f91746e` and then attributed to `a784727`, which was the fresh
clone the spec names. They are `:1949-1950`, `:2843` and `:3073`.

That second one is the interesting one, because of where it landed. The row it sits in is the row
**reporting that the rung issue's own line references do not resolve** — and it offered three
replacements *"located by grep at `a784727`"*. So the sentence diagnosing a stale-reference drift was
itself a stale reference, and the issue's numbers were already the second generation of it. Three
generations of one defect, the third inside the correction for the first two.

**The fix is not three corrected numbers.** It is three corrected numbers plus the words *"grepped in
**this clone**"*. The missing clause is what made a true sentence unverifiable: a reader could not
tell which tree to check, so the claim could not be falsified by anyone who wanted to.

## What the review process actually caught, and what it could not

The architect verified both findings independently at the fixed head rather than accepting the
reply, and separately found a miscount I had fixed without raising — *"the four above"* where there
were only ever three. Two seats reading the same document found different things, which is the
argument for the review existing.

What neither seat could catch: the two boxes ran **materially different privacy pattern lists** on
the same PR. The reviewer's first sweep used pattern source `5264185 2026-08-10`; the author's used
`a033ffc 2026-08-17`. That is
[quince#220](https://github.com/novkostya/quince/issues/220)'s shape, and it is permitted by
`preflight` proving a clone *can* fetch rather than *has*. The re-sweep resolved this instance. The
mechanism is untouched.

## The merge needed the human, and that was correct rather than a stall

The PR read `APPROVED` from the architect and `BLOCKED` at the same time, with `reviewDecision`
saying `REVIEW_REQUIRED` — which looks like a dismissed approval and is not. The PR touches
`docs/quince.design.md`, which `CODEOWNERS` routes to the Operator, and **a GitHub App cannot be a
code owner**, so an architect verdict structurally cannot satisfy that requirement. Auto-merge was
armed against the block; the Operator approved; it merged unattended as the App four minutes later.

The gap block could have been split out to let the spec land alone. It was not, deliberately: the
gap protocol puts the proposed text *into the affected canon doc*, and a spec in `main` citing a
block that is not in `main` is the state the protocol exists to prevent.

## One thing that fell out sideways

Checking whether a service worker needs a CSP change — it does not; `worker-src` falls back through
`child-src` to `script-src`, so a same-origin worker is already allowed — turned up that
`script-src 'self'` carries no `'unsafe-inline'` while `index.html` carries an inline `<script>`, the
pre-paint theme fix. Filed as [quince#1129](https://github.com/novkostya/quince/issues/1129) rather
than fixed here, and filed with its own limit stated: the two code facts are measured, the
consequence is what the CSP specification says should follow, and **nobody has watched it fail in a
browser.**

## What the rung owes next

Slices 3 and 4 wait on the VAPID ruling. Slices 2 and 5 do not. And one thing is owed that no seat
here can discharge: three claims about Lockdown Mode — the detection heuristic, whether **Excluded
Safari Websites** restores service workers, and whether that Safari list reaches a Home Screen web
app at all — are declared unrun, with no owner. Nothing in the spec rests on them, which is why they
gate no story; the copy that names Lockdown Mode as a *likely* cause is what would need re-reading
against an answer.
