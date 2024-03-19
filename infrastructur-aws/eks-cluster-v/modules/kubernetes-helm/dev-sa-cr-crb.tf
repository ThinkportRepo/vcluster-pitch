resource "kubernetes_service_account" "admin-dev-sa" {
  metadata {
    name      = "admin-dev-sa"
    namespace = kubernetes_namespace.v-dev-ns.metadata[0].name
  }
  secret {
    name = kubernetes_secret.admin-dev-secret.metadata[0].name
  }
}

resource "kubernetes_secret" "admin-dev-secret" {
  metadata {
    name      = "admin-dev-secret"
    namespace = kubernetes_namespace.v-dev-ns.metadata[0].name
  }
}

resource "kubernetes_role" "admin_dev_role" {
  metadata {
    name      = "admin-dev-role"
    namespace = kubernetes_namespace.v-dev-ns.metadata[0].name
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "admin_dev_role_binding" {
  metadata {
    name      = "admin-dev-rolebinding"
    namespace = kubernetes_namespace.v-dev-ns.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.admin-dev-sa.metadata[0].name
    namespace = kubernetes_namespace.v-dev-ns.metadata[0].name
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.admin_dev_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role" "admin-dev-cr" {
  metadata {
    name = "admin-dev-cr"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "admin-dev-crb" {
  metadata {
    name = "admin-dev-crb"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.admin-dev-cr.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.admin-dev-sa.metadata[0].name
    namespace = kubernetes_service_account.admin-dev-sa.metadata[0].namespace
  }
}