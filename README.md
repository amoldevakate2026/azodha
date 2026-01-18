# Azodha API - DevOps Engineer Take-Home Assignment

A production-ready Flask API service deployed on AWS EKS with complete CI/CD pipeline, monitoring, and security best practices.

## 🚀 Features

- **RESTful API** with health check and prediction endpoints
- **Production Docker** image with multi-stage builds
- **Kubernetes** deployment with auto-scaling and high availability
- **CI/CD Pipeline** with GitHub Actions
- **Security** hardened containers and Kubernetes configurations
- **Monitoring** ready with Prometheus metrics

## 📋 API Endpoints

### Health Check
```bash
GET /health
```
Returns service health status.

**Response:**
```json
{
  "status": "healthy",
  "service": "azodha-api",
  "version": "1.0.0"
}
```

### Prediction
```bash
GET /predict
```
Returns a prediction score.

**Response:**
```json
{
  "score": 0.75
}
```

## 🏗️ Architecture

### Application Stack
- **Language:** Python 3.11
- **Framework:** Flask 3.0
- **WSGI Server:** Gunicorn
- **Container:** Docker (multi-stage build)

### Infrastructure
- **Cloud Provider:** AWS
- **Orchestration:** Kubernetes (EKS)
- **CI/CD:** GitHub Actions
- **Container Registry:** Docker Hub
- **Infrastructure as Code:** Terraform (existing setup)

## 📦 Project Structure

```
.
├── .github/
│   └── workflows/
│       └── ci-cd.yml          # CI/CD pipeline
├── k8s/
│   ├── deployment.yaml        # Kubernetes deployment
│   ├── service.yaml           # Kubernetes service
│   ├── ingress.yaml           # Ingress configuration
│   └── hpa.yaml              # Horizontal Pod Autoscaler
├── app.py                     # Flask application
├── requirements.txt           # Python dependencies
├── Dockerfile                 # Multi-stage Docker build
└── README.md                  # This file
```

## 🚀 Quick Start

### Local Development

1. **Clone the repository**
   ```bash
   git clone https://github.com/amoldevakate2026/azodha.git
   cd azodha
   git checkout Dev
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Run the application**
   ```bash
   python app.py
   ```

4. **Test the endpoints**
   ```bash
   curl http://localhost:8080/health
   curl http://localhost:8080/predict
   ```

### Docker

1. **Build the image**
   ```bash
   docker build -t azodha-api:latest .
   ```

2. **Run the container**
   ```bash
   docker run -p 8080:8080 azodha-api:latest
   ```

### Kubernetes Deployment

1. **Apply Kubernetes manifests**
   ```bash
   kubectl apply -f k8s/
   ```

2. **Verify deployment**
   ```bash
   kubectl get pods
   kubectl get svc
   ```

3. **Check logs**
   ```bash
   kubectl logs -f deployment/azodha-api
   ```

## 🔧 Configuration

### Required Secrets (GitHub Actions)

- `DOCKER_USERNAME` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub access token
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key

### Environment Variables

- `PORT` - Application port (default: 8080)

## 🔒 Security Features

- Non-root user in containers
- Read-only root filesystem
- Dropped all Linux capabilities
- Security context constraints
- Vulnerability scanning with Trivy
- HTTPS/TLS termination at ingress
- Rate limiting

## 📊 Monitoring

- Health check endpoints
- Kubernetes liveness and readiness probes
- Horizontal Pod Autoscaler (HPA)
- Resource limits and requests

## 🔄 CI/CD Pipeline

The GitHub Actions workflow includes:

1. **Test Stage**
   - Runs unit tests
   - Generates code coverage

2. **Security Scan**
   - Trivy vulnerability scanning
   - SARIF report generation

3. **Build & Push**
   - Multi-stage Docker build
   - Push to Docker Hub
   - Image tagging strategy

4. **Deploy**
   - AWS EKS deployment
   - Rolling updates
   - Deployment verification

## 🎯 Scaling

The application automatically scales based on:
- CPU utilization (target: 70%)
- Memory utilization (target: 80%)
- Min replicas: 2
- Max replicas: 10

## 🛠️ Development

### Prerequisites

- Python 3.11+
- Docker
- kubectl
- AWS CLI
- Terraform (for infrastructure)

### Contributing

1. Create a feature branch
2. Make your changes
3. Test locally
4. Submit a pull request to `Dev` branch

## 📝 License

This project is part of a DevOps Engineer take-home assignment.

## 👤 Author

**Amol Devakate**
- GitHub: [@amoldevakate2026](https://github.com/amoldevakate2026)

## 🙏 Acknowledgments

- Azodha for the assignment opportunity
- Flask and Python community
- Kubernetes community
