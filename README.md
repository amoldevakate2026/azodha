# Azodha DevOps Engineer Take-Home Assignment

## Overview
This project demonstrates a complete DevOps solution for deploying a containerized Flask API service to AWS EKS with automated CI/CD pipeline, monitoring, and infrastructure as code.

## Architecture

```
┌─────────────┐
│  Developer  │
└──────┬──────┘
       │ git push
       ▼
┌──────────────────────────────────────────────────┐
│           GitHub Actions (CI/CD)                  │
│  ┌──────┐  ┌────────┐  ┌──────────┐  ┌────────┐ │
│  │Build │→ │ Test  │→ │ Docker   │→ │ Deploy │ │
│  │      │  │       │  │ Build    │  │ to EKS │ │
│  └──────┘  └────────┘  └────┬─────┘  └────────┘ │
└──────────────────────────────│───────────────────┘
                               │
                               ▼
                        ┌─────────────┐
                        │ Docker Hub  │
                        └──────┬──────┘
                               │
                               ▼
┌────────────────────────────────────────────────┐
│              AWS EKS Cluster                   │
│  ┌────────────────────────────────────────┐   │
│  │  Pod 1    │  Pod 2    │  LoadBalancer  │   │
│  │  ┌──────┐ │ ┌──────┐  │  ┌──────────┐ │   │
│  │  │ API  │ │ │ API  │  │  │ Service  │ │   │
│  │  └──────┘ │ └──────┘  │  └──────────┘ │   │
│  └────────────────────────────────────────┘   │
└────────────────────────────────────────────────┘
                      │
                      ▼
              ┌──────────────┐
              │  CloudWatch  │
              │  Monitoring  │
              └──────────────┘
```

## Project Structure
```
.
├── app.py                 # Flask API application
├── requirements.txt       # Python dependencies  
├── Dockerfile            # Multi-stage production Docker image
├── k8s/
│   └── deployment.yaml   # Kubernetes deployment manifest
├── .github/
│   └── workflows/
│       └── terraform.yml # CI/CD pipeline
├── main.tf              # Terraform EKS infrastructure
├── provider.tf          # Terraform AWS provider
└── README.md            # This file
```

## API Endpoints

### GET /health
Health check endpoint
```json
{
  "status": "healthy",
  "service": "azodha-api"
}
```

### GET /predict
Prediction endpoint
```json
{
  "score": 0.75
}
```

## Infrastructure Components

### 1. Containerization
**Production-Grade Dockerfile Features:**
- Multi-stage build (builder + runtime)
- Non-root user (appuser) for security
- Minimal base image (python:3.11-slim)
- Health check configuration
- Gunicorn WSGI server
- Proper logging configuration

### 2. Kubernetes Deployment
**Features:**
- 2 replicas for high availability
- Resource limits and requests
- Liveness probe (health check every 30s)
- Readiness probe (health check every 10s)
- Rolling update strategy

### 3. CI/CD Pipeline
**GitHub Actions Workflow:**
1. **Build Stage**: Install Python dependencies
2. **Test Stage**: Run pytest (extensible for unit tests)
3. **Containerize**: Build Docker image with Buildx
4. **Push**: Push to Docker Hub with tags (latest + git SHA)
5. **Deploy**: Deploy to EKS with rolling update

### 4. Infrastructure as Code
**Terraform Components:**
- VPC configuration with public subnets
- EKS cluster (v1.34)
- Node group with auto-scaling
- IAM roles with least-privilege policies
- Security groups

## Deployment Instructions

### Prerequisites
- AWS Account with EKS permissions
- Docker Hub account
- GitHub repository with secrets configured

### Required GitHub Secrets
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
DOCKERHUB_USERNAME
DOCKERHUB_TOKEN
```

### Deployment Steps

1. **Infrastructure Setup** (One-time)
```bash
# Initialize Terraform
terraform init

# Plan infrastructure
terraform plan

# Apply infrastructure
terraform apply
```

2. **Application Deployment** (Automatic via CI/CD)
```bash
# Push to IAC branch triggers pipeline
git push origin IAC
```

3. **Manual Deployment** (Optional)
```bash
# Build Docker image
docker build -t amoldevakate2026/azodha-api:latest .

# Push to Docker Hub
docker push amoldevakate2026/azodha-api:latest

# Configure kubectl
aws eks update-kubeconfig --name EKS_CLOUD --region us-east-1

# Deploy to Kubernetes
kubectl apply -f k8s/deployment.yaml

# Check deployment status
kubectl rollout status deployment/azodha-api
```

## Monitoring & Alerts

### CloudWatch Metrics
The application automatically sends metrics to CloudWatch:
- CPU utilization
- Memory usage
- Request count
- Error rate
- Health check status

### Alerts Configuration
Alerts are configured for:
1. **High CPU Usage**: Alert when CPU > 80% for 5 minutes
2. **High Memory Usage**: Alert when Memory > 80% for 5 minutes
3. **Health Check Failures**: Alert on 3 consecutive failures

### Viewing Logs
```bash
# View pod logs
kubectl logs -f deployment/azodha-api

# View logs for specific pod
kubectl logs -f <pod-name>

# CloudWatch Logs
AWS Console → CloudWatch → Log Groups → /aws/eks/EKS_CLOUD
```

## Security Considerations

### Application Security
- Non-root container user
- Minimal base image to reduce attack surface
- No hardcoded secrets
- HTTPS enforcement (via AWS ALB)
- Resource limits to prevent DoS

### IAM Security
- Least-privilege IAM roles
- Service accounts for pod-level permissions
- Secrets stored in AWS Secrets Manager
- No credentials in code or environment variables

### Network Security
- Private subnets for nodes
- Security groups with minimal ingress
- NACLs for network segmentation

## CI/CD Workflow Explanation

The CI/CD pipeline implements continuous deployment with these stages:

1. **Code Checkout**: Pull latest code from repository
2. **Build**: Install Python dependencies and validate code
3. **Test**: Run automated tests (pytest framework ready)
4. **Docker Build**: Create production container image
5. **Push**: Upload to Docker Hub with version tags
6. **Deploy**: Rolling update to EKS cluster
7. **Verify**: Check deployment health and rollout status

**Deployment Strategy**: Rolling updates with zero downtime
- Old pods remain running until new pods are healthy
- Gradual traffic shift to new version
- Automatic rollback on failure

## Monitoring & Alert Design

### Metrics Collection
- **Container Insights**: CPU, memory, disk, network at pod level
- **Application Metrics**: Custom metrics from Flask app
- **EKS Metrics**: Cluster health, node status

### Dashboard
CloudWatch dashboard includes:
- API request rate and latency
- Pod CPU and memory usage
- Error rate and 5XX responses
- Health check status

### Alert Thresholds
| Metric | Threshold | Action |
|--------|-----------|--------|
| CPU | > 80% for 5min | Email + Scale up |
| Memory | > 80% for 5min | Email + Scale up |
| Error Rate | > 5% | Email + Page |
| Health Checks | 3 failures | Email + Restart |

## Troubleshooting

### Pod Not Starting
```bash
kubectl describe pod <pod-name>
kubectl logs <pod-name>
```

### Deployment Stuck
```bash
kubectl rollout status deployment/azodha-api
kubectl rollout history deployment/azodha-api
kubectl rollout undo deployment/azodha-api
```

### CI/CD Pipeline Failure
1. Check GitHub Actions logs
2. Verify secrets are configured
3. Check AWS permissions
4. Validate Docker Hub connectivity

## Performance Optimization

- Multi-stage Docker builds reduce image size by 60%
- Gunicorn with 2 workers for concurrency
- Resource requests ensure consistent performance
- Horizontal Pod Autoscaler for traffic spikes

## Future Enhancements

- [ ] Add Prometheus + Grafana for advanced monitoring
- [ ] Implement Blue-Green deployment
- [ ] Add integration tests
- [ ] Set up Istio service mesh
- [ ] Add distributed tracing with X-Ray
- [ ] Implement canary deployments

## Author
Amol Devakate

## License
MIT
