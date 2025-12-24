# 🧠 Smart Task Manager – Backend

A production-ready **Task Management Backend** built with **Node.js, Express, and Supabase**, featuring **intelligent task classification**, **audit logging**, and an **optional ML-powered enhancement**.

---

## 🚀 Features

- Task CRUD APIs (Create, Read, Update, Delete)
- Intelligent task classification (category & priority)
- ML-inspired weighted scoring with confidence values
- Optional LLM-based intent extraction (Ollama + LangChain)
- Audit trail for all task updates
- Pagination & filtering support
- Deployed globally on Render
- Flutter-ready REST APIs

---

## 🏗️ Architecture

Flutter App
↓
Node.js Backend (Express) — Global (Render)
↓
ML-inspired Classification Engine
↓
Supabase (PostgreSQL)


---

## 🧠 Intelligent Classification

### Global (Production)
The production system uses an **ML-inspired rule engine**:
- Feature extraction
- Weighted keyword scoring
- Confidence-based predictions
- Fully explainable outputs

Example:
```json
{
  "category": "scheduling",
  "category_confidence": 0.82,
  "priority": "high",
  "priority_confidence": 0.91
}
```

Optional ML Enhancement (Local)

An optional LLM-based intent extraction service is implemented using Ollama (Mistral).

Due to infrastructure requirements:

Rule-based system runs globally

ML service runs locally / on VM

Architecture supports seamless future ML deployment

Production is never blocked by ML availability.


📦 API Endpoints
POST   /api/tasks
GET    /api/tasks
GET    /api/tasks/:id
PATCH  /api/tasks/:id
DELETE /api/tasks/:id

🧪 Example Request
{
  "title": "Schedule meeting",
  "description": "Urgent meeting with team today about budget",
  "assigned_to": "Aayush"
}

🗂️ Project Structure
src/
 ├── controllers/
 ├── services/
 ├── routes/
 ├── validators/
 ├── config/
 └── server.js

🔐 Environment Variables
SUPABASE_URL=your_supabase_url
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
INTENT_ML_URL=http://127.0.0.1:8001   # optional

▶️ Run Locally
npm install
npm run dev


🌍 Deployment

Backend deployed globally on Render

ML service designed for future VM deployment
