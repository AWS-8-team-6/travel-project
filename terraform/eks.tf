# IAM role for EBS CSI driver (IRSA)
module "ebs_csi_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.cluster_name}-ebs-csi-sa"
  attach_ebs_csi_policy = true

  oidc_providers = {
    eks = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = {
    MadeBy = "seoho-terraform"
  }
}

# EKS cluster with IRSA and CSI driver addon
module "eks" {
  source        = "terraform-aws-modules/eks/aws"
  version       = "20.0.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnet_ids

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      name             = "ng-default"
      desired_capacity = var.node_group_desired
      max_capacity     = var.node_group_max
      min_capacity     = var.node_group_min
      instance_types   = [var.node_instance_type]
    }
  }

  cluster_addons = {
    aws-ebs-csi-driver = {
      addon_version            = "v1.27.0-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = module.ebs_csi_irsa_role.iam_role_arn
    }
  }

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access = true

  tags = {
    MadeBy = "seoho-terraform"
  }
}
