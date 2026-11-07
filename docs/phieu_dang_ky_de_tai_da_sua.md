# CAPSTONE PROJECT REGISTER (BẢN ĐÃ CHỈNH SỬA HOÀN CHỈNH - V2)

> [!NOTE]
> - **File Word hoàn chỉnh mới nhất**: [`FA26SE090_AI_POWERED_PERSONALIZED_LEARNING_PATH_PL_Updated_v2.docx`](./FA26SE090_AI_POWERED_PERSONALIZED_LEARNING_PATH_PL_Updated_v2.docx)
> - **File mẫu gốc đối chiếu**: [`FA26SE090_AI_POWERED_PERSONALIZED_LEARNING_PATH_PL_taint.docx`](./FA26SE090_AI_POWERED_PERSONALIZED_LEARNING_PATH_PL_taint.docx)
> - **Đã khắc phục toàn bộ 7 điểm rà soát**:
>   1. Đồng bộ nhất quán **Parent Web Portal** giữa cả 3 mục (*System Roles*, *Deliverables* và *Proposed Tasks*).
>   2. **Chia lại khối lượng công việc cân bằng đều cho 4 thành viên** (chuyển *AI Tutor UI* sang `Member 3` cùng phần AI/RAG; giao `Member 2` phụ trách cả *Management APIs* lẫn *Web Portals* để san tải Backend với `Leader`).
>   3. Khôi phục đầy đủ 2 dòng tính năng gốc của Thầy Tài: `Monitor AI recommendation quality` (Teacher) và `Receive personalized study recommendations` (Student).
>   4. Làm mềm phần Tech Stack (`Python` thay vì khóa cứng `FastAPI`, `PostgreSQL & Vector Search Storage`).
>   5. Điền mã `Class: FA26SE090`, đánh dấu rõ ô `[x] Students` ở người đăng ký và cập nhật ngày ký `29/10/2026`.
>   6. Bổ sung **Bảng tóm tắt các điểm chỉnh sửa (Changelog)** ở cuối tài liệu để nhóm gửi xin xác nhận trực tiếp từ Thầy Nguyễn Trọng Tài trước khi nộp.

---

**CAPSTONE PROJECT REGISTER**  
**Class:** `FA26SE090` — **Duration time:** from `09/2026` To `03/2027`  
**(\*) Profession:** Software Engineer — **Specialty:** SE  
**(\*) Kinds of person make registers:** `[ ]` Lecturer &nbsp;&nbsp;&nbsp; `[x]` Students  

### 1. Register information for supervisor (if have)

| No. | Full name | Phone | E-Mail | Title |
| :---: | :--- | :---: | :--- | :---: |
| Supervisor | Nguyễn Trọng Tài | | `taint@fpt.edu.vn` | Giảng viên |

### 2. Register information for students (if have)

| No. | Full name | Student code | Phone | E-mail | Role in Group |
| :---: | :--- | :---: | :---: | :--- | :---: |
| 1 | Phạm Tấn Lộc | SE184400 | 0373097930 | `Locptse184400@fpt.edu.vn` | Leader |
| 2 | Trần Thái Thịnh | SE182004 | 0338606577 | `Thinhttse182004@fpt.edu.vn` | Member |
| 3 | Nguyễn Duy Khôi | SE184910 | 0783629758 | `Khoindse184910@fpt.edu.vn` | Member |
| 4 | Mai Thành Nhân | SE184916 | 0908554754 | `Nhanmtse184916@fpt.edu.vn` | Member |
| 5 | | | | | |

---

### 3. Register content of Capstone Project

#### (\*) 3.1. Capstone Project name:
- **3.1.1. English:** AI-powered Personalized Learning Path Platform for Competency Assessment Exam Preparation
- **3.1.2. Vietnamese:** Hệ thống cá nhân hóa lộ trình học và luyện thi Đánh giá năng lực tích hợp AI

#### (\*) 3.2. Main proposal content (including result and product)

##### a) Context:
In recent years, Competency Assessment Examinations have become one of the primary admission methods adopted by many universities in Vietnam. Unlike traditional examinations that mainly evaluate memorized knowledge, competency assessment focuses on measuring students' logical reasoning, analytical thinking, reading comprehension, quantitative reasoning, and problem-solving abilities.

Although numerous online learning platforms and examination preparation systems are available, most of them provide identical learning content and predefined study plans for every learner. Such an approach does not consider individual differences in academic background, learning pace, target scores, available study time, or knowledge mastery.

Consequently, many students spend excessive time reviewing topics they have already mastered while overlooking weaker knowledge areas that require additional practice. Teachers and parents also lack effective tools to monitor learning progress, evaluate competency development, and provide timely guidance.

With the rapid advancement of Artificial Intelligence and Educational Data Analytics, personalized learning has become a promising approach for improving learning efficiency. By continuously analyzing students' learning behaviors, assessment results, and learning patterns, AI can generate adaptive study plans tailored to each learner's competency and continuously refine those plans based on real-time performance.

Therefore, this project proposes the development of an AI-powered personalized learning platform that supports competency assessment exam preparation through intelligent study planning, adaptive practice recommendation, learning analytics, and AI-assisted tutoring.

##### b) Proposed Solutions:
The proposed system aims to build an intelligent learning platform that continuously analyzes students' academic performance and automatically personalizes their learning journey throughout the examination preparation process.

Instead of providing a static curriculum, the platform dynamically adjusts learning objectives, recommended lessons, practice exercises, and examination strategies according to each student's competency profile and learning progress.

The system provides comprehensive support for both learners and educators through the following capabilities:
- Managing learning materials, question banks, mock examinations, and competency frameworks.
- Conducting diagnostic assessments to identify each student's strengths and weaknesses.
- Generating personalized learning paths according to target scores and available preparation time.
- Recommending adaptive learning content and practice questions.
- Monitoring learning progress using learning analytics dashboards.
- Providing AI-powered tutoring for question explanation, concept clarification, and knowledge summarization.
- Predicting examination performance and recommending learning adjustments.
- Supporting teachers and parents in monitoring students' learning progress through analytical reports.

The primary objective is to establish an adaptive learning ecosystem where every learner follows an individualized study plan that continuously evolves according to their academic performance and learning behavior.

**\*\*\* System Roles**
- **Administrator**
  - Manage user accounts, system roles, and access permissions.
  - Manage campus directories and general platform configurations.
  - Configure AI services and system settings.
  - Monitor overall platform operations, data backups, and system health.
- **Academic Director**
  - Define, approve, and govern standardized competency frameworks and knowledge structures.
  - Oversee and ensure the quality of the master question bank and reference knowledge base for AI.
  - Configure academic evaluation standards and review cross-campus educational quality reports.
- **Academic Manager**
  - Coordinate academic operations, class schedules, and teacher assignments.
  - Review and approve student class placements and coordinate mock examination schedules.
  - Monitor student engagement and coordinate timely academic support for at-risk learners.
- **Teacher**
  - Develop, upload, and organize learning materials, practice exercises, and mock examinations.
  - Evaluate question quality and review AI-assisted educational content.
  - Review students' learning progress and provide pedagogical feedback.
  - Monitor AI recommendation quality.
- **Student**
  - Complete diagnostic assessments and set target examination scores on the web platform.
  - Follow personalized learning paths and practice adaptive exercises and mock examinations on the web platform.
  - Interact with AI Tutor for guided academic explanations.
  - Receive personalized study recommendations.
  - View learning dashboards, schedules, reports, and track predicted examination performance via the web platform and companion mobile app.
- **Parent**
  - Monitor students' learning progress via the parent web portal and companion mobile app.
  - View competency development reports.
  - Receive learning alerts and notifications.
  - Track target score achievement.
  - Monitor study schedules and examination readiness.
- **AI Recommendation Engine and Chat Bot**
  - Analyze student learning profiles and assessment behaviors.
  - Generate personalized learning paths and adaptive study recommendations.
  - Predict examination performance.
  - Explain examination questions and provide guided step-by-step explanations.
  - Answer students' academic questions grounded in learning resources.
- **Research-Based Learning (RBL) - Research Topics**
  - Adaptive Learning Systems
  - Intelligent Tutoring Systems
  - Educational Recommendation Systems
  - Knowledge Tracing
  - Student Performance Prediction
  - Learning Analytics
  - Educational Data Mining
  - Large Language Models for Education
  - Retrieval-Augmented Generation

##### c) Functional Requirements:
**\*\*\* Business Core Flows**

**Core Flow 1. Competency Diagnosis and Learning Profile Generation**  
Students begin by taking a diagnostic assessment designed to evaluate their competency across multiple knowledge domains and cognitive skills. The system analyzes assessment results together with behavioral learning indicators to establish a comprehensive Learning Profile that reflects each student's current competency level, learning preferences, and areas requiring improvement.

**Core Flow 2. Personalized Learning Path Planning**  
Based on the generated Learning Profile, the student's target examination score, and the available preparation period, the AI engine constructs a personalized study roadmap. The roadmap specifies learning priorities, recommended learning sequences, study schedules, revision milestones, and practice strategies tailored to the student's individual needs.

**Core Flow 3. Adaptive Learning and Continuous Recommendation**  
Throughout the learning process on the web platform, students complete lessons, adaptive quizzes, and mock examinations recommended by the system. Learning performance is continuously analyzed, allowing AI to dynamically update competency estimations and recommend subsequent learning activities with appropriate difficulty levels and knowledge coverage.

**Core Flow 4. AI-assisted Learning Support**  
Students can interact with an AI Tutor during their learning journey on the web platform. The AI Tutor provides guided step-by-step explanations, clarifies incorrect answers, summarizes complex concepts, recommends study techniques, and answers academic questions grounded in contextual learning resources.

**Core Flow 5. Learning Analytics and Progress Monitoring**  
The platform continuously collects learning activities, including study duration, quiz performance, competency improvement, learning consistency, and engagement metrics. Interactive dashboards visualize these indicators on the web portals for students, teachers, academic managers, academic directors, and parents, while key progress summaries and notifications are also accessible via the companion mobile application.

**Core Flow 6. Examination Performance Prediction**  
Using historical learning data, competency progression, and behavioral analytics, the AI engine estimates each student's expected performance and probability of achieving the desired examination score. The system also identifies potential risks early and recommends learning adjustments to help learners reach their targets.

##### d) Non-Functional Requirements:
- Responsive and smooth system performance for standard learning, assessment, and AI tutoring operations.
- Reliable concurrent access supporting online learning and examination activities across classes and campuses.
- Secure authentication using JWT with Role-Based Access Control (RBAC) across all system roles.
- Modular and scalable architecture separating Web, Companion Mobile, Backend, AI Services, and Analytics components.
- Secure storage of learning and assessment data with scheduled backup and recovery mechanisms.
- Containerized and cloud-ready deployment supporting service stability, maintainability, and scalability.
- APIs designed for future integration with external educational tools and additional examination frameworks.

##### e) Theory & Practical:
- Web Application: ReactJS (Primary platform for interactive learning, adaptive practice, examinations, AI tutoring, and management portals)
- Mobile Application: React Native (Companion mobile app for viewing learning progress, schedules, reports, and notifications)
- Backend Services: ASP.NET Core Web API & Python
- Database & Vector Storage: PostgreSQL & Vector Search Storage
- Authentication: JWT & Role-Based Access Control (RBAC)
- Large Language Models (LLMs)
- Retrieval-Augmented Generation (RAG)
- Educational Recommendation Systems
- Psychometric & Knowledge Tracing Models
- Machine Learning & Student Performance Prediction
- Educational Data Mining & Learning Analytics
- **AI Integration:**
  - Large Language Model (LLM) APIs
  - Retrieval-Augmented Generation (RAG) Frameworks
  - Adaptive Recommendation System
  - Knowledge Tracing Models
  - Student Performance Prediction Models
- Deployment & Infrastructure: Docker & Cloud/Server Deployment
- CI/CD: GitHub Actions
- Version Control: GitHub

The project integrates Software Engineering principles with Artificial Intelligence, Educational Data Mining, Learning Analytics, and Adaptive Learning methodologies to develop a scalable intelligent learning platform capable of delivering personalized learning experiences and AI-assisted examination preparation.

##### f) Products (Expected Deliverables):
The expected deliverables include:
- Web application for students (supporting diagnostic assessments, personalized learning paths, adaptive practice, mock examinations, and AI Tutor interaction).
- Web portal for teachers, academic managers, academic directors, and system administrators.
- Parent web portal for learning progress and competency monitoring.
- Companion mobile application (React Native) for students and parents (for viewing learning progress, schedules, analytical reports, and notifications).
- Backend platform for learning, assessment, and user data management.
- AI Recommendation Engine and Personalized Learning Path Management Module.
- AI Tutor integrated with LLM and RAG.
- Learning Analytics and Academic Management Dashboards.
- Examination Performance Prediction Module.

##### g) Proposed Tasks:
1. Perform requirement analysis, system architecture and database design, API Gateway, and core learning/assessment backend services - **Leader**
2. Develop the student web learning application (diagnostic assessment, personalized learning path, adaptive practice, mock examinations) and the companion mobile app for viewing progress, schedules, reports, and notifications - **Member 1**
3. Develop the web portals and management APIs for administrators, academic directors, academic managers, teachers, and parents, including competency framework governance, question bank & content management, dashboards, and user management - **Member 2**
4. Design and implement AI and analytics components, including the Recommendation Engine, Knowledge Tracing, Student Performance Prediction, and LLM-based AI Tutor (RAG pipeline and conversational interface) - **Member 3**
5. Conduct system integration, testing, performance optimization, deployment, technical documentation, and final Capstone report preparation - **All Members**

---

### 4. Other comments (propose all relative things if have):
- Interactive learning activities, adaptive practice, and timed examinations are delivered on the Web platform to ensure optimal display for complex reading passages and academic expressions, whereas the companion mobile application is dedicated to viewing study progress, schedules, analytical reports, and notifications.
- Predicted examination scores and early learning alerts serve as supportive reference indicators based on learners' practice data within the platform.

---

| Supervisor (If have) | HCM, date 29/10/2026 — On behalf of Registers |
| :---: | :---: |
| *(Sign and full name)* | *(Sign and full name)* |

---

## PHỤ LỤC GỬI XIN XÁC NHẬN GVHD THẦY NGUYỄN TRỌNG TÀI (KHÔNG NẰM TRONG FILE WORD NỘP)

> [!IMPORTANT]
> Vì phiếu gốc do Thầy Nguyễn Trọng Tài khởi tạo ngày `19/08/2026`, nhóm cần gửi kèm 5 gạch đầu dòng tóm tắt minh bạch dưới đây để xin Thầy xác nhận trước khi nộp chính thức:

1. **Bổ sung thông tin hành chính nhóm `FA26SE090`**: Điền mã lớp `FA26SE090`, danh sách 4 sinh viên, tick ô `Students` và cập nhật ngày ký (nhờ Thầy xác nhận giữ ngày đầu kỳ `19/08/2026` hay ngày cập nhật `29/10/2026`).
2. **Tách rõ vai trò quản lý học thuật (`Academic Director` & `Academic Manager`)**: Trong mục *System Roles*, nhóm giữ nguyên các nhiệm vụ gốc của Thầy (bao gồm `Monitor AI recommendation quality` và `Receive personalized study recommendations`) nhưng bổ sung thêm role `Academic Director` (quản trị khung năng lực chuẩn, ngân hàng câu hỏi gốc, nguồn tri thức AI) để đồng bộ 100% với phân quyền thực tế trong SRS/Database của nhóm.
3. **Làm rõ phạm vi Web (`ReactJS`) và Mobile (`React Native`)**: Đổi công nghệ Mobile từ `Flutter` sang `React Native` và định vị rõ các hoạt động học tập, luyện đề, thi thử diễn ra trên **Web Platform**, còn **Mobile App** đóng vai trò ứng dụng đồng hành (*Companion App*) phục vụ xem tiến độ, lịch trình, báo cáo và thông báo; đồng thời giữ đầy đủ **Parent Web Portal** nhất quán ở mọi mục.
4. **Cập nhật công nghệ & NFR khớp môi trường triển khai thực tế**: Điều chỉnh `OpenAI / Qdrant / Azure` sang mô tả khái quát khớp thực tế (`LLM APIs`, `ASP.NET Core & Python`, `PostgreSQL & Vector Search Storage`, `Docker`) và chuyển các thông số NFR (`< 3s`, `1,000 users`) sang mô tả định tính an toàn khi bảo vệ trước Hội đồng.
5. **Cân đối lại bảng phân công (`Proposed Tasks`) cho 4 thành viên**: San đều khối lượng giữa Core Backend (`Leader`), Student Web + Companion Mobile (`Member 1`), Management/Parent Web Portals + Management APIs (`Member 2`), và AI/RAG/Analytics + AI Tutor UI (`Member 3`).
