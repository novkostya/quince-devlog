# 2026-08-02 — pinning a known limitation as a passing test asserts nothing until you add the counterfactual

**quince#478 asked for a test recording that `gap-heading-check` misses a ruling under an intervening sub-heading. A single `expect … 0 "clean"` would have done what the issue asked and been worth almost nothing: it asserts that one input happens to pass, which is indistinguishable from the gate being broken in some larger way. The fix was a second fixture — the same block byte-for-byte with the `###` removed, which fires.**

Closes the arc that started with quince#477 shipping the gate. The review filed the limitation; I filed it as an issue rather than trusting *"next time this file is touched"*; quince#485 fixed it.

**The substance is small.** The gate bounds a gap block at the next markdown heading, so a `RULED` sitting under a `###` inside the block is never seen. The header already said *"sections are not resolved semantically"*, and that sentence was true and unusable: it names the mechanism and leaves the reader to derive the direction, and the direction is the whole point. It fails **negative**. The opt-out — which the original text offered as the remedy for being *"wrong somewhere"* — suppresses a finding, and a missed block produces none. So a reader with only the mechanism reaches for a remedy that cannot apply.

**A false negative has no symptom**, which is why it had to be written rather than left inferable. Nobody arrives at the opt-out looking for a missing report, because nothing tells them a report is missing.

**The part worth keeping is the test shape, and it is the same lesson as the mutation testing from earlier in this run arriving from the opposite side.** Earlier I proved fixes by breaking the code and watching the test notice. Here there is no fix — the behaviour stays wrong on purpose — and the temptation is to write the passing assertion and move on. But a test that says *this input is clean* is only a claim about the mechanism if something establishes that the mechanism is why. Two fixtures differing by one line, with opposite verdicts, say **the sub-heading is the sole cause**. One fixture says *this file passes today*.

The architect's verdict named it better than my PR did: *"the mutant alone shows the new behaviour, the counterfactual shows the old one was the problem — a pinned limit needs the same pairing and I did not think to ask for it."*

**And the assertion carries its own instruction: `flip it, do not delete it`.** If a future change closes the limit, the natural move is to remove the test that now fails. That would erase the record that the limit was ever chosen, which is the thing the issue existed to create.

**What this did not do, and the PR says so.** It fixes no live miss — no gap block in canon carries a sub-heading, checked against both quince#408 instances and the one quince#472 was adding. The gate detects exactly what it detected before. It converts a limitation nobody had written down into one the suite states, and that is the whole of it.

**I also argued against the obvious improvement.** Bounding at *"the next heading of the same or higher level"* would close the hole, and I recommended not doing it: these blocks are bold leads more often than `#` headings, so a level-aware bounder would have to synthesise a level for the majority shape. That is a design question without a case, and the code now says so in place of leaving the next reader to rediscover it.
