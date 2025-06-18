###################################################################
# Providers for Kubernetes & Helm
###################################################################
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.auth.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.auth.token
  }
}

data "aws_eks_cluster_auth" "auth" {
  name = module.eks.cluster_name
}

###################################################################
# ArgoCD Helm release
###################################################################
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.39.6"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
        }
      }
    })
  ]

  depends_on = [module.eks]
}

###################################################################
# StorageClass for dynamic EBS provisioning
###################################################################
resource "kubernetes_storage_class" "ebs_sc" {
  metadata {
    name = "ebs-sc"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  reclaim_policy      = "Delete"
}

###################################################################
# Kubecost Helm release
###################################################################
resource "kubernetes_namespace" "kubecost" {
  metadata {
    name = "kubecost"
  }
}

resource "helm_release" "kubecost" {
  name             = "kubecost"
  repository       = "https://kubecost.github.io/cost-analyzer"
  chart            = "cost-analyzer"
  version          = "1.104.4"
  namespace        = kubernetes_namespace.kubecost.metadata[0].name
  create_namespace = false

  values = [
    yamlencode({
      storageClass = kubernetes_storage_class.ebs_sc.metadata[0].name
      prometheus = {
        server = {
          persistentVolume = {
            enabled = true
            size    = "20Gi"
          }
        }
      }
    })
  ]

  depends_on = [
    module.eks,
    kubernetes_storage_class.ebs_sc
  ]
}
