################################
# Datei für AWS Security Group #
################################
# 1- Erstellung von zwei Sicherheitsgruppen für zwei Worker-Knotengruppen
resource "aws_security_group" "worker_group_mgmt_g_one" {
  name_prefix = var.name_prefix
  vpc_id      = var.vpc_id

  ingress {
    # erlaubnis nur 22 Ports für die SSH-Verbindung
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Der SSH-Zugriff Beschränkung für den CIDR-Block 10.0.0.0/8
    cidr_blocks = var.cidr_blocks
  }
}
