resource "kubernetes_service_account" "admin-sa" {
  metadata {
    name      = "admin-sa"
    namespace = kubernetes_namespace.v-admin-ns.metadata[0].name
  }
  secret {
    name = kubernetes_secret.admin-secret.metadata[0].name
  }
}

resource "kubernetes_secret" "admin-secret" {
  metadata {
    name      = "admin-secret"
    namespace = kubernetes_namespace.v-admin-ns.metadata[0].name
  }
}

resource "kubernetes_role" "admin_role" {
  metadata {
    name      = "admin-role"
    namespace = kubernetes_namespace.v-admin-ns.metadata[0].name
  }

  rule {
    api_groups = ["*"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "admin_role_binding" {
  metadata {
    name      = "admin-rolebinding"
    namespace = kubernetes_namespace.v-admin-ns.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.admin-sa.metadata[0].name
    namespace = kubernetes_namespace.v-admin-ns.metadata[0].name
  }

  role_ref {
    kind      = "Role"
    name      = kubernetes_role.admin_role.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_cluster_role" "admin-cr" {
  metadata {
    name = "admin-cr"
  }

  rule {
    api_groups = [""]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "admin-crb" {
  metadata {
    name = "admin-crb"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.admin-cr.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.admin-sa.metadata[0].name
    namespace = kubernetes_service_account.admin-sa.metadata[0].namespace
  }
}