-- Previously applied migrations are commented out below for reference.
-- Re-running this file is safe - all active statements use IF NOT EXISTS / IF EXISTS guards.

-- Fix vector dimensions to 768 (both nomic-embed-text and text-embedding-005 produce 768-dim,
-- not 1536). Also add the dirty flag and HNSW indexes. Columns are nullable so a row
-- can exist before the embedding is actually generated (e.g. while Ollama is warming up).

-- -- freelancer_embedding
-- ALTER TABLE freelancer_embedding DROP COLUMN IF EXISTS embedding_vector;
-- ALTER TABLE freelancer_embedding ADD COLUMN embedding_vector VECTOR(768);
-- ALTER TABLE freelancer_embedding ALTER COLUMN source_text DROP NOT NULL;
-- ALTER TABLE freelancer_embedding ADD COLUMN IF NOT EXISTS embedding_dirty BOOLEAN NOT NULL DEFAULT TRUE;

-- -- job_embedding
-- ALTER TABLE job_embedding DROP COLUMN IF EXISTS embedding_vector;
-- ALTER TABLE job_embedding ADD COLUMN embedding_vector VECTOR(768);
-- ALTER TABLE job_embedding ALTER COLUMN source_text DROP NOT NULL;
-- ALTER TABLE job_embedding ADD COLUMN IF NOT EXISTS embedding_dirty BOOLEAN NOT NULL DEFAULT TRUE;

-- -- HNSW indexes for fast cosine similarity (only on rows that have a vector)
-- CREATE INDEX IF NOT EXISTS idx_freelancer_embedding_hnsw
--     ON freelancer_embedding USING hnsw (embedding_vector vector_cosine_ops)
--     WHERE embedding_vector IS NOT NULL;

-- CREATE INDEX IF NOT EXISTS idx_job_embedding_hnsw
--     ON job_embedding USING hnsw (embedding_vector vector_cosine_ops)
--     WHERE embedding_vector IS NOT NULL;

-- -- Partial indexes on dirty flag to accelerate sweep queries
-- CREATE INDEX IF NOT EXISTS idx_freelancer_embedding_dirty
--     ON freelancer_embedding (embedding_dirty)
--     WHERE embedding_dirty = TRUE;

-- CREATE INDEX IF NOT EXISTS idx_job_embedding_dirty
--     ON job_embedding (embedding_dirty)
--     WHERE embedding_dirty = TRUE;


-- -- Contract embedding table. Stores vectors for completed contracts so the RAG
-- -- analyser can pull semantically similar past work. source_text combines job title,
-- -- role title, description, and review text. freelancer_id is denormalised here
-- -- for fast per-freelancer lookups.

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
-- RETURNS TRIGGER AS $$
-- BEGIN
--     NEW.updated_at = NOW();
--     RETURN NEW;
-- END;
-- $$ LANGUAGE plpgsql;

-- DROP TRIGGER IF EXISTS trg_contract_embedding_updated_at ON contract_embedding;
-- CREATE TRIGGER trg_contract_embedding_updated_at
--     BEFORE UPDATE ON contract_embedding
--     FOR EACH ROW EXECUTE FUNCTION set_contract_embedding_updated_at();

-- -- HNSW index for cosine similarity search on contract embeddings
-- CREATE INDEX IF NOT EXISTS idx_contract_embedding_hnsw
--     ON contract_embedding USING hnsw (embedding_vector vector_cosine_ops)
--     WHERE embedding_vector IS NOT NULL;

-- -- Partial index on dirty flag for sweep worker
-- CREATE INDEX IF NOT EXISTS idx_contract_embedding_dirty
--     ON contract_embedding (embedding_dirty)
--     WHERE embedding_dirty = TRUE;

-- -- Index for per-freelancer contract embedding lookups (RAG retrieval)
-- CREATE INDEX IF NOT EXISTS idx_contract_embedding_freelancer
--     ON contract_embedding (freelancer_id)
--     WHERE embedding_vector IS NOT NULL;


-- ── Standardise "projects" → "jobs" naming ───────────────────────────────────
--
-- contract_status deliberately keeps only: active | completed | cancelled | disputed
--   completed  → work done, counters incremented, contract embedded for RAG
--   cancelled  → work stopped; a new contract can be drafted for the same role
--   (job_post.status already has its own 'closed' value — different concept)
--
-- posted_at / closed_at on job_post are wired up in app logic:
--   posted_at  → set when job_post.status transitions to 'active'
--   closed_at  → set when job_post.status transitions to 'closed' or 'filled',
--                and also auto-set when a contract is first created for that job post

-- -- Rename client counter: total_projects_completed → total_jobs_completed
-- ALTER TABLE client RENAME COLUMN total_projects_completed TO total_jobs_completed;

-- -- Rename freelancer counter: total_projects → total_jobs
-- ALTER TABLE freelancer RENAME COLUMN total_projects TO total_jobs;

-- -- ── Add missing rating columns ────────────────────────────────────────────────
-- -- update_count and updated_at were in create_table.sql but not in the original
-- -- live schema. Add them so rating insert/update logic works correctly.
-- ALTER TABLE rating ADD COLUMN IF NOT EXISTS update_count INTEGER DEFAULT 0;
-- ALTER TABLE rating ADD COLUMN IF NOT EXISTS updated_at   TIMESTAMP DEFAULT NOW();

-- Add contract PDF metadata columns to support generated contract storage.
ALTER TABLE contract ADD COLUMN IF NOT EXISTS contract_pdf_url VARCHAR(500);
ALTER TABLE contract ADD COLUMN IF NOT EXISTS contract_pdf_generated_at TIMESTAMP;

-- Add contract_terms table for legal clause storage alongside generated PDFs.
CREATE TABLE IF NOT EXISTS contract_terms (
    contract_terms_id      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id            UUID NOT NULL UNIQUE,
    termination_notice     INTEGER,
    governing_law          VARCHAR(100),
    confidentiality        BOOLEAN DEFAULT FALSE,
    confidentiality_text   TEXT,
    late_payment_penalty   DECIMAL(5, 2),
    dispute_resolution     VARCHAR(50),
    revision_rounds        INTEGER,
    additional_clauses     TEXT,
    created_at             TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (contract_id) REFERENCES contract(contract_id) ON DELETE CASCADE
);
