-- ─── 1. job_payment ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS job_payment (
    job_payment_id   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    job_post_id      UUID         NOT NULL REFERENCES job_post(job_post_id) ON DELETE CASCADE,
    payment_type     VARCHAR(20)  NOT NULL CHECK (payment_type IN ('full', 'milestone')),
    payment_option   VARCHAR(50)  NOT NULL,
    status           VARCHAR(20)  NOT NULL DEFAULT 'pending',
    created_at       TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_job_payment_job_post_id
    ON job_payment(job_post_id);


-- ─── 2. job_milestone ─────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS job_milestone (
    milestone_id        UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    job_payment_id      UUID         NOT NULL REFERENCES job_payment(job_payment_id) ON DELETE CASCADE,
    milestone_order     INT          NOT NULL,
    work_progress       VARCHAR(50)  NOT NULL,
    payment_percentage  VARCHAR(50)  NOT NULL,
    created_at          TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_job_milestone_payment_id
    ON job_milestone(job_payment_id);


-- ─── 3. contract_milestone — add ONE new column only ─────────────────────────
ALTER TABLE contract_milestone
    ADD COLUMN IF NOT EXISTS job_milestone_id UUID
        REFERENCES job_milestone(milestone_id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_contract_milestone_job_milestone_id
    ON contract_milestone(job_milestone_id);