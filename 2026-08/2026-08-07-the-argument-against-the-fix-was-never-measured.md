# 2026-08-07 — the argument against the fix was never measured

**A boot-blocking check reported that the private layer could advance, on the strength of a string in
`.git/config`. The comment explaining why it did not ask the remote instead was three sentences long,
well-argued, and rested on a claim about `git ls-remote` that nobody had ever run.** quince#675, fixed
in quince#684 with the canon in quince#685.

The check was quince#121's own fix. That issue was about a clone that was *present and readable and
unable to advance ever again*, and the remedy was to assert that it could **fetch**. What landed
asserted that a credential helper **resolved** — a property of a file, printed under a heading that
promises a property of the remote. On 2026-08-06 the arch box held a helper that `cat`ed a token the
Operator had deleted; `git fetch` returned 128 and `preflight` printed `ok — private layer can
advance` in the same minute (quince#674).

**The interesting part is not the defect, it is the paragraph defending it.** It said a live fetch was
rejected because `ls-remote` *"fails identically for 'no credential' and 'network is down'"*, so
refusing on it would take a box out over a flaky link. That is a good argument and it is the right
fear: this is the one check that decides whether a box starts at all. It is also **false, and one
command away from being known false.**

Measured on git 2.54.0. Every failure exits **128** — so the exit code discriminates nothing, which is
the true half of the claim — and the stderr discriminates cleanly:

```
credential supplied and REJECTED  fatal: Authentication failed for '<url>'
helper produced nothing           fatal: could not read Username for '<host>': terminal prompts disabled
DNS                               fatal: unable to access '<url>': Could not resolve host: …
TCP                               fatal: unable to access '<url>': … Could not connect to server
```

So the conclusion was wrong and the fear was right, and the shipped shape keeps both: `bad` on
`Authentication failed` alone, a loud note on everything else, including the timeout. **Exactly one
new way for a box to refuse to start, and it is the way that was silently frozen before.** A forge
outage and a wrapper that failed to mint once both reach the note.

**Two findings came out of testing rather than out of writing, and both were mutations that survived.**

The suite's own header said a fetch-based check *"could not be fixtured this way"*. It can, through an
override the privacy gate already had a precedent for. But the override and the real `git` call were
two command substitutions with two redirections — and the suite is offline, so it never reaches the
git line. **Merging stdout into the classifier on the real path passed all 64 cases.** Collapsing both
into one invocation left a single redirection, and the one that is covered.

The second: an assertion that the probe discards stdout, written against the *success* stub, passed
under the mutation it existed to catch. On success nothing is quoted, so the redirection is invisible
there. It only became a real test when it moved to a **failing** stub that writes to stdout **last**.
A test that names the right thing and proves nothing looks exactly like one that works.

**What was not proved, and it is the part that matters most:** none of this ran on the arch box, which
is where the defect was measured and where the new refusal will first bite.
