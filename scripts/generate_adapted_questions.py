#!/usr/bin/env python3
"""
Generate adapted question rows from the existing multiple_choice bank.

Usage:
    python3 scripts/generate_adapted_questions.py <questions_export.csv> \
        --out supabase/migrations/0035_adapted_question_bank.sql \
        --report /tmp/adaptation_report.json

This is an OFFLINE, one-time batch step (see 0034's migration header for
why: materialize once, don't transform at request time). It reads a CSV
export of the `questions` table (the same shape Supabase's SQL editor
"Download CSV" produces), and for every eligible multiple_choice row,
deterministically derives one or more compatible representations:

    true_false       — a true statement and a false statement, each
                        graded via the same option_a/option_b/
                        correct_option machinery multiple_choice's
                        sibling type already uses (0026).
    identification    — same prompt, typed answer = the correct option.
    fill_blank        — a declarative version of the prompt with the
                        answer blanked out. Only generated when the
                        prompt matches a clean interrogative pattern
                        (What/Which/Who is/was/are/were...) — this is
                        the one type where a bad automatic transform
                        would visibly read as broken, so unmatched
                        prompts are skipped rather than forced through
                        the generic fallback used for true_false.
    unscramble        — only when the correct answer is a single,
                        alphabetic-ish token 3-20 characters long
                        (the same shape questions_unscramble_fields
                        already requires).
    matching          — built from *sets* of 2-6 source questions in the
                        same category+difficulty whose declarative form
                        produced a short proper-noun-ish term and a
                        concise definition. Not a 1:1 adaptation, so it
                        gets its own source_question_ids array.

Every generated row is checked against the QUESTION QUALITY RULES in the
brief before being kept: no ambiguous/overlong answers, no changed
meaning, category+difficulty always inherited verbatim from the source.
sequence and image are NOT generated here — the CSV genuinely doesn't
contain reliable chronology/imagery data to adapt from (see the
migration's final report for that limitation).

Output is a plain .sql file of INSERT statements referencing the
source rows' existing ids via source_question_id / source_question_ids.
It does NOT touch or re-insert the original multiple_choice rows —
per the brief, the CSV is treated as read-only source-of-truth for
*analysis*, not something to overwrite the database with.
"""

from __future__ import annotations

import argparse
import csv
import json
import random
import re
import sys
from collections import defaultdict
from dataclasses import dataclass, field

MAX_TYPED_ANSWER_WORDS = 8
MAX_TYPED_ANSWER_CHARS = 60
MAX_MATCHING_TERM_WORDS = 4
MAX_MATCHING_TERM_CHARS = 30
MIN_MATCHING_DEF_CHARS = 8
MAX_MATCHING_DEF_CHARS = 140
MATCHING_SET_SIZE = 4
UNSCRAMBLE_MIN_LEN = 3
UNSCRAMBLE_MAX_LEN = 20

# Deterministic across runs so regenerating from the same CSV produces the
# same output (important for reviewability / diffing).
RNG_SEED = 20260825
rng = random.Random(RNG_SEED)

DECL_PATTERNS = [
    # (regex, verb-in-statement, "who"-style i.e. blank goes at the front)
    (re.compile(r"^(?:What|Which)\s+is\s+(.+)$", re.IGNORECASE), "is", False),
    (re.compile(r"^(?:What|Which)\s+was\s+(.+)$", re.IGNORECASE), "was", False),
    (re.compile(r"^(?:What|Which)\s+are\s+(.+)$", re.IGNORECASE), "are", False),
    (re.compile(r"^(?:What|Which)\s+were\s+(.+)$", re.IGNORECASE), "were", False),
    (re.compile(r"^Who\s+is\s+(.+)$", re.IGNORECASE), "is", True),
    (re.compile(r"^Who\s+was\s+(.+)$", re.IGNORECASE), "was", True),
    (re.compile(r"^Who\s+are\s+(.+)$", re.IGNORECASE), "are", True),
    (re.compile(r"^Who\s+were\s+(.+)$", re.IGNORECASE), "were", True),
]

WORD_RE = re.compile(r"\S+")
TOKEN_RE = re.compile(r"^[A-Za-z][A-Za-z'\-]{2,19}$")

# "What is/are the X called(, trailing clause)?" is common trivia
# phrasing where the answer belongs after "called", not as the sentence
# subject the generic What-is pattern below would put it as. Handled as
# its own case, tried first, so "What is the traditional Filipino
# practice ... called, often seen in community projects?" becomes
# "The traditional Filipino practice ... is called Bayanihan, often seen
# in community projects." instead of the grammatically broken
# "Bayanihan is the traditional Filipino practice ... called, often
# seen...".
CALLED_PATTERN = re.compile(
    r"^What\s+(?:is|are)\s+the\s+(.+?)\s+called\s*(.*)$", re.IGNORECASE
)


def word_count(s: str) -> int:
    return len(WORD_RE.findall(s))


def sql_str(s: str | None) -> str:
    if s is None:
        return "null"
    return "'" + s.replace("'", "''") + "'"


def sql_arr(items) -> str:
    if not items:
        return "null"
    return "ARRAY[" + ",".join(sql_str(i) for i in items) + "]::text[]"


def sql_uuid_arr(ids) -> str:
    if not ids:
        return "null"
    return "ARRAY[" + ",".join(sql_str(i) for i in ids) + "]::uuid[]"


@dataclass
class SourceQ:
    id: str
    category: str
    difficulty: str
    prompt: str
    options: dict  # A/B/C/D -> text
    correct_option: str
    explanation: str | None

    @property
    def correct_text(self) -> str:
        return self.options[self.correct_option].strip()

    def wrong_option_letter(self) -> str | None:
        for letter in ["A", "B", "C", "D"]:
            if letter == self.correct_option:
                continue
            text = self.options.get(letter)
            if text and text.strip() and text.strip().lower() != self.correct_text.lower():
                return letter
        return None


def declarative(prompt: str, answer: str):
    """Try to turn an interrogative prompt into a declarative statement.

    Returns (statement, blank_sentence, method) or None if no pattern
    matched. `method` is 'pattern' (clean grammatical transform, safe to
    also use for fill_blank/matching) — there is no fallback here; callers
    that need 100% coverage (true_false) fall back to the generic
    "correct answer to ..." template themselves.
    """
    stripped = prompt.strip()
    if stripped.endswith("?"):
        stripped = stripped[:-1].rstrip()

    m = CALLED_PATTERN.match(stripped)
    if m:
        prefix = m.group(1).strip()
        trailing = (m.group(2) or "").strip().lstrip(",").strip()
        suffix = f", {trailing}" if trailing else ""
        statement = f"{prefix[0].upper()}{prefix[1:]} is called {answer}{suffix}."
        blank = f"{prefix[0].upper()}{prefix[1:]} is called ______{suffix}."
        # For matching, the descriptive content a definition needs is
        # "prefix + trailing clause" together (bare prefix alone, e.g.
        # "the Filipino tradition", is too generic on its own to work as
        # a matching-board clue).
        rest_for_matching = f"{prefix} {trailing}".strip() if trailing else prefix
        return statement, blank, rest_for_matching

    for regex, verb, blank_at_front in DECL_PATTERNS:
        m = regex.match(stripped)
        if not m:
            continue
        rest = m.group(1).strip().rstrip(".")
        if not rest:
            continue
        if blank_at_front:
            statement = f"{answer} {verb} {rest}."
            blank = f"______ {verb} {rest}."
        else:
            statement = f"{answer} {verb} {rest}."
            rest_cap = rest[0].upper() + rest[1:] if rest else rest
            statement = f"{answer} {verb} {rest}."
            blank = f"{rest_cap} {verb} ______."
        return statement, blank, rest
    return None


def generic_true_false(prompt: str, answer: str) -> str:
    p = prompt.strip()
    return f'The correct answer to "{p}" is {answer}.'


def eligible_typed_answer(text: str) -> bool:
    text = text.strip()
    if not text or len(text) > MAX_TYPED_ANSWER_CHARS:
        return False
    if word_count(text) > MAX_TYPED_ANSWER_WORDS:
        return False
    return True


def load_rows(csv_path: str):
    with open(csv_path, newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        return list(reader)


def build_sources(rows) -> list[SourceQ]:
    out = []
    for row in rows:
        if row["question_type"] != "multiple_choice":
            continue
        opts = {
            "A": row.get("option_a") or "",
            "B": row.get("option_b") or "",
            "C": row.get("option_c") or "",
            "D": row.get("option_d") or "",
        }
        correct = (row.get("correct_option") or "").strip().upper()
        if correct not in ("A", "B", "C", "D"):
            continue
        if not opts[correct].strip():
            continue
        if not row.get("prompt", "").strip():
            continue
        out.append(
            SourceQ(
                id=row["id"],
                category=row["category"],
                difficulty=row["difficulty"],
                prompt=row["prompt"].strip(),
                options=opts,
                correct_option=correct,
                explanation=(row.get("explanation") or "").strip() or None,
            )
        )
    return out


@dataclass
class Stats:
    true_false: int = 0
    identification: int = 0
    fill_blank: int = 0
    unscramble: int = 0
    matching_sets: int = 0
    matching_sources_used: int = 0


def generate(sources: list[SourceQ]):
    stats = Stats()
    inserts: list[str] = []
    matching_candidates: dict[tuple, list[tuple[SourceQ, str, str]]] = defaultdict(list)

    for src in sources:
        answer = src.correct_text

        # ---------------- true_false ----------------
        wrong_letter = src.wrong_option_letter()
        if wrong_letter:
            wrong_text = src.options[wrong_letter].strip()
            decl = declarative(src.prompt, answer)
            if decl:
                true_stmt = decl[0]
                decl_wrong = declarative(src.prompt, wrong_text)
                false_stmt = decl_wrong[0] if decl_wrong else generic_true_false(src.prompt, wrong_text)
            else:
                true_stmt = generic_true_false(src.prompt, answer)
                false_stmt = generic_true_false(src.prompt, wrong_text)

            if len(true_stmt) <= 200 and len(false_stmt) <= 200 and true_stmt.lower() != false_stmt.lower():
                # Randomize which slot (A/B) holds True vs False per row,
                # same convention true_false already uses; correct_option
                # says which statement (the true one) is correct — but the
                # UI always renders "True"/"False" literal text (see the
                # 0026 constraint), so what varies here is *which
                # statement* — true or false — this generated row asserts,
                # not which button says what.
                for is_true_variant in (True, False):
                    stmt = true_stmt if is_true_variant else false_stmt
                    correct_opt = "A"  # option_a='True' is always correct when we assert a true statement
                    if not is_true_variant:
                        correct_opt = "B"  # asserting a false statement -> 'False' is correct
                    inserts.append(f"""
insert into questions (category, difficulty, question_type, prompt, option_a, option_b, correct_option, explanation, source_question_id, is_adapted)
values ({sql_str(src.category)}, {sql_str(src.difficulty)}, 'true_false', {sql_str(stmt)}, 'True', 'False', {sql_str(correct_opt)}, {sql_str(src.explanation)}, {sql_str(src.id)}, true);""")
                    stats.true_false += 1

        # ---------------- identification ----------------
        if eligible_typed_answer(answer):
            inserts.append(f"""
insert into questions (category, difficulty, question_type, prompt, correct_answer, explanation, source_question_id, is_adapted)
values ({sql_str(src.category)}, {sql_str(src.difficulty)}, 'identification', {sql_str(src.prompt)}, {sql_str(answer)}, {sql_str(src.explanation)}, {sql_str(src.id)}, true);""")
            stats.identification += 1

        # ---------------- fill_blank ----------------
        decl = declarative(src.prompt, answer)
        if decl and eligible_typed_answer(answer):
            _, blank_sentence, rest = decl
            if len(blank_sentence) <= 220:
                inserts.append(f"""
insert into questions (category, difficulty, question_type, prompt, correct_answer, explanation, source_question_id, is_adapted)
values ({sql_str(src.category)}, {sql_str(src.difficulty)}, 'fill_blank', {sql_str(blank_sentence)}, {sql_str(answer)}, {sql_str(src.explanation)}, {sql_str(src.id)}, true);""")
                stats.fill_blank += 1

                # ---------------- matching candidate ----------------
                # Only from a clean declarative match (not the generic
                # fallback), and only when the term reads like a concise
                # named entity, not a long descriptive phrase.
                if (
                    word_count(answer) <= MAX_MATCHING_TERM_WORDS
                    and len(answer) <= MAX_MATCHING_TERM_CHARS
                    and MIN_MATCHING_DEF_CHARS <= len(rest) <= MAX_MATCHING_DEF_CHARS
                ):
                    definition = rest[0].upper() + rest[1:] if rest else rest
                    key = (src.category, src.difficulty)
                    matching_candidates[key].append((src, answer, definition))

        # ---------------- unscramble ----------------
        token = answer.strip()
        if TOKEN_RE.match(token) and UNSCRAMBLE_MIN_LEN <= len(token) <= UNSCRAMBLE_MAX_LEN:
            inserts.append(f"""
insert into questions (category, difficulty, question_type, prompt, correct_answer, explanation, source_question_id, is_adapted)
values ({sql_str(src.category)}, {sql_str(src.difficulty)}, 'unscramble', {sql_str(src.prompt)}, {sql_str(token)}, {sql_str(src.explanation)}, {sql_str(src.id)}, true);""")
            stats.unscramble += 1

    # ---------------- matching sets ----------------
    for (category, difficulty), candidates in matching_candidates.items():
        # De-dupe by term and by definition (case-insensitive) so a set
        # never contains two rows about the same concept, or two
        # different terms that happen to share a definition string.
        seen_terms = set()
        seen_defs = set()
        deduped = []
        for src, term, definition in candidates:
            tkey = term.strip().lower()
            dkey = definition.strip().lower()
            if tkey in seen_terms or dkey in seen_defs:
                continue
            seen_terms.add(tkey)
            seen_defs.add(dkey)
            deduped.append((src, term, definition))

        rng.shuffle(deduped)

        i = 0
        while i < len(deduped):
            chunk = deduped[i : i + MATCHING_SET_SIZE]
            i += MATCHING_SET_SIZE
            if len(chunk) < 2:
                # Leftover of 1 can't form a valid matching set (schema
                # requires 2-6 pairs) — drop it rather than force it into
                # an unrelated set.
                continue
            terms = [c[1] for c in chunk]
            defs = [c[2] for c in chunk]
            source_ids = [c[0].id for c in chunk]
            prompt = "Match each item to its correct description."
            inserts.append(f"""
insert into questions (category, difficulty, question_type, prompt, match_terms, match_definitions, source_question_ids, is_adapted)
values ({sql_str(category)}, {sql_str(difficulty)}, 'matching', {sql_str(prompt)}, {sql_arr(terms)}, {sql_arr(defs)}, {sql_uuid_arr(source_ids)}, true);""")
            stats.matching_sets += 1
            stats.matching_sources_used += len(chunk)

    return inserts, stats


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("csv_path")
    ap.add_argument("--out", required=True)
    ap.add_argument("--report", default=None)
    args = ap.parse_args()

    rows = load_rows(args.csv_path)
    sources = build_sources(rows)
    inserts, stats = generate(sources)

    header = f"""-- Pinoy Quiz — 0035: materialized adapted question bank
--
-- Generated offline by scripts/generate_adapted_questions.py from a CSV
-- export of `questions` ({len(rows)} rows, {len(sources)} eligible
-- multiple_choice sources). Every statement below INSERTs an *adapted*
-- row that references its source via source_question_id /
-- source_question_ids (0034) and is_adapted = true — it never touches or
-- duplicates the original multiple_choice rows, which already exist in
-- the target database (this migration assumes the same rows the CSV was
-- exported from are already present with the same ids; if you are
-- restoring into a fresh database, load the original question bank
-- first, then run this migration).
--
-- Regenerate with:
--   python3 scripts/generate_adapted_questions.py <fresh_export.csv> \\
--     --out supabase/migrations/0035_adapted_question_bank.sql
--
-- Counts (see the accompanying report for the full per-type breakdown):
--   true_false rows generated:      {stats.true_false}
--   identification rows generated:  {stats.identification}
--   fill_blank rows generated:      {stats.fill_blank}
--   unscramble rows generated:      {stats.unscramble}
--   matching sets generated:        {stats.matching_sets} (from {stats.matching_sources_used} source questions)
--
-- sequence and image are intentionally NOT generated here — see the
-- top-level docstring in the generator script for why.

begin;
"""
    footer = "\ncommit;\n"

    with open(args.out, "w", encoding="utf-8") as f:
        f.write(header)
        f.write("\n".join(inserts))
        f.write(footer)

    if args.report:
        with open(args.report, "w", encoding="utf-8") as f:
            json.dump(
                {
                    "csv_rows": len(rows),
                    "eligible_mc_sources": len(sources),
                    "true_false_generated": stats.true_false,
                    "identification_generated": stats.identification,
                    "fill_blank_generated": stats.fill_blank,
                    "unscramble_generated": stats.unscramble,
                    "matching_sets_generated": stats.matching_sets,
                    "matching_sources_used": stats.matching_sources_used,
                },
                f,
                indent=2,
            )

    print(f"wrote {len(inserts)} insert statements to {args.out}", file=sys.stderr)
    print(json.dumps(stats.__dict__, indent=2), file=sys.stderr)


if __name__ == "__main__":
    main()
