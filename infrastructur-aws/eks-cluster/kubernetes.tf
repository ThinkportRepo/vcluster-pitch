###########################################
# Datei für Terraform Kubernetes-Anbieter #
###########################################

provider "kubernetes" {
    host = data.aws_eks_cluster.cluster.endpoint # verwendung der erstellten Cluster als Host
    token = data.aws_eks_cluster_auth.cluster_name.token # Ein Authentifizierungstoken als Token.
    cluster_ca_certificate = base64encode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  #Die verwendung des Cluster_ca_certificate für das CA-Zertifikat
}