-- Add contract PDF metadata columns and create the contract_terms table.

ALTER TABLE contract
  ADD COLUMN IF NOT EXISTS contract_pdf_url VARCHAR(500),
  ADD COLUMN IF NOT EXISTS contract_pdf_generated_at TIMESTAMP;

CREATE TABLE IF NOT EXISTS contract_terms (
    contract_terms_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_id           UUID NOT NULL UNIQUE,
    termination_notice    INTEGER,
    governing_law         VARCHAR(100),
    confidentiality       BOOLEAN DEFAULT FALSE,
    confidentiality_text  TEXT,
    late_payment_penalty  DECIMAL(5, 2),
    dispute_resolution    VARCHAR(50),
    revision_rounds       INTEGER,
    additional_clauses    TEXT,
    created_at            TIMESTAMP DEFAULT NOW(),
    FOREIGN KEY (contract_id)
        REFERENCES contract(contract_id) ON DELETE CASCADE
);
