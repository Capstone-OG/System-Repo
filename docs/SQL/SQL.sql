CREATE TABLE "Roles" (
  "role_id" uuid PRIMARY KEY,
  "role_name" varchar UNIQUE
);

CREATE TABLE "Users" (
  "user_id" uuid PRIMARY KEY,
  "email" varchar UNIQUE,
  "password_hash" varchar,
  "full_name" varchar,
  "phone" varchar,
  "avatar_url" varchar,
  "is_active" boolean DEFAULT true,
  "created_at" timestamp DEFAULT (now())
);

CREATE TABLE "UserRoles" (
  "user_id" uuid,
  "role_id" uuid,
  PRIMARY KEY ("user_id", "role_id")
);

CREATE TABLE "Students" (
  "student_id" uuid PRIMARY KEY,
  "target_score" int,
  "exam_date" date,
  "study_hours_day" double,
  "school_name" varchar
);

CREATE TABLE "Parents" (
  "parent_id" uuid PRIMARY KEY,
  "phone_work" varchar
);

CREATE TABLE "ParentStudentRelations" (
  "relation_id" uuid PRIMARY KEY,
  "parent_id" uuid,
  "student_id" uuid,
  "created_at" timestamp
);

CREATE TABLE "CompetencyDomains" (
  "domain_id" uuid PRIMARY KEY,
  "name" varchar,
  "description" text
);

CREATE TABLE "Skills" (
  "skill_id" uuid PRIMARY KEY,
  "domain_id" uuid,
  "name" varchar,
  "parent_id" uuid,
  "weight" double,
  "created_at" timestamp
);

CREATE TABLE "Materials" (
  "material_id" uuid PRIMARY KEY,
  "skill_id" uuid,
  "title" varchar,
  "content" text,
  "video_url" varchar,
  "file_url" varchar,
  "created_at" timestamp
);

CREATE TABLE "Passages" (
  "passage_id" uuid PRIMARY KEY,
  "title" varchar,
  "content" text,
  "image_url" varchar
);

CREATE TABLE "Questions" (
  "question_id" uuid PRIMARY KEY,
  "skill_id" uuid,
  "passage_id" uuid,
  "difficulty_level" int,
  "content_latex" text,
  "option_a" text,
  "option_b" text,
  "option_c" text,
  "option_d" text,
  "correct_option" char,
  "explanation" text,
  "created_at" timestamp
);

CREATE TABLE "MockExams" (
  "exam_id" uuid PRIMARY KEY,
  "title" varchar,
  "duration_minutes" int,
  "total_questions" int,
  "is_published" boolean DEFAULT false,
  "created_at" timestamp
);

CREATE TABLE "ExamQuestions" (
  "exam_id" uuid,
  "question_id" uuid,
  "question_order" int,
  PRIMARY KEY ("exam_id", "question_id")
);

CREATE TABLE "LearningProfiles" (
  "profile_id" uuid PRIMARY KEY,
  "student_id" uuid,
  "skill_id" uuid,
  "mastery_score" double,
  "last_updated" timestamp
);

CREATE TABLE "LearningRoadmaps" (
  "roadmap_id" uuid PRIMARY KEY,
  "student_id" uuid,
  "created_at" timestamp,
  "updated_at" timestamp
);

CREATE TABLE "RoadmapNodes" (
  "node_id" uuid PRIMARY KEY,
  "roadmap_id" uuid,
  "skill_id" uuid,
  "step_order" int,
  "status" varchar,
  "completed_at" timestamp
);

CREATE TABLE "AttemptLogs" (
  "attempt_id" uuid PRIMARY KEY,
  "student_id" uuid,
  "question_id" uuid,
  "selected_option" char,
  "is_correct" boolean,
  "time_spent" int,
  "created_at" timestamp
);

CREATE TABLE "ExamSubmissions" (
  "submission_id" uuid PRIMARY KEY,
  "student_id" uuid,
  "exam_id" uuid,
  "total_score" int,
  "started_at" timestamp,
  "completed_at" timestamp,
  "status" varchar
);

CREATE TABLE "SubmissionAnswers" (
  "answer_id" uuid PRIMARY KEY,
  "submission_id" uuid,
  "question_id" uuid,
  "selected_option" char,
  "is_correct" boolean,
  "time_spent" int
);

CREATE TABLE "AITutorSessions" (
  "session_id" uuid PRIMARY KEY,
  "student_id" uuid,
  "question_id" uuid,
  "created_at" timestamp
);

CREATE TABLE "AITutorMessages" (
  "message_id" uuid PRIMARY KEY,
  "session_id" uuid,
  "role" varchar,
  "content" text,
  "created_at" timestamp
);

CREATE TABLE "ScorePredictions" (
  "prediction_id" uuid PRIMARY KEY,
  "student_id" uuid,
  "predicted_score" int,
  "confidence_rate" double,
  "created_at" timestamp
);

CREATE TABLE "SystemAlerts" (
  "alert_id" uuid PRIMARY KEY,
  "student_id" uuid,
  "alert_type" varchar,
  "message" text,
  "is_read" boolean DEFAULT false,
  "created_at" timestamp
);

COMMENT ON COLUMN "Roles"."role_name" IS 'ADMIN, TEACHER, STUDENT, PARENT';

COMMENT ON COLUMN "Students"."student_id" IS 'Khóa ngoại liên kết 1-1 với bảng Users';

COMMENT ON COLUMN "Students"."target_score" IS 'Điểm đích mong muốn (0 - 1200)';

COMMENT ON COLUMN "Students"."exam_date" IS 'Ngày thi thật dự kiến';

COMMENT ON COLUMN "Students"."study_hours_day" IS 'Giờ học tự cam kết trên ngày';

COMMENT ON COLUMN "Students"."school_name" IS 'Tên trường THPT học sinh theo học';

COMMENT ON COLUMN "Parents"."parent_id" IS 'Khóa ngoại liên kết 1-1 với bảng Users';

COMMENT ON COLUMN "ParentStudentRelations"."parent_id" IS 'FK liên kết Parents';

COMMENT ON COLUMN "ParentStudentRelations"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "CompetencyDomains"."name" IS 'Sử dụng ngôn ngữ, Toán học, Tư duy khoa học';

COMMENT ON COLUMN "Skills"."domain_id" IS 'FK liên kết CompetencyDomains';

COMMENT ON COLUMN "Skills"."name" IS 'Tên kỹ năng (ví dụ: Quy hoạch tuyến tính)';

COMMENT ON COLUMN "Skills"."parent_id" IS 'FK liên kết kỹ năng cha để tạo cây phân cấp';

COMMENT ON COLUMN "Skills"."weight" IS 'Trọng số phân bổ điểm trong đề thi thực tế';

COMMENT ON COLUMN "Materials"."skill_id" IS 'FK liên kết Skills (Lý thuyết cho kỹ năng này)';

COMMENT ON COLUMN "Materials"."title" IS 'Tiêu đề bài học';

COMMENT ON COLUMN "Materials"."content" IS 'Nội dung bài viết giảng lý thuyết';

COMMENT ON COLUMN "Materials"."video_url" IS 'Link video bài giảng (nếu có)';

COMMENT ON COLUMN "Materials"."file_url" IS 'Link tài liệu PDF đính kèm';

COMMENT ON COLUMN "Passages"."content" IS 'Đoạn văn đọc hiểu hoặc mô tả thí nghiệm khoa học lớn';

COMMENT ON COLUMN "Passages"."image_url" IS 'Hình ảnh, sơ đồ đi kèm trong đề bài';

COMMENT ON COLUMN "Questions"."skill_id" IS 'FK liên kết Skills';

COMMENT ON COLUMN "Questions"."passage_id" IS 'FK liên kết Passages (nếu thuộc chùm câu hỏi)';

COMMENT ON COLUMN "Questions"."difficulty_level" IS '1: Dễ, 2: Trung bình, 3: Khó';

COMMENT ON COLUMN "Questions"."content_latex" IS 'Nội dung câu hỏi định dạng văn bản hoặc LaTeX';

COMMENT ON COLUMN "Questions"."correct_option" IS 'A, B, C hoặc D';

COMMENT ON COLUMN "Questions"."explanation" IS 'Lời giải chi tiết của giáo viên';

COMMENT ON COLUMN "MockExams"."title" IS 'Ví dụ: Đề thi minh họa V-ACT số 1';

COMMENT ON COLUMN "MockExams"."duration_minutes" IS 'Thời gian làm bài thi (ví dụ: 150 phút)';

COMMENT ON COLUMN "MockExams"."total_questions" IS 'Tổng số câu (ví dụ: 120 câu)';

COMMENT ON COLUMN "ExamQuestions"."question_order" IS 'Thứ tự hiển thị câu hỏi trong đề thi';

COMMENT ON COLUMN "LearningProfiles"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "LearningProfiles"."skill_id" IS 'FK liên kết Skills';

COMMENT ON COLUMN "LearningProfiles"."mastery_score" IS 'Chỉ số làm chủ kỹ năng hiện tại (0.0 đến 1.0)';

COMMENT ON COLUMN "LearningRoadmaps"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "RoadmapNodes"."roadmap_id" IS 'FK liên kết LearningRoadmaps';

COMMENT ON COLUMN "RoadmapNodes"."skill_id" IS 'FK liên kết Skills';

COMMENT ON COLUMN "RoadmapNodes"."step_order" IS 'Thứ tự chặng học (1, 2, 3...)';

COMMENT ON COLUMN "RoadmapNodes"."status" IS 'LOCKED, IN_PROGRESS, COMPLETED';

COMMENT ON COLUMN "AttemptLogs"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "AttemptLogs"."question_id" IS 'FK liên kết Questions';

COMMENT ON COLUMN "AttemptLogs"."selected_option" IS 'A, B, C hoặc D';

COMMENT ON COLUMN "AttemptLogs"."is_correct" IS 'Đúng hay Sai';

COMMENT ON COLUMN "AttemptLogs"."time_spent" IS 'Thời gian làm bài (giây)';

COMMENT ON COLUMN "ExamSubmissions"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "ExamSubmissions"."exam_id" IS 'FK liên kết MockExams';

COMMENT ON COLUMN "ExamSubmissions"."total_score" IS 'Tổng điểm thi đạt được';

COMMENT ON COLUMN "ExamSubmissions"."status" IS 'DOING, SUBMITTED';

COMMENT ON COLUMN "SubmissionAnswers"."submission_id" IS 'FK liên kết ExamSubmissions';

COMMENT ON COLUMN "SubmissionAnswers"."question_id" IS 'FK liên kết Questions';

COMMENT ON COLUMN "SubmissionAnswers"."selected_option" IS 'A, B, C hoặc D';

COMMENT ON COLUMN "SubmissionAnswers"."time_spent" IS 'Thời gian làm câu hỏi này (giây)';

COMMENT ON COLUMN "AITutorSessions"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "AITutorSessions"."question_id" IS 'FK liên kết Questions (nếu hỏi về một câu cụ thể)';

COMMENT ON COLUMN "AITutorMessages"."session_id" IS 'FK liên kết AITutorSessions';

COMMENT ON COLUMN "AITutorMessages"."role" IS 'user hoặc assistant';

COMMENT ON COLUMN "AITutorMessages"."content" IS 'Nội dung tin nhắn';

COMMENT ON COLUMN "ScorePredictions"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "ScorePredictions"."predicted_score" IS 'Điểm dự đoán (0 - 1200)';

COMMENT ON COLUMN "ScorePredictions"."confidence_rate" IS 'Độ tin cậy của mô hình';

COMMENT ON COLUMN "SystemAlerts"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "SystemAlerts"."alert_type" IS 'LATE (trễ tiến độ), PERFORMANCE_DROP (học sa sút)';

COMMENT ON COLUMN "SystemAlerts"."message" IS 'Nội dung cảnh báo gửi Phụ huynh/Học sinh';

ALTER TABLE "UserRoles" ADD FOREIGN KEY ("user_id") REFERENCES "Users" ("user_id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "UserRoles" ADD FOREIGN KEY ("role_id") REFERENCES "Roles" ("role_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Users" ADD FOREIGN KEY ("user_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Users" ADD FOREIGN KEY ("user_id") REFERENCES "Parents" ("parent_id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ParentStudentRelations" ADD FOREIGN KEY ("parent_id") REFERENCES "Parents" ("parent_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ParentStudentRelations" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Skills" ADD FOREIGN KEY ("domain_id") REFERENCES "CompetencyDomains" ("domain_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Skills" ADD FOREIGN KEY ("parent_id") REFERENCES "Skills" ("skill_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Materials" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Questions" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Questions" ADD FOREIGN KEY ("passage_id") REFERENCES "Passages" ("passage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ExamQuestions" ADD FOREIGN KEY ("exam_id") REFERENCES "MockExams" ("exam_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ExamQuestions" ADD FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "LearningProfiles" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "LearningProfiles" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "LearningRoadmaps" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "RoadmapNodes" ADD FOREIGN KEY ("roadmap_id") REFERENCES "LearningRoadmaps" ("roadmap_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "RoadmapNodes" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "AttemptLogs" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "AttemptLogs" ADD FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ExamSubmissions" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ExamSubmissions" ADD FOREIGN KEY ("exam_id") REFERENCES "MockExams" ("exam_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "SubmissionAnswers" ADD FOREIGN KEY ("submission_id") REFERENCES "ExamSubmissions" ("submission_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "SubmissionAnswers" ADD FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "AITutorSessions" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "AITutorSessions" ADD FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "AITutorMessages" ADD FOREIGN KEY ("session_id") REFERENCES "AITutorSessions" ("session_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ScorePredictions" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "SystemAlerts" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;
