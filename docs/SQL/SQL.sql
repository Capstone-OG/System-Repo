-- =====================================================================
-- V-EVAL PLATFORM — SYSTEM DATABASE MIGRATION SCRIPT (PostgreSQL / Supabase)
-- Phiên bản: Schema V2 (Non-Destructive & Idempotent Migration)
-- Cập nhật ngày: 23/09/2026 — Phân chia 5 Schemas chuẩn Microservices (v_eval_*)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. TẠO EXTENSION VÀ CÁC SCHEMAS CHO CÁC MICROSERVICES
-- ---------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS vector;

CREATE SCHEMA IF NOT EXISTS "v_eval_identity";
CREATE SCHEMA IF NOT EXISTS "v_eval_content";
CREATE SCHEMA IF NOT EXISTS "v_eval_practice";
CREATE SCHEMA IF NOT EXISTS "v_eval_ai";
CREATE SCHEMA IF NOT EXISTS "v_eval_system";

-- ---------------------------------------------------------------------
-- 1. SCHEMA: v_eval_identity (V-Eval Identity Service)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "v_eval_identity"."Campuses" (
  "campus_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" varchar NOT NULL,
  "address" varchar,
  "phone" varchar,
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."Roles" (
  "role_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "role_name" varchar UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."Users" (
  "user_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "email" varchar UNIQUE NOT NULL,
  "password_hash" varchar NOT NULL,
  "full_name" varchar NOT NULL,
  "phone" varchar,
  "avatar_url" varchar,
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."UserRoles" (
  "user_id" uuid NOT NULL,
  "role_id" uuid NOT NULL,
  PRIMARY KEY ("user_id", "role_id")
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."Students" (
  "student_id" uuid PRIMARY KEY,
  "campus_id" uuid,
  "target_score" int,
  "exam_date" date,
  "study_hours_day" double precision,
  "school_name" varchar,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."Parents" (
  "parent_id" uuid PRIMARY KEY,
  "phone_work" varchar
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."ParentStudentRelations" (
  "relation_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "parent_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."Teachers" (
  "teacher_id" uuid PRIMARY KEY,
  "campus_id" uuid,
  "specialty" varchar,
  "bio" text,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."AcademicManagers" (
  "manager_id" uuid PRIMARY KEY,
  "campus_id" uuid,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."AcademicDirectors" (
  "director_id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."Administrators" (
  "admin_id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."RefreshTokens" (
  "token_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "token" varchar NOT NULL,
  "expires_at" timestamp NOT NULL,
  "is_revoked" boolean DEFAULT false,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_identity"."OtpVerifications" (
  "otp_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "email" varchar NOT NULL,
  "otp_code" varchar NOT NULL,
  "expires_at" timestamp NOT NULL,
  "is_used" boolean DEFAULT false,
  "created_at" timestamp DEFAULT (now())
);

-- ---------------------------------------------------------------------
-- 2. SCHEMA: v_eval_content (V-Eval Content Service)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "v_eval_content"."CompetencyDomains" (
  "domain_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" varchar NOT NULL,
  "description" text,
  "is_approved" boolean DEFAULT false,
  "approved_by" uuid,
  "approved_at" timestamp
);

CREATE TABLE IF NOT EXISTS "v_eval_content"."Skills" (
  "skill_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "domain_id" uuid NOT NULL,
  "name" varchar NOT NULL,
  "parent_id" uuid,
  "weight" double precision DEFAULT 1.0,
  "is_approved" boolean DEFAULT false,
  "approved_by" uuid,
  "approved_at" timestamp,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_content"."Materials" (
  "material_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "skill_id" uuid NOT NULL,
  "title" varchar NOT NULL,
  "content" text,
  "video_url" varchar,
  "file_url" varchar,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_content"."Passages" (
  "passage_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "title" varchar,
  "content" text NOT NULL,
  "image_url" varchar
);

CREATE TABLE IF NOT EXISTS "v_eval_content"."Questions" (
  "question_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "skill_id" uuid NOT NULL,
  "passage_id" uuid,
  "difficulty_level" int DEFAULT 1,
  "content_latex" text NOT NULL,
  "option_a" text NOT NULL,
  "option_b" text NOT NULL,
  "option_c" text NOT NULL,
  "option_d" text NOT NULL,
  "correct_option" char(1) NOT NULL,
  "explanation" text,
  "is_ai_generated" boolean DEFAULT false,
  "moderation_status" varchar DEFAULT 'PENDING',
  "reviewed_by" uuid,
  "reviewed_at" timestamp,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_content"."MockExams" (
  "exam_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "campus_id" uuid,
  "domain_id" uuid,
  "title" varchar NOT NULL,
  "exam_type" varchar,
  "duration_minutes" int DEFAULT 150,
  "total_questions" int DEFAULT 120,
  "scheduled_at" timestamp,
  "is_published" boolean DEFAULT false,
  "is_ai_generated" boolean DEFAULT false,
  "approval_status" varchar DEFAULT 'APPROVED',
  "approved_by" uuid,
  "approved_at" timestamp,
  "rejection_reason" text,
  "created_by" uuid,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_content"."ExamQuestions" (
  "exam_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "question_order" int NOT NULL,
  PRIMARY KEY ("exam_id", "question_id")
);

-- ---------------------------------------------------------------------
-- 3. SCHEMA: v_eval_practice (V-Eval Practice Service)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "v_eval_practice"."Classes" (
  "class_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "campus_id" uuid NOT NULL,
  "teacher_id" uuid NOT NULL,
  "assigned_by" uuid,
  "name" varchar NOT NULL,
  "start_date" date,
  "end_date" date,
  "status" varchar DEFAULT 'ACTIVE',
  "assigned_at" timestamp,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."ClassEnrollments" (
  "enrollment_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "class_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "diagnostic_submission_id" uuid,
  "approved_by" uuid,
  "status" varchar DEFAULT 'ENROLLED',
  "enrolled_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."LiveSessions" (
  "session_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "class_id" uuid NOT NULL,
  "teacher_id" uuid NOT NULL,
  "title" varchar NOT NULL,
  "description" text,
  "scheduled_at" timestamp NOT NULL,
  "duration_minutes" int DEFAULT 60,
  "meeting_url" varchar,
  "status" varchar DEFAULT 'SCHEDULED',
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."LiveSessionAttendance" (
  "attendance_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "session_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "joined_at" timestamp,
  "left_at" timestamp
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."TeacherFeedback" (
  "feedback_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "teacher_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "class_id" uuid,
  "content" text NOT NULL,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."LearningProfiles" (
  "profile_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "skill_id" uuid NOT NULL,
  "mastery_score" double precision DEFAULT 0.0,
  "last_updated" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."LearningRoadmaps" (
  "roadmap_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."RoadmapNodes" (
  "node_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "roadmap_id" uuid NOT NULL,
  "skill_id" uuid NOT NULL,
  "step_order" int NOT NULL,
  "status" varchar DEFAULT 'LOCKED',
  "completed_at" timestamp
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."AttemptLogs" (
  "attempt_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "selected_option" char(1),
  "is_correct" boolean NOT NULL,
  "time_spent" int,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."ExamSubmissions" (
  "submission_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "exam_id" uuid NOT NULL,
  "exam_type" varchar(50) DEFAULT 'MOCK_EXAM',
  "total_score" int,
  "total_correct" int,
  "total_questions" int,
  "total_time_spent_seconds" int,
  "started_at" timestamp DEFAULT (now()),
  "completed_at" timestamp,
  "status" varchar DEFAULT 'DOING'
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."SubmissionAnswers" (
  "answer_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "submission_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "selected_option" char(1),
  "is_correct" boolean NOT NULL,
  "time_spent" int
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."AbilityGroups" (
  "group_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "domain_id" uuid NOT NULL,
  "skill_id" uuid,
  "group_label" varchar NOT NULL,
  "description" text,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_practice"."StudentGroupMemberships" (
  "membership_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "group_id" uuid NOT NULL,
  "assigned_at" timestamp DEFAULT (now()),
  "is_current" boolean DEFAULT true
);

-- ---------------------------------------------------------------------
-- 4. SCHEMA: v_eval_ai (V-Eval AI Engine & RAG Service)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "v_eval_ai"."KnowledgeSources" (
  "source_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "domain_id" uuid,
  "skill_id" uuid,
  "title" varchar NOT NULL,
  "content" text,
  "file_url" varchar,
  "uploaded_by" uuid,
  "document_type" varchar DEFAULT 'GENERAL_KNOWLEDGE',
  "description" text,
  "vector_status" varchar DEFAULT 'PENDING',
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_ai"."KnowledgeVectorChunks" (
  "chunk_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "source_id" uuid NOT NULL,
  "domain_id" uuid,
  "skill_id" uuid,
  "content_snippet" text NOT NULL,
  "embedding" vector(768),
  "chunk_type" varchar DEFAULT 'THEORY',
  "metadata" jsonb,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_ai"."AITutorSessions" (
  "session_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "question_id" uuid,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_ai"."AITutorMessages" (
  "message_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "session_id" uuid NOT NULL,
  "role" varchar NOT NULL,
  "content" text NOT NULL,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_ai"."ScorePredictions" (
  "prediction_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "predicted_score" int,
  "predicted_score_min" int,
  "predicted_score_max" int,
  "confidence_rate" double precision,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_ai"."TokenUsageLogs" (
  "log_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "service_name" varchar NOT NULL,
  "related_session_id" uuid,
  "tokens_used" int DEFAULT 0,
  "cost_usd" double precision DEFAULT 0.0,
  "created_at" timestamp DEFAULT (now())
);

-- ---------------------------------------------------------------------
-- 5. SCHEMA: v_eval_system (V-Eval System Operations & Alerts)
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "v_eval_system"."SystemAlerts" (
  "alert_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "alert_type" varchar NOT NULL,
  "message" text NOT NULL,
  "is_read" boolean DEFAULT false,
  "handled_by" uuid,
  "resolution_notes" text,
  "resolved_at" timestamp,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE IF NOT EXISTS "v_eval_system"."SystemConfigs" (
  "config_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "config_key" varchar UNIQUE NOT NULL,
  "config_value" varchar,
  "description" text,
  "updated_by" uuid,
  "updated_at" timestamp DEFAULT (now())
);

-- ---------------------------------------------------------------------
-- 6. FOREIGN KEY CONSTRAINTS (LIÊN KẾT GIỮA CÁC SCHEMAS)
-- ---------------------------------------------------------------------

-- v_eval_identity
ALTER TABLE "v_eval_identity"."UserRoles" ADD FOREIGN KEY ("user_id") REFERENCES "v_eval_identity"."Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_identity"."UserRoles" ADD FOREIGN KEY ("role_id") REFERENCES "v_eval_identity"."Roles" ("role_id");

ALTER TABLE "v_eval_identity"."Students" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_identity"."Students" ADD FOREIGN KEY ("campus_id") REFERENCES "v_eval_identity"."Campuses" ("campus_id");

ALTER TABLE "v_eval_identity"."Parents" ADD FOREIGN KEY ("parent_id") REFERENCES "v_eval_identity"."Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_identity"."ParentStudentRelations" ADD FOREIGN KEY ("parent_id") REFERENCES "v_eval_identity"."Parents" ("parent_id");
ALTER TABLE "v_eval_identity"."ParentStudentRelations" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id");

ALTER TABLE "v_eval_identity"."Teachers" ADD FOREIGN KEY ("teacher_id") REFERENCES "v_eval_identity"."Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_identity"."Teachers" ADD FOREIGN KEY ("campus_id") REFERENCES "v_eval_identity"."Campuses" ("campus_id");

ALTER TABLE "v_eval_identity"."AcademicManagers" ADD FOREIGN KEY ("manager_id") REFERENCES "v_eval_identity"."Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_identity"."AcademicManagers" ADD FOREIGN KEY ("campus_id") REFERENCES "v_eval_identity"."Campuses" ("campus_id");

ALTER TABLE "v_eval_identity"."AcademicDirectors" ADD FOREIGN KEY ("director_id") REFERENCES "v_eval_identity"."Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_identity"."Administrators" ADD FOREIGN KEY ("admin_id") REFERENCES "v_eval_identity"."Users" ("user_id") ON DELETE CASCADE;

-- v_eval_content
ALTER TABLE "v_eval_content"."CompetencyDomains" ADD FOREIGN KEY ("approved_by") REFERENCES "v_eval_identity"."AcademicDirectors" ("director_id");
ALTER TABLE "v_eval_content"."Skills" ADD FOREIGN KEY ("domain_id") REFERENCES "v_eval_content"."CompetencyDomains" ("domain_id");
ALTER TABLE "v_eval_content"."Skills" ADD FOREIGN KEY ("parent_id") REFERENCES "v_eval_content"."Skills" ("skill_id");
ALTER TABLE "v_eval_content"."Skills" ADD FOREIGN KEY ("approved_by") REFERENCES "v_eval_identity"."AcademicDirectors" ("director_id");
ALTER TABLE "v_eval_content"."Materials" ADD FOREIGN KEY ("skill_id") REFERENCES "v_eval_content"."Skills" ("skill_id");
ALTER TABLE "v_eval_content"."Questions" ADD FOREIGN KEY ("skill_id") REFERENCES "v_eval_content"."Skills" ("skill_id");
ALTER TABLE "v_eval_content"."Questions" ADD FOREIGN KEY ("passage_id") REFERENCES "v_eval_content"."Passages" ("passage_id");
ALTER TABLE "v_eval_content"."Questions" ADD FOREIGN KEY ("reviewed_by") REFERENCES "v_eval_identity"."Teachers" ("teacher_id");

ALTER TABLE "v_eval_content"."MockExams" ADD FOREIGN KEY ("campus_id") REFERENCES "v_eval_identity"."Campuses" ("campus_id");
ALTER TABLE "v_eval_content"."MockExams" ADD FOREIGN KEY ("domain_id") REFERENCES "v_eval_content"."CompetencyDomains" ("domain_id");
ALTER TABLE "v_eval_content"."MockExams" ADD FOREIGN KEY ("created_by") REFERENCES "v_eval_identity"."Users" ("user_id");
ALTER TABLE "v_eval_content"."MockExams" ADD FOREIGN KEY ("approved_by") REFERENCES "v_eval_identity"."Users" ("user_id");
ALTER TABLE "v_eval_content"."ExamQuestions" ADD FOREIGN KEY ("exam_id") REFERENCES "v_eval_content"."MockExams" ("exam_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_content"."ExamQuestions" ADD FOREIGN KEY ("question_id") REFERENCES "v_eval_content"."Questions" ("question_id");

-- v_eval_practice
ALTER TABLE "v_eval_practice"."Classes" ADD FOREIGN KEY ("campus_id") REFERENCES "v_eval_identity"."Campuses" ("campus_id");
ALTER TABLE "v_eval_practice"."Classes" ADD FOREIGN KEY ("teacher_id") REFERENCES "v_eval_identity"."Teachers" ("teacher_id");
ALTER TABLE "v_eval_practice"."Classes" ADD FOREIGN KEY ("assigned_by") REFERENCES "v_eval_identity"."AcademicManagers" ("manager_id");
ALTER TABLE "v_eval_practice"."ClassEnrollments" ADD FOREIGN KEY ("class_id") REFERENCES "v_eval_practice"."Classes" ("class_id");
ALTER TABLE "v_eval_practice"."ClassEnrollments" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id");
ALTER TABLE "v_eval_practice"."ClassEnrollments" ADD FOREIGN KEY ("approved_by") REFERENCES "v_eval_identity"."AcademicManagers" ("manager_id");
ALTER TABLE "v_eval_practice"."LiveSessions" ADD FOREIGN KEY ("class_id") REFERENCES "v_eval_practice"."Classes" ("class_id");
ALTER TABLE "v_eval_practice"."LiveSessions" ADD FOREIGN KEY ("teacher_id") REFERENCES "v_eval_identity"."Teachers" ("teacher_id");
ALTER TABLE "v_eval_practice"."LiveSessionAttendance" ADD FOREIGN KEY ("session_id") REFERENCES "v_eval_practice"."LiveSessions" ("session_id");
ALTER TABLE "v_eval_practice"."LiveSessionAttendance" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id");
ALTER TABLE "v_eval_practice"."TeacherFeedback" ADD FOREIGN KEY ("teacher_id") REFERENCES "v_eval_identity"."Teachers" ("teacher_id");
ALTER TABLE "v_eval_practice"."TeacherFeedback" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id");
ALTER TABLE "v_eval_practice"."TeacherFeedback" ADD FOREIGN KEY ("class_id") REFERENCES "v_eval_practice"."Classes" ("class_id");

ALTER TABLE "v_eval_practice"."LearningProfiles" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id");
ALTER TABLE "v_eval_practice"."LearningProfiles" ADD FOREIGN KEY ("skill_id") REFERENCES "v_eval_content"."Skills" ("skill_id");
ALTER TABLE "v_eval_practice"."LearningRoadmaps" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id");
ALTER TABLE "v_eval_practice"."RoadmapNodes" ADD FOREIGN KEY ("roadmap_id") REFERENCES "v_eval_practice"."LearningRoadmaps" ("roadmap_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_practice"."RoadmapNodes" ADD FOREIGN KEY ("skill_id") REFERENCES "v_eval_content"."Skills" ("skill_id");
ALTER TABLE "v_eval_practice"."AttemptLogs" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id");
ALTER TABLE "v_eval_practice"."AttemptLogs" ADD FOREIGN KEY ("question_id") REFERENCES "v_eval_content"."Questions" ("question_id");
ALTER TABLE "v_eval_practice"."ExamSubmissions" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id");
ALTER TABLE "v_eval_practice"."ExamSubmissions" ADD FOREIGN KEY ("exam_id") REFERENCES "v_eval_content"."MockExams" ("exam_id");
ALTER TABLE "v_eval_practice"."SubmissionAnswers" ADD FOREIGN KEY ("submission_id") REFERENCES "v_eval_practice"."ExamSubmissions" ("submission_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_practice"."SubmissionAnswers" ADD FOREIGN KEY ("question_id") REFERENCES "v_eval_content"."Questions" ("question_id");

ALTER TABLE "v_eval_practice"."AbilityGroups" ADD FOREIGN KEY ("domain_id") REFERENCES "v_eval_content"."CompetencyDomains" ("domain_id");
ALTER TABLE "v_eval_practice"."AbilityGroups" ADD FOREIGN KEY ("skill_id") REFERENCES "v_eval_content"."Skills" ("skill_id");
ALTER TABLE "v_eval_practice"."StudentGroupMemberships" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_practice"."StudentGroupMemberships" ADD FOREIGN KEY ("group_id") REFERENCES "v_eval_practice"."AbilityGroups" ("group_id") ON DELETE CASCADE;

-- v_eval_ai
ALTER TABLE "v_eval_ai"."KnowledgeSources" ADD FOREIGN KEY ("uploaded_by") REFERENCES "v_eval_identity"."AcademicDirectors" ("director_id");
ALTER TABLE "v_eval_ai"."KnowledgeSources" ADD FOREIGN KEY ("domain_id") REFERENCES "v_eval_content"."CompetencyDomains" ("domain_id");
ALTER TABLE "v_eval_ai"."KnowledgeSources" ADD FOREIGN KEY ("skill_id") REFERENCES "v_eval_content"."Skills" ("skill_id");
ALTER TABLE "v_eval_ai"."KnowledgeVectorChunks" ADD FOREIGN KEY ("source_id") REFERENCES "v_eval_ai"."KnowledgeSources" ("source_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_ai"."KnowledgeVectorChunks" ADD FOREIGN KEY ("domain_id") REFERENCES "v_eval_content"."CompetencyDomains" ("domain_id");
ALTER TABLE "v_eval_ai"."KnowledgeVectorChunks" ADD FOREIGN KEY ("skill_id") REFERENCES "v_eval_content"."Skills" ("skill_id");
ALTER TABLE "v_eval_ai"."AITutorSessions" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id");
ALTER TABLE "v_eval_ai"."AITutorSessions" ADD FOREIGN KEY ("question_id") REFERENCES "v_eval_content"."Questions" ("question_id");
ALTER TABLE "v_eval_ai"."AITutorMessages" ADD FOREIGN KEY ("session_id") REFERENCES "v_eval_ai"."AITutorSessions" ("session_id") ON DELETE CASCADE;
ALTER TABLE "v_eval_ai"."ScorePredictions" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id");
ALTER TABLE "v_eval_ai"."TokenUsageLogs" ADD FOREIGN KEY ("related_session_id") REFERENCES "v_eval_ai"."AITutorSessions" ("session_id");

-- v_eval_system
ALTER TABLE "v_eval_system"."SystemAlerts" ADD FOREIGN KEY ("student_id") REFERENCES "v_eval_identity"."Students" ("student_id");
ALTER TABLE "v_eval_system"."SystemAlerts" ADD FOREIGN KEY ("handled_by") REFERENCES "v_eval_identity"."AcademicManagers" ("manager_id");
ALTER TABLE "v_eval_system"."SystemConfigs" ADD FOREIGN KEY ("updated_by") REFERENCES "v_eval_identity"."Users" ("user_id");

-- ---------------------------------------------------------------------
-- 7. INDEXES (HỖ TRỢ TRUY VẤN HỆ THỐNG V-EVAL)
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS "idx_sgm_student_current" ON "v_eval_practice"."StudentGroupMemberships" ("student_id", "is_current");
CREATE INDEX IF NOT EXISTS "idx_ability_groups_domain" ON "v_eval_practice"."AbilityGroups" ("domain_id");
CREATE INDEX IF NOT EXISTS "idx_mock_exams_approval" ON "v_eval_content"."MockExams" ("approval_status", "domain_id");
CREATE INDEX IF NOT EXISTS "idx_knowledge_sources_domain_skill" ON "v_eval_ai"."KnowledgeSources" ("domain_id", "skill_id");
CREATE INDEX IF NOT EXISTS "idx_vector_hnsw" ON "v_eval_ai"."KnowledgeVectorChunks" USING hnsw ("embedding" vector_cosine_ops);

-- ---------------------------------------------------------------------
-- 8. MIGRATION AN TOÀN CHO DATABASE ĐÃ CÓ BẢNG (SAFE ALTER / ADD COLUMN)
-- ---------------------------------------------------------------------
DO $$
BEGIN
  -- Safe alters for MockExams
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'v_eval_content' AND tablename = 'MockExams') THEN
    ALTER TABLE "v_eval_content"."MockExams" ADD COLUMN IF NOT EXISTS "domain_id" uuid;
    ALTER TABLE "v_eval_content"."MockExams" ADD COLUMN IF NOT EXISTS "is_ai_generated" boolean DEFAULT false;
    ALTER TABLE "v_eval_content"."MockExams" ADD COLUMN IF NOT EXISTS "approval_status" varchar(50) DEFAULT 'APPROVED';
    ALTER TABLE "v_eval_content"."MockExams" ADD COLUMN IF NOT EXISTS "approved_by" uuid;
    ALTER TABLE "v_eval_content"."MockExams" ADD COLUMN IF NOT EXISTS "approved_at" timestamp;
    ALTER TABLE "v_eval_content"."MockExams" ADD COLUMN IF NOT EXISTS "rejection_reason" text;
  END IF;

  -- Safe alters for KnowledgeSources
  IF EXISTS (SELECT FROM pg_tables WHERE schemaname = 'v_eval_ai' AND tablename = 'KnowledgeSources') THEN
    ALTER TABLE "v_eval_ai"."KnowledgeSources" ADD COLUMN IF NOT EXISTS "domain_id" uuid;
    ALTER TABLE "v_eval_ai"."KnowledgeSources" ADD COLUMN IF NOT EXISTS "skill_id" uuid;
    ALTER TABLE "v_eval_ai"."KnowledgeSources" ADD COLUMN IF NOT EXISTS "document_type" varchar(50) DEFAULT 'GENERAL_KNOWLEDGE';
    ALTER TABLE "v_eval_ai"."KnowledgeSources" ADD COLUMN IF NOT EXISTS "description" text;
  END IF;
END $$;