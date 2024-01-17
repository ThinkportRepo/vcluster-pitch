# call the terraform-aws-eks module to deploy your EKS cluster
module "eks_cluster" {
  source       = "../eks-cluster"
  cluster_name = data.aws_eks_cluster.cluster.name
}

# Use the cluster_id output in your null resource
/*resource "null_resource" "eks_master_worker_join" {
  provisioner "local-exec" {
    command = "bash -x setup-env.sh ${data.aws_eks_cluster.cluster.name}"
  }
}*/

resource "aws_instance" "eks-ins" {
  ami           = module.eks_cluster.cluster_security_
  instance_type = ""
  key_name = ""
  vpc_security_group_ids = []
    # Connect with AWS Resoeces
  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("./tf_provisioner.pem")
  }
  provisioner "file" {
    source      = "setup-env.sh"
    destination = "/tmp/setup-env.sh"
  }

  provisioner "file" {
    source      = "kubeconfig-create-rbac.sh"
    destination = "/tmp/kubeconfig-create-rbac.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-env.sh",
      "/tmp/setup-env.sh args",
    ]
  }
}
