# The ECS cluster
resource "aws_ecs_cluster" "cluster" {
  name = "${var.appname}_${var.environ}"
}

resource "template_file" "task_definition" {
  depends_on = ["null_resource.docker"]
  template   = "${file("task-definition.json.tmpl")}"

  vars {
    name        = "${var.appname}_${var.environ}"
    image       = "${var.dockerimg}"
    docker_port = "${var.docker_port}"
    host_port   = "${var.host_port}"
  }
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                = "${var.appname}_${var.environ}"
  container_definitions = "${template_file.task_definition.rendered}"
}

resource "aws_elb" "service_elb" {
  name                      = "${var.appname}-${var.environ}"
  subnets                   = ["${split(",", module.vpc.public_subnets)}"]
  connection_draining       = true
  cross_zone_load_balancing = true

  security_groups = [
    "${aws_security_group.allow_cluster.id}",
    "${aws_security_group.allow_80_inbound.id}",
    "${aws_security_group.allow_all_outbound.id}",
  ]

  listener {
    instance_port     = "${var.host_port}"
    instance_protocol = "http"
    lb_port           = "${var.lb_port}"
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    target              = "HTTP:${var.host_port}/"
    interval            = 5
    timeout             = 4
  }
}

resource "aws_ecs_service" "ecs_service" {
  name                               = "${var.appname}_${var.environ}"
  cluster                            = "${aws_ecs_cluster.cluster.id}"
  task_definition                    = "${aws_ecs_task_definition.ecs_task.arn}"
  desired_count                      = 3
  iam_role                           = "${aws_iam_role.ecs_elb.arn}"
  depends_on                         = ["aws_iam_policy_attachment.ecs_elb"]
  deployment_minimum_healthy_percent = 50

  load_balancer {
    elb_name       = "${aws_elb.service_elb.id}"
    container_name = "${var.appname}_${var.environ}"
    container_port = "${var.docker_port}"
  }
}

resource "template_file" "user_data" {
  template = "ec2_user_data.tmpl"

  vars {
    cluster_name = "${var.appname}_${var.environ}"
  }
}

resource "aws_iam_instance_profile" "ecs" {
  name  = "${var.appname}_${var.environ}"
  roles = ["${aws_iam_role.ecs.name}"]
}

resource "aws_launch_configuration" "ecs_cluster" {
  name                        = "${var.appname}_cluster_conf_${var.environ}"
  instance_type               = "t2.micro"
  image_id                    = "${lookup(var.ami, var.aws_region)}"
  iam_instance_profile        = "${aws_iam_instance_profile.ecs.id}"
  associate_public_ip_address = true

  security_groups = [
    "${aws_security_group.allow_all_ssh.id}",
    "${aws_security_group.allow_all_outbound.id}",
    "${aws_security_group.allow_cluster.id}",
  ]

  user_data = "${template_file.user_data.rendered}"
  key_name  = "${var.key_name}"
}

resource "aws_autoscaling_group" "ecs_cluster" {
  name                 = "${var.appname}_${var.environ}"
  vpc_zone_identifier  = ["${split(",", module.vpc.public_subnets)}"]
  min_size             = 0
  max_size             = 3
  desired_capacity     = 3
  launch_configuration = "${aws_launch_configuration.ecs_cluster.name}"
  health_check_type    = "EC2"
}
