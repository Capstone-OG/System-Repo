-- =====================================================================
-- V-EVAL ADAPTIVE LEARNING PLATFORM — UNIFIED DATABASE SCHEMA V3
-- =====================================================================
-- Phiên bản: Schema V3.0 (PostgreSQL / Supabase / ERD Reverse-Engineering)
-- Cập nhật ngày: 16/10/2026
-- 
-- TỔNG QUAN NÂNG CẤP TỪ V2 SANG V3:
-- 1. Identity Service: Bổ sung RefreshTokens, OtpVerifications, Campus mappings.
-- 2. Content Service: Bổ sung SkillPrerequisites (DAG Graph), duration_seconds, 
--    các trường phân loại đề thi (exam_category, subject_code, difficulty_level).
-- 3. Practice Service:
--    - Mở rộng Classes (class_type phân tầng K-Means, domain_code, cluster_index).
--    - Bổ sung ClassGroups & ClassGroupMembers (Nhóm học tập vi mô 3-5 bạn).
--    - Mở rộng ExamSubmissions (giám sát thi thử proctoring, theta_0, placement_class).
--    - Bổ sung ProctoringSnapshots (ảnh chụp webcam chống gian lận).
--    - Bổ sung StageProgress & AdaptiveQuizAttempts (chu trình P-L-A-R thích ứng).
--    - Bổ sung MistakeNotebooks (sổ tay lỗi sai & ôn tập ngắt quãng SM-2).
--    - Đã lược bỏ LiveSessions & LiveSessionAttendance (do chuyển đổi mô hình học offline tại trung tâm).
-- 4. Core Flow 6 (Chuẩn bị triển khai):
--    - Mở rộng ScorePredictions (dải điểm SEM, thâm hụt deficit_score, prescription_items JSONB).
--    - Chuẩn hóa SystemAlerts (cảnh báo sớm 3 cấp BR-04, phân quyền handled_by Mentor).
-- 5. AI Engine & RAG: Bổ sung KnowledgeVectorChunks (pgvector 768 chiều), TokenUsageLogs.
-- =====================================================================

-- Bật extension mở rộng cần thiết
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "vector";

-- =====================================================================
-- 1. ĐỊNH DANH, PHÂN QUYỀN & BẢO MẬT (IAM - IDENTITY SERVICE)
-- =====================================================================

CREATE TABLE "Campuses" (
  "campus_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" varchar(255) NOT NULL,
  "address" varchar(500),
  "phone" varchar(50),
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "Roles" (
  "role_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "role_name" varchar(100) UNIQUE NOT NULL
);

CREATE TABLE "Users" (
  "user_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "email" varchar(255) UNIQUE NOT NULL,
  "password_hash" varchar(500) NOT NULL,
  "full_name" varchar(255) NOT NULL,
  "phone" varchar(50),
  "avatar_url" varchar(500),
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "UserRoles" (
  "user_id" uuid NOT NULL,
  "role_id" uuid NOT NULL,
  PRIMARY KEY ("user_id", "role_id")
);

CREATE TABLE "RefreshTokens" (
  "refresh_token_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "user_id" uuid NOT NULL,
  "token" varchar(500) NOT NULL,
  "expires_at" timestamp NOT NULL,
  "is_revoked" boolean DEFAULT false,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "OtpVerifications" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "email" varchar(255) NOT NULL,
  "otp_code" varchar(10) NOT NULL,
  "type" varchar(50) NOT NULL, -- 'REGISTER_VERIFY', 'RESET_PASSWORD'
  "expires_at" timestamp NOT NULL,
  "is_used" boolean DEFAULT false,
  "created_at" timestamp DEFAULT now()
);

-- =====================================================================
-- 2. HỒ SƠ CHỦ THỂ (ACTOR PROFILES - 1:1 VỚI USERS)
-- =====================================================================

CREATE TABLE "Students" (
  "student_id" uuid PRIMARY KEY,
  "campus_id" uuid,
  "target_score" int,
  "exam_date" date,
  "study_hours_day" double precision DEFAULT 2.0,
  "school_name" varchar(255),
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "Parents" (
  "parent_id" uuid PRIMARY KEY,
  "phone_work" varchar(50)
);

CREATE TABLE "ParentStudentRelations" (
  "relation_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "parent_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "Teachers" (
  "teacher_id" uuid PRIMARY KEY,
  "campus_id" uuid,
  "specialty" varchar(255),
  "bio" text,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "AcademicManagers" (
  "manager_id" uuid PRIMARY KEY,
  "campus_id" uuid,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "AcademicDirectors" (
  "director_id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "Administrators" (
  "admin_id" uuid PRIMARY KEY,
  "created_at" timestamp DEFAULT now()
);

-- =====================================================================
-- 3. KHUNG NĂNG LỰC & NGÂN HÀNG CÂU HỎI (CONTENT SERVICE)
-- =====================================================================

CREATE TABLE "CompetencyDomains" (
  "domain_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "name" varchar(255) NOT NULL,
  "description" text,
  "is_approved" boolean DEFAULT false,
  "approved_by" uuid,
  "approved_at" timestamp
);

CREATE TABLE "Skills" (
  "skill_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "domain_id" uuid NOT NULL,
  "name" varchar(255) NOT NULL,
  "parent_id" uuid,
  "weight" double precision DEFAULT 1.0,
  "is_approved" boolean DEFAULT false,
  "approved_by" uuid,
  "approved_at" timestamp,
  "created_at" timestamp DEFAULT now()
);

-- Cấu trúc đồ thị kỹ năng có hướng DAG (Skill Dependency Graph)
CREATE TABLE "SkillPrerequisites" (
  "skill_id" uuid NOT NULL,
  "prerequisite_id" uuid NOT NULL,
  PRIMARY KEY ("skill_id", "prerequisite_id")
);

CREATE TABLE "Materials" (
  "material_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "skill_id" uuid NOT NULL,
  "title" varchar(255) NOT NULL,
  "content" text NOT NULL,
  "video_url" varchar(500),
  "file_url" varchar(500),
  "duration_seconds" int DEFAULT 0,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "Passages" (
  "passage_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "title" varchar(255),
  "content" text NOT NULL,
  "image_url" varchar(500)
);

CREATE TABLE "Questions" (
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
  "moderation_status" varchar(50) DEFAULT 'PENDING',
  "reviewed_by" uuid,
  "reviewed_at" timestamp,
  "created_at" timestamp DEFAULT now()
);

-- =====================================================================
-- 4. ĐỀ THI & THI THỬ (MOCK EXAMS - CONTENT SERVICE)
-- =====================================================================

CREATE TABLE "MockExams" (
  "exam_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "campus_id" uuid,
  "title" varchar(255) NOT NULL,
  "exam_type" varchar(50),
  "exam_category" varchar(50) DEFAULT 'FULL_MOCK', -- 'DIAGNOSTIC', 'FULL_MOCK', 'MINI_TEST', 'THEMATIC'
  "subject_code" varchar(50),
  "difficulty_level" int,
  "duration_minutes" int DEFAULT 150,
  "total_questions" int DEFAULT 120,
  "scheduled_at" timestamp,
  "is_published" boolean DEFAULT false,
  "created_by" uuid,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "ExamQuestions" (
  "exam_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "question_order" int NOT NULL,
  PRIMARY KEY ("exam_id", "question_id")
);

-- =====================================================================
-- 5. LỚP HỌC & NHÓM HỌC TẬP VI MÔ (PRACTICE SERVICE)
-- =====================================================================

CREATE TABLE "Classes" (
  "class_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "campus_id" uuid NOT NULL,
  "teacher_id" uuid,
  "assigned_by" uuid,
  "name" varchar(255) NOT NULL,
  "start_date" date,
  "end_date" date,
  "status" varchar(50) DEFAULT 'ACTIVE',
  "class_type" int DEFAULT 0, -- 0: Chuẩn, 1: Phân tầng theo cụm K-Means/Thematic Cohort
  "domain_id" uuid,
  "domain_code" varchar(50),
  "cluster_index" int,
  "assigned_at" timestamp,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "ClassEnrollments" (
  "enrollment_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "class_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "diagnostic_submission_id" uuid,
  "approved_by" uuid,
  "status" varchar(50) DEFAULT 'ENROLLED',
  "enrolled_at" timestamp DEFAULT now()
);

-- Phân nhóm vi mô 3 - 5 học sinh cùng điểm nghẽn kiến thức tại lớp
CREATE TABLE "ClassGroups" (
  "group_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "class_id" uuid NOT NULL,
  "group_name" varchar(255) NOT NULL,
  "focus_area" varchar(255),
  "common_weak_skill_ids" text,
  "recommended_worksheet_title" varchar(255),
  "assigned_worksheet_id" varchar(100),
  "assigned_worksheet_title" varchar(255),
  "worksheet_assigned_at" timestamp,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "ClassGroupMembers" (
  "group_member_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "group_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "joined_at" timestamp DEFAULT now()
);

CREATE TABLE "TeacherFeedback" (
  "feedback_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "teacher_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "class_id" uuid,
  "content" text NOT NULL,
  "created_at" timestamp DEFAULT now()
);

-- =====================================================================
-- 6. HỌC TẬP CÁ NHÂN HÓA & TIẾN TRÌNH THÍCH ỨNG (CORE 2 & CORE 3)
-- =====================================================================

CREATE TABLE "LearningProfiles" (
  "profile_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "skill_id" uuid NOT NULL,
  "mastery_score" double precision DEFAULT 0.0,
  "last_updated" timestamp DEFAULT now()
);

CREATE TABLE "LearningRoadmaps" (
  "roadmap_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "diagnostic_submission_id" uuid,
  "target_score" int,
  "total_milestones" int DEFAULT 0,
  "completed_milestones" int DEFAULT 0,
  "is_pruned" boolean DEFAULT false,
  "pruned_reason" text,
  "status" varchar(50) DEFAULT 'ACTIVE',
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp DEFAULT now()
);

-- Chặng học thích ứng cá nhân hóa (Video lý thuyết, Quiz củng cố)
CREATE TABLE "RoadmapNodes" (
  "node_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "roadmap_id" uuid NOT NULL,
  "skill_id" uuid NOT NULL,
  "step_order" int NOT NULL,
  "material_id" uuid,
  "quiz_exam_id" uuid,
  "status" varchar(50) DEFAULT 'LOCKED', -- 'LOCKED', 'UNLOCKED', 'COMPLETED'
  "is_pruned" boolean DEFAULT false,
  "unlocked_at" timestamp,
  "completed_at" timestamp,
  "video_watched_seconds" int DEFAULT 0,
  "video_total_seconds" int DEFAULT 0,
  "is_video_completed" boolean DEFAULT false,
  "quiz_score" double precision,
  "is_quiz_passed" boolean DEFAULT false
);

-- Core Flow 3: Tiến trình chặng học theo chu trình P-L-A-R
CREATE TABLE "StageProgress" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "roadmap_node_id" uuid NOT NULL,
  "current_step" varchar(20) NOT NULL, -- 'PREVIEW', 'LEARN', 'APPLY', 'REFLECT'
  "video_watch_percentage" decimal(5,2) DEFAULT 0.0,
  "bkt_mastery_plt" double precision DEFAULT 0.0,
  "consecutive_advanced_correct" int DEFAULT 0,
  "consecutive_incorrect" int DEFAULT 0,
  "status" varchar(20) NOT NULL, -- 'IN_PROGRESS', 'COMPLETED', 'REMEDIAL_NEEDED'
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp DEFAULT now()
);

-- Core Flow 3: Nhật ký trả lời thích ứng từng câu (Động cơ BKT & IRT ZPD)
CREATE TABLE "AdaptiveQuizAttempts" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "stage_progress_id" uuid NOT NULL,
  "student_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "pattern_id" varchar(100),
  "selected_option" varchar(10),
  "is_correct" boolean NOT NULL,
  "time_spent_seconds" int,
  "item_difficulty_b" double precision,
  "item_discrimination_a" double precision,
  "is_lucky_guess" boolean DEFAULT false,
  "prior_plt" double precision,
  "posterior_plt" double precision,
  "created_at" timestamp DEFAULT now()
);

-- Core Flow 3: Sổ tay lỗi sai & Lặp lại ngắt quãng SM-2
CREATE TABLE "MistakeNotebooks" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "skill_id" uuid NOT NULL,
  "pattern_id" varchar(100),
  "cognitive_error_tag" varchar(50), -- 'CARELESS', 'MISREAD_QUESTION', 'MISSING_CONCEPT', 'TIME_PRESSURE'
  "student_notes" text,
  "next_review_date" date,
  "review_count" int DEFAULT 0,
  "consecutive_correct_reviews" int DEFAULT 0,
  "interval_days" int DEFAULT 1,
  "ease_factor" double precision DEFAULT 2.5,
  "is_mastered" boolean DEFAULT false,
  "last_reviewed_at" timestamp,
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp DEFAULT now()
);

-- =====================================================================
-- 7. THI CỬ, NỘP BÀI & GIÁM SÁT PROCTORING (PRACTICE SERVICE)
-- =====================================================================

CREATE TABLE "ExamSubmissions" (
  "submission_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "exam_id" uuid NOT NULL,
  "exam_type" varchar(50) NOT NULL, -- 'DIAGNOSTIC', 'FULL_MOCK', 'MINI_TEST'
  "total_score" int,
  "total_correct" int,
  "total_questions" int,
  "total_time_spent_seconds" int,
  "started_at" timestamp DEFAULT now(),
  "completed_at" timestamp,
  "status" varchar(50) DEFAULT 'DOING',
  "theta_0" double precision,
  "placement_class" varchar(50),
  "ai_commentary" text,
  "enrolled_class_id" uuid,
  -- Module 3: Giám sát liêm chính thi cử (Proctoring)
  "tab_departure_count" int DEFAULT 0,
  "integrity_status" varchar(50) DEFAULT 'CLEAN', -- 'CLEAN', 'FLAGGED', 'CHEATING_SUSPECTED'
  "mentor_verdict" varchar(50),
  "mentor_notes" text
);

CREATE TABLE "SubmissionAnswers" (
  "answer_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "submission_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "selected_option" varchar(10),
  "is_correct" boolean NOT NULL,
  "time_spent_seconds" int
);

-- Module 3: Ảnh chụp webcam giám sát thi thử
CREATE TABLE "ProctoringSnapshots" (
  "id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "submission_id" uuid NOT NULL,
  "snapshot_url" text NOT NULL,
  "captured_at" timestamp DEFAULT now(),
  "face_detected" boolean DEFAULT true
);

-- Tương thích ngược: Log làm bài luyện tập độc lập
CREATE TABLE "AttemptLogs" (
  "attempt_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "question_id" uuid NOT NULL,
  "selected_option" char(1),
  "is_correct" boolean NOT NULL,
  "time_spent" int,
  "created_at" timestamp DEFAULT now()
);

-- =====================================================================
-- 8. DỰ BÁO KHOẢNG ĐIỂM, TOA THUỐC & CẢNH BÁO SỚM (CORE FLOW 6)
-- =====================================================================

CREATE TABLE "ScorePredictions" (
  "prediction_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "predicted_score" int,
  "predicted_score_min" int,
  "predicted_score_max" int,
  "confidence_rate" double precision,
  -- Core 6: Bảng cân đối thâm hụt & Toa thuốc ROI
  "target_score" int,
  "deficit_score" int,
  "sem_score" double precision,
  "prescription_items" jsonb, -- Payload JSONB chứa Top 2-3 dạng bài tối ưu Greedy Knapsack ROI
  "calculation_source" varchar(50) DEFAULT 'MOCK_EXAM', -- 'MOCK_EXAM', 'STAGE_COMPLETION', 'MANUAL_RECALCULATE'
  "created_at" timestamp DEFAULT now()
);

-- Core 6: Hệ thống cảnh báo sớm 3 cấp (BR-04) & Can thiệp Mentor
CREATE TABLE "SystemAlerts" (
  "alert_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "alert_type" varchar(50) NOT NULL, -- 'GREEN', 'YELLOW', 'RED', 'UNREALISTIC_GOAL'
  "message" text NOT NULL,
  "is_read" boolean DEFAULT false,
  "handled_by" uuid,
  "resolution_notes" text,
  "resolved_at" timestamp,
  "created_at" timestamp DEFAULT now()
);

-- =====================================================================
-- 9. AI TUTOR & TRI THỨC VECTOR DB (PGVECTOR / RAG - AI ENGINE)
-- =====================================================================

CREATE TABLE "KnowledgeSources" (
  "source_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "domain_id" varchar(100),
  "skill_id" varchar(100),
  "title" varchar(255) NOT NULL,
  "content" text,
  "file_url" varchar(500),
  "file_hash" varchar(64),
  "document_type" varchar(50) DEFAULT 'TEXTBOOK', -- 'TEXTBOOK', 'CURRICULUM', 'GENERAL_KNOWLEDGE'
  "total_pages" int DEFAULT 0,
  "total_chars" int DEFAULT 0,
  "total_chunks" int DEFAULT 0,
  "vector_status" varchar(50) DEFAULT 'COMPLETED', -- 'PENDING', 'PROCESSING', 'COMPLETED', 'FAILED'
  "uploaded_by" uuid,
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp DEFAULT now()
);

-- Bảng phân đoạn Vector Chunks phục vụ RAG (Gemini text-embedding-004 768 dimensions)
CREATE TABLE "KnowledgeVectorChunks" (
  "chunk_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "source_id" uuid NOT NULL,
  "domain_id" varchar(100),
  "skill_id" varchar(100),
  "chunk_index" int NOT NULL,
  "page_number" int DEFAULT 1,
  "content_snippet" text NOT NULL,
  "embedding" vector(768),
  "document_type" varchar(50) DEFAULT 'TEXTBOOK',
  "char_count" int DEFAULT 0,
  "metadata" jsonb,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "AITutorSessions" (
  "session_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "question_id" uuid,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "AITutorMessages" (
  "message_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "session_id" uuid NOT NULL,
  "role" varchar(50) NOT NULL, -- 'USER', 'ASSISTANT', 'SYSTEM'
  "content" text NOT NULL,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "TokenUsageLogs" (
  "log_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "service_name" varchar(100) NOT NULL,
  "related_session_id" uuid,
  "tokens_used" int DEFAULT 0,
  "cost_usd" double precision DEFAULT 0.0,
  "created_at" timestamp DEFAULT now()
);

-- =====================================================================
-- 10. GOM NHÓM NĂNG LỰC (ABILITY GROUPS - CLUSTER-THEN-CLASSIFY)
-- =====================================================================

CREATE TABLE "AbilityGroups" (
  "group_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "domain_id" uuid NOT NULL,
  "skill_id" uuid,
  "group_label" varchar(100) NOT NULL,
  "description" text,
  "created_at" timestamp DEFAULT now()
);

CREATE TABLE "StudentGroupMemberships" (
  "membership_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "student_id" uuid NOT NULL,
  "group_id" uuid NOT NULL,
  "assigned_at" timestamp DEFAULT now(),
  "is_current" boolean DEFAULT true
);

-- =====================================================================
-- 11. CẤU HÌNH VẬN HÀNH HỆ THỐNG
-- =====================================================================

CREATE TABLE "SystemConfigs" (
  "config_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "config_key" varchar(100) UNIQUE NOT NULL,
  "config_value" varchar(500),
  "description" text,
  "updated_by" uuid,
  "updated_at" timestamp DEFAULT now()
);

-- =====================================================================
-- RÀNG BUỘC KHÓA NGOẠI (FOREIGN KEY CONSTRAINTS)
-- =====================================================================

-- RBAC, Identity & RefreshTokens
ALTER TABLE "UserRoles" ADD CONSTRAINT "fk_userroles_user" FOREIGN KEY ("user_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "UserRoles" ADD CONSTRAINT "fk_userroles_role" FOREIGN KEY ("role_id") REFERENCES "Roles" ("role_id") ON DELETE CASCADE;
ALTER TABLE "RefreshTokens" ADD CONSTRAINT "fk_refreshtokens_user" FOREIGN KEY ("user_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;

-- Actor Profiles (1-1 với Users qua PK)
ALTER TABLE "Students" ADD CONSTRAINT "fk_students_user" FOREIGN KEY ("student_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "Students" ADD CONSTRAINT "fk_students_campus" FOREIGN KEY ("campus_id") REFERENCES "Campuses" ("campus_id") ON DELETE SET NULL;

ALTER TABLE "Parents" ADD CONSTRAINT "fk_parents_user" FOREIGN KEY ("parent_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "ParentStudentRelations" ADD CONSTRAINT "fk_psr_parent" FOREIGN KEY ("parent_id") REFERENCES "Parents" ("parent_id") ON DELETE CASCADE;
ALTER TABLE "ParentStudentRelations" ADD CONSTRAINT "fk_psr_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;

ALTER TABLE "Teachers" ADD CONSTRAINT "fk_teachers_user" FOREIGN KEY ("teacher_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "Teachers" ADD CONSTRAINT "fk_teachers_campus" FOREIGN KEY ("campus_id") REFERENCES "Campuses" ("campus_id") ON DELETE SET NULL;

ALTER TABLE "AcademicManagers" ADD CONSTRAINT "fk_managers_user" FOREIGN KEY ("manager_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "AcademicManagers" ADD CONSTRAINT "fk_managers_campus" FOREIGN KEY ("campus_id") REFERENCES "Campuses" ("campus_id") ON DELETE SET NULL;

ALTER TABLE "AcademicDirectors" ADD CONSTRAINT "fk_directors_user" FOREIGN KEY ("director_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;
ALTER TABLE "Administrators" ADD CONSTRAINT "fk_admins_user" FOREIGN KEY ("admin_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE;

-- Khung Năng Lực, Đồ Thị Tiên Quyết DAG & Ngân Hàng Câu Hỏi
ALTER TABLE "CompetencyDomains" ADD CONSTRAINT "fk_domains_approver" FOREIGN KEY ("approved_by") REFERENCES "AcademicDirectors" ("director_id") ON DELETE SET NULL;
ALTER TABLE "Skills" ADD CONSTRAINT "fk_skills_domain" FOREIGN KEY ("domain_id") REFERENCES "CompetencyDomains" ("domain_id") ON DELETE RESTRICT;
ALTER TABLE "Skills" ADD CONSTRAINT "fk_skills_parent" FOREIGN KEY ("parent_id") REFERENCES "Skills" ("skill_id") ON DELETE RESTRICT;
ALTER TABLE "Skills" ADD CONSTRAINT "fk_skills_approver" FOREIGN KEY ("approved_by") REFERENCES "AcademicDirectors" ("director_id") ON DELETE SET NULL;

ALTER TABLE "SkillPrerequisites" ADD CONSTRAINT "fk_skillprereq_skill" FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") ON DELETE CASCADE;
ALTER TABLE "SkillPrerequisites" ADD CONSTRAINT "fk_skillprereq_prereq" FOREIGN KEY ("prerequisite_id") REFERENCES "Skills" ("skill_id") ON DELETE CASCADE;

ALTER TABLE "Materials" ADD CONSTRAINT "fk_materials_skill" FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") ON DELETE CASCADE;
ALTER TABLE "Questions" ADD CONSTRAINT "fk_questions_skill" FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") ON DELETE RESTRICT;
ALTER TABLE "Questions" ADD CONSTRAINT "fk_questions_passage" FOREIGN KEY ("passage_id") REFERENCES "Passages" ("passage_id") ON DELETE SET NULL;
ALTER TABLE "Questions" ADD CONSTRAINT "fk_questions_reviewer" FOREIGN KEY ("reviewed_by") REFERENCES "Teachers" ("teacher_id") ON DELETE SET NULL;

-- Đề Thi & Quan Hệ Đề - Câu Hỏi
ALTER TABLE "MockExams" ADD CONSTRAINT "fk_mockexams_campus" FOREIGN KEY ("campus_id") REFERENCES "Campuses" ("campus_id") ON DELETE SET NULL;
ALTER TABLE "MockExams" ADD CONSTRAINT "fk_mockexams_creator" FOREIGN KEY ("created_by") REFERENCES "Users" ("user_id") ON DELETE SET NULL;
ALTER TABLE "ExamQuestions" ADD CONSTRAINT "fk_examquestions_exam" FOREIGN KEY ("exam_id") REFERENCES "MockExams" ("exam_id") ON DELETE CASCADE;
ALTER TABLE "ExamQuestions" ADD CONSTRAINT "fk_examquestions_question" FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") ON DELETE CASCADE;

-- Lớp Học, Nhóm Vi Mô & Ghi Danh
ALTER TABLE "Classes" ADD CONSTRAINT "fk_classes_campus" FOREIGN KEY ("campus_id") REFERENCES "Campuses" ("campus_id") ON DELETE RESTRICT;
ALTER TABLE "Classes" ADD CONSTRAINT "fk_classes_teacher" FOREIGN KEY ("teacher_id") REFERENCES "Teachers" ("teacher_id") ON DELETE SET NULL;
ALTER TABLE "Classes" ADD CONSTRAINT "fk_classes_assigner" FOREIGN KEY ("assigned_by") REFERENCES "AcademicManagers" ("manager_id") ON DELETE SET NULL;
ALTER TABLE "Classes" ADD CONSTRAINT "fk_classes_domain" FOREIGN KEY ("domain_id") REFERENCES "CompetencyDomains" ("domain_id") ON DELETE SET NULL;

ALTER TABLE "ClassEnrollments" ADD CONSTRAINT "fk_enrollments_class" FOREIGN KEY ("class_id") REFERENCES "Classes" ("class_id") ON DELETE RESTRICT;
ALTER TABLE "ClassEnrollments" ADD CONSTRAINT "fk_enrollments_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "ClassEnrollments" ADD CONSTRAINT "fk_enrollments_approver" FOREIGN KEY ("approved_by") REFERENCES "AcademicManagers" ("manager_id") ON DELETE SET NULL;

ALTER TABLE "ClassGroups" ADD CONSTRAINT "fk_classgroups_class" FOREIGN KEY ("class_id") REFERENCES "Classes" ("class_id") ON DELETE CASCADE;
ALTER TABLE "ClassGroupMembers" ADD CONSTRAINT "fk_groupmembers_group" FOREIGN KEY ("group_id") REFERENCES "ClassGroups" ("group_id") ON DELETE CASCADE;
ALTER TABLE "ClassGroupMembers" ADD CONSTRAINT "fk_groupmembers_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;

ALTER TABLE "TeacherFeedback" ADD CONSTRAINT "fk_feedback_teacher" FOREIGN KEY ("teacher_id") REFERENCES "Teachers" ("teacher_id") ON DELETE CASCADE;
ALTER TABLE "TeacherFeedback" ADD CONSTRAINT "fk_feedback_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "TeacherFeedback" ADD CONSTRAINT "fk_feedback_class" FOREIGN KEY ("class_id") REFERENCES "Classes" ("class_id") ON DELETE SET NULL;

-- Học Tập Thích Ứng, Lộ Trình & P-L-A-R
ALTER TABLE "LearningProfiles" ADD CONSTRAINT "fk_learningprofiles_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "LearningProfiles" ADD CONSTRAINT "fk_learningprofiles_skill" FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") ON DELETE CASCADE;

ALTER TABLE "LearningRoadmaps" ADD CONSTRAINT "fk_roadmaps_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;

ALTER TABLE "RoadmapNodes" ADD CONSTRAINT "fk_roadmapnodes_roadmap" FOREIGN KEY ("roadmap_id") REFERENCES "LearningRoadmaps" ("roadmap_id") ON DELETE CASCADE;
ALTER TABLE "RoadmapNodes" ADD CONSTRAINT "fk_roadmapnodes_skill" FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") ON DELETE RESTRICT;
ALTER TABLE "RoadmapNodes" ADD CONSTRAINT "fk_roadmapnodes_material" FOREIGN KEY ("material_id") REFERENCES "Materials" ("material_id") ON DELETE SET NULL;
ALTER TABLE "RoadmapNodes" ADD CONSTRAINT "fk_roadmapnodes_quiz" FOREIGN KEY ("quiz_exam_id") REFERENCES "MockExams" ("exam_id") ON DELETE SET NULL;

ALTER TABLE "StageProgress" ADD CONSTRAINT "fk_stageprogress_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "StageProgress" ADD CONSTRAINT "fk_stageprogress_node" FOREIGN KEY ("roadmap_node_id") REFERENCES "RoadmapNodes" ("node_id") ON DELETE CASCADE;

ALTER TABLE "AdaptiveQuizAttempts" ADD CONSTRAINT "fk_adaptiveattempts_progress" FOREIGN KEY ("stage_progress_id") REFERENCES "StageProgress" ("id") ON DELETE CASCADE;
ALTER TABLE "AdaptiveQuizAttempts" ADD CONSTRAINT "fk_adaptiveattempts_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "AdaptiveQuizAttempts" ADD CONSTRAINT "fk_adaptiveattempts_question" FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") ON DELETE CASCADE;

ALTER TABLE "MistakeNotebooks" ADD CONSTRAINT "fk_mistakenotebooks_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "MistakeNotebooks" ADD CONSTRAINT "fk_mistakenotebooks_question" FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") ON DELETE CASCADE;
ALTER TABLE "MistakeNotebooks" ADD CONSTRAINT "fk_mistakenotebooks_skill" FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") ON DELETE CASCADE;

-- Thi Cử, Nộp Bài & Proctoring
ALTER TABLE "ExamSubmissions" ADD CONSTRAINT "fk_submissions_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "ExamSubmissions" ADD CONSTRAINT "fk_submissions_exam" FOREIGN KEY ("exam_id") REFERENCES "MockExams" ("exam_id") ON DELETE RESTRICT;
ALTER TABLE "ExamSubmissions" ADD CONSTRAINT "fk_submissions_enrolled_class" FOREIGN KEY ("enrolled_class_id") REFERENCES "Classes" ("class_id") ON DELETE SET NULL;

ALTER TABLE "ClassEnrollments" ADD CONSTRAINT "fk_enrollments_diag_sub" FOREIGN KEY ("diagnostic_submission_id") REFERENCES "ExamSubmissions" ("submission_id") ON DELETE SET NULL;
ALTER TABLE "LearningRoadmaps" ADD CONSTRAINT "fk_roadmaps_diag_sub" FOREIGN KEY ("diagnostic_submission_id") REFERENCES "ExamSubmissions" ("submission_id") ON DELETE SET NULL;

ALTER TABLE "SubmissionAnswers" ADD CONSTRAINT "fk_subanswers_submission" FOREIGN KEY ("submission_id") REFERENCES "ExamSubmissions" ("submission_id") ON DELETE CASCADE;
ALTER TABLE "SubmissionAnswers" ADD CONSTRAINT "fk_subanswers_question" FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") ON DELETE CASCADE;

ALTER TABLE "ProctoringSnapshots" ADD CONSTRAINT "fk_proctoring_submission" FOREIGN KEY ("submission_id") REFERENCES "ExamSubmissions" ("submission_id") ON DELETE CASCADE;

ALTER TABLE "AttemptLogs" ADD CONSTRAINT "fk_attemptlogs_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "AttemptLogs" ADD CONSTRAINT "fk_attemptlogs_question" FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") ON DELETE CASCADE;

-- Dự Báo Điểm & Cảnh Báo Sớm BR-04 (Core 6)
ALTER TABLE "ScorePredictions" ADD CONSTRAINT "fk_predictions_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "SystemAlerts" ADD CONSTRAINT "fk_alerts_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "SystemAlerts" ADD CONSTRAINT "fk_alerts_handler" FOREIGN KEY ("handled_by") REFERENCES "Users" ("user_id") ON DELETE SET NULL;

-- AI Engine, RAG & Vector DB
ALTER TABLE "KnowledgeSources" ADD CONSTRAINT "fk_knowledgesources_uploader" FOREIGN KEY ("uploaded_by") REFERENCES "Users" ("user_id") ON DELETE SET NULL;
ALTER TABLE "KnowledgeVectorChunks" ADD CONSTRAINT "fk_vectorchunks_source" FOREIGN KEY ("source_id") REFERENCES "KnowledgeSources" ("source_id") ON DELETE CASCADE;

ALTER TABLE "AITutorSessions" ADD CONSTRAINT "fk_tutorsessions_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "AITutorSessions" ADD CONSTRAINT "fk_tutorsessions_question" FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") ON DELETE SET NULL;
ALTER TABLE "AITutorMessages" ADD CONSTRAINT "fk_tutormessages_session" FOREIGN KEY ("session_id") REFERENCES "AITutorSessions" ("session_id") ON DELETE CASCADE;
ALTER TABLE "TokenUsageLogs" ADD CONSTRAINT "fk_tokenlogs_session" FOREIGN KEY ("related_session_id") REFERENCES "AITutorSessions" ("session_id") ON DELETE SET NULL;

-- Gom Nhóm Năng Lực (Ability Groups)
ALTER TABLE "AbilityGroups" ADD CONSTRAINT "fk_abilitygroups_domain" FOREIGN KEY ("domain_id") REFERENCES "CompetencyDomains" ("domain_id") ON DELETE CASCADE;
ALTER TABLE "AbilityGroups" ADD CONSTRAINT "fk_abilitygroups_skill" FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") ON DELETE SET NULL;
ALTER TABLE "StudentGroupMemberships" ADD CONSTRAINT "fk_groupmemberships_student" FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE;
ALTER TABLE "StudentGroupMemberships" ADD CONSTRAINT "fk_groupmemberships_group" FOREIGN KEY ("group_id") REFERENCES "AbilityGroups" ("group_id") ON DELETE CASCADE;

-- Quản Trị Hệ Thống
ALTER TABLE "SystemConfigs" ADD CONSTRAINT "fk_configs_updater" FOREIGN KEY ("updated_by") REFERENCES "Users" ("user_id") ON DELETE SET NULL;

-- =====================================================================
-- CHỈ MỤC TỐI ƯU HÓA HIỆU NĂNG (INDEXES)
-- =====================================================================

-- 1. Index tra cứu sinh viên & vai trò
CREATE INDEX "idx_userroles_user_role" ON "UserRoles" ("user_id", "role_id");
CREATE INDEX "idx_students_campus" ON "Students" ("campus_id");
CREATE INDEX "idx_refreshtokens_user" ON "RefreshTokens" ("user_id");

-- 2. Index đồ thị năng lực & câu hỏi
CREATE INDEX "idx_skills_domain" ON "Skills" ("domain_id");
CREATE INDEX "idx_skills_parent" ON "Skills" ("parent_id");
CREATE INDEX "idx_questions_skill" ON "Questions" ("skill_id");
CREATE INDEX "idx_questions_difficulty" ON "Questions" ("difficulty_level");
CREATE INDEX "idx_questions_moderation" ON "Questions" ("moderation_status");

-- 3. Index lớp học & nhóm học tập vi mô
CREATE INDEX "idx_classes_campus" ON "Classes" ("campus_id");
CREATE INDEX "idx_classes_teacher" ON "Classes" ("teacher_id");
CREATE INDEX "idx_class_enrollments_student" ON "ClassEnrollments" ("student_id");
CREATE INDEX "idx_class_enrollments_class" ON "ClassEnrollments" ("class_id");
CREATE INDEX "idx_class_groups_class" ON "ClassGroups" ("class_id");
CREATE INDEX "idx_class_group_members_group" ON "ClassGroupMembers" ("group_id");

-- 4. Index tiến trình học thích ứng & sổ tay lỗi sai
CREATE INDEX "idx_stage_progress_student" ON "StageProgress" ("student_id");
CREATE INDEX "idx_stage_progress_node" ON "StageProgress" ("roadmap_node_id");
CREATE INDEX "idx_adaptive_attempts_progress" ON "AdaptiveQuizAttempts" ("stage_progress_id");
CREATE INDEX "idx_mistake_notebooks_student_next_review" ON "MistakeNotebooks" ("student_id", "next_review_date");
CREATE INDEX "idx_mistake_notebooks_mastery" ON "MistakeNotebooks" ("student_id", "is_mastered");

-- 5. Index bài thi & giám sát proctoring
CREATE INDEX "idx_submissions_student" ON "ExamSubmissions" ("student_id");
CREATE INDEX "idx_submissions_exam" ON "ExamSubmissions" ("exam_id");
CREATE INDEX "idx_submissions_integrity" ON "ExamSubmissions" ("integrity_status");
CREATE INDEX "idx_proctoring_submission" ON "ProctoringSnapshots" ("submission_id");

-- 6. Index dự báo điểm & cảnh báo sớm BR-04
CREATE INDEX "idx_score_predictions_student" ON "ScorePredictions" ("student_id");
CREATE INDEX "idx_system_alerts_student_read" ON "SystemAlerts" ("student_id", "is_read");
CREATE INDEX "idx_system_alerts_type" ON "SystemAlerts" ("alert_type");

-- 7. Index Vector HNSW cho RAG AI Tutor (Tìm kiếm độ tương đồng Cosine < 5ms)
CREATE INDEX "idx_knowledge_vector_hnsw" ON "KnowledgeVectorChunks" 
USING hnsw ("embedding" vector_cosine_ops);

CREATE INDEX "idx_knowledge_chunks_source" ON "KnowledgeVectorChunks" ("source_id");
CREATE INDEX "idx_knowledge_chunks_domain" ON "KnowledgeVectorChunks" ("domain_id");

-- 8. Index gom nhóm năng lực
CREATE INDEX "idx_sgm_student_current" ON "StudentGroupMemberships" ("student_id", "is_current");
CREATE INDEX "idx_ability_groups_domain" ON "AbilityGroups" ("domain_id");
