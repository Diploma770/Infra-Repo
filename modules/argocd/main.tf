terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubernetes_secret_v1" "repo" {
  count = var.create_repo_secret ? 1 : 0

  metadata {
    name      = var.repo_secret_name
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"

  data = merge(
    {
      url  = var.repo_url
      type = "git"
    },
    var.repo_auth_type == "ssh"
    ? { sshPrivateKey = var.repo_ssh_private_key }
    : {
      username = var.repo_username
      password = var.repo_password
    }
  )

  lifecycle {
    precondition {
      condition = !var.create_repo_secret || (
        var.repo_url != null && trimspace(var.repo_url) != ""
      )
      error_message = "When create_repo_secret=true, repo_url must be provided."
    }

    # precondition {
    #   condition = !var.create_repo_secret || (
    #     var.repo_auth_type != "ssh" || (
    #       var.repo_ssh_private_key != null && trimspace(var.repo_ssh_private_key) != ""
    #     )
    #   )
    #   error_message = "When repo_auth_type=ssh, repo_ssh_private_key must be provided."
    # }

    precondition {
      condition = !var.create_repo_secret || (
        var.repo_auth_type != "https" || (
          var.repo_username != null && trimspace(var.repo_username) != "" &&
          var.repo_password != null && trimspace(var.repo_password) != ""
        )
      )
      error_message = "When repo_auth_type=https, both repo_username and repo_password must be provided."
    }
  }

  depends_on = [helm_release.argocd]
}
