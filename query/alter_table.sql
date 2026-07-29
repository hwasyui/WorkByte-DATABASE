-- Previously applied migrations are commented out below for reference.
-- Re-running this file is safe - all active statements use IF NOT EXISTS / IF EXISTS guards.

-- DROP TABLE IF EXISTS job_milestone CASCADE;
-- DROP TABLE IF EXISTS job_payment CASCADE;
-- ALTER TABLE contract_milestone DROP COLUMN IF EXISTS job_milestone_id;

-- ALTER TABLE freelancer_embedding DROP COLUMN IF EXISTS embedding_vector;
-- ALTER TABLE freelancer_embedding ADD COLUMN embedding_vector VECTOR(768);
-- ALTER TABLE freelancer_embedding ALTER COLUMN source_text DROP NOT NULL;
-- ALTER TABLE freelancer_embedding ADD COLUMN IF NOT EXISTS embedding_dirty BOOLEAN NOT NULL DEFAULT TRUE;

-- ALTER TABLE job_embedding DROP COLUMN IF EXISTS embedding_vector;
-- ALTER TABLE job_embedding ADD COLUMN embedding_vector VECTOR(768);
-- ALTER TABLE job_embedding ALTER COLUMN source_text DROP NOT NULL;
-- ALTER TABLE job_embedding ADD COLUMN IF NOT EXISTS embedding_dirty BOOLEAN NOT NULL DEFAULT TRUE;

-- CREATE INDEX IF NOT EXISTS idx_freelancer_embedding_hnsw
--     ON freelancer_embedding USING hnsw (embedding_vector vector_cosine_ops)
--     WHERE embedding_vector IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_freelancer_embedding_dirty
--     ON freelancer_embedding (embedding_dirty) WHERE embedding_dirty = TRUE;

-- CREATE INDEX IF NOT EXISTS idx_job_embedding_hnsw
--     ON job_embedding USING hnsw (embedding_vector vector_cosine_ops)
--     WHERE embedding_vector IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_job_embedding_dirty
--     ON job_embedding (embedding_dirty) WHERE embedding_dirty = TRUE;

-- CREATE TABLE IF NOT EXISTS contract_embedding (
--     embedding_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     contract_id        UUID NOT NULL UNIQUE,
--     freelancer_id      UUID NOT NULL,
--     embedding_vector   VECTOR(768),
--     source_text        TEXT,
--     embedding_metadata JSONB,
--     embedding_dirty    BOOLEAN NOT NULL DEFAULT TRUE,
--     created_at         TIMESTAMP DEFAULT NOW(),
--     updated_at         TIMESTAMP DEFAULT NOW(),
--     FOREIGN KEY (contract_id)   REFERENCES contract(contract_id)     ON DELETE CASCADE,
--     FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
-- );
-- CREATE OR REPLACE FUNCTION set_contract_embedding_updated_at()
-- RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;
-- DROP TRIGGER IF EXISTS trg_contract_embedding_updated_at ON contract_embedding;
-- CREATE TRIGGER trg_contract_embedding_updated_at
--     BEFORE UPDATE ON contract_embedding
--     FOR EACH ROW EXECUTE FUNCTION set_contract_embedding_updated_at();
-- CREATE INDEX IF NOT EXISTS idx_contract_embedding_hnsw
--     ON contract_embedding USING hnsw (embedding_vector vector_cosine_ops)
--     WHERE embedding_vector IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_contract_embedding_dirty
--     ON contract_embedding (embedding_dirty) WHERE embedding_dirty = TRUE;
-- CREATE INDEX IF NOT EXISTS idx_contract_embedding_freelancer
--     ON contract_embedding (freelancer_id) WHERE embedding_vector IS NOT NULL;

-- ALTER TABLE client RENAME COLUMN total_projects_completed TO total_jobs_completed;
-- ALTER TABLE freelancer RENAME COLUMN total_projects TO total_jobs;

-- ALTER TABLE rating ADD COLUMN IF NOT EXISTS update_count INTEGER DEFAULT 0;
-- ALTER TABLE rating ADD COLUMN IF NOT EXISTS updated_at   TIMESTAMP DEFAULT NOW();

-- ALTER TABLE proposal ADD CONSTRAINT uq_proposal_freelancer_role UNIQUE (freelancer_id, job_role_id);

-- ALTER TABLE contract ADD COLUMN IF NOT EXISTS contract_pdf_url VARCHAR(500);
-- ALTER TABLE contract ADD COLUMN IF NOT EXISTS contract_pdf_generated_at TIMESTAMP;

-- ALTER TABLE contract_milestone ADD COLUMN IF NOT EXISTS client_approved           BOOLEAN DEFAULT FALSE;
-- ALTER TABLE contract_milestone ADD COLUMN IF NOT EXISTS payment_requested         BOOLEAN DEFAULT FALSE;
-- ALTER TABLE contract_milestone ADD COLUMN IF NOT EXISTS payment_released          BOOLEAN DEFAULT FALSE;
-- ALTER TABLE contract_milestone ADD COLUMN IF NOT EXISTS freelancer_confirmed_paid BOOLEAN DEFAULT FALSE;

-- DROP TABLE IF EXISTS contract_milestone CASCADE;
-- DROP TABLE IF EXISTS job_milestone CASCADE;
-- DROP TABLE IF EXISTS job_payment CASCADE;
-- DROP TYPE IF EXISTS milestone_status CASCADE;
-- ALTER TABLE contract_terms ADD COLUMN IF NOT EXISTS payment_schedule TEXT;

-- DROP TABLE IF EXISTS message CASCADE;

-- ALTER TABLE contract ADD COLUMN IF NOT EXISTS cancelled_by         UUID;
-- ALTER TABLE contract ADD COLUMN IF NOT EXISTS cancellation_reason  TEXT;

-- ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified    BOOLEAN NOT NULL DEFAULT FALSE;
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified_at TIMESTAMP;

-- Email/password accounts have this enabled. OAuth-only accounts keep a random
-- password hash for NOT NULL compatibility, but password login remains disabled
-- until the user explicitly sets a password.
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS password_login_enabled BOOLEAN NOT NULL DEFAULT TRUE;

-- CREATE TABLE IF NOT EXISTS email_verification_otps (
    -- otp_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- user_id     UUID NOT NULL,
    -- otp_hash    VARCHAR(255) NOT NULL,
    -- expires_at  TIMESTAMP NOT NULL,
    -- consumed_at TIMESTAMP,
    -- attempts    INTEGER NOT NULL DEFAULT 0,
    -- created_at  TIMESTAMP DEFAULT NOW(),
    -- FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
-- );

-- CREATE INDEX IF NOT EXISTS idx_email_verification_otps_user_active
    -- ON email_verification_otps (user_id, created_at DESC)
    -- WHERE consumed_at IS NULL;

-- Replaces the single `type` column with profile-based capability checks.
-- freelancer/client roles are determined by the existence of a row in the
-- respective profile table. is_admin is a flag for admin-only access.
-- ALTER TABLE users DROP COLUMN IF EXISTS type;
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS is_admin BOOLEAN NOT NULL DEFAULT FALSE;
-- DROP TYPE IF EXISTS user_type;

-- ALTER TYPE rate_time_type ADD VALUE IF NOT EXISTS 'daily';

-- ALTER TABLE client ADD COLUMN IF NOT EXISTS contract_message_template TEXT;

-- Auto-generated portfolio rows (created on contract completion) are NOT
-- embedded here; they're already covered by contract_embedding, which carries
-- the rating + review text and is the authoritative source for completed work.
-- This table holds embeddings for user-curated showcase items only
-- (is_auto_generated = FALSE).
-- CREATE TABLE IF NOT EXISTS portfolio_embedding (
    -- embedding_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- portfolio_id       UUID NOT NULL UNIQUE,
    -- freelancer_id      UUID NOT NULL,
    -- embedding_vector   VECTOR(768),
    -- source_text        TEXT,
    -- embedding_metadata JSONB,
    -- embedding_dirty    BOOLEAN NOT NULL DEFAULT TRUE,
    -- created_at         TIMESTAMP DEFAULT NOW(),
    -- updated_at         TIMESTAMP DEFAULT NOW(),
    -- FOREIGN KEY (portfolio_id)  REFERENCES portfolio(portfolio_id)   ON DELETE CASCADE,
    -- FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
-- );
-- CREATE OR REPLACE FUNCTION set_portfolio_embedding_updated_at()
-- RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;
-- DROP TRIGGER IF EXISTS trg_portfolio_embedding_updated_at ON portfolio_embedding;
-- CREATE TRIGGER trg_portfolio_embedding_updated_at
    -- BEFORE UPDATE ON portfolio_embedding
    -- FOR EACH ROW EXECUTE FUNCTION set_portfolio_embedding_updated_at();
-- CREATE INDEX IF NOT EXISTS idx_portfolio_embedding_hnsw
    -- ON portfolio_embedding USING hnsw (embedding_vector vector_cosine_ops)
    -- WHERE embedding_vector IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_portfolio_embedding_dirty
    -- ON portfolio_embedding (embedding_dirty) WHERE embedding_dirty = TRUE;
-- CREATE INDEX IF NOT EXISTS idx_portfolio_embedding_freelancer
    -- ON portfolio_embedding (freelancer_id) WHERE embedding_vector IS NOT NULL;

-- Contract chats and free DMs both live here.
-- contract_id links a thread to a contract once one is created.
-- status: 'request' → receiver hasn't accepted yet (1-msg cap on initiator)
--         'active'  → both parties can freely exchange messages
--         'declined'→ receiver declined; initiator cannot send more
-- CREATE TABLE IF NOT EXISTS dm_thread (
    -- thread_id      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    -- user_a_id      UUID        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    -- user_b_id      UUID        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    -- initiator_id   UUID        NOT NULL REFERENCES users(user_id),
    -- status         TEXT        NOT NULL DEFAULT 'request',
    -- job_post_id    UUID        REFERENCES job_post(job_post_id) ON DELETE SET NULL,
    -- contract_id    UUID        REFERENCES contract(contract_id) ON DELETE SET NULL,
    -- created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- UNIQUE (user_a_id, user_b_id),
    -- CHECK (user_a_id < user_b_id)
-- );
-- CREATE INDEX IF NOT EXISTS idx_dm_thread_user_a    ON dm_thread (user_a_id);
-- CREATE INDEX IF NOT EXISTS idx_dm_thread_user_b    ON dm_thread (user_b_id);
-- CREATE INDEX IF NOT EXISTS idx_dm_thread_contract  ON dm_thread (contract_id) WHERE contract_id IS NOT NULL;

-- CREATE TABLE IF NOT EXISTS dm_message (
    -- dm_message_id  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    -- thread_id      UUID        NOT NULL REFERENCES dm_thread(thread_id) ON DELETE CASCADE,
    -- sender_id      UUID        NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    -- message_text   TEXT        NOT NULL DEFAULT '',
    -- metadata       TEXT,
    -- is_read        BOOLEAN     NOT NULL DEFAULT FALSE,
    -- read_at        TIMESTAMPTZ,
    -- sent_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );
-- CREATE INDEX IF NOT EXISTS idx_dm_message_thread ON dm_message (thread_id, sent_at DESC);

-- CREATE TABLE IF NOT EXISTS dm_message_attachment (
    -- attachment_id    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    -- dm_message_id    UUID        NOT NULL REFERENCES dm_message(dm_message_id) ON DELETE CASCADE,
    -- file_name        TEXT        NOT NULL,
    -- file_url         TEXT        NOT NULL,
    -- file_type        TEXT        NOT NULL,
    -- mime_type        TEXT        NOT NULL,
    -- file_size_bytes  INTEGER,
    -- duration_seconds FLOAT,
    -- created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );
-- CREATE INDEX IF NOT EXISTS idx_dm_attachment_message ON dm_message_attachment (dm_message_id);

-- CREATE TABLE IF NOT EXISTS contract_terms (
--     contract_terms_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
--     contract_id            UUID NOT NULL UNIQUE,
--     termination_notice     INTEGER,
--     governing_law          VARCHAR(100),
--     confidentiality        BOOLEAN DEFAULT FALSE,
--     confidentiality_text   TEXT,
--     late_payment_penalty   DECIMAL(5, 2),
--     dispute_resolution     VARCHAR(50),
--     revision_rounds        INTEGER,
--     additional_clauses     TEXT,
--     created_at             TIMESTAMP DEFAULT NOW(),
--     FOREIGN KEY (contract_id) REFERENCES contract(contract_id) ON DELETE CASCADE
-- );

-- Drop description column from skill table (unused)
-- ALTER TABLE skill DROP COLUMN IF EXISTS description CASCADE;

-- Add search_tokens column for basic keyword search
-- ALTER TABLE skill
  -- ADD COLUMN IF NOT EXISTS search_tokens TEXT;

-- Drop embedding-related columns (no longer needed)
-- ALTER TABLE skill DROP COLUMN IF EXISTS embedding CASCADE;
-- ALTER TABLE skill DROP COLUMN IF EXISTS embedding_dirty CASCADE;

-- Drop embedding-related indexes
-- DROP INDEX IF EXISTS idx_skill_embedding_vector CASCADE;
-- DROP INDEX IF EXISTS idx_skill_embedding_dirty CASCADE;
-- DROP INDEX IF EXISTS idx_skill_embedding_not_null CASCADE;
-- DROP INDEX IF EXISTS idx_skill_name_trgm CASCADE;
-- DROP INDEX IF EXISTS idx_skill_search_tokens_trgm CASCADE;

-- Holds flagged content (job posts, freelancer/client profiles) pending review.
-- Labels mirror the ML model's output: toxic, severe_toxic, obscene, threat,
-- insult, identity_hate.
-- After 30 days with no admin action:
--   total_score (sum of 6 labels) >= 0.85 (job_post) or >= 0.90 (profile) -> auto-close
--   total_score below threshold -> auto-dismissed as false positive (status = approved)
-- CREATE TABLE IF NOT EXISTS content_moderation_queue (
    -- moderation_id       UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    -- content_type        TEXT      NOT NULL,
    -- content_id          UUID      NOT NULL,
    -- user_id             UUID      NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    -- toxic_score         FLOAT     NOT NULL DEFAULT 0,
    -- severe_toxic_score  FLOAT     NOT NULL DEFAULT 0,
    -- obscene_score       FLOAT     NOT NULL DEFAULT 0,
    -- threat_score        FLOAT     NOT NULL DEFAULT 0,
    -- insult_score        FLOAT     NOT NULL DEFAULT 0,
    -- identity_hate_score FLOAT     NOT NULL DEFAULT 0,
    -- detected_labels     JSONB     NOT NULL DEFAULT '[]',
    -- flagged_text        TEXT,
    -- status              TEXT      NOT NULL DEFAULT 'pending',
    -- admin_user_id       UUID      REFERENCES users(user_id),
    -- admin_note          TEXT,
    -- actioned_at         TIMESTAMP,
    -- auto_approve_at     TIMESTAMP NOT NULL,
    -- created_at          TIMESTAMP DEFAULT NOW()
-- );
-- CREATE INDEX IF NOT EXISTS idx_cmq_status  ON content_moderation_queue (status, created_at DESC);
-- CREATE INDEX IF NOT EXISTS idx_cmq_content ON content_moderation_queue (content_type, content_id);
-- CREATE INDEX IF NOT EXISTS idx_cmq_auto    ON content_moderation_queue (auto_approve_at) WHERE status = 'pending';

-- Keyword-detected scam patterns in job posts. Auto-removed + client flagged
-- when scam_score > 0.85 AND the flag is >30 days old without admin action.
-- CREATE TABLE IF NOT EXISTS scam_job_flags (
    -- flag_id             UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    -- job_post_id         UUID      NOT NULL REFERENCES job_post(job_post_id) ON DELETE CASCADE,
    -- client_id           UUID      NOT NULL REFERENCES client(client_id) ON DELETE CASCADE,
    -- scam_score          FLOAT     NOT NULL,
    -- detected_keywords   JSONB     NOT NULL DEFAULT '[]',
    -- flagged_text        TEXT,
    -- status              TEXT      NOT NULL DEFAULT 'pending',
    -- admin_user_id       UUID      REFERENCES users(user_id),
    -- admin_note          TEXT,
    -- actioned_at         TIMESTAMP,
    -- auto_remove_at      TIMESTAMP NOT NULL,
    -- created_at          TIMESTAMP DEFAULT NOW()
-- );
-- CREATE INDEX IF NOT EXISTS idx_scam_status ON scam_job_flags (status, created_at DESC);
-- CREATE INDEX IF NOT EXISTS idx_scam_client ON scam_job_flags (client_id);
-- CREATE INDEX IF NOT EXISTS idx_scam_auto   ON scam_job_flags (auto_remove_at) WHERE status = 'pending';

-- Tracks confirmed scam jobs per client. Banned automatically after 3 confirmed.
-- CREATE TABLE IF NOT EXISTS client_scam_record (
    -- record_id            UUID     PRIMARY KEY DEFAULT gen_random_uuid(),
    -- client_id            UUID     NOT NULL UNIQUE REFERENCES client(client_id) ON DELETE CASCADE,
    -- total_scam_confirmed INTEGER  NOT NULL DEFAULT 0,
    -- is_banned            BOOLEAN  NOT NULL DEFAULT FALSE,
    -- banned_at            TIMESTAMP,
    -- updated_at           TIMESTAMP DEFAULT NOW()
-- );

-- Any authenticated user can report a freelancer, client profile, or job post.
-- reported_type: 'freelancer' | 'client' | 'job_post'
-- For profile reports: reported_user_id is required, job_post_id is NULL.
-- For job post reports: job_post_id is required, reported_user_id is NULL.
-- Predefined reasons stored as JSONB array; optional free-text custom_reason.
-- CREATE TABLE IF NOT EXISTS user_reports (
    -- report_id           UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    -- reporter_id         UUID      NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    -- reported_user_id    UUID      REFERENCES users(user_id) ON DELETE CASCADE,
    -- job_post_id         UUID      REFERENCES job_post(job_post_id) ON DELETE CASCADE,
    -- reported_type       TEXT      NOT NULL,
    -- reasons             JSONB     NOT NULL DEFAULT '[]',
    -- custom_reason       TEXT,
    -- status              TEXT      NOT NULL DEFAULT 'pending',
    -- admin_user_id       UUID      REFERENCES users(user_id),
    -- admin_note          TEXT,
    -- actioned_at         TIMESTAMP,
    -- created_at          TIMESTAMP DEFAULT NOW(),
    -- CHECK (
        -- (reported_type IN ('freelancer', 'client') AND reported_user_id IS NOT NULL)
        -- OR
        -- (reported_type = 'job_post' AND job_post_id IS NOT NULL)
    -- )
-- );
-- CREATE INDEX IF NOT EXISTS idx_reports_status      ON user_reports (status, created_at DESC);
-- CREATE INDEX IF NOT EXISTS idx_reports_reported    ON user_reports (reported_user_id) WHERE reported_user_id IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_reports_job_post    ON user_reports (job_post_id) WHERE job_post_id IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_reports_reporter    ON user_reports (reporter_id);

-- ALTER TABLE user_reports ADD COLUMN IF NOT EXISTS job_post_id UUID REFERENCES job_post(job_post_id) ON DELETE CASCADE;
-- ALTER TABLE user_reports ALTER COLUMN reported_user_id DROP NOT NULL;

-- When a profile/job post accumulates >=10 reports AND the oldest is >30 days old,
-- the user is report-banned (is_report_banned=TRUE) or the job post is closed.
-- One record per target; prevents double-firing.
-- CREATE TABLE IF NOT EXISTS report_auto_actions (
    -- action_id       UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    -- target_type     TEXT      NOT NULL,
    -- target_id       UUID      NOT NULL,
    -- report_count    INT       NOT NULL,
    -- created_at      TIMESTAMP DEFAULT NOW(),
    -- UNIQUE (target_type, target_id)
-- );
-- CREATE INDEX IF NOT EXISTS idx_raa_target  ON report_auto_actions (target_type, target_id);

-- Add report-ban columns to users (separate from admin manual ban / scam ban)
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS is_report_banned   BOOLEAN   NOT NULL DEFAULT FALSE;
-- ALTER TABLE users ADD COLUMN IF NOT EXISTS report_banned_at   TIMESTAMP;

-- job_post: set when the post is closed by admin or auto-action so the owner
--           can see why and whether to appeal.
-- users: set when a report-threshold ban fires; explains the restriction.
-- ALTER TABLE job_post ADD COLUMN IF NOT EXISTS closure_reason TEXT;
-- ALTER TABLE job_post ADD COLUMN IF NOT EXISTS closure_note   TEXT;
-- ALTER TABLE users    ADD COLUMN IF NOT EXISTS ban_reason     TEXT;
-- ALTER TABLE users    ADD COLUMN IF NOT EXISTS ban_message    TEXT;

-- Users can appeal a ban (target_type='user') or a closed job post
-- (target_type='job_post'). Admin approves -> restores; rejects -> stays closed.
-- CREATE TABLE IF NOT EXISTS appeals (
    -- appeal_id       UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    -- user_id         UUID      NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    -- target_type     TEXT      NOT NULL,
    -- target_id       UUID      NOT NULL,
    -- message         TEXT      NOT NULL,
    -- status          TEXT      NOT NULL DEFAULT 'pending',
    -- admin_user_id   UUID      REFERENCES users(user_id),
    -- admin_note      TEXT,
    -- actioned_at     TIMESTAMP,
    -- created_at      TIMESTAMP DEFAULT NOW()
-- );
-- CREATE INDEX IF NOT EXISTS idx_appeals_user   ON appeals (user_id, created_at DESC);
-- CREATE INDEX IF NOT EXISTS idx_appeals_target ON appeals (target_type, target_id);
-- CREATE INDEX IF NOT EXISTS idx_appeals_status ON appeals (status, created_at DESC);

-- CREATE TABLE IF NOT EXISTS password_reset_otps (
    -- otp_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- user_id     UUID NOT NULL,
    -- otp_hash    VARCHAR(255) NOT NULL,
    -- expires_at  TIMESTAMP NOT NULL,
    -- consumed_at TIMESTAMP,
    -- attempts    INTEGER NOT NULL DEFAULT 0,
    -- created_at  TIMESTAMP DEFAULT NOW(),
    -- FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
-- );

-- CREATE INDEX IF NOT EXISTS idx_password_reset_otps_user_active
    -- ON password_reset_otps (user_id, created_at DESC)
    -- WHERE consumed_at IS NULL;

-- Tracks which OAuth providers a user has connected. One user can have multiple
-- providers (e.g. Google + LinkedIn). Email stays the single identity key across
-- both manual and OAuth sign-ups; the UNIQUE constraint on users.email prevents
-- duplicate accounts.
-- CREATE TABLE IF NOT EXISTS user_oauth_providers (
    -- id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- user_id          UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    -- provider         VARCHAR(50)  NOT NULL,
    -- provider_user_id VARCHAR(255) NOT NULL,
    -- provider_email   VARCHAR(255),
    -- created_at       TIMESTAMP DEFAULT NOW(),
    -- UNIQUE (provider, provider_user_id)
-- );
-- CREATE INDEX IF NOT EXISTS idx_user_oauth_providers_user
    -- ON user_oauth_providers (user_id);

-- auto_closed = TRUE  -> job was auto-closed by ML (hard flag, score >= 0.4)
-- auto_closed = FALSE -> job still active, flagged for admin review (soft flag, score 0.25-0.4)
-- ALTER TABLE scam_job_flags
    -- ADD COLUMN IF NOT EXISTS auto_closed BOOLEAN NOT NULL DEFAULT TRUE;

-- Reflects that the table specifically tracks toxicity label scores (toxic,
-- severe_toxic, obscene, threat, insult, identity_hate), not general moderation.
-- ALTER TABLE content_moderation_queue RENAME TO toxicity_queue;
-- ALTER INDEX IF EXISTS idx_cmq_status  RENAME TO idx_tq_status;
-- ALTER INDEX IF EXISTS idx_cmq_content RENAME TO idx_tq_content;
-- ALTER INDEX IF EXISTS idx_cmq_auto    RENAME TO idx_tq_auto;

-- DROP TABLE IF EXISTS freelancer_language CASCADE;
-- DROP TABLE IF EXISTS language CASCADE;
-- DROP TYPE IF EXISTS proficiency_language CASCADE;

-- ALTER TABLE toxicity_queue DROP COLUMN IF EXISTS severe_toxic_score;

-- ALTER TABLE freelancer ADD COLUMN IF NOT EXISTS title VARCHAR(255);

-- DROP TABLE IF EXISTS freelancer_speciality CASCADE;
-- DROP TABLE IF EXISTS speciality CASCADE;
-- DROP FUNCTION IF EXISTS check_max_specialities() CASCADE;

-- One vector per role so multi-domain posts don't dilute cosine similarity.
-- Stage 1 pgvector search now deduplicates back to job_post via DISTINCT ON.
-- DROP TABLE IF EXISTS job_embedding CASCADE;

-- CREATE TABLE IF NOT EXISTS job_role_embedding (
    -- embedding_id       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    -- job_role_id        UUID        NOT NULL UNIQUE REFERENCES job_role(job_role_id) ON DELETE CASCADE,
    -- job_post_id        UUID        NOT NULL REFERENCES job_post(job_post_id) ON DELETE CASCADE,
    -- embedding_vector   VECTOR(768),
    -- source_text        TEXT,
    -- embedding_metadata JSONB,
    -- embedding_dirty    BOOLEAN     NOT NULL DEFAULT TRUE,
    -- created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- updated_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
-- );

-- CREATE OR REPLACE FUNCTION set_job_role_embedding_updated_at()
-- RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;
-- DROP TRIGGER IF EXISTS trg_job_role_embedding_updated_at ON job_role_embedding;
-- CREATE TRIGGER trg_job_role_embedding_updated_at
    -- BEFORE UPDATE ON job_role_embedding
    -- FOR EACH ROW EXECUTE FUNCTION set_job_role_embedding_updated_at();

-- CREATE INDEX IF NOT EXISTS idx_job_role_embedding_hnsw
    -- ON job_role_embedding USING hnsw (embedding_vector vector_cosine_ops)
    -- WHERE embedding_vector IS NOT NULL;
-- CREATE INDEX IF NOT EXISTS idx_job_role_embedding_dirty
    -- ON job_role_embedding (embedding_dirty) WHERE embedding_dirty = TRUE;
-- CREATE INDEX IF NOT EXISTS idx_job_role_embedding_job_post
    -- ON job_role_embedding (job_post_id);

-- Seed dirty placeholder rows for every existing job_role so sweep regenerates all embeddings.
-- Vectors are NOT copied from the old job_embedding (wrong granularity); sweep will compute fresh ones.
-- INSERT INTO job_role_embedding (job_role_id, job_post_id, embedding_dirty)
-- SELECT jr.job_role_id, jr.job_post_id, TRUE
-- FROM job_role jr
-- ON CONFLICT (job_role_id) DO NOTHING;

-- Opaque tokens (SHA-256 hashed) for mobile session persistence.
-- Token rotation: each use revokes the old token and issues a new one.
-- Revoked/expired rows are kept for 90 days for audit, then prunable.
-- CREATE TABLE IF NOT EXISTS refresh_tokens (
    -- token_id    UUID      PRIMARY KEY DEFAULT gen_random_uuid(),
    -- user_id     UUID      NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    -- token_hash  CHAR(64)  NOT NULL,
    -- expires_at  TIMESTAMP NOT NULL,
    -- revoked_at  TIMESTAMP,
    -- created_at  TIMESTAMP DEFAULT NOW()
-- );
-- CREATE INDEX IF NOT EXISTS idx_refresh_tokens_hash
    -- ON refresh_tokens (token_hash) WHERE revoked_at IS NULL;
-- CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user
    -- ON refresh_tokens (user_id);

-- ALTER TABLE IF EXISTS toxicity_queue RENAME TO harmful_text_queue;

-- Pre-filtered ANN: metadata columns on job_role_embedding
-- Denormalizes stable job attributes from job_post/job_role so the /relevant
-- query can apply metadata filters before computing cosine similarity,
-- reducing the candidate set without extra joins inside the similarity CTE.
-- ALTER TABLE job_role_embedding ADD COLUMN IF NOT EXISTS meta_experience_level VARCHAR(50);
-- ALTER TABLE job_role_embedding ADD COLUMN IF NOT EXISTS meta_role_budget      NUMERIC(15, 2);
-- CREATE INDEX IF NOT EXISTS idx_jre_meta_exp_level ON job_role_embedding (meta_experience_level) WHERE embedding_vector IS NOT NULL;

-- Re-dirty all job role embeddings to repopulate new metadata columns and re-embed
-- with restructured source text (required skills now lead immediately after title/role).
-- UPDATE job_role_embedding SET embedding_dirty = TRUE WHERE embedding_vector IS NOT NULL;

-- Re-dirty all query-side embeddings (freelancer, contract, portfolio) to re-embed
-- with search_query: prefix for correct asymmetric retrieval against job role
-- search_document: vectors.
-- UPDATE freelancer_embedding SET embedding_dirty = TRUE WHERE embedding_vector IS NOT NULL;
-- UPDATE contract_embedding   SET embedding_dirty = TRUE WHERE embedding_vector IS NOT NULL;
-- UPDATE portfolio_embedding  SET embedding_dirty = TRUE WHERE embedding_vector IS NOT NULL;

-- toxicity_queue is a dead legacy table (renamed origin of harmful_text_queue).
-- The backend exclusively uses harmful_text_queue; toxicity_queue is safe to drop.
-- DROP TABLE IF EXISTS toxicity_queue CASCADE;

-- Legacy table from before the DM system was built; messages table no longer exists.
-- DROP TABLE IF EXISTS message_attachment CASCADE;

-- Dev-era table, never used in production.
-- DROP TABLE IF EXISTS testing_table CASCADE;

-- DROP TABLE IF EXISTS portfolio_skill CASCADE;

-- proposal moderation moves to post-moderation: row stays, edited in place, cycles through this status
-- ALTER TABLE proposal ADD COLUMN IF NOT EXISTS moderation_status TEXT NOT NULL DEFAULT 'visible';
-- ALTER TABLE proposal ADD COLUMN IF NOT EXISTS scanned_at TIMESTAMPTZ;
-- ALTER TABLE proposal ADD CONSTRAINT proposal_moderation_status_check
    -- CHECK (moderation_status IN ('scanning', 'visible', 'blocked'));

-- meta_experience_level/meta_role_budget on job_role_embedding were scaffolded for a
-- pre-filtered ANN design on /job-posts/relevant (filter candidate roles by experience/budget
-- before running cosine similarity). Confirmed via code audit that nothing ever reads either
-- column - /job-posts/relevant only pre-filters on status/category. Dropping as dead weight;
-- no other embedding table (freelancer_embedding, contract_embedding, portfolio_embedding)
-- carries anything like this, so it wasn't a general schema pattern either.
-- DROP INDEX IF EXISTS idx_jre_meta_exp_level;
-- ALTER TABLE job_role_embedding DROP COLUMN IF EXISTS meta_experience_level;
-- ALTER TABLE job_role_embedding DROP COLUMN IF EXISTS meta_role_budget;

-- Job posts and profile sub-entities (portfolio, work_experience, education) move onto the
-- same scanning -> visible | blocked instant-block pattern proposals already use, replacing
-- the old pre-moderation-queue + held_active_contract design for job_post content flags.
-- Added with DEFAULT 'visible' first so existing rows backfill safely (they were already
-- live under the old system), then flipped the column default to 'scanning' for new rows
-- going forward, so a create path that forgets to set it explicitly fails closed (hidden
-- until scanned) instead of failing open like a plain 'visible' default would.
-- portfolio already had moderation_status/scanned_at from an earlier pass; only its default
-- needed aligning to 'scanning'.
-- ALTER TABLE work_experience ADD COLUMN IF NOT EXISTS moderation_status TEXT NOT NULL DEFAULT 'visible';
-- ALTER TABLE work_experience ADD COLUMN IF NOT EXISTS scanned_at TIMESTAMPTZ;
-- ALTER TABLE work_experience ADD CONSTRAINT work_experience_moderation_status_check
    -- CHECK (moderation_status IN ('scanning', 'visible', 'blocked'));
-- ALTER TABLE work_experience ALTER COLUMN moderation_status SET DEFAULT 'scanning';

-- ALTER TABLE education ADD COLUMN IF NOT EXISTS moderation_status TEXT NOT NULL DEFAULT 'visible';
-- ALTER TABLE education ADD COLUMN IF NOT EXISTS scanned_at TIMESTAMPTZ;
-- ALTER TABLE education ADD CONSTRAINT education_moderation_status_check
    -- CHECK (moderation_status IN ('scanning', 'visible', 'blocked'));
-- ALTER TABLE education ALTER COLUMN moderation_status SET DEFAULT 'scanning';

-- ALTER TABLE job_post ADD COLUMN IF NOT EXISTS moderation_status TEXT NOT NULL DEFAULT 'visible';
-- ALTER TABLE job_post ADD COLUMN IF NOT EXISTS scanned_at TIMESTAMPTZ;
-- ALTER TABLE job_post ADD CONSTRAINT job_post_moderation_status_check
    -- CHECK (moderation_status IN ('scanning', 'visible', 'blocked'));
-- ALTER TABLE job_post ALTER COLUMN moderation_status SET DEFAULT 'scanning';

-- ALTER TABLE portfolio ALTER COLUMN moderation_status SET DEFAULT 'scanning';

-- Self-delete must not destroy the *other* party's DM history. user_a_id/user_b_id/
-- initiator_id/sender_id move from ON DELETE CASCADE to ON DELETE SET NULL (and become
-- nullable) - deleting one user anonymizes their side of a thread/message instead of
-- wiping the row. Application code (UserFunctions.delete_user) then checks, per thread,
-- whether the *other* side is already NULL (i.e. that participant was deleted earlier)
-- and only then purges the thread outright. UNIQUE(user_a_id, user_b_id) and
-- CHECK(user_a_id < user_b_id) both still hold with NULLs (NULL <> NULL for uniqueness,
-- and a NULL comparison satisfies a CHECK) - verified, no constraint changes needed there.
-- ALTER TABLE dm_thread ALTER COLUMN user_a_id DROP NOT NULL;
-- ALTER TABLE dm_thread ALTER COLUMN user_b_id DROP NOT NULL;
-- ALTER TABLE dm_thread ALTER COLUMN initiator_id DROP NOT NULL;
-- ALTER TABLE dm_message ALTER COLUMN sender_id DROP NOT NULL;

-- ALTER TABLE dm_thread DROP CONSTRAINT dm_thread_user_a_id_fkey;
-- ALTER TABLE dm_thread ADD CONSTRAINT dm_thread_user_a_id_fkey
    -- FOREIGN KEY (user_a_id) REFERENCES users(user_id) ON DELETE SET NULL;

-- ALTER TABLE dm_thread DROP CONSTRAINT dm_thread_user_b_id_fkey;
-- ALTER TABLE dm_thread ADD CONSTRAINT dm_thread_user_b_id_fkey
    -- FOREIGN KEY (user_b_id) REFERENCES users(user_id) ON DELETE SET NULL;

-- initiator_id previously had no ON DELETE clause at all (defaulted to blocking NO
-- ACTION) - harmless only because it's always a subset of {user_a_id, user_b_id} and
-- those used to CASCADE the row away first. Once those stop cascading, this needed the
-- same SET NULL treatment or every self-delete that ever initiated a thread would throw.
-- ALTER TABLE dm_thread DROP CONSTRAINT dm_thread_initiator_id_fkey;
-- ALTER TABLE dm_thread ADD CONSTRAINT dm_thread_initiator_id_fkey
    -- FOREIGN KEY (initiator_id) REFERENCES users(user_id) ON DELETE SET NULL;

-- ALTER TABLE dm_message DROP CONSTRAINT dm_message_sender_id_fkey;
-- ALTER TABLE dm_message ADD CONSTRAINT dm_message_sender_id_fkey
    -- FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE SET NULL;

-- harmful_text_queue's pending/approved/rejected + 30-day auto_approve_at workflow was
-- pure theater by this point: neither the automatic 30-day sweep nor the manual admin
-- approve/reject button gated any real action anymore (job_post/portfolio/education/
-- work_experience/proposal all already get their real consequence - instant visibility
-- gating - through their own dedicated mechanisms; the one place "approve" still did
-- something, closing a job post, was a verbatim duplicate of the already-existing
-- admin_close_job()). Collapsed to a plain audit trail: reviewed_at (nullable) replaces
-- the whole status/auto_approve_at machinery - NULL means unreviewed, a timestamp means
-- an admin looked at it and optionally left admin_note. No column drives any action.
-- DROP INDEX IF EXISTS idx_tq_auto;
-- DROP INDEX IF EXISTS idx_tq_status;
-- ALTER TABLE harmful_text_queue DROP COLUMN status;
-- ALTER TABLE harmful_text_queue DROP COLUMN auto_approve_at;
-- ALTER TABLE harmful_text_queue RENAME COLUMN actioned_at TO reviewed_at;
-- CREATE INDEX idx_tq_reviewed ON harmful_text_queue (reviewed_at) WHERE reviewed_at IS NULL;

-- Found by the walkthrough after the change above: harmful_text_queue.admin_user_id had
-- no ON DELETE clause at all (defaulted to blocking NO ACTION), so an admin who ever
-- reviewed even one item could never delete their own account afterward - the exact
-- same class of bug as gap #1 (self-delete blocked by an unhandled RESTRICT), just on a
-- different table. Fixed the same way as the DM anonymize work: the audit trail should
-- outlive the specific admin's account, so it survives with admin_user_id set to NULL
-- rather than blocking the delete or cascading the audit rows away.
-- ALTER TABLE harmful_text_queue DROP CONSTRAINT content_moderation_queue_admin_user_id_fkey;
-- ALTER TABLE harmful_text_queue ADD CONSTRAINT content_moderation_queue_admin_user_id_fkey
    -- FOREIGN KEY (admin_user_id) REFERENCES users(user_id) ON DELETE SET NULL;

-- Async-scanned content (education, work_experience, portfolio, job_post, proposal) had
-- moderation_status/scanned_at but nowhere on the entity itself to see WHY it was
-- blocked - detected_labels only ever existed transiently in the notification body text
-- and in harmful_text_queue (admin-only, via GET /admin/moderation). A freelancer who
-- missed/dismissed the notification and reopened their profile later saw
-- moderation_status='blocked' with zero indication of what to fix. Adds the same raw
-- label keys (toxic/obscene/threat/insult/identity_hate) the scanner already returns and
-- harmful_text_queue already stores, directly onto the entity so every relevant route
-- returns it, matching harmful_text_queue's own JSONB shape (scam_job_flags.detected_keywords
-- is the precedent for this pattern on this codebase). Sync-reject fields (bio/full_name/
-- title/skill_name/DM messages) don't need this - nothing is ever saved when they're
-- flagged, so the label just rides along in that request's own error response
-- (ResponseSchema.error's new `extra` param) instead of needing a column anywhere.
ALTER TABLE work_experience ADD COLUMN IF NOT EXISTS detected_labels JSONB NOT NULL DEFAULT '[]';
ALTER TABLE education       ADD COLUMN IF NOT EXISTS detected_labels JSONB NOT NULL DEFAULT '[]';
ALTER TABLE job_post        ADD COLUMN IF NOT EXISTS detected_labels JSONB NOT NULL DEFAULT '[]';
ALTER TABLE proposal        ADD COLUMN IF NOT EXISTS detected_labels JSONB NOT NULL DEFAULT '[]';
ALTER TABLE portfolio       ADD COLUMN IF NOT EXISTS detected_labels JSONB NOT NULL DEFAULT '[]';

-- skill.search_tokens (fed only by SkillCreate.description) was dead weight end to end:
-- the frontend's actual "add skill" UI never sent a description (only the standalone
-- SkillModel carried the field for display), and the read side never worked either -
-- SkillResponse expected a key literally named `description`, but the DB column was
-- `search_tokens`, so it always deserialized to None regardless of what was stored. Only
-- SkillFunctions.search_skills_autocomplete's ILIKE clause ever read the raw column, and
-- since nothing ever populated it through the app, that clause never matched anything in
-- practice either. Removed end to end (schema, create/update/search functions, this
-- column) rather than scanned - found unscanned during the 2026-07-11 full-field audit
-- (HARMFUL_TEXT.md), and simpler to delete a feature nothing used than to defend it.
ALTER TABLE skill DROP COLUMN IF EXISTS search_tokens;

-- Schema-file drift audit (2026-07-11): "does create_table.sql/alter_table.sql actually
-- mirror the live DB?" - answer was no, for two tables/columns that were evidently created
-- live at some point but never written back to these tracked files. Found by diffing
-- information_schema.columns against a parse of both files; both gaps below were already
-- live and already in active use by the backend, so this is a documentation-catch-up on
-- the tracked schema, not a live migration - create_table.sql now has both inline too, so
-- a fresh clone + create_table.sql produces the same schema this ALTER would.

-- job_fit_analysis_usage (the daily per-freelancer job-fit-analysis rate limit, §1.5 of
-- ASW_contributions.md) existed live with no CREATE TABLE anywhere in this file.
CREATE TABLE IF NOT EXISTS job_fit_analysis_usage (
    usage_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id  UUID NOT NULL,
    usage_date     DATE NOT NULL DEFAULT CURRENT_DATE,
    request_count  INTEGER NOT NULL DEFAULT 0,
    created_at     TIMESTAMP DEFAULT NOW(),
    updated_at     TIMESTAMP DEFAULT NOW(),
    UNIQUE (freelancer_id, usage_date),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_job_fit_analysis_usage_updated_at
    BEFORE UPDATE ON job_fit_analysis_usage
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_job_fit_usage_lookup
    ON job_fit_analysis_usage (freelancer_id, usage_date);

-- appeals.proof_file_url existed live and is actively written by admin_functions.py's
-- create_appeal (the ban-appeal proof-file upload flow, admin_routes.py) but was missing
-- from the appeals table definition.
ALTER TABLE appeals ADD COLUMN IF NOT EXISTS proof_file_url VARCHAR(500);

-- work_experience/education/portfolio.moderation_status/scanned_at/detected_labels are dead
-- schema: no code references any of the three columns on any of these tables anywhere in
-- routes/. Every row's moderation_status sat frozen at its 'scanning' default forever, since
-- nothing ever transitioned it. Removed to match what's actually running rather than leave
-- inert columns describing a scan pipeline this codebase doesn't have wired up.
ALTER TABLE work_experience DROP CONSTRAINT IF EXISTS work_experience_moderation_status_check;
ALTER TABLE work_experience DROP COLUMN IF EXISTS moderation_status;
ALTER TABLE work_experience DROP COLUMN IF EXISTS scanned_at;
ALTER TABLE work_experience DROP COLUMN IF EXISTS detected_labels;

ALTER TABLE education DROP CONSTRAINT IF EXISTS education_moderation_status_check;
ALTER TABLE education DROP COLUMN IF EXISTS moderation_status;
ALTER TABLE education DROP COLUMN IF EXISTS scanned_at;
ALTER TABLE education DROP COLUMN IF EXISTS detected_labels;

ALTER TABLE portfolio DROP CONSTRAINT IF EXISTS portfolio_moderation_status_check;
ALTER TABLE portfolio DROP COLUMN IF EXISTS moderation_status;
ALTER TABLE portfolio DROP COLUMN IF EXISTS scanned_at;
ALTER TABLE portfolio DROP COLUMN IF EXISTS detected_labels;

-- job_post/proposal.moderation_status/scanned_at/detected_labels are dead schema too, for the
-- same reason as work_experience/education/portfolio above: no code in routes/job_posts/ or
-- routes/proposals/ reads or writes any of the three on either table. Real moderation for
-- both lives entirely outside these columns -- job_post's scan result goes into
-- harmful_text_queue (its own toxic_score/detected_labels/status, checked by the 30-day
-- sweep), and proposal is sync-reject-outright, so a flagged cover letter is never persisted
-- in the first place and a clean one never needs a scan result recorded on it afterward.
-- Neither JobPostResponse nor ProposalResponse (schema_model.py) even declares these fields.
ALTER TABLE job_post DROP CONSTRAINT IF EXISTS job_post_moderation_status_check;
ALTER TABLE job_post DROP COLUMN IF EXISTS moderation_status;
ALTER TABLE job_post DROP COLUMN IF EXISTS scanned_at;
ALTER TABLE job_post DROP COLUMN IF EXISTS detected_labels;

ALTER TABLE proposal DROP CONSTRAINT IF EXISTS proposal_moderation_status_check;
ALTER TABLE proposal DROP COLUMN IF EXISTS moderation_status;
ALTER TABLE proposal DROP COLUMN IF EXISTS scanned_at;
ALTER TABLE proposal DROP COLUMN IF EXISTS detected_labels;

-- Added to support the three trained review-analysis models (authenticity
-- classifier, sentiment-rating mismatch regressor, sentiment classifier) and
-- the reworked trust score formula that uses them as named weighted inputs
-- instead of an invisible gate. See ai_related/review_analysis/review_ml/.

-- Continuous mismatch severity (|predicted_rating - actual_rating| from the
-- mismatch model), alongside the existing boolean sentiment_mismatch, so the
-- trust score's "consistency" component can average a real magnitude
-- instead of just a fraction of true/false flags.
ALTER TABLE review_ai_analysis ADD COLUMN IF NOT EXISTS mismatch_severity NUMERIC;

-- Trust score breakdown components: on_time_score was already computed per
-- contract but never aggregated/stored at the trust-score level; authenticity
-- and consistency are new, computed from the trained models above.
ALTER TABLE freelancer_trust_scores ADD COLUMN IF NOT EXISTS on_time_score NUMERIC;
ALTER TABLE freelancer_trust_scores ADD COLUMN IF NOT EXISTS authenticity_confidence NUMERIC;
ALTER TABLE freelancer_trust_scores ADD COLUMN IF NOT EXISTS consistency_score NUMERIC;

-- Freelancer-reviews-client system: symmetric counterpart to the reviews/
-- review_ratings/review_written_content/review_ai_analysis tables, so a
-- freelancer can review the client they worked for after contract completion.
-- No payment tracking exists on this platform, so trust-score inputs are
-- limited to what's actually observable: review text/ratings, DM
-- responsiveness, and dispute-arbitration fairness.

CREATE TABLE IF NOT EXISTS client_reviews (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id  UUID NOT NULL REFERENCES contract(contract_id) ON DELETE CASCADE,
    reviewer_id  UUID NOT NULL,  -- freelancer's user_id (the one writing the review)
    client_id    UUID NOT NULL,  -- client's user_id (being reviewed)
    status       VARCHAR(20) NOT NULL DEFAULT 'pending',  -- pending | published | flagged | suppressed
    is_anonymous BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMP DEFAULT NOW(),
    published_at TIMESTAMP,
    UNIQUE (contract_id)
);

CREATE TABLE IF NOT EXISTS client_review_ratings (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_review_id  UUID NOT NULL REFERENCES client_reviews(id) ON DELETE CASCADE,
    category          VARCHAR(50) NOT NULL,  -- communication | clarity_of_requirements | responsiveness | professionalism
    score             NUMERIC NOT NULL
);

CREATE TABLE IF NOT EXISTS client_review_written_content (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_review_id  UUID NOT NULL REFERENCES client_reviews(id) ON DELETE CASCADE,
    ai_question       TEXT,
    freelancer_answer TEXT,
    overall_comment   TEXT
);

CREATE TABLE IF NOT EXISTS client_review_ai_analysis (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_review_id    UUID NOT NULL REFERENCES client_reviews(id) ON DELETE CASCADE,
    sentiment_score     NUMERIC,
    sentiment_label     VARCHAR(20),
    sentiment_mismatch  BOOLEAN DEFAULT FALSE,
    mismatch_severity   NUMERIC,
    authenticity_score  NUMERIC,
    is_flagged_fake     BOOLEAN DEFAULT FALSE,
    is_flagged_coerced  BOOLEAN DEFAULT FALSE,
    flag_reasons        JSONB DEFAULT '[]',
    bias_score          NUMERIC,
    bias_flags          JSONB DEFAULT '{}',
    overall_pass        BOOLEAN DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_client_reviews_client_id ON client_reviews (client_id);

-- client_trust_score already existed (rating_consistency_score/extreme_rating_ratio/
-- total_ratings_given track the client's quality AS A RATER of freelancers - untouched
-- here). These new columns are the symmetric counterpart: the client's own reputation
-- as reviewed BY freelancers. trust_score itself is repurposed as the composite output
-- (it was previously a dormant manually-set field with no calculation engine behind it).
ALTER TABLE client_trust_score ADD COLUMN IF NOT EXISTS weighted_review_avg_received NUMERIC;
ALTER TABLE client_trust_score ADD COLUMN IF NOT EXISTS total_reviews_received INTEGER DEFAULT 0;
ALTER TABLE client_trust_score ADD COLUMN IF NOT EXISTS responsiveness_score NUMERIC;
ALTER TABLE client_trust_score ADD COLUMN IF NOT EXISTS communication_sentiment NUMERIC;
ALTER TABLE client_trust_score ADD COLUMN IF NOT EXISTS authenticity_confidence NUMERIC;
ALTER TABLE client_trust_score ADD COLUMN IF NOT EXISTS consistency_score NUMERIC;
ALTER TABLE client_trust_score ADD COLUMN IF NOT EXISTS dispute_fairness_score NUMERIC;

-- Correction to the above: the comment claimed client_id stays client.client_id-keyed,
-- but client_review_pipeline.py's upsert_client_trust_score/get_client_trust_score
-- actually key it by the client's user_id (resolved via client_reviews.client_id,
-- itself a user_id - see client_reviews' own column comment above), matching
-- freelancer_trust_scores' existing user_id-keyed FK. The original FK still pointed
-- at client(client_id), so every upsert for a client without a coincidentally-matching
-- client_id-as-user_id row violated the FK and was silently dropped by the pipeline's
-- outer try/except - trust scores never actually persisted. The pre-existing
-- rating-consistency columns (populated only via the standalone, frontend-unreachable
-- /client-trust-scores CRUD API - never auto-computed) are unaffected by this repoint.
ALTER TABLE client_trust_score DROP CONSTRAINT IF EXISTS client_trust_score_client_id_fkey;
ALTER TABLE client_trust_score ADD CONSTRAINT client_trust_score_client_id_fkey
    FOREIGN KEY (client_id) REFERENCES users(user_id) ON DELETE CASCADE;

-- red_flag_alerts previously only ever meant "freelancer_id"; reused generically for
-- clients too rather than duplicating the whole table, since the column is really just
-- "subject's user_id". Existing rows default to 'freelancer' so nothing already relying
-- on this table changes meaning.
ALTER TABLE red_flag_alerts ADD COLUMN IF NOT EXISTS subject_type VARCHAR(20) NOT NULL DEFAULT 'freelancer';

-- Bias detection removed from both review pipelines: it was a single-LLM self-report
-- with no ground truth to evaluate against - name_bias needs a comparison baseline
-- across a reviewer's full history to mean anything, not a per-review guess, and
-- rating_vs_performance_inconsistency was already redundant with on_time_score/
-- revision_rate_score/responsiveness_score independently feeding the trust score.
-- client_review_ai_analysis.bias_score/bias_flags were never populated by the
-- freelancer-reviews-client pipeline in the first place (always 0.0/{}). All backend
-- code that read/wrote these columns (routes/reviews/review_functions.py,
-- routes/client_reviews/client_review_functions.py, both *_pipeline.py files) has
-- already been updated to stop referencing them - this migration must not run before
-- that code is deployed, or the still-live INSERTs would fail on the dropped columns.
ALTER TABLE review_ai_analysis DROP COLUMN IF EXISTS bias_score;
ALTER TABLE review_ai_analysis DROP COLUMN IF EXISTS bias_flags;
ALTER TABLE client_review_ai_analysis DROP COLUMN IF EXISTS bias_score;
ALTER TABLE client_review_ai_analysis DROP COLUMN IF EXISTS bias_flags;

-- bias_detection_log was write-only (see review_pipeline.py's old "Log significant
-- bias for manual review" block, now removed) - confirmed nothing anywhere ever
-- read from this table before dropping it.
DROP TABLE IF EXISTS bias_detection_log;

-- AI-generated profile-level review summary (generate_freelancer_review_summary,
-- ai_related/review_analysis/review_ai_functions.py): synthesizes a freelancer's
-- PUBLISHED reviews into a short profile blurb, regenerated every
-- SUMMARY_REGEN_INTERVAL published reviews (3, 8, 13...) rather than on every
-- single publish. Nullable with no default - stays NULL until a freelancer
-- crosses MIN_REVIEWS_FOR_SUMMARY.
ALTER TABLE freelancer_trust_scores ADD COLUMN IF NOT EXISTS ai_review_summary TEXT;
ALTER TABLE freelancer_trust_scores ADD COLUMN IF NOT EXISTS ai_review_summary_updated_at TIMESTAMPTZ;

-- Symmetric client-side counterpart (generate_client_review_summary,
-- ai_related/review_analysis/client_review_ai_functions.py), same cadence.
-- No companion _updated_at column needed here - client_trust_score already
-- has an auto-maintained updated_at via trg_client_trust_score_updated_at.
ALTER TABLE client_trust_score ADD COLUMN IF NOT EXISTS ai_review_summary TEXT;

-- harmful_text_queue was missing status/auto_approve_at/actioned_at entirely at the currently-pinned
-- backend commit -- confirmed live: GET /admin/moderation 500'd with "column status does not exist"
-- the moment _auto_approve_expired() ran. admin_functions.py's whole 30-day sweep
-- (queue_harmful_text_scan's INSERT ... auto_approve_at, _auto_approve_expired()'s SELECT/UPDATE,
-- action_moderation_item()'s UPDATE) depends on all three columns; without them the entire
-- moderation-queue read path throws on every call, not just the sweep. reviewed_at (the column that
-- was here instead) is genuinely dead -- confirmed zero SQL references anywhere in the backend, only
-- a stale Pydantic type hint (functions/schema_model.py) -- dropped along with its now-pointless index.
ALTER TABLE harmful_text_queue DROP COLUMN IF EXISTS reviewed_at;
DROP INDEX IF EXISTS idx_htq_reviewed;

ALTER TABLE harmful_text_queue ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'pending';
ALTER TABLE harmful_text_queue ADD CONSTRAINT harmful_text_queue_status_check
    CHECK (status IN ('pending', 'approved', 'rejected'));
ALTER TABLE harmful_text_queue ADD COLUMN IF NOT EXISTS auto_approve_at TIMESTAMP;
ALTER TABLE harmful_text_queue ADD COLUMN IF NOT EXISTS actioned_at TIMESTAMP;
CREATE INDEX IF NOT EXISTS idx_htq_status ON harmful_text_queue (status) WHERE status = 'pending';

-- Duplicate pending scans found live: queue_harmful_text_scan() did an unconditional INSERT
-- with no check for an already-pending row on the same content, and idx_htq_content was a
-- plain (non-unique) index. Confirmed in the AI Analysis admin page: 2 job posts had 12 and 13
-- duplicate pending rows apiece (identical scores, identical flagged_text) -- the frontend was
-- faithfully rendering what the DB had, not a rendering bug. Most likely cause: repeated manual
-- calls to the now-removed POST /admin/moderation/scan admin utility during earlier testing,
-- since the only automatic call site (job_post_routes.py create_job_post) fires exactly once
-- per job post. A partial unique index enforces at most one pending row per
-- (content_type, content_id) at the DB level -- paired with ON CONFLICT DO NOTHING on the
-- INSERT in queue_harmful_text_scan(), this also closes the race between two concurrent scans
-- of the same content, not just the no-check case.
CREATE UNIQUE INDEX IF NOT EXISTS idx_htq_content_pending_unique
    ON harmful_text_queue (content_type, content_id) WHERE status = 'pending';

-- rating & performance_rating dropped -- the freelancer rating/performance flow is no longer
-- used (superseded by the reviews / freelancer_performance_scores tables). Both were empty and
-- nothing references them. Removed from create_table.sql as well so a fresh rebuild omits them.
DROP TABLE IF EXISTS rating CASCADE;
DROP TABLE IF EXISTS performance_rating CASCADE;

-- proposal.job_role_id was UUID NULL with FK ON DELETE SET NULL, but a proposal is required
-- to target a specific role at create time (app-enforced). The SET NULL left orphan rows that
-- violated that invariant whenever a role was deleted. After purging the only null-role rows
-- (all walkthrough/test data), tightened the DB to match: role is mandatory, and deleting a
-- role now cascades to its proposals. A role whose proposal already has a contract stays
-- undeletable via contract -> proposal RESTRICT. The old partial unique index that only
-- applied to NULL roles is dead and dropped.
ALTER TABLE proposal DROP CONSTRAINT IF EXISTS proposal_job_role_id_fkey;
ALTER TABLE proposal ADD  CONSTRAINT proposal_job_role_id_fkey
      FOREIGN KEY (job_role_id) REFERENCES job_role(job_role_id) ON DELETE CASCADE;
ALTER TABLE proposal ALTER COLUMN job_role_id SET NOT NULL;
DROP INDEX IF EXISTS proposal_freelancer_job_post_null_role_uniq;


-- ============================================================================
-- Review subsystem: key on profile IDs, not users.user_id
-- ============================================================================
-- The review/trust tables were the only place in the schema where a column
-- named freelancer_id/client_id held a users.user_id instead of a
-- freelancer.freelancer_id / client.client_id. Everywhere else (contract,
-- proposal, job_post, portfolio, saved_job, ...) those names mean the profile
-- PK. That split was not cosmetic - it silently broke two functions that
-- joined across the boundary:
--
--   * compute_client_responsiveness_score() queried
--     contract WHERE client_id = <users.user_id>, which never matched, so it
--     always returned its 0.8 fallback.
--   * compute_client_dispute_rate_score() did the same on contract, so the
--     dispute-fairness component of every client trust score was the constant
--     1.0 rather than a measurement.
--
-- Both are ~20% of the client trust score between them. Rather than paper over
-- it with resolve-to-user_id calls at each join site, the tables now key on the
-- profile PK like the rest of the schema, and the handful of places that
-- genuinely need a users.user_id (notification recipients, DM sender_id
-- comparisons) resolve it explicitly from the profile row.
--
-- All review tables were empty when this ran, so the retyping below needs no
-- backfill. On a populated database each ALTER would need a
-- USING (SELECT freelancer_id FROM freelancer WHERE user_id = <col>) style
-- rewrite first.

-- reviews: freelancer_id -> freelancer, reviewer_id -> client (the reviewer of
-- a freelancer is always the client party of the contract).
ALTER TABLE reviews DROP CONSTRAINT IF EXISTS fk_reviews_freelancer;
ALTER TABLE reviews DROP CONSTRAINT IF EXISTS fk_reviews_reviewer;
ALTER TABLE reviews ADD CONSTRAINT fk_reviews_freelancer
      FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE;
ALTER TABLE reviews ADD CONSTRAINT fk_reviews_reviewer
      FOREIGN KEY (reviewer_id)   REFERENCES client(client_id)         ON DELETE CASCADE;

-- client_reviews had NO foreign keys on either party at all - the freelancer
-- side has had fk_reviews_reviewer/fk_reviews_freelancer since it was created,
-- so a deleted user left orphan client_reviews rows behind but not orphan
-- reviews rows. Added here, pointing at the profile tables.
ALTER TABLE client_reviews ADD CONSTRAINT fk_client_reviews_reviewer
      FOREIGN KEY (reviewer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE;
ALTER TABLE client_reviews ADD CONSTRAINT fk_client_reviews_client
      FOREIGN KEY (client_id)   REFERENCES client(client_id)         ON DELETE CASCADE;

ALTER TABLE freelancer_performance_scores DROP CONSTRAINT IF EXISTS fk_fps_freelancer;
ALTER TABLE freelancer_performance_scores ADD CONSTRAINT fk_fps_freelancer
      FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE;

ALTER TABLE freelancer_trust_scores DROP CONSTRAINT IF EXISTS fk_fts_freelancer;
ALTER TABLE freelancer_trust_scores ADD CONSTRAINT fk_fts_freelancer
      FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE;

ALTER TABLE trust_score_history DROP CONSTRAINT IF EXISTS fk_tsh_freelancer;
ALTER TABLE trust_score_history ADD CONSTRAINT fk_tsh_freelancer
      FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE;

ALTER TABLE client_trust_score DROP CONSTRAINT IF EXISTS client_trust_score_client_id_fkey;
ALTER TABLE client_trust_score ADD CONSTRAINT client_trust_score_client_id_fkey
      FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE;

-- red_flag_alerts held both freelancer and client subjects in a single
-- freelancer_id column discriminated by subject_type - workable while both were
-- users.user_id, impossible once they became different tables' PKs. Split into
-- two nullable columns with a real FK each and a CHECK that exactly one is set,
-- so a deleted profile can no longer strand its alerts.
ALTER TABLE red_flag_alerts DROP CONSTRAINT IF EXISTS fk_rfa_freelancer;
ALTER TABLE red_flag_alerts ALTER COLUMN freelancer_id DROP NOT NULL;
ALTER TABLE red_flag_alerts ADD COLUMN IF NOT EXISTS client_id UUID;
ALTER TABLE red_flag_alerts ADD CONSTRAINT fk_rfa_freelancer
      FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE;
ALTER TABLE red_flag_alerts ADD CONSTRAINT fk_rfa_client
      FOREIGN KEY (client_id)     REFERENCES client(client_id)         ON DELETE CASCADE;
ALTER TABLE red_flag_alerts ADD CONSTRAINT red_flag_alerts_one_subject_check
      CHECK (num_nonnulls(freelancer_id, client_id) = 1);

DROP INDEX IF EXISTS idx_rfa_unresolved;
CREATE INDEX IF NOT EXISTS idx_rfa_client_id ON red_flag_alerts (client_id);
CREATE INDEX IF NOT EXISTS idx_rfa_freelancer_unresolved
    ON red_flag_alerts (freelancer_id, is_resolved) WHERE is_resolved = FALSE;
CREATE INDEX IF NOT EXISTS idx_rfa_client_unresolved
    ON red_flag_alerts (client_id, is_resolved)     WHERE is_resolved = FALSE;


-- ============================================================================
-- client_reviews*: bring up to parity with the reviews* tables
-- ============================================================================
-- The freelancer-side review tables were built first and carry a full set of
-- enums, CHECKs, UNIQUEs and indexes. The client-side mirror was added later
-- and got almost none of them, so the two halves of a deliberately symmetric
-- feature enforced very different guarantees. Most consequential: with no
-- UNIQUE (client_review_id, category), a double submit - possible because the
-- submit guard is status='pending' and status only leaves 'pending' when the
-- background pipeline finishes - inserted duplicate ratings that
-- calculate_weighted_client_review_avg() then double-counted. The freelancer
-- side has always rejected that via uq_review_rating_category.

ALTER TABLE client_reviews ALTER COLUMN status DROP DEFAULT;
ALTER TABLE client_reviews ALTER COLUMN status TYPE review_status USING status::review_status;
ALTER TABLE client_reviews ALTER COLUMN status SET DEFAULT 'pending';

-- created_at/published_at were naive TIMESTAMP while reviews used TIMESTAMPTZ.
-- calculate_weighted_client_review_avg() does recency math against an aware
-- datetime.now(timezone.utc) and had to .replace(tzinfo=utc) to compensate,
-- which is only correct while the server happens to run UTC.
ALTER TABLE client_reviews ALTER COLUMN created_at   TYPE TIMESTAMPTZ USING created_at   AT TIME ZONE 'UTC';
ALTER TABLE client_reviews ALTER COLUMN published_at TYPE TIMESTAMPTZ USING published_at AT TIME ZONE 'UTC';
ALTER TABLE client_reviews ALTER COLUMN created_at SET DEFAULT NOW();
ALTER TABLE client_reviews ALTER COLUMN created_at SET NOT NULL;

CREATE INDEX IF NOT EXISTS idx_client_reviews_reviewer_id ON client_reviews (reviewer_id);
CREATE INDEX IF NOT EXISTS idx_client_reviews_status      ON client_reviews (status);
CREATE INDEX IF NOT EXISTS idx_client_reviews_created_at  ON client_reviews (created_at DESC);

ALTER TABLE client_review_ratings ALTER COLUMN score TYPE DECIMAL(2,1);
ALTER TABLE client_review_ratings ADD CONSTRAINT client_review_ratings_score_check
      CHECK (score >= 1.0 AND score <= 5.0);
ALTER TABLE client_review_ratings ADD CONSTRAINT uq_client_review_rating_category
      UNIQUE (client_review_id, category);
CREATE INDEX IF NOT EXISTS idx_client_review_ratings_review_id
    ON client_review_ratings (client_review_id);

ALTER TABLE client_review_written_content ADD CONSTRAINT client_review_written_content_client_review_id_key
      UNIQUE (client_review_id);

ALTER TABLE client_review_ai_analysis ADD CONSTRAINT client_review_ai_analysis_client_review_id_key
      UNIQUE (client_review_id);
ALTER TABLE client_review_ai_analysis ALTER COLUMN sentiment_label TYPE review_sentiment_label
      USING sentiment_label::review_sentiment_label;
ALTER TABLE client_review_ai_analysis ALTER COLUMN sentiment_score    TYPE DECIMAL(4,3);
ALTER TABLE client_review_ai_analysis ALTER COLUMN authenticity_score TYPE DECIMAL(4,3);
ALTER TABLE client_review_ai_analysis ADD CONSTRAINT client_review_ai_analysis_sentiment_score_check
      CHECK (sentiment_score BETWEEN -1.0 AND 1.0);
ALTER TABLE client_review_ai_analysis ADD CONSTRAINT client_review_ai_analysis_authenticity_score_check
      CHECK (authenticity_score BETWEEN 0 AND 1.0);
ALTER TABLE client_review_ai_analysis ALTER COLUMN sentiment_mismatch SET NOT NULL;
ALTER TABLE client_review_ai_analysis ALTER COLUMN is_flagged_fake    SET NOT NULL;
ALTER TABLE client_review_ai_analysis ALTER COLUMN is_flagged_coerced SET NOT NULL;
ALTER TABLE client_review_ai_analysis ALTER COLUMN flag_reasons       SET NOT NULL;
-- overall_pass defaulted TRUE here but FALSE on the freelancer side: a row
-- inserted before analysis completed would have read as "passed" and been
-- eligible to publish. Fail closed, like reviews.
ALTER TABLE client_review_ai_analysis ALTER COLUMN overall_pass SET DEFAULT FALSE;
ALTER TABLE client_review_ai_analysis ALTER COLUMN overall_pass SET NOT NULL;
ALTER TABLE client_review_ai_analysis ADD COLUMN IF NOT EXISTS analyzed_at TIMESTAMPTZ NOT NULL DEFAULT NOW();


-- ============================================================================
-- client_trust_score_history
-- ============================================================================
-- Clients had no equivalent of trust_score_history, and
-- ClientReviewFunctions.check_and_create_red_flag() worked around it by reading
-- the *current* client_trust_score.trust_score as the "previous" score. Its
-- caller (recalculate_and_persist_client_trust_score) upserts the new score
-- before calling it, so "previous" was always the value just written: the drop
-- was always 0.0 and no client red flag could ever fire. The freelancer path
-- avoids this only because trust_score_history is append-only and it reads
-- snapshots[1]. Giving clients the same table lets both sides use identical
-- logic instead of one of them being subtly wrong.
CREATE TABLE IF NOT EXISTS client_trust_score_history (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id       UUID NOT NULL,
    trust_score     DECIMAL(5,2) NOT NULL,
    snapshot_reason trust_snapshot_reason NOT NULL DEFAULT 'review_published',
    recorded_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_ctsh_client FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_ctsh_client_id   ON client_trust_score_history (client_id);
CREATE INDEX IF NOT EXISTS idx_ctsh_recorded_at ON client_trust_score_history (client_id, recorded_at DESC);


-- ============================================================================
-- Dead review columns
-- ============================================================================
-- freelancer_trust_scores.work_quality_score was never written by anything:
-- ReviewFunctions.upsert_trust_score() builds its payload dict explicitly and
-- has no such key, and no other writer touches the table. Always NULL, yet it
-- carried a CHECK constraint and was advertised in the TrustScoreResponse
-- model. The real work-quality signal lives per-contract in
-- freelancer_performance_scores.work_quality_score, which is retained.
ALTER TABLE freelancer_trust_scores DROP COLUMN IF EXISTS work_quality_score;

-- client_trust_score kept six columns from the pre-review-system client scoring
-- design. upsert_client_trust_score() writes none of them and nothing reads
-- them; they are permanently NULL/0.
ALTER TABLE client_trust_score DROP COLUMN IF EXISTS rating_consistency_score;
ALTER TABLE client_trust_score DROP COLUMN IF EXISTS extreme_rating_ratio;
ALTER TABLE client_trust_score DROP COLUMN IF EXISTS project_completion_rate;
ALTER TABLE client_trust_score DROP COLUMN IF EXISTS average_budget_gap;
ALTER TABLE client_trust_score DROP COLUMN IF EXISTS total_ratings_given;
ALTER TABLE client_trust_score DROP COLUMN IF EXISTS last_calculated_at;


-- ============================================================================
-- contract.original_end_date - stop deadline extensions laundering on-time
-- ============================================================================
-- ContractFunctions.arbitrate_dispute(outcome='revise') overwrites
-- contract.end_date with the new deadline, and compute_on_time_score() compared
-- delivery against that. A freelancer who missed a deadline, had a dispute
-- raised, and was granted an extension therefore scored as fully on-time - the
-- worst outcome produced the best score, and the original commitment was gone
-- from the database entirely.
--
-- original_end_date is captured once at insert and is immutable thereafter.
-- Enforced by trigger rather than by application code: end_date is written from
-- several paths (create, generic update_contract, arbitration) and a rule this
-- load-bearing should not depend on every one of them remembering.
ALTER TABLE contract ADD COLUMN IF NOT EXISTS original_end_date DATE;

UPDATE contract SET original_end_date = end_date WHERE original_end_date IS NULL;

CREATE OR REPLACE FUNCTION lock_original_end_date() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Seed from end_date unless the caller set it explicitly.
        IF NEW.original_end_date IS NULL THEN
            NEW.original_end_date := NEW.end_date;
        END IF;
    ELSE
        -- Immutable on update: extensions move end_date, never the original.
        NEW.original_end_date := OLD.original_end_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_contract_original_end_date ON contract;
CREATE TRIGGER trg_contract_original_end_date
    BEFORE INSERT OR UPDATE ON contract
    FOR EACH ROW EXECUTE FUNCTION lock_original_end_date();


-- ============================================================================
-- Persist the shrunk ("effective") review average
-- ============================================================================
-- The trust score shrinks the star average toward a neutral prior by review
-- count (shrink_toward_prior), so a single 5-star review can no longer buy a top
-- score. But only the RAW weighted average was ever persisted, so the API kept
-- returning 4.625 while the score was actually computed from 3.69 - the number
-- moved and the number clients could see did not, which defeats the point of
-- making confidence explicit. Stored alongside the raw value rather than
-- replacing it: the raw average is still the honest "what did people rate you",
-- and the effective one is "what that is worth given how little evidence backs it".
ALTER TABLE freelancer_trust_scores ADD COLUMN IF NOT EXISTS effective_review_avg NUMERIC;
ALTER TABLE client_trust_score       ADD COLUMN IF NOT EXISTS effective_review_avg_received NUMERIC;


-- ============================================================================
-- job_post.project_scope_is_auto
-- ============================================================================
-- project_scope is either chosen by the client or recommended by
-- calculate_project_scope(), and nothing recorded which. That mattered once the
-- recommendation started being recomputed after creation: without provenance the
-- only options were to overwrite deliberate client choices or to never correct a
-- stale auto value.
--
-- Backfilled TRUE because every existing row was auto-set: the create path
-- computed a scope whenever the payload omitted one, and a manual choice was
-- indistinguishable. Rows the client explicitly set will flip to FALSE the next
-- time they are updated with an explicit scope.
ALTER TABLE job_post ADD COLUMN IF NOT EXISTS project_scope_is_auto BOOLEAN NOT NULL DEFAULT TRUE;


-- ============================================================================
-- One pending scam flag per job post
-- ============================================================================
-- scam_job_flags had no uniqueness on job_post_id, which was harmless only
-- because the automatic scan ran exactly once, at creation. Now that an edit to
-- an active post re-scans it, and the admin scan endpoint can be re-run by hand,
-- the same job would accumulate pending rows - each with its own 30-day deadline,
-- so the sweep would close the job off whichever row expired first.
--
-- Partial rather than a plain unique constraint: only PENDING flags are
-- exclusive. A job that was flagged, actioned, and later flagged again keeps its
-- full history, which is what the client_scam_record strike count reads.
--
-- Paired with the ON CONFLICT ... DO UPDATE in queue_scam_scan, which overwrites
-- the pending row only when the re-scan scores higher. Mirrors the guard
-- harmful_text_queue already has on (content_type, content_id).
CREATE UNIQUE INDEX IF NOT EXISTS idx_scam_pending_one_per_job
    ON scam_job_flags (job_post_id)
    WHERE status = 'pending';
