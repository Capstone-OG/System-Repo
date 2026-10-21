-- =====================================================================
-- V-EVAL PLATFORM — MASTER ENTERPRISE DATABASE SCHEMA V3 (PostgreSQL)
-- Đồng bộ 100% với Kiến trúc Microservices, ERD V3 & 6 Core Flows
-- Tương thích: Supabase PostgreSQL 15+, pgvector, EF Core 9 Migrations
-- Phân tách chuẩn 4 Schema:
--   1. v_eval_identity  (Định danh, RBAC, 6 Actor Profiles, Cơ sở Trường)
--   2. v_eval_content   (Ma trận Khung Năng lực 3 cấp, DAG Tiên quyết, Đề thi & Ngân hàng 4 khối)
--   3. v_eval_practice  (Hồ sơ Năng lực, Lộ trình Cá nhân hóa, 4 Giai đoạn Sư phạm, Sổ tay Lỗi sai Leitner, Lớp học & Nhóm phân hóa)
--   4. v_eval_ai        (RAG Vector Database, Socratic AI Tutor Session, Dự đoán Điểm & Token Logs)
-- Cập nhật ngày: 21/10/2026
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. CÀI ĐẶT EXTENSIONS HỆ THỐNG
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS vector;

-- ---------------------------------------------------------------------
-- KHỞI TẠO 4 NAMESPACE SCHEMAS ĐỘC LẬP
-- ---------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS v_eval_identity;
CREATE SCHEMA IF NOT EXISTS v_eval_content;
CREATE SCHEMA IF NOT EXISTS v_eval_practice;
CREATE SCHEMA IF NOT EXISTS v_eval_ai;

-- =====================================================================
-- PHÂN HỆ 1: V_EVAL_IDENTITY (ĐỊNH DANH & PHÂN QUYỀN RBAC)
-- =====================================================================

-- 1.1 Cơ sở đào tạo liên kết (Campuses)
CREATE TABLE IF NOT EXISTS v_eval_identity."Campuses" (
  "campus_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" varchar(255) NOT NULL,
  "address" varchar(500),
  "phone" varchar(50),
  "is_active" boolean DEFAULT true,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 1.2 Vai trò hệ thống (Roles)
CREATE TABLE IF NOT EXISTS v_eval_identity."Roles" (
  "role_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "role_name" varchar(50) UNIQUE NOT NULL -- 'STUDENT', 'TEACHER', 'ACADEMIC_MANAGER', 'ACADEMIC_DIRECTOR', 'ADMINISTRATOR', 'PARENT'
);

-- 1.3 Tài khoản người dùng tập trung (Users)
CREATE TABLE IF NOT EXISTS v_eval_identity."Users" (
  "user_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "email" varchar(255) UNIQUE NOT NULL,
  "password_hash" varchar(500) NOT NULL,
  "full_name" varchar(255) NOT NULL,
  "phone" varchar(50),
  "avatar_url" varchar(500),
  "is_active" boolean DEFAULT true,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 1.4 Bảng nối N-N Người dùng - Vai trò (UserRoles)
CREATE TABLE IF NOT EXISTS v_eval_identity."UserRoles" (
  "user_id" uuid NOT NULL REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
  "role_id" uuid NOT NULL REFERENCES v_eval_identity."Roles"("role_id") ON DELETE RESTRICT,
  PRIMARY KEY ("user_id", "role_id")
);

-- 1.5 Hồ sơ Học sinh (Students)
CREATE TABLE IF NOT EXISTS v_eval_identity."Students" (
  "student_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
  "campus_id" uuid REFERENCES v_eval_identity."Campuses"("campus_id") ON DELETE SET NULL,
  "target_score" int DEFAULT 800,
  "exam_date" date,
  "study_hours_day" double precision DEFAULT 2.0,
  "school_name" varchar(255),
  "created_at" timestamp with time zone DEFAULT now()
);

-- 1.6 Hồ sơ Phụ huynh (Parents)
CREATE TABLE IF NOT EXISTS v_eval_identity."Parents" (
  "parent_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
  "phone_work" varchar(50)
);

-- 1.7 Quan hệ Phụ huynh - Học sinh (ParentStudentRelations)
CREATE TABLE IF NOT EXISTS v_eval_identity."ParentStudentRelations" (
  "relation_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "parent_id" uuid NOT NULL REFERENCES v_eval_identity."Parents"("parent_id") ON DELETE CASCADE,
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "created_at" timestamp with time zone DEFAULT now(),
  CONSTRAINT "uq_parent_student" UNIQUE ("parent_id", "student_id")
);

-- 1.8 Hồ sơ Giáo viên (Teachers)
CREATE TABLE IF NOT EXISTS v_eval_identity."Teachers" (
  "teacher_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
  "campus_id" uuid REFERENCES v_eval_identity."Campuses"("campus_id") ON DELETE SET NULL,
  "specialty" varchar(255),
  "bio" text,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 1.9 Hồ sơ Quản lý Học vụ (AcademicManagers)
CREATE TABLE IF NOT EXISTS v_eval_identity."AcademicManagers" (
  "manager_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
  "campus_id" uuid REFERENCES v_eval_identity."Campuses"("campus_id") ON DELETE SET NULL,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 1.10 Hồ sơ Giám đốc Đào tạo (AcademicDirectors)
CREATE TABLE IF NOT EXISTS v_eval_identity."AcademicDirectors" (
  "director_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 1.11 Hồ sơ Quản trị viên Kỹ thuật (Administrators)
CREATE TABLE IF NOT EXISTS v_eval_identity."Administrators" (
  "admin_id" uuid PRIMARY KEY REFERENCES v_eval_identity."Users"("user_id") ON DELETE CASCADE,
  "created_at" timestamp with time zone DEFAULT now()
);

-- =====================================================================
-- PHÂN HỆ 2: V_EVAL_CONTENT (KHUNG NĂNG LỰC, DAG TIÊN QUYẾT & NGÂN HÀNG CÂU HỎI)
-- =====================================================================

-- 2.1 Miền Năng lực ĐGNL (CompetencyDomains)
CREATE TABLE IF NOT EXISTS v_eval_content."CompetencyDomains" (
  "domain_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" varchar(255) NOT NULL,
  "description" text,
  "is_approved" boolean DEFAULT false,
  "approved_by" uuid REFERENCES v_eval_identity."Users"("user_id") ON DELETE SET NULL,
  "approved_at" timestamp with time zone
);

-- 2.2 Cây Phân cấp Kỹ năng / Tri thức 3 tầng (Skills): Chương -> Bài học -> Dạng bài
CREATE TABLE IF NOT EXISTS v_eval_content."Skills" (
  "skill_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "domain_id" uuid NOT NULL REFERENCES v_eval_content."CompetencyDomains"("domain_id") ON DELETE CASCADE,
  "name" varchar(255) NOT NULL,
  "parent_id" uuid REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
  "weight" double precision DEFAULT 1.0,
  "is_approved" boolean DEFAULT false,
  "approved_by" uuid REFERENCES v_eval_identity."Users"("user_id") ON DELETE SET NULL,
  "approved_at" timestamp with time zone,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 2.3 Đồ thị Có hướng Không chu trình (DAG) Kỹ năng Tiên quyết (SkillPrerequisites)
CREATE TABLE IF NOT EXISTS v_eval_content."SkillPrerequisites" (
  "skill_id" uuid NOT NULL REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
  "prerequisite_id" uuid NOT NULL REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
  PRIMARY KEY ("skill_id", "prerequisite_id")
);

-- 2.4 Tài liệu Sư phạm 4 khối theo Dạng bài (Materials)
CREATE TABLE IF NOT EXISTS v_eval_content."Materials" (
  "material_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "skill_id" uuid NOT NULL REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
  "title" varchar(255) NOT NULL,
  "content" text,                           -- Markdown chứa 4 khối, KaTeX, [MATH_GRAPH], [VARIATION_TABLE]
  "video_url" varchar(500),
  "file_url" varchar(500),
  "duration_seconds" int DEFAULT 600,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 2.5 Đoạn văn / Bài đọc chung (Passages)
CREATE TABLE IF NOT EXISTS v_eval_content."Passages" (
  "passage_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "title" varchar(255),
  "content" text NOT NULL,
  "image_url" varchar(500)
);

-- 2.6 Ngân hàng Câu hỏi Trắc nghiệm Chuẩn hóa (Questions)
CREATE TABLE IF NOT EXISTS v_eval_content."Questions" (
  "question_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "skill_id" uuid NOT NULL REFERENCES v_eval_content."Skills"("skill_id") ON DELETE RESTRICT,
  "passage_id" uuid REFERENCES v_eval_content."Passages"("passage_id") ON DELETE SET NULL,
  "difficulty_level" int DEFAULT 2,          -- 1: Nhận biết, 2: Thông hiểu, 3: Vận dụng, 4: Vận dụng cao
  "content_latex" text NOT NULL,
  "option_a" text NOT NULL,
  "option_b" text NOT NULL,
  "option_c" text NOT NULL,
  "option_d" text NOT NULL,
  "correct_option" char(1) NOT NULL,        -- 'A', 'B', 'C', 'D' (Được chuẩn hóa qua FlexibleCharJsonConverter)
  "explanation" text,
  "is_ai_generated" boolean DEFAULT false,
  "moderation_status" varchar(50) DEFAULT 'PENDING', -- 'PENDING', 'APPROVED', 'REJECTED'
  "reviewed_by" uuid REFERENCES v_eval_identity."Users"("user_id") ON DELETE SET NULL,
  "reviewed_at" timestamp with time zone,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 2.7 Bộ Đề thi Thử & Đề Chẩn đoán Năng lực (MockExams)
CREATE TABLE IF NOT EXISTS v_eval_content."MockExams" (
  "exam_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "campus_id" uuid REFERENCES v_eval_identity."Campuses"("campus_id") ON DELETE SET NULL,
  "title" varchar(255) NOT NULL,
  "exam_type" varchar(50) DEFAULT 'MOCK_VACT', -- 'DIAGNOSTIC', 'PERIODIC', 'MOCK_VACT'
  "duration_minutes" int DEFAULT 150,
  "total_questions" int DEFAULT 120,
  "scheduled_at" timestamp with time zone,
  "is_published" boolean DEFAULT false,
  "created_by" uuid REFERENCES v_eval_identity."Users"("user_id") ON DELETE SET NULL,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 2.8 Danh sách Câu hỏi trong Đề thi (ExamQuestions)
CREATE TABLE IF NOT EXISTS v_eval_content."ExamQuestions" (
  "exam_id" uuid NOT NULL REFERENCES v_eval_content."MockExams"("exam_id") ON DELETE CASCADE,
  "question_id" uuid NOT NULL REFERENCES v_eval_content."Questions"("question_id") ON DELETE RESTRICT,
  "question_order" int NOT NULL,
  PRIMARY KEY ("exam_id", "question_id")
);

-- =====================================================================
-- PHÂN HỆ 3: V_EVAL_PRACTICE (HỌC TẬP CÁ NHÂN HÓA, LỘ TRÌNH, LỚP HỌC & ADAPTIVE)
-- =====================================================================

-- 3.1 Hồ sơ Điểm Năng lực theo Từng Kỹ năng (LearningProfiles)
CREATE TABLE IF NOT EXISTS v_eval_practice."LearningProfiles" (
  "profile_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "skill_id" uuid NOT NULL REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
  "mastery_score" double precision DEFAULT 0.5, -- IRT / BKT: 0.0 -> 1.0 (Ngưỡng đạt: 0.85)
  "last_updated" timestamp with time zone DEFAULT now(),
  CONSTRAINT "uq_student_skill_profile" UNIQUE ("student_id", "skill_id")
);

-- 3.2 Lộ trình Học tập Cá nhân hóa Tổng thể (LearningRoadmaps)
CREATE TABLE IF NOT EXISTS v_eval_practice."LearningRoadmaps" (
  "roadmap_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "target_score" int DEFAULT 800,
  "total_estimated_days" int DEFAULT 90,
  "status" varchar(50) DEFAULT 'IN_PROGRESS',   -- 'IN_PROGRESS', 'COMPLETED', 'ARCHIVED'
  "created_at" timestamp with time zone DEFAULT now(),
  "updated_at" timestamp with time zone DEFAULT now()
);

-- 3.3 Từng Node Kỹ năng trên Lộ trình (RoadmapNodes - Topological Ordered)
CREATE TABLE IF NOT EXISTS v_eval_practice."RoadmapNodes" (
  "node_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "roadmap_id" uuid NOT NULL REFERENCES v_eval_practice."LearningRoadmaps"("roadmap_id") ON DELETE CASCADE,
  "skill_id" uuid NOT NULL REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
  "step_order" int NOT NULL,
  "status" varchar(50) DEFAULT 'LOCKED',        -- 'LOCKED', 'AVAILABLE', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED'
  "completed_at" timestamp with time zone
);

-- 3.4 Tiến độ 4 Giai đoạn Sư phạm trên Từng Node (StageProgress)
CREATE TABLE IF NOT EXISTS v_eval_practice."StageProgress" (
  "stage_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "node_id" uuid NOT NULL REFERENCES v_eval_practice."RoadmapNodes"("node_id") ON DELETE CASCADE,
  "stage_number" int NOT NULL,                  -- 1: Nền tảng SGK, 2: Phương pháp & Bẫy, 3: Video Giảng dạy, 4: Adaptive Quiz
  "is_completed" boolean DEFAULT false,
  "completed_at" timestamp with time zone,
  CONSTRAINT "uq_node_stage" UNIQUE ("node_id", "stage_number")
);

-- 3.5 Lịch sử Làm Adaptive Quiz Từng Câu (AdaptiveQuizAttempts)
CREATE TABLE IF NOT EXISTS v_eval_practice."AdaptiveQuizAttempts" (
  "attempt_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "node_id" uuid NOT NULL REFERENCES v_eval_practice."RoadmapNodes"("node_id") ON DELETE CASCADE,
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "question_id" uuid NOT NULL REFERENCES v_eval_content."Questions"("question_id") ON DELETE RESTRICT,
  "question_level" int NOT NULL,
  "selected_option" char(1),
  "is_correct" boolean NOT NULL,
  "time_spent_seconds" int DEFAULT 0,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 3.6 Nhật ký Luyện tập Tự do (AttemptLogs)
CREATE TABLE IF NOT EXISTS v_eval_practice."AttemptLogs" (
  "attempt_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "question_id" uuid NOT NULL REFERENCES v_eval_content."Questions"("question_id") ON DELETE RESTRICT,
  "selected_option" char(1),
  "is_correct" boolean NOT NULL,
  "time_spent" int DEFAULT 0,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 3.7 Bài Làm Đề Thi Thử / Đề Chẩn Đoán (ExamSubmissions)
CREATE TABLE IF NOT EXISTS v_eval_practice."ExamSubmissions" (
  "submission_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "exam_id" uuid NOT NULL REFERENCES v_eval_content."MockExams"("exam_id") ON DELETE CASCADE,
  "total_score" int DEFAULT 0,
  "started_at" timestamp with time zone DEFAULT now(),
  "completed_at" timestamp with time zone,
  "status" varchar(50) DEFAULT 'DOING'          -- 'DOING', 'SUBMITTED', 'GRADED'
);

-- 3.8 Chi tiết Câu Trả Lời Trong Đề Thi (SubmissionAnswers)
CREATE TABLE IF NOT EXISTS v_eval_practice."SubmissionAnswers" (
  "answer_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "submission_id" uuid NOT NULL REFERENCES v_eval_practice."ExamSubmissions"("submission_id") ON DELETE CASCADE,
  "question_id" uuid NOT NULL REFERENCES v_eval_content."Questions"("question_id") ON DELETE RESTRICT,
  "selected_option" char(1),
  "is_correct" boolean NOT NULL,
  "time_spent" int DEFAULT 0
);

-- 3.9 Sổ tay Lỗi sai & Lặp lại Ngắt quãng Leitner (MistakeNotebooks)
CREATE TABLE IF NOT EXISTS v_eval_practice."MistakeNotebooks" (
  "mistake_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "question_id" uuid NOT NULL REFERENCES v_eval_content."Questions"("question_id") ON DELETE RESTRICT,
  "skill_id" uuid NOT NULL REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
  "last_attempted_at" timestamp with time zone DEFAULT now(),
  "error_type" varchar(50) DEFAULT 'CONCEPT_MISUNDERSTANDING', -- 'CALCULATION', 'CONCEPT_MISUNDERSTANDING', 'MISREAD_QUESTION', 'TIME_PRESSURE'
  "repetition_count" int DEFAULT 1,             -- Hộp Leitner (1 -> 5)
  "next_review_date" date NOT NULL,             -- Spaced Repetition Scheduling
  "is_resolved" boolean DEFAULT false,
  CONSTRAINT "uq_student_mistake_question" UNIQUE ("student_id", "question_id")
);

-- 3.10 Lớp Học Trực Tuyến & Cơ Sở (Classes)
CREATE TABLE IF NOT EXISTS v_eval_practice."Classes" (
  "class_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "campus_id" uuid NOT NULL REFERENCES v_eval_identity."Campuses"("campus_id") ON DELETE RESTRICT,
  "teacher_id" uuid NOT NULL REFERENCES v_eval_identity."Teachers"("teacher_id") ON DELETE RESTRICT,
  "assigned_by" uuid REFERENCES v_eval_identity."AcademicManagers"("manager_id") ON DELETE SET NULL,
  "name" varchar(255) NOT NULL,
  "start_date" date,
  "end_date" date,
  "status" varchar(50) DEFAULT 'ACTIVE',        -- 'ACTIVE', 'COMPLETED', 'ARCHIVED'
  "assigned_at" timestamp with time zone,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 3.11 Danh Sách Học Viên Thuộc Lớp (ClassEnrollments)
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassEnrollments" (
  "enrollment_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "class_id" uuid NOT NULL REFERENCES v_eval_practice."Classes"("class_id") ON DELETE CASCADE,
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "diagnostic_submission_id" uuid REFERENCES v_eval_practice."ExamSubmissions"("submission_id") ON DELETE SET NULL,
  "approved_by" uuid REFERENCES v_eval_identity."AcademicManagers"("manager_id") ON DELETE SET NULL,
  "status" varchar(50) DEFAULT 'ENROLLED',      -- 'ENROLLED', 'DROPPED', 'COMPLETED'
  "enrolled_at" timestamp with time zone DEFAULT now(),
  CONSTRAINT "uq_class_student" UNIQUE ("class_id", "student_id")
);

-- 3.12 Nhóm Phân Hóa Năng Lực Trong Lớp (ClassGroups - Thematic Cohorts)
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassGroups" (
  "class_group_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "class_id" uuid NOT NULL REFERENCES v_eval_practice."Classes"("class_id") ON DELETE CASCADE,
  "group_name" varchar(255) NOT NULL,
  "target_level" varchar(50) DEFAULT 'STANDARD', -- 'REMEDIAL', 'STANDARD', 'ADVANCED'
  "assigned_roadmap_node_id" uuid REFERENCES v_eval_practice."RoadmapNodes"("node_id") ON DELETE SET NULL,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 3.13 Thành Viên Nhóm Phân Hóa (ClassGroupMembers)
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassGroupMembers" (
  "membership_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "class_group_id" uuid NOT NULL REFERENCES v_eval_practice."ClassGroups"("class_group_id") ON DELETE CASCADE,
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "joined_at" timestamp with time zone DEFAULT now(),
  CONSTRAINT "uq_class_group_student" UNIQUE ("class_group_id", "student_id")
);

-- 3.14 Buổi Học Live Trực Tuyến (LiveSessions)
CREATE TABLE IF NOT EXISTS v_eval_practice."LiveSessions" (
  "session_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "class_id" uuid NOT NULL REFERENCES v_eval_practice."Classes"("class_id") ON DELETE CASCADE,
  "teacher_id" uuid NOT NULL REFERENCES v_eval_identity."Teachers"("teacher_id") ON DELETE RESTRICT,
  "title" varchar(255) NOT NULL,
  "description" text,
  "scheduled_at" timestamp with time zone NOT NULL,
  "duration_minutes" int DEFAULT 60,
  "meeting_url" varchar(500),
  "status" varchar(50) DEFAULT 'SCHEDULED',     -- 'SCHEDULED', 'IN_PROGRESS', 'ENDED'
  "created_at" timestamp with time zone DEFAULT now()
);

-- 3.15 Điểm Danh Buổi Học Live (LiveSessionAttendance)
CREATE TABLE IF NOT EXISTS v_eval_practice."LiveSessionAttendance" (
  "attendance_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "session_id" uuid NOT NULL REFERENCES v_eval_practice."LiveSessions"("session_id") ON DELETE CASCADE,
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "joined_at" timestamp with time zone,
  "left_at" timestamp with time zone,
  CONSTRAINT "uq_session_student_att" UNIQUE ("session_id", "student_id")
);

-- 3.16 Phản Hồi Sư Phạm Của Giáo Viên (TeacherFeedback)
CREATE TABLE IF NOT EXISTS v_eval_practice."TeacherFeedback" (
  "feedback_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "teacher_id" uuid NOT NULL REFERENCES v_eval_identity."Teachers"("teacher_id") ON DELETE RESTRICT,
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "class_id" uuid REFERENCES v_eval_practice."Classes"("class_id") ON DELETE SET NULL,
  "content" text NOT NULL,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 3.17 Nhóm Năng Lực Vĩ Mô Phân Cụm ML (AbilityGroups - Constrained K-Means)
CREATE TABLE IF NOT EXISTS v_eval_practice."AbilityGroups" (
  "group_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "domain_id" uuid NOT NULL REFERENCES v_eval_content."CompetencyDomains"("domain_id") ON DELETE CASCADE,
  "skill_id" uuid REFERENCES v_eval_content."Skills"("skill_id") ON DELETE CASCADE,
  "group_label" varchar(255) NOT NULL,
  "description" text,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 3.18 Phân Cụm Năng Lực Học Sinh Hiện Tại (StudentGroupMemberships)
CREATE TABLE IF NOT EXISTS v_eval_practice."StudentGroupMemberships" (
  "membership_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "group_id" uuid NOT NULL REFERENCES v_eval_practice."AbilityGroups"("group_id") ON DELETE CASCADE,
  "assigned_at" timestamp with time zone DEFAULT now(),
  "is_current" boolean DEFAULT true
);

-- 3.19 Cảnh Báo Nguy Cơ Học Tập (SystemAlerts)
CREATE TABLE IF NOT EXISTS v_eval_practice."SystemAlerts" (
  "alert_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "alert_type" varchar(50) NOT NULL,            -- 'FALL_BEHIND', 'INACTIVE', 'REPEATED_MISTAKES', 'MILESTONE_REACHED'
  "message" text NOT NULL,
  "is_read" boolean DEFAULT false,
  "handled_by" uuid REFERENCES v_eval_identity."AcademicManagers"("manager_id") ON DELETE SET NULL,
  "resolution_notes" text,
  "resolved_at" timestamp with time zone,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 3.20 Cấu Hình Hệ Thống Tập Trung (SystemConfigs)
CREATE TABLE IF NOT EXISTS v_eval_practice."SystemConfigs" (
  "config_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "config_key" varchar(255) UNIQUE NOT NULL,
  "config_value" text,
  "description" text,
  "updated_by" uuid REFERENCES v_eval_identity."Users"("user_id") ON DELETE SET NULL,
  "updated_at" timestamp with time zone DEFAULT now()
);

-- =====================================================================
-- PHÂN HỆ 4: V_EVAL_AI (VECTOR DATABASE, RAG TRI THỨC & SOCRATIC AI TUTOR)
-- =====================================================================

-- 4.1 Nguồn Tài Liệu Tri Thức Sách Giáo Khoa (KnowledgeSources)
CREATE TABLE IF NOT EXISTS v_eval_ai."KnowledgeSources" (
  "source_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "domain_id" varchar(100),
  "skill_id" varchar(100),
  "title" varchar(255) NOT NULL,
  "file_url" varchar(500),
  "file_hash" varchar(64),
  "document_type" varchar(50) DEFAULT 'TEXTBOOK', -- 'TEXTBOOK', 'CURRICULUM', 'GENERAL_KNOWLEDGE'
  "total_pages" int DEFAULT 0,
  "total_chars" int DEFAULT 0,
  "total_chunks" int DEFAULT 0,
  "vector_status" varchar(50) DEFAULT 'COMPLETED', -- 'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED'
  "created_at" timestamp with time zone DEFAULT now(),
  "updated_at" timestamp with time zone DEFAULT now()
);

-- 4.2 Bảng Chunks Vector Tri Thức Nhúng pgvector (KnowledgeVectorChunks)
CREATE TABLE IF NOT EXISTS v_eval_ai."KnowledgeVectorChunks" (
  "chunk_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "source_id" uuid NOT NULL REFERENCES v_eval_ai."KnowledgeSources"("source_id") ON DELETE CASCADE,
  "domain_id" varchar(100),
  "skill_id" varchar(100),
  "chunk_index" int NOT NULL,
  "page_number" int DEFAULT 1,
  "content_snippet" text NOT NULL,
  "embedding" vector(768),                         -- 768 chiều (Gemini text-embedding-004)
  "document_type" varchar(50) DEFAULT 'TEXTBOOK',
  "char_count" int DEFAULT 0,
  "metadata" jsonb,                                -- Thông tin mở rộng (header, chương, tiêu đề phụ...)
  "created_at" timestamp with time zone DEFAULT now()
);

-- 4.3 Phiên Hỏi Đáp Trợ Lý Ảo Socratic (AITutorSessions)
CREATE TABLE IF NOT EXISTS v_eval_ai."AITutorSessions" (
  "session_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "question_id" uuid REFERENCES v_eval_content."Questions"("question_id") ON DELETE SET NULL,
  "skill_id" uuid REFERENCES v_eval_content."Skills"("skill_id") ON DELETE SET NULL,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 4.4 Lịch Sử Tin Nhắn Trợ Lý Ảo Socratic (AITutorMessages)
CREATE TABLE IF NOT EXISTS v_eval_ai."AITutorMessages" (
  "message_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "session_id" uuid NOT NULL REFERENCES v_eval_ai."AITutorSessions"("session_id") ON DELETE CASCADE,
  "role" varchar(50) NOT NULL,                     -- 'user', 'assistant', 'system'
  "content" text NOT NULL,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 4.5 Dự Đoán Điểm Thi ĐGNL Tương Lai (ScorePredictions)
CREATE TABLE IF NOT EXISTS v_eval_ai."ScorePredictions" (
  "prediction_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL REFERENCES v_eval_identity."Students"("student_id") ON DELETE CASCADE,
  "predicted_score" int NOT NULL,
  "predicted_score_min" int NOT NULL,
  "predicted_score_max" int NOT NULL,
  "confidence_rate" double precision DEFAULT 0.85,
  "created_at" timestamp with time zone DEFAULT now()
);

-- 4.6 Giám Sát Chi Phí & Token Tiêu Thụ LLM (TokenUsageLogs)
CREATE TABLE IF NOT EXISTS v_eval_ai."TokenUsageLogs" (
  "log_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "service_name" varchar(100) NOT NULL,
  "related_session_id" uuid REFERENCES v_eval_ai."AITutorSessions"("session_id") ON DELETE SET NULL,
  "tokens_used" int DEFAULT 0,
  "cost_usd" double precision DEFAULT 0.0,
  "created_at" timestamp with time zone DEFAULT now()
);

-- =====================================================================
-- CHỈ MỤC TỐI ƯU HÓA HIỆU NĂNG CAO (ENTERPRISE HIGH-PERFORMANCE INDEXES)
-- =====================================================================

-- Chỉ mục pgvector HNSW Cosine Similarity (<5ms tra cứu)
CREATE INDEX IF NOT EXISTS "idx_knowledge_vector_hnsw" 
ON v_eval_ai."KnowledgeVectorChunks" 
USING hnsw ("embedding" vector_cosine_ops);

-- Chỉ mục lọc và nối Vector Chunks
CREATE INDEX IF NOT EXISTS "idx_knowledge_chunks_source" ON v_eval_ai."KnowledgeVectorChunks" ("source_id");
CREATE INDEX IF NOT EXISTS "idx_knowledge_chunks_domain" ON v_eval_ai."KnowledgeVectorChunks" ("domain_id");
CREATE INDEX IF NOT EXISTS "idx_knowledge_chunks_skill" ON v_eval_ai."KnowledgeVectorChunks" ("skill_id");

-- Chỉ mục Hồ sơ Năng lực & Lộ trình
CREATE INDEX IF NOT EXISTS "idx_lp_student_mastery" ON v_eval_practice."LearningProfiles" ("student_id", "mastery_score");
CREATE INDEX IF NOT EXISTS "idx_roadmap_student_status" ON v_eval_practice."LearningRoadmaps" ("student_id", "status");
CREATE INDEX IF NOT EXISTS "idx_roadmap_nodes_order" ON v_eval_practice."RoadmapNodes" ("roadmap_id", "step_order");
CREATE INDEX IF NOT EXISTS "idx_stage_progress_node" ON v_eval_practice."StageProgress" ("node_id", "stage_number");
CREATE INDEX IF NOT EXISTS "idx_adaptive_attempts_student" ON v_eval_practice."AdaptiveQuizAttempts" ("student_id", "node_id");

-- Chỉ mục Sổ tay Lỗi sai Leitner
CREATE INDEX IF NOT EXISTS "idx_mistake_review_schedule" ON v_eval_practice."MistakeNotebooks" ("student_id", "is_resolved", "next_review_date");

-- Chỉ mục Nhóm Phân Hóa Năng Lực
CREATE INDEX IF NOT EXISTS "idx_sgm_student_current" ON v_eval_practice."StudentGroupMemberships" ("student_id", "is_current");
CREATE INDEX IF NOT EXISTS "idx_ability_groups_domain" ON v_eval_practice."AbilityGroups" ("domain_id");
CREATE INDEX IF NOT EXISTS "idx_class_groups_class" ON v_eval_practice."ClassGroups" ("class_id");

-- Chỉ mục Khung Năng Lực & Câu Hỏi
CREATE INDEX IF NOT EXISTS "idx_skills_domain_parent" ON v_eval_content."Skills" ("domain_id", "parent_id");
CREATE INDEX IF NOT EXISTS "idx_questions_skill_level" ON v_eval_content."Questions" ("skill_id", "difficulty_level");
CREATE INDEX IF NOT EXISTS "idx_materials_skill" ON v_eval_content."Materials" ("skill_id");
CREATE INDEX IF NOT EXISTS "idx_exam_questions_order" ON v_eval_content."ExamQuestions" ("exam_id", "question_order");

-- =====================================================================
-- BẢO VỆ SCHEMA SEARCH_PATH CHO CLIENT LIÊN THÔNG
-- =====================================================================
-- Lệnh cấu hình search_path cho user ứng dụng khi kết nối chung:
-- ALTER ROLE postgres SET search_path TO v_eval_identity, v_eval_content, v_eval_practice, v_eval_ai, public;