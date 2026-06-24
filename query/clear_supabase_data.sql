-- Clear all data that was stored on Supabase storage.
-- Contracts and proposals are deleted entirely so users can redo those actions.
-- Profile pictures, CV URLs, and DM message text are left untouched.
--
-- Cascade rules mean deleting a contract automatically removes:
--   contract_submission, contract_submission_file, contract_embedding,
--   contract_terms, freelancer_performance_scores, rating, reviews,
--   review_ai_analysis, review_ratings, review_skill_tags, review_written_content,
--   bias_detection_log
-- Deleting a proposal automatically removes: proposal_file
--
-- Run order matters: contracts must be deleted before proposals
-- because contract has a RESTRICT FK to proposal.

BEGIN;

-- Preview counts before deletion (uncomment to verify before running)
-- SELECT 'contracts to delete' AS target, COUNT(*) FROM contract
-- WHERE contract_pdf_url LIKE '%supabase.co%'
--    OR contract_id IN (
--        SELECT DISTINCT cs.contract_id FROM contract_submission cs
--        JOIN contract_submission_file csf ON csf.submission_id = cs.submission_id
--        WHERE csf.file_url LIKE '%supabase.co%'
--    );
-- SELECT 'proposals to delete' AS target, COUNT(*) FROM proposal
-- WHERE proposal_id IN (SELECT proposal_id FROM proposal_file WHERE file_url LIKE '%supabase.co%');
-- SELECT 'job files to delete' AS target, COUNT(*) FROM job_file WHERE file_url LIKE '%supabase.co%';
-- SELECT 'dm attachments to delete' AS target, COUNT(*) FROM dm_message_attachment WHERE file_url LIKE '%supabase.co%';
-- SELECT 'message attachments to delete' AS target, COUNT(*) FROM message_attachment WHERE file_url LIKE '%supabase.co%';

-- Step 1: Delete contracts with Supabase PDF or submission files
-- Cascades to: contract_submission, contract_submission_file, contract_embedding,
--              contract_terms, freelancer_performance_scores, rating, reviews and all
--              review child tables, bias_detection_log
-- Sets to NULL: dm_thread.contract_id, portfolio.contract_id
DELETE FROM contract
WHERE contract_pdf_url LIKE '%supabase.co%'
   OR contract_id IN (
       SELECT DISTINCT cs.contract_id
       FROM contract_submission cs
       JOIN contract_submission_file csf ON csf.submission_id = cs.submission_id
       WHERE csf.file_url LIKE '%supabase.co%'
   );

-- Step 2: Delete proposals that have Supabase proposal files
-- Cascades to: proposal_file
DELETE FROM proposal
WHERE proposal_id IN (
    SELECT proposal_id FROM proposal_file
    WHERE file_url LIKE '%supabase.co%'
);

-- Step 3: Delete job file records with Supabase URLs
DELETE FROM job_file
WHERE file_url LIKE '%supabase.co%';

-- Step 4: Delete DM message attachments with Supabase URLs
-- Message text is preserved, only the attachment record is removed
DELETE FROM dm_message_attachment
WHERE file_url LIKE '%supabase.co%';

DELETE FROM message_attachment
WHERE file_url LIKE '%supabase.co%';

-- Step 5: Null out CV file URLs pointing to Supabase
-- (profile pictures are left as-is; users will re-upload)
UPDATE freelancer
SET cv_file_url = NULL
WHERE cv_file_url LIKE '%supabase.co%';

COMMIT;
