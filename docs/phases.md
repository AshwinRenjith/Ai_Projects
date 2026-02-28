Here’s the decomposed `phases.md` plan for the foundeV AI Developer Agent:

```markdown
# foundeV AI Developer Agent - Execution Plan

## Phase 1: Project Scaffold and Baseline Tooling
**Objective**: Establish the foundational project structure, tooling, and configuration for all subsequent phases.

**Scope**:
- Initialize monorepo structure for frontend, backend, and AI services.
- Set up CI/CD pipelines (GitHub Actions) for automated testing and deployment.
- Configure baseline infrastructure (AWS EKS, RDS, S3, Redis) using Terraform.
- Implement linting, formatting, and pre-commit hooks (ESLint, Prettier, Black).
- Define environment variables and secrets management (AWS Secrets Manager).

**Files to Create/Modify**:
- `/README.md` (Project overview, setup instructions)
- `/.github/workflows/ci.yml` (CI pipeline for linting/testing)
- `/.github/workflows/cd.yml` (CD pipeline for deployments)
- `/terraform/main.tf` (AWS EKS, RDS, S3, Redis)
- `/terraform/variables.tf` (Terraform variables)
- `/terraform/outputs.tf` (Terraform outputs)
- `/docker-compose.yml` (Local development setup)
- `/frontend/.eslintrc.json` (React Native linting)
- `/backend/.eslintrc.json` (Node.js linting)
- `/ai/.flake8` (Python linting)
- `/scripts/setup.sh` (Automated setup script)
- `/.pre-commit-config.yaml` (Pre-commit hooks)

**Success Criteria**:
- Monorepo initialized with `frontend/`, `backend/`, and `ai/` directories.
- CI pipeline passes linting and unit tests for all services.
- Terraform applies successfully to create AWS resources.
- Local development environment spins up via `docker-compose up`.

**QA Criteria**:
- Verify CI pipeline runs on `git push` and passes all checks.
- Confirm Terraform state is stored in AWS S3 backend.
- Validate local development environment with mock services.

**Dependencies**:
- AWS account with IAM permissions for EKS, RDS, S3, and ElastiCache.
- GitHub repository with Actions enabled.

---

## Phase 2: Core Database and Authentication
**Objective**: Implement the PostgreSQL database schema and JWT-based authentication.

**Scope**:
- Create PostgreSQL tables (`users`, `doubts`, `syllabus`, `premium_voice_notes`).
- Implement JWT authentication in Node.js (Express).
- Set up Redis for session caching.
- Create API endpoints for user registration and login (OTP-based).
- Write database migration scripts (using Knex.js).

**Files to Create/Modify**:
- `/backend/src/db/migrations/20231015_init.js` (Knex migration for schema)
- `/backend/src/db/seeds/test_data.js` (Seed data for development)
- `/backend/src/auth/jwt.js` (JWT generation/validation)
- `/backend/src/routes/auth.js` (OTP login endpoint)
- `/backend/src/middleware/auth.js` (Authentication middleware)
- `/backend/src/config/redis.js` (Redis client setup)
- `/backend/src/models/User.js` (User model)
- `/backend/.env.example` (Environment variables template)

**Success Criteria**:
- Database schema matches PRD specifications.
- Users can register/login via OTP and receive a JWT.
- Redis caches active sessions.
- Knex migrations run successfully in development and production.

**QA Criteria**:
- Test OTP login flow with Postman.
- Verify JWT validation middleware blocks unauthorized requests.
- Confirm Redis cache hits for repeated login attempts.

**Dependencies**:
- Phase 1 (Terraform-provisioned RDS and Redis).

---

## Phase 3: Mobile App Scaffold and Offline Mode
**Objective**: Build the React Native app scaffold and implement offline caching.

**Scope**:
- Initialize React Native project with TypeScript.
- Set up navigation (React Navigation).
- Implement SQLite for offline syllabus caching.
- Create basic UI components (login screen, doubt submission form).
- Integrate with backend auth endpoints (Phase 2).

**Files to Create/Modify**:
- `/frontend/src/navigation/AppNavigator.tsx` (React Navigation setup)
- `/frontend/src/screens/LoginScreen.tsx` (OTP login UI)
- `/frontend/src/screens/DoubtScreen.tsx` (Doubt submission form)
- `/frontend/src/services/auth.ts` (Auth API calls)
- `/frontend/src/services/db.ts` (SQLite setup for offline cache)
- `/frontend/src/utils/offlineQueue.ts` (Queue for offline doubt submissions)
- `/frontend/android/app/build.gradle` (Android-specific config)
- `/frontend/ios/Podfile` (iOS-specific config)

**Success Criteria**:
- App builds for Android and iOS.
- Users can log in via OTP and navigate to the doubt submission screen.
- Syllabus data is cached offline in SQLite.
- Doubts submitted offline are queued and synced when online.

**QA Criteria**:
- Test offline mode by disabling network and submitting a doubt.
- Verify syllabus cache persists after app restart.
- Confirm queued doubts sync when network is restored.

**Dependencies**:
- Phase 2 (Authentication API).

---

## Phase 4: API Gateway and Doubt Submission
**Objective**: Implement the API Gateway and doubt submission workflow.

**Scope**:
- Create Express routes for doubt submission and resolution.
- Integrate with AI pipeline (mock for now).
- Implement rate limiting (5 requests/day for free tier).
- Add image upload to S3 for OCR processing.
- Write unit/integration tests for API endpoints.

**Files to Create/Modify**:
- `/backend/src/routes/doubts.js` (Doubt submission/resolution endpoints)
- `/backend/src/controllers/doubtController.js` (Business logic)
- `/backend/src/services/s3.js` (Image upload to S3)
- `/backend/src/services/aiMock.js` (Mock AI pipeline for testing)
- `/backend/src/middleware/rateLimiter.js` (Rate limiting)
- `/backend/tests/doubt.test.js` (Jest tests)
- `/backend/src/config/aws.js` (AWS SDK config)

**Success Criteria**:
- Users can submit doubts via photo/text and receive a `doubt_id`.
- Images are uploaded to S3 and OCR text is extracted (mock).
- Rate limiting blocks free-tier users after 5 requests/day.
- API tests pass in CI.

**QA Criteria**:
- Test doubt submission with Postman (photo + text).
- Verify rate limiting by exceeding free-tier quota.
- Confirm S3 uploads work for images <1MB.

**Dependencies**:
- Phase 1 (S3 Terraform setup).
- Phase 2 (Authentication).

---

## Phase 5: AI Pipeline (OCR + Generative Model)
**Objective**: Implement the OCR and generative AI pipeline.

**Scope**:
- Set up FastAPI service for OCR (EasyOCR/Tesseract).
- Fine-tune Llama-2 for syllabus-aligned responses.
- Implement hallucination guardrails (syllabus alignment checks).
- Add method validation (scratchpad analysis).
- Create endpoints for doubt resolution and similar questions.

**Files to Create/Modify**:
- `/ai/src/main.py` (FastAPI app)
- `/ai/src/ocr/ocr_service.py` (EasyOCR/Tesseract integration)
- `/ai/src/models/generative.py` (Llama-2 fine-tuning)
- `/ai/src/validation/hallucination.py` (Syllabus alignment checks)
- `/ai/src/validation/method.py` (Scratchpad analysis)
- `/ai/src/routes/doubts.py` (Doubt resolution endpoint)
- `/ai/Dockerfile` (FastAPI container)
- `/ai/requirements.txt` (Python dependencies)
- `/ai/tests/test_ocr.py` (OCR unit tests)

**Success Criteria**:
- OCR extracts text from images with >90% accuracy.
- Generative model produces syllabus-aligned responses.
- Hallucination guardrails flag >10% deviation from syllabus.
- Method validation identifies errors in user scratchpads.

**QA Criteria**:
- Test OCR with sample textbook images.
- Verify generative model responses against syllabus cache.
- Confirm hallucination guardrails reject off-topic responses.

**Dependencies**:
- Phase 1 (Terraform-provisioned EKS for AI service).
- Phase 4 (Doubt submission API).

---

## Phase 6: Premium Features (Voice Notes)
**Objective**: Implement premium-tier features (voice notes).

**Scope**:
- Add Stripe/PayU integration for payments.
- Create endpoint for voice-note generation (text-to-speech).
- Store voice notes in S3 and link to doubts.
- Update mobile app to play voice notes.

**Files to Create/Modify**:
- `/backend/src/routes/premium.js` (Voice-note endpoint)
- `/backend/src/services/payments.js` (Stripe/PayU integration)
- `/backend/src/models/PremiumVoiceNote.js` (Voice-note model)
- `/frontend/src/screens/PremiumScreen.tsx` (Premium UI)
- `/frontend/src/services/premium.ts` (Premium API calls)
- `/ai/src/services/tts.py` (Text-to-speech service)

**Success Criteria**:
- Premium users can generate voice notes for doubts.
- Voice notes are stored in S3 and linked to doubts.
- Payments are processed via Stripe/PayU.

**QA Criteria**:
- Test voice-note generation for a sample doubt.
- Verify payment flow with Stripe test cards.
- Confirm voice notes play in the mobile app.

**Dependencies**:
- Phase 2 (User tiering).
- Phase 4 (Doubt resolution).

---

## Phase 7: Deployment and Production Hardening
**Objective**: Deploy the system to production and implement hardening measures.

**Scope**:
- Configure Kubernetes manifests for all services (EKS).
- Set up Prometheus + Grafana for monitoring.
- Implement logging (ELK stack or AWS CloudWatch).
- Add security headers and CORS policies.
- Configure auto-scaling for EKS nodes.
- Write runbooks for incident response.

**Files to Create/Modify**:
- `/k8s/frontend-deployment.yaml` (React Native webview)
- `/k8s/backend-deployment.yaml` (Node.js)
- `/k8s/ai-deployment.yaml` (FastAPI)
- `/k8s/monitoring/prometheus-values.yaml` (Prometheus config)
- `/k8s/monitoring/grafana-dashboard.json` (Grafana dashboard)
- `/docs/runbook.md` (Incident response)
- `/backend/src/middleware/security.js` (Security headers)
- `/terraform/production.tfvars` (Production Terraform vars)

**Success Criteria**:
- All services deploy to EKS without errors.
- Monitoring dashboards show real-time metrics.
- Auto-scaling handles traffic spikes.
- Security headers are enforced.

**QA Criteria**:
- Verify Prometheus scrapes metrics from all services.
- Test auto-scaling by simulating traffic spikes.
- Confirm security headers are present in API responses.

**Dependencies**:
- All prior phases.
```

This plan ensures each phase is independently deployable, with clear dependencies and success criteria. The final phase includes production hardening and deployment configuration as required.