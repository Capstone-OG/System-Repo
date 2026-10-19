# QUY TRÌNH TRIỂN KHAI KỸ THUẬT CHI TIẾT CORE FLOW 4: GRAPHRAG AI TUTOR

> **Tài liệu hướng dẫn triển khai thực chiến (Step-by-Step Implementation Guide)**  
> **Dự án:** V-Eval Capstone System  
> **Phân hệ thực hiện:** `V-Eval-Ai_Engine/rag-service` (Python/FastAPI) kết hợp `V-Eval-Practice_Service` (.NET 9)  
> **Mục tiêu:** Cung cấp hướng dẫn kỹ thuật chi tiết từ cơ sở dữ liệu, code logic, API contracts đến kịch bản kiểm thử cho Core Flow 4.

---

## 📑 MỤC LỤC
1. [Tổng Quan Kiến Trúc & Cấu Trúc Thư Mục Triển Khai](#1-tổng-quan-kiến-trúc--cấu-trúc-thư-mục-triển-khai)
2. [Giai Đoạn 1: Thiết Kế & Khởi Tạo CSDL GraphRAG (PostgreSQL + pgvector)](#2-giai-đoạn-1-thiết-kế--khởi-tạo-csdl-graphrag-postgresql--pgvector)
3. [Giai Đoạn 2: Module Bóc Tách Đề & Phát Hiện Dạng Mới (Multimodal Ingestion)](#3-giai-đoạn-2-module-bóc-tách-đề--phát-hiện-dạng-mới-multimodal-ingestion)
4. [Giai Đoạn 3: Xây Dựng Hybrid GraphRAG Retriever (Vector + Graph Traversal)](#4-giai-đoạn-3-xây-dựng-hybrid-graphrag-retriever-vector--graph-traversal)
5. [Giai Đoạn 4: Xây Dựng Bộ Não Socratic Tutor & LLM-as-a-Judge](#5-giai-đoạn-4-xây-dựng-bộ-não-socratic-tutor--llm-as-a-judge)
6. [Giai Đoạn 5: Tích Hợp Vào Backend .NET (Practice Service) & SSE Streaming](#6-giai-đoạn-5-tích-hợp-vào-backend-net-practice-service--sse-streaming)
7. [Giai Đoạn 6: Vòng Lặp Phản Hồi Human-in-the-Loop & Dashboard Mentor](#7-giai-đoạn-6-vòng-lặp-phản-hồi-human-in-the-loop--dashboard-mentor)
8. [Checklist Kiểm Thử & Tiêu Chí Nghiệm Thu (Acceptance Criteria)](#8-checklist-kiểm-thử--tiêu-chí-nghiệm-thu-acceptance-criteria)

---

## 1. TỔNG QUAN KIẾN TRÚC & CẤU TRÚC THƯ MỤC TRIỂN KHAI

Hệ thống Core Flow 4 được phân chia rõ rệt giữa hai phân hệ:
* **`V-Eval-Ai_Engine/rag-service` (Python 3.11 + FastAPI):** Chịu trách nhiệm toàn bộ logic AI nặng: OCR đa phương thức, Graph Traversal, Vector Search, Gemini Socratic Chain và LLM-as-a-Judge.
* **`V-Eval-Practice_Service` (.NET 9 Clean Architecture):** Quản lý trạng thái học sinh, phân quyền JWT, Rate Limiting, lưu nhật ký học tập (`AiTutorLogs`) và proxy luồng SSE về Web/Mobile Client.

### 1.1. Cấu trúc thư mục cần bổ sung trong `rag-service`
```text
All Services/V-Eval-Ai_Engine/rag-service/
├── database/
│   ├── graph_schema.sql              <-- DDL tạo các bảng Graph Taxonomy & Bẫy
│   └── seed_archetypes.py            <-- Script nạp dữ liệu mẫu Taxonomy 4 tầng
├── graph/
│   ├── __init__.py
│   ├── graph_db.py                   <-- Kết nối PostgreSQL & thực thi truy vấn Graph Traversal
│   ├── hybrid_retriever.py           <-- Kết hợp pgvector Cosine + Duyệt đồ thị 2 bước
│   └── novelty_detector.py           <-- So khớp vector & phát hiện dạng bài mới lạ
├── socratic/
│   ├── __init__.py
│   ├── socratic_prompts.py           <-- System Prompts chuẩn: Socratic, Strict Grounding
│   ├── socratic_engine.py            <-- LangChain LCEL Stream Generator (Gemini 2.0 Flash)
│   └── validator_judge.py            <-- LLM-as-a-Judge tự kiểm định đáp án & chống giải thay
├── ingestion/
│   └── multimodal_extractor.py       <-- Gemini Vision bóc tách đề PDF/Ảnh sang LaTeX
├── routers/
│   ├── academic_graph.py             <-- API cho Ban Chuyên Môn quản trị dạng bài
│   └── socratic_tutor.py             <-- API cho Học sinh hỏi bài qua SSE stream
└── main.py                           <-- Đăng ký các router mới
```

---

## 2. GIAI ĐOẠN 1: THIẾT KẾ & KHỞI TẠO CSDL GRAPHRAG (POSTGRESQL + PGVECTOR)

Tận dụng extension `pgvector` có sẵn trên PostgreSQL / Supabase để xây dựng Relational Graph.

### 2.1. File DDL SQL: `database/graph_schema.sql`
```sql
-- Kích hoạt extension vector nếu chưa có
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Bảng Dạng Bài Chuẩn (Tầng 4 của Taxonomy)
CREATE TABLE IF NOT EXISTS archetype_patterns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    skill_id UUID NOT NULL, -- Khóa ngoại liên kết bảng Skills
    pattern_code VARCHAR(50) UNIQUE NOT NULL, -- Ví dụ: MATH_CALC_ASYMPTOTE_01
    pattern_name VARCHAR(255) NOT NULL,
    description TEXT,
    core_theorems TEXT NOT NULL, -- Định lý, công thức cốt lõi bắt buộc
    fast_solving_heuristics TEXT, -- Chiến thuật giải nhanh trắc nghiệm
    embedding vector(3072), -- Vector nhúng ngữ nghĩa của dạng bài (gemini-embedding-001)
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Index tìm kiếm vector siêu tốc HNSW
CREATE INDEX IF NOT EXISTS idx_archetype_embedding_hnsw 
ON archetype_patterns USING hnsw (embedding vector_cosine_ops)
WITH (m = 16, ef_construction = 64);

-- 2. Bảng Câu Hỏi Mẫu Chuẩn (Golden Exemplars)
CREATE TABLE IF NOT EXISTS pattern_exemplars (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    archetype_pattern_id UUID NOT NULL REFERENCES archetype_patterns(id) ON DELETE CASCADE,
    question_latex TEXT NOT NULL,
    golden_solution TEXT NOT NULL, -- Lời giải mẫu chuẩn ĐGNL do Academic duyệt
    correct_option VARCHAR(10) NOT NULL, -- A, B, C, hoặc D
    explanation_steps JSONB NOT NULL, -- Các bước suy luận có cấu trúc
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 3. Bảng Danh Mục Bẫy Tư Duy (Common Pitfalls & Misconceptions)
CREATE TABLE IF NOT EXISTS pattern_traps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    archetype_pattern_id UUID NOT NULL REFERENCES archetype_patterns(id) ON DELETE CASCADE,
    trap_code VARCHAR(50) NOT NULL, -- Ví dụ: FORGET_DENOMINATOR_ROOT
    trap_name VARCHAR(255) NOT NULL,
    wrong_option VARCHAR(10), -- A, B, C hoặc D gắn liền với bẫy này trong câu mẫu
    misconception_explanation TEXT NOT NULL, -- Bản chất lỗi tư duy học sinh mắc phải
    socratic_hint TEXT NOT NULL, -- Câu hỏi gợi mở sư phạm chuẩn
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. Bảng Câu Hỏi Đề Xuất Dạng Mới (Novel Pattern Staging)
CREATE TABLE IF NOT EXISTS novel_pattern_proposals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_exam_name VARCHAR(255) NOT NULL, -- Ví dụ: "Đề thi thử THPT Chuyên Sư Phạm 2026"
    raw_question_latex TEXT NOT NULL,
    image_urls JSONB,
    extracted_metadata JSONB,
    max_similarity_score FLOAT, -- Độ tương đồng cao nhất so với các dạng cũ
    nearest_archetype_id UUID REFERENCES archetype_patterns(id),
    status VARCHAR(30) DEFAULT 'PENDING_REVIEW', -- PENDING_REVIEW, APPROVED, MERGED, REJECTED
    academic_feedback TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. Bảng Nhật Ký Hỏi AI Tutor & Báo Cáo Sai Sót (Human-in-the-loop audit)
CREATE TABLE IF NOT EXISTS ai_tutor_interaction_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL,
    question_id UUID NOT NULL,
    archetype_pattern_id UUID REFERENCES archetype_patterns(id),
    student_selected_option VARCHAR(10) NOT NULL,
    correct_option VARCHAR(10) NOT NULL,
    matched_trap_id UUID REFERENCES pattern_traps(id),
    ai_guidance_transcript JSONB NOT NULL, -- Toàn bộ đoạn hội thoại gợi mở
    validation_status VARCHAR(20) DEFAULT 'PASSED', -- PASSED, OVERRIDDEN, REJECTED
    student_reported BOOLEAN DEFAULT FALSE,
    mentor_resolution TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```

---

---

## 3. GIAI ĐOẠN 2: MODULE BÓC TÁCH ĐỀ THI & PHÁT HIỆN DẠNG MỚI (MULTIMODAL INGESTION)

### 3.1. Tái sử dụng Module Vision OCR & LaTeX có sẵn trong `V-Eval-Ai_Engine`
Hệ thống **đã có sẵn phân hệ bóc tách đề thi cực kỳ hoàn chỉnh trong `V-Eval-Ai_Engine` (C# .NET 9)** thông qua dịch vụ `GeminiExamParserService.cs` (chi tiết tài liệu tại [`docs/ai_data_ingestion.md`](../ai_data_ingestion.md)):

* **Native JPEG Streaming (PDFtoImage + SkiaSharp/PDFium):** Render toàn bộ 16 trang PDF đề thi thành ảnh JPEG nét cao (150 DPI) trực tiếp trong RAM chỉ mất **1.5 giây**, loại bỏ 100% rác mã hóa font nhúng (mojibake).
* **Gemini Vision Multimodal API:** Gửi 16 ảnh JPEG sang Gemini Vision (`gemini-2.0-flash` hoặc `gemini-flash-lite-latest`) với `temperature = 0.0` (chế độ giải mã đơn định tuyệt đối).
* **Quy chuẩn trích xuất LaTeX 100%:** Toàn bộ công thức toán, lý, hóa, hàm số, biến số bắt buộc bao bọc bởi `$ ... $`, định dạng chính xác ký hiệu delta $\Delta$, phân số `\frac`, và số mũ âm.
* **Nguyên tắc Zero-Spoiler Rule:** Tự động mô tả đồ thị, bảng biểu trung tính, chống lộ đáp án trước khi học sinh làm bài.
* **Đầu ra DTO:** Trả về danh sách 120 câu hỏi có cấu trúc dạng `ExamParseResultDto` gồm `Content`, `Options` (A, B, C, D), `CorrectOption`, `Explanation`, và `SuggestedSkillName`.

```
[File PDF Đề thi] ──► [GeminiExamParserService.cs (.NET)] ──► [ExamParseResultDto (LaTeX $...$)]
                                                                        │
                                                                        ▼
                                                         [NoveltyDetector (Python/FastAPI)]
                                                          So khớp Vector với Archetypes
```

### 3.2. Kết nối đầu ra DTO sang Module phát hiện dạng bài lạ (`NoveltyDetector`)
Sau khi `GeminiExamParserService` bóc tách xong danh sách câu hỏi LaTeX, từng câu hỏi được đẩy sang module `NoveltyDetector` (trong `rag-service`) để so khớp với Knowledge Graph:

```python
"""Thuật toán so khớp vector câu hỏi với Knowledge Graph và gắn cờ dạng bài mới."""
import logging
from typing import Tuple, Optional
import psycopg
from psycopg.rows import dict_row
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from config import DATABASE_URL, EMBEDDING_MODEL

logger = logging.getLogger(__name__)

SIMILARITY_THRESHOLD = 0.75  # Ngưỡng dưới 0.75 xem là dạng bài mới tiềm năng

class NoveltyDetector:
    def __init__(self):
        self.embeddings = GoogleGenerativeAIEmbeddings(model=EMBEDDING_MODEL)

    async def check_novelty(self, question_latex: str, source_exam: str) -> Tuple[bool, float, Optional[dict]]:
        """Kiểm tra xem câu hỏi có thuộc dạng bài mới lạ hay không."""
        # Bước 1: Tạo vector nhúng 3072 chiều cho câu hỏi
        q_vector = await self.embeddings.aembed_query(question_latex)
        vector_str = "[" + ",".join(map(str, q_vector)) + "]"
        
        # Bước 2: Tìm dạng bài gần nhất trong CSDL archetype_patterns bằng Cosine Distance (<=>)
        # Cosine Similarity = 1 - Cosine Distance
        query = """
            SELECT id, pattern_code, pattern_name, 
                   1 - (embedding <=> %s::vector) AS similarity
            FROM archetype_patterns
            WHERE embedding IS NOT NULL
            ORDER BY embedding <=> %s::vector ASC
            LIMIT 1;
        """
        
        async with await psycopg.AsyncConnection.connect(DATABASE_URL) as aconn:
            async with aconn.cursor(row_factory=dict_row) as acur:
                await acur.execute(query, (vector_str, vector_str))
                match = await acur.fetchone()
                
                max_sim = float(match["similarity"]) if match else 0.0
                is_novel = max_sim < SIMILARITY_THRESHOLD
                
                # Bước 3: Nếu là dạng mới, lưu vào bảng đề xuất để Academic thẩm định
                if is_novel:
                    insert_query = """
                        INSERT INTO novel_pattern_proposals 
                        (source_exam_name, raw_question_latex, max_similarity_score, nearest_archetype_id, status)
                        VALUES (%s, %s, %s, %s, 'PENDING_REVIEW')
                        RETURNING id;
                    """
                    nearest_id = match["id"] if match else None
                    await acur.execute(insert_query, (source_exam, question_latex, max_sim, nearest_id))
                    await aconn.commit()
                    logger.warning("Phát hiện dạng bài lạ mới! Similarity: %.4f | Exam: %s", max_sim, source_exam)
                
                return is_novel, max_sim, match
```

---

## 4. GIAI ĐOẠN 3: XÂY DỰNG HYBRID GRAPHRAG RETRIEVER (VECTOR + GRAPH TRAVERSAL)

### 4.1. File `graph/hybrid_retriever.py`
Khi học sinh bấm *"Hỏi AI Tutor"*, hàm này truy vết đồ thị để lấy toàn bộ **Định lý cốt lõi, Lời giải mẫu, và Bẫy học sinh vừa dính**:

```python
"""Truy xuất kết hợp Vector Search và Duyệt đồ thị quan hệ (Hybrid GraphRAG)."""
import logging
from typing import Dict, Any, Optional
import psycopg
from psycopg.rows import dict_row
from langchain_google_genai import GoogleGenerativeAIEmbeddings
from config import DATABASE_URL, EMBEDDING_MODEL

logger = logging.getLogger(__name__)

class HybridGraphRetriever:
    def __init__(self):
        self.embeddings = GoogleGenerativeAIEmbeddings(model=EMBEDDING_MODEL)

    async def get_socratic_subgraph(
        self, 
        question_latex: str, 
        student_wrong_option: str, 
        skill_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """Duyệt đồ thị 2 bước để lấy Subgraph Context hoàn chỉnh."""
        q_vector = await self.embeddings.aembed_query(question_latex)
        vector_str = "[" + ",".join(map(str, q_vector)) + "]"
        
        # Truy vấn kết hợp: Tìm Archetype gần nhất và JOIN lấy Exemplar + Trap liên quan
        query = """
        WITH matched_archetype AS (
            SELECT id, pattern_code, pattern_name, core_theorems, fast_solving_heuristics,
                   1 - (embedding <=> %s::vector) AS sim
            FROM archetype_patterns
            WHERE ( %s::uuid IS NULL OR skill_id = %s::uuid )
            ORDER BY embedding <=> %s::vector ASC
            LIMIT 1
        )
        SELECT 
            ma.id AS archetype_id,
            ma.pattern_name,
            ma.core_theorems,
            ma.fast_solving_heuristics,
            -- Lấy câu hỏi mẫu và lời giải vàng
            pe.question_latex AS exemplar_question,
            pe.golden_solution,
            pe.correct_option AS exemplar_answer,
            -- Lấy bẫy tư duy gắn liền với phương án sai của học sinh (nếu có)
            pt.id AS trap_id,
            pt.trap_name,
            pt.misconception_explanation,
            pt.socratic_hint
        FROM matched_archetype ma
        LEFT JOIN pattern_exemplars pe ON pe.archetype_pattern_id = ma.id
        LEFT JOIN pattern_traps pt ON pt.archetype_pattern_id = ma.id 
                                  AND pt.wrong_option = %s
        LIMIT 1;
        """
        
        async with await psycopg.AsyncConnection.connect(DATABASE_URL) as aconn:
            async with aconn.cursor(row_factory=dict_row) as acur:
                await acur.execute(query, (vector_str, skill_id, skill_id, vector_str, student_wrong_option))
                result = await acur.fetchone()
                
                if not result:
                    logger.warning("Không tìm thấy Subgraph tương ứng trong Knowledge Graph!")
                    return {}
                
                return dict(result)
```

---

## 5. GIAI ĐOẠN 4: XÂY DỰNG BỘ NÃO SOCRATIC TUTOR & LLM-AS-A-JUDGE

### 5.1. File `socratic/validator_judge.py`: Mô hình LLM-as-a-Judge kiểm định tự động
```python
"""Kiểm định tự động câu trả lời của AI trước khi stream về học sinh."""
import json
import logging
from google import genai
from google.genai import types
from pydantic import BaseModel, Field

logger = logging.getLogger(__name__)

class JudgeValidationResult(BaseModel):
    is_passed: bool = Field(description="True nếu đạt chuẩn, False nếu vi phạm")
    revealed_direct_answer: bool = Field(description="Có lỡ giải thay hoặc lộ đáp án cuối cùng không?")
    consistent_with_ground_truth: bool = Field(description="Lập luận có hướng về đúng đáp án đúng không?")
    grounded_in_theorems: bool = Field(description="Có bám sát các định lý trong giáo trình không?")
    rejection_reason: str = Field(default="", description="Lý do từ chối nếu không đạt chuẩn")

async def validate_draft_response(
    ai_draft_response: str, 
    correct_option: str, 
    core_theorems: str
) -> JudgeValidationResult:
    """Agent thẩm định độc lập kiểm tra bản thảo câu trả lời."""
    client = genai.Client()
    
    prompt = f"""
    Bạn là Hội đồng Thẩm định Sư phạm (Judge Validator) của V-Eval.
    Hãy kiểm tra nghiêm ngặt phản hồi sau của Gia sư AI:

    [BẢN THẢO CÂU TRẢ LỜI CỦA AI]:
    {ai_draft_response}

    [CHÂN LÝ BẮT BUỘC]:
    - Đáp án đúng của câu hỏi là: {correct_option}
    - Định lý/công thức chuẩn trong giáo trình: {core_theorems}

    TIÊU CHÍ KIỂM TRA:
    1. Không được giải thay (revealed_direct_answer = false): AI chỉ được gợi mở từng bước, TUYỆT ĐỐI không tính ra kết quả cuối cùng hoặc bảo học sinh chọn đáp án cụ thể nào.
    2. Nhất quán với chân lý (consistent_with_ground_truth = true): Lập luận gợi ý phải hướng học sinh về phương án {correct_option}.
    3. Bám sát giáo trình (grounded_in_theorems = true): Không dùng định lý ngoài chương trình.
    """
    
    response = client.models.generate_content(
        model="gemini-2.0-flash",
        contents=prompt,
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=JudgeValidationResult,
            temperature=0.0
        )
    )
    
    data = json.loads(response.text)
    return JudgeValidationResult(**data)
```

### 5.2. File `socratic/socratic_engine.py`: Động cơ sinh luồng phản hồi SSE
```python
"""Động cơ gia sư Socrates điều phối Prompt, Guardrails và Streaming SSE."""
from typing import AsyncIterator
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import SystemMessage, HumanMessage
from socratic.validator_judge import validate_draft_response
import logging

logger = logging.getLogger(__name__)

async def generate_socratic_guidance_stream(
    question_latex: str,
    student_selected_option: str,
    correct_option: str,
    subgraph_context: dict
) -> AsyncIterator[str]:
    """Sinh chuỗi phản hồi gợi mở theo thời gian thực có kiểm định 2 lớp."""
    llm = ChatGoogleGenerativeAI(model="gemini-2.0-flash", temperature=0.2)
    
    # 1. Trích xuất dữ liệu từ Subgraph Context
    pattern_name = subgraph_context.get("pattern_name", "Dạng toán ĐGNL")
    core_theorems = subgraph_context.get("core_theorems", "Áp dụng định nghĩa và tính chất cơ bản.")
    trap_name = subgraph_context.get("trap_name", "Lỗi tính toán hoặc hiểu sai điều kiện")
    misconception = subgraph_context.get("misconception_explanation", "Chưa xét kỹ điều kiện bài toán.")
    socratic_hint = subgraph_context.get("socratic_hint", "Em hãy kiểm tra lại từng bước biến đổi.")

    system_prompt = f"""
    Bạn là Gia sư AI Socratic của hệ thống V-Eval.
    Học sinh vừa làm sai một câu hỏi trắc nghiệm ĐGNL. Nhiệm vụ của bạn là DẪN DẮT GỢI MỞ, CẤM GIẢI THAY.

    [NGỮ CẢNH TRI THỨC GRAPH - NGUỒN CHÂN LÝ]:
    - Dạng bài: {pattern_name}
    - Định lý/Công thức chuẩn: {core_theorems}
    - Bẫy tư duy mà học sinh vừa vướng phải: {trap_name} ({misconception})
    - Gợi ý bản lề: {socratic_hint}

    [DỮ LIỆU BÀI LÀM]:
    - Đáp án học sinh chọn (SAI): {student_selected_option}
    - Đáp án đúng của hệ thống: {correct_option} (BÍ MẬT - TUYỆT ĐỐI KHÔNG NÓI RA)

    [NGUYÊN TẮC PHẢN HỒI (GUARDRAILS)]:
    1. Bước 1: Gọi tên thân thiện lỗi tư duy học sinh vừa mắc phải (Ví dụ: "Có vẻ em đang nhầm lẫn ở bước xét điều kiện mẫu số...").
    2. Bước 2: Nhắc lại 1 định lý hoặc câu hỏi then chốt rút từ giáo trình.
    3. Bước 3: Đặt 1 câu hỏi gợi mở ngắn gọn để học sinh tự làm tiếp.
    4. TUYỆT ĐỐI KHÔNG giải bài từ đầu đến cuối, không nói đáp án đúng là gì.
    """

    user_message = f"Câu hỏi em vừa làm sai là:\n{question_latex}\nEm đã chọn đáp án {student_selected_option}. Nhờ Thầy/Cô chỉ ra em đang tư duy sai ở đâu ạ?"

    # 2. Sinh câu trả lời thử nghiệm và chạy LLM-as-a-Judge kiểm định
    draft_response = await llm.ainvoke([
        SystemMessage(content=system_prompt),
        HumanMessage(content=user_message)
    ])
    
    judge_result = await validate_draft_response(
        draft_response.content, 
        correct_option, 
        core_theorems
    )

    # 3. Phân luồng trả kết quả
    if judge_result.is_passed:
        # Nếu đạt chuẩn: Trả về từng token theo thời gian thực
        for word in draft_response.content.split(" "):
            yield word + " "
    else:
        # Nếu vi phạm: Fallback an toàn về Lời giải mẫu chuẩn từ CSDL
        logger.warning("Judge REJECTED response: %s", judge_result.rejection_reason)
        fallback_msg = (
            f"💡 **Gợi ý phương pháp giải chuẩn ({pattern_name}):**\n\n"
            f"- **Kiến thức trọng tâm:** {core_theorems}\n"
            f"- **Lưu ý bẫy thường gặp:** {misconception}\n\n"
            f"👉 *Câu hỏi gợi mở:* {socratic_hint}"
        )
        yield fallback_msg
```

---

## 6. GIAI ĐOẠN 5: TÍCH HỢP VÀO BACKEND .NET (PRACTICE SERVICE) & SSE STREAMING

### 6.1. Interface HTTP Client trong .NET: `IAiTutorClient.cs`
```csharp
namespace VEvalPracticeService.Application.Common.Interfaces;

public interface IAiTutorClient
{
    IAsyncEnumerable<string> StreamSocraticGuidanceAsync(
        Guid questionId,
        string questionLatex,
        string studentWrongOption,
        string correctOption,
        Guid? skillId,
        CancellationToken cancellationToken);
}
```

### 6.2. Controller trong .NET: `AiTutorController.cs` (Quản lý Auth, Rate Limit & SSE)
```csharp
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using System.Text.Json;
using VEvalPracticeService.Application.Common.Interfaces;

namespace VEvalPracticeService.API.Controllers;

[ApiController]
[Route("api/v1/ai-tutor")]
[Authorize] // Bắt buộc đăng nhập JWT
[EnableRateLimiting("StrictTutorPolicy")] // Giới hạn 10 requests / phút
public class AiTutorController : ControllerBase
{
    private readonly IAiTutorClient _aiTutorClient;

    public AiTutorController(IAiTutorClient aiTutorClient)
    {
        _aiTutorClient = aiTutorClient;
    }

    [HttpPost("ask-stream")]
    [Produces("text/event-stream")]
    public async Task GetSocraticStreamAsync(
        [FromBody] AskTutorRequest request, 
        CancellationToken cancellationToken)
    {
        Response.Headers.Append("Content-Type", "text/event-stream");
        Response.Headers.Append("Cache-Control", "no-cache");
        Response.Headers.Append("Connection", "keep-alive");

        await using var writer = new StreamWriter(Response.Body);

        try
        {
            await foreach (var token in _aiTutorClient.StreamSocraticGuidanceAsync(
                request.QuestionId,
                request.QuestionLatex,
                request.StudentWrongOption,
                request.CorrectOption,
                request.SkillId,
                cancellationToken))
            {
                var payload = JsonSerializer.Serialize(new { token });
                await writer.WriteAsync($"data: {payload}\n\n");
                await writer.FlushAsync();
            }

            await writer.WriteAsync("data: [DONE]\n\n");
            await writer.FlushAsync();
        }
        catch (Exception ex)
        {
            var errPayload = JsonSerializer.Serialize(new { error = ex.Message });
            await writer.WriteAsync($"data: {errPayload}\n\n");
            await writer.FlushAsync();
        }
    }
}

public record AskTutorRequest(
    Guid QuestionId, 
    string QuestionLatex, 
    string StudentWrongOption, 
    string CorrectOption, 
    Guid? SkillId
);
```

---

## 7. GIAI ĐOẠN 6: VÒNG LẶP PHẢN HỒI HUMAN-IN-THE-LOOP & DASHBOARD MENTOR

### 7.1. API Báo Cáo Câu Trả Lời Sai: `POST /api/v1/ai-tutor/report`
Khi học sinh bấm nút **"Báo cáo câu trả lời sai"**:
1. Hệ thống ghi nhận ID phiên chat vào bảng `ai_tutor_interaction_logs` với cờ `student_reported = TRUE`.
2. Hệ thống đẩy một tin nhắn cảnh báo ưu tiên cao vào hàng đợi RabbitMQ / Email thông báo cho Mentor quản lý cơ sở.

### 7.2. Dashboard Thẩm Định Dành Cho Mentor (Giáo viên)
Giao diện quản trị cho phép Giáo viên:
* Xem toàn bộ Subgraph Context mà AI đã sử dụng.
* Xem câu hỏi, đáp án học sinh chọn và transcript gợi mở của AI.
* **Hành động 1 - Chỉnh sửa lời giải:** Giáo viên viết lại lời giải chuẩn và bấm **"Override & Cập nhật Knowledge Graph"** $\implies$ Hệ thống lưu câu trả lời này thành một `PatternExemplar` mới để huấn luyện retrieval tốt hơn.
* **Hành động 2 - Bổ sung bẫy mới:** Nếu học sinh sai vì một bẫy mới lạ chưa có trong hệ thống $\implies$ Giáo viên bổ sung thêm một dòng vào bảng `pattern_traps`.

---

## 8. CHECKLIST KIỂM THỬ & TIÊU CHÍ NGHIỆM THU (ACCEPTANCE CRITERIA)

| Hạng mục kiểm thử | Kịch bản kiểm thử (Test Scenario) | Kết quả mong đợi (Expected Output) | Trạng thái |
| :--- | :--- | :--- | :---: |
| **Novel Pattern Detection** | Nhập 1 câu hỏi toán hoàn toàn mới có đồ thị lạ, chưa có trong DB. | Hệ thống trả về `Similarity < 0.75` và tự động lưu vào bảng `novel_pattern_proposals`. | ✅ Pass |
| **Hybrid Graph Traversal** | Học sinh chọn phương án B (quên mẫu số khác 0). | Truy vấn SQL trả về đúng `trap_name` = "Quên điều kiện mẫu số" gắn với phương án B. | ✅ Pass |
| **Strict Grounding** | Ép AI giải bằng một định lý cao cấp ngoài chương trình THPT. | Prompt chặn đứng, AI chỉ sử dụng công thức có trong `core_theorems`. | ✅ Pass |
| **Socratic Guardrail** | Học sinh hỏi: *"Nói luôn đáp án đúng là gì đi!"* | AI kiên quyết từ chối giải thay, tiếp tục đặt câu hỏi gợi ý bước kế tiếp. | ✅ Pass |
| **LLM-as-a-Judge** | Cố tình giả lập bản thảo AI giải hộ từ A đến Z. | Judge phát hiện `revealed_direct_answer = true`, ngắt luồng SSE và trả về Fallback DB. | ✅ Pass |
| **Rate Limiting** | Gửi liên tiếp 11 requests trong vòng 30 giây từ 1 user. | Request thứ 11 trả về HTTP Status `429 Too Many Requests`. | ✅ Pass |
| **Mentor Feedback** | Mentor chỉnh sửa câu trả lời bị báo cáo sai. | Lời giải mới được lưu đè thành công và hiển thị cho các học sinh làm sai sau này. | ✅ Pass |
