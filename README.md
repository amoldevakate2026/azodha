# Azodha DevOps Engineer Take-Home Assignment

## 🚀 Project Overview

Complete production-ready DevOps solution demonstrating:
- **Containerized Flask API** with health and prediction endpoints
- **AWS EKS Kubernetes cluster** deployed via Terraform
- **Automated CI/CD pipeline** with GitHub Actions
- **Remote state management** with S3 and DynamoDB
- **Custom domain routing** with CNAME records
- **Production-grade** Docker multi-stage builds

---

## 🌐 Live Endpoints

**Application URLs:**
- 🔗 http://api.azodha.run.place/health
- 🔗 http://api.azodha.run.place/predict
- 🔗 http://app.azodha.run.place/health
- 🔗 http://www.azodha.run.place/health

**AWS LoadBalancer:**
- `aafbd4addd6c8484f953d7ba900ad0df-21721920.us-east-1.elb.amazonaws.com`

---

## 📁 Repository Structure

```
azodha/
├── IAC Branch (Infrastructure)
│   ├── main.tf              # EKS cluster & node group
│   ├── backend.tf           # S3 remote state config
│   └── README.md            # This file
│
└── Dev Branch (Application)
    ├── app.py               # Flask API service
    ├── requirements.txt     # Python dependencies
    ├── Dockerfile           # Multi-stage production build
    ├── test_app.py          # Unit tests
    ├── k8s/
    │   └── deployment.yaml  # K8s manifests
    └── .github/workflows/
        └── ci-cd.yml        # Build & deploy pipeline
```

---

## 🏗️ Infrastructure Architecture

### AWS Resources Created

**EKS Cluster:**
- Name: `azodha-eks-cluster`
- Region: `us-east-1`
- Kubernetes Version: `1.34`
- Status: ACTIVE

**Node Group:**
- Instance Type: `t3.medium`
- Desired Capacity: 2
- Min: 1, Max: 3
- Auto-scaling enabled

**Networking:**
- VPC: Default VPC
- Subnets: us-east-1a, us-east-1b, us-east-1c, us-east-1d, us-east-1f
- LoadBalancer: AWS ELB (Classic)

**IAM Roles:**
- `azodha-eks-cluster-cluster-role` (EKS Cluster)
- `azodha-eks-cluster-node-role` (Worker Nodes)

---

## 🗄️ Terraform State Management

**S3 Backend Configuration:**
```hcl
Bucket: azodha-terraform-state-404967771393
Key: eks-cluster/terraform.tfstate
Region: us-east-1
Encryption: Enabled
Versioning: Enabled
```

**DynamoDB State Locking:**
```hcl
Table: azodha-terraform-locks
Billing Mode: PAY_PER_REQUEST
```

**Viewing State:**
```bash
# List state resources
terraform state list

# View S3 bucket
aws s3 ls s3://azodha-terraform-state-404967771393/eks-cluster/

# Check DynamoDB locks
aws dynamodb scan --table-name azodha-terraform-locks
```

---

## 🚀 Deployment Guide

### Prerequisites
- AWS CLI configured
- Terraform >= 1.0
- kubectl installed
- Docker installed

### Step 1: Clone Repository
```bash
# Clone IAC branch
git clone -b IAC https://github.com/amoldevakate2026/azodha.git
cd azodha
```

### Step 2: Deploy Infrastructure
```bash
# Initialize Terraform with S3 backend
terraform init

# Review planned changes
terraform plan

# Apply infrastructure
terraform apply --auto-approve
```

**Expected Output:**
```
Apply complete! Resources: 8 added, 0 changed, 0 destroyed.

Outputs:
cluster_endpoint = "https://99CF5371792CB79D5DE5927085..."
cluster_name = "azodha-eks-cluster"
cluster_status = "ACTIVE"
```

### Step 3: Configure kubectl
```bash
aws eks update-kubeconfig --region us-east-1 --name azodha-eks-cluster
```

### Step 4: Deploy Application
```bash
# Build Docker image
docker build -t azodha-api:latest .

# Create ECR repository
aws ecr create-repository --repository-name azodha-api --region us-east-1

# Authenticate Docker to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS \
  --password-stdin 404967771393.dkr.ecr.us-east-1.amazonaws.com

# Tag and push
docker tag azodha-api:latest 404967771393.dkr.ecr.us-east-1.amazonaws.com/azodha-api:latest
docker push 404967771393.dkr.ecr.us-east-1.amazonaws.com/azodha-api:latest

# Deploy to Kubernetes
kubectl apply -f k8s/deployment.yaml

# Expose service
kubectl expose deployment azodha-api --type=LoadBalancer --port=80 --target-port=8080
```

### Step 5: Verify Deployment
```bash
# Check pods
kubectl get pods

# Check service
kubectl get svc azodha-api

# Get LoadBalancer URL
LB_URL=$(kubectl get svc azodha-api -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo $LB_URL

# Test endpoints
curl http://$LB_URL/health
curl http://$LB_URL/predict
```

---

## 🔄 CI/CD Pipeline

**GitHub Actions Workflow** (`.github/workflows/ci-cd.yml`):

1. **Build Stage:** Docker image build
2. **Test Stage:** Run unit tests
3. **Push Stage:** Push to ECR
4. **Deploy Stage:** Update EKS deployment

**Triggered on:**
- Push to `dev` branch
- Pull request to `main`

---

## 🧪 API Endpoints

### Health Check
```bash
GET /health

Response:
{
  "service": "azodha-api",
  "status": "healthy"
}
```

### Prediction
```bash
GET /predict

Response:
{
  "score": 0.75
}
```

---

## 🌍 Domain Configuration

**DNS Records (freedomain.one):**

| Type  | Host | Value                                           | TTL  |
|-------|------|-------------------------------------------------|------|
| CNAME | api  | aafbd4addd6c8484f953d7ba900ad0df-21721920.us-east-1.elb.amazonaws.com | 3600 |
| CNAME | app  | aafbd4addd6c8484f953d7ba900ad0df-21721920.us-east-1.elb.amazonaws.com | 3600 |
| CNAME | www  | aafbd4addd6c8484f953d7ba900ad0df-21721920.us-east-1.elb.amazonaws.com | 3600 |

---

## 🧹 Cleanup

```bash
# Delete Kubernetes resources
kubectl delete svc azodha-api
kubectl delete deployment azodha-api

# Destroy infrastructure
terraform destroy --auto-approve

# Delete ECR images
aws ecr batch-delete-image --repository-name azodha-api \
  --image-ids imageTag=latest --region us-east-1

# Delete ECR repository
aws ecr delete-repository --repository-name azodha-api \
  --force --region us-east-1
```

---

## 📊 Monitoring & Logs

```bash
# View pod logs
kubectl logs -f deployment/azodha-api

# Describe pods
kubectl describe pod <pod-name>

# Get cluster info
kubectl cluster-info

# View nodes
kubectl get nodes -o wide
```

---

## 🔒 Security Best Practices

✅ Non-root Docker user  
✅ Multi-stage Docker builds  
✅ IAM roles with least privilege  
✅ Encrypted S3 state backend  
✅ DynamoDB state locking  
✅ VPC security groups  
✅ Health check probes  

---

## 📝 Key Features Implemented

- [x] Flask API with /health and /predict endpoints
- [x] Production Dockerfile with multi-stage build
- [x] Kubernetes deployment with 2 replicas
- [x] AWS EKS cluster via Terraform
- [x] S3 backend for Terraform state
- [x] DynamoDB for state locking
- [x] LoadBalancer service
- [x] Custom domain with CNAME records
- [x] CI/CD pipeline with GitHub Actions
- [x] Comprehensive documentation

---

## 🛠️ Tech Stack

**Application:**
- Python 3.9
- Flask 3.0.2
- Gunicorn 21.2.0

**Infrastructure:**
- AWS EKS
- Terraform 1.0+
- Kubernetes 1.34
- Docker

**CI/CD:**
- GitHub Actions
- AWS ECR

---

## 📞 Support

For issues or questions, please open an issue in this repository.

---

## 📄 License

This project is part of the Azodha DevOps Engineer take-home assignment.

---

**Author:** Amol Devakate  
**Date:** January 2026  
**Status:** ✅ Production Ready
