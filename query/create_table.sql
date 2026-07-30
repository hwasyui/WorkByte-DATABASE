CREATE TYPE rate_time_type        AS ENUM ('hourly', 'weekly', 'monthly', 'annually', 'daily');
CREATE TYPE skill_category_type   AS ENUM ('hard_skill', 'soft_skill', 'tool');
CREATE TYPE proficiency_skill     AS ENUM ('beginner', 'intermediate', 'advanced', 'expert');
CREATE TYPE project_type          AS ENUM ('individual', 'team');
CREATE TYPE project_scope         AS ENUM ('small', 'medium', 'large');
CREATE TYPE experience_level      AS ENUM ('entry', 'intermediate', 'expert');
CREATE TYPE job_status            AS ENUM ('draft', 'active', 'closed', 'filled');
CREATE TYPE budget_type           AS ENUM ('fixed', 'negotiable');
CREATE TYPE importance_level      AS ENUM ('nice_to_have', 'preferred', 'required');
CREATE TYPE proposal_status       AS ENUM ('pending', 'accepted', 'rejected');
CREATE TYPE payment_structure     AS ENUM ('full_payment', 'milestone_based');
CREATE TYPE contract_status       AS ENUM ('active', 'completed', 'cancelled', 'disputed', 'revision_requested', 'under_review');

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS users (
    user_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email             VARCHAR(255) NOT NULL UNIQUE,
    password          VARCHAR(255) NOT NULL,
    password_login_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    is_admin          BOOLEAN NOT NULL DEFAULT FALSE,
    email_verified    BOOLEAN NOT NULL DEFAULT FALSE,
    email_verified_at TIMESTAMP,
    created_at        TIMESTAMP DEFAULT NOW(),
    updated_at        TIMESTAMP DEFAULT NOW(),
    is_report_banned  BOOLEAN NOT NULL DEFAULT FALSE,
    report_banned_at  TIMESTAMP,
    ban_reason        TEXT,
    ban_message       TEXT,
    fcm_token         TEXT
);

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS email_verification_otps (
    otp_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL,
    otp_hash    VARCHAR(255) NOT NULL,
    expires_at  TIMESTAMP NOT NULL,
    consumed_at TIMESTAMP,
    attempts    INTEGER NOT NULL DEFAULT 0,
    created_at  TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_email_verification_otps_user_active
    ON email_verification_otps (user_id, created_at DESC)
    WHERE consumed_at IS NULL;

CREATE TABLE IF NOT EXISTS password_reset_otps (
    otp_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL,
    otp_hash    VARCHAR(255) NOT NULL,
    expires_at  TIMESTAMP NOT NULL,
    consumed_at TIMESTAMP,
    attempts    INTEGER NOT NULL DEFAULT 0,
    created_at  TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_password_reset_otps_user_active
    ON password_reset_otps (user_id, created_at DESC)
    WHERE consumed_at IS NULL;

CREATE TABLE IF NOT EXISTS user_oauth_providers (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID NOT NULL,
    provider         VARCHAR(50)  NOT NULL,
    provider_user_id VARCHAR(255) NOT NULL,
    provider_email   VARCHAR(255),
    created_at       TIMESTAMP DEFAULT NOW(),
    UNIQUE (provider, provider_user_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_user_oauth_providers_user ON user_oauth_providers (user_id);

CREATE TABLE IF NOT EXISTS refresh_tokens (
    token_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL,
    token_hash  CHAR(64) NOT NULL,
    expires_at  TIMESTAMP NOT NULL,
    revoked_at  TIMESTAMP,
    created_at  TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_hash
    ON refresh_tokens (token_hash) WHERE revoked_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user
    ON refresh_tokens (user_id);

CREATE TABLE IF NOT EXISTS freelancer (
    freelancer_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL UNIQUE,
    full_name           VARCHAR(255) NOT NULL,
    title               VARCHAR(255),
    bio                 TEXT,
    cv_file_url         VARCHAR(500),
    profile_picture_url VARCHAR(500),
    estimated_rate      DECIMAL(10, 2),
    rate_time           rate_time_type DEFAULT 'hourly',
    rate_currency       VARCHAR(10) DEFAULT 'USD',
    total_jobs          INTEGER DEFAULT 0,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_freelancer_updated_at
    BEFORE UPDATE ON freelancer
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS client (
    client_id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                  UUID NOT NULL UNIQUE,
    full_name                VARCHAR(255),
    bio                      TEXT,
    website_url              VARCHAR(500),
    profile_picture_url      VARCHAR(500),
    total_jobs_posted         INTEGER DEFAULT 0,
    total_jobs_completed      INTEGER DEFAULT 0,
    average_rating_given      DECIMAL(3, 2),
    contract_message_template TEXT,
    created_at                TIMESTAMP DEFAULT NOW(),
    updated_at                TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_client_updated_at
    BEFORE UPDATE ON client
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS client_scam_record (
    record_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id            UUID NOT NULL UNIQUE,
    total_scam_confirmed INTEGER NOT NULL DEFAULT 0,
    is_banned            BOOLEAN NOT NULL DEFAULT FALSE,
    banned_at            TIMESTAMP,
    updated_at           TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS skill (
    skill_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    skill_name     VARCHAR(100) NOT NULL UNIQUE,
    skill_category skill_category_type,
    created_at     TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS freelancer_skill (
    freelancer_skill_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id       UUID NOT NULL,
    skill_id            UUID NOT NULL,
    proficiency_level   proficiency_skill,
    created_at          TIMESTAMP DEFAULT NOW(),
    UNIQUE (freelancer_id, skill_id),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id)      REFERENCES skill(skill_id)           ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS work_experience (
    work_experience_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id      UUID NOT NULL,
    job_title          VARCHAR(255) NOT NULL,
    company_name       VARCHAR(255) NOT NULL,
    location           VARCHAR(255),
    start_date         DATE NOT NULL,
    end_date           DATE,
    is_current         BOOLEAN DEFAULT FALSE,
    description        TEXT,
    created_at         TIMESTAMP DEFAULT NOW(),
    updated_at         TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_work_experience_updated_at
    BEFORE UPDATE ON work_experience
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS education (
    education_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id     UUID NOT NULL,
    institution_name  VARCHAR(255) NOT NULL,
    degree            VARCHAR(255) NOT NULL,
    field_of_study    VARCHAR(255),
    start_date        DATE NOT NULL,
    end_date          DATE,
    is_current        BOOLEAN DEFAULT FALSE,
    grade             VARCHAR(50),
    description       TEXT,
    created_at        TIMESTAMP DEFAULT NOW(),
    updated_at        TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_education_updated_at
    BEFORE UPDATE ON education
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS job_post (
    job_post_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id          UUID NOT NULL,
    job_title          VARCHAR(255) NOT NULL,
    job_description    TEXT NOT NULL,
    project_type       project_type NOT NULL,
    project_scope      project_scope NOT NULL,
    -- FALSE once a client explicitly chooses a scope; TRUE while the value is a
    -- recommendation from calculate_project_scope() and may be recomputed.
    project_scope_is_auto BOOLEAN NOT NULL DEFAULT TRUE,
    estimated_duration VARCHAR(100),
    working_days       INTEGER,
    deadline           DATE,
    experience_level   experience_level,
    status             job_status NOT NULL,
    is_ai_generated    BOOLEAN DEFAULT FALSE,
    view_count         INTEGER DEFAULT 0,
    proposal_count     INTEGER DEFAULT 0,
    created_at         TIMESTAMP DEFAULT NOW(),
    updated_at         TIMESTAMP DEFAULT NOW(),
    posted_at          TIMESTAMP,
    closed_at          TIMESTAMP,
    project_category   VARCHAR(50) DEFAULT 'general',
    closure_reason     TEXT,
    closure_note       TEXT,
    FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_job_post_updated_at
    BEFORE UPDATE ON job_post
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS scam_job_flags (
    flag_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_post_id       UUID NOT NULL,
    client_id         UUID NOT NULL,
    scam_score        DOUBLE PRECISION NOT NULL,
    detected_keywords JSONB NOT NULL DEFAULT '[]',
    flagged_text      TEXT,
    status            TEXT NOT NULL DEFAULT 'pending',
    admin_user_id     UUID,
    admin_note        TEXT,
    actioned_at       TIMESTAMP,
    auto_remove_at    TIMESTAMP NOT NULL,
    auto_closed       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (job_post_id)   REFERENCES job_post(job_post_id) ON DELETE CASCADE,
    FOREIGN KEY (client_id)     REFERENCES client(client_id)     ON DELETE CASCADE,
    FOREIGN KEY (admin_user_id) REFERENCES users(user_id)
);

CREATE INDEX IF NOT EXISTS idx_scam_status ON scam_job_flags (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_scam_client ON scam_job_flags (client_id);
CREATE INDEX IF NOT EXISTS idx_scam_auto   ON scam_job_flags (auto_remove_at) WHERE status = 'pending';

CREATE TABLE IF NOT EXISTS user_reports (
    report_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id      UUID NOT NULL,
    reported_user_id UUID,
    reported_type    TEXT NOT NULL,
    reasons          JSONB NOT NULL DEFAULT '[]',
    custom_reason    TEXT,
    status           TEXT NOT NULL DEFAULT 'pending',
    admin_user_id    UUID,
    admin_note       TEXT,
    actioned_at      TIMESTAMP,
    created_at       TIMESTAMP DEFAULT NOW(),
    job_post_id      UUID,
    FOREIGN KEY (reporter_id)      REFERENCES users(user_id)         ON DELETE CASCADE,
    FOREIGN KEY (reported_user_id) REFERENCES users(user_id)         ON DELETE CASCADE,
    FOREIGN KEY (job_post_id)      REFERENCES job_post(job_post_id)  ON DELETE CASCADE,
    FOREIGN KEY (admin_user_id)    REFERENCES users(user_id)         ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_reports_status   ON user_reports (status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_reported ON user_reports (reported_user_id);
CREATE INDEX IF NOT EXISTS idx_reports_job_post ON user_reports (job_post_id) WHERE job_post_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_reports_reporter ON user_reports (reporter_id);

CREATE TABLE IF NOT EXISTS job_role (
    job_role_id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_post_id         UUID NOT NULL,
    role_title          VARCHAR(255) NOT NULL,
    role_budget         DECIMAL(12, 2),
    budget_currency     VARCHAR(10) DEFAULT 'USD',
    budget_type         budget_type NOT NULL,
    role_description    TEXT,
    positions_available INTEGER DEFAULT 1,
    positions_filled    INTEGER DEFAULT 0,
    is_required         BOOLEAN DEFAULT TRUE,
    display_order       INTEGER DEFAULT 0,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (job_post_id) REFERENCES job_post(job_post_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_job_role_updated_at
    BEFORE UPDATE ON job_role
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS job_role_skill (
    job_role_skill_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_role_id       UUID NOT NULL,
    skill_id          UUID NOT NULL,
    is_required       BOOLEAN DEFAULT TRUE,
    importance_level  importance_level,
    created_at        TIMESTAMP DEFAULT NOW(),
    UNIQUE (job_role_id, skill_id),
    FOREIGN KEY (job_role_id) REFERENCES job_role(job_role_id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id)    REFERENCES skill(skill_id)       ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS job_role_embedding (
    embedding_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_role_id           UUID NOT NULL UNIQUE,
    job_post_id           UUID NOT NULL,
    embedding_vector      VECTOR(768),
    source_text           TEXT,
    embedding_metadata    JSONB,
    embedding_dirty       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    FOREIGN KEY (job_role_id) REFERENCES job_role(job_role_id) ON DELETE CASCADE,
    FOREIGN KEY (job_post_id) REFERENCES job_post(job_post_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_job_role_embedding_hnsw
    ON job_role_embedding USING hnsw (embedding_vector vector_cosine_ops)
    WHERE embedding_vector IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_job_role_embedding_dirty
    ON job_role_embedding (embedding_dirty) WHERE embedding_dirty = TRUE;
CREATE INDEX IF NOT EXISTS idx_job_role_embedding_job_post
    ON job_role_embedding (job_post_id);

CREATE TRIGGER trg_job_role_embedding_updated_at
    BEFORE UPDATE ON job_role_embedding
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS job_file (
    job_file_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_post_id UUID NOT NULL,
    file_url    VARCHAR(5000) NOT NULL,
    file_type   VARCHAR(50) NOT NULL,
    file_name   VARCHAR(255) NOT NULL,
    file_size   INTEGER,
    created_at  TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (job_post_id) REFERENCES job_post(job_post_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS proposal (
    proposal_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_post_id       UUID NOT NULL,
    job_role_id       UUID NOT NULL,
    freelancer_id     UUID NOT NULL,
    cover_letter      TEXT NOT NULL,
    proposed_budget   DECIMAL(12, 2) NOT NULL,
    proposed_duration VARCHAR(100),
    status            proposal_status NOT NULL,
    is_ai_generated   BOOLEAN DEFAULT FALSE,
    submitted_at      TIMESTAMP DEFAULT NOW(),
    CONSTRAINT uq_proposal_freelancer_role UNIQUE (freelancer_id, job_role_id),
    FOREIGN KEY (job_post_id)   REFERENCES job_post(job_post_id)     ON DELETE CASCADE,
    -- A proposal always targets a real role (required at create). CASCADE so deleting a
    -- role takes its proposals with it; a role whose proposal is already under contract
    -- can't be deleted (contract -> proposal is RESTRICT), which is the intended guard.
    FOREIGN KEY (job_role_id)   REFERENCES job_role(job_role_id)     ON DELETE CASCADE,
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS proposal_file (
    proposal_file_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proposal_id      UUID NOT NULL,
    file_url         VARCHAR(500) NOT NULL,
    file_type        VARCHAR(50) NOT NULL,
    file_name        VARCHAR(255) NOT NULL,
    file_size        INTEGER,
    created_at       TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (proposal_id) REFERENCES proposal(proposal_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS contract (
    contract_id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_post_id                UUID NOT NULL,
    job_role_id                UUID NOT NULL,
    proposal_id                UUID NOT NULL CONSTRAINT contract_proposal_id_uniq UNIQUE,
    freelancer_id              UUID NOT NULL,
    client_id                  UUID NOT NULL,
    contract_title             VARCHAR(255) NOT NULL,
    role_title                 VARCHAR(255),
    agreed_budget              DECIMAL(12, 2) NOT NULL,
    budget_currency            VARCHAR(10) DEFAULT 'USD',
    payment_structure          payment_structure NOT NULL,
    agreed_duration            VARCHAR(100),
    status                     contract_status NOT NULL,
    start_date                 DATE NOT NULL,
    end_date                   DATE,
    -- The deadline as originally agreed. Captured once at insert and immutable
    -- thereafter (see trg_contract_original_end_date) so a deadline extension
    -- granted during dispute arbitration cannot retroactively make a late
    -- delivery score as on-time. end_date remains the live working deadline.
    original_end_date          DATE,
    actual_completion_date     DATE,
    total_hours_worked         DECIMAL(8, 2),
    total_paid                 DECIMAL(12, 2) DEFAULT 0,
    contract_pdf_url           VARCHAR(500),
    contract_pdf_generated_at  TIMESTAMP,
    cancelled_by               UUID,
    cancellation_reason        TEXT,
    created_at                 TIMESTAMP DEFAULT NOW(),
    updated_at                 TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (job_post_id)   REFERENCES job_post(job_post_id)     ON DELETE RESTRICT,
    FOREIGN KEY (job_role_id)   REFERENCES job_role(job_role_id)     ON DELETE RESTRICT,
    FOREIGN KEY (proposal_id)   REFERENCES proposal(proposal_id)     ON DELETE RESTRICT,
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE RESTRICT,
    FOREIGN KEY (client_id)     REFERENCES client(client_id)         ON DELETE RESTRICT,
    FOREIGN KEY (cancelled_by)  REFERENCES users(user_id)            ON DELETE SET NULL
);

CREATE TRIGGER trg_contract_updated_at
    BEFORE UPDATE ON contract
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE FUNCTION lock_original_end_date() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.original_end_date IS NULL THEN
            NEW.original_end_date := NEW.end_date;
        END IF;
    ELSE
        NEW.original_end_date := OLD.original_end_date;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_contract_original_end_date
    BEFORE INSERT OR UPDATE ON contract
    FOR EACH ROW EXECUTE FUNCTION lock_original_end_date();

CREATE TABLE IF NOT EXISTS contract_terms (
    contract_terms_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id          UUID NOT NULL UNIQUE,
    termination_notice   INTEGER,
    governing_law        VARCHAR(100),
    confidentiality      BOOLEAN DEFAULT FALSE,
    confidentiality_text TEXT,
    late_payment_penalty DECIMAL(5, 2),
    dispute_resolution   VARCHAR(50),
    revision_rounds      INTEGER,
    additional_clauses   TEXT,
    payment_schedule     TEXT,
    created_at           TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (contract_id) REFERENCES contract(contract_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS portfolio (
    portfolio_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id       UUID NOT NULL,
    project_title       VARCHAR(255) NOT NULL,
    project_description TEXT NOT NULL,
    project_url         VARCHAR(255),
    completion_date     DATE,
    is_auto_generated   BOOLEAN DEFAULT FALSE,
    contract_id         UUID UNIQUE,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE,
    FOREIGN KEY (contract_id)   REFERENCES contract(contract_id)     ON DELETE SET NULL
);

CREATE TRIGGER trg_portfolio_updated_at
    BEFORE UPDATE ON portfolio
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS portfolio_embedding (
    embedding_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    portfolio_id       UUID NOT NULL UNIQUE,
    freelancer_id      UUID NOT NULL,
    embedding_vector   VECTOR(768),
    source_text        TEXT,
    embedding_metadata JSONB,
    embedding_dirty    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMP DEFAULT NOW(),
    updated_at         TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (portfolio_id)  REFERENCES portfolio(portfolio_id)   ON DELETE CASCADE,
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION set_portfolio_embedding_updated_at()
RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;

CREATE TRIGGER trg_portfolio_embedding_updated_at
    BEFORE UPDATE ON portfolio_embedding
    FOR EACH ROW EXECUTE FUNCTION set_portfolio_embedding_updated_at();

CREATE INDEX IF NOT EXISTS idx_portfolio_embedding_hnsw
    ON portfolio_embedding USING hnsw (embedding_vector vector_cosine_ops)
    WHERE embedding_vector IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_portfolio_embedding_dirty
    ON portfolio_embedding (embedding_dirty) WHERE embedding_dirty = TRUE;
CREATE INDEX IF NOT EXISTS idx_portfolio_embedding_freelancer
    ON portfolio_embedding (freelancer_id) WHERE embedding_vector IS NOT NULL;

CREATE TABLE IF NOT EXISTS saved_job (
    saved_job_id  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id UUID NOT NULL,
    job_post_id   UUID NOT NULL,
    saved_at      TIMESTAMP DEFAULT NOW(),
    notes         TEXT,
    UNIQUE (freelancer_id, job_post_id),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE,
    FOREIGN KEY (job_post_id)   REFERENCES job_post(job_post_id)     ON DELETE CASCADE
);

-- rating & performance_rating tables removed (no longer used); dropped via alter_table.sql

CREATE TABLE IF NOT EXISTS client_trust_score (
    client_trust_score_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id                UUID NOT NULL UNIQUE,
    trust_score              DECIMAL(5, 2),
    updated_at               TIMESTAMP DEFAULT NOW(),
    -- review-derived fields (added via alter_table)
    total_reviews_received       INTEGER DEFAULT 0,
    weighted_review_avg_received NUMERIC,
    effective_review_avg_received NUMERIC,
    authenticity_confidence      NUMERIC,
    communication_sentiment      NUMERIC,
    consistency_score            NUMERIC,
    dispute_fairness_score       NUMERIC,
    responsiveness_score         NUMERIC,
    ai_review_summary            TEXT,
    FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_client_trust_score_updated_at
    BEFORE UPDATE ON client_trust_score
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS freelancer_embedding (
    embedding_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id      UUID NOT NULL UNIQUE,
    embedding_vector   VECTOR(768),
    source_text        TEXT,
    embedding_metadata JSONB,
    embedding_dirty    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMP DEFAULT NOW(),
    updated_at         TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_freelancer_embedding_updated_at
    BEFORE UPDATE ON freelancer_embedding
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX IF NOT EXISTS idx_freelancer_embedding_hnsw
    ON freelancer_embedding USING hnsw (embedding_vector vector_cosine_ops)
    WHERE embedding_vector IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_freelancer_embedding_dirty
    ON freelancer_embedding (embedding_dirty)
    WHERE embedding_dirty = TRUE;

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

CREATE TABLE IF NOT EXISTS contract_embedding (
    embedding_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id        UUID NOT NULL UNIQUE,
    freelancer_id      UUID NOT NULL,
    embedding_vector   VECTOR(768),
    source_text        TEXT,
    embedding_metadata JSONB,
    embedding_dirty    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at         TIMESTAMP DEFAULT NOW(),
    updated_at         TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (contract_id)   REFERENCES contract(contract_id)     ON DELETE CASCADE,
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION set_contract_embedding_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_contract_embedding_updated_at
    BEFORE UPDATE ON contract_embedding
    FOR EACH ROW EXECUTE FUNCTION set_contract_embedding_updated_at();

CREATE INDEX IF NOT EXISTS idx_contract_embedding_hnsw
    ON contract_embedding USING hnsw (embedding_vector vector_cosine_ops)
    WHERE embedding_vector IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_contract_embedding_dirty
    ON contract_embedding (embedding_dirty)
    WHERE embedding_dirty = TRUE;

CREATE INDEX IF NOT EXISTS idx_contract_embedding_freelancer
    ON contract_embedding (freelancer_id)
    WHERE embedding_vector IS NOT NULL;

-- One thread per user pair. contract_id links a thread to a contract.
-- status: 'request' -> 1-msg cap on initiator until receiver accepts
--         'active'  -> free exchange (set on accept or contract creation)
--         'declined'-> receiver declined

-- user_a_id/user_b_id/initiator_id/sender_id (below) are nullable with ON DELETE SET
-- NULL rather than CASCADE: deleting one side of a thread must not destroy the other
-- party's copy of the conversation. A thread/message with a NULL user side means that
-- participant deleted their account; the row is anonymized, not gone. Only once BOTH
-- sides of a thread are NULL (both participants deleted) does application code purge
-- the thread outright - see UserFunctions.delete_user().
CREATE TABLE IF NOT EXISTS dm_thread (
    thread_id      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_a_id      UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    user_b_id      UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    initiator_id   UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    status         TEXT        NOT NULL DEFAULT 'request',
    job_post_id    UUID        REFERENCES job_post(job_post_id) ON DELETE SET NULL,
    contract_id    UUID        REFERENCES contract(contract_id) ON DELETE SET NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_a_id, user_b_id),
    CHECK (user_a_id < user_b_id)
);
CREATE INDEX IF NOT EXISTS idx_dm_thread_user_a   ON dm_thread (user_a_id);
CREATE INDEX IF NOT EXISTS idx_dm_thread_user_b   ON dm_thread (user_b_id);
CREATE INDEX IF NOT EXISTS idx_dm_thread_contract ON dm_thread (contract_id) WHERE contract_id IS NOT NULL;

CREATE TABLE IF NOT EXISTS dm_message (
    dm_message_id  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    thread_id      UUID        NOT NULL REFERENCES dm_thread(thread_id) ON DELETE CASCADE,
    sender_id      UUID        REFERENCES users(user_id) ON DELETE SET NULL,
    message_text   TEXT        NOT NULL DEFAULT '',
    metadata       TEXT,
    is_read        BOOLEAN     NOT NULL DEFAULT FALSE,
    read_at        TIMESTAMPTZ,
    sent_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_dm_message_thread ON dm_message (thread_id, sent_at DESC);

CREATE TABLE IF NOT EXISTS dm_message_attachment (
    attachment_id    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    dm_message_id    UUID        NOT NULL REFERENCES dm_message(dm_message_id) ON DELETE CASCADE,
    file_name        TEXT        NOT NULL,
    file_url         TEXT        NOT NULL,
    file_type        TEXT        NOT NULL,
    mime_type        TEXT        NOT NULL,
    file_size_bytes  INTEGER,
    duration_seconds FLOAT,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_dm_attachment_message ON dm_message_attachment (dm_message_id);

CREATE TABLE IF NOT EXISTS contract_submission (
    submission_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id     UUID NOT NULL,
    submitted_by    UUID NOT NULL,
    note            TEXT,
    status          VARCHAR(50) NOT NULL DEFAULT 'submitted',
    submitted_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at     TIMESTAMP WITH TIME ZONE,
    revision_note   TEXT,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY (contract_id)   REFERENCES contract(contract_id) ON DELETE CASCADE,
    FOREIGN KEY (submitted_by)  REFERENCES users(user_id)        ON DELETE CASCADE
);

CREATE TRIGGER trigger_contract_submission_updated_at
    BEFORE UPDATE ON contract_submission
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS contract_submission_file (
    file_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    submission_id     UUID NOT NULL,
    file_url          TEXT NOT NULL,
    file_name         TEXT NOT NULL,
    file_size_bytes   BIGINT,
    mime_type         VARCHAR(100),
    uploaded_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY (submission_id) REFERENCES contract_submission(submission_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_contract_submission_contract_id
    ON contract_submission (contract_id);
CREATE INDEX IF NOT EXISTS idx_contract_submission_submitted_by
    ON contract_submission (submitted_by);
CREATE INDEX IF NOT EXISTS idx_contract_submission_file_submission_id
    ON contract_submission_file (submission_id);

CREATE TYPE review_status          AS ENUM ('pending', 'published', 'flagged', 'suppressed');
CREATE TYPE review_sentiment_label AS ENUM ('positive', 'neutral', 'negative');
CREATE TYPE review_alert_type      AS ENUM ('score_drop', 'spike_in_revisions', 'fake_review_pattern', 'high_conflict_detected');
CREATE TYPE review_alert_severity  AS ENUM ('low', 'medium', 'high');
CREATE TYPE trust_snapshot_reason  AS ENUM ('review_published', 'dispute_closed', 'score_recalculated', 'manual_adjustment');

CREATE TABLE IF NOT EXISTS reviews (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id       UUID NOT NULL,
    reviewer_id       UUID NOT NULL,
    freelancer_id     UUID NOT NULL,
    inferred_category VARCHAR(100) NOT NULL DEFAULT 'general',
    status            review_status NOT NULL DEFAULT 'pending',
    is_anonymous      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    published_at      TIMESTAMP WITH TIME ZONE,
    -- reviewer is always the client party of the contract
    CONSTRAINT fk_reviews_contract   FOREIGN KEY (contract_id)   REFERENCES contract(contract_id)     ON DELETE CASCADE,
    CONSTRAINT fk_reviews_reviewer   FOREIGN KEY (reviewer_id)   REFERENCES client(client_id)         ON DELETE CASCADE,
    CONSTRAINT fk_reviews_freelancer FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE,
    CONSTRAINT uq_reviews_contract   UNIQUE (contract_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_freelancer_id ON reviews (freelancer_id);
CREATE INDEX IF NOT EXISTS idx_reviews_reviewer_id   ON reviews (reviewer_id);
CREATE INDEX IF NOT EXISTS idx_reviews_status        ON reviews (status);
CREATE INDEX IF NOT EXISTS idx_reviews_category      ON reviews (inferred_category);
CREATE INDEX IF NOT EXISTS idx_reviews_created_at    ON reviews (created_at DESC);

CREATE TABLE IF NOT EXISTS review_ratings (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id   UUID NOT NULL,
    category    VARCHAR(50) NOT NULL,
    score       DECIMAL(2,1) NOT NULL CHECK (score >= 1.0 AND score <= 5.0),
    CONSTRAINT fk_review_ratings_review  FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE,
    CONSTRAINT uq_review_rating_category UNIQUE (review_id, category)
);

CREATE INDEX IF NOT EXISTS idx_review_ratings_review_id ON review_ratings (review_id);

CREATE TABLE IF NOT EXISTS review_written_content (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id       UUID NOT NULL UNIQUE,
    ai_question     TEXT,
    client_answer   TEXT,
    overall_comment TEXT,
    CONSTRAINT fk_rwc_review FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS review_skill_tags (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id        UUID NOT NULL,
    skill_tag        VARCHAR(100) NOT NULL,
    is_ai_suggested  BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_rst_review       FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE,
    CONSTRAINT uq_review_skill_tag UNIQUE (review_id, skill_tag)
);

CREATE INDEX IF NOT EXISTS idx_review_skill_tags_review_id ON review_skill_tags (review_id);

CREATE TABLE IF NOT EXISTS ai_review_prompts (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_category  VARCHAR(100) NOT NULL,
    question_text     TEXT NOT NULL,
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_prompts_category ON ai_review_prompts (project_category);
CREATE INDEX IF NOT EXISTS idx_ai_prompts_active   ON ai_review_prompts (is_active) WHERE is_active = TRUE;

CREATE TABLE IF NOT EXISTS freelancer_performance_scores (
    id                             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id                    UUID NOT NULL UNIQUE,
    freelancer_id                  UUID NOT NULL,
    work_quality_score             DECIMAL(4,3) CHECK (work_quality_score            BETWEEN 0 AND 1.0),
    work_quality_notes             TEXT,
    on_time_score                  DECIMAL(4,3) CHECK (on_time_score                 BETWEEN 0 AND 1.0),
    revision_count                 INT NOT NULL DEFAULT 0 CHECK (revision_count >= 0),
    revision_rate_score            DECIMAL(4,3) CHECK (revision_rate_score           BETWEEN 0 AND 1.0),
    responsiveness_score           DECIMAL(4,3) CHECK (responsiveness_score          BETWEEN 0 AND 1.0),
    communication_sentiment_score  DECIMAL(4,3) CHECK (communication_sentiment_score BETWEEN 0 AND 1.0),
    conflict_score                 DECIMAL(4,3) CHECK (conflict_score                BETWEEN 0 AND 1.0),
    communication_summary          TEXT,
    computed_at                    TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_fps_contract   FOREIGN KEY (contract_id)   REFERENCES contract(contract_id)     ON DELETE CASCADE,
    CONSTRAINT fk_fps_freelancer FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_fps_freelancer_id ON freelancer_performance_scores (freelancer_id);

CREATE TABLE IF NOT EXISTS review_ai_analysis (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id           UUID NOT NULL UNIQUE,
    sentiment_score     DECIMAL(4,3) CHECK (sentiment_score   BETWEEN -1.0 AND 1.0),
    sentiment_label     review_sentiment_label,
    sentiment_mismatch  BOOLEAN NOT NULL DEFAULT FALSE,
    authenticity_score  DECIMAL(4,3) CHECK (authenticity_score BETWEEN 0 AND 1.0),
    is_flagged_fake     BOOLEAN NOT NULL DEFAULT FALSE,
    is_flagged_coerced  BOOLEAN NOT NULL DEFAULT FALSE,
    flag_reasons        JSONB NOT NULL DEFAULT '[]',
    disagreement_probability DECIMAL(4,3) CHECK (disagreement_probability BETWEEN 0 AND 1),
    overall_pass        BOOLEAN NOT NULL DEFAULT FALSE,
    analyzed_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_raa_review FOREIGN KEY (review_id) REFERENCES reviews(id) ON DELETE CASCADE
);

-- Freelancer-reviews-client mirror of the reviews* tables above. Deliberately
-- symmetric: same enums, CHECKs, UNIQUEs and indexes on both halves, so a
-- guarantee that holds for a review of a freelancer also holds for a review of
-- a client (see alter_table.sql for what this used to look like).
CREATE TABLE IF NOT EXISTS client_reviews (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id    UUID NOT NULL,
    reviewer_id    UUID NOT NULL,
    client_id      UUID NOT NULL,
    status         review_status NOT NULL DEFAULT 'pending',
    is_anonymous   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    published_at   TIMESTAMP WITH TIME ZONE,
    -- reviewer is always the freelancer party of the contract
    CONSTRAINT client_reviews_contract_id_key  UNIQUE (contract_id),
    CONSTRAINT client_reviews_contract_id_fkey FOREIGN KEY (contract_id) REFERENCES contract(contract_id)     ON DELETE CASCADE,
    CONSTRAINT fk_client_reviews_reviewer      FOREIGN KEY (reviewer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE,
    CONSTRAINT fk_client_reviews_client        FOREIGN KEY (client_id)   REFERENCES client(client_id)         ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_client_reviews_client_id   ON client_reviews (client_id);
CREATE INDEX IF NOT EXISTS idx_client_reviews_reviewer_id ON client_reviews (reviewer_id);
CREATE INDEX IF NOT EXISTS idx_client_reviews_status      ON client_reviews (status);
CREATE INDEX IF NOT EXISTS idx_client_reviews_created_at  ON client_reviews (created_at DESC);

CREATE TABLE IF NOT EXISTS client_review_ratings (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_review_id  UUID NOT NULL,
    category          VARCHAR(50) NOT NULL,
    score             DECIMAL(2,1) NOT NULL CHECK (score >= 1.0 AND score <= 5.0),
    CONSTRAINT client_review_ratings_client_review_id_fkey FOREIGN KEY (client_review_id) REFERENCES client_reviews(id) ON DELETE CASCADE,
    CONSTRAINT uq_client_review_rating_category            UNIQUE (client_review_id, category)
);

CREATE INDEX IF NOT EXISTS idx_client_review_ratings_review_id ON client_review_ratings (client_review_id);

CREATE TABLE IF NOT EXISTS client_review_written_content (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_review_id  UUID NOT NULL UNIQUE,
    ai_question       TEXT,
    freelancer_answer TEXT,
    overall_comment   TEXT,
    CONSTRAINT client_review_written_content_client_review_id_fkey FOREIGN KEY (client_review_id) REFERENCES client_reviews(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS client_review_ai_analysis (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_review_id    UUID NOT NULL UNIQUE,
    sentiment_score     DECIMAL(4,3) CHECK (sentiment_score    BETWEEN -1.0 AND 1.0),
    sentiment_label     review_sentiment_label,
    sentiment_mismatch  BOOLEAN NOT NULL DEFAULT FALSE,
    disagreement_probability DECIMAL(4,3) CHECK (disagreement_probability BETWEEN 0 AND 1),
    authenticity_score  DECIMAL(4,3) CHECK (authenticity_score BETWEEN 0 AND 1.0),
    is_flagged_fake     BOOLEAN NOT NULL DEFAULT FALSE,
    is_flagged_coerced  BOOLEAN NOT NULL DEFAULT FALSE,
    flag_reasons        JSONB NOT NULL DEFAULT '[]',
    overall_pass        BOOLEAN NOT NULL DEFAULT FALSE,
    analyzed_at         TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT client_review_ai_analysis_client_review_id_fkey FOREIGN KEY (client_review_id) REFERENCES client_reviews(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS freelancer_trust_scores (
    id                       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id            UUID NOT NULL UNIQUE,
    overall_score            DECIMAL(5,2) NOT NULL DEFAULT 0 CHECK (overall_score BETWEEN 0 AND 100),
    weighted_review_avg      DECIMAL(4,3) CHECK (weighted_review_avg    BETWEEN 0 AND 5.0),
    -- weighted_review_avg shrunk toward a neutral prior by review count; this is
    -- what the trust score is actually computed from (see shrink_toward_prior)
    effective_review_avg     NUMERIC,
    revision_rate_score      DECIMAL(4,3) CHECK (revision_rate_score    BETWEEN 0 AND 1.0),
    responsiveness_score     DECIMAL(4,3) CHECK (responsiveness_score   BETWEEN 0 AND 1.0),
    communication_sentiment  DECIMAL(4,3) CHECK (communication_sentiment BETWEEN 0 AND 1.0),
    total_reviews            INT NOT NULL DEFAULT 0,
    category                 VARCHAR(100),
    category_rank_pct        DECIMAL(5,2) CHECK (category_rank_pct BETWEEN 0 AND 100),
    display_star_avg         DOUBLE PRECISION,
    last_updated             TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    -- review-derived fields (added via alter_table)
    on_time_score                NUMERIC,
    authenticity_confidence      NUMERIC,
    consistency_score            NUMERIC,
    ai_review_summary            TEXT,
    ai_review_summary_updated_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT fk_fts_freelancer FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_fts_overall_score ON freelancer_trust_scores (overall_score DESC);
CREATE INDEX IF NOT EXISTS idx_fts_category      ON freelancer_trust_scores (category);
CREATE INDEX IF NOT EXISTS idx_fts_category_rank ON freelancer_trust_scores (category, category_rank_pct);

CREATE TABLE IF NOT EXISTS trust_score_history (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id   UUID NOT NULL,
    overall_score   DECIMAL(5,2) NOT NULL,
    snapshot_reason trust_snapshot_reason NOT NULL DEFAULT 'review_published',
    recorded_at     TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    CONSTRAINT fk_tsh_freelancer FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_tsh_freelancer_id ON trust_score_history (freelancer_id);
CREATE INDEX IF NOT EXISTS idx_tsh_recorded_at   ON trust_score_history (freelancer_id, recorded_at DESC);

-- Client counterpart to trust_score_history. Append-only, so
-- check_and_create_red_flag can compare the new score against the previous
-- snapshot rather than against the row it just overwrote.
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

-- Subject is either a freelancer or a client, never both: one column per
-- profile table so each can carry a real FK, with subject_type kept as a
-- convenience discriminator for filtering.
CREATE TABLE IF NOT EXISTS red_flag_alerts (
    id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id UUID,
    client_id     UUID,
    alert_type    review_alert_type NOT NULL,
    severity      review_alert_severity NOT NULL,
    message       TEXT NOT NULL,
    is_resolved   BOOLEAN NOT NULL DEFAULT FALSE,
    triggered_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    resolved_at   TIMESTAMP WITH TIME ZONE,
    subject_type  VARCHAR(20) NOT NULL DEFAULT 'freelancer',
    CONSTRAINT fk_rfa_freelancer FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE,
    CONSTRAINT fk_rfa_client     FOREIGN KEY (client_id)     REFERENCES client(client_id)         ON DELETE CASCADE,
    CONSTRAINT red_flag_alerts_one_subject_check CHECK (num_nonnulls(freelancer_id, client_id) = 1)
);

CREATE INDEX IF NOT EXISTS idx_rfa_freelancer_id ON red_flag_alerts (freelancer_id);
CREATE INDEX IF NOT EXISTS idx_rfa_client_id     ON red_flag_alerts (client_id);
CREATE INDEX IF NOT EXISTS idx_rfa_freelancer_unresolved
    ON red_flag_alerts (freelancer_id, is_resolved) WHERE is_resolved = FALSE;
CREATE INDEX IF NOT EXISTS idx_rfa_client_unresolved
    ON red_flag_alerts (client_id, is_resolved)     WHERE is_resolved = FALSE;

CREATE TABLE IF NOT EXISTS report_auto_actions (
    action_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_type  TEXT NOT NULL,
    target_id    UUID NOT NULL,
    report_count INTEGER NOT NULL,
    created_at   TIMESTAMP DEFAULT NOW(),
    UNIQUE (target_type, target_id)
);

CREATE INDEX IF NOT EXISTS idx_raa_target ON report_auto_actions (target_type, target_id);

CREATE TABLE IF NOT EXISTS appeals (
    appeal_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id       UUID NOT NULL,
    target_type   TEXT NOT NULL,
    target_id     UUID NOT NULL,
    message       TEXT NOT NULL,
    status        TEXT NOT NULL DEFAULT 'pending',
    admin_user_id UUID,
    admin_note    TEXT,
    actioned_at   TIMESTAMP,
    created_at    TIMESTAMP DEFAULT NOW(),
    proof_file_url VARCHAR(500),
    FOREIGN KEY (user_id)       REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (admin_user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE INDEX IF NOT EXISTS idx_appeals_user   ON appeals (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_appeals_target ON appeals (target_type, target_id);
CREATE INDEX IF NOT EXISTS idx_appeals_status ON appeals (status, created_at DESC);

-- One row per (user, guideline section) once the user has confirmed they read it.
-- The guideline text itself lives in the Flutter app; this only tracks the ack.
CREATE TABLE IF NOT EXISTS user_guideline_ack (
    ack_id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id          UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    section          VARCHAR(20) NOT NULL CHECK (section IN ('general', 'freelancer', 'client')),
    acknowledged_at  TIMESTAMP DEFAULT NOW(),
    UNIQUE (user_id, section)
);

CREATE INDEX IF NOT EXISTS idx_user_guideline_ack_user_id ON user_guideline_ack (user_id);

CREATE TABLE IF NOT EXISTS notifications (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id UUID NOT NULL,
    type         TEXT NOT NULL,
    title        TEXT NOT NULL,
    body         TEXT NOT NULL,
    data         JSONB DEFAULT '{}',
    is_read      BOOLEAN DEFAULT FALSE,
    created_at   TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    FOREIGN KEY (recipient_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_notif_recipient ON notifications (recipient_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notif_unread    ON notifications (recipient_id) WHERE is_read = FALSE;

CREATE TABLE IF NOT EXISTS harmful_text_queue (
    -- PK constraint name is pinned so a fresh build mirrors the live DB exactly.
    moderation_id        UUID CONSTRAINT content_moderation_queue_pkey PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type         TEXT NOT NULL,
    content_id           UUID NOT NULL,
    user_id              UUID NOT NULL,
    toxic_score          DOUBLE PRECISION NOT NULL DEFAULT 0,
    obscene_score        DOUBLE PRECISION NOT NULL DEFAULT 0,
    threat_score         DOUBLE PRECISION NOT NULL DEFAULT 0,
    insult_score         DOUBLE PRECISION NOT NULL DEFAULT 0,
    identity_hate_score  DOUBLE PRECISION NOT NULL DEFAULT 0,
    detected_labels      JSONB NOT NULL DEFAULT '[]',
    flagged_text         TEXT,
    admin_user_id        UUID,
    admin_note           TEXT,
    status               TEXT NOT NULL DEFAULT 'pending',
    auto_approve_at      TIMESTAMP,
    actioned_at          TIMESTAMP,
    created_at           TIMESTAMP DEFAULT NOW(),
    CHECK (status IN ('pending', 'approved', 'rejected')),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (admin_user_id) REFERENCES users(user_id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_tq_content ON harmful_text_queue (content_type, content_id);
CREATE INDEX IF NOT EXISTS idx_htq_status  ON harmful_text_queue (status) WHERE status = 'pending';
CREATE UNIQUE INDEX IF NOT EXISTS idx_htq_content_pending_unique
    ON harmful_text_queue (content_type, content_id) WHERE status = 'pending';
