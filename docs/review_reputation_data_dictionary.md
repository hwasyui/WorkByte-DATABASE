# Review & Reputation — Data Dictionary

Source: `query/create_table.sql` + `query/alter_table.sql`. 19 tables: 17 active, 2 legacy (still live, untouched by recent migrations), plus 1 table (`bias_detection_log`) dropped by a later migration — noted where relevant.

**Legend:** `PK` primary key · `FK` foreign key · `UQ` unique constraint · *(later)* added by a later migration in `alter_table.sql`.

---

## 1. Freelancer review pipeline

Client rates a freelancer after a contract closes. One `reviews` row per contract, fanned out into per-category ratings, free-text content, skill tags, and an AI-analysis verdict that gates publication.

`contract completes → reviews → {review_ratings, review_written_content, review_skill_tags} → review_ai_analysis → freelancer_trust_scores`

### `reviews`
One row per contract-review. The client is always `reviewer_id`, the freelancer is always `freelancer_id`; both point at `users.user_id`, not the `client`/`freelancer` profile tables. `status` gates visibility — a review only counts toward reputation once `published`.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `contract_id` **FK→contract** **UQ** | uuid | Unique — a contract can only be reviewed once |
| `reviewer_id` **FK→users** | uuid | The client writing the review |
| `freelancer_id` **FK→users** | uuid | The freelancer being reviewed |
| `inferred_category` | varchar(100) | Default `'general'`. Drives which `ai_review_prompts` question is shown, and the `category` bucket used later in `freelancer_trust_scores` |
| `status` | enum: pending, published, flagged, suppressed | Only `published` reviews feed trust scores / public profile |
| `is_anonymous` | boolean | Hides reviewer identity on display |
| `created_at` / `published_at` | timestamptz | `published_at` nullable until it clears moderation |

### `review_ratings`
Per-category star scores for a review (e.g. communication, quality). One row per category, 1.0–5.0.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `review_id` **FK→reviews** | uuid | On delete cascade |
| `category` | varchar(50) | Free-form category label |
| `score` | decimal(2,1) | CHECK 1.0–5.0 |

> **Constraint:** `UNIQUE(review_id, category)` — a review can't rate the same category twice. Contrast with `client_review_ratings` below, which has no equivalent constraint.

### `review_written_content`
The free-text part of a review, including the AI's follow-up question and the client's answer to it.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `review_id` **FK→reviews** **UQ** | uuid | 1:1 with reviews |
| `ai_question` | text | Question pulled from `ai_review_prompts` for this review's category |
| `client_answer` | text | Client's answer to `ai_question` |
| `overall_comment` | text | Free-text review body |

### `review_skill_tags`
Skills a client attributes to the freelancer via this review, either self-selected or AI-suggested.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `review_id` **FK→reviews** | uuid | |
| `skill_tag` | varchar(100) | `UNIQUE(review_id, skill_tag)` |
| `is_ai_suggested` | boolean | Distinguishes AI-suggested tags from client-picked ones |

### `ai_review_prompts`
Standalone lookup table — a bank of AI-authored follow-up questions keyed by project category, not tied to any one review. Feeds `review_written_content.ai_question` at review-creation time.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `project_category` | varchar(100) | Matches `reviews.inferred_category` |
| `question_text` | text | |
| `is_active` | boolean | Inactive prompts are retired, not deleted |
| `created_at` | timestamptz | |

### `review_ai_analysis`
Output of three trained models run against a review: a sentiment classifier, an authenticity classifier, and a sentiment/rating-mismatch regressor. `overall_pass` is the automated gate a review must clear before publishing.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `review_id` **FK→reviews** **UQ** | uuid | 1:1 with reviews |
| `sentiment_score` / `sentiment_label` | decimal(4,3) [-1,1] / enum | positive / neutral / negative |
| `sentiment_mismatch` | boolean | Text sentiment disagrees with the numeric rating |
| `mismatch_severity` *(later)* | numeric | Continuous \|predicted − actual rating\| from the mismatch regressor, alongside the boolean above |
| `authenticity_score` | decimal(4,3) [0,1] | |
| `is_flagged_fake` / `is_flagged_coerced` | boolean | |
| `flag_reasons` | jsonb array | Default `[]` |
| `overall_pass` | boolean | Default `FALSE` — publishing requires an explicit pass |
| `analyzed_at` | timestamptz | |

> **Removed:** `bias_score` and `bias_flags` columns were dropped from this table (and the mirrored `client_review_ai_analysis`) — bias detection was a single-LLM self-report with no ground truth to check against, and was cut. The companion `bias_detection_log` table was dropped outright as write-only and never read.

---

## 2. Client review pipeline

The symmetric counterpart, added later: the freelancer reviews the client after the same contract closes. Structurally mirrors the pipeline above one-for-one, but with no payment data on this platform to draw on, its inputs are narrower — review text/ratings, DM responsiveness, and dispute-arbitration fairness.

`contract completes → client_reviews → {client_review_ratings, client_review_written_content} → client_review_ai_analysis → client_trust_score`

### `client_reviews`
One row per contract, freelancer reviewing client. Mirrors `reviews` field-for-field, but `status` is a plain `varchar` here rather than the `review_status` enum.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `contract_id` **FK→contract** **UQ** | uuid | |
| `reviewer_id` | uuid | Freelancer's `user_id` — **no FK constraint** despite the semantics |
| `client_id` | uuid | Client's `user_id` being reviewed — **no FK constraint** |
| `status` | varchar(20) | pending / published / flagged / suppressed, by convention only (not enum-enforced) |
| `is_anonymous` | boolean | |
| `created_at` / `published_at` | timestamp | |

> **Integrity gap:** unlike `reviews`, `reviewer_id` and `client_id` aren't declared as foreign keys to `users` — referential integrity here is enforced by application code only.

### `client_review_ratings`
Per-category scores a freelancer gives a client: communication, clarity_of_requirements, responsiveness, professionalism.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `client_review_id` **FK→client_reviews** | uuid | On delete cascade |
| `category` | varchar(50) | |
| `score` | numeric | No range CHECK and no per-category uniqueness — both present on the freelancer-side `review_ratings`, absent here |

### `client_review_written_content`
Free-text content, mirroring `review_written_content` with the answerer flipped to the freelancer.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `client_review_id` **FK→client_reviews** | uuid | Not declared unique, unlike `review_written_content.review_id` |
| `ai_question` | text | |
| `freelancer_answer` | text | |
| `overall_comment` | text | |

### `client_review_ai_analysis`
Mirrors `review_ai_analysis`. `overall_pass` defaults to `TRUE` here (vs. `FALSE` on the freelancer side) — a client review publishes unless flagged, rather than requiring an explicit pass.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `client_review_id` **FK→client_reviews** | uuid | |
| `sentiment_score` / `sentiment_label` | numeric / varchar(20) | |
| `sentiment_mismatch` / `mismatch_severity` | boolean / numeric | |
| `authenticity_score` | numeric | |
| `is_flagged_fake` / `is_flagged_coerced` | boolean | |
| `flag_reasons` | jsonb | |
| `overall_pass` | boolean | Default `TRUE` |

> **Removed:** `bias_score`/`bias_flags` dropped — never actually populated by this pipeline (always `0.0`/`{}`).

---

## 3. Reputation & trust scoring

Rollup layer that turns individual reviews plus objective per-contract signals into the composite scores actually shown on a profile, with a time-series audit trail and an alerting table for anomalies.

### `freelancer_performance_scores`
Objective, per-contract signals — not reviewer-given — computed automatically and later rolled up into `freelancer_trust_scores`.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `contract_id` **FK→contract** **UQ** | uuid | |
| `freelancer_id` **FK→users** | uuid | |
| `work_quality_score` / `work_quality_notes` | decimal(4,3) [0,1] / text | |
| `on_time_score` | decimal(4,3) [0,1] | |
| `revision_count` / `revision_rate_score` | int / decimal(4,3) | |
| `responsiveness_score` | decimal(4,3) [0,1] | |
| `communication_sentiment_score` / `communication_summary` | decimal(4,3) / text | |
| `conflict_score` | decimal(4,3) [0,1] | |
| `computed_at` | timestamptz | |

### `freelancer_trust_scores`
The composite reputation record shown on a freelancer's profile — one row per freelancer, recomputed as reviews and contracts land.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `freelancer_id` **FK→users** **UQ** | uuid | |
| `overall_score` | decimal(5,2) [0,100] | The headline composite number |
| `weighted_review_avg` | decimal(4,3) [0,5] | |
| `work_quality_score` / `revision_rate_score` / `responsiveness_score` / `communication_sentiment` | decimal(4,3) [0,1] | Rolled up from `freelancer_performance_scores` |
| `on_time_score` *(later)* | numeric | Aggregated on-time delivery — previously computed per-contract only, not stored at this level |
| `authenticity_confidence` *(later)* | numeric | From the trained authenticity classifier |
| `consistency_score` *(later)* | numeric | From the mismatch regressor |
| `total_reviews` | int | |
| `category` / `category_rank_pct` | varchar(100) / decimal(5,2) [0,100] | Percentile rank among freelancers in the same category |
| `display_star_avg` | double precision | Simple average shown to end users, distinct from the weighted composite |
| `ai_review_summary` / `_updated_at` *(later)* | text / timestamptz | AI-generated profile blurb synthesizing published reviews; regenerated every N reviews (3, 8, 13…), not on every publish. Stays `NULL` until a review-count floor is crossed |
| `last_updated` | timestamptz | |

### `trust_score_history`
Append-only time series of `freelancer_trust_scores.overall_score`, one snapshot per recalculation.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `freelancer_id` **FK→users** | uuid | |
| `overall_score` | decimal(5,2) | |
| `snapshot_reason` | enum | review_published, dispute_closed, score_recalculated, manual_adjustment |
| `recorded_at` | timestamptz | |

### `client_trust_score`
Carries *two* distinct roles in one row: legacy columns tracking a client's quality *as a rater* of freelancers, plus newer columns tracking the client's own reputation *as reviewed by* freelancers via `client_reviews`.

| Field | Type | Notes |
|---|---|---|
| `client_trust_score_id` **PK** | uuid | |
| `client_id` **FK→users** **UQ** | uuid | Column name is a holdover — repointed by migration from `client.client_id` to `users.user_id` |
| `trust_score` | decimal(5,2) | Repurposed as the composite output; previously a dormant, manually-set field with no calculation engine behind it |
| `rating_consistency_score` / `extreme_rating_ratio` / `total_ratings_given` | decimal(5,2) / decimal(5,2) / int | *Legacy — client as rater.* Populated only via a standalone, frontend-unreachable CRUD API; never auto-computed |
| `project_completion_rate` / `average_budget_gap` | decimal(5,2) | *Legacy — dormant* |
| `weighted_review_avg_received` / `total_reviews_received` *(later)* | numeric / int | *Current — client as reviewed subject* |
| `responsiveness_score` / `communication_sentiment` *(later)* | numeric | From DM responsiveness — no payment data exists on this platform to score against instead |
| `authenticity_confidence` / `consistency_score` *(later)* | numeric | Symmetric to the freelancer-side model outputs |
| `dispute_fairness_score` *(later)* | numeric | From dispute-arbitration outcomes |
| `ai_review_summary` *(later)* | text | Client-side counterpart to `freelancer_trust_scores.ai_review_summary`; reuses the table's existing `updated_at` trigger instead of a separate timestamp column |
| `last_calculated_at` / `updated_at` | timestamp | `updated_at` auto-maintained by trigger |

> **Watch for:** two unrelated scoring systems share this table. `trust_score` is now the current composite output, but the FK repoint means historical rows keyed to the old `client(client_id)` may not resolve the same way against `users.user_id` going forward.

### `red_flag_alerts`
Anomaly alerts raised against a subject's reputation trend. Originally freelancer-only; the `subject_type` column extends it to clients without duplicating the table.

| Field | Type | Notes |
|---|---|---|
| `id` **PK** | uuid | |
| `freelancer_id` **FK→users** | uuid | Column name is legacy — really "subject's user_id" now |
| `subject_type` *(later)* | varchar(20) | Default `'freelancer'`, so existing rows keep their original meaning unchanged |
| `alert_type` | enum | score_drop, spike_in_revisions, fake_review_pattern, high_conflict_detected |
| `severity` | enum: low, medium, high | |
| `message` | text | |
| `is_resolved` / `triggered_at` / `resolved_at` | boolean / timestamptz / timestamptz | |

---

## 4. Legacy rating system

An earlier, simpler client → freelancer rating model that predates the `reviews` pipeline. Both tables are still present and unmodified by recent migrations — nothing in this repo drops or renames them, so treat them as still-live until confirmed otherwise against the application code.

### `rating`
Single-table rating + free-text review, one row per contract. Structurally the predecessor of `reviews` + `review_ratings` + `review_written_content` combined — no AI analysis layer.

| Field | Type | Notes |
|---|---|---|
| `rating_id` **PK** | uuid | |
| `contract_id` **FK→contract** **UQ** | uuid | |
| `client_id` **FK→client** | uuid | Points at the `client` profile table, not `users` — unlike the newer `reviews` table |
| `freelancer_id` **FK→freelancer** | uuid | Points at the `freelancer` profile table, not `users` |
| `communication_score` / `result_quality_score` / `professionalism_score` / `timeline_compliance_score` | int [1,5] | Four fixed sub-scores |
| `overall_rating` | decimal(3,2) | |
| `review_text` | text | |
| `update_count` | int | |
| `created_at` / `updated_at` | timestamp | Auto-maintained by trigger |

### `performance_rating`
Per-freelancer rollup of `rating` — the legacy analogue of `freelancer_trust_scores`.

| Field | Type | Notes |
|---|---|---|
| `performance_rating_id` **PK** | uuid | |
| `freelancer_id` **FK→freelancer** **UQ** | uuid | |
| `overall_performance_score` / `confidence_score` | decimal(5,2) | |
| `total_ratings_received` | int | |
| `average_communication` / `average_result_quality` / `average_professionalism` / `average_scope_compliance` / `average_timeline_compliance` | decimal(3,2) | Five sub-score averages |
| `success_rate` | decimal(5,2) | |
| `last_calculated_at` / `updated_at` | timestamp | |

---

## 5. Shared moderation infra

Not review-specific — these are generic, polymorphic tables (`content_type`/`target_type` + a bare `uuid`) that reviews pass through alongside job posts, profiles, and other user content. Included because a suppressed or flagged review typically shows up here.

### `harmful_text_queue`
Toxicity-classifier output for any flagged text content, including review bodies. `content_type`/`content_id` is a polymorphic pointer — no FK, resolved in application code.

| Field | Type | Notes |
|---|---|---|
| `moderation_id` **PK** | uuid | |
| `content_type` / `content_id` | text / uuid | Polymorphic; e.g. `content_type = 'review'` |
| `user_id` **FK→users** | uuid | Author of the flagged text |
| `toxic_score` / `obscene_score` / `threat_score` / `insult_score` / `identity_hate_score` | double precision | Perspective-API-style per-category classifier scores |
| `detected_labels` | jsonb | Default `[]` |
| `flagged_text` | text | |
| `admin_user_id` **FK→users** / `admin_note` / `reviewed_at` | uuid / text / timestamp | `reviewed_at` nullable — `NULL` means still unreviewed |

### `report_auto_actions`
Log of automatic moderation actions triggered once a target — potentially a review — accumulates enough user reports.

| Field | Type | Notes |
|---|---|---|
| `action_id` **PK** | uuid | |
| `target_type` / `target_id` | text / uuid | Polymorphic, no FK |
| `report_count` | int | Threshold that triggered the action |
| `created_at` | timestamp | |

### `appeals`
Generic user appeal against a moderation action — `target_type` could be a suppressed review as easily as a ban.

| Field | Type | Notes |
|---|---|---|
| `appeal_id` **PK** | uuid | |
| `user_id` **FK→users** | uuid | Appellant |
| `target_type` / `target_id` | text / uuid | Polymorphic, no FK |
| `message` | text | |
| `status` | text | Default `'pending'` |
| `admin_user_id` **FK→users** / `admin_note` / `actioned_at` | uuid / text / timestamp | |
| `proof_file_url` | varchar(500) | Ban-appeal proof upload; was live in the app before being added to this schema file |
| `created_at` | timestamp | |

---

**Out of scope:** `client.average_rating_given` and `freelancer.total_jobs` (cached summary columns on the profile tables, not dedicated review tables), and `contract_embedding` (embeds rating + review text for semantic job-matching — a search feature, not the reputation system itself).
