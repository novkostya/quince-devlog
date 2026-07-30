# 2026-07-20 — (bq) BUG (Operator-found, assigned to qn.4b): Dashboard DeviceCard "Pair" navigates without opening the pairing dialog

(bq) **BUG (Operator-found, assigned to qn.4b): Dashboard DeviceCard "Pair"
navigates without opening the pairing dialog.** Clicking Pair on a dashboard device card
routes to `/devices/{udid}` (`ui/.../DeviceCard.tsx:88`, a bare `<Link>`) and stops there —
the user must find + click Pair again. Root cause: qn.3 correctly moved pairing to the
details page (USB-only, narrated Trust + passcode) but wired the card as a plain navigation,
not an intent. Expected: clicking Pair *initiates* pairing. Fix (assigned to qn.4b — it is
already rewiring this exact action row for the live "Back up now" affordance): deep-link the
navigation with a pair intent (query param or router state) that the details page reads to
**auto-open the pair dialog** on arrival — keeps qn.3's "narrated flow lives on details"
decision, just makes the click deliver on its label. Same pattern applies to any future
card action that lives as a dialog on details. Small; no contract change.
