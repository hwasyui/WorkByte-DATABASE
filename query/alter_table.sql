-- Previously applied migrations are commented out below for reference.
-- Re-running this file is safe - all active statements use IF NOT EXISTS / IF EXISTS guards.

-- ── Drop legacy tables (job_milestone, job_payment) ──────────────────────────
-- DROP TABLE IF EXISTS job_milestone CASCADE;
-- DROP TABLE IF EXISTS job_payment CASCADE;
-- ALTER TABLE contract_milestone DROP COLUMN IF EXISTS job_milestone_id;

-- ── Fix vector dimensions to 768 ─────────────────────────────────────────────
-- ALTER TABLE freelancer_embedding DROP COLUMN IF EXISTS embedding_vector;
-- ALTER TABLE freelancer_embedding ADD COLUMN embedding_vector VECTOR(768);
-- ALTER TABLE freelancer_embedding ALTER COLUMN source_text DROP NOT NULL;
-- ALTER TABLE freelancer_embedding ADD COLUMN IF NOT EXISTS embedding_dirty BOOLEAN NOT NULL DEFAULT TRUE;

-- ALTER TABLE job_embedding DROP COLUMN IF EXISTS embedding_vector;
-- ALTER TABLE job_embedding ADD COLUMN embedding_vector VECTOR(768);
-- ALTER TABLE job_embedding ALTER COLUMN source_text DROP NOT NULL;
-- ALTER TABLE job_embedding ADD COLUMN IF NOT EXISTS embedding_dirty BOOLEAN NOT NULL DEFAULT TRUE;

-- ── HNSW indexes ──────────────────────────────────────────────────────────────
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

-- ── Contract embedding table ──────────────────────────────────────────────────
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

-- ── Standardise "projects" → "jobs" naming ───────────────────────────────────
-- ALTER TABLE client RENAME COLUMN total_projects_completed TO total_jobs_completed;
-- ALTER TABLE freelancer RENAME COLUMN total_projects TO total_jobs;

-- ── Add missing rating columns ────────────────────────────────────────────────
-- ALTER TABLE rating ADD COLUMN IF NOT EXISTS update_count INTEGER DEFAULT 0;
-- ALTER TABLE rating ADD COLUMN IF NOT EXISTS updated_at   TIMESTAMP DEFAULT NOW();

-- ── Enforce one proposal per freelancer per job role ──────────────────────────
-- ALTER TABLE proposal ADD CONSTRAINT uq_proposal_freelancer_role UNIQUE (freelancer_id, job_role_id);

-- ── Add contract PDF metadata columns ────────────────────────────────────────
-- ALTER TABLE contract ADD COLUMN IF NOT EXISTS contract_pdf_url VARCHAR(500);
-- ALTER TABLE contract ADD COLUMN IF NOT EXISTS contract_pdf_generated_at TIMESTAMP;

-- ── Add payment-flow flag columns to contract_milestone ──────────────────────
-- ALTER TABLE contract_milestone ADD COLUMN IF NOT EXISTS client_approved          BOOLEAN DEFAULT FALSE;
-- ALTER TABLE contract_milestone ADD COLUMN IF NOT EXISTS payment_requested        BOOLEAN DEFAULT FALSE;
-- ALTER TABLE contract_milestone ADD COLUMN IF NOT EXISTS payment_released         BOOLEAN DEFAULT FALSE;
-- ALTER TABLE contract_milestone ADD COLUMN IF NOT EXISTS freelancer_confirmed_paid BOOLEAN DEFAULT FALSE;

-- ── Remove contract_milestone, job_milestone, job_payment; add payment_schedule ─
DROP TABLE IF EXISTS contract_milestone CASCADE;
DROP TABLE IF EXISTS job_milestone CASCADE;
DROP TABLE IF EXISTS job_payment CASCADE;
DROP TYPE IF EXISTS milestone_status CASCADE;
ALTER TABLE contract_terms ADD COLUMN IF NOT EXISTS payment_schedule TEXT;

-- ── Add contract_terms table ──────────────────────────────────────────────────
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
