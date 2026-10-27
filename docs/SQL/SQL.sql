-- =====================================================================
-- V-EVAL ADAPTIVE LEARNING PLATFORM — UNIFIED MASTER DATABASE SCHEMA
-- =====================================================================
-- Phiên bản: Schema V4.1 (Đồng bộ 100% Microservices, Mô hình Offline Cohort 20 học sinh & Nhóm vi mô thích ứng)
-- Ngày ban hành: 24/10/2026
-- Tổng số thực thể: 49 bảng (Identity: 13, Content: 8, Practice: 19, AI: 9)
-- Phân vùng 4 Bounded Context Schemas:
--   1. v_eval_identity : Quản trị định danh, RBAC, 6 Actor Profiles, Cơ sở & Bảo mật OTP/Token (13 bảng)
--   2. v_eval_content  : Khung năng lực 3 cấp, DAG tiên quyết, Đề thi chuẩn hóa & Ngân hàng câu hỏi (8 bảng)
--   3. v_eval_practice : Lộ trình thích ứng P-L-A-R, Lớp học offline, Nhóm vi mô 3-5 HS, BKT/SM-2, Proctoring, Dự báo SEM & Heatmap Analytics (19 bảng)
--   4. v_eval_ai       : Nguồn tri thức RAG, Vector Chunks 768d, Archetype Knowledge Graph, Theoretical Documents & Socratic Tutor Sessions (9 bảng)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. KHỞI TẠO EXTENSIONS & SCHEMAS HỆ THỐNG
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "vector";

CREATE SCHEMA IF NOT EXISTS v_eval_identity;
CREATE SCHEMA IF NOT EXISTS v_eval_content;
CREATE SCHEMA IF NOT EXISTS v_eval_practice;
CREATE SCHEMA IF NOT EXISTS v_eval_ai;

-- =====================================================================
-- PHÂN VÙNG 1: V_EVAL_IDENTITY (ĐỊNH DANH, BẢO MẬT & HỒ SƠ ACTORS)
-- =====================================================================

-- 1.1 Cơ sở Đào tạo Offline (Campuses)
CREATE TABLE IF NOT EXISTS v_eval_identity."Campuses" (
    "campus_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "code" varchar(50) UNIQUE,
    "name" varchar(255) NOT NULL,
    "address" varchar(500) NOT NULL,
    "phone" varchar(50) NOT NULL,
    "is_active" boolean NOT NULL DEFAULT true,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 1.2 Vai trò Phân quyền RBAC (Roles)
CREATE TABLE IF NOT EXISTS v_eval_identity."Roles" (
    "role_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "role_name" varchar(50) UNIQUE NOT NULL
);

-- 1.3 Tài khoản Người dùng Tập trung (Users)
CREATE TABLE IF NOT EXISTS v_eval_identity."Users" (
    "user_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "email" varchar(255) UNIQUE NOT NULL,
    "password_hash" text NOT NULL,
    "full_name" varchar(255) NOT NULL,
    "phone" varchar(50) NOT NULL,
    "avatar_url" text,
    "is_active" boolean NOT NULL DEFAULT false,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 1.4 Phân quyền Người dùng - Vai trò (UserRoles)
CREATE TABLE IF NOT EXISTS v_eval_identity."UserRoles" (
    "user_id" uuid NOT NULL REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    "role_id" uuid NOT NULL REFERENCES v_eval_identity."Roles"("role_id") ON DELETE RESTRICT,
    PRIMARY KEY ("user_id", "role_id")
);

-- 1.5 Phiên Đăng nhập Kéo dài (RefreshTokens)
CREATE TABLE IF NOT EXISTS v_eval_identity."RefreshTokens" (
    "refresh_token_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "user_id" uuid NOT NULL REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    "token" varchar(500) NOT NULL,
    "expires_at" timestamp with time zone NOT NULL,
    "is_revoked" boolean NOT NULL DEFAULT false,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 1.6 Mã Xác thực Một lần OTP (OtpVerifications)
CREATE TABLE IF NOT EXISTS v_eval_identity."OtpVerifications" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "email" varchar(255) NOT NULL,
    "otp_code" varchar(10) NOT NULL,
    "type" varchar(50) NOT NULL, -- 'REGISTER_VERIFY', 'RESET_PASSWORD'
    "expires_at" timestamp with time zone NOT NULL,
    "is_used" boolean NOT NULL DEFAULT false,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 1.7 Hồ sơ Học sinh (Students - 1:1 Users)
CREATE TABLE IF NOT EXISTS v_eval_identity."Students" (
    "student_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    "campus_id" uuid NOT NULL REFERENCES v_eval_identity."Campuses"("campus_id") ON DELETE RESTRICT,
    "target_score" integer DEFAULT 800,
    "exam_date" date,
    "study_hours_day" double precision DEFAULT 2.0,
    "school_name" varchar(255),
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 1.8 Hồ sơ Phụ huynh (Parents - 1:1 Users)
CREATE TABLE IF NOT EXISTS v_eval_identity."Parents" (
    "parent_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    "phone_work" varchar(50),
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 1.9 Quan hệ Giám hộ Phụ huynh - Học sinh (ParentStudentRelations)
CREATE TABLE IF NOT EXISTS v_eval_identity."ParentStudentRelations" (
    "relation_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "parent_id" uuid NOT NULL REFERENCES v_eval_identity."Parents"("parent_id") ON DELETE CASCADE,
    "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
    "created_at" timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT "uq_parent_student" UNIQUE ("parent_id", "student_id")
);

-- 1.10 Hồ sơ Giáo viên / Lead Mentor (Teachers - 1:1 Users)
CREATE TABLE IF NOT EXISTS v_eval_identity."Teachers" (
    "teacher_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    "campus_id" uuid NOT NULL REFERENCES v_eval_identity."Campuses"("campus_id") ON DELETE RESTRICT,
    "specialty" varchar(255),
    "bio" text,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 1.11 Hồ sơ Quản lý Học vụ Cơ sở (AcademicManagers - 1:1 Users)
CREATE TABLE IF NOT EXISTS v_eval_identity."AcademicManagers" (
    "manager_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    "campus_id" uuid NOT NULL REFERENCES v_eval_identity."Campuses"("campus_id") ON DELETE RESTRICT,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 1.12 Hồ sơ Giám đốc Đào tạo (AcademicDirectors - 1:1 Users)
CREATE TABLE IF NOT EXISTS v_eval_identity."AcademicDirectors" (
    "director_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 1.13 Hồ sơ Quản trị viên Kỹ thuật (Administrators - 1:1 Users)
CREATE TABLE IF NOT EXISTS v_eval_identity."Administrators" (
    "admin_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- =====================================================================
-- PHÂN VÙNG 2: V_EVAL_CONTENT (KHUNG NĂNG LỰC, DAG TIÊN QUYẾT & ĐỀ THI)
-- =====================================================================

-- 2.1 Miền Năng lực ĐGNL Chuẩn (CompetencyDomains)
CREATE TABLE IF NOT EXISTS v_eval_content."CompetencyDomains" (
    "domain_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "name" text NOT NULL,
    "description" text
);

-- 2.2 Cây Kỹ năng Vi mô (Skills)
CREATE TABLE IF NOT EXISTS v_eval_content."Skills" (
    "skill_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "domain_id" uuid NOT NULL REFERENCES v_eval_content."CompetencyDomains"("domain_id") ON DELETE RESTRICT,
    "name" text NOT NULL,
    "parent_id" uuid REFERENCES v_eval_content."Skills"("skill_id") ON DELETE RESTRICT,
    "weight" double precision DEFAULT 1.0,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 2.3 Đồ thị Có hướng Không chu trình (DAG) Kỹ năng Tiên quyết (SkillPrerequisites)
CREATE TABLE IF NOT EXISTS v_eval_content."SkillPrerequisites" (
    "skill_id" uuid NOT NULL REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
    "prerequisite_id" uuid NOT NULL REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
    PRIMARY KEY ("skill_id", "prerequisite_id")
);

-- 2.4 Học liệu Sư phạm Chuẩn (Materials)
CREATE TABLE IF NOT EXISTS v_eval_content."Materials" (
    "material_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "skill_id" uuid NOT NULL REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
    "title" text NOT NULL,
    "content" text NOT NULL,
    "video_url" text,
    "file_url" text,
    "duration_seconds" integer DEFAULT 0,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 2.5 Ngữ liệu Đọc hiểu / Dữ liệu Khoa học Chung (Passages)
CREATE TABLE IF NOT EXISTS v_eval_content."Passages" (
    "passage_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "title" text,
    "content" text NOT NULL,
    "image_url" text
);

-- 2.6 Ngân hàng Câu hỏi Trắc nghiệm Chuẩn hóa (Questions)
CREATE TABLE IF NOT EXISTS v_eval_content."Questions" (
    "question_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "skill_id" uuid NOT NULL REFERENCES v_eval_content."Skills"("skill_id") ON DELETE RESTRICT,
    "passage_id" uuid REFERENCES v_eval_content."Passages"("passage_id") ON DELETE SET NULL,
    "difficulty_level" integer NOT NULL, -- 1: Nhận biết, 2: Thông hiểu, 3: Vận dụng, 4: Vận dụng cao
    "content_latex" text NOT NULL,
    "option_a" text NOT NULL,
    "option_b" text NOT NULL,
    "option_c" text NOT NULL,
    "option_d" text NOT NULL,
    "correct_option" character(1) NOT NULL, -- 'A', 'B', 'C', 'D'
    "explanation" text,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 2.7 Bộ Đề thi Chuẩn hóa & Đề Khảo sát Chẩn đoán (MockExams)
CREATE TABLE IF NOT EXISTS v_eval_content."MockExams" (
    "exam_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "title" text NOT NULL,
    "duration_minutes" integer NOT NULL DEFAULT 150,
    "total_questions" integer NOT NULL DEFAULT 120,
    "is_published" boolean NOT NULL DEFAULT false,
    "exam_category" text NOT NULL DEFAULT 'FULL_MOCK', -- 'DIAGNOSTIC', 'FULL_MOCK', 'MINI_TEST'
    "subject_code" text,
    "difficulty_level" integer,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 2.8 Ma trận Câu hỏi trong Đề thi (ExamQuestions)
CREATE TABLE IF NOT EXISTS v_eval_content."ExamQuestions" (
    "exam_id" uuid NOT NULL REFERENCES v_eval_content."MockExams"("exam_id") ON DELETE CASCADE,
    "question_id" uuid NOT NULL REFERENCES v_eval_content."Questions"("question_id") ON DELETE RESTRICT,
    "question_order" integer NOT NULL,
    PRIMARY KEY ("exam_id", "question_id")
);

-- =====================================================================
-- PHÂN VÙNG 3: V_EVAL_PRACTICE (LỚP HỌC, LỘ TRÌNH, ADAPTIVE & ANALYTICS)
-- =====================================================================

-- 3.1 Lớp Học Trực tiếp & Phân tầng K-Means Cohort (Classes)
CREATE TABLE IF NOT EXISTS v_eval_practice."Classes" (
    "class_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "campus_id" uuid NOT NULL,
    "teacher_id" uuid,
    "assigned_by" uuid,
    "name" text NOT NULL,
    "status" varchar(50) NOT NULL DEFAULT 'ACTIVE',
    "assigned_at" timestamp with time zone,
    "created_at" timestamp with time zone NOT NULL DEFAULT now(),
    "class_type" integer NOT NULL DEFAULT 0, -- 0: Tiêu chuẩn, 1: Phân cụm Thematic Cohort
    "cluster_index" integer,
    "domain_code" varchar(50),
    "domain_id" uuid
);

-- 3.2 Phiên Làm Bài Thi & Giám sát Liêm chính Proctoring (ExamSubmissions)
CREATE TABLE IF NOT EXISTS v_eval_practice."ExamSubmissions" (
    "submission_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,
    "exam_id" uuid NOT NULL,
    "exam_type" varchar(50) NOT NULL, -- 'DIAGNOSTIC', 'FULL_MOCK'
    "total_score" integer NOT NULL DEFAULT 0,
    "total_correct" integer NOT NULL DEFAULT 0,
    "total_questions" integer NOT NULL DEFAULT 0,
    "total_time_spent_seconds" integer NOT NULL DEFAULT 0,
    "started_at" timestamp with time zone NOT NULL DEFAULT now(),
    "completed_at" timestamp with time zone NOT NULL DEFAULT now(),
    "status" varchar(50) NOT NULL DEFAULT 'SUBMITTED',
    "theta_0" double precision,
    "placement_class" varchar(50),
    "ai_commentary" text,
    "enrolled_class_id" uuid REFERENCES v_eval_practice."Classes"("class_id") ON DELETE SET NULL,
    "tab_departure_count" integer DEFAULT 0,
    "integrity_status" varchar(50) DEFAULT 'NORMAL', -- 'NORMAL', 'FLAGGED', 'CLEAN'
    "mentor_verdict" varchar(50) DEFAULT 'PENDING',  -- 'PENDING', 'APPROVED', 'DISQUALIFIED'
    "mentor_notes" text
);

-- 3.3 Chi tiết Câu Trả lời Bài thi (SubmissionAnswers)
CREATE TABLE IF NOT EXISTS v_eval_practice."SubmissionAnswers" (
    "answer_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "submission_id" uuid NOT NULL REFERENCES v_eval_practice."ExamSubmissions"("submission_id") ON DELETE CASCADE,
    "question_id" uuid NOT NULL,
    "selected_option" varchar(10),
    "is_correct" boolean NOT NULL,
    "time_spent_seconds" integer NOT NULL DEFAULT 0
);

-- 3.4 Ảnh chụp Webcam Giám sát Thi thử (ProctoringSnapshots)
CREATE TABLE IF NOT EXISTS v_eval_practice."ProctoringSnapshots" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "submission_id" uuid NOT NULL REFERENCES v_eval_practice."ExamSubmissions"("submission_id") ON DELETE CASCADE,
    "snapshot_url" text NOT NULL,
    "captured_at" timestamp with time zone DEFAULT now(),
    "face_detected" boolean DEFAULT true
);

-- 3.5 Danh sách Ghi danh Lớp học (ClassEnrollments)
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassEnrollments" (
    "enrollment_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "class_id" uuid NOT NULL REFERENCES v_eval_practice."Classes"("class_id") ON DELETE RESTRICT,
    "student_id" uuid NOT NULL,
    "diagnostic_submission_id" uuid REFERENCES v_eval_practice."ExamSubmissions"("submission_id") ON DELETE SET NULL,
    "approved_by" uuid,
    "status" varchar(50) NOT NULL DEFAULT 'ENROLLED',
    "enrolled_at" timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT "uq_class_student_enrollment" UNIQUE ("class_id", "student_id")
);

-- 3.6 Nhóm Học tập Vi mô 3–5 Bạn Cùng Lỗ Hổng Kiến thức (ClassGroups)
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassGroups" (
    "group_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "class_id" uuid NOT NULL REFERENCES v_eval_practice."Classes"("class_id") ON DELETE CASCADE,
    "group_name" varchar(255) NOT NULL,
    "focus_area" varchar(255),
    "common_weak_skill_ids" text,
    "recommended_worksheet_title" varchar(255),
    "assigned_worksheet_id" varchar(100),
    "assigned_worksheet_title" varchar(255),
    "worksheet_assigned_at" timestamp with time zone,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 3.7 Thành viên Nhóm Vi mô (ClassGroupMembers)
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassGroupMembers" (
    "group_member_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "group_id" uuid NOT NULL REFERENCES v_eval_practice."ClassGroups"("group_id") ON DELETE CASCADE,
    "student_id" uuid NOT NULL,
    "joined_at" timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT "uq_group_student_member" UNIQUE ("group_id", "student_id")
);

-- 3.8 Hồ sơ Năng lực BKT P(L0) & Xác suất Thành thạo (LearningProfiles)
CREATE TABLE IF NOT EXISTS v_eval_practice."LearningProfiles" (
    "profile_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,
    "skill_id" uuid NOT NULL,
    "mastery_score" double precision NOT NULL DEFAULT 0.1000,
    "last_updated" timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT "uq_student_skill_profile" UNIQUE ("student_id", "skill_id")
);

-- 3.9 Lộ trình Học tập Cá nhân hóa Tự động Cắt tỉa (LearningRoadmaps)
CREATE TABLE IF NOT EXISTS v_eval_practice."LearningRoadmaps" (
    "roadmap_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,
    "diagnostic_submission_id" uuid REFERENCES v_eval_practice."ExamSubmissions"("submission_id") ON DELETE SET NULL,
    "target_score" integer NOT NULL DEFAULT 800,
    "total_milestones" integer NOT NULL DEFAULT 0,
    "completed_milestones" integer NOT NULL DEFAULT 0,
    "is_pruned" boolean NOT NULL DEFAULT false,
    "pruned_reason" text,
    "status" varchar(50) NOT NULL DEFAULT 'ACTIVE',
    "created_at" timestamp with time zone NOT NULL DEFAULT now(),
    "updated_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 3.10 Từng Chặng học Tích hợp 2 Thành phần (RoadmapNodes)
CREATE TABLE IF NOT EXISTS v_eval_practice."RoadmapNodes" (
    "node_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "roadmap_id" uuid NOT NULL REFERENCES v_eval_practice."LearningRoadmaps"("roadmap_id") ON DELETE CASCADE,
    "skill_id" uuid NOT NULL,
    "step_order" integer NOT NULL,
    "material_id" uuid,
    "quiz_exam_id" uuid,
    "status" varchar(50) NOT NULL DEFAULT 'LOCKED', -- 'LOCKED', 'UNLOCKED', 'COMPLETED'
    "is_pruned" boolean NOT NULL DEFAULT false,
    "unlocked_at" timestamp with time zone,
    "completed_at" timestamp with time zone,
    "video_watched_seconds" integer DEFAULT 0,
    "video_total_seconds" integer DEFAULT 0,
    "is_video_completed" boolean DEFAULT false,
    "quiz_score" double precision DEFAULT 0.0,
    "is_quiz_passed" boolean DEFAULT false
);

-- 3.11 Tiến trình Chặng học Chu trình 4 bước P-L-A-R (StageProgress)
CREATE TABLE IF NOT EXISTS v_eval_practice."StageProgress" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,
    "roadmap_node_id" uuid NOT NULL REFERENCES v_eval_practice."RoadmapNodes"("node_id") ON DELETE CASCADE,
    "current_step" varchar(50) NOT NULL DEFAULT 'PREVIEW', -- 'PREVIEW', 'LEARN', 'APPLY', 'REFLECT'
    "video_watch_percentage" numeric(5,2) DEFAULT 0.00,
    "bkt_mastery_plt" double precision DEFAULT 0.1000,
    "consecutive_advanced_correct" integer DEFAULT 0,
    "consecutive_incorrect" integer DEFAULT 0,
    "status" varchar(50) NOT NULL DEFAULT 'IN_PROGRESS', -- 'IN_PROGRESS', 'COMPLETED', 'REMEDIAL_NEEDED'
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now()
);

-- 3.12 Log Trả lời Thích ứng BKT & IRT ZPD (AdaptiveQuizAttempts)
CREATE TABLE IF NOT EXISTS v_eval_practice."AdaptiveQuizAttempts" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "stage_progress_id" uuid NOT NULL REFERENCES v_eval_practice."StageProgress"("id") ON DELETE CASCADE,
    "student_id" uuid NOT NULL,
    "question_id" uuid NOT NULL,
    "pattern_id" varchar(100),
    "selected_option" varchar(10),
    "is_correct" boolean NOT NULL,
    "time_spent_seconds" integer NOT NULL DEFAULT 0,
    "item_difficulty_b" double precision NOT NULL,
    "item_discrimination_a" double precision NOT NULL,
    "is_lucky_guess" boolean DEFAULT false,
    "prior_plt" double precision NOT NULL,
    "posterior_plt" double precision NOT NULL,
    "created_at" timestamp with time zone DEFAULT now()
);

-- 3.13 Sổ tay Lỗi sai & Lặp lại Ngắt quãng SuperMemo-2 (MistakeNotebooks)
CREATE TABLE IF NOT EXISTS v_eval_practice."MistakeNotebooks" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,
    "question_id" uuid NOT NULL,
    "skill_id" uuid NOT NULL,
    "pattern_id" varchar(100),
    "cognitive_error_tag" varchar(50), -- 'CARELESS', 'MISREAD_QUESTION', 'MISSING_CONCEPT', 'TIME_PRESSURE'
    "student_notes" text,
    "next_review_date" date NOT NULL,
    "review_count" integer DEFAULT 0,
    "consecutive_correct_reviews" integer DEFAULT 0,
    "interval_days" integer DEFAULT 1,
    "ease_factor" double precision DEFAULT 2.50,
    "is_mastered" boolean DEFAULT false,
    "last_reviewed_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    CONSTRAINT "uq_student_mistake_question" UNIQUE ("student_id", "question_id")
);

-- 3.14 Dự báo Khoảng điểm SEM & Toa thuốc Knapsack ROI (ScorePredictions)
CREATE TABLE IF NOT EXISTS v_eval_practice."ScorePredictions" (
    "prediction_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,
    "predicted_score" integer,
    "predicted_score_min" integer,
    "predicted_score_max" integer,
    "confidence_rate" double precision DEFAULT 0.95,
    "target_score" integer,
    "deficit_score" integer,
    "sem_score" double precision,
    "prescription_items" jsonb,
    "calculation_source" varchar(50) DEFAULT 'MOCK_EXAM',
    "created_at" timestamp with time zone DEFAULT now()
);

-- 3.15 Hệ thống Cảnh báo Sớm 3 Cấp BR-04 (SystemAlerts)
CREATE TABLE IF NOT EXISTS v_eval_practice."SystemAlerts" (
    "alert_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,
    "alert_type" varchar(50) NOT NULL, -- 'GREEN', 'YELLOW', 'RED', 'UNREALISTIC_GOAL'
    "message" text NOT NULL,
    "is_read" boolean DEFAULT false,
    "handled_by" uuid,
    "resolution_notes" text,
    "resolved_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT now()
);

-- 3.16 Ma trận Nhiệt Năng lực Kỹ năng Từng Học sinh (ClassSkillHeatmaps)
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassSkillHeatmaps" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "class_id" uuid NOT NULL REFERENCES v_eval_practice."Classes"("class_id") ON DELETE CASCADE,
    "student_id" uuid NOT NULL,
    "skill_id" uuid NOT NULL,
    "skill_name" varchar(255) NOT NULL,
    "domain_code" varchar(50) NOT NULL,
    "plt_value" double precision NOT NULL DEFAULT 0.1000,
    "mastery_level" varchar(30) NOT NULL DEFAULT 'WEAK', -- 'CRITICAL', 'WEAK', 'DEVELOPING', 'MASTERED'
    "last_assessment_type" varchar(50) NOT NULL DEFAULT 'DIAGNOSTIC',
    "updated_at" timestamp with time zone DEFAULT now(),
    CONSTRAINT "uq_class_student_skill" UNIQUE ("class_id", "student_id", "skill_id")
);

-- 3.17 Tổng hợp Cột Kỹ năng Lớp học & Cảnh báo Sư phạm (ClassHeatmapSummaries)
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassHeatmapSummaries" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "class_id" uuid NOT NULL REFERENCES v_eval_practice."Classes"("class_id") ON DELETE CASCADE,
    "skill_id" uuid NOT NULL,
    "skill_name" varchar(255) NOT NULL,
    "domain_code" varchar(50) NOT NULL,
    "average_plt" double precision NOT NULL DEFAULT 0.0,
    "struggling_count" integer NOT NULL DEFAULT 0,
    "total_students" integer NOT NULL DEFAULT 0,
    "struggling_rate" double precision NOT NULL DEFAULT 0.0,
    "std_dev_plt" double precision NOT NULL DEFAULT 0.0,
    "alert_status" varchar(30) NOT NULL DEFAULT 'SAFE_GREEN', -- 'CRITICAL_RED', 'WARNING_AMBER', 'SAFE_GREEN'
    "is_bimodal" boolean NOT NULL DEFAULT false,
    "calculated_at" timestamp with time zone DEFAULT now(),
    CONSTRAINT "uq_class_skill_summary" UNIQUE ("class_id", "skill_id")
);

-- 3.18 Nhật ký Chuyên cần & Streak Học tập (StudentDailyActivities)
CREATE TABLE IF NOT EXISTS v_eval_practice."StudentDailyActivities" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,
    "activity_date" date NOT NULL,
    "study_time_minutes" integer NOT NULL DEFAULT 0,
    "practice_questions_solved" integer NOT NULL DEFAULT 0,
    "video_minutes_watched" integer NOT NULL DEFAULT 0,
    "mock_exams_taken" integer NOT NULL DEFAULT 0,
    "is_streak_counted" boolean NOT NULL DEFAULT false,
    "is_frozen" boolean NOT NULL DEFAULT false,
    "created_at" timestamp with time zone DEFAULT now(),
    "updated_at" timestamp with time zone DEFAULT now(),
    CONSTRAINT "uq_student_activity_date" UNIQUE ("student_id", "activity_date")
);

-- 3.19 Chỉ số Sẵn sàng Thi ĐGNL & Xu hướng (StudentReadinessMetrics)
CREATE TABLE IF NOT EXISTS v_eval_practice."StudentReadinessMetrics" (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL UNIQUE,
    "normalized_theta" double precision NOT NULL DEFAULT 50.0,
    "skill_coverage_plt" double precision NOT NULL DEFAULT 0.0,
    "consistency_score" double precision NOT NULL DEFAULT 0.0,
    "exam_readiness_index" double precision NOT NULL DEFAULT 0.0,
    "readiness_tier" varchar(30) NOT NULL DEFAULT 'PREPARING', -- 'NOT_READY', 'PREPARING', 'ACCELERATING', 'READY'
    "study_hours_this_week" double precision NOT NULL DEFAULT 0.0,
    "current_streak_days" integer NOT NULL DEFAULT 0,
    "calculated_at" timestamp with time zone DEFAULT now()
);

-- =====================================================================
-- PHÂN VÙNG 4: V_EVAL_AI (KNOWLEDGE GRAPH RAG & SOCRATIC TUTOR LOGS)
-- =====================================================================

-- 4.1 Nguồn Tri thức Sách Giáo Khoa (KnowledgeSources)
CREATE TABLE IF NOT EXISTS v_eval_ai."KnowledgeSources" (
    "source_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "domain_id" varchar(100),
    "skill_id" varchar(100),
    "title" varchar(255) NOT NULL,
    "file_url" varchar(500),
    "file_hash" varchar(64),
    "document_type" varchar(50) DEFAULT 'TEXTBOOK', -- 'TEXTBOOK', 'CURRICULUM', 'GENERAL_KNOWLEDGE'
    "total_pages" integer DEFAULT 0,
    "total_chars" integer DEFAULT 0,
    "total_chunks" integer DEFAULT 0,
    "vector_status" varchar(50) DEFAULT 'COMPLETED', -- 'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED'
    "created_at" timestamp without time zone DEFAULT now(),
    "updated_at" timestamp without time zone DEFAULT now()
);

-- 4.2 Vector Chunks Tri thức Nhúng 768 Chiều (KnowledgeVectorChunks)
CREATE TABLE IF NOT EXISTS v_eval_ai."KnowledgeVectorChunks" (
    "chunk_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "source_id" uuid NOT NULL REFERENCES v_eval_ai."KnowledgeSources"("source_id") ON DELETE CASCADE,
    "domain_id" varchar(100),
    "skill_id" varchar(100),
    "chunk_index" integer NOT NULL,
    "page_number" integer DEFAULT 1,
    "content_snippet" text NOT NULL,
    "embedding" vector(768),
    "document_type" varchar(50) DEFAULT 'TEXTBOOK',
    "char_count" integer DEFAULT 0,
    "metadata" jsonb,
    "created_at" timestamp without time zone DEFAULT now()
);

-- 4.3 Dạng bài Mẫu Mực (archetype_patterns) - Taxonomy Level 4 Knowledge Graph
CREATE TABLE IF NOT EXISTS v_eval_ai.archetype_patterns (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "skill_id" uuid NOT NULL, -- Liên kết logic với v_eval_content."Skills"(skill_id)
    "pattern_code" varchar(100) UNIQUE NOT NULL,
    "pattern_name" varchar(255) NOT NULL,
    "description" text,
    "core_theorems" text NOT NULL,
    "fast_solving_heuristics" text,
    "embedding" vector(3072), -- 3072 chiều gemini-embedding-001 hoặc 768 chiều
    "is_verified" boolean DEFAULT false,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    "updated_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- 4.4 Lời giải Mẫu Chuẩn Vàng (pattern_exemplars)
CREATE TABLE IF NOT EXISTS v_eval_ai.pattern_exemplars (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "archetype_pattern_id" uuid NOT NULL REFERENCES v_eval_ai.archetype_patterns("id") ON DELETE CASCADE,
    "question_latex" text NOT NULL,
    "golden_solution" text NOT NULL,
    "correct_option" varchar(10) NOT NULL,
    "explanation_steps" jsonb NOT NULL DEFAULT '[]'::jsonb,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- 4.5 Bẫy Nhận thức & Ngộ nhận Điển hình (pattern_traps)
CREATE TABLE IF NOT EXISTS v_eval_ai.pattern_traps (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "archetype_pattern_id" uuid NOT NULL REFERENCES v_eval_ai.archetype_patterns("id") ON DELETE CASCADE,
    "trap_code" varchar(100) NOT NULL,
    "trap_name" varchar(255) NOT NULL,
    "wrong_option" varchar(10),
    "misconception_explanation" text NOT NULL,
    "socratic_hint" text NOT NULL,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- 4.6 Đề xuất Dạng bài Mới Chờ Kiểm duyệt (novel_pattern_proposals)
CREATE TABLE IF NOT EXISTS v_eval_ai.novel_pattern_proposals (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "source_exam_name" varchar(255) NOT NULL,
    "raw_question_latex" text NOT NULL,
    "image_urls" jsonb DEFAULT '[]'::jsonb,
    "extracted_metadata" jsonb DEFAULT '{}'::jsonb,
    "max_similarity_score" double precision,
    "nearest_archetype_id" uuid REFERENCES v_eval_ai.archetype_patterns("id") ON DELETE SET NULL,
    "status" varchar(30) DEFAULT 'PENDING_REVIEW', -- 'PENDING_REVIEW', 'APPROVED', 'MERGED', 'REJECTED'
    "academic_feedback" text,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- 4.7 Nhật ký Hội thoại Trợ giảng AI Socratic & Hậu kiểm (ai_tutor_interaction_logs)
CREATE TABLE IF NOT EXISTS v_eval_ai.ai_tutor_interaction_logs (
    "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    "student_id" uuid NOT NULL,
    "question_id" uuid NOT NULL,
    "archetype_pattern_id" uuid REFERENCES v_eval_ai.archetype_patterns("id") ON DELETE SET NULL,
    "student_selected_option" varchar(10) NOT NULL,
    "correct_option" varchar(10) NOT NULL,
    "matched_trap_id" uuid REFERENCES v_eval_ai.pattern_traps("id") ON DELETE SET NULL,
    "ai_guidance_transcript" jsonb NOT NULL DEFAULT '[]'::jsonb,
    "validation_status" varchar(20) DEFAULT 'PASSED', -- 'PASSED', 'OVERRIDDEN', 'REJECTED'
    "student_reported" boolean DEFAULT false,
    "mentor_resolution" text,
    "created_at" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

-- 4.8 Tài liệu Lý thuyết Nạp AI RAG (TheoreticalDocuments) - Domain Entity AI Engine
CREATE TABLE IF NOT EXISTS v_eval_ai."TheoreticalDocuments" (
    "document_id" varchar(100) PRIMARY KEY,
    "title" varchar(255) NOT NULL,
    "content" text NOT NULL,
    "skill_id" varchar(100) NOT NULL, -- Tham chiếu logic v_eval_content."Skills"(skill_id)
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- 4.9 Phiên Gia sư Ảo Socratic (TutorSessions) - Domain Entity AI Engine
CREATE TABLE IF NOT EXISTS v_eval_ai."TutorSessions" (
    "session_id" varchar(100) PRIMARY KEY,
    "student_id" varchar(100) NOT NULL, -- Tham chiếu logic v_eval_identity."Students"(student_id)
    "question_id" varchar(100) NOT NULL, -- Tham chiếu logic v_eval_content."Questions"(question_id)
    "is_active" boolean NOT NULL DEFAULT true,
    "messages" jsonb NOT NULL DEFAULT '[]'::jsonb,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- =====================================================================
-- CHỈ MỤC TỐI ƯU HÓA HIỆU NĂNG CAO (ENTERPRISE INDEXES)
-- =====================================================================

-- 1. Identity & Actors
CREATE INDEX IF NOT EXISTS "idx_users_email" ON v_eval_identity."Users"("email");
CREATE INDEX IF NOT EXISTS "idx_userroles_user_role" ON v_eval_identity."UserRoles"("user_id", "role_id");
CREATE INDEX IF NOT EXISTS "idx_students_campus" ON v_eval_identity."Students"("campus_id");
CREATE INDEX IF NOT EXISTS "idx_refreshtokens_user" ON v_eval_identity."RefreshTokens"("user_id");
CREATE INDEX IF NOT EXISTS "idx_otp_email_type" ON v_eval_identity."OtpVerifications"("email", "type");

-- 2. Content & Questions
CREATE INDEX IF NOT EXISTS "idx_skills_domain_parent" ON v_eval_content."Skills"("domain_id", "parent_id");
CREATE INDEX IF NOT EXISTS "idx_questions_skill_difficulty" ON v_eval_content."Questions"("skill_id", "difficulty_level");
CREATE INDEX IF NOT EXISTS "idx_materials_skill" ON v_eval_content."Materials"("skill_id");
CREATE INDEX IF NOT EXISTS "idx_examquestions_order" ON v_eval_content."ExamQuestions"("exam_id", "question_order");

-- 3. Practice, Roadmaps & Stages
CREATE INDEX IF NOT EXISTS "idx_classes_campus_status" ON v_eval_practice."Classes"("campus_id", "status");
CREATE INDEX IF NOT EXISTS "idx_class_groups_class" ON v_eval_practice."ClassGroups"("class_id");
CREATE INDEX IF NOT EXISTS "idx_class_group_members_group" ON v_eval_practice."ClassGroupMembers"("group_id");
CREATE INDEX IF NOT EXISTS "idx_class_group_members_student" ON v_eval_practice."ClassGroupMembers"("student_id");
CREATE INDEX IF NOT EXISTS "idx_submissions_student_exam" ON v_eval_practice."ExamSubmissions"("student_id", "exam_id");
CREATE INDEX IF NOT EXISTS "idx_subanswers_submission" ON v_eval_practice."SubmissionAnswers"("submission_id");
CREATE INDEX IF NOT EXISTS "idx_proctoring_submission" ON v_eval_practice."ProctoringSnapshots"("submission_id");
CREATE INDEX IF NOT EXISTS "idx_roadmaps_student" ON v_eval_practice."LearningRoadmaps"("student_id");
CREATE INDEX IF NOT EXISTS "idx_roadmap_nodes_order" ON v_eval_practice."RoadmapNodes"("roadmap_id", "step_order");
CREATE INDEX IF NOT EXISTS "idx_stage_progress_node" ON v_eval_practice."StageProgress"("roadmap_node_id");
CREATE INDEX IF NOT EXISTS "idx_adaptive_attempts_progress" ON v_eval_practice."AdaptiveQuizAttempts"("stage_progress_id");
CREATE INDEX IF NOT EXISTS "idx_mistake_review_schedule" ON v_eval_practice."MistakeNotebooks"("student_id", "is_mastered", "next_review_date");
CREATE INDEX IF NOT EXISTS "idx_score_predictions_student" ON v_eval_practice."ScorePredictions"("student_id");
CREATE INDEX IF NOT EXISTS "idx_system_alerts_student" ON v_eval_practice."SystemAlerts"("student_id", "is_read");

-- 4. Analytics & Heatmaps
CREATE INDEX IF NOT EXISTS "idx_heatmaps_class_student" ON v_eval_practice."ClassSkillHeatmaps"("class_id", "student_id");
CREATE INDEX IF NOT EXISTS "idx_heatmaps_skill" ON v_eval_practice."ClassSkillHeatmaps"("skill_id");
CREATE INDEX IF NOT EXISTS "idx_heatmap_summaries_class_status" ON v_eval_practice."ClassHeatmapSummaries"("class_id", "alert_status");
CREATE INDEX IF NOT EXISTS "idx_student_activity_date" ON v_eval_practice."StudentDailyActivities"("student_id", "activity_date" DESC);
CREATE INDEX IF NOT EXISTS "idx_readiness_student" ON v_eval_practice."StudentReadinessMetrics"("student_id");

-- 5. AI Engine & Vector Search
CREATE INDEX IF NOT EXISTS "idx_knowledge_vector_hnsw" ON v_eval_ai."KnowledgeVectorChunks" USING hnsw ("embedding" vector_cosine_ops);
CREATE INDEX IF NOT EXISTS "idx_knowledge_chunks_source" ON v_eval_ai."KnowledgeVectorChunks"("source_id");
CREATE INDEX IF NOT EXISTS "idx_archetype_patterns_code" ON v_eval_ai.archetype_patterns("pattern_code");
CREATE INDEX IF NOT EXISTS "idx_archetype_patterns_skill" ON v_eval_ai.archetype_patterns("skill_id");
CREATE INDEX IF NOT EXISTS "idx_exemplars_archetype" ON v_eval_ai.pattern_exemplars("archetype_pattern_id");
CREATE INDEX IF NOT EXISTS "idx_traps_archetype" ON v_eval_ai.pattern_traps("archetype_pattern_id");
CREATE INDEX IF NOT EXISTS "idx_novel_proposals_status" ON v_eval_ai.novel_pattern_proposals("status");
CREATE INDEX IF NOT EXISTS "idx_ai_logs_student_question" ON v_eval_ai.ai_tutor_interaction_logs("student_id", "question_id");
CREATE INDEX IF NOT EXISTS "idx_theoretical_docs_skill" ON v_eval_ai."TheoreticalDocuments"("skill_id");
CREATE INDEX IF NOT EXISTS "idx_tutor_sessions_student_question" ON v_eval_ai."TutorSessions"("student_id", "question_id");