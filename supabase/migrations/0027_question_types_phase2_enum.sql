-- Pinoy Quiz — 0027: question_type Phase 2 enum values
--
-- Split into its own migration on purpose: Postgres won't let a new enum
-- value be referenced (in a query, a check constraint, a function body)
-- in the same transaction that added it. Supabase runs each migration
-- file as one transaction, so 0028 (which uses these) has to be a
-- separate file that runs after this one commits.

alter type question_type add value 'unscramble';
alter type question_type add value 'matching';
alter type question_type add value 'image';
