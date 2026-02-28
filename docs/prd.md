```markdown
# **Product Requirements Document (PRD)**
**Product Name**: foundeV AI Developer Agent (Doubt Resolution Engine)
**Version**: 1.0
**Author**: Senior System Architect
**Date**: 2023-10-15

---

## **1. Executive Summary**
### **1.1 Purpose**
foundeV is an **AI Developer Agent** designed to resolve the **"Doubt Bottleneck"** for JEE/NEET aspirants by providing **instant, syllabus-aligned, and hallucination-free** explanations for STEM doubts. The agent operates as a **self-contained, production-grade system** with:
- **Photo-to-answer workflow** (OCR + generative AI).
- **Method validation** (scratchpad analysis for droppers).
- **Syllabus-aware responses** (JEE/NEET-specific logic).
- **Offline-capable** (Tier 2/3 constraints).

### **1.2 Key Features**
| Feature                          | Description                                                                 |
|----------------------------------|-----------------------------------------------------------------------------|
| **Photo Scan**                   | OCR-based doubt extraction from textbooks/notes.                           |
| **Syllabus-Aligned Explanations** | Responses tailored to JEE/NEET patterns (e.g., step-by-step derivations).  |
| **Method Validation**            | Analyzes user scratchpad work to pinpoint errors (e.g., "Fix sign in step 3"). |
| **Voice Notes**                  | Premium-tier feature for verbal explanations.                              |
| **Similar Question Generator**   | Generates practice problems based on the doubt.                            |
| **Offline Mode**                 | Caches syllabus data for low-connectivity regions.                         |

### **1.3 Success Metrics**
| Metric                          | Target                          | Measurement Method                     |
|---------------------------------|---------------------------------|----------------------------------------|
| **Doubt Resolution Time**       | <2 minutes (vs. 45+ minutes)    | User-reported timestamps in app logs.  |
| **Hallucination Rate**          | <1% (vs. 40% for generic AI)    | Manual audit of 1,000+ responses.      |
| **User Retention**              | 70% DAU/MAU (30-day rolling)    | Firebase Analytics.                    |
| **Premium Conversion**          | 5% of free users (₹199–₹349/mo) | Stripe/PayU payment logs.              |

---

## **2. Tech Stack**
### **2.1 Justification**
| Component               | Technology               | Rationale                                                                 |
|-------------------------|--------------------------|---------------------------------------------------------------------------|
| **Frontend**            | React Native             | Cross-platform (Android-first), lightweight (<50MB), offline-capable.    |
| **Backend**             | Node.js (Express)        | Non-blocking I/O for high concurrency (2M+ users).                       |
| **AI/ML**               | Python (FastAPI)         | PyTorch/TensorFlow for OCR (EasyOCR) and generative models (Llama-2).    |
| **Database**            | PostgreSQL               | ACID compliance for user data; JSONB for flexible syllabus storage.      |
| **Caching**             | Redis                    | Low-latency responses for frequent doubts (e.g., "Newton’s Laws").        |
| **Storage**             | AWS S3                   | Scalable, cost-effective for image uploads (OCR inputs).                  |
| **Deployment**          | AWS EKS (Kubernetes)     | Auto-scaling for exam-season traffic spikes (e.g., January–April).       |
| **Monitoring**          | Prometheus + Grafana     | Real-time hallucination detection and performance metrics.               |

### **2.2 Constraints**
- **Android-First**: 95% of target users (Jio phones in Tier 2/3).
- **Offline Mode**: Cache syllabus data (50MB limit) for low-connectivity regions.
- **Data Usage**: <10MB per doubt resolution (Jio users).

---

## **3. Architecture**
### **3.1 High-Level Diagram**
```
┌─────────────┐    ┌─────────────┐    ┌─────────────────┐    ┌─────────────┐
│             │    │             │    │                 │    │             │
│   Mobile    │───▶│   API       │───▶│   AI Pipeline   │───▶│  Database   │
│   (React    │    │   Gateway   │    │   (FastAPI)     │    │  (Postgres) │
│   Native)   │◀───│   (Express) │◀───│                 │◀───│             │
└─────────────┘    └─────────────┘    └─────────────────┘    └─────────────┘
       ▲                  ▲  ▲  ▲                  ▲
       │                  │  │  │                  │
┌──────┴──────┐    ┌──────┴──┴──┴──────┐    ┌──────┴──────┐
│             │    │                     │    │             │
│   S3        │    │   Redis Cache       │    │   Prometheus│
│  (Images)   │    │  (Frequent Doubts)  │    │   + Grafana │
└─────────────┘    └─────────────────────┘    └─────────────┘
```

### **3.2 Component Breakdown**
#### **3.2.1 Mobile App (React Native)**
- **Offline Mode**:
  - Cache syllabus data (e.g., JEE Mains 2024 topics) in SQLite.
  - Queue doubt resolutions for sync when online.
- **Photo Scan**:
  - Use `react-native-image-picker` for OCR input.
  - Compress images to <1MB (Jio users).

#### **3.2.2 API Gateway (Node.js/Express)**
- **Routes**:
  - `POST /api/doubts` (Submit doubt via photo/text).
  - `GET /api/doubts/:id` (Fetch resolution).
  - `POST /api/premium/voice` (Voice-note explanations).
- **Rate Limiting**:
  - Free tier: 5 requests/day.
  - Premium tier: Unlimited.

#### **3.2.3 AI Pipeline (FastAPI)**
- **OCR Module**:
  - EasyOCR for handwritten/textbook scans.
  - Fallback to Tesseract if confidence <90%.
- **Generative Model**:
  - Fine-tuned Llama-2 (7B) for syllabus-aligned responses.
  - **Hallucination Guardrails**:
    - Reject responses with >10% deviation from cached syllabus.
    - Log flagged responses for manual review.
- **Method Validation**:
  - Compare user scratchpad steps to model solution.
  - Highlight discrepancies (e.g., "Step 3: Incorrect sign convention").

#### **3.2.4 Database (PostgreSQL)**
- **Tables**:
  - `users` (auth, tier, usage stats).
  - `doubts` (OCR text, resolution, timestamps).
  - `syllabus` (JEE/NEET topics, cached responses).
- **Indexes**:
  - `doubts(user_id, created_at)` for usage analytics.
  - `syllabus(topic, exam_type)` for fast lookups.

---

## **4. Database Schema**
```sql
-- Users
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  phone_number VARCHAR(15) UNIQUE NOT NULL,
  tier VARCHAR(10) CHECK (tier IN ('free', 'premium')) DEFAULT 'free',
  created_at TIMESTAMP DEFAULT NOW(),
  last_active_at TIMESTAMP
);

-- Doubts
CREATE TABLE doubts (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  image_url VARCHAR(255),
  ocr_text TEXT,
  resolution TEXT,
  is_resolved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  resolved_at TIMESTAMP
);

-- Syllabus Cache
CREATE TABLE syllabus (
  id SERIAL PRIMARY KEY,
  topic VARCHAR(100) NOT NULL,
  exam_type VARCHAR(10) CHECK (exam_type IN ('JEE', 'NEET')),
  cached_response TEXT,
  last_updated TIMESTAMP DEFAULT NOW()
);

-- Premium Features
CREATE TABLE premium_voice_notes (
  id SERIAL PRIMARY KEY,
  doubt_id INTEGER REFERENCES doubts(id),
  audio_url VARCHAR(255),
  duration INTEGER
);
```

---

## **5. API Design**
### **5.1 Base URL**
`https://api.foundev.ai/v1`

### **5.2 Authentication**
- **Method**: JWT (phone number + OTP).
- **Header**: `Authorization: Bearer <token>`

### **5.3 Endpoints**
#### **5.3.1 Submit Doubt**
```http
POST /doubts
Headers:
  Authorization: Bearer <token>
  Content-Type: multipart/form-data

Body:
  image: <file> (JPEG/PNG, <1MB)
  exam_type: "JEE" | "NEET"
  topic: "Rotational Mechanics" (optional)

Response (201):
{
  "id": "doubt_abc123",
  "status": "processing",
  "estimated_time": 15
}
```

#### **5.3.2 Fetch Resolution**
```http
GET /doubts/{id}
Headers:
  Authorization: Bearer <token>

Response (200):
{
  "id": "doubt_abc123",
  "resolution": "Step 1: Apply conservation of angular momentum...",
  "method_validation": {
    "user_steps": ["m1v1 = m2v2", "..."],
    "errors": ["Step 2: Incorrect sign for v2"]
  },
  "similar_questions": ["Q1: A rod of length L..."]
}
```

#### **5.3.3 Premium: Voice Note**
```http
POST /premium/voice
Headers:
  Authorization: Bearer <token>

Body:
  doubt_id: "doubt_abc123"

Response (201):
{
  "audio_url": "https://foundev.s3.amazonaws.com/voice_abc123.mp3",
  "duration": 45
}
```

---

## **6. Security**
### **6.1 Threat Model**
| Threat                     | Mitigation Strategy                                  |
|----------------------------|------------------------------------------------------|
| **Hallucinations**         | Syllabus alignment checks + manual review queue.     |
| **Data Leakage**           | Encrypt PII (phone numbers) at rest (AES-256).       |
| **Rate Limiting Abuse**    | 5 requests/day for free tier; JWT expiration (1h).   |
| **Image Upload Exploits**  | Sanitize OCR input (strip EXIF, validate file type). |

### **6.2 Controls**
- **Authentication**: JWT with 1-hour expiry.
- **Data Encryption**:
  - TLS 1.3 for in-transit data.
  - AWS KMS for S3/PostgreSQL encryption.
- **Audit Logs**: Track all doubt resolutions for compliance.

---

## **7. Deployment Configuration**
### **7.1 Deployment Target**
- **Environment**: AWS EKS (Kubernetes) in `ap-south-1` (Mumbai).
- **Rationale**:
  - Low latency for Indian users.
  - Auto-scaling for exam-season traffic (e.g., January–April).
  - Cost-effective for Tier 2/3 user base.

### **7.2 Infrastructure as Code**
- **Tools**: Terraform + Helm.
- **Components**:
  - **EKS Cluster**: 3-node `t3.medium` (auto-scaling to 10 nodes).
  - **PostgreSQL**: AWS RDS (Multi-AZ for HA).
  - **Redis**: ElastiCache (cluster mode).
  - **S3**: Standard storage class for images.

### **7.3 CI/CD Pipeline**
- **GitHub Actions**:
  - Build React Native APK/IPA.
  - Deploy FastAPI/Node.js to EKS.
- **Rollback Strategy**: Blue-green deployments for zero downtime.

### **7.4 Monitoring**
- **Prometheus**: Track hallucination rate, latency.
- **Grafana**: Dashboards for DAU, premium conversions.
- **Sentry**: Error tracking for mobile app crashes.
```

---
**End of PRD**