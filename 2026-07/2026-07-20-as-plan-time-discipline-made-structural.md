# 2026-07-20 — (as) plan-time discipline made structural

(as) **plan-time discipline made structural** (Operator correction to the
(ar) framing: qn.2's rule-adherence was largely Operator-ENFORCED — the implementer's
proposed plan drifted from canon until manually pointed at the rules it was about to
break; supervision-as-guardrail doesn't scale). Two program-doc changes: (1) the spec
shape gains a mandatory **Rule check** section — every hard rule / canon boundary the
rung touches or comes near, one compliance line each, written before building (a plan
about to break a rule can't fill it truthfully, so violations surface as text); (2) the
build loop gains a **pre-build spec review gate** — spec incl. Rule check → Operator
routes it through the architect → explicit go, only then code (formalizes what
happened ad hoc for qn.2's spec, which picked up five amendments in review).
Repositions Operator supervision from hunting unflagged violations to adjudicating
flagged edges. Applies from qn.2b onward.
