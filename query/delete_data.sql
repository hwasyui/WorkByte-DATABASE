-- Wipe all rows from every table while keeping the schema intact.
-- Safe to run multiple times. Tables are truncated in FK dependency order
-- so no constraint violations occur.

TRUNCATE TABLE
    message,
    contract_embedding,
    job_embedding,
    freelancer_embedding,
    client_trust_score,
    performance_rating,
    rating,
    saved_job,
    contract_milestone,
    portfolio,
    contract,
    proposal_file,
    proposal,
    job_file,
    job_role_skill,
    job_role,
    job_post,
    work_experience,
    education,
    freelancer_language,
    freelancer_speciality,
    freelancer_skill,
    language,
    speciality,
    skill,
    client,
    freelancer,
    users
RESTART IDENTITY CASCADE;
