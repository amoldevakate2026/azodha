data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "azodha-project" {
  name               = "eks-cluster-cloud"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "azodha-project-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.azodha-project.name
}

#get vpc data
data "aws_vpc" "default" {
  default = true
}
#get public subnets for cluster
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1f"]
  }
}
#cluster provision
resource "aws_eks_cluster" "azodha-project" {
  name     = "EKS_CLOUD"
  role_arn = aws_iam_role.azodha-project.arn

  vpc_config {
    subnet_ids = data.aws_subnets.public.ids
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.azodha-project-AmazonEKSClusterPolicy,
  ]
}

resource "aws_iam_role" "azodha-project-1" {
  name = "eks-node-group-cloud"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "azodha-project-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.azodha-project-1.name
}

resource "aws_iam_role_policy_attachment" "azodha-project-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.azodha-project-1.name
}

resource "aws_iam_role_policy_attachment" "azodha-project-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.azodha-project-1.name
}

resource "aws_eks_node_group" "azodha-project" {
  cluster_name    = aws_eks_cluster.azodha-project.name
  node_group_name = "Node-cloud-v3"  node_role_arn   = aws_iam_role.azodha-project-1.arn
  subnet_ids      = data.aws_subnets.public.ids

  scaling_config {
    desired_size = 1

    max_size     = 2
    min_size     = 1
  }

  instance_types = ["t2.medium"]
  depends_on = [
    aws_iam_role_policy_attachment.azodha-project-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.azodha-project-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.azodha-project-AmazonEC2ContainerRegistryReadOnly,
  ]
}
