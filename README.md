# Azodha - Simple API Service

## Overview
A simple REST API service built with Node.js and Express, deployed on AWS EKS with complete CI/CD pipeline, monitoring, and custom domain configuration.

## 🌐 Live URLs
- **Custom Domain**: https://azodha.run.place/health
- **Load Balancer**: http://aafbd4adab6c8484f953a7ba900aa0df-21721920.us-east-1.elb.amazonaws.com/health

## 📋 API Endpoints

### Health Check
```bash
GET /health
```
Returns: `{"status": "healthy"}`

### Root
```bash
GET /
```
Returns: `{"message": "Hello from Azodha API!"}`

## 🏗️ Architecture

### Infrastructure Components
- **AWS EKS Cluster**: Kubernetes cluster with 2 worker nodes (t3.medium)
- **Application Load Balancer**: AWS NLB for traffic distribution
- **Docker**: Containerized application
- **CloudWatch**: Monitoring and logging
- **Custom Domain**: azodha.run.place with SSL/TLS

### Technology Stack
- **Runtime**: Node.js 18
- **Framework**: Express.js
- **Container**: Docker
- **Orchestration**: Kubernetes (AWS EKS)
- **IaC**: Terraform
- **CI/CD**: GitHub Actions
- **Registry**: Docker Hub

## 🚀 Deployment

### Prerequisites
- AWS Account with appropriate permissions
- AWS CLI configured
- kubectl installed
- Terraform installed
- Docker installed
- GitHub account

### Infrastructure Setup

1. **Clone the repository**
```bash
git clone https://github.com/amoldevakate2026/azodha.git
cd azodha
```

2. **Deploy Infrastructure with Terraform**
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

3. **Configure kubectl**
```bash
aws eks update-kubeconfig --region us-east-1 --name azodha-eks-cluster
```

4. **Deploy Application**
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

### CI/CD Pipeline

The project uses GitHub Actions for automated deployment:

1. **Build**: Builds Docker image from source code
2. **Push**: Pushes image to Docker Hub
3. **Deploy**: Deploys to EKS cluster using kubectl

**Workflow File**: `.github/workflows/deploy.yml`

### Docker Hub
- **Repository**: amoldevakate2026/azodha.run.place-dockerhub
- **Image**: Latest tag is automatically updated on each push

## 📊 Monitoring

### CloudWatch Dashboard
Access the monitoring dashboard at:
- **Dashboard Name**: Azodha-EKS-Cluster-Monitoring
- **Region**: us-east-1

### Metrics Monitored
1. **API Server Metrics**
   - `apiserver_current_inflight_requests_READONLY`
   - `apiserver_request_total_LIST_PODS`

2. **Scheduler Metrics**
   - `scheduler_pending_pods`

3. **Host Health**
   - `HealthyHostCount`
   - `UnHealthyHostCount`

## 🔐 Security Features
- SSL/TLS encryption via custom domain
- AWS IAM roles for service access
- Kubernetes RBAC for cluster access
- Secrets management via Kubernetes secrets

## 📁 Project Structure
```
azodha/
├── .github/
│   └── workflows/
│       └── deploy.yml          # CI/CD pipeline
├── terraform/
│   ├── main.tf                 # Main Terraform configuration
│   ├── variables.tf            # Variable definitions
│   ├── outputs.tf              # Output values
│   └── provider.tf             # Provider configuration
├── k8s/
│   ├── deployment.yaml         # Kubernetes deployment
│   └── service.yaml            # Kubernetes service (LoadBalancer)
├── src/
│   └── index.js                # Express application
├── Dockerfile                  # Docker build configuration
├── package.json                # Node.js dependencies
└── README.md                   # This file
```

## 🔧 Configuration

### Environment Variables
- `PORT`: Application port (default: 3000)
- `AWS_REGION`: AWS region (default: us-east-1)

### Kubernetes Resources
- **Deployment**: 2 replicas of the application
- **Service**: LoadBalancer type for external access
- **Container Port**: 3000
- **Service Port**: 80

## 🧪 Testing

### Local Testing
```bash
# Install dependencies
npm install

# Run locally
npm start

# Test endpoint
curl http://localhost:3000/health
```

### Docker Testing
```bash
# Build image
docker build -t azodha-api .

# Run container
docker run -p 3000:3000 azodha-api

# Test endpoint
curl http://localhost:3000/health
```

### Kubernetes Testing
```bash
# Check deployment status
kubectl get deployments

# Check pods
kubectl get pods

# Check service
kubectl get services

# Get logs
kubectl logs -l app=azodha-api
```

## 📝 Maintenance

### Updating the Application
1. Make code changes
2. Commit and push to GitHub
3. GitHub Actions will automatically:
   - Build new Docker image
   - Push to Docker Hub
   - Deploy to EKS cluster

### Scaling
```bash
# Scale deployment
kubectl scale deployment azodha-api-deployment --replicas=3
```

### Monitoring Logs
```bash
# View application logs
kubectl logs -f deployment/azodha-api-deployment

# View CloudWatch logs
aws logs tail /aws/eks/azodha-eks-cluster/cluster --follow
```

## 🗑️ Cleanup

To destroy all infrastructure:

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/

# Destroy Terraform infrastructure
cd terraform
terraform destroy -auto-approve
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is created for educational purposes as part of a DevOps assignment.

## 👤 Author

**Amol Devakate**
- GitHub: [@amoldevakate2026](https://github.com/amoldevakate2026)
- Docker Hub: [amoldevakate2026](https://hub.docker.com/u/amoldevakate2026)

## 🙏 Acknowledgments

- AWS EKS Documentation
- Kubernetes Documentation
- Terraform AWS Provider Documentation
- Express.js Framework

---

**Status**: ✅ Deployed and Running
**Last Updated**: January 2025
