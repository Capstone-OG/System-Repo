CREATE TABLE "Users" (
  "user_id" uuid PRIMARY KEY,
  "email" varchar UNIQUE,
  "password_hash" varchar,
  "full_name" varchar,
  "role" varchar
);

CREATE TABLE "Students" (
  "student_id" uuid PRIMARY KEY,
  "target_score" int,
  "exam_date" date,
  "study_hours_day" double
);

CREATE TABLE "ParentStudentRelations" (
  "relation_id" uuid PRIMARY KEY,
  "parent_id" uuid,
  "student_id" uuid
);

CREATE TABLE "Skills" (
  "skill_id" uuid PRIMARY KEY,
  "name" varchar,
  "parent_id" uuid,
  "weight" double
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
  "explanation" text
);

CREATE TABLE "LearningProfiles" (
  "profile_id" uuid PRIMARY KEY,
  "student_id" uuid,
  "skill_id" uuid,
  "mastery_score" double,
  "last_updated" timestamp
);

CREATE TABLE "PathNodes" (
  "node_id" uuid PRIMARY KEY,
  "student_id" uuid,
  "skill_id" uuid,
  "step_order" int,
  "status" varchar
);

CREATE TABLE "AttemptLogs" (
  "attempt_id" uuid PRIMARY KEY,
  "student_id" uuid,
  "question_id" uuid,
  "is_correct" boolean,
  "time_spent" int,
  "created_at" timestamp
);

CREATE TABLE "AITutorMessages" (
  "message_id" uuid PRIMARY KEY,
  "student_id" uuid,
  "question_id" uuid,
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

COMMENT ON COLUMN "Users"."email" IS 'Email đăng nhập';

COMMENT ON COLUMN "Users"."password_hash" IS 'Mật khẩu băm bảo mật';

COMMENT ON COLUMN "Users"."full_name" IS 'Họ và tên';

COMMENT ON COLUMN "Users"."role" IS 'Vai trò: ADMIN, TEACHER, STUDENT, PARENT';

COMMENT ON COLUMN "Students"."student_id" IS 'FK liên kết Users';

COMMENT ON COLUMN "Students"."target_score" IS 'Điểm mục tiêu (ví dụ: 850)';

COMMENT ON COLUMN "Students"."exam_date" IS 'Ngày thi thật dự kiến';

COMMENT ON COLUMN "Students"."study_hours_day" IS 'Số giờ cam kết tự học/ngày';

COMMENT ON COLUMN "ParentStudentRelations"."parent_id" IS 'FK liên kết Users';

COMMENT ON COLUMN "ParentStudentRelations"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "Skills"."name" IS 'Tên kỹ năng/chủ đề';

COMMENT ON COLUMN "Skills"."parent_id" IS 'FK liên kết cha-con để tạo cây năng lực';

COMMENT ON COLUMN "Skills"."weight" IS 'Trọng số điểm trong đề thi thực tế';

COMMENT ON COLUMN "Passages"."title" IS 'Tiêu đề ngữ cảnh';

COMMENT ON COLUMN "Passages"."content" IS 'Đoạn văn đọc hiểu hoặc mô tả thí nghiệm lớn';

COMMENT ON COLUMN "Passages"."image_url" IS 'Hình ảnh, biểu đồ đi kèm nếu có';

COMMENT ON COLUMN "Questions"."skill_id" IS 'FK liên kết Skills';

COMMENT ON COLUMN "Questions"."passage_id" IS 'FK liên kết Passages (dành cho câu hỏi chùm)';

COMMENT ON COLUMN "Questions"."difficulty_level" IS 'Độ khó: 1-Dễ, 2-Trung bình, 3-Khó';

COMMENT ON COLUMN "Questions"."content_latex" IS 'Nội dung câu hỏi dạng văn bản hoặc LaTeX';

COMMENT ON COLUMN "Questions"."explanation" IS 'Lời giải chi tiết của giáo viên';

COMMENT ON COLUMN "LearningProfiles"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "LearningProfiles"."skill_id" IS 'FK liên kết Skills';

COMMENT ON COLUMN "LearningProfiles"."mastery_score" IS 'Điểm năng lực tích lũy thực tế (0.0 đến 1.0)';

COMMENT ON COLUMN "PathNodes"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "PathNodes"."skill_id" IS 'FK liên kết Skills';

COMMENT ON COLUMN "PathNodes"."step_order" IS 'Thứ tự chặng học trên lộ trình';

COMMENT ON COLUMN "PathNodes"."status" IS 'Trạng thái chặng: LOCKED, IN_PROGRESS, COMPLETED';

COMMENT ON COLUMN "AttemptLogs"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "AttemptLogs"."question_id" IS 'FK liên kết Questions';

COMMENT ON COLUMN "AttemptLogs"."is_correct" IS 'Đúng/Sai';

COMMENT ON COLUMN "AttemptLogs"."time_spent" IS 'Thời gian làm bài (giây)';

COMMENT ON COLUMN "AITutorMessages"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "AITutorMessages"."question_id" IS 'FK liên kết câu hỏi đang trao đổi';

COMMENT ON COLUMN "AITutorMessages"."role" IS 'Vai trò: user / assistant';

COMMENT ON COLUMN "AITutorMessages"."content" IS 'Nội dung tin nhắn hội thoại';

COMMENT ON COLUMN "ScorePredictions"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "ScorePredictions"."predicted_score" IS 'Điểm dự đoán hiện tại (0 - 1200)';

COMMENT ON COLUMN "ScorePredictions"."confidence_rate" IS 'Độ tin cậy của thuật toán dự đoán';

COMMENT ON COLUMN "SystemAlerts"."student_id" IS 'FK liên kết Students';

COMMENT ON COLUMN "SystemAlerts"."alert_type" IS 'Loại cảnh báo: LATE, SCORE_DROP, INACTIVE';

COMMENT ON COLUMN "SystemAlerts"."message" IS 'Nội dung thông báo';

ALTER TABLE "Users" ADD FOREIGN KEY ("user_id") REFERENCES "Students" ("student_id") ON DELETE CASCADE DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ParentStudentRelations" ADD FOREIGN KEY ("parent_id") REFERENCES "Users" ("user_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ParentStudentRelations" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Skills" ADD FOREIGN KEY ("parent_id") REFERENCES "Skills" ("skill_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Questions" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "Questions" ADD FOREIGN KEY ("passage_id") REFERENCES "Passages" ("passage_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "LearningProfiles" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "LearningProfiles" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "PathNodes" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "PathNodes" ADD FOREIGN KEY ("skill_id") REFERENCES "Skills" ("skill_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "AttemptLogs" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "AttemptLogs" ADD FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "AITutorMessages" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "AITutorMessages" ADD FOREIGN KEY ("question_id") REFERENCES "Questions" ("question_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "ScorePredictions" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "SystemAlerts" ADD FOREIGN KEY ("student_id") REFERENCES "Students" ("student_id") DEFERRABLE INITIALLY IMMEDIATE;
