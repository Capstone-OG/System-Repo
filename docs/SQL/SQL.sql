-- =====================================================================
-- V-EVAL ADAPTIVE LEARNING PLATFORM — UNIFIED MASTER DATABASE SCHEMA V5.0
-- Sinh từ ERD v3 (VEval_ERD_3Pages_v3.drawio). Ngày ban hành: 29/10/2026
-- Cập nhật: Bổ sung PayOS Payment Integration & Chu trình PLAR (03/11/2026)
-- DBMS: PostgreSQL 13 trở lên (Hỗ trợ pgcrypto & timestamptz)
-- Quy ước: Tên bảng PascalCase trong ngoặc kép, tên cột snake_case trong ngoặc kép
-- Kiến trúc: Microservices Database-per-Service
--   - Khóa ngoại VẬT LÝ (Physical FK): CHỈ tạo khi bảng cha và con CÙNG schema.
--   - Khóa ngoại LOGIC (Logical FK*): Tham chiếu liên schema được quản lý qua tầng ứng dụng / Event Bus.
-- Tổng số: 51 bảng, 5 Bounded Context Schemas (identity 12, content 8, enrollment 5, practice 19, outcome 7).
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS pgcrypto;  -- gen_random_uuid() cho PostgreSQL < 13

-- Khởi tạo 5 Schemas nghiệp vụ cốt lõi
CREATE SCHEMA IF NOT EXISTS v_eval_identity;    -- 1. Định danh, phân quyền RBAC và hồ sơ các actor
CREATE SCHEMA IF NOT EXISTS v_eval_content;     -- 2. Khung năng lực, kỹ năng tiên quyết, học liệu và ngân hàng đề thi
CREATE SCHEMA IF NOT EXISTS v_eval_enrollment;  -- 3. Khóa học, chuẩn đầu ra, đăng ký và thanh toán PayOS
CREATE SCHEMA IF NOT EXISTS v_eval_practice;    -- 4. Lớp học offline, nhóm vi mô, lộ trình thích ứng PLAR, BKT & chuyên cần
CREATE SCHEMA IF NOT EXISTS v_eval_outcome;     -- 5. Nguyện vọng đại học, điểm thi thật, kết quả trúng tuyển & hiệu quả tăng điểm

-- =====================================================================
-- PHÂN HỆ 1: SCHEMA v_eval_identity (12 bảng)
-- Định danh, phân quyền RBAC và hồ sơ các actor
-- =====================================================================

-- 1. Cơ sở đào tạo offline (địa chỉ, điện thoại, trạng thái hoạt động).
CREATE TABLE IF NOT EXISTS v_eval_identity."Campuses" (
    "campus_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "code" varchar(50) UNIQUE,
    "name" varchar(255) NOT NULL,
    "address" varchar(500) NOT NULL,
    "phone" varchar(50) NOT NULL,
    "is_active" boolean NOT NULL DEFAULT true,
    "created_at" timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE v_eval_identity."Campuses" IS 'Cơ sở đào tạo offline (địa chỉ, điện thoại, trạng thái hoạt động).';

-- 2. Tài khoản đăng nhập tập trung cho mọi vai trò (email, mật khẩu băm, họ tên).
CREATE TABLE IF NOT EXISTS v_eval_identity."Users" (
    "user_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "email" varchar(255) NOT NULL UNIQUE,
    "password_hash" text NOT NULL,
    "full_name" varchar(255) NOT NULL,
    "phone" varchar(50) NOT NULL,
    "avatar_url" text,
    "is_active" boolean NOT NULL DEFAULT false,
    "created_at" timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE v_eval_identity."Users" IS 'Tài khoản đăng nhập tập trung cho mọi vai trò (email, mật khẩu băm, họ tên).';

-- 3. Danh mục vai trò phân quyền RBAC.
CREATE TABLE IF NOT EXISTS v_eval_identity."Roles" (
    "role_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "role_name" varchar(50) NOT NULL UNIQUE
);
COMMENT ON TABLE v_eval_identity."Roles" IS 'Danh mục vai trò phân quyền RBAC.';

-- 4. Bảng nối gán vai trò cho tài khoản (nhiều–nhiều).
CREATE TABLE IF NOT EXISTS v_eval_identity."UserRoles" (
    "user_id" uuid NOT NULL,
    "role_id" uuid NOT NULL,
    PRIMARY KEY ("user_id", "role_id"),
    CONSTRAINT "fk_userroles_user_id" FOREIGN KEY ("user_id") REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    CONSTRAINT "fk_userroles_role_id" FOREIGN KEY ("role_id") REFERENCES v_eval_identity."Roles"("role_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_identity."UserRoles" IS 'Bảng nối gán vai trò cho tài khoản (nhiều–nhiều).';

-- 5. Hồ sơ học sinh, quan hệ 1–1 với Users, thuộc một cơ sở.
CREATE TABLE IF NOT EXISTS v_eval_identity."Students" (
    "student_id" uuid PRIMARY KEY,
    "campus_id" uuid NOT NULL,
    "school_name" varchar(255),
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_students_student_id" FOREIGN KEY ("student_id") REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    CONSTRAINT "fk_students_campus_id" FOREIGN KEY ("campus_id") REFERENCES v_eval_identity."Campuses"("campus_id") ON DELETE RESTRICT
);
COMMENT ON TABLE v_eval_identity."Students" IS 'Hồ sơ học sinh, quan hệ 1–1 với Users, thuộc một cơ sở.';

-- 6. Hồ sơ phụ huynh, quan hệ 1–1 với Users.
CREATE TABLE IF NOT EXISTS v_eval_identity."Parents" (
    "parent_id" uuid PRIMARY KEY,
    "phone_work" varchar(50),
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_parents_parent_id" FOREIGN KEY ("parent_id") REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_identity."Parents" IS 'Hồ sơ phụ huynh, quan hệ 1–1 với Users.';

-- 7. Quan hệ giám hộ giữa phụ huynh và học sinh (nhiều–nhiều).
CREATE TABLE IF NOT EXISTS v_eval_identity."ParentStudentRelations" (
    "relation_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "parent_id" uuid NOT NULL,
    "student_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "uq_parentstudentrelations" UNIQUE ("parent_id", "student_id"),
    CONSTRAINT "fk_parentstudentrelations_parent_id" FOREIGN KEY ("parent_id") REFERENCES v_eval_identity."Parents"("parent_id") ON DELETE RESTRICT,
    CONSTRAINT "fk_parentstudentrelations_student_id" FOREIGN KEY ("student_id") REFERENCES v_eval_identity."Students"("student_id") ON DELETE RESTRICT
);
COMMENT ON TABLE v_eval_identity."ParentStudentRelations" IS 'Quan hệ giám hộ giữa phụ huynh và học sinh (nhiều–nhiều).';

-- 8. Hồ sơ giáo viên / Lead Mentor, quan hệ 1–1 với Users, thuộc một cơ sở.
CREATE TABLE IF NOT EXISTS v_eval_identity."Teachers" (
    "teacher_id" uuid PRIMARY KEY,
    "campus_id" uuid NOT NULL,
    "bio" text,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_teachers_teacher_id" FOREIGN KEY ("teacher_id") REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    CONSTRAINT "fk_teachers_campus_id" FOREIGN KEY ("campus_id") REFERENCES v_eval_identity."Campuses"("campus_id") ON DELETE RESTRICT
);
COMMENT ON TABLE v_eval_identity."Teachers" IS 'Hồ sơ giáo viên / Lead Mentor, quan hệ 1–1 với Users, thuộc một cơ sở.';

-- 9. Môn (miền năng lực) mà mỗi giáo viên được phép dạy; căn cứ để gán giáo viên vào lớp.
CREATE TABLE IF NOT EXISTS v_eval_identity."TeacherSubjects" (
    "teacher_id" uuid NOT NULL,
    "domain_id" uuid NOT NULL,  -- FK* logic -> v_eval_content."CompetencyDomains"(domain_id)
    "assigned_at" timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY ("teacher_id", "domain_id"),
    CONSTRAINT "fk_teachersubjects_teacher_id" FOREIGN KEY ("teacher_id") REFERENCES v_eval_identity."Teachers"("teacher_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_identity."TeacherSubjects" IS 'Môn (miền năng lực) mà mỗi giáo viên được phép dạy; căn cứ để gán giáo viên vào lớp.';

-- 10. Hồ sơ quản lý học vụ của cơ sở, quan hệ 1–1 với Users.
CREATE TABLE IF NOT EXISTS v_eval_identity."AcademicManagers" (
    "manager_id" uuid PRIMARY KEY,
    "campus_id" uuid NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_academicmanagers_manager_id" FOREIGN KEY ("manager_id") REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    CONSTRAINT "fk_academicmanagers_campus_id" FOREIGN KEY ("campus_id") REFERENCES v_eval_identity."Campuses"("campus_id") ON DELETE RESTRICT
);
COMMENT ON TABLE v_eval_identity."AcademicManagers" IS 'Hồ sơ quản lý học vụ của cơ sở, quan hệ 1–1 với Users.';

-- 11. Hồ sơ giám đốc đào tạo, quan hệ 1–1 với Users.
CREATE TABLE IF NOT EXISTS v_eval_identity."AcademicDirectors" (
    "director_id" uuid PRIMARY KEY,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_academicdirectors_director_id" FOREIGN KEY ("director_id") REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_identity."AcademicDirectors" IS 'Hồ sơ giám đốc đào tạo, quan hệ 1–1 với Users.';

-- 12. Hồ sơ quản trị viên kỹ thuật, quan hệ 1–1 với Users.
CREATE TABLE IF NOT EXISTS v_eval_identity."Administrators" (
    "admin_id" uuid PRIMARY KEY,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_administrators_admin_id" FOREIGN KEY ("admin_id") REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_identity."Administrators" IS 'Hồ sơ quản trị viên kỹ thuật, quan hệ 1–1 với Users.';

-- =====================================================================
-- PHÂN HỆ 2: SCHEMA v_eval_content (8 bảng)
-- Khung năng lực, kỹ năng tiên quyết, học liệu, ngân hàng câu hỏi và đề thi
-- =====================================================================

-- 13. Miền năng lực / môn của kỳ thi ĐGNL (cấp 1 của khung năng lực).
CREATE TABLE IF NOT EXISTS v_eval_content."CompetencyDomains" (
    "domain_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "description" text
);
COMMENT ON TABLE v_eval_content."CompetencyDomains" IS 'Miền năng lực / môn của kỳ thi ĐGNL (cấp 1 của khung năng lực).';

-- 14. Cây kỹ năng vi mô (có cha–con), thuộc một miền; exam_weight_pct là tỉ trọng trong đề thi.
CREATE TABLE IF NOT EXISTS v_eval_content."Skills" (
    "skill_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "domain_id" uuid NOT NULL,
    "parent_id" uuid,
    "name" text NOT NULL,
    "exam_weight_pct" numeric(5,2) NOT NULL DEFAULT 0,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_skills_domain_id" FOREIGN KEY ("domain_id") REFERENCES v_eval_content."CompetencyDomains"("domain_id") ON DELETE RESTRICT,
    CONSTRAINT "fk_skills_parent_id" FOREIGN KEY ("parent_id") REFERENCES v_eval_content."Skills"("skill_id") ON DELETE SET NULL
);
COMMENT ON TABLE v_eval_content."Skills" IS 'Cây kỹ năng vi mô (có cha–con), thuộc một miền; exam_weight_pct là tỉ trọng trong đề thi.';

-- 15. Đồ thị có hướng không chu trình (DAG) kỹ năng tiên quyết.
CREATE TABLE IF NOT EXISTS v_eval_content."SkillPrerequisites" (
    "skill_id" uuid NOT NULL,
    "prerequisite_id" uuid NOT NULL,
    PRIMARY KEY ("skill_id", "prerequisite_id"),
    CONSTRAINT "fk_skillprerequisites_skill_id" FOREIGN KEY ("skill_id") REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
    CONSTRAINT "fk_skillprerequisites_prerequisite_id" FOREIGN KEY ("prerequisite_id") REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_content."SkillPrerequisites" IS 'Đồ thị có hướng không chu trình (DAG) kỹ năng tiên quyết.';

-- 16. Học liệu sư phạm chuẩn (nội dung, video, tệp) gắn với kỹ năng.
CREATE TABLE IF NOT EXISTS v_eval_content."Materials" (
    "material_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "skill_id" uuid NOT NULL,
    "title" text NOT NULL,
    "content" text NOT NULL,
    "video_url" text,
    "file_url" text,
    "duration_seconds" integer NOT NULL DEFAULT 0,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_materials_skill_id" FOREIGN KEY ("skill_id") REFERENCES v_eval_content."Skills"("skill_id") ON DELETE RESTRICT
);
COMMENT ON TABLE v_eval_content."Materials" IS 'Học liệu sư phạm chuẩn (nội dung, video, tệp) gắn với kỹ năng.';

-- 17. Ngữ liệu đọc hiểu / dữ liệu khoa học dùng chung cho nhiều câu hỏi.
CREATE TABLE IF NOT EXISTS v_eval_content."Passages" (
    "passage_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "title" text,
    "content" text NOT NULL,
    "image_url" text
);
COMMENT ON TABLE v_eval_content."Passages" IS 'Ngữ liệu đọc hiểu / dữ liệu khoa học dùng chung cho nhiều câu hỏi.';

-- 18. Ngân hàng câu hỏi trắc nghiệm chuẩn hóa, 4 mức độ khó.
CREATE TABLE IF NOT EXISTS v_eval_content."Questions" (
    "question_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "skill_id" uuid NOT NULL,
    "passage_id" uuid,
    "difficulty_level" smallint NOT NULL,
    "content_latex" text NOT NULL,
    "option_a" text NOT NULL,
    "option_b" text NOT NULL,
    "option_c" text NOT NULL,
    "option_d" text NOT NULL,
    "correct_option" char(1) NOT NULL,
    "explanation" text,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_questions_skill_id" FOREIGN KEY ("skill_id") REFERENCES v_eval_content."Skills"("skill_id") ON DELETE RESTRICT,
    CONSTRAINT "fk_questions_passage_id" FOREIGN KEY ("passage_id") REFERENCES v_eval_content."Passages"("passage_id") ON DELETE SET NULL,
    CHECK (difficulty_level BETWEEN 1 AND 4),
    CHECK (correct_option IN ('A','B','C','D'))
);
COMMENT ON TABLE v_eval_content."Questions" IS 'Ngân hàng câu hỏi trắc nghiệm chuẩn hóa, 4 mức độ khó.';

-- 19. Bộ đề thi chuẩn hóa: khảo sát đầu vào, đề thi thử đầy đủ, bài kiểm tra nhỏ.
CREATE TABLE IF NOT EXISTS v_eval_content."MockExams" (
    "exam_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "title" text NOT NULL,
    "duration_minutes" integer NOT NULL DEFAULT 150,
    "total_questions" integer NOT NULL DEFAULT 120,
    "is_published" boolean NOT NULL DEFAULT false,
    "exam_category" varchar(30) NOT NULL DEFAULT 'FULL_MOCK',
    "subject_code" text,
    "difficulty_level" smallint,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CHECK (exam_category IN ('DIAGNOSTIC','FULL_MOCK','MINI_TEST'))
);
COMMENT ON TABLE v_eval_content."MockExams" IS 'Bộ đề thi chuẩn hóa: khảo sát đầu vào, đề thi thử đầy đủ, bài kiểm tra nhỏ.';

-- 20. Ma trận câu hỏi trong đề thi, có thứ tự (nhiều–nhiều).
CREATE TABLE IF NOT EXISTS v_eval_content."ExamQuestions" (
    "exam_id" uuid NOT NULL,
    "question_id" uuid NOT NULL,
    "question_order" integer NOT NULL,
    PRIMARY KEY ("exam_id", "question_id"),
    CONSTRAINT "fk_examquestions_exam_id" FOREIGN KEY ("exam_id") REFERENCES v_eval_content."MockExams"("exam_id") ON DELETE CASCADE,
    CONSTRAINT "fk_examquestions_question_id" FOREIGN KEY ("question_id") REFERENCES v_eval_content."Questions"("question_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_content."ExamQuestions" IS 'Ma trận câu hỏi trong đề thi, có thứ tự (nhiều–nhiều).';

-- =====================================================================
-- PHÂN HỆ 3: SCHEMA v_eval_enrollment (5 bảng)
-- Khóa học, chuẩn đầu ra, đăng ký và thanh toán tích hợp PayOS / VietQR
-- =====================================================================

-- 21. Khóa học do cơ sở mở: gói, thời lượng, học phí, chính sách học lại, sĩ số tối đa.
CREATE TABLE IF NOT EXISTS v_eval_enrollment."Courses" (
    "course_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "campus_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Campuses"(campus_id)
    "code" varchar(50) NOT NULL UNIQUE,
    "name" varchar(255) NOT NULL,
    "plan_type" varchar(20) NOT NULL DEFAULT 'STANDARD',
    "duration_weeks" integer NOT NULL,
    "tuition_fee" numeric(12,2) NOT NULL,
    "retake_policy" varchar(20) NOT NULL DEFAULT 'PAID',
    "retake_fee" numeric(12,2) NOT NULL DEFAULT 0,
    "max_class_size" integer NOT NULL DEFAULT 20,
    "is_active" boolean NOT NULL DEFAULT true,
    "created_at" timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE v_eval_enrollment."Courses" IS 'Khóa học do cơ sở mở: gói, thời lượng, học phí, chính sách học lại, sĩ số tối đa.';

-- 22. Tiêu chuẩn đầu ra của khóa (điểm dự báo, độ phủ kỹ năng, độ đều đặn tối thiểu).
CREATE TABLE IF NOT EXISTS v_eval_enrollment."ReadinessStandards" (
    "standard_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "course_id" uuid NOT NULL,
    "min_predicted_score" integer NOT NULL,
    "min_skill_coverage" numeric(5,2) NOT NULL,
    "min_consistency" numeric(5,2),
    "description" text,
    CONSTRAINT "fk_readinessstandards_course_id" FOREIGN KEY ("course_id") REFERENCES v_eval_enrollment."Courses"("course_id") ON DELETE RESTRICT
);
COMMENT ON TABLE v_eval_enrollment."ReadinessStandards" IS 'Tiêu chuẩn đầu ra của khóa (điểm dự báo, độ phủ kỹ năng, độ đều đặn tối thiểu).';

-- 23. Đăng ký khóa học của học sinh; attempt_no và previous_registration_id biểu diễn các lần học lại.
CREATE TABLE IF NOT EXISTS v_eval_enrollment."CourseRegistrations" (
    "registration_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "course_id" uuid NOT NULL,
    "previous_registration_id" uuid,
    "attempt_no" integer NOT NULL DEFAULT 1,
    "status" varchar(30) NOT NULL DEFAULT 'PENDING_PAYMENT',
    "registered_at" timestamptz NOT NULL DEFAULT now(),
    "start_date" date,
    "end_date" date,
    CONSTRAINT "uq_courseregistrations" UNIQUE ("student_id", "course_id", "attempt_no"),
    CONSTRAINT "fk_courseregistrations_course_id" FOREIGN KEY ("course_id") REFERENCES v_eval_enrollment."Courses"("course_id") ON DELETE RESTRICT,
    CONSTRAINT "fk_courseregistrations_previous_registration_id" FOREIGN KEY ("previous_registration_id") REFERENCES v_eval_enrollment."CourseRegistrations"("registration_id") ON DELETE SET NULL
);
COMMENT ON TABLE v_eval_enrollment."CourseRegistrations" IS 'Đăng ký khóa học của học sinh; attempt_no và previous_registration_id biểu diễn các lần học lại.';

-- 24. Thanh toán học phí tích hợp Cổng thanh toán PayOS (VietQR) / Chuyển khoản.
CREATE TABLE IF NOT EXISTS v_eval_enrollment."Payments" (
    "payment_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "registration_id" uuid NOT NULL,
    "parent_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Parents"(parent_id)
    "payment_type" varchar(20) NOT NULL DEFAULT 'TUITION',
    "amount" numeric(12,2) NOT NULL,
    "method" varchar(30) NOT NULL DEFAULT 'PAYOS',
    "status" varchar(20) NOT NULL DEFAULT 'PENDING',
    "transaction_ref" varchar(100) UNIQUE,
    "order_code" bigint UNIQUE,                          -- PayOS OrderCode (Số nguyên dương JavaScript-safe)
    "checkout_url" text,                                 -- Link trang thanh toán VietQR do PayOS trả về
    "payment_link_id" varchar(100),                      -- ID link thanh toán trên hệ thống PayOS
    "counter_account_bank_name" varchar(100),            -- Ngân hàng người nộp tiền (nhận qua IPN Webhook)
    "counter_account_name" varchar(255),                 -- Tên chủ thẻ/tài khoản người nộp
    "counter_account_number" varchar(100),               -- Số tài khoản nộp
    "idempotency_key" varchar(100) UNIQUE,               -- Khóa chống double-spend / gọi trùng Webhook
    "paid_at" timestamptz,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_payments_registration_id" FOREIGN KEY ("registration_id") REFERENCES v_eval_enrollment."CourseRegistrations"("registration_id") ON DELETE RESTRICT,
    CHECK (status IN ('PENDING','PROCESSING','SUCCESS','FAILED','REFUNDED'))
);
COMMENT ON TABLE v_eval_enrollment."Payments" IS 'Thanh toán học phí tích hợp Cổng PayOS (VietQR) kèm mã order_code và dữ liệu đối soát.';

-- 25. Nhật ký giao dịch và Webhook IPN từ PayOS phục vụ kiểm toán tài chính (Audit Logs).
CREATE TABLE IF NOT EXISTS v_eval_enrollment."PaymentTransactions" (
    "transaction_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "payment_id" uuid NOT NULL,
    "event_type" varchar(50) NOT NULL,                   -- WEBHOOK_RECEIVED, STATUS_UPDATED, SIGNATURE_VERIFIED
    "raw_payload" text,                                  -- Chuỗi JSON Webhook gốc gửi từ PayOS
    "signature" text,                                    -- Chữ ký HMAC-SHA512 kiểm định tính toàn vẹn
    "ip_address" varchar(50),
    "logged_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_paymenttransactions_payment_id" FOREIGN KEY ("payment_id") REFERENCES v_eval_enrollment."Payments"("payment_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_enrollment."PaymentTransactions" IS 'Nhật ký giao dịch và Webhook IPN từ PayOS phục vụ kiểm toán tài chính.';

-- =====================================================================
-- PHÂN HỆ 4: SCHEMA v_eval_practice (19 bảng)
-- Lớp học, lộ trình thích ứng PLAR, bài làm, theo dõi năng lực và cảnh báo
-- =====================================================================

-- 26. Lớp học trực tiếp (tối đa 20 học sinh), một môn, một giáo viên; có thể là lớp phân cụm theo cohort.
CREATE TABLE IF NOT EXISTS v_eval_practice."Classes" (
    "class_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "campus_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Campuses"(campus_id)
    "course_id" uuid NOT NULL,  -- FK* logic -> v_eval_enrollment."Courses"(course_id)
    "domain_id" uuid NOT NULL,
    "teacher_id" uuid,  -- FK* logic -> v_eval_identity."TeacherSubjects"(teacher_id)
    "name" text NOT NULL,
    "status" varchar(30) NOT NULL DEFAULT 'ACTIVE',
    "class_type" smallint NOT NULL DEFAULT 0,
    "cluster_index" integer,
    "max_capacity" integer NOT NULL DEFAULT 20,
    "start_date" date,
    "end_date" date,
    "created_at" timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE v_eval_practice."Classes" IS 'Lớp học trực tiếp (tối đa 20 học sinh), một môn, một giáo viên; có thể là lớp phân cụm theo cohort.';

-- 27. Các buổi học của lớp: ngày, giờ, phòng, kỹ năng dạy, trạng thái.
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassSessions" (
    "session_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "class_id" uuid NOT NULL,
    "skill_id" uuid,  -- FK* logic -> v_eval_content."Skills"(skill_id)
    "session_date" date NOT NULL,
    "start_time" time NOT NULL,
    "end_time" time NOT NULL,
    "room" varchar(100),
    "status" varchar(30) NOT NULL DEFAULT 'SCHEDULED',
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "uq_classsessions" UNIQUE ("class_id", "session_date", "start_time"),
    CONSTRAINT "fk_classsessions_class_id" FOREIGN KEY ("class_id") REFERENCES v_eval_practice."Classes"("class_id") ON DELETE CASCADE,
    CHECK (end_time > start_time)
);
COMMENT ON TABLE v_eval_practice."ClassSessions" IS 'Các buổi học của lớp: ngày, giờ, phòng, kỹ năng dạy, trạng thái.';

-- 28. Kỹ năng chủ đạo của lớp kèm thứ tự ưu tiên.
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassSkills" (
    "class_id" uuid NOT NULL,
    "skill_id" uuid NOT NULL,  -- FK* logic -> v_eval_content."Skills"(skill_id)
    "priority" integer NOT NULL,
    PRIMARY KEY ("class_id", "skill_id"),
    CONSTRAINT "fk_classskills_class_id" FOREIGN KEY ("class_id") REFERENCES v_eval_practice."Classes"("class_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_practice."ClassSkills" IS 'Kỹ năng chủ đạo của lớp kèm thứ tự ưu tiên.';

-- 29. Bài làm của học sinh, kèm kết quả, theta khởi điểm, xếp lớp và dữ liệu liêm chính (proctoring).
CREATE TABLE IF NOT EXISTS v_eval_practice."ExamSubmissions" (
    "submission_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "exam_id" uuid NOT NULL,  -- FK* logic -> v_eval_content."MockExams"(exam_id)
    "exam_type" varchar(30) NOT NULL,
    "total_score" integer NOT NULL DEFAULT 0,
    "total_correct" integer NOT NULL DEFAULT 0,
    "total_questions" integer NOT NULL DEFAULT 0,
    "total_time_spent_seconds" integer NOT NULL DEFAULT 0,
    "started_at" timestamptz NOT NULL DEFAULT now(),
    "completed_at" timestamptz,
    "status" varchar(30) NOT NULL DEFAULT 'SUBMITTED',
    "theta_0" double precision,
    "placement_class" varchar(50),
    "tab_departure_count" integer NOT NULL DEFAULT 0,
    "integrity_status" varchar(30) NOT NULL DEFAULT 'NORMAL',
    "mentor_verdict" varchar(30) NOT NULL DEFAULT 'PENDING',
    "mentor_notes" text,
    CHECK (integrity_status IN ('NORMAL','FLAGGED','CLEAN')),
    CHECK (mentor_verdict IN ('PENDING','APPROVED','DISQUALIFIED'))
);
COMMENT ON TABLE v_eval_practice."ExamSubmissions" IS 'Bài làm của học sinh, kèm kết quả, theta khởi điểm, xếp lớp và dữ liệu liêm chính (proctoring).';

-- 30. Ghi danh học sinh vào lớp, gắn với đăng ký khóa học và bài khảo sát đầu vào.
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassEnrollments" (
    "enrollment_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "class_id" uuid NOT NULL,
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "registration_id" uuid NOT NULL,  -- FK* logic -> v_eval_enrollment."CourseRegistrations"(registration_id)
    "diagnostic_submission_id" uuid,
    "approved_by" uuid,
    "status" varchar(30) NOT NULL DEFAULT 'ENROLLED',
    "enrolled_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "uq_classenrollments" UNIQUE ("class_id", "student_id"),
    CONSTRAINT "fk_classenrollments_class_id" FOREIGN KEY ("class_id") REFERENCES v_eval_practice."Classes"("class_id") ON DELETE RESTRICT,
    CONSTRAINT "fk_classenrollments_diagnostic_submission_id" FOREIGN KEY ("diagnostic_submission_id") REFERENCES v_eval_practice."ExamSubmissions"("submission_id") ON DELETE SET NULL
);
COMMENT ON TABLE v_eval_practice."ClassEnrollments" IS 'Ghi danh học sinh vào lớp, gắn với đăng ký khóa học và bài khảo sát đầu vào.';

-- 31. Nhóm học tập vi mô 3–5 học sinh cùng lỗ hổng kiến thức trong một lớp.
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassGroups" (
    "group_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "class_id" uuid NOT NULL,
    "group_name" varchar(255) NOT NULL,
    "focus_area" varchar(255),
    "recommended_worksheet_title" varchar(255),
    "assigned_worksheet_title" varchar(255),
    "worksheet_assigned_at" timestamptz,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_classgroups_class_id" FOREIGN KEY ("class_id") REFERENCES v_eval_practice."Classes"("class_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_practice."ClassGroups" IS 'Nhóm học tập vi mô 3–5 học sinh cùng lỗ hổng kiến thức trong một lớp.';

-- 32. Các kỹ năng yếu chung của nhóm vi mô (nhiều–nhiều).
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassGroupSkills" (
    "group_id" uuid NOT NULL,
    "skill_id" uuid NOT NULL,  -- FK* logic -> v_eval_content."Skills"(skill_id)
    PRIMARY KEY ("group_id", "skill_id"),
    CONSTRAINT "fk_classgroupskills_group_id" FOREIGN KEY ("group_id") REFERENCES v_eval_practice."ClassGroups"("group_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_practice."ClassGroupSkills" IS 'Các kỹ năng yếu chung của nhóm vi mô (nhiều–nhiều).';

-- 33. Thành viên của nhóm vi mô.
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassGroupMembers" (
    "group_member_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "group_id" uuid NOT NULL,
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "joined_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "uq_classgroupmembers" UNIQUE ("group_id", "student_id"),
    CONSTRAINT "fk_classgroupmembers_group_id" FOREIGN KEY ("group_id") REFERENCES v_eval_practice."ClassGroups"("group_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_practice."ClassGroupMembers" IS 'Thành viên của nhóm vi mô.';

-- 34. Chi tiết từng câu trả lời trong một bài làm.
CREATE TABLE IF NOT EXISTS v_eval_practice."SubmissionAnswers" (
    "answer_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "submission_id" uuid NOT NULL,
    "question_id" uuid NOT NULL,  -- FK* logic -> v_eval_content."Questions"(question_id)
    "selected_option" varchar(10),
    "is_correct" boolean NOT NULL,
    "time_spent_seconds" integer NOT NULL DEFAULT 0,
    CONSTRAINT "fk_submissionanswers_submission_id" FOREIGN KEY ("submission_id") REFERENCES v_eval_practice."ExamSubmissions"("submission_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_practice."SubmissionAnswers" IS 'Chi tiết từng câu trả lời trong một bài làm.';

-- 35. Ảnh webcam chụp trong lúc thi để giám sát liêm chính.
CREATE TABLE IF NOT EXISTS v_eval_practice."ProctoringSnapshots" (
    "snapshot_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "submission_id" uuid NOT NULL,
    "snapshot_url" text NOT NULL,
    "captured_at" timestamptz NOT NULL DEFAULT now(),
    "face_detected" boolean NOT NULL DEFAULT true,
    CONSTRAINT "fk_proctoringsnapshots_submission_id" FOREIGN KEY ("submission_id") REFERENCES v_eval_practice."ExamSubmissions"("submission_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_practice."ProctoringSnapshots" IS 'Ảnh webcam chụp trong lúc thi để giám sát liêm chính.';

-- 36. Hồ sơ năng lực: xác suất thành thạo từng kỹ năng của từng học sinh (BKT).
CREATE TABLE IF NOT EXISTS v_eval_practice."LearningProfiles" (
    "profile_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "skill_id" uuid NOT NULL,  -- FK* logic -> v_eval_content."Skills"(skill_id)
    "mastery_score" double precision NOT NULL DEFAULT 0.1,
    "last_updated" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "uq_learningprofiles" UNIQUE ("student_id", "skill_id"),
    CHECK (mastery_score BETWEEN 0 AND 1)
);
COMMENT ON TABLE v_eval_practice."LearningProfiles" IS 'Hồ sơ năng lực: xác suất thành thạo từng kỹ năng của từng học sinh (BKT).';

-- 37. Lộ trình học cá nhân hóa, tạo sau khi thanh toán; chứa điểm mục tiêu, ngày thi, giờ học mỗi ngày; có cắt tỉa theo kỹ năng tiên quyết.
CREATE TABLE IF NOT EXISTS v_eval_practice."LearningRoadmaps" (
    "roadmap_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "registration_id" uuid NOT NULL UNIQUE,  -- FK* logic -> v_eval_enrollment."CourseRegistrations"(registration_id)
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "target_score" integer NOT NULL,
    "exam_date" date NOT NULL,
    "study_hours_day" numeric(3,1) NOT NULL,
    "start_date" date NOT NULL,
    "end_date" date NOT NULL,
    "total_milestones" integer NOT NULL DEFAULT 0,
    "completed_milestones" integer NOT NULL DEFAULT 0,
    "is_pruned" boolean NOT NULL DEFAULT false,
    "pruned_reason" text,
    "validation_status" varchar(20) NOT NULL DEFAULT 'PENDING',
    "status" varchar(30) NOT NULL DEFAULT 'CREATED',
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE v_eval_practice."LearningRoadmaps" IS 'Lộ trình học cá nhân hóa, tạo sau khi thanh toán; chứa điểm mục tiêu, ngày thi, giờ học mỗi ngày; có cắt tỉa theo kỹ năng tiên quyết.';

-- 38. Từng chặng của lộ trình, tích hợp học liệu (video), quiz và bài kiểm tra chốt chặng (daily_exam_id).
CREATE TABLE IF NOT EXISTS v_eval_practice."RoadmapNodes" (
    "node_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "roadmap_id" uuid NOT NULL,
    "skill_id" uuid NOT NULL,  -- FK* logic -> v_eval_content."Skills"(skill_id)
    "material_id" uuid,  -- FK* logic -> v_eval_content."Materials"(material_id)
    "quiz_exam_id" uuid,  -- FK* logic -> v_eval_content."MockExams"(exam_id)
    "daily_exam_id" uuid, -- FK* logic -> v_eval_content."MockExams"(exam_id) Đề kiểm tra chốt chặng của ngày
    "step_order" integer NOT NULL,
    "status" varchar(30) NOT NULL DEFAULT 'LOCKED',
    "is_pruned" boolean NOT NULL DEFAULT false,
    "unlocked_at" timestamptz,
    "completed_at" timestamptz,
    "video_watched_seconds" integer NOT NULL DEFAULT 0,
    "is_video_completed" boolean NOT NULL DEFAULT false,
    "quiz_score" double precision NOT NULL DEFAULT 0,
    "is_quiz_passed" boolean NOT NULL DEFAULT false,
    CONSTRAINT "fk_roadmapnodes_roadmap_id" FOREIGN KEY ("roadmap_id") REFERENCES v_eval_practice."LearningRoadmaps"("roadmap_id") ON DELETE CASCADE,
    CHECK (status IN ('LOCKED','UNLOCKED','COMPLETED'))
);
COMMENT ON TABLE v_eval_practice."RoadmapNodes" IS 'Từng chặng của lộ trình, tích hợp học liệu (video), quiz và bài kiểm tra chốt chặng (daily_exam_id).';

-- 39. Tiến trình chặng theo chu trình 4 bước Preview – Learn – Apply – Reflect (PLAR).
CREATE TABLE IF NOT EXISTS v_eval_practice."StageProgress" (
    "stage_progress_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "roadmap_node_id" uuid NOT NULL,
    "current_step" varchar(20) NOT NULL DEFAULT 'PREVIEW',
    "video_watch_percentage" numeric(5,2) NOT NULL DEFAULT 0,
    "bkt_mastery_plt" double precision NOT NULL DEFAULT 0.1,
    "consecutive_advanced_correct" integer NOT NULL DEFAULT 0,
    "consecutive_incorrect" integer NOT NULL DEFAULT 0,
    "status" varchar(30) NOT NULL DEFAULT 'IN_PROGRESS',
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_stageprogress_roadmap_node_id" FOREIGN KEY ("roadmap_node_id") REFERENCES v_eval_practice."RoadmapNodes"("node_id") ON DELETE CASCADE,
    CHECK (current_step IN ('PREVIEW','LEARN','APPLY','REFLECT')),
    CHECK (status IN ('IN_PROGRESS','COMPLETED','REMEDIAL_NEEDED'))
);
COMMENT ON TABLE v_eval_practice."StageProgress" IS 'Tiến trình chặng theo chu trình 4 bước Preview – Learn – Apply – Reflect (PLAR).';

-- 40. Nhật ký từng câu trả lời thích ứng (BKT và IRT: độ khó b, độ phân biệt a, đoán mò, xác suất thành thạo trước và sau).
CREATE TABLE IF NOT EXISTS v_eval_practice."AdaptiveQuizAttempts" (
    "attempt_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "stage_progress_id" uuid NOT NULL,
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "question_id" uuid NOT NULL,  -- FK* logic -> v_eval_content."Questions"(question_id)
    "selected_option" varchar(10),
    "is_correct" boolean NOT NULL,
    "time_spent_seconds" integer NOT NULL DEFAULT 0,
    "item_difficulty_b" double precision NOT NULL,
    "item_discrimination_a" double precision NOT NULL,
    "is_lucky_guess" boolean NOT NULL DEFAULT false,
    "prior_plt" double precision NOT NULL,
    "posterior_plt" double precision NOT NULL,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_adaptivequizattempts_stage_progress_id" FOREIGN KEY ("stage_progress_id") REFERENCES v_eval_practice."StageProgress"("stage_progress_id") ON DELETE CASCADE
);
COMMENT ON TABLE v_eval_practice."AdaptiveQuizAttempts" IS 'Nhật ký từng câu trả lời thích ứng (BKT và IRT: độ khó b, độ phân biệt a, đoán mò, xác suất thành thạo trước và sau).';

-- 41. Sổ tay lỗi sai và lặp lại ngắt quãng SuperMemo-2.
CREATE TABLE IF NOT EXISTS v_eval_practice."MistakeNotebooks" (
    "mistake_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "question_id" uuid NOT NULL,  -- FK* logic -> v_eval_content."Questions"(question_id)
    "skill_id" uuid NOT NULL,  -- FK* logic -> v_eval_content."Skills"(skill_id)
    "cognitive_error_tag" varchar(30),
    "student_notes" text,
    "next_review_date" date NOT NULL,
    "review_count" integer NOT NULL DEFAULT 0,
    "interval_days" integer NOT NULL DEFAULT 1,
    "ease_factor" double precision NOT NULL DEFAULT 2.5,
    "status" varchar(30) NOT NULL DEFAULT 'NEW_MISTAKE',
    "last_reviewed_at" timestamptz,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "uq_mistakenotebooks" UNIQUE ("student_id", "question_id"),
    CHECK (cognitive_error_tag IN ('CARELESS','MISREAD_QUESTION','MISSING_CONCEPT','TIME_PRESSURE')),
    CHECK (status IN ('NEW_MISTAKE','DUE_FOR_REVIEW','REVIEWING','RETAINED','RELAPSED','MASTERED')),
    CHECK (ease_factor >= 1.3)
);
COMMENT ON TABLE v_eval_practice."MistakeNotebooks" IS 'Sổ tay lỗi sai và lặp lại ngắt quãng SuperMemo-2.';

-- 42. Nhật ký chuyên cần hằng ngày và chuỗi ngày học liên tiếp (Streak & Diligence Tracker).
CREATE TABLE IF NOT EXISTS v_eval_practice."StudentDailyActivities" (
    "activity_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "activity_date" date NOT NULL,
    "study_time_minutes" integer NOT NULL DEFAULT 0,
    "practice_questions_solved" integer NOT NULL DEFAULT 0,
    "video_minutes_watched" integer NOT NULL DEFAULT 0,
    "mock_exams_taken" integer NOT NULL DEFAULT 0,
    "is_streak_counted" boolean NOT NULL DEFAULT false,
    "is_frozen" boolean NOT NULL DEFAULT false,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    "updated_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "uq_studentdailyactivities" UNIQUE ("student_id", "activity_date")
);
COMMENT ON TABLE v_eval_practice."StudentDailyActivities" IS 'Nhật ký chuyên cần hằng ngày và chuỗi ngày học liên tiếp (Streak & Diligence Tracker).';

-- 43. Đánh giá mức sẵn sàng thi của học sinh so với chuẩn đầu ra, có khoảng điểm dự báo; đánh giá nhiều lần theo thời gian.
CREATE TABLE IF NOT EXISTS v_eval_practice."ReadinessAssessments" (
    "assessment_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "registration_id" uuid NOT NULL,  -- FK* logic -> v_eval_enrollment."CourseRegistrations"(registration_id)
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "standard_id" uuid NOT NULL,  -- FK* logic -> v_eval_enrollment."ReadinessStandards"(standard_id)
    "predicted_score" integer,
    "predicted_score_min" integer,
    "predicted_score_max" integer,
    "skill_coverage" numeric(5,2) NOT NULL,
    "consistency_score" numeric(5,2),
    "is_standard_met" boolean NOT NULL DEFAULT false,
    "assessed_at" timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE v_eval_practice."ReadinessAssessments" IS 'Đánh giá mức sẵn sàng thi của học sinh so với chuẩn đầu ra, có khoảng điểm dự báo; đánh giá nhiều lần theo thời gian.';

-- 44. Cảnh báo sớm nhiều cấp cho học sinh hoặc kỹ năng.
CREATE TABLE IF NOT EXISTS v_eval_practice."SystemAlerts" (
    "alert_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "skill_id" uuid,  -- FK* logic -> v_eval_content."Skills"(skill_id)
    "alert_type" varchar(30) NOT NULL,
    "severity" varchar(20) NOT NULL,
    "message" text NOT NULL,
    "is_read" boolean NOT NULL DEFAULT false,
    "handled_by" uuid,
    "resolution_notes" text,
    "resolved_at" timestamptz,
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CHECK (alert_type IN ('GREEN','YELLOW','RED','UNREALISTIC_GOAL'))
);
COMMENT ON TABLE v_eval_practice."SystemAlerts" IS 'Cảnh báo sớm nhiều cấp cho học sinh hoặc kỹ năng.';

-- =====================================================================
-- PHÂN HỆ 5: SCHEMA v_eval_outcome (7 bảng)
-- Nguyện vọng, điểm thi thật, kết quả tuyển sinh và tổng hợp theo khóa
-- =====================================================================

-- 45. Danh mục trường đại học.
CREATE TABLE IF NOT EXISTS v_eval_outcome."Universities" (
    "university_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "code" varchar(30) NOT NULL UNIQUE,
    "name" varchar(255) NOT NULL
);
COMMENT ON TABLE v_eval_outcome."Universities" IS 'Danh mục trường đại học.';

-- 46. Ngành / chương trình tuyển sinh của một trường, kèm phương thức xét.
CREATE TABLE IF NOT EXISTS v_eval_outcome."AdmissionPrograms" (
    "program_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "university_id" uuid NOT NULL,
    "code" varchar(50) NOT NULL UNIQUE,
    "name" varchar(255) NOT NULL,
    "admission_method" varchar(50) NOT NULL DEFAULT 'DGNL',
    CONSTRAINT "fk_admissionprograms_university_id" FOREIGN KEY ("university_id") REFERENCES v_eval_outcome."Universities"("university_id") ON DELETE RESTRICT
);
COMMENT ON TABLE v_eval_outcome."AdmissionPrograms" IS 'Ngành / chương trình tuyển sinh của một trường, kèm phương thức xét.';

-- 47. Điểm chuẩn từng năm của một ngành.
CREATE TABLE IF NOT EXISTS v_eval_outcome."AdmissionBenchmarks" (
    "benchmark_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "program_id" uuid NOT NULL,
    "admission_year" integer NOT NULL,
    "benchmark_score" integer NOT NULL,
    CONSTRAINT "fk_admissionbenchmarks_program_id" FOREIGN KEY ("program_id") REFERENCES v_eval_outcome."AdmissionPrograms"("program_id") ON DELETE RESTRICT
);
COMMENT ON TABLE v_eval_outcome."AdmissionBenchmarks" IS 'Điểm chuẩn từng năm của một ngành.';

-- 48. Nguyện vọng của học sinh: ngành, thứ tự ưu tiên, điểm mục tiêu.
CREATE TABLE IF NOT EXISTS v_eval_outcome."StudentAspirations" (
    "aspiration_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "program_id" uuid NOT NULL,
    "priority" smallint NOT NULL,
    "target_score" integer NOT NULL,
    "status" varchar(20) NOT NULL DEFAULT 'REGISTERED',
    "created_at" timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT "fk_studentaspirations_program_id" FOREIGN KEY ("program_id") REFERENCES v_eval_outcome."AdmissionPrograms"("program_id") ON DELETE RESTRICT
);
COMMENT ON TABLE v_eval_outcome."StudentAspirations" IS 'Nguyện vọng của học sinh: ngành, thứ tự ưu tiên, điểm mục tiêu.';

-- 49. Điểm thi ĐGNL thật của học sinh.
CREATE TABLE IF NOT EXISTS v_eval_outcome."RealExamResults" (
    "exam_result_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,  -- FK* logic -> v_eval_identity."Students"(student_id)
    "exam_year" integer NOT NULL,
    "exam_date" date NOT NULL,
    "official_score" integer NOT NULL,
    "recorded_at" timestamptz NOT NULL DEFAULT now(),
    "recorded_by" uuid
);
COMMENT ON TABLE v_eval_outcome."RealExamResults" IS 'Điểm thi ĐGNL thật của học sinh.';

-- 50. Kết quả thật của một nguyện vọng (trúng tuyển, đạt nguyện vọng, điểm thực tế), nối về đăng ký khóa học.
CREATE TABLE IF NOT EXISTS v_eval_outcome."AdmissionResults" (
    "admission_result_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "aspiration_id" uuid NOT NULL,
    "exam_result_id" uuid NOT NULL,
    "registration_id" uuid,  -- FK* logic -> v_eval_enrollment."CourseRegistrations"(registration_id)
    "admission_year" integer NOT NULL,
    "is_admitted" boolean NOT NULL,
    "is_aspiration_met" boolean NOT NULL,
    "actual_score" integer,
    "recorded_at" timestamptz NOT NULL DEFAULT now(),
    "recorded_by" uuid,
    CONSTRAINT "fk_admissionresults_aspiration_id" FOREIGN KEY ("aspiration_id") REFERENCES v_eval_outcome."StudentAspirations"("aspiration_id") ON DELETE RESTRICT,
    CONSTRAINT "fk_admissionresults_exam_result_id" FOREIGN KEY ("exam_result_id") REFERENCES v_eval_outcome."RealExamResults"("exam_result_id") ON DELETE RESTRICT
);
COMMENT ON TABLE v_eval_outcome."AdmissionResults" IS 'Kết quả thật của một nguyện vọng (trúng tuyển, đạt nguyện vọng, điểm thực tế), nối về đăng ký khóa học.';

-- 51. Bảng tổng hợp theo khóa, ngành, năm: số đăng ký, số trúng tuyển, tỉ lệ thành công, điểm tăng trung bình.
CREATE TABLE IF NOT EXISTS v_eval_outcome."CohortOutcomeSummaries" (
    "summary_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "course_id" uuid NOT NULL,  -- FK* logic -> v_eval_enrollment."Courses"(course_id)
    "program_id" uuid NOT NULL,
    "cohort_year" integer NOT NULL,
    "total_aspirants" integer NOT NULL,
    "total_admitted" integer NOT NULL,
    "success_rate" numeric(5,2) NOT NULL,
    "avg_score_gain" numeric(6,2),
    "calculated_at" timestamptz NOT NULL,
    CONSTRAINT "fk_cohortoutcomesummaries_program_id" FOREIGN KEY ("program_id") REFERENCES v_eval_outcome."AdmissionPrograms"("program_id") ON DELETE RESTRICT
);
COMMENT ON TABLE v_eval_outcome."CohortOutcomeSummaries" IS 'Bảng tổng hợp theo khóa, ngành, năm: số đăng ký, số trúng tuyển, tỉ lệ thành công, điểm tăng trung bình.';

-- =====================================================================
-- HỆ THỐNG CHỈ MỤC TỐI ƯU TRUY VẤN (INDEXES)
-- Phủ kín các cột khóa ngoại, trường tìm kiếm và sắp xếp thường dùng
-- =====================================================================

-- Chỉ mục cho v_eval_identity
CREATE INDEX IF NOT EXISTS "idx_userroles_role_id" ON v_eval_identity."UserRoles"("role_id");
CREATE INDEX IF NOT EXISTS "idx_students_campus_id" ON v_eval_identity."Students"("campus_id");
CREATE INDEX IF NOT EXISTS "idx_parentstudentrelations_student_id" ON v_eval_identity."ParentStudentRelations"("student_id");
CREATE INDEX IF NOT EXISTS "idx_teachers_campus_id" ON v_eval_identity."Teachers"("campus_id");
CREATE INDEX IF NOT EXISTS "idx_teachersubjects_domain_id" ON v_eval_identity."TeacherSubjects"("domain_id");
CREATE INDEX IF NOT EXISTS "idx_academicmanagers_campus_id" ON v_eval_identity."AcademicManagers"("campus_id");

-- Chỉ mục cho v_eval_content
CREATE INDEX IF NOT EXISTS "idx_skills_domain_id" ON v_eval_content."Skills"("domain_id");
CREATE INDEX IF NOT EXISTS "idx_skills_parent_id" ON v_eval_content."Skills"("parent_id");
CREATE INDEX IF NOT EXISTS "idx_skillprerequisites_prerequisite_id" ON v_eval_content."SkillPrerequisites"("prerequisite_id");
CREATE INDEX IF NOT EXISTS "idx_materials_skill_id" ON v_eval_content."Materials"("skill_id");
CREATE INDEX IF NOT EXISTS "idx_questions_skill_id" ON v_eval_content."Questions"("skill_id");
CREATE INDEX IF NOT EXISTS "idx_questions_passage_id" ON v_eval_content."Questions"("passage_id");
CREATE INDEX IF NOT EXISTS "idx_examquestions_question_id" ON v_eval_content."ExamQuestions"("question_id");

-- Chỉ mục cho v_eval_enrollment
CREATE INDEX IF NOT EXISTS "idx_courses_campus_id" ON v_eval_enrollment."Courses"("campus_id");
CREATE INDEX IF NOT EXISTS "idx_readinessstandards_course_id" ON v_eval_enrollment."ReadinessStandards"("course_id");
CREATE INDEX IF NOT EXISTS "idx_courseregistrations_course_id" ON v_eval_enrollment."CourseRegistrations"("course_id");
CREATE INDEX IF NOT EXISTS "idx_courseregistrations_previous_registration_id" ON v_eval_enrollment."CourseRegistrations"("previous_registration_id");
CREATE INDEX IF NOT EXISTS "idx_payments_registration_id" ON v_eval_enrollment."Payments"("registration_id");
CREATE INDEX IF NOT EXISTS "idx_payments_parent_id" ON v_eval_enrollment."Payments"("parent_id");
CREATE INDEX IF NOT EXISTS "idx_payments_order_code" ON v_eval_enrollment."Payments"("order_code");
CREATE INDEX IF NOT EXISTS "idx_paymenttransactions_payment_id" ON v_eval_enrollment."PaymentTransactions"("payment_id");

-- Chỉ mục cho v_eval_practice
CREATE INDEX IF NOT EXISTS "idx_classes_campus_id" ON v_eval_practice."Classes"("campus_id");
CREATE INDEX IF NOT EXISTS "idx_classes_course_id" ON v_eval_practice."Classes"("course_id");
CREATE INDEX IF NOT EXISTS "idx_classes_teacher_id" ON v_eval_practice."Classes"("teacher_id");
CREATE INDEX IF NOT EXISTS "idx_classsessions_skill_id" ON v_eval_practice."ClassSessions"("skill_id");
CREATE INDEX IF NOT EXISTS "idx_classskills_skill_id" ON v_eval_practice."ClassSkills"("skill_id");
CREATE INDEX IF NOT EXISTS "idx_examsubmissions_student_id" ON v_eval_practice."ExamSubmissions"("student_id");
CREATE INDEX IF NOT EXISTS "idx_examsubmissions_exam_id" ON v_eval_practice."ExamSubmissions"("exam_id");
CREATE INDEX IF NOT EXISTS "idx_classenrollments_student_id" ON v_eval_practice."ClassEnrollments"("student_id");
CREATE INDEX IF NOT EXISTS "idx_classenrollments_registration_id" ON v_eval_practice."ClassEnrollments"("registration_id");
CREATE INDEX IF NOT EXISTS "idx_classenrollments_diagnostic_submission_id" ON v_eval_practice."ClassEnrollments"("diagnostic_submission_id");
CREATE INDEX IF NOT EXISTS "idx_classgroups_class_id" ON v_eval_practice."ClassGroups"("class_id");
CREATE INDEX IF NOT EXISTS "idx_classgroupskills_skill_id" ON v_eval_practice."ClassGroupSkills"("skill_id");
CREATE INDEX IF NOT EXISTS "idx_classgroupmembers_student_id" ON v_eval_practice."ClassGroupMembers"("student_id");
CREATE INDEX IF NOT EXISTS "idx_submissionanswers_submission_id" ON v_eval_practice."SubmissionAnswers"("submission_id");
CREATE INDEX IF NOT EXISTS "idx_submissionanswers_question_id" ON v_eval_practice."SubmissionAnswers"("question_id");
CREATE INDEX IF NOT EXISTS "idx_proctoringsnapshots_submission_id" ON v_eval_practice."ProctoringSnapshots"("submission_id");
CREATE INDEX IF NOT EXISTS "idx_learningprofiles_skill_id" ON v_eval_practice."LearningProfiles"("skill_id");
CREATE INDEX IF NOT EXISTS "idx_learningroadmaps_student_id" ON v_eval_practice."LearningRoadmaps"("student_id");
CREATE INDEX IF NOT EXISTS "idx_roadmapnodes_roadmap_id" ON v_eval_practice."RoadmapNodes"("roadmap_id");
CREATE INDEX IF NOT EXISTS "idx_roadmapnodes_skill_id" ON v_eval_practice."RoadmapNodes"("skill_id");
CREATE INDEX IF NOT EXISTS "idx_roadmapnodes_material_id" ON v_eval_practice."RoadmapNodes"("material_id");
CREATE INDEX IF NOT EXISTS "idx_roadmapnodes_quiz_exam_id" ON v_eval_practice."RoadmapNodes"("quiz_exam_id");
CREATE INDEX IF NOT EXISTS "idx_roadmapnodes_daily_exam_id" ON v_eval_practice."RoadmapNodes"("daily_exam_id");
CREATE INDEX IF NOT EXISTS "idx_stageprogress_student_id" ON v_eval_practice."StageProgress"("student_id");
CREATE INDEX IF NOT EXISTS "idx_stageprogress_roadmap_node_id" ON v_eval_practice."StageProgress"("roadmap_node_id");
CREATE INDEX IF NOT EXISTS "idx_adaptivequizattempts_stage_progress_id" ON v_eval_practice."AdaptiveQuizAttempts"("stage_progress_id");
CREATE INDEX IF NOT EXISTS "idx_adaptivequizattempts_student_id" ON v_eval_practice."AdaptiveQuizAttempts"("student_id");
CREATE INDEX IF NOT EXISTS "idx_adaptivequizattempts_question_id" ON v_eval_practice."AdaptiveQuizAttempts"("question_id");
CREATE INDEX IF NOT EXISTS "idx_mistakenotebooks_question_id" ON v_eval_practice."MistakeNotebooks"("question_id");
CREATE INDEX IF NOT EXISTS "idx_mistakenotebooks_skill_id" ON v_eval_practice."MistakeNotebooks"("skill_id");
CREATE INDEX IF NOT EXISTS "idx_mistakenotebooks_student_id_next_review_date" ON v_eval_practice."MistakeNotebooks"("student_id", "next_review_date");
CREATE INDEX IF NOT EXISTS "idx_readinessassessments_registration_id" ON v_eval_practice."ReadinessAssessments"("registration_id");
CREATE INDEX IF NOT EXISTS "idx_readinessassessments_student_id" ON v_eval_practice."ReadinessAssessments"("student_id");
CREATE INDEX IF NOT EXISTS "idx_readinessassessments_standard_id" ON v_eval_practice."ReadinessAssessments"("standard_id");
CREATE INDEX IF NOT EXISTS "idx_systemalerts_student_id" ON v_eval_practice."SystemAlerts"("student_id");
CREATE INDEX IF NOT EXISTS "idx_systemalerts_skill_id" ON v_eval_practice."SystemAlerts"("skill_id");

-- Chỉ mục cho v_eval_outcome
CREATE INDEX IF NOT EXISTS "idx_admissionprograms_university_id" ON v_eval_outcome."AdmissionPrograms"("university_id");
CREATE INDEX IF NOT EXISTS "idx_admissionbenchmarks_program_id" ON v_eval_outcome."AdmissionBenchmarks"("program_id");
CREATE INDEX IF NOT EXISTS "idx_studentaspirations_student_id" ON v_eval_outcome."StudentAspirations"("student_id");
CREATE INDEX IF NOT EXISTS "idx_studentaspirations_program_id" ON v_eval_outcome."StudentAspirations"("program_id");
CREATE INDEX IF NOT EXISTS "idx_realexamresults_student_id" ON v_eval_outcome."RealExamResults"("student_id");
CREATE INDEX IF NOT EXISTS "idx_admissionresults_aspiration_id" ON v_eval_outcome."AdmissionResults"("aspiration_id");
CREATE INDEX IF NOT EXISTS "idx_admissionresults_exam_result_id" ON v_eval_outcome."AdmissionResults"("exam_result_id");
CREATE INDEX IF NOT EXISTS "idx_admissionresults_registration_id" ON v_eval_outcome."AdmissionResults"("registration_id");
CREATE INDEX IF NOT EXISTS "idx_cohortoutcomesummaries_course_id" ON v_eval_outcome."CohortOutcomeSummaries"("course_id");
CREATE INDEX IF NOT EXISTS "idx_cohortoutcomesummaries_program_id" ON v_eval_outcome."CohortOutcomeSummaries"("program_id");

