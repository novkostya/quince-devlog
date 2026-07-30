# journal-migrate.awk — the parser behind bin/journal-migrate. See that script for the contract.
#
# The source region is regular and this program ASSERTS that rather than assuming it: every
# top-level construct is `- 2026-…`, every continuation is exactly 2 spaces, and every blank line
# sits between entries. Any line that is none of those stops the run. A migration that silently
# skipped a line it did not recognise is the failure mode worth spending an assertion on.

function die(msg) {
	printf "journal-migrate: %s\n", msg > "/dev/stderr"
	bad = 1
	exit 1
}

function trim(s) {
	gsub(/^[ \t]+/, "", s)
	gsub(/[ \t]+$/, "", s)
	return s
}

# The H1 title. Bold-lead entries (the form CLAUDE.md specifies) give it up directly; the oldest
# entries predate that convention, so their first sentence stands in. Two openers are peeled off
# first and for different reasons: the `<date>[ (qualifier)]: ` prefix, which the 11 verbatim
# entries still carry in their body and which would otherwise repeat the date inside its own
# title; and a leading retired lettered id, which is kept but held aside so the bold claim behind
# it is still found. A title is derived metadata: a poor one is cosmetic and fixable by editing
# one line, and cannot corrupt a body.
function extractClaim(   txt, i, lim, p, q, c, id) {
	lim = (n > 8) ? 8 : n
	txt = L[1]
	for (i = 2; i <= lim; i++) txt = txt " " L[i]
	if (txt ~ /^2026-[0-9][0-9]-[0-9][0-9]/) {
		p = index(txt, ": ")
		if (p > 0) txt = substr(txt, p + 2)
	}
	id = ""
	if (match(txt, /^\([a-z]+(-[a-z0-9]+)?\) /)) {
		id = substr(txt, 1, RLENGTH - 1) " "
		txt = substr(txt, RLENGTH + 1)
	}
	if (substr(txt, 1, 2) == "**") {
		p = index(substr(txt, 3), "**")
		c = (p > 0) ? substr(txt, 3, p - 1) : substr(txt, 3)
	} else {
		c = txt
		p = index(c, ". ")
		q = index(c, "; ")
		if (q > 0 && (p == 0 || q < p)) p = q
		q = index(c, " \342\200\224 ") # " — ", as bytes
		if (q > 0 && (p == 0 || q < p)) p = q
		if (p > 0) c = substr(c, 1, p - 1)
	}
	# A handful of claims carry their whole citation tail inside the bold — one runs to 636
	# characters of inline links. Cut at the first parenthesised markdown link, then hard-cap at a
	# word boundary. The ellipsis is there so a truncated title cannot be mistaken for a short one.
	p = index(c, " ([")
	if (p > 0) c = substr(c, 1, p - 1)
	if (length(c) > 180) {
		c = substr(c, 1, 180)
		for (i = length(c); i > 0; i--)
			if (substr(c, i, 1) == " ") {
				c = substr(c, 1, i - 1)
				break
			}
		gsub(/[ \t,;:.\342\200\224-]+$/, "", c)
		c = c "\342\200\246" # …
	}
	c = id c
	gsub(/\*\*/, "", c)
	gsub(/[ \t]+/, " ", c)
	c = trim(c)
	gsub(/[.,;:]+$/, "", c)
	return c
}
function slugify(c,   s, i, p) {
	s = tolower(c)
	gsub(/[^a-z0-9]+/, "-", s)
	gsub(/^-+/, "", s)
	gsub(/-+$/, "", s)
	if (length(s) > 56) {
		s = substr(s, 1, 56)
		p = 0
		for (i = length(s); i > 0; i--)
			if (substr(s, i, 1) == "-") {
				p = i
				break
			}
		if (p > 20) s = substr(s, 1, p - 1)
		gsub(/-+$/, "", s)
	}
	return (s == "") ? "entry" : s
}

function startEntry(line,   rest, cand) {
	entries++
	date = substr(line, 3, 10)
	if (date !~ /^2026-[0-9][0-9]-[0-9][0-9]$/) die("line " NR ": entry date is not a date: " date)
	months[substr(date, 1, 7)] = 1
	n = 0
	rest = substr(line, 13)
	# 165 of 176 entries open `- <date>: `; the 11 that carry a parenthetical qualifier keep it
	# verbatim, because one of them wraps the qualifier onto a second line and a stripper that
	# handles the easy 165 and mangles the hard 11 is worse than one that declines the 11.
	if (substr(rest, 1, 2) == ": ") {
		cand = substr(rest, 3)
		if (substr(cand, 1, 5) != "2026-") {
			L[++n] = cand
			stripped++
		}
	}
	if (n == 0) L[++n] = substr(line, 3)
}

# The retired lettered ids `(a)`–`(do)`. CLAUDE.md keeps them forever as live citations from docs
# and git history, so a migration that leaves them unresolvable breaks references it cannot see.
# Two signals, in priority order: an entry whose claim OPENS with `(id) ` declares it, which is
# how 100 of them read; otherwise first occurrence in source order wins, which is sound because
# the log is append-only and no id can be cited before the entry that mints it.
function recordIds(rel, display, claim,   txt, i, lim, id, rest, p) {
	if (match(claim, /^\([a-z0-9]+(-[a-z0-9]+)?\) /)) {
		id = substr(claim, 2, RLENGTH - 3)
		declCount[id]++
		decl[id] = (declCount[id] > 1) ? decl[id] "\n" rel "\t" display : rel "\t" display
	}
	lim = (n > 40) ? 40 : n
	txt = ""
	for (i = 1; i <= lim; i++) txt = txt " " L[i]
	rest = txt
	while (match(rest, /\([a-z][a-z]?\)/)) {
		id = substr(rest, RSTART + 1, RLENGTH - 2)
		if ((id in canon) && !(id in firstSeen)) firstSeen[id] = rel "\t" display
		rest = substr(rest, RSTART + RLENGTH)
	}
}

function flush(   claim, slug, base, k, path, rel, i, h, line, want) {
	if (n == 0) return
	claim = extractClaim()
	slug = slugify(claim)
	base = slug
	k = 1
	while ((date "-" base) in used) {
		k++
		base = slug "-" k
	}
	used[date "-" base] = 1
	if (k > 1) collisions++
	if (mode == "months" || mode == "count") return

	rel = substr(date, 1, 7) "/" date "-" base ".md"
	if (mode == "letters") {
		recordIds(rel, date " \342\200\224 " claim, claim)
		return
	}
	path = tree "/" rel
	h = "# " date " \342\200\224 " claim # "# <date> — <claim>"

	if (mode == "split") {
		print h > path
		print "" > path
		for (i = 1; i <= n; i++) print L[i] > path
		close(path)
		written++
		return
	}

	# verify — read the file back and compare every byte of every line.
	if ((getline line < path) <= 0) {
		mism++
		printf "  MISSING  %s\n", path > "/dev/stderr"
		close(path)
		return
	}
	if (line != h) {
		mism++
		printf "  H1 DIFFERS  %s\n", path > "/dev/stderr"
	}
	if ((getline line < path) <= 0 || line != "") {
		mism++
		printf "  NO BLANK AFTER H1  %s\n", path > "/dev/stderr"
	}
	for (i = 1; i <= n; i++) {
		if ((getline line < path) <= 0) {
			mism++
			printf "  SHORT at body line %d  %s\n", i, path > "/dev/stderr"
			break
		}
		if (line != L[i]) {
			mism++
			printf "  BODY LINE %d DIFFERS  %s\n", i, path > "/dev/stderr"
			break
		}
	}
	if ((getline line < path) > 0) {
		mism++
		printf "  TRAILING CONTENT  %s\n", path > "/dev/stderr"
	}
	close(path)
	checked++
}

BEGIN {
	inlog = 0
	n = 0
	pendingBlank = 0
	# The canonical id space, closed at (do) — CLAUDE.md: "never mint a new one". Because it is
	# closed, the map this produces is FROZEN rather than regenerated, and cannot go stale.
	nCanon = 0
	for (i = 1; i <= 26; i++) canonOrder[++nCanon] = sprintf("%c", 96 + i)
	done = 0
	for (p = 1; p <= 4 && !done; p++)
		for (i = 1; i <= 26 && !done; i++) {
			id = sprintf("%c%c", 96 + p, 96 + i)
			canonOrder[++nCanon] = id
			if (id == "do") done = 1
		}
	for (i = 1; i <= nCanon; i++) canon[canonOrder[i]] = i
}

/^\*\*Decisions log\.\*\*/ {
	inlog = 1
	next
}
!inlog { next }

NF == 0 {
	pendingBlank = 1
	blanks++
	next
}

/^- 2026-/ {
	if (n > 0) flush()
	pendingBlank = 0
	startEntry($0)
	next
}

/^  / {
	if (pendingBlank) die("line " NR ": a blank line sits INSIDE an entry; the split would lose it")
	if (n == 0) die("line " NR ": continuation line before any entry")
	L[++n] = substr($0, 3)
	next
}

{ die("line " NR ": unrecognised line shape: " substr($0, 1, 60)) }

END {
	if (bad) exit 1
	if (n > 0) flush()
	if (!inlog) die("no `**Decisions log.**` header found in the source")
	if (entries == 0) die("the decisions log is empty")

	if (mode == "months") {
		for (m in months) print m
		exit 0
	}
	if (mode == "count") {
		print entries
		exit 0
	}
	if (mode == "letters") {
		unresolved = ""
		ambiguous = ""
		print "| id | entry |"
		print "| --- | --- |"
		for (i = 1; i <= nCanon; i++) {
			id = canonOrder[i]
			src = (id in decl) ? decl[id] : ((id in firstSeen) ? firstSeen[id] : "")
			if (src == "") {
				unresolved = unresolved " (" id ")"
				continue
			}
			if (declCount[id] > 1) ambiguous = ambiguous " (" id ")"
			nl = split(src, rows, "\n")
			for (r = 1; r <= nl; r++) {
				split(rows[r], f, "\t")
				printf "| `(%s)` | [%s](%s) |\n", id, f[2], f[1]
			}
		}
		printf "\nunresolved:%s\n", (unresolved == "") ? " none" : unresolved > "/dev/stderr"
		printf "declared more than once:%s\n", (ambiguous == "") ? " none" : ambiguous > "/dev/stderr"
		exit 0
	}
	if (mode == "split") {
		printf "journal-migrate: %d entries -> %d files; %d date-prefixes stripped, %d kept verbatim\n", entries, written, stripped, entries - stripped
		printf "journal-migrate: %d slug collision(s) resolved by suffix; %d inter-entry blank line(s) normalised away\n", collisions + 0, blanks + 0
		exit 0
	}
	if (mism > 0) {
		printf "journal-migrate: VERIFY FAILED - %d mismatch(es) across %d entries\n", mism, entries > "/dev/stderr"
		exit 1
	}
	printf "journal-migrate: verify clean - %d entries reassemble byte-identically from %d files\n", entries, checked
	exit 0
}
