resource "kubernetes_service_account" "admin-prod-sa" {
  depends_on = [kubernetes_namespace.v-prod-ns]
  metadata {
    name      = "admin-prod-sa"
    namespace = kubernetes_namespace.v-prod-ns.metadata[0].name
  }
  secret {
    name = kubernetes_secret.admin-prod-secret.metadata[0].name
  }
}

resource "kubernetes_secret" "admin-prod-secret" {
  metadata {
    name      = "admin-prod-secret"
    namespace = kubernetes_namespace.v-prod-ns.metadata[0].name
  }
}

resource "kubernetes_role" "admin_prod_role" {
  metadata {
    name      = "admin-prod-role"
    namespace = kubernetes_namespace.v-prod-ns.metadata[0].name
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "admin_prod_role_binding" {
  metadata {
    name      = "admin-prod-rolebinding"
    namespace = kubernetes_namespace.v-prod-ns.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.admin-prod-sa.metadata[0].name
    namespace = kubernetes_namespace.v-prod-ns.metadata[0].name
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.admin_prod_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}


resource "kubernetes_cluster_role" "admin-prod-cr" {
  metadata {
    name = "admin-prod-cr"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "admin-prod-crb" {
  metadata {
    name = "admin-prod-crb"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.admin-prod-cr.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.admin-prod-sa.metadata[0].name
    namespace = kubernetes_service_account.admin-prod-sa.metadata[0].namespace
  }
}