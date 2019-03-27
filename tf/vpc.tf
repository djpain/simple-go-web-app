module "vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  name           = "${var.appname}-${var.environ}-vpc"
  cidr           = "${var.cidr}"
  public_subnets = "${var.public_subnets}"
  azs            = "${var.azs}"

  tags {
    "Name"        = "${var.appname}"
    "terraform"   = "true"
    "environment" = "${var.environ}"
  }
}

resource "aws_security_group" "allow_all_outbound" {
  name_prefix = "${var.appname}-${var.environ}-${module.vpc.vpc_id}-"
  description = "Allow all outbound traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  egress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_80_inbound" {
  name_prefix = "${var.appname}-${var.environ}-${module.vpc.vpc_id}-"
  description = "Allow all inbound traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress = {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_cluster" {
  name_prefix = "${var.appname}-${var.environ}-${module.vpc.vpc_id}-"
  description = "Allow all traffic within cluster"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress = {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }

  egress = {
    from_port = 0
    to_port   = 65535
    protocol  = "tcp"
    self      = true
  }
}

resource "aws_security_group" "allow_all_ssh" {
  name_prefix = "${var.appname}-${var.environ}-${module.vpc.vpc_id}-"
  description = "Allow all inbound SSH traffic"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.privateip}"
  }
}
