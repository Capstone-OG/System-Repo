-- =====================================================================
-- V-ACT PLATFORM — DATABASE SCHEMA V2 (PostgreSQL)
-- Đồng bộ 100% với PlantUML ERD (VACT_SCHEMA_V2_ERD)
-- Cập nhật ngày: 21/09/2026 — bổ sung Luồng Duyệt Đề Thi AI & Nuốt Tài Liệu RAG Theo Môn/Skill
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. ĐỊNH DANH & RBAC
-- ---------------------------------------------------------------------
CREATE TABLE "Campuses" (
  "campus_id" uuid PRIMARY KEY,
  "name" varchar NOT NULL,
  "address" varchar,
  "phone" varchar,
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "Roles" (
  "role_id" uuid PRIMARY KEY,
  "role_name" varchar UNIQUE NOT NULL
);

CREATE TABLE "Users" (
  "user_id" uuid PRIMARY KEY,
  "email" varchar UNIQUE NOT NULL,
  "password_hash" varchar NOT NULL,
  "full_name" varchar NOT NULL,
  "phone" varchar,
  "avatar_url" varchar,
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "UserRoles" (
  "user_id" uuid NOT NULL,
  "role_id" uuid NOT NULL,
  PRIMARY KEY ("user_id", "role_id")
);

-- ---------------------------------------------------------------------
-- 2. HỒ SƠ ACTOR (1-1 với Users qua PK = FK user_id)
-- ---------------------------------------------------------------------
CREATE TABLE "Students" (
  "student_id" uuid PRIMARY KEY,
  "campus_id" uuid,
  "target_score" int,
  "exam_date" date,
  "study_hours_day" double precision,
  "school_name" varchar,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "Parents" (
  "parent_id" uuid PRIMARY KEY,
  "phone_work" varchar
);

CREATE TABLE "ParentStudentRelations" (
  "relation_id" uuid PRIMARY KEY,
  "parent_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "Teachers" (
  "teacher_id" uuid PRIMARY KEY,
  "campus_id" uuid,
  "specialty" varchar,
  "bio" text,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "AcademicManagers" (
  "manager_id" uuid PRIMARY KEY,
  "campus_id" uuid,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "AcademicDirectors" (
  "director_id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "Administrators" (
  "admin_id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT (now())
);

-- ---------------------------------------------------------------------
-- 3. KHUNG NĂNG LỰC & NGÂN HÀNG CÂU HỎI
-- ---------------------------------------------------------------------
CREATE TABLE "CompetencyDomains" (
  "domain_id" uuid PRIMARY KEY,
  "name" varchar NOT NULL,
  "description" text,
  "is_approved" boolean DEFAULT false,
  "approved_by" uuid,
  "approved_at" timestamp
);

CREATE TABLE "Skills" (
  "skill_id" uuid PRIMARY KEY,
  "domain_id" uuid NOT NULL,
  "name" varchar NOT NULL,
  "parent_id" uuid,
  "weight" double precision DEFAULT 1.0,
  "is_approved" boolean DEFAULT false,
  "approved_by" uuid,
  "approved_at" timestamp,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "Materials" (
  "material_id" uuid PRIMARY KEY,
  "skill_id" uuid NOT NULL,
  "title" varchar NOT NULL,
  "content" text,
  "video_url" varchar,
  "file_url" varchar,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "Passages" (
  "passage_id" uuid PRIMARY KEY,
  "title" varchar,
  "content" text NOT NULL,
  "image_url" varchar
);

CREATE TABLE "Questions" (
  "question_id" uuid PRIMARY KEY,
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

-- ---------------------------------------------------------------------
-- 4. THI THỬ
-- ---------------------------------------------------------------------
CREATE TABLE "MockExams" (
  "exam_id" uuid PRIMARY KEY,
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

CREATE TABLE "ExamQuestions" (
  "exam_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "question_order" int NOT NULL,
  PRIMARY KEY ("exam_id", "question_id")
);

-- ---------------------------------------------------------------------
-- 5. LỚP HỌC & LIVE
-- ---------------------------------------------------------------------
CREATE TABLE "Classes" (
  "class_id" uuid PRIMARY KEY,
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

CREATE TABLE "ClassEnrollments" (
  "enrollment_id" uuid PRIMARY KEY,
  "class_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "diagnostic_submission_id" uuid,
  "approved_by" uuid,
  "status" varchar DEFAULT 'ENROLLED',
  "enrolled_at" timestamp DEFAULT (now())
);

CREATE TABLE "LiveSessions" (
  "session_id" uuid PRIMARY KEY,
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

CREATE TABLE "LiveSessionAttendance" (
  "attendance_id" uuid PRIMARY KEY,
  "session_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "joined_at" timestamp,
  "left_at" timestamp
);

CREATE TABLE "TeacherFeedback" (
  "feedback_id" uuid PRIMARY KEY,
  "teacher_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "class_id" uuid,
  "content" text NOT NULL,
  "created_at" timestamp DEFAULT (now())
);

-- ---------------------------------------------------------------------
-- 6. HỌC TẬP CÁ NHÂN HÓA
-- ---------------------------------------------------------------------
CREATE TABLE "LearningProfiles" (
  "profile_id" uuid PRIMARY KEY,
  "student_id" uuid NOT NULL,
  "skill_id" uuid NOT NULL,
  "mastery_score" double precision DEFAULT 0.0,
  "last_updated" timestamp DEFAULT (now())
);

CREATE TABLE "LearningRoadmaps" (
  "roadmap_id" uuid PRIMARY KEY,
  "student_id" uuid NOT NULL,
  "created_at" timestamp DEFAULT (now()),
  "updated_at" timestamp DEFAULT (now())
);

CREATE TABLE "RoadmapNodes" (
  "node_id" uuid PRIMARY KEY,
  "roadmap_id" uuid NOT NULL,
  "skill_id" uuid NOT NULL,
  "step_order" int NOT NULL,
  "status" varchar DEFAULT 'LOCKED',
  "completed_at" timestamp
);

CREATE TABLE "AttemptLogs" (
  "attempt_id" uuid PRIMARY KEY,
  "student_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "selected_option" char(1),
  "is_correct" boolean NOT NULL,
  "time_spent" int,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "ExamSubmissions" (
  "submission_id" uuid PRIMARY KEY,
  "student_id" uuid NOT NULL,
  "exam_id" uuid NOT NULL,
  "total_score" int,
  "started_at" timestamp DEFAULT (now()),
  "completed_at" timestamp,
  "status" varchar DEFAULT 'DOING'
);

CREATE TABLE "SubmissionAnswers" (
  "answer_id" uuid PRIMARY KEY,
  "submission_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "selected_option" char(1),
  "is_correct" boolean NOT NULL,
  "time_spent" int
);

-- ---------------------------------------------------------------------
-- 7. AI TUTOR & RAG
-- ---------------------------------------------------------------------
CREATE TABLE "KnowledgeSources" (
  "source_id" uuid PRIMARY KEY,
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

CREATE TABLE "AITutorSessions" (
  "session_id" uuid PRIMARY KEY,
  "student_id" uuid NOT NULL,
  "question_id" uuid,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "AITutorMessages" (
  "message_id" uuid PRIMARY KEY,
  "session_id" uuid NOT NULL,
  "role" varchar NOT NULL,
  "content" text NOT NULL,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "ScorePredictions" (
  "prediction_id" uuid PRIMARY KEY,
  "student_id" uuid NOT NULL,
  "predicted_score" int,
  "predicted_score_min" int,
  "predicted_score_max" int,
  "confidence_rate" double precision,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "TokenUsageLogs" (
  "log_id" uuid PRIMARY KEY,
  "service_name" varchar NOT NULL,
  "related_session_id" uuid,
  "tokens_used" int DEFAULT 0,
  "cost_usd" double precision DEFAULT 0.0,
  "created_at" timestamp DEFAULT (now())
);

-- ---------------------------------------------------------------------
-- 8. CẢNH BÁO
-- ---------------------------------------------------------------------
CREATE TABLE "SystemAlerts" (
  "alert_id" uuid PRIMARY KEY,
  "student_id" uuid NOT NULL,
  "alert_type" varchar NOT NULL,
  "message" text NOT NULL,
  "is_read" boolean DEFAULT false,
  "handled_by" uuid,
  "resolution_notes" text,
  "resolved_at" timestamp,
  "created_at" timestamp DEFAULT (now())
);

-- ---------------------------------------------------------------------
-- 9. VẬN HÀNH HỆ THỐNG
-- ---------------------------------------------------------------------
CREATE TABLE "SystemConfigs" (
  "config_id" uuid PRIMARY KEY,
  "config_key" varchar UNIQUE NOT NULL,
  "config_value" varchar,
  "description" text,
  "updated_by" uuid,
  "updated_at" timestamp DEFAULT (now())
);

-- ---------------------------------------------------------------------
-- 10. ABILITY GROUP — GOM NHÓM NĂNG LỰC (Cluster-then-Classify)
-- Chỉ lưu KẾT QUẢ (state) sau khi phân cụm/phân loại ở tầng ứng dụng/ML
-- service (K-Means chạy định kỳ, KNN classify real-time). Không lưu
-- quy trình/tham số thuật toán trong ERD.
-- ---------------------------------------------------------------------
CREATE TABLE "AbilityGroups" (
  "group_id" uuid PRIMARY KEY,
  "domain_id" uuid NOT NULL,
  "skill_id" uuid,
  "group_label" varchar NOT NULL,
  "description" text,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "StudentGroupMemberships" (
  "membership_id" uuid PRIMARY KEY,
  "student_id" uuid NOT NULL,
  "group_id" uuid NOT NULL,
  "assigned_at" timestamp DEFAULT (now()),
  "is_current" boolean DEFAULT true
);

-- =====================================================================
-- FOREIGN KEY CONSTRAINTS
-- =====================================================================

-- RBAC & Actors
ALTER TABLE "UserRoles" ADD FOREIGN KEY ("user_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "UserRoles" ADD FOREIGN KEY ("role_id") REFERENCES "Roles" ("role_id");

ALTER TABLE "Students" ADD FOREIGN KEY ("student_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "Students" ADD FOREIGN KEY ("campus_id") REFERENCES "Campuses" ("campus_id");

ALTER TABLE "Parents" ADD FOREIGN KEY ("parent_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "ParentStudentRelations" ADD FOREIGN KEY ("parent_id") REFERENCES "Parents" ("parent_id");
ALTER TABLE "ParentStudentRelations" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id");

ALTER TABLE "Teachers" ADD FOREIGN KEY ("teacher_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "Teachers" ADD FOREIGN KEY ("campus_id") REFERENCES "Campuses" ("campus_id");

ALTER TABLE "AcademicManagers" ADD FOREIGN KEY ("manager_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "AcademicManagers" ADD FOREIGN KEY ("campus_id") REFERENCES "Campuses" ("campus_id");

ALTER TABLE "AcademicDirectors" ADD FOREIGN KEY ("director_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "Administrators" ADD FOREIGN KEY ("admin_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;

-- Khung Năng Lực & Câu Hỏi
ALTER TABLE "CompetencyDomains" ADD FOREIGN KEY ("approved_by") REFERENCES "AcademicDirectors" ("director_id");
ALTER TABLE "Skills" ADD FOREIGN KEY ("domain_id") REFERENCES "CompetencyDomains" ("domain_id");
ALTER TABLE "Skills" ADD FOREIGN KEY ("parent_id") REFERENCES "Skills" ("skill_id");
ALTER TABLE "Skills" ADD FOREIGN KEY ("approved_by") REFERENCES "AcademicDirectors" ("director_id");
ALTER TABLE "Materials" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id");
ALTER TABLE "Questions" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id");
ALTER TABLE "Questions" ADD FOREIGN KEY ("passage_id") REFERENCES "Passages" ("passage_id");
ALTER TABLE "Questions" ADD FOREIGN KEY ("reviewed_by") REFERENCES "Teachers" ("teacher_id");

-- Thi Thử
ALTER TABLE "MockExams" ADD FOREIGN KEY ("campus_id") REFERENCES "Campuses" ("campus_id");
ALTER TABLE "MockExams" ADD FOREIGN KEY ("domain_id") REFERENCES "CompetencyDomains" ("domain_id");
ALTER TABLE "MockExams" ADD FOREIGN KEY ("created_by") REFERENCES "Users" ("user_id");
ALTER TABLE "MockExams" ADD FOREIGN KEY ("approved_by") REFERENCES "Users" ("user_id");
ALTER TABLE "ExamQuestions" ADD FOREIGN KEY ("exam_id") REFERENCES "MockExams" ("exam_id") ON DELETE CASCADE;
ALTER TABLE "ExamQuestions" ADD FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id");

-- Lớp Học & Live
ALTER TABLE "Classes" ADD FOREIGN KEY ("campus_id") REFERENCES "Campuses" ("campus_id");
ALTER TABLE "Classes" ADD FOREIGN KEY ("teacher_id") REFERENCES "Teachers" ("teacher_id");
ALTER TABLE "Classes" ADD FOREIGN KEY ("assigned_by") REFERENCES "AcademicManagers" ("manager_id");
ALTER TABLE "ClassEnrollments" ADD FOREIGN KEY ("class_id") REFERENCES "Classes" ("class_id");
ALTER TABLE "ClassEnrollments" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id");
ALTER TABLE "ClassEnrollments" ADD FOREIGN KEY ("diagnostic_submission_id") REFERENCES "ExamSubmissions" ("submission_id");
ALTER TABLE "ClassEnrollments" ADD FOREIGN KEY ("approved_by") REFERENCES "AcademicManagers" ("manager_id");
ALTER TABLE "LiveSessions" ADD FOREIGN KEY ("class_id") REFERENCES "Classes" ("class_id");
ALTER TABLE "LiveSessions" ADD FOREIGN KEY ("teacher_id") REFERENCES "Teachers" ("teacher_id");
ALTER TABLE "LiveSessionAttendance" ADD FOREIGN KEY ("session_id") REFERENCES "LiveSessions" ("session_id");
ALTER TABLE "LiveSessionAttendance" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id");
ALTER TABLE "TeacherFeedback" ADD FOREIGN KEY ("teacher_id") REFERENCES "Teachers" ("teacher_id");
ALTER TABLE "TeacherFeedback" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id");
ALTER TABLE "TeacherFeedback" ADD FOREIGN KEY ("class_id") REFERENCES "Classes" ("class_id");

-- Học Tập Cá Nhân Hóa
ALTER TABLE "LearningProfiles" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id");
ALTER TABLE "LearningProfiles" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id");
ALTER TABLE "LearningRoadmaps" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id");
ALTER TABLE "RoadmapNodes" ADD FOREIGN KEY ("roadmap_id") REFERENCES "LearningRoadmaps" ("roadmap_id") ON DELETE CASCADE;
ALTER TABLE "RoadmapNodes" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id");
ALTER TABLE "AttemptLogs" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id");
ALTER TABLE "AttemptLogs" ADD FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id");
ALTER TABLE "ExamSubmissions" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id");
ALTER TABLE "ExamSubmissions" ADD FOREIGN KEY ("exam_id") REFERENCES "MockExams" ("exam_id");
ALTER TABLE "SubmissionAnswers" ADD FOREIGN KEY ("submission_id") REFERENCES "ExamSubmissions" ("submission_id") ON DELETE CASCADE;
ALTER TABLE "SubmissionAnswers" ADD FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id");

-- AI Tutor & RAG
ALTER TABLE "KnowledgeSources" ADD FOREIGN KEY ("uploaded_by") REFERENCES "AcademicDirectors" ("director_id");
ALTER TABLE "KnowledgeSources" ADD FOREIGN KEY ("domain_id") REFERENCES "CompetencyDomains" ("domain_id");
ALTER TABLE "KnowledgeSources" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id");
ALTER TABLE "AITutorSessions" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id");
ALTER TABLE "AITutorSessions" ADD FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id");
ALTER TABLE "AITutorMessages" ADD FOREIGN KEY ("session_id") REFERENCES "AITutorSessions" ("session_id") ON DELETE CASCADE;
ALTER TABLE "ScorePredictions" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id");
ALTER TABLE "TokenUsageLogs" ADD FOREIGN KEY ("related_session_id") REFERENCES "AITutorSessions" ("session_id");

-- Cảnh Báo & Vận Hành
ALTER TABLE "SystemAlerts" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id");
ALTER TABLE "SystemAlerts" ADD FOREIGN KEY ("handled_by") REFERENCES "AcademicManagers" ("manager_id");
ALTER TABLE "SystemConfigs" ADD FOREIGN KEY ("updated_by") REFERENCES "Users" ("user_id");

-- Ability Group (Nhóm 10 — mới bổ sung)
ALTER TABLE "AbilityGroups" ADD FOREIGN KEY ("domain_id") REFERENCES "CompetencyDomains" ("domain_id");
ALTER TABLE "AbilityGroups" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id");
ALTER TABLE "StudentGroupMemberships" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "StudentGroupMemberships" ADD FOREIGN KEY ("group_id") REFERENCES "AbilityGroups" ("group_id") ON DELETE CASCADE;

-- =====================================================================
-- INDEXES (hỗ trợ truy vấn thường dùng của Ability Group & Duyệt Đề AI/RAG)
-- =====================================================================
CREATE INDEX "idx_sgm_student_current" ON "StudentGroupMemberships" ("student_id", "is_current");
CREATE INDEX "idx_ability_groups_domain" ON "AbilityGroups" ("domain_id");
CREATE INDEX "idx_mock_exams_approval" ON "MockExams" ("approval_status", "domain_id");
CREATE INDEX "idx_knowledge_sources_domain_skill" ON "KnowledgeSources" ("domain_id", "skill_id");