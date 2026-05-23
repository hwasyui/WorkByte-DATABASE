-- Wipe all rows from every table while keeping the schema intact.
-- Safe to run multiple times. CASCADE handles FK dependencies automatically.

TRUNCATE TABLE
    -- ── Review analysis ───────────────────────────────────────────────────────
    review_ai_analysis,
    review_skill_tags,
    review_written_content,
    review_ratings,
    bias_detection_log,
    red_flag_alerts,
    trust_score_history,
    freelancer_trust_scores,
    freelancer_performance_scores,
    ai_review_prompts,
    reviews,

    -- ── Messaging ─────────────────────────────────────────────────────────────
    dm_message_attachment,
    dm_message,
    dm_thread,

    -- ── Contract submissions ───────────────────────────────────────────────────
    contract_submission_file,
    contract_submission,

    -- ── Embeddings ────────────────────────────────────────────────────────────
    portfolio_embedding,
    contract_embedding,
    job_role_embedding,
    freelancer_embedding,

    -- ── Auth ──────────────────────────────────────────────────────────────────
    email_verification_otps,
    password_reset_otps,
    user_oauth_providers,

    -- ── Admin / moderation ────────────────────────────────────────────────────
    harmful_text_queue,
    scam_job_flags,
    client_scam_record,
    user_reports,
    report_auto_actions,
    appeals,

    -- ── Notifications ─────────────────────────────────────────────────────────
    notifications,

    -- ── Core domain ───────────────────────────────────────────────────────────
    client_trust_score,
    performance_rating,
    rating,
    saved_job,
    contract_terms,
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
    freelancer_speciality,
    freelancer_skill,
    speciality,
    skill,

    -- ── Users ─────────────────────────────────────────────────────────────────
    client,
    freelancer,
    users
RESTART IDENTITY CASCADE;
