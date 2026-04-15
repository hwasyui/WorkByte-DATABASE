-- ============================================================
-- COMPREHENSIVE DATA INSERTION FOR WORKBYTE PLATFORM
-- 10 Freelancers, 10 Clients, and related data for all tables
-- ============================================================

-- ============================================================
-- 1. INSERT USERS (20 total: 10 freelancers + 10 clients)
-- ============================================================

INSERT INTO users (email, password, type) VALUES
-- Freelancers
('freelancer1@test.com', 'dummy1234', 'freelancer'),
('freelancer2@test.com', 'dummy1234', 'freelancer'),
('freelancer3@test.com', 'dummy1234', 'freelancer'),
('freelancer4@test.com', 'dummy1234', 'freelancer'),
('freelancer5@test.com', 'dummy1234', 'freelancer'),
('freelancer6@test.com', 'dummy1234', 'freelancer'),
('freelancer7@test.com', 'dummy1234', 'freelancer'),
('freelancer8@test.com', 'dummy1234', 'freelancer'),
('freelancer9@test.com', 'dummy1234', 'freelancer'),
('freelancer10@test.com', 'dummy1234', 'freelancer'),
-- Clients
('client1@test.com', 'dummy1234', 'client'),
('client2@test.com', 'dummy1234', 'client'),
('client3@test.com', 'dummy1234', 'client'),
('client4@test.com', 'dummy1234', 'client'),
('client5@test.com', 'dummy1234', 'client'),
('client6@test.com', 'dummy1234', 'client'),
('client7@test.com', 'dummy1234', 'client'),
('client8@test.com', 'dummy1234', 'client'),
('client9@test.com', 'dummy1234', 'client'),
('client10@test.com', 'dummy1234', 'client')
ON CONFLICT (email) DO NOTHING;

-- ============================================================
-- 2. INSERT FREELANCERS (10)
-- ============================================================

INSERT INTO freelancer (user_id, full_name, bio, estimated_rate, rate_time, rate_currency)
SELECT u.user_id, 'FREELANCER 1 DUMMY', 'Professional freelancer with 5+ years of experience', 50.00, 'hourly'::rate_time_type, 'USD'
FROM users u WHERE u.email = 'freelancer1@test.com'
UNION ALL
SELECT u.user_id, 'FREELANCER 2 DUMMY', 'Expert in web development and design', 60.00, 'hourly'::rate_time_type, 'USD'
FROM users u WHERE u.email = 'freelancer2@test.com'
UNION ALL
SELECT u.user_id, 'FREELANCER 3 DUMMY', 'Full-stack developer specializing in cloud solutions', 75.00, 'hourly'::rate_time_type, 'USD'
FROM users u WHERE u.email = 'freelancer3@test.com'
UNION ALL
SELECT u.user_id, 'FREELANCER 4 DUMMY', 'Mobile app developer with 3+ years', 55.00, 'hourly'::rate_time_type, 'USD'
FROM users u WHERE u.email = 'freelancer4@test.com'
UNION ALL
SELECT u.user_id, 'FREELANCER 5 DUMMY', 'Data scientist and machine learning specialist', 80.00, 'hourly'::rate_time_type, 'USD'
FROM users u WHERE u.email = 'freelancer5@test.com'
UNION ALL
SELECT u.user_id, 'FREELANCER 6 DUMMY', 'UI/UX Designer with award-winning portfolio', 65.00, 'hourly'::rate_time_type, 'USD'
FROM users u WHERE u.email = 'freelancer6@test.com'
UNION ALL
SELECT u.user_id, 'FREELANCER 7 DUMMY', 'DevOps Engineer and Cloud Architect', 70.00, 'hourly'::rate_time_type, 'USD'
FROM users u WHERE u.email = 'freelancer7@test.com'
UNION ALL
SELECT u.user_id, 'FREELANCER 8 DUMMY', 'Backend Developer specializing in databases', 68.00, 'hourly'::rate_time_type, 'USD'
FROM users u WHERE u.email = 'freelancer8@test.com'
UNION ALL
SELECT u.user_id, 'FREELANCER 9 DUMMY', 'Frontend Developer with React expertise', 62.00, 'hourly'::rate_time_type, 'USD'
FROM users u WHERE u.email = 'freelancer9@test.com'
UNION ALL
SELECT u.user_id, 'FREELANCER 10 DUMMY', 'QA Engineer and Test Automation Specialist', 58.00, 'hourly'::rate_time_type, 'USD'
FROM users u WHERE u.email = 'freelancer10@test.com'
ON CONFLICT DO NOTHING;

-- ============================================================
-- 3. INSERT CLIENTS (10)
-- ============================================================

INSERT INTO client (user_id, full_name, bio, website_url)
SELECT u.user_id, 'CLIENT 1 DUMMY', 'Tech startup focused on AI solutions', 'https://client1.com'
FROM users u WHERE u.email = 'client1@test.com'
UNION ALL
SELECT u.user_id, 'CLIENT 2 DUMMY', 'E-commerce company expanding globally', 'https://client2.com'
FROM users u WHERE u.email = 'client2@test.com'
UNION ALL
SELECT u.user_id, 'CLIENT 3 DUMMY', 'Digital agency specializing in web design', 'https://client3.com'
FROM users u WHERE u.email = 'client3@test.com'
UNION ALL
SELECT u.user_id, 'CLIENT 4 DUMMY', 'Financial services firm modernizing systems', 'https://client4.com'
FROM users u WHERE u.email = 'client4@test.com'
UNION ALL
SELECT u.user_id, 'CLIENT 5 DUMMY', 'Healthcare startup building patient platform', 'https://client5.com'
FROM users u WHERE u.email = 'client5@test.com'
UNION ALL
SELECT u.user_id, 'CLIENT 6 DUMMY', 'Real estate technology company', 'https://client6.com'
FROM users u WHERE u.email = 'client6@test.com'
UNION ALL
SELECT u.user_id, 'CLIENT 7 DUMMY', 'Education tech platform provider', 'https://client7.com'
FROM users u WHERE u.email = 'client7@test.com'
UNION ALL
SELECT u.user_id, 'CLIENT 8 DUMMY', 'Marketing and analytics software company', 'https://client8.com'
FROM users u WHERE u.email = 'client8@test.com'
UNION ALL
SELECT u.user_id, 'CLIENT 9 DUMMY', 'Supply chain management solutions', 'https://client9.com'
FROM users u WHERE u.email = 'client9@test.com'
UNION ALL
SELECT u.user_id, 'CLIENT 10 DUMMY', 'Mobile game development studio', 'https://client10.com'
FROM users u WHERE u.email = 'client10@test.com'
ON CONFLICT DO NOTHING;

-- ============================================================
-- 4. INSERT SKILLS (30 diverse skills)
-- ============================================================

INSERT INTO skill (skill_name, skill_category, description) VALUES
('Python', 'hard_skill', 'Python programming language'),
('JavaScript', 'hard_skill', 'JavaScript programming language'),
('React', 'hard_skill', 'React frontend library'),
('Node.js', 'hard_skill', 'Node.js runtime environment'),
('PostgreSQL', 'hard_skill', 'PostgreSQL database'),
('MongoDB', 'hard_skill', 'MongoDB NoSQL database'),
('AWS', 'hard_skill', 'Amazon Web Services cloud platform'),
('Docker', 'hard_skill', 'Container technology'),
('Kubernetes', 'hard_skill', 'Orchestration platform'),
('Git', 'hard_skill', 'Version control system'),
('API Development', 'hard_skill', 'RESTful API design and development'),
('Machine Learning', 'hard_skill', 'ML and AI implementation'),
('Data Analysis', 'hard_skill', 'Data analysis and visualization'),
('UI/UX Design', 'hard_skill', 'User interface and experience design'),
('Figma', 'tool', 'Design tool'),
('Adobe Creative Suite', 'tool', 'Adobe design tools'),
('Jira', 'tool', 'Project management tool'),
('Communication', 'soft_skill', 'Effective communication skills'),
('Problem Solving', 'soft_skill', 'Problem-solving ability'),
('Team Collaboration', 'soft_skill', 'Teamwork and collaboration'),
('Project Management', 'soft_skill', 'Project management skills'),
('Leadership', 'soft_skill', 'Leadership abilities'),
('TypeScript', 'hard_skill', 'TypeScript programming language'),
('Vue.js', 'hard_skill', 'Vue.js frontend framework'),
('Angular', 'hard_skill', 'Angular frontend framework'),
('Java', 'hard_skill', 'Java programming language'),
('C++', 'hard_skill', 'C++ programming language'),
('Mobile Development', 'hard_skill', 'Mobile app development'),
('Cloud Architecture', 'hard_skill', 'Cloud system design'),
('Testing', 'hard_skill', 'Software testing and QA')
ON CONFLICT (skill_name) DO NOTHING;

-- ============================================================
-- 5. INSERT SPECIALITIES (10 diverse specialities)
-- ============================================================

INSERT INTO speciality (speciality_name, description) VALUES
('Web Development', 'Full-stack web development services'),
('Mobile App Development', 'iOS and Android app development'),
('Cloud Solutions', 'Cloud infrastructure and services'),
('Data Science', 'Data analysis and machine learning'),
('AI/ML', 'Artificial intelligence and machine learning'),
('UI/UX Design', 'User interface and experience design'),
('DevOps', 'Development operations and infrastructure'),
('Backend Development', 'Server-side development services'),
('Frontend Development', 'Client-side development services'),
('Quality Assurance', 'Software testing and quality assurance')
ON CONFLICT (speciality_name) DO NOTHING;

-- ============================================================
-- 6. INSERT LANGUAGES (8 languages)
-- ============================================================

INSERT INTO language (language_name, iso_code) VALUES
('English', 'en'),
('Spanish', 'es'),
('French', 'fr'),
('German', 'de'),
('Chinese', 'zh'),
('Japanese', 'ja'),
('Portuguese', 'pt'),
('Hindi', 'hi')
ON CONFLICT (language_name) DO NOTHING;

-- ============================================================
-- 7. INSERT FREELANCER SKILLS (5 skills per freelancer)
-- ============================================================

INSERT INTO freelancer_skill (freelancer_id, skill_id, proficiency_level)
SELECT f.freelancer_id, s.skill_id, 'advanced'
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN skill s
WHERE u.email IN ('freelancer1@test.com', 'freelancer2@test.com', 'freelancer3@test.com', 
                    'freelancer4@test.com', 'freelancer5@test.com', 'freelancer6@test.com',
                    'freelancer7@test.com', 'freelancer8@test.com', 'freelancer9@test.com', 'freelancer10@test.com')
AND s.skill_name IN ('Python', 'JavaScript', 'React', 'Node.js', 'PostgreSQL')
ON CONFLICT (freelancer_id, skill_id) DO NOTHING;

-- Additional varied skills for different freelancers
INSERT INTO freelancer_skill (freelancer_id, skill_id, proficiency_level)
SELECT f.freelancer_id, s.skill_id, 'expert'
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN skill s
WHERE u.email IN ('freelancer1@test.com', 'freelancer3@test.com', 'freelancer5@test.com')
AND s.skill_name IN ('AWS', 'Docker', 'Machine Learning')
ON CONFLICT (freelancer_id, skill_id) DO NOTHING;

INSERT INTO freelancer_skill (freelancer_id, skill_id, proficiency_level)
SELECT f.freelancer_id, s.skill_id, 'intermediate'
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN skill s
WHERE u.email IN ('freelancer2@test.com', 'freelancer4@test.com', 'freelancer6@test.com')
AND s.skill_name IN ('UI/UX Design', 'Figma', 'Adobe Creative Suite')
ON CONFLICT (freelancer_id, skill_id) DO NOTHING;

-- ============================================================
-- 8. INSERT FREELANCER SPECIALITIES (2-3 per freelancer)
-- ============================================================

INSERT INTO freelancer_speciality (freelancer_id, speciality_id, is_primary)
SELECT f.freelancer_id, sp.speciality_id, true
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN speciality sp
WHERE u.email = 'freelancer1@test.com' AND sp.speciality_name = 'Web Development'
UNION ALL
SELECT f.freelancer_id, sp.speciality_id, true
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN speciality sp
WHERE u.email = 'freelancer2@test.com' AND sp.speciality_name = 'Frontend Development'
UNION ALL
SELECT f.freelancer_id, sp.speciality_id, true
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN speciality sp
WHERE u.email = 'freelancer3@test.com' AND sp.speciality_name = 'Full-stack Web Development'
UNION ALL
SELECT f.freelancer_id, sp.speciality_id, true
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN speciality sp
WHERE u.email = 'freelancer4@test.com' AND sp.speciality_name = 'Mobile App Development'
UNION ALL
SELECT f.freelancer_id, sp.speciality_id, true
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN speciality sp
WHERE u.email = 'freelancer5@test.com' AND sp.speciality_name = 'Data Science'
UNION ALL
SELECT f.freelancer_id, sp.speciality_id, true
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN speciality sp
WHERE u.email = 'freelancer6@test.com' AND sp.speciality_name = 'UI/UX Design'
UNION ALL
SELECT f.freelancer_id, sp.speciality_id, true
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN speciality sp
WHERE u.email = 'freelancer7@test.com' AND sp.speciality_name = 'DevOps'
UNION ALL
SELECT f.freelancer_id, sp.speciality_id, true
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN speciality sp
WHERE u.email = 'freelancer8@test.com' AND sp.speciality_name = 'Backend Development'
UNION ALL
SELECT f.freelancer_id, sp.speciality_id, true
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN speciality sp
WHERE u.email = 'freelancer9@test.com' AND sp.speciality_name = 'Frontend Development'
UNION ALL
SELECT f.freelancer_id, sp.speciality_id, true
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN speciality sp
WHERE u.email = 'freelancer10@test.com' AND sp.speciality_name = 'Quality Assurance'
ON CONFLICT DO NOTHING;

-- Secondary specialities
INSERT INTO freelancer_speciality (freelancer_id, speciality_id, is_primary)
SELECT f.freelancer_id, sp.speciality_id, false
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN speciality sp
WHERE u.email IN ('freelancer1@test.com', 'freelancer3@test.com', 'freelancer5@test.com',
                   'freelancer7@test.com', 'freelancer8@test.com', 'freelancer10@test.com')
AND sp.speciality_name = 'Cloud Solutions'
ON CONFLICT DO NOTHING;

-- ============================================================
-- 9. INSERT FREELANCER LANGUAGES (2-3 languages per freelancer)
-- ============================================================

INSERT INTO freelancer_language (freelancer_id, language_id, proficiency_level)
SELECT f.freelancer_id, l.language_id, 'fluent'
FROM freelancer f
CROSS JOIN language l
WHERE l.language_name = 'English'
ON CONFLICT (freelancer_id, language_id) DO NOTHING;

INSERT INTO freelancer_language (freelancer_id, language_id, proficiency_level)
SELECT f.freelancer_id, l.language_id, 'conversational'
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN language l
WHERE u.email IN ('freelancer1@test.com', 'freelancer2@test.com', 'freelancer3@test.com',
                   'freelancer4@test.com', 'freelancer5@test.com')
AND l.language_name = 'Spanish'
ON CONFLICT (freelancer_id, language_id) DO NOTHING;

INSERT INTO freelancer_language (freelancer_id, language_id, proficiency_level)
SELECT f.freelancer_id, l.language_id, 'conversational'
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
CROSS JOIN language l
WHERE u.email IN ('freelancer6@test.com', 'freelancer7@test.com', 'freelancer8@test.com',
                   'freelancer9@test.com', 'freelancer10@test.com')
AND l.language_name = 'French'
ON CONFLICT (freelancer_id, language_id) DO NOTHING;

-- ============================================================
-- 10. INSERT WORK EXPERIENCE (3 entries per freelancer)
-- ============================================================

INSERT INTO work_experience (freelancer_id, job_title, company_name, location, start_date, end_date, is_current, description)
SELECT f.freelancer_id, 'Senior Developer', 'Tech Company A', 'New York, USA', '2020-01-15'::date, '2023-12-31'::date, false, 'Led development team and built scalable applications'
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
WHERE u.email IN ('freelancer1@test.com', 'freelancer3@test.com', 'freelancer5@test.com', 'freelancer7@test.com', 'freelancer9@test.com')
UNION ALL
SELECT f.freelancer_id, 'Full Stack Engineer', 'Tech Company B', 'San Francisco, USA', '2021-03-01'::date, '2024-01-31'::date, false, 'Developed and maintained web applications'
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
WHERE u.email IN ('freelancer2@test.com', 'freelancer4@test.com', 'freelancer6@test.com', 'freelancer8@test.com', 'freelancer10@test.com')
UNION ALL
SELECT f.freelancer_id, 'Project Manager', 'Tech Company C', 'Austin, USA', '2023-06-01'::date, NULL, true, 'Currently managing multiple client projects'
FROM freelancer f
UNION ALL
SELECT f.freelancer_id, 'Junior Developer', 'Startup XYZ', 'Remote', '2019-05-10'::date, '2020-12-31'::date, false, 'Built initial MVP and core features'
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
WHERE u.email IN ('freelancer1@test.com', 'freelancer2@test.com', 'freelancer4@test.com', 'freelancer6@test.com')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 11. INSERT EDUCATION (2 entries per freelancer)
-- ============================================================

INSERT INTO education (freelancer_id, institution_name, degree, field_of_study, start_date, end_date, is_current, grade, description)
SELECT f.freelancer_id, 'University of Technology', 'Bachelor of Science', 'Computer Science', '2016-09-01'::date, '2020-05-31'::date, false, 'A', 'Graduated with honors'
FROM freelancer f
UNION ALL
SELECT f.freelancer_id, 'Online Academy', 'Professional Certification', 'Full Stack Development', '2022-01-15'::date, '2022-06-30'::date, false, 'A+', 'Completed advanced bootcamp'
FROM freelancer f
UNION ALL
SELECT f.freelancer_id, 'Tech Institute', 'Master of Science', 'Data Science', '2023-09-01'::date, NULL, true, 'In Progress', 'Currently pursuing advanced degree'
FROM freelancer f
JOIN users u ON f.user_id = u.user_id
WHERE u.email IN ('freelancer1@test.com', 'freelancer3@test.com', 'freelancer5@test.com')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 12. INSERT JOB POSTS (5 jobs per client)
-- ============================================================

INSERT INTO job_post (client_id, job_title, job_description, project_type, project_scope, estimated_duration, deadline, experience_level, status, posted_at)
SELECT c.client_id, 'Build E-Commerce Platform', 'Need experienced developer to build a full-featured e-commerce platform', 'team'::project_type, 'large'::project_scope, '3-4 months', '2026-07-01'::date, 'intermediate'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client1@test.com'
UNION ALL
SELECT c.client_id, 'Mobile App Development', 'Develop iOS and Android app for our startup', 'team'::project_type, 'medium'::project_scope, '2-3 months', '2026-06-15'::date, 'expert'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client2@test.com'
UNION ALL
SELECT c.client_id, 'Website Redesign', 'Redesign our company website with modern UI/UX', 'individual'::project_type, 'small'::project_scope, '4-6 weeks', '2026-05-31'::date, 'intermediate'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client3@test.com'
UNION ALL
SELECT c.client_id, 'Cloud Migration', 'Migrate legacy systems to AWS cloud infrastructure', 'team'::project_type, 'large'::project_scope, '2-3 months', '2026-07-15'::date, 'expert'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client4@test.com'
UNION ALL
SELECT c.client_id, 'Data Analytics Dashboard', 'Build real-time analytics dashboard', 'individual'::project_type, 'medium'::project_scope, '6-8 weeks', '2026-06-01'::date, 'intermediate'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client5@test.com'
UNION ALL
SELECT c.client_id, 'API Development', 'Develop RESTful APIs for mobile app', 'individual'::project_type, 'medium'::project_scope, '4-6 weeks', '2026-05-30'::date, 'intermediate'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client6@test.com'
UNION ALL
SELECT c.client_id, 'Testing Framework Setup', 'Setup automated testing and QA framework', 'individual'::project_type, 'small'::project_scope, '2-3 weeks', '2026-05-15'::date, 'intermediate'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client7@test.com'
UNION ALL
SELECT c.client_id, 'Game Development', 'Develop mobile game with multiplayer support', 'team'::project_type, 'large'::project_scope, '4-5 months', '2026-08-31'::date, 'expert'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client8@test.com'
UNION ALL
SELECT c.client_id, 'Database Optimization', 'Optimize PostgreSQL database performance', 'individual'::project_type, 'small'::project_scope, '2-4 weeks', '2026-05-20'::date, 'expert'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client9@test.com'
UNION ALL
SELECT c.client_id, 'DevOps Pipeline Setup', 'Setup CI/CD pipeline with Docker and Kubernetes', 'individual'::project_type, 'medium'::project_scope, '3-4 weeks', '2026-05-25'::date, 'expert'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client10@test.com'
ON CONFLICT DO NOTHING;

-- Additional jobs for more contracts and proposals
INSERT INTO job_post (client_id, job_title, job_description, project_type, project_scope, estimated_duration, deadline, experience_level, status, posted_at)
SELECT c.client_id, 'Frontend UI Components', 'Build reusable React component library', 'individual'::project_type, 'medium'::project_scope, '3-4 weeks', '2026-06-10'::date, 'intermediate'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client1@test.com'
UNION ALL
SELECT c.client_id, 'Backend API Enhancement', 'Enhance existing API with new features', 'individual'::project_type, 'medium'::project_scope, '2-3 weeks', '2026-05-28'::date, 'intermediate'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client2@test.com'
UNION ALL
SELECT c.client_id, 'Security Audit', 'Perform security audit and fix vulnerabilities', 'individual'::project_type, 'small'::project_scope, '2-3 weeks', '2026-05-22'::date, 'expert'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client3@test.com'
UNION ALL
SELECT c.client_id, 'ML Model Development', 'Develop ML models for recommendation system', 'team'::project_type, 'medium'::project_scope, '2-3 months', '2026-07-30'::date, 'expert'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client4@test.com'
UNION ALL
SELECT c.client_id, 'Performance Testing', 'Load testing and performance optimization', 'individual'::project_type, 'small'::project_scope, '2-3 weeks', '2026-05-25'::date, 'expert'::experience_level, 'active'::job_status, NOW()
FROM client c
JOIN users u ON c.user_id = u.user_id
WHERE u.email = 'client5@test.com'
ON CONFLICT DO NOTHING;

-- ============================================================
-- 13. INSERT JOB ROLES (2 roles per job post, use CTE to target specific jobs)
-- ============================================================

WITH job_posts_cte AS (
    SELECT jp.job_post_id, c.client_id
    FROM job_post jp
    JOIN client c ON jp.client_id = c.client_id
    JOIN users u ON c.user_id = u.user_id
    WHERE u.email IN ('client1@test.com', 'client2@test.com', 'client3@test.com', 'client4@test.com', 'client5@test.com')
    LIMIT 15
)
INSERT INTO job_role (job_post_id, role_title, role_budget, budget_currency, budget_type, role_description, positions_available, display_order)
SELECT 
    jp.job_post_id,
    'Senior Developer',
    5000.00,
    'USD',
    'fixed'::budget_type,
    'Lead development role with architectural responsibilities',
    1,
    1
FROM job_posts_cte jp
WHERE jp.client_id IN (SELECT c.client_id FROM client c JOIN users u ON c.user_id = u.user_id WHERE u.email = 'client1@test.com')
UNION ALL
SELECT 
    jp.job_post_id,
    'Junior Developer',
    2500.00,
    'USD',
    'fixed'::budget_type,
    'Support role for implementation',
    2,
    2
FROM job_posts_cte jp
WHERE jp.client_id IN (SELECT c.client_id FROM client c JOIN users u ON c.user_id = u.user_id WHERE u.email = 'client1@test.com')
UNION ALL
SELECT 
    jp.job_post_id,
    'Full Stack Developer',
    4000.00,
    'USD',
    'negotiable'::budget_type,
    'Full stack development responsibilities',
    1,
    1
FROM job_posts_cte jp
WHERE jp.client_id IN (SELECT c.client_id FROM client c JOIN users u ON c.user_id = u.user_id WHERE u.email = 'client2@test.com')
UNION ALL
SELECT 
    jp.job_post_id,
    'Designer',
    3000.00,
    'USD',
    'fixed'::budget_type,
    'UI/UX design role',
    1,
    1
FROM job_posts_cte jp
WHERE jp.client_id IN (SELECT c.client_id FROM client c JOIN users u ON c.user_id = u.user_id WHERE u.email = 'client3@test.com')
UNION ALL
SELECT 
    jp.job_post_id,
    'DevOps Engineer',
    4500.00,
    'USD',
    'fixed'::budget_type,
    'Infrastructure and deployment',
    1,
    1
FROM job_posts_cte jp
WHERE jp.client_id IN (SELECT c.client_id FROM client c JOIN users u ON c.user_id = u.user_id WHERE u.email = 'client4@test.com')
UNION ALL
SELECT 
    jp.job_post_id,
    'Data Scientist',
    5500.00,
    'USD',
    'fixed'::budget_type,
    'ML and data analysis role',
    1,
    1
FROM job_posts_cte jp
WHERE jp.client_id IN (SELECT c.client_id FROM client c JOIN users u ON c.user_id = u.user_id WHERE u.email = 'client5@test.com')
ON CONFLICT DO NOTHING;

-- ============================================================
-- 14. INSERT JOB ROLE SKILLS (3-4 skills per job role)
-- ============================================================

INSERT INTO job_role_skill (job_role_id, skill_id, is_required, importance_level)
SELECT jr.job_role_id, s.skill_id, true, 'required'
FROM job_role jr
CROSS JOIN skill s
WHERE s.skill_name IN ('Python', 'JavaScript', 'React', 'Node.js', 'PostgreSQL')
LIMIT 50
ON CONFLICT (job_role_id, skill_id) DO NOTHING;

INSERT INTO job_role_skill (job_role_id, skill_id, is_required, importance_level)
SELECT jr.job_role_id, s.skill_id, false, 'preferred'
FROM job_role jr
CROSS JOIN skill s
WHERE s.skill_name IN ('Docker', 'AWS', 'Git', 'API Development')
LIMIT 30
ON CONFLICT (job_role_id, skill_id) DO NOTHING;

-- ============================================================
-- 15. INSERT JOB FILES (files attached to job posts)
-- ============================================================

INSERT INTO job_file (job_post_id, file_url, file_type, file_name, file_size)
SELECT jp.job_post_id, 'https://example.com/files/requirements_' || ROW_NUMBER() OVER (ORDER BY jp.job_post_id) || '.pdf', 'pdf', 'requirements.pdf', 250000
FROM job_post jp
WHERE jp.status = 'active'
LIMIT 10
ON CONFLICT DO NOTHING;

-- ============================================================
-- 16. INSERT PROPOSALS (2-3 proposals per job from different freelancers)
-- ============================================================

INSERT INTO proposal (job_post_id, freelancer_id, cover_letter, proposed_budget, proposed_duration, status, submitted_at)
SELECT 
    rn.job_post_id,
    rn.freelancer_id,
    'I am interested in this project and have relevant experience.',
    2500.00 + (ROW_NUMBER() OVER (PARTITION BY rn.job_post_id ORDER BY rn.freelancer_id) * 500),
    '4-6 weeks',
    'pending'::proposal_status,
    NOW()
FROM (
    SELECT 
        jp.job_post_id,
        f.freelancer_id,
        ROW_NUMBER() OVER (PARTITION BY jp.job_post_id ORDER BY f.freelancer_id) as rn
    FROM job_post jp
    CROSS JOIN freelancer f
    WHERE jp.status = 'active'
) rn
WHERE rn.rn <= 3
ON CONFLICT DO NOTHING;

-- ============================================================
-- 17. INSERT PROPOSAL FILES
-- ============================================================

INSERT INTO proposal_file (proposal_id, file_url, file_type, file_name, file_size)
SELECT p.proposal_id, 'https://example.com/proposals/portfolio_' || ROW_NUMBER() OVER (ORDER BY p.proposal_id) || '.pdf', 'pdf', 'portfolio.pdf', 500000
FROM proposal p
LIMIT 15
ON CONFLICT DO NOTHING;

-- ============================================================
-- 18. INSERT CONTRACTS (accept some proposals)
-- ============================================================

INSERT INTO contract (
    job_post_id, job_role_id, proposal_id, freelancer_id, client_id,
    contract_title, role_title, agreed_budget, budget_currency, payment_structure,
    agreed_duration, status, start_date, end_date
)
SELECT 
    p.job_post_id,
    jr.job_role_id,
    p.proposal_id,
    p.freelancer_id,
    c.client_id,
    jp.job_title || ' - ' || f.full_name,
    jr.role_title,
    p.proposed_budget,
    'USD',
    'full_payment',
    p.proposed_duration,
    'active',
    '2024-01-01'::date,
    '2024-04-01'::date
FROM proposal p
JOIN job_post jp ON p.job_post_id = jp.job_post_id
JOIN client c ON jp.client_id = c.client_id
JOIN freelancer f ON p.freelancer_id = f.freelancer_id
JOIN job_role jr ON jp.job_post_id = jr.job_post_id
WHERE p.status = 'pending'
LIMIT 10
ON CONFLICT DO NOTHING;

-- ============================================================
-- 19. INSERT CONTRACT MILESTONES (3 milestones per contract)
-- ============================================================

INSERT INTO contract_milestone (
    contract_id, milestone_title, milestone_description, milestone_percentage,
    milestone_amount, milestone_order, due_date, status
)
SELECT 
    ct.contract_id,
    'Phase ' || i || ' Completion',
    'Complete phase ' || i || ' of the project',
    (100.00 / 3)::numeric,
    (ct.agreed_budget / 3)::numeric,
    i,
    ct.start_date + (INTERVAL '1 month' * i),
    CASE WHEN i = 1 THEN 'completed'::milestone_status ELSE 'pending'::milestone_status END
FROM contract ct
CROSS JOIN LATERAL generate_series(1, 3) i
ON CONFLICT DO NOTHING;

-- ============================================================
-- 20. INSERT PORTFOLIO (1-2 portfolio items per freelancer)
-- ============================================================

INSERT INTO portfolio (
    freelancer_id, project_title, project_description, project_url, completion_date, is_auto_generated
)
SELECT 
    f.freelancer_id,
    'Project ' || (ROW_NUMBER() OVER (PARTITION BY f.freelancer_id ORDER BY f.freelancer_id))::text,
    'Completed project showcasing skills',
    'https://example.com/portfolio/' || (ROW_NUMBER() OVER (PARTITION BY f.freelancer_id ORDER BY f.freelancer_id))::text,
    (NOW() - INTERVAL '6 months')::date,
    false
FROM freelancer f
LIMIT 20
ON CONFLICT DO NOTHING;

-- ============================================================
-- 21. INSERT SAVED JOBS (freelancers save some jobs)
-- ============================================================

INSERT INTO saved_job (freelancer_id, job_post_id, saved_at, notes)
SELECT 
    rn.freelancer_id,
    rn.job_post_id,
    NOW(),
    'Interesting opportunity to apply my skills'
FROM (
    SELECT 
        f.freelancer_id,
        jp.job_post_id,
        ROW_NUMBER() OVER (PARTITION BY f.freelancer_id ORDER BY jp.job_post_id) as rn
    FROM freelancer f
    CROSS JOIN job_post jp
    WHERE jp.status = 'active'::job_status
) rn
WHERE rn.rn <= 2
ON CONFLICT DO NOTHING;

-- ============================================================
-- 22. INSERT RATINGS (client rates freelancer after contract completion)
-- ============================================================

INSERT INTO rating (
    contract_id, client_id, freelancer_id,
    communication_score, result_quality_score, professionalism_score,
    timeline_compliance_score, overall_rating, review_text
)
SELECT 
    ct.contract_id,
    ct.client_id,
    ct.freelancer_id,
    5,
    5,
    5,
    5,
    5.00,
    'Excellent work! Professional and delivered on time. Highly recommended!'
FROM contract ct
WHERE ct.status IN ('completed'::contract_status, 'active'::contract_status)
LIMIT 10
ON CONFLICT (contract_id) DO NOTHING;

-- ============================================================
-- 23. INSERT PERFORMANCE RATINGS (aggregate ratings for freelancers)
-- ============================================================

INSERT INTO performance_rating (
    freelancer_id, overall_performance_score, confidence_score,
    total_ratings_received, average_communication, average_result_quality,
    average_professionalism, average_scope_compliance, average_timeline_compliance,
    success_rate, last_calculated_at
)
SELECT 
    f.freelancer_id,
    4.50,
    0.85,
    1,
    4.5,
    4.5,
    4.5,
    4.5,
    4.5,
    90.00,
    NOW()
FROM freelancer f
ON CONFLICT (freelancer_id) DO NOTHING;

-- ============================================================
-- 24. INSERT CLIENT TRUST SCORES
-- ============================================================

INSERT INTO client_trust_score (
    client_id, trust_score, rating_consistency_score, extreme_rating_ratio,
    project_completion_rate, average_budget_gap, total_ratings_given, last_calculated_at
)
SELECT 
    c.client_id,
    80.00,
    0.90,
    0.10,
    95.00,
    10.00,
    5,
    NOW()
FROM client c
ON CONFLICT (client_id) DO NOTHING;

-- ============================================================
-- 25. INSERT MESSAGES (communication between users)
-- ============================================================

INSERT INTO message (sender_id, receiver_id, contract_id, message_text, is_read, sent_at)
SELECT 
    u1.user_id,
    u2.user_id,
    ct.contract_id,
    'Hello, I''m starting work on the project. Will update you with progress.',
    true,
    NOW() - INTERVAL '2 days'
FROM contract ct
JOIN freelancer f ON ct.freelancer_id = f.freelancer_id
JOIN users u1 ON f.user_id = u1.user_id
JOIN client c ON ct.client_id = c.client_id
JOIN users u2 ON c.user_id = u2.user_id
LIMIT 10
ON CONFLICT DO NOTHING;

INSERT INTO message (sender_id, receiver_id, contract_id, message_text, is_read, sent_at)
SELECT 
    u2.user_id,
    u1.user_id,
    ct.contract_id,
    'Great! I''m looking forward to seeing the progress. Please keep me updated.',
    false,
    NOW() - INTERVAL '1 day'
FROM contract ct
JOIN freelancer f ON ct.freelancer_id = f.freelancer_id
JOIN users u1 ON f.user_id = u1.user_id
JOIN client c ON ct.client_id = c.client_id
JOIN users u2 ON c.user_id = u2.user_id
LIMIT 10
ON CONFLICT DO NOTHING;

-- ============================================================
-- 26. INSERT FREELANCER EMBEDDINGS (dummy vectors)
-- ============================================================

INSERT INTO freelancer_embedding (freelancer_id, embedding_vector, source_text, embedding_metadata)
SELECT 
    f.freelancer_id,
    (SELECT array_agg((random() * 2 - 1)::real) FROM generate_series(1, 1536))::vector,
    f.full_name || ' - ' || COALESCE((SELECT bio FROM freelancer WHERE freelancer_id = f.freelancer_id), 'Professional freelancer'),
    jsonb_build_object('profile_type', 'freelancer', 'updated', NOW()::text)
FROM freelancer f
ON CONFLICT (freelancer_id) DO NOTHING;

-- ============================================================
-- 27. INSERT JOB EMBEDDINGS (dummy vectors)
-- ============================================================

INSERT INTO job_embedding (job_post_id, embedding_vector, source_text, embedding_metadata)
SELECT 
    jp.job_post_id,
    (SELECT array_agg((random() * 2 - 1)::real) FROM generate_series(1, 1536))::vector,
    jp.job_title || ' - ' || jp.job_description,
    jsonb_build_object('job_type', jp.project_type::text, 'updated', NOW()::text)
FROM job_post jp
WHERE jp.status = 'active'::job_status
ON CONFLICT (job_post_id) DO NOTHING;

-- ============================================================
-- SUMMARY STATISTICS
-- ============================================================

-- Display inserted data counts
SELECT 'Users' as entity, COUNT(*) as count FROM users
UNION ALL
SELECT 'Freelancers', COUNT(*) FROM freelancer
UNION ALL
SELECT 'Clients', COUNT(*) FROM client
UNION ALL
SELECT 'Skills', COUNT(*) FROM skill
UNION ALL
SELECT 'Specialities', COUNT(*) FROM speciality
UNION ALL
SELECT 'Languages', COUNT(*) FROM language
UNION ALL
SELECT 'Freelancer Skills', COUNT(*) FROM freelancer_skill
UNION ALL
SELECT 'Freelancer Specialities', COUNT(*) FROM freelancer_speciality
UNION ALL
SELECT 'Freelancer Languages', COUNT(*) FROM freelancer_language
UNION ALL
SELECT 'Work Experience', COUNT(*) FROM work_experience
UNION ALL
SELECT 'Education', COUNT(*) FROM education
UNION ALL
SELECT 'Job Posts', COUNT(*) FROM job_post
UNION ALL
SELECT 'Job Roles', COUNT(*) FROM job_role
UNION ALL
SELECT 'Job Role Skills', COUNT(*) FROM job_role_skill
UNION ALL
SELECT 'Job Files', COUNT(*) FROM job_file
UNION ALL
SELECT 'Proposals', COUNT(*) FROM proposal
UNION ALL
SELECT 'Proposal Files', COUNT(*) FROM proposal_file
UNION ALL
SELECT 'Contracts', COUNT(*) FROM contract
UNION ALL
SELECT 'Contract Milestones', COUNT(*) FROM contract_milestone
UNION ALL
SELECT 'Portfolio', COUNT(*) FROM portfolio
UNION ALL
SELECT 'Saved Jobs', COUNT(*) FROM saved_job
UNION ALL
SELECT 'Ratings', COUNT(*) FROM rating
UNION ALL
SELECT 'Performance Ratings', COUNT(*) FROM performance_rating
UNION ALL
SELECT 'Client Trust Scores', COUNT(*) FROM client_trust_score
UNION ALL
SELECT 'Freelancer Embeddings', COUNT(*) FROM freelancer_embedding
UNION ALL
SELECT 'Job Embeddings', COUNT(*) FROM job_embedding
UNION ALL
SELECT 'Messages', COUNT(*) FROM message
ORDER BY count DESC;
