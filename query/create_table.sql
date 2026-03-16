CREATE TYPE user_type             AS ENUM ('freelancer', 'client');
CREATE TYPE rate_time_type        AS ENUM ('hourly', 'weekly', 'monthly', 'annually');
CREATE TYPE skill_category_type   AS ENUM ('hard_skill', 'soft_skill', 'tool');
CREATE TYPE proficiency_skill     AS ENUM ('beginner', 'intermediate', 'advanced', 'expert');
CREATE TYPE proficiency_language  AS ENUM ('basic', 'conversational', 'fluent', 'native');
CREATE TYPE project_type          AS ENUM ('individual', 'team');
CREATE TYPE project_scope         AS ENUM ('small', 'medium', 'large');
CREATE TYPE experience_level      AS ENUM ('entry', 'intermediate', 'expert');
CREATE TYPE job_status            AS ENUM ('draft', 'active', 'closed', 'filled');
CREATE TYPE budget_type           AS ENUM ('fixed', 'negotiable');
CREATE TYPE importance_level      AS ENUM ('nice_to_have', 'preferred', 'required');
CREATE TYPE proposal_status       AS ENUM ('pending', 'accepted', 'rejected', 'withdrawn');
CREATE TYPE payment_structure     AS ENUM ('full_payment', 'milestone_based');
CREATE TYPE contract_status       AS ENUM ('active', 'completed', 'cancelled', 'disputed');
CREATE TYPE milestone_status      AS ENUM ('pending', 'in_progress', 'completed', 'paid');

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TABLE IF NOT EXISTS users (
    user_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email      VARCHAR(255) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    type       user_type NOT NULL DEFAULT 'freelancer',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS freelancer (
    freelancer_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL UNIQUE,
    full_name           VARCHAR(255) NOT NULL,
    bio                 TEXT,
    cv_file_url         VARCHAR(500),
    profile_picture_url VARCHAR(500),
    estimated_rate      DECIMAL(10, 2),
    rate_time           rate_time_type DEFAULT 'hourly',
    rate_currency       VARCHAR(10) DEFAULT 'USD',
    total_projects      INTEGER DEFAULT 0,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_freelancer_updated_at
    BEFORE UPDATE ON freelancer
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS client (
    client_id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id                   UUID NOT NULL UNIQUE,
    company_name              VARCHAR(255),
    company_description       TEXT,
    website_url               VARCHAR(500),
    total_jobs_posted         INTEGER DEFAULT 0,
    total_projects_completed  INTEGER DEFAULT 0,
    average_rating_given      DECIMAL(3, 2),
    created_at                TIMESTAMP DEFAULT NOW(),
    updated_at                TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_client_updated_at
    BEFORE UPDATE ON client
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS skill (
    skill_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    skill_name     VARCHAR(100) NOT NULL UNIQUE,
    skill_category skill_category_type,
    description    TEXT,
    created_at     TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS speciality (
    speciality_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    speciality_name VARCHAR(100) NOT NULL UNIQUE,
    description     TEXT,
    created_at      TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS language (
    language_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    language_name VARCHAR(100) NOT NULL UNIQUE,
    iso_code      VARCHAR(10) UNIQUE,
    created_at    TIMESTAMP DEFAULT NOW()
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

CREATE TABLE IF NOT EXISTS freelancer_speciality (
    freelancer_speciality_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id            UUID NOT NULL,
    speciality_id            UUID NOT NULL,
    is_primary               BOOLEAN DEFAULT FALSE,
    created_at               TIMESTAMP DEFAULT NOW(),
    UNIQUE (freelancer_id, speciality_id),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE,
    FOREIGN KEY (speciality_id) REFERENCES speciality(speciality_id) ON DELETE CASCADE
);

CREATE OR REPLACE FUNCTION check_max_specialities()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM freelancer_speciality WHERE freelancer_id = NEW.freelancer_id) >= 3 THEN
        RAISE EXCEPTION 'Freelancer cannot have more than 3 specialities';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_max_specialities
    BEFORE INSERT ON freelancer_speciality
    FOR EACH ROW EXECUTE FUNCTION check_max_specialities();

CREATE TABLE IF NOT EXISTS freelancer_language (
    freelancer_language_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id          UUID NOT NULL,
    language_id            UUID NOT NULL,
    proficiency_level      proficiency_language NOT NULL,
    created_at             TIMESTAMP DEFAULT NOW(),
    UNIQUE (freelancer_id, language_id),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE,
    FOREIGN KEY (language_id)   REFERENCES language(language_id)     ON DELETE CASCADE
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
    FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_job_post_updated_at
    BEFORE UPDATE ON job_post
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

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
    job_role_id       UUID,
    freelancer_id     UUID NOT NULL,
    cover_letter      TEXT NOT NULL,
    proposed_budget   DECIMAL(12, 2) NOT NULL,
    proposed_duration VARCHAR(100),
    status            proposal_status NOT NULL,
    is_ai_generated   BOOLEAN DEFAULT FALSE,
    submitted_at      TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (job_post_id)   REFERENCES job_post(job_post_id)     ON DELETE CASCADE,
    FOREIGN KEY (job_role_id)   REFERENCES job_role(job_role_id)     ON DELETE SET NULL,
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
    contract_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_post_id            UUID NOT NULL,
    job_role_id            UUID NOT NULL,
    proposal_id            UUID NOT NULL,
    freelancer_id          UUID NOT NULL,
    client_id              UUID NOT NULL,
    contract_title         VARCHAR(255) NOT NULL,
    role_title             VARCHAR(255),
    agreed_budget          DECIMAL(12, 2) NOT NULL,
    budget_currency        VARCHAR(10) DEFAULT 'USD',
    payment_structure      payment_structure NOT NULL,
    agreed_duration        VARCHAR(100),
    status                 contract_status NOT NULL,
    start_date             DATE NOT NULL,
    end_date               DATE,
    actual_completion_date DATE,
    total_hours_worked     DECIMAL(8, 2),
    total_paid             DECIMAL(12, 2) DEFAULT 0,
    created_at             TIMESTAMP DEFAULT NOW(),
    updated_at             TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (job_post_id)   REFERENCES job_post(job_post_id)     ON DELETE RESTRICT,
    FOREIGN KEY (job_role_id)   REFERENCES job_role(job_role_id)     ON DELETE RESTRICT,
    FOREIGN KEY (proposal_id)   REFERENCES proposal(proposal_id)     ON DELETE RESTRICT,
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE RESTRICT,
    FOREIGN KEY (client_id)     REFERENCES client(client_id)         ON DELETE RESTRICT
);

CREATE TRIGGER trg_contract_updated_at
    BEFORE UPDATE ON contract
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS contract_milestone (
    milestone_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id           UUID NOT NULL,
    milestone_title       VARCHAR(255) NOT NULL,
    milestone_description TEXT,
    milestone_percentage  DECIMAL(5, 2) NOT NULL,
    milestone_amount      DECIMAL(12, 2) NOT NULL,
    milestone_order       INTEGER NOT NULL,
    due_date              DATE,
    status                milestone_status NOT NULL,
    completed_at          TIMESTAMP,
    paid_at               TIMESTAMP,
    created_at            TIMESTAMP DEFAULT NOW(),
    updated_at            TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (contract_id) REFERENCES contract(contract_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_contract_milestone_updated_at
    BEFORE UPDATE ON contract_milestone
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS portfolio (
    portfolio_id        UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id       UUID NOT NULL,
    project_title       VARCHAR(255) NOT NULL,
    project_description TEXT NOT NULL,
    project_url         VARCHAR(255),
    completion_date     DATE,
    is_auto_generated   BOOLEAN DEFAULT FALSE,
    contract_id         UUID,
    created_at          TIMESTAMP DEFAULT NOW(),
    updated_at          TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE,
    FOREIGN KEY (contract_id) REFERENCES contract(contract_id) ON DELETE SET NULL
);

CREATE TRIGGER trg_portfolio_updated_at
    BEFORE UPDATE ON portfolio
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

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

CREATE TABLE IF NOT EXISTS rating (
    rating_id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id               UUID NOT NULL UNIQUE,
    client_id                 UUID NOT NULL,
    freelancer_id             UUID NOT NULL,
    communication_score       INTEGER CHECK (communication_score BETWEEN 1 AND 5),
    result_quality_score      INTEGER CHECK (result_quality_score BETWEEN 1 AND 5),
    professionalism_score     INTEGER CHECK (professionalism_score BETWEEN 1 AND 5),
    timeline_compliance_score INTEGER CHECK (timeline_compliance_score BETWEEN 1 AND 5),
    overall_rating            DECIMAL(3, 2),
    review_text               TEXT,
    created_at                TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (contract_id)   REFERENCES contract(contract_id)     ON DELETE CASCADE,
    FOREIGN KEY (client_id)     REFERENCES client(client_id)         ON DELETE RESTRICT,
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS performance_rating (
    performance_rating_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id               UUID NOT NULL UNIQUE,
    overall_performance_score   DECIMAL(5, 2),
    confidence_score            DECIMAL(5, 2),
    total_ratings_received      INTEGER DEFAULT 0,
    average_communication       DECIMAL(3, 2),
    average_result_quality      DECIMAL(3, 2),
    average_professionalism     DECIMAL(3, 2),
    average_scope_compliance    DECIMAL(3, 2),
    average_timeline_compliance DECIMAL(3, 2),
    success_rate                DECIMAL(5, 2),
    last_calculated_at          TIMESTAMP,
    updated_at                  TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_performance_rating_updated_at
    BEFORE UPDATE ON performance_rating
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS client_trust_score (
    client_trust_score_id    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id                UUID NOT NULL UNIQUE,
    trust_score              DECIMAL(5, 2),
    rating_consistency_score DECIMAL(5, 2),
    extreme_rating_ratio     DECIMAL(5, 2),
    project_completion_rate  DECIMAL(5, 2),
    average_budget_gap       DECIMAL(5, 2),
    total_ratings_given      INTEGER DEFAULT 0,
    last_calculated_at       TIMESTAMP,
    updated_at               TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (client_id) REFERENCES client(client_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_client_trust_score_updated_at
    BEFORE UPDATE ON client_trust_score
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS freelancer_embedding (
    embedding_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    freelancer_id      UUID NOT NULL UNIQUE,
    embedding_vector   VECTOR(1536) NOT NULL,
    source_text        TEXT NOT NULL,
    embedding_metadata JSONB,
    created_at         TIMESTAMP DEFAULT NOW(),
    updated_at         TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (freelancer_id) REFERENCES freelancer(freelancer_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_freelancer_embedding_updated_at
    BEFORE UPDATE ON freelancer_embedding
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS job_embedding (
    embedding_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    job_post_id        UUID NOT NULL UNIQUE,
    embedding_vector   VECTOR(1536) NOT NULL,
    source_text        TEXT NOT NULL,
    embedding_metadata JSONB,
    created_at         TIMESTAMP DEFAULT NOW(),
    updated_at         TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (job_post_id) REFERENCES job_post(job_post_id) ON DELETE CASCADE
);

CREATE TRIGGER trg_job_embedding_updated_at
    BEFORE UPDATE ON job_embedding
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS message (
    message_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_id    UUID NOT NULL,
    receiver_id  UUID NOT NULL,
    contract_id  UUID,
    message_text TEXT NOT NULL,
    is_read      BOOLEAN DEFAULT FALSE,
    read_at      TIMESTAMP,
    sent_at      TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (sender_id)   REFERENCES users(user_id)        ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id)        ON DELETE CASCADE,
    FOREIGN KEY (contract_id) REFERENCES contract(contract_id) ON DELETE SET NULL
);