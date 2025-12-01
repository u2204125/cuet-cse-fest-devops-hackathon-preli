# CUET CSE Fest DevOps Hackathon - E-Commerce Platform

![CI Status](https://github.com/$GITHUB_USERNAME/$REPO_NAME/workflows/DevSecOps%20CI/CD%20Pipeline/badge.svg)
![Security Scan](https://img.shields.io/badge/security-trivy%20scanned-blue)
![Docker](https://img.shields.io/badge/docker-compose-2496ED?logo=docker)
![License](https://img.shields.io/badge/license-MIT-green)

> A production-ready, containerized microservices e-commerce backend with automated DevSecOps pipeline implementation for the CUET CSE Fest Hackathon.

---

## 📊 DevSecOps Architecture

This project implements a complete **5-stage DevSecOps pipeline** ensuring security, quality, and reliability at every step:

```
┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│  Test   │ → │  Scan   │ → │  Build  │ → │  Push   │ → │ Deploy  │
└─────────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
```

### Pipeline Stages

**1. 🧪 Test Stage**
- Unit testing for both `backend` and `gateway` services
- Automated dependency caching for faster builds
- Validates code functionality before security checks

**2. 🔒 Scan Stage (SAST)**
- **Trivy filesystem scanning** for vulnerability detection
- SARIF report generation and upload to GitHub Security
- Scans for CRITICAL, HIGH, and MEDIUM severity issues
- Blocks deployment if critical vulnerabilities found

**3. 🏗️ Build Stage**
- Multi-stage Docker builds for optimized image sizes
- Separate development and production configurations
- Layer caching for efficient rebuilds

**4. 📤 Push Stage**
- Automated push to DockerHub registry
- Tagged images for version control
- Secure credential management via GitHub Secrets

**5. 🚀 Deploy Stage**
- Automated deployment via Render webhook
- Post-deployment health checks
- Integration testing to verify service availability
- Pipeline fails if health checks return non-200 status

---

## 🏗️ System Architecture

```
                    ┌─────────────────┐
                    │   Client/User   │
                    └────────┬────────┘
                             │
                             │ HTTP (port 5921)
                             │
                    ┌────────▼────────┐
                    │    Gateway      │
                    │  (port 5921)    │
                    │   [Exposed]     │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
         ┌──────────▼──────────┐      │
         │   Private Network   │      │
         │  (Docker Network)   │      │
         └──────────┬──────────┘      │
                    │                 │
         ┌──────────┴──────────┐      │
         │                     │      │
    ┌────▼────┐         ┌──────▼──────┐
    │ Backend │         │   MongoDB   │
    │(port    │◄────────┤  (port      │
    │ 3847)   │         │  27017)     │
    │[Not     │         │ [Not        │
    │Exposed] │         │ Exposed]    │
    └─────────┘         └─────────────┘
```

**Security-First Design:**
- ✅ Gateway is the **only** service exposed to external clients (port 5921)
- ✅ All external requests **must** go through the Gateway
- ✅ Backend and MongoDB are **not exposed** to public network
- ✅ Services communicate via internal Docker network

---

## 🚀 Quick Start

### Prerequisites
- Docker Engine 20.10+
- Docker Compose V2+
- Make utility

### Development Environment

Start the development stack:
```bash
make dev
```

Or use the universal command:
```bash
make up MODE=dev
```

### Production Environment

Start the production stack:
```bash
make up
# or explicitly
make up MODE=prod
```

### Stop Services

Stop all running services:
```bash
make down
```

### Available Make Commands

| Command | Description |
|---------|-------------|
| `make dev` | Start development environment |
| `make up` | Start production environment |
| `make down` | Stop all services |
| `make test-health` | Test Gateway health endpoint |
| `make test-backend-check` | Test Backend health via Gateway |
| `make build` | Build Docker images |
| `make logs` | View service logs |
| `make ps` | Show running containers |
| `make clean` | Remove containers and networks |

For a complete list of commands:
```bash
make help
```

---

## 🔐 Security Verification

This project implements **two critical security checks** as required:

### 1. ✅ Trivy SAST Scan

**Implementation:**
- Automated filesystem scanning in CI/CD pipeline
- Scans for vulnerabilities in dependencies and code
- SARIF format results uploaded to GitHub Security tab
- Severity levels: CRITICAL, HIGH, MEDIUM

**Verification:**
```bash
# View scan results in GitHub Actions logs
# Or check the Security tab in GitHub repository
```

**Pipeline Step:**
```yaml
- name: Run Trivy Filesystem Scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: 'fs'
    format: 'sarif'
    severity: 'CRITICAL,HIGH,MEDIUM'
```

### 2. ✅ Backend Exposure Test

**Requirement:** Backend service must **NOT** be directly accessible from external network.

**Test Command:**
```bash
curl http://localhost:3847/api/products
```

**Expected Result:** ❌ Connection should **FAIL** or be **REFUSED**

**Correct Access Path:**
```bash
# ✅ This should work (via Gateway)
curl http://localhost:5921/api/products
```

**Why This Matters:**
- Prevents direct database access exploitation
- Enforces API gateway pattern
- Adds authentication/authorization layer
- Provides request logging and monitoring

---

## 🧪 Testing

### Health Checks

Check gateway health:
```bash
make test-health
# or
curl http://localhost:5921/health
```

Check backend health via gateway:
```bash
make test-backend-check
# or
curl http://localhost:5921/api/health
```

### Product Management

Create a product:
```bash
curl -X POST http://localhost:5921/api/products \
  -H 'Content-Type: application/json' \
  -d '{"name":"Test Product","price":99.99}'
```

Get all products:
```bash
curl http://localhost:5921/api/products
```

### Security Test (Must Fail)

Verify backend is **not** directly accessible:
```bash
curl http://localhost:3847/api/products
# Expected: Connection refused or timeout
```

---

## 📁 Project Structure

```
.
├── .github/
│   └── workflows/
│       └── main.yml              # CI/CD pipeline configuration
├── backend/
│   ├── Dockerfile                # Production backend image
│   ├── Dockerfile.dev            # Development backend image
│   ├── package.json
│   └── src/
│       ├── index.ts
│       ├── config/
│       ├── models/
│       └── routes/
├── gateway/
│   ├── Dockerfile                # Production gateway image
│   ├── Dockerfile.dev            # Development gateway image
│   ├── package.json
│   └── src/
│       └── gateway.js
├── docker/
│   ├── compose.development.yaml  # Dev environment config
│   └── compose.production.yaml   # Prod environment config
├── Makefile                      # Automation commands
├── README.md                     # This file
└── .env                          # Environment variables (git-ignored)
```

---

## 🔧 Environment Variables

Create a `.env` file in the root directory:

```env
# MongoDB Configuration
MONGO_INITDB_ROOT_USERNAME=admin
MONGO_INITDB_ROOT_PASSWORD=your_secure_password
MONGO_URI=mongodb://admin:your_secure_password@mongodb:27017/ecommerce?authSource=admin
MONGO_DATABASE=ecommerce

# Service Ports (DO NOT CHANGE)
BACKEND_PORT=3847
GATEWAY_PORT=5921

# Environment
NODE_ENV=production

# Docker Registry (for CI/CD)
DOCKERHUB_USERNAME=your_username
```

**⚠️ Security Note:** Never commit the `.env` file to version control.

---

## 🏆 Implementation Highlights

### ✅ Separate Dev and Prod Configurations
- Distinct Dockerfiles for development and production
- Separate Docker Compose files for each environment
- Environment-specific optimizations

### ✅ Data Persistence
- MongoDB data persisted using Docker volumes
- Data survives container restarts
- Named volumes for easy backup/restore

### ✅ Security Best Practices
- Backend and MongoDB not exposed to external network
- Gateway acts as single point of entry
- Environment variables for sensitive data
- Automated security scanning with Trivy
- Minimal attack surface with multi-stage builds

### ✅ Docker Image Optimization
- Multi-stage builds reducing image size
- Layer caching for faster builds
- Minimal base images (Alpine Linux)
- Only production dependencies in final images

### ✅ Makefile CLI Commands
- Simple, memorable commands for all operations
- Consistent interface for dev and prod
- Automated health checks and testing
- Complete development workflow automation

### ✅ Additional Best Practices
- Automated CI/CD with GitHub Actions
- Health check endpoints for all services
- Structured logging
- Graceful error handling
- Type safety with TypeScript (backend)

---

## 🚀 CI/CD Pipeline

The project includes a complete GitHub Actions workflow that:

1. **Tests** both backend and gateway services
2. **Scans** for security vulnerabilities with Trivy
3. **Builds** optimized Docker images
4. **Pushes** images to DockerHub
5. **Deploys** to production environment
6. **Verifies** deployment with health checks

### Required GitHub Secrets

Configure these secrets in your repository settings:

- `DOCKERHUB_USERNAME` - Your DockerHub username
- `DOCKERHUB_TOKEN` - DockerHub access token
- `RENDER_DEPLOY_HOOK` - Render deployment webhook URL
- `RENDER_URL` - Your deployed application URL

---

## 📈 Monitoring & Logs

View logs for all services:
```bash
make logs
```

View logs for a specific service:
```bash
make logs SERVICE=backend
# or
make logs SERVICE=gateway
```

Check running containers:
```bash
make ps
```

---

## 🧹 Cleanup

Remove containers and networks:
```bash
make clean
```

Remove everything including volumes and images:
```bash
make clean-all
```

---

## 📝 Submission Process

1. **Fork the Repository**
   - Fork this repository to your GitHub account
   - The repository must remain **private** during the contest

2. **Make Repository Public**
   - In the **last 5 minutes** of the contest, make your repository **public**
   - Repositories that remain private after the contest ends will not be evaluated

3. **Submit Repository URL**
   - Submit your repository URL at [arena.bongodev.com](https://arena.bongodev.com)
   - Ensure the URL is correct and accessible

4. **Code Evaluation**
   - All submissions will be both **automated and manually evaluated**
   - Plagiarism and code copying will result in disqualification

---

## ⚠️ Rules

- ⚠️ **NO COPYING**: All code must be your original work. Copying code from other participants or external sources will result in immediate disqualification.

- ⚠️ **NO POST-CONTEST COMMITS**: Pushing any commits to the git repository after the contest ends will result in **disqualification**. All work must be completed and committed before the contest deadline.

- ✅ **Repository Visibility**: Keep your repository private during the contest, then make it public in the last 5 minutes.

- ✅ **Submission Deadline**: Ensure your repository is public and submitted before the contest ends.

---

## 📄 License

MIT License - See LICENSE file for details

---

## 🙏 Acknowledgments

Developed for the **CUET CSE Fest DevOps Hackathon 2025**

Good luck! 🚀

