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
