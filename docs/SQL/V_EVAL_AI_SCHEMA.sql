-- =====================================================================
-- V-EVAL PLATFORM — AI ENGINE SCHEMA (v_eval_ai)
-- Đồng bộ với kiến trúc Vector DB (pgvector) cho RAG Tri Thức SGK
-- Thực thi trên Supabase PostgreSQL Cloud
-- =====================================================================

-- 1. Bật Extension pgvector
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. Khởi tạo Schema v_eval_ai
CREATE SCHEMA IF NOT EXISTS v_eval_ai;

-- 3. Bảng Nguồn Tri Thức / Sách Giáo Khoa (KnowledgeSources)
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
  "created_at" timestamp DEFAULT now(),
  "updated_at" timestamp DEFAULT now()
);

-- 4. Bảng Vector Chunks Tri Thức Phân Đoạn (KnowledgeVectorChunks)
CREATE TABLE IF NOT EXISTS v_eval_ai."KnowledgeVectorChunks" (
  "chunk_id" uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  "source_id" uuid NOT NULL REFERENCES v_eval_ai."KnowledgeSources"("source_id") ON DELETE CASCADE,
  "domain_id" varchar(100),
  "skill_id" varchar(100),
  "chunk_index" int NOT NULL,
  "page_number" int DEFAULT 1,
  "content_snippet" text NOT NULL,
  "embedding" vector(768),                         -- Vector 768 chiều (Gemini text-embedding-004)
  "document_type" varchar(50) DEFAULT 'TEXTBOOK',
  "char_count" int DEFAULT 0,
  "metadata" jsonb,                                -- Thông tin mở rộng (header, chương, tiêu đề phụ...)
  "created_at" timestamp DEFAULT now()
);

-- 5. Tạo HNSW Index phục vụ tìm kiếm Vector Cosine Similarity siêu tốc (<5ms)
CREATE INDEX IF NOT EXISTS "idx_knowledge_vector_hnsw" 
ON v_eval_ai."KnowledgeVectorChunks" 
USING hnsw ("embedding" vector_cosine_ops);

-- 6. Tạo Index tra cứu metadata và lọc theo môn / kỹ năng
CREATE INDEX IF NOT EXISTS "idx_knowledge_chunks_source" ON v_eval_ai."KnowledgeVectorChunks" ("source_id");
CREATE INDEX IF NOT EXISTS "idx_knowledge_chunks_domain" ON v_eval_ai."KnowledgeVectorChunks" ("domain_id");
CREATE INDEX IF NOT EXISTS "idx_knowledge_chunks_skill" ON v_eval_ai."KnowledgeVectorChunks" ("skill_id");
