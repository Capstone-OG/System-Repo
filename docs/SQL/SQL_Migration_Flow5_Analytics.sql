-- =======================================================================
-- MIGRATION SCRIPT: CORE FLOW 5 - LEARNING ANALYTICS & CLASS HEATMAP
-- Schema: v_eval_practice
-- =======================================================================

SET search_path TO v_eval_practice, public;

-- 1. Bảng lưu trữ chi tiết từng ô ma trận nhiệt P(Lt) cho từng học sinh và kỹ năng
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassSkillHeatmaps" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID NOT NULL REFERENCES "Classes"(class_id) ON DELETE CASCADE,
    student_id UUID NOT NULL,
    skill_id UUID NOT NULL,
    skill_name VARCHAR(255) NOT NULL,
    domain_code VARCHAR(50) NOT NULL, -- DOM_LANG, DOM_MATH, DOM_NAT_SCI, DOM_SOC_SCI
    plt_value DOUBLE PRECISION NOT NULL DEFAULT 0.1000,
    mastery_level VARCHAR(30) NOT NULL DEFAULT 'WEAK', -- CRITICAL, WEAK, DEVELOPING, MASTERED
    last_assessment_type VARCHAR(50) NOT NULL DEFAULT 'DIAGNOSTIC', -- DIAGNOSTIC, ADAPTIVE_QUIZ, MOCK_EXAM
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_class_student_skill UNIQUE (class_id, student_id, skill_id)
);

CREATE INDEX IF NOT EXISTS idx_heatmaps_class_id ON v_eval_practice."ClassSkillHeatmaps"(class_id);
CREATE INDEX IF NOT EXISTS idx_heatmaps_student_id ON v_eval_practice."ClassSkillHeatmaps"(student_id);
CREATE INDEX IF NOT EXISTS idx_heatmaps_skill_id ON v_eval_practice."ClassSkillHeatmaps"(skill_id);

-- 2. Bảng tổng hợp thống kê theo cột kỹ năng của lớp học (phục vụ cảnh báo sư phạm)
CREATE TABLE IF NOT EXISTS v_eval_practice."ClassHeatmapSummaries" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    class_id UUID NOT NULL REFERENCES "Classes"(class_id) ON DELETE CASCADE,
    skill_id UUID NOT NULL,
    skill_name VARCHAR(255) NOT NULL,
    domain_code VARCHAR(50) NOT NULL,
    average_plt DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    struggling_count INT NOT NULL DEFAULT 0,
    total_students INT NOT NULL DEFAULT 0,
    struggling_rate DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    std_dev_plt DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    alert_status VARCHAR(30) NOT NULL DEFAULT 'SAFE_GREEN', -- CRITICAL_RED, WARNING_AMBER, SAFE_GREEN
    is_bimodal BOOLEAN NOT NULL DEFAULT FALSE,
    calculated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_class_skill_summary UNIQUE (class_id, skill_id)
);

CREATE INDEX IF NOT EXISTS idx_heatmap_summaries_class_status 
ON v_eval_practice."ClassHeatmapSummaries"(class_id, alert_status);

-- 3. Bảng ghi nhận nhật ký chuyên cần và thời gian học tập hằng ngày (phục vụ Streak)
CREATE TABLE IF NOT EXISTS v_eval_practice."StudentDailyActivities" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL,
    activity_date DATE NOT NULL,
    study_time_minutes INT NOT NULL DEFAULT 0,
    practice_questions_solved INT NOT NULL DEFAULT 0,
    video_minutes_watched INT NOT NULL DEFAULT 0,
    mock_exams_taken INT NOT NULL DEFAULT 0,
    is_streak_counted BOOLEAN NOT NULL DEFAULT FALSE,
    is_frozen BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_student_activity_date UNIQUE (student_id, activity_date)
);

CREATE INDEX IF NOT EXISTS idx_student_activity_date 
ON v_eval_practice."StudentDailyActivities"(student_id, activity_date DESC);

-- 4. Bảng lưu trữ chỉ số sẵn sàng thi cho Phụ huynh và Học sinh (Exam Readiness)
CREATE TABLE IF NOT EXISTS v_eval_practice."StudentReadinessMetrics" (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL,
    normalized_theta DOUBLE PRECISION NOT NULL DEFAULT 50.0,
    skill_coverage_plt DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    consistency_score DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    exam_readiness_index DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    readiness_tier VARCHAR(30) NOT NULL DEFAULT 'PREPARING', -- NOT_READY, PREPARING, ACCELERATING, READY
    study_hours_this_week DOUBLE PRECISION NOT NULL DEFAULT 0.0,
    current_streak_days INT NOT NULL DEFAULT 0,
    calculated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_student_readiness UNIQUE (student_id)
);

CREATE INDEX IF NOT EXISTS idx_readiness_student_id 
ON v_eval_practice."StudentReadinessMetrics"(student_id);
