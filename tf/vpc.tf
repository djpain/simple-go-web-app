module "vpc" {
  source         = "github.com/terraform-community-modules/tf_aws_vpc"
  name           = "${var.appname}-${var.environ}-vpc"
  cidr           = "10.100.0.0/16"
  public_subnets = "10.100.101.0/24,10.100.102.0/24"
  azs            = "${var.azs}"
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
    protocol    = "-1"
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
