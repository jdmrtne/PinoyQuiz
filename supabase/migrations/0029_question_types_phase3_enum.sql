-- Pinoy Quiz — 0029: question_type Phase 3 enum value
--
-- Same reasoning as 0027: a new enum value can't be referenced in the
-- same transaction that adds it, so this is split from 0030 which uses it.

alter type question_type add value 'sequence';
