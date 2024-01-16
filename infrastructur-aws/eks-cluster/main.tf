###############################
# Datei für AWS-Konfiguration #
###############################


# stellt die Liste der Verfügbarkeitszonen für die Region eu-central-1 bereit
data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


resource "random_string" "suffix" {
  length  = 8
  special = false
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"

  create_role                   = true
  role_name                     = "AmazonEKS_EBS_CSI_DriverRole"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}

resource "aws_eks_addon" "ebs-csi" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.20.0-eksbuild.1"
  service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
  tags = {
    "eks_addon" = "ebs-csi"
    "terraform" = "true"
  }
}

/*resource "aws_instance" "run-script" {
  launch_template {
    id      = aws_launch_template.
    version = "${aws_launch_template.example.latest_version}"
  }
  provisioner "file" {
    source      = "config/vcluster/admin-values.yaml"
    destination = "/tmp/script.sh"
  }

  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x script.sh",
      "/tmp/script.sh",
    ]
  }
}*/

/*
## Template
#resource "aws_launch_template" "example" {
#  name = "example_template"
#
#  # ... other configurations ...
#}
#
#resource "aws_instance" "run-script" {
#  launch_template {
#    id      = aws_launch_template.example.id
#    version = "${aws_launch_template.example.latest_version}"
#  }
#  provisioner "file" {
#    source      = "config/vcluster/admin-values.yaml"
#    destination = "/tmp/script.sh"
#  }
#
#  provisioner "file" {
#    source      = "script.sh"
#    destination = "/tmp/script.sh"
#  }
#
  provisioner "remote-exec" {
    inline = [
      "chmod +x script.sh",
      "/tmp/script.sh",
    ]
  }
#}
variable "test_cluster_name" {
  value = "your_cluster_name_here"
}
# call the terraform-aws-eks module to deploy your EKS cluster
module "my_cluster" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = var.cluster_name

  # ...
}*/

/*
# Use the cluster_id output in your null resource
resource "null_resource" "eks_master_worker_join" {
  provisioner "local-exec" {
    command = "sh /Users/dhineshbabu.elango/Documents/Terraform_shellScripts/bin/eks_app_provision.sh ${local.cluster_name}"
  }
}*/
