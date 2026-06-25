-- WorkByte Platform Seed Data
--
-- Accounts created by this script:
--
--   Role          Email                     Password
--   Admin         admin@example.com         passwordexample
--   Freelancer    freelancer@example.com    freelancerexample
--   Client        client@example.com        clientexample
--   Dual          dual@example.com          dualexample
--
-- "Dual" means the account has both a freelancer and a client profile.
--
-- What gets seeded:
--   4 users, freelancer and client profiles, skills, work experience,
--   education, 3 job posts with roles and required skills, 2 proposals
--   (accepted), 1 completed contract (freelancer x client) with rating,
--   published review, portfolio entry, and DM thread, plus 1 active
--   contract (dual as freelancer x client) with a pending submission.
--
-- This script is safe to re-run: all inserts use ON CONFLICT DO NOTHING
-- or NOT EXISTS guards to avoid duplicates.


-- 1. Users

INSERT INTO users (email, password, is_admin, password_login_enabled, email_verified, email_verified_at)
VALUES
    ('admin@example.com',
     '$argon2id$v=19$m=65536,t=3,p=4$qeI1Ga6q4FJI3lKbfiPx0w$EUAFY7QKOQDR8aCL7I5lAw8oSo0Zcm5rDWJuvIKo8Uo',
     TRUE, TRUE, TRUE, NOW()),
    ('freelancer@example.com',
     '$argon2id$v=19$m=65536,t=3,p=4$lSsOw3mygtHtAZtaaHGqJQ$+X+yDEnPvnxEjWW3h9eST5rWnQ/PiDozaE9hYXWPEqc',
     FALSE, TRUE, TRUE, NOW()),
    ('client@example.com',
     '$argon2id$v=19$m=65536,t=3,p=4$An6lM3LBLRsqMIDHMcxumw$QRkOQlgvaaAvJcYANrtk6QSI6j/Eljya4B9I8swSplY',
     FALSE, TRUE, TRUE, NOW()),
    ('dual@example.com',
     '$argon2id$v=19$m=65536,t=3,p=4$qvaYQbXTJj2QLnniE7w89A$g7tfJ8GiLMt5+HW5ebctsea5Vg16PqV9awK7fv8qPUY',
     FALSE, TRUE, TRUE, NOW())
ON CONFLICT (email) DO NOTHING;


-- 2. Freelancer profiles

INSERT INTO freelancer (user_id, full_name, title, bio, estimated_rate, rate_time, rate_currency)
SELECT user_id,
       'Ryan Tan',
       'Full-Stack Developer',
       'Experienced full-stack developer specialising in Python and React. Passionate about clean APIs and intuitive interfaces.',
       65.00, 'hourly'::rate_time_type, 'USD'
FROM users WHERE email = 'freelancer@example.com'
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO freelancer (user_id, full_name, title, bio, estimated_rate, rate_time, rate_currency)
SELECT user_id,
       'Dana Kim',
       'UI/UX Designer and Frontend Developer',
       'Designer-developer hybrid with 3 years in mobile and web products. Posts jobs and takes on design contracts.',
       55.00, 'hourly'::rate_time_type, 'USD'
FROM users WHERE email = 'dual@example.com'
ON CONFLICT (user_id) DO NOTHING;


-- 3. Client profiles

INSERT INTO client (user_id, full_name, bio, website_url)
SELECT user_id,
       'Nexus Digital',
       'Product-focused software consultancy building SaaS platforms for mid-market clients.',
       'https://nexusdigital.example.com'
FROM users WHERE email = 'client@example.com'
ON CONFLICT (user_id) DO NOTHING;

INSERT INTO client (user_id, full_name, bio, website_url)
SELECT user_id,
       'Dana Kim Studio',
       'Independent design studio offering brand and interface projects.',
       'https://danakim.example.com'
FROM users WHERE email = 'dual@example.com'
ON CONFLICT (user_id) DO NOTHING;


-- 4. Skills

INSERT INTO skill (skill_name, skill_category) VALUES
    -- Programming Languages
    ('Python',              'hard_skill'),
    ('JavaScript',          'hard_skill'),
    ('TypeScript',          'hard_skill'),
    ('Java',                'hard_skill'),
    ('Kotlin',              'hard_skill'),
    ('Swift',               'hard_skill'),
    ('Go',                  'hard_skill'),
    ('PHP',                 'hard_skill'),
    ('Ruby',                'hard_skill'),
    ('C++',                 'hard_skill'),
    ('C#',                  'hard_skill'),
    ('Dart',                'hard_skill'),
    ('Rust',                'hard_skill'),
    -- Backend Frameworks & APIs
    ('FastAPI',             'hard_skill'),
    ('Django',              'hard_skill'),
    ('Flask',               'hard_skill'),
    ('Node.js',             'hard_skill'),
    ('Express.js',          'hard_skill'),
    ('Spring Boot',         'hard_skill'),
    ('Laravel',             'hard_skill'),
    ('REST API',            'hard_skill'),
    ('GraphQL',             'hard_skill'),
    -- Frontend Frameworks & Libraries
    ('React',               'hard_skill'),
    ('Vue.js',              'hard_skill'),
    ('Angular',             'hard_skill'),
    ('Next.js',             'hard_skill'),
    ('HTML/CSS',            'hard_skill'),
    ('Tailwind CSS',        'hard_skill'),
    -- Mobile
    ('Flutter',             'hard_skill'),
    ('React Native',        'hard_skill'),
    ('Android Development', 'hard_skill'),
    ('iOS Development',     'hard_skill'),
    -- Databases
    ('PostgreSQL',          'hard_skill'),
    ('MySQL',               'hard_skill'),
    ('MongoDB',             'hard_skill'),
    ('Redis',               'hard_skill'),
    ('Firebase',            'hard_skill'),
    ('Supabase',            'hard_skill'),
    ('SQL',                 'hard_skill'),
    -- DevOps & Cloud
    ('Docker',              'hard_skill'),
    ('Kubernetes',          'hard_skill'),
    ('AWS',                 'hard_skill'),
    ('GCP',                 'hard_skill'),
    ('Azure',               'hard_skill'),
    ('CI/CD',               'hard_skill'),
    ('Linux',               'hard_skill'),
    ('Git',                 'tool'),
    -- Data & AI / ML
    ('Machine Learning',    'hard_skill'),
    ('Data Analysis',       'hard_skill'),
    ('TensorFlow',          'hard_skill'),
    ('PyTorch',             'hard_skill'),
    ('Pandas',              'hard_skill'),
    ('Power BI',            'tool'),
    ('Tableau',             'tool'),
    -- Design
    ('UI/UX Design',        'hard_skill'),
    ('Graphic Design',      'hard_skill'),
    ('Wireframing',         'hard_skill'),
    ('Prototyping',         'hard_skill'),
    ('Figma',               'tool'),
    ('Adobe XD',            'tool'),
    ('Sketch',              'tool'),
    ('Photoshop',           'tool'),
    ('Illustrator',         'tool'),
    ('After Effects',       'tool'),
    ('Premiere Pro',        'tool'),
    -- Writing & Marketing
    ('Copywriting',         'hard_skill'),
    ('SEO',                 'hard_skill'),
    ('Content Writing',     'hard_skill'),
    ('Social Media Marketing', 'hard_skill'),
    ('Digital Marketing',   'hard_skill'),
    -- Project Tools
    ('Jira',                'tool'),
    ('Notion',              'tool'),
    ('Trello',              'tool'),
    ('Postman',             'tool'),
    -- Soft Skills
    ('Communication',       'soft_skill'),
    ('Problem Solving',     'soft_skill'),
    ('Teamwork',            'soft_skill'),
    ('Leadership',          'soft_skill'),
    ('Project Management',  'soft_skill'),
    ('Time Management',     'soft_skill'),
    ('Critical Thinking',   'soft_skill'),
    ('Adaptability',        'soft_skill'),
    ('Creativity',          'soft_skill'),
    ('Attention to Detail', 'soft_skill')
ON CONFLICT (skill_name) DO NOTHING;


-- 5. Freelancer skills

INSERT INTO freelancer_skill (freelancer_id, skill_id, proficiency_level)
SELECT f.freelancer_id, s.skill_id, 'expert'::proficiency_skill
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN skill s
WHERE u.email = 'freelancer@example.com'
  AND s.skill_name IN ('Python', 'FastAPI', 'PostgreSQL', 'REST API', 'Docker')
ON CONFLICT (freelancer_id, skill_id) DO NOTHING;

INSERT INTO freelancer_skill (freelancer_id, skill_id, proficiency_level)
SELECT f.freelancer_id, s.skill_id, 'advanced'::proficiency_skill
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN skill s
WHERE u.email = 'freelancer@example.com'
  AND s.skill_name IN ('React', 'Communication', 'Problem Solving')
ON CONFLICT (freelancer_id, skill_id) DO NOTHING;

INSERT INTO freelancer_skill (freelancer_id, skill_id, proficiency_level)
SELECT f.freelancer_id, s.skill_id, 'expert'::proficiency_skill
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN skill s
WHERE u.email = 'dual@example.com'
  AND s.skill_name IN ('Figma', 'React', 'TypeScript')
ON CONFLICT (freelancer_id, skill_id) DO NOTHING;


-- 6. Work experience

INSERT INTO work_experience (freelancer_id, job_title, company_name, location, start_date, end_date, is_current, description)
SELECT f.freelancer_id,
       'Backend Developer', 'Orbis Tech', 'Singapore',
       '2022-03-01'::date, '2024-08-31'::date, FALSE,
       'Built microservices and REST APIs serving 50k+ daily active users using Python and FastAPI.'
FROM freelancer f JOIN users u ON f.user_id = u.user_id
WHERE u.email = 'freelancer@example.com';

INSERT INTO work_experience (freelancer_id, job_title, company_name, location, start_date, end_date, is_current, description)
SELECT f.freelancer_id,
       'Junior Developer', 'CodeCraft PH', 'Remote',
       '2020-06-01'::date, '2022-02-28'::date, FALSE,
       'Developed full-stack features for a logistics SaaS product.'
FROM freelancer f JOIN users u ON f.user_id = u.user_id
WHERE u.email = 'freelancer@example.com';

INSERT INTO work_experience (freelancer_id, job_title, company_name, location, start_date, end_date, is_current, description)
SELECT f.freelancer_id,
       'UI/UX Designer', 'Prism Agency', 'Jakarta, Indonesia',
       '2021-01-01'::date, NULL, TRUE,
       'Leading design for mobile and web products across e-commerce and fintech verticals.'
FROM freelancer f JOIN users u ON f.user_id = u.user_id
WHERE u.email = 'dual@example.com';


-- 7. Education

INSERT INTO education (freelancer_id, institution_name, degree, field_of_study, start_date, end_date, is_current, grade)
SELECT f.freelancer_id,
       'President University', 'Bachelor of Computer Science', 'Software Engineering',
       '2016-09-01'::date, '2020-06-30'::date, FALSE, 'A'
FROM freelancer f JOIN users u ON f.user_id = u.user_id
WHERE u.email = 'freelancer@example.com';

INSERT INTO education (freelancer_id, institution_name, degree, field_of_study, start_date, end_date, is_current, grade)
SELECT f.freelancer_id,
       'President University', 'Bachelor of Visual Communication Design', 'Interaction Design',
       '2017-09-01'::date, '2021-06-30'::date, FALSE, 'A'
FROM freelancer f JOIN users u ON f.user_id = u.user_id
WHERE u.email = 'dual@example.com';


-- 8. Job posts
-- Job 1: posted by client, filled (completed contract)
-- Job 2: posted by client, filled (active contract)
-- Job 3: posted by dual as client, active (open for proposals)

INSERT INTO job_post (client_id, job_title, job_description, project_type, project_scope, estimated_duration, experience_level, status, posted_at, project_category)
SELECT c.client_id,
       'Backend API Development for SaaS Platform',
       'We need an experienced backend developer to build a RESTful API for our new SaaS product. The scope includes user authentication, subscription management, and a reporting module. Python/FastAPI preferred.',
       'individual'::project_type, 'medium'::project_scope, '2-3 months',
       'intermediate'::experience_level, 'filled'::job_status,
       NOW() - INTERVAL '6 months', 'software_development'
FROM client c JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client@example.com'
  AND NOT EXISTS (SELECT 1 FROM job_post jp2 JOIN client c2 ON jp2.client_id = c2.client_id JOIN users u2 ON c2.user_id = u2.user_id WHERE u2.email = 'client@example.com' AND jp2.job_title = 'Backend API Development for SaaS Platform');

INSERT INTO job_post (client_id, job_title, job_description, project_type, project_scope, estimated_duration, experience_level, status, posted_at, project_category)
SELECT c.client_id,
       'React Frontend for Analytics Dashboard',
       'Build the frontend of our internal analytics dashboard in React. The backend API is ready. Deliverables include interactive charts, filters, and a responsive layout.',
       'individual'::project_type, 'medium'::project_scope, '6-8 weeks',
       'intermediate'::experience_level, 'filled'::job_status,
       NOW() - INTERVAL '2 months', 'software_development'
FROM client c JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client@example.com'
  AND NOT EXISTS (SELECT 1 FROM job_post jp2 JOIN client c2 ON jp2.client_id = c2.client_id JOIN users u2 ON c2.user_id = u2.user_id WHERE u2.email = 'client@example.com' AND jp2.job_title = 'React Frontend for Analytics Dashboard');

INSERT INTO job_post (client_id, job_title, job_description, project_type, project_scope, estimated_duration, experience_level, status, posted_at, project_category)
SELECT c.client_id,
       'Mobile App UI Redesign (Figma to Flutter)',
       'We need a designer to redesign the UI of our existing Flutter mobile app. Deliverables include a full Figma prototype and a handoff-ready component library.',
       'individual'::project_type, 'small'::project_scope, '3-4 weeks',
       'intermediate'::experience_level, 'active'::job_status,
       NOW() - INTERVAL '1 week', 'design'
FROM client c JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'dual@example.com'
  AND NOT EXISTS (SELECT 1 FROM job_post jp2 JOIN client c2 ON jp2.client_id = c2.client_id JOIN users u2 ON c2.user_id = u2.user_id WHERE u2.email = 'dual@example.com' AND jp2.job_title = 'Mobile App UI Redesign (Figma to Flutter)');


-- 9. Job roles

INSERT INTO job_role (job_post_id, role_title, role_budget, budget_currency, budget_type, role_description, positions_available, display_order)
SELECT jp.job_post_id,
       'Backend Developer', 5500.00, 'USD', 'fixed'::budget_type,
       'Owns the full API implementation from data models through to endpoint testing.', 1, 1
FROM job_post jp JOIN client c ON jp.client_id = c.client_id JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client@example.com' AND jp.job_title = 'Backend API Development for SaaS Platform'
  AND NOT EXISTS (SELECT 1 FROM job_role jr2 WHERE jr2.job_post_id = jp.job_post_id AND jr2.role_title = 'Backend Developer');

INSERT INTO job_role (job_post_id, role_title, role_budget, budget_currency, budget_type, role_description, positions_available, display_order)
SELECT jp.job_post_id,
       'Frontend Developer', 3800.00, 'USD', 'negotiable'::budget_type,
       'Implements the dashboard UI against the existing API spec.', 1, 1
FROM job_post jp JOIN client c ON jp.client_id = c.client_id JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client@example.com' AND jp.job_title = 'React Frontend for Analytics Dashboard'
  AND NOT EXISTS (SELECT 1 FROM job_role jr2 WHERE jr2.job_post_id = jp.job_post_id AND jr2.role_title = 'Frontend Developer');

INSERT INTO job_role (job_post_id, role_title, role_budget, budget_currency, budget_type, role_description, positions_available, display_order)
SELECT jp.job_post_id,
       'UI/UX Designer', 2500.00, 'USD', 'fixed'::budget_type,
       'Full design ownership from wireframes to handoff-ready Figma files.', 1, 1
FROM job_post jp JOIN client c ON jp.client_id = c.client_id JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'dual@example.com' AND jp.job_title = 'Mobile App UI Redesign (Figma to Flutter)'
  AND NOT EXISTS (SELECT 1 FROM job_role jr2 WHERE jr2.job_post_id = jp.job_post_id AND jr2.role_title = 'UI/UX Designer');


-- 10. Job role skills

INSERT INTO job_role_skill (job_role_id, skill_id, is_required, importance_level)
SELECT jr.job_role_id, s.skill_id, TRUE, 'required'::importance_level
FROM job_role jr
JOIN job_post jp ON jr.job_post_id = jp.job_post_id
JOIN client c ON jp.client_id = c.client_id
JOIN users u ON c.user_id = u.user_id
CROSS JOIN skill s
WHERE u.email = 'client@example.com'
  AND jp.job_title = 'Backend API Development for SaaS Platform'
  AND s.skill_name IN ('Python', 'FastAPI', 'PostgreSQL', 'REST API')
ON CONFLICT (job_role_id, skill_id) DO NOTHING;

INSERT INTO job_role_skill (job_role_id, skill_id, is_required, importance_level)
SELECT jr.job_role_id, s.skill_id, TRUE, 'required'::importance_level
FROM job_role jr
JOIN job_post jp ON jr.job_post_id = jp.job_post_id
JOIN client c ON jp.client_id = c.client_id
JOIN users u ON c.user_id = u.user_id
CROSS JOIN skill s
WHERE u.email = 'client@example.com'
  AND jp.job_title = 'React Frontend for Analytics Dashboard'
  AND s.skill_name IN ('React', 'TypeScript')
ON CONFLICT (job_role_id, skill_id) DO NOTHING;

INSERT INTO job_role_skill (job_role_id, skill_id, is_required, importance_level)
SELECT jr.job_role_id, s.skill_id, TRUE, 'required'::importance_level
FROM job_role jr
JOIN job_post jp ON jr.job_post_id = jp.job_post_id
JOIN client c ON jp.client_id = c.client_id
JOIN users u ON c.user_id = u.user_id
CROSS JOIN skill s
WHERE u.email = 'dual@example.com'
  AND jp.job_title = 'Mobile App UI Redesign (Figma to Flutter)'
  AND s.skill_name = 'Figma'
ON CONFLICT (job_role_id, skill_id) DO NOTHING;


-- 11. Proposals

-- Job 1: Ryan applies as freelancer, accepted
INSERT INTO proposal (job_post_id, job_role_id, freelancer_id, cover_letter, proposed_budget, proposed_duration, status, submitted_at)
SELECT jp.job_post_id, jr.job_role_id, f.freelancer_id,
       'I have 4+ years of Python and FastAPI experience and have built production APIs for similar SaaS products. I am confident I can deliver the full scope within the estimated timeline.',
       5500.00, '10 weeks', 'accepted'::proposal_status,
       NOW() - INTERVAL '5 months 3 weeks'
FROM job_post jp
JOIN job_role jr ON jr.job_post_id = jp.job_post_id
JOIN client c ON jp.client_id = c.client_id
JOIN users uc ON c.user_id = uc.user_id
JOIN freelancer f ON TRUE
JOIN users uf ON f.user_id = uf.user_id
WHERE uc.email = 'client@example.com'
  AND jp.job_title = 'Backend API Development for SaaS Platform'
  AND jr.role_title = 'Backend Developer'
  AND uf.email = 'freelancer@example.com'
ON CONFLICT (freelancer_id, job_role_id) DO NOTHING;

-- Job 2: Dana (dual as freelancer) applies, accepted
INSERT INTO proposal (job_post_id, job_role_id, freelancer_id, cover_letter, proposed_budget, proposed_duration, status, submitted_at)
SELECT jp.job_post_id, jr.job_role_id, f.freelancer_id,
       'I specialise in React and TypeScript and have built several dashboard UIs. I can start immediately and deliver responsive, well-documented components.',
       3800.00, '7 weeks', 'accepted'::proposal_status,
       NOW() - INTERVAL '7 weeks'
FROM job_post jp
JOIN job_role jr ON jr.job_post_id = jp.job_post_id
JOIN client c ON jp.client_id = c.client_id
JOIN users uc ON c.user_id = uc.user_id
JOIN freelancer f ON TRUE
JOIN users uf ON f.user_id = uf.user_id
WHERE uc.email = 'client@example.com'
  AND jp.job_title = 'React Frontend for Analytics Dashboard'
  AND jr.role_title = 'Frontend Developer'
  AND uf.email = 'dual@example.com'
ON CONFLICT (freelancer_id, job_role_id) DO NOTHING;


-- 12. Contracts

-- Contract 1: completed (Ryan x Nexus Digital)
INSERT INTO contract (
    job_post_id, job_role_id, proposal_id,
    freelancer_id, client_id,
    contract_title, role_title,
    agreed_budget, budget_currency, payment_structure, agreed_duration,
    status, start_date, end_date, actual_completion_date,
    total_hours_worked, total_paid
)
SELECT p.job_post_id, p.job_role_id, p.proposal_id,
       p.freelancer_id, c.client_id,
       'Backend API Development - Nexus Digital SaaS Platform', 'Backend Developer',
       5500.00, 'USD', 'full_payment'::payment_structure, '10 weeks',
       'completed'::contract_status,
       (NOW() - INTERVAL '5 months')::date,
       (NOW() - INTERVAL '2 months 2 weeks')::date,
       (NOW() - INTERVAL '2 months 2 weeks')::date,
       320.00, 5500.00
FROM proposal p
JOIN job_role jr ON p.job_role_id = jr.job_role_id
JOIN job_post jp ON p.job_post_id = jp.job_post_id
JOIN client c ON jp.client_id = c.client_id
JOIN users uc ON c.user_id = uc.user_id
JOIN freelancer f ON p.freelancer_id = f.freelancer_id
JOIN users uf ON f.user_id = uf.user_id
WHERE uc.email = 'client@example.com'
  AND jp.job_title = 'Backend API Development for SaaS Platform'
  AND uf.email = 'freelancer@example.com'
  AND NOT EXISTS (SELECT 1 FROM contract ct2 WHERE ct2.contract_title = 'Backend API Development - Nexus Digital SaaS Platform');

-- Contract 2: active (Dana as freelancer x Nexus Digital)
INSERT INTO contract (
    job_post_id, job_role_id, proposal_id,
    freelancer_id, client_id,
    contract_title, role_title,
    agreed_budget, budget_currency, payment_structure, agreed_duration,
    status, start_date, end_date,
    total_paid
)
SELECT p.job_post_id, p.job_role_id, p.proposal_id,
       p.freelancer_id, c.client_id,
       'React Analytics Dashboard - Nexus Digital', 'Frontend Developer',
       3800.00, 'USD', 'full_payment'::payment_structure, '7 weeks',
       'active'::contract_status,
       (NOW() - INTERVAL '6 weeks')::date,
       (NOW() + INTERVAL '1 week')::date,
       0.00
FROM proposal p
JOIN job_role jr ON p.job_role_id = jr.job_role_id
JOIN job_post jp ON p.job_post_id = jp.job_post_id
JOIN client c ON jp.client_id = c.client_id
JOIN users uc ON c.user_id = uc.user_id
JOIN freelancer f ON p.freelancer_id = f.freelancer_id
JOIN users uf ON f.user_id = uf.user_id
WHERE uc.email = 'client@example.com'
  AND jp.job_title = 'React Frontend for Analytics Dashboard'
  AND uf.email = 'dual@example.com'
  AND NOT EXISTS (SELECT 1 FROM contract ct2 WHERE ct2.contract_title = 'React Analytics Dashboard - Nexus Digital');


-- 13. Contract terms

INSERT INTO contract_terms (contract_id, termination_notice, governing_law, confidentiality, revision_rounds, dispute_resolution, payment_schedule)
SELECT ct.contract_id, 14, 'Indonesia', TRUE, 2, 'negotiation',
       'Full payment upon final delivery and client sign-off.'
FROM contract ct WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (contract_id) DO NOTHING;

INSERT INTO contract_terms (contract_id, termination_notice, governing_law, confidentiality, revision_rounds, dispute_resolution, payment_schedule)
SELECT ct.contract_id, 7, 'Indonesia', FALSE, 3, 'negotiation',
       'Full payment on delivery and acceptance of all components.'
FROM contract ct WHERE ct.contract_title = 'React Analytics Dashboard - Nexus Digital'
ON CONFLICT (contract_id) DO NOTHING;


-- 14. Contract submissions

-- Contract 1 submission: approved (contract is completed)
INSERT INTO contract_submission (contract_id, submitted_by, note, status, submitted_at, reviewed_at)
SELECT ct.contract_id, u.user_id,
       'All API endpoints are implemented, documented in Swagger, and covered by unit tests. Ready for final review.',
       'approved',
       ct.end_date::timestamptz - INTERVAL '3 days',
       ct.end_date::timestamptz
FROM contract ct
JOIN freelancer f ON ct.freelancer_id = f.freelancer_id
JOIN users u ON f.user_id = u.user_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
  AND NOT EXISTS (SELECT 1 FROM contract_submission cs2 WHERE cs2.contract_id = ct.contract_id AND cs2.status = 'approved');

-- Contract 2 submission: submitted, awaiting review
INSERT INTO contract_submission (contract_id, submitted_by, note, status, submitted_at)
SELECT ct.contract_id, u.user_id,
       'Dashboard components are complete. Chart interactivity and filter logic are working. Awaiting client review.',
       'submitted',
       NOW() - INTERVAL '2 days'
FROM contract ct
JOIN freelancer f ON ct.freelancer_id = f.freelancer_id
JOIN users u ON f.user_id = u.user_id
WHERE ct.contract_title = 'React Analytics Dashboard - Nexus Digital'
  AND NOT EXISTS (SELECT 1 FROM contract_submission cs2 WHERE cs2.contract_id = ct.contract_id);


-- 15. Rating (completed contract)

INSERT INTO rating (contract_id, client_id, freelancer_id, communication_score, result_quality_score, professionalism_score, timeline_compliance_score, overall_rating, review_text)
SELECT ct.contract_id, ct.client_id, ct.freelancer_id,
       5, 5, 5, 4, 4.75,
       'Ryan delivered exactly what we needed. The API is clean, well-documented, and handles edge cases properly. Slight delay on one milestone but communicated proactively throughout.'
FROM contract ct WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (contract_id) DO NOTHING;


-- 16. Review (completed contract)

INSERT INTO reviews (contract_id, reviewer_id, freelancer_id, inferred_category, status, is_anonymous, published_at)
SELECT ct.contract_id, uc.user_id, uf.user_id,
       'software_development', 'published'::review_status, FALSE,
       NOW() - INTERVAL '2 months'
FROM contract ct
JOIN client cl ON ct.client_id = cl.client_id
JOIN users uc ON cl.user_id = uc.user_id
JOIN freelancer f ON ct.freelancer_id = f.freelancer_id
JOIN users uf ON f.user_id = uf.user_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (contract_id) DO NOTHING;

INSERT INTO review_ratings (review_id, category, score)
SELECT r.id, 'communication', 4.5
FROM reviews r JOIN contract ct ON r.contract_id = ct.contract_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (review_id, category) DO NOTHING;

INSERT INTO review_ratings (review_id, category, score)
SELECT r.id, 'work_quality', 5.0
FROM reviews r JOIN contract ct ON r.contract_id = ct.contract_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (review_id, category) DO NOTHING;

INSERT INTO review_ratings (review_id, category, score)
SELECT r.id, 'professionalism', 5.0
FROM reviews r JOIN contract ct ON r.contract_id = ct.contract_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (review_id, category) DO NOTHING;

INSERT INTO review_ratings (review_id, category, score)
SELECT r.id, 'timeline', 4.0
FROM reviews r JOIN contract ct ON r.contract_id = ct.contract_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (review_id, category) DO NOTHING;

INSERT INTO review_written_content (review_id, ai_question, client_answer, overall_comment)
SELECT r.id,
       'How effectively did the freelancer communicate progress and any blockers during the project?',
       'Ryan kept us updated every week and flagged a scope ambiguity early that saved us from a significant rework later. One deadline slipped by a few days but he was upfront about it.',
       'Solid developer with strong technical fundamentals. Would hire again for backend work.'
FROM reviews r JOIN contract ct ON r.contract_id = ct.contract_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (review_id) DO NOTHING;

INSERT INTO review_skill_tags (review_id, skill_tag, is_ai_suggested)
SELECT r.id, 'Python', FALSE FROM reviews r JOIN contract ct ON r.contract_id = ct.contract_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (review_id, skill_tag) DO NOTHING;

INSERT INTO review_skill_tags (review_id, skill_tag, is_ai_suggested)
SELECT r.id, 'FastAPI', TRUE FROM reviews r JOIN contract ct ON r.contract_id = ct.contract_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (review_id, skill_tag) DO NOTHING;

INSERT INTO review_skill_tags (review_id, skill_tag, is_ai_suggested)
SELECT r.id, 'Communication', FALSE FROM reviews r JOIN contract ct ON r.contract_id = ct.contract_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (review_id, skill_tag) DO NOTHING;


-- 17. Portfolio (auto-generated from completed contract)

INSERT INTO portfolio (freelancer_id, project_title, project_description, completion_date, is_auto_generated, contract_id)
SELECT ct.freelancer_id,
       'Backend API - Nexus Digital SaaS Platform',
       'Designed and implemented a production-grade RESTful API for a SaaS platform covering user authentication, subscription management, and a reporting module. Built with Python/FastAPI and PostgreSQL.',
       ct.actual_completion_date,
       TRUE, ct.contract_id
FROM contract ct
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
  AND NOT EXISTS (SELECT 1 FROM portfolio p2 WHERE p2.contract_id = ct.contract_id);


-- 18. Freelancer embedding stubs (sweep worker populates vectors)

INSERT INTO freelancer_embedding (freelancer_id, embedding_dirty)
SELECT f.freelancer_id, TRUE
FROM freelancer f JOIN users u ON f.user_id = u.user_id
WHERE u.email IN ('freelancer@example.com', 'dual@example.com')
ON CONFLICT (freelancer_id) DO NOTHING;


-- 19. Contract embedding stub for completed contract

INSERT INTO contract_embedding (contract_id, freelancer_id, embedding_dirty)
SELECT ct.contract_id, ct.freelancer_id, TRUE
FROM contract ct WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (contract_id) DO NOTHING;


-- 20. DM thread and messages (client <-> freelancer, Contract 1)

-- dm_thread enforces user_a_id < user_b_id (UUID lexicographic order)
INSERT INTO dm_thread (user_a_id, user_b_id, initiator_id, status, contract_id)
SELECT
    LEAST(uc.user_id, uf.user_id),
    GREATEST(uc.user_id, uf.user_id),
    uc.user_id, 'active',
    ct.contract_id
FROM contract ct
JOIN client cl ON ct.client_id = cl.client_id
JOIN users uc ON cl.user_id = uc.user_id
JOIN freelancer f ON ct.freelancer_id = f.freelancer_id
JOIN users uf ON f.user_id = uf.user_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
ON CONFLICT (user_a_id, user_b_id) DO NOTHING;

INSERT INTO dm_message (thread_id, sender_id, message_text, is_read, read_at, sent_at)
SELECT t.thread_id, uc.user_id,
       'Hi Ryan, just checking in — how is the auth module coming along?',
       TRUE, NOW() - INTERVAL '3 months 6 days', NOW() - INTERVAL '3 months 1 week'
FROM dm_thread t
JOIN contract ct ON t.contract_id = ct.contract_id
JOIN client cl ON ct.client_id = cl.client_id
JOIN users uc ON cl.user_id = uc.user_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
  AND NOT EXISTS (SELECT 1 FROM dm_message m2 WHERE m2.thread_id = t.thread_id);

INSERT INTO dm_message (thread_id, sender_id, message_text, is_read, read_at, sent_at)
SELECT t.thread_id, uf.user_id,
       'Going well — JWT flow is done and refresh tokens are in. Should have the full auth suite ready for review by end of week.',
       TRUE, NOW() - INTERVAL '3 months 5 days', NOW() - INTERVAL '3 months 6 days' + INTERVAL '4 hours'
FROM dm_thread t
JOIN contract ct ON t.contract_id = ct.contract_id
JOIN freelancer f ON ct.freelancer_id = f.freelancer_id
JOIN users uf ON f.user_id = uf.user_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
  AND (SELECT COUNT(*) FROM dm_message m2 WHERE m2.thread_id = t.thread_id) = 1;

INSERT INTO dm_message (thread_id, sender_id, message_text, is_read, read_at, sent_at)
SELECT t.thread_id, uc.user_id,
       'Perfect, sounds great. Let us know when it is ready for review.',
       TRUE, NOW() - INTERVAL '3 months 4 days', NOW() - INTERVAL '3 months 5 days' + INTERVAL '2 hours'
FROM dm_thread t
JOIN contract ct ON t.contract_id = ct.contract_id
JOIN client cl ON ct.client_id = cl.client_id
JOIN users uc ON cl.user_id = uc.user_id
WHERE ct.contract_title = 'Backend API Development - Nexus Digital SaaS Platform'
  AND (SELECT COUNT(*) FROM dm_message m2 WHERE m2.thread_id = t.thread_id) = 2;


-- 21. Job role embedding stubs (sweep worker populates vectors)
-- Created here because seeding bypasses the API that normally calls mark_job_dirty().

INSERT INTO job_role_embedding (job_role_id, job_post_id, embedding_dirty)
SELECT jr.job_role_id, jr.job_post_id, TRUE
FROM job_role jr
JOIN job_post jp ON jr.job_post_id = jp.job_post_id
JOIN client c ON jp.client_id = c.client_id
JOIN users u ON c.user_id = u.user_id
WHERE (u.email = 'client@example.com' AND jp.job_title IN (
           'Backend API Development for SaaS Platform',
           'React Frontend for Analytics Dashboard'
       ))
   OR (u.email = 'dual@example.com' AND jp.job_title = 'Mobile App UI Redesign (Figma to Flutter)')
ON CONFLICT (job_role_id) DO NOTHING;


-- 22. AI review prompts (category-specific questions for the post-completion review pipeline)
-- Categories must match review_pipeline.infer_project_category() output.
-- get_targeted_question() picks one at random per category; 'general' is the fallback.

INSERT INTO ai_review_prompts (project_category, question_text, is_active) VALUES

    -- general (fallback for anything unclassified)
    ('general', 'How satisfied are you with the overall quality and outcome of the project?', TRUE),
    ('general', 'Did the freelancer meet your expectations in terms of deliverables and professionalism?', TRUE),
    ('general', 'How well did the freelancer understand and address your project requirements?', TRUE),

    -- backend_dev
    ('backend_dev', 'How would you rate the quality, structure, and maintainability of the code delivered?', TRUE),
    ('backend_dev', 'Did the freelancer handle edge cases, error handling, and API reliability to your satisfaction?', TRUE),
    ('backend_dev', 'How effectively did the freelancer communicate technical decisions and any blockers during the project?', TRUE),

    -- web_dev
    ('web_dev', 'How satisfied are you with the responsiveness, performance, and visual accuracy of the delivered frontend?', TRUE),
    ('web_dev', 'Did the freelancer follow your design specifications and browser compatibility requirements?', TRUE),
    ('web_dev', 'How well did the freelancer collaborate with you on feedback rounds and UI revisions?', TRUE),

    -- mobile_dev
    ('mobile_dev', 'How would you rate the performance, stability, and user experience of the delivered mobile app?', TRUE),
    ('mobile_dev', 'Did the freelancer test the app across the required devices and OS versions?', TRUE),
    ('mobile_dev', 'How satisfied are you with how the freelancer handled platform-specific constraints (Android/iOS)?', TRUE),

    -- ui_ux_design
    ('ui_ux_design', 'How well did the freelancer translate your goals into an intuitive and visually appealing design?', TRUE),
    ('ui_ux_design', 'Did the delivered Figma files or prototypes meet your handoff and usability requirements?', TRUE),
    ('ui_ux_design', 'How effectively did the freelancer incorporate your feedback into the design iterations?', TRUE),

    -- graphic_design
    ('graphic_design', 'How satisfied are you with the creativity and visual quality of the delivered design assets?', TRUE),
    ('graphic_design', 'Did the freelancer deliver the assets in the correct formats and resolutions for your use case?', TRUE),
    ('graphic_design', 'How well did the freelancer understand and represent your brand identity in the work?', TRUE),

    -- copywriting
    ('copywriting', 'How well did the content align with your brand voice, target audience, and messaging goals?', TRUE),
    ('copywriting', 'Did the freelancer deliver the copy on time and incorporate your revision requests effectively?', TRUE),
    ('copywriting', 'How satisfied are you with the clarity, engagement level, and originality of the written content?', TRUE),

    -- data_analytics
    ('data_analytics', 'How clearly and accurately did the freelancer present the data insights and findings?', TRUE),
    ('data_analytics', 'Did the deliverables (dashboards, reports, models) meet your analytical requirements?', TRUE),
    ('data_analytics', 'How well did the freelancer handle data quality issues and communicate assumptions made?', TRUE),

    -- video_editing
    ('video_editing', 'How satisfied are you with the pacing, visual quality, and overall storytelling of the final video?', TRUE),
    ('video_editing', 'Did the freelancer incorporate your feedback and revision requests in a timely manner?', TRUE),
    ('video_editing', 'How well did the freelancer match the tone and style you requested for the project?', TRUE),

    -- marketing
    ('marketing', 'How effectively did the freelancer plan and execute the marketing strategy for your goals?', TRUE),
    ('marketing', 'Did the campaign or content delivered meet your target KPIs and audience engagement expectations?', TRUE),
    ('marketing', 'How satisfied are you with the freelancer''s understanding of your market and brand positioning?', TRUE)

ON CONFLICT DO NOTHING;
