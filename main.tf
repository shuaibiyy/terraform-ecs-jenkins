provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.region}"
}

resource "aws_vpc" "jenkins" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_route_table" "external" {
  vpc_id = "${aws_vpc.jenkins.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.jenkins.id}"
  }
}

resource "aws_route_table_association" "external-jenkins" {
  subnet_id = "${aws_subnet.jenkins.id}"
  route_table_id = "${aws_route_table.external.id}"
}

resource "aws_subnet" "jenkins" {
  vpc_id = "${aws_vpc.jenkins.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.availability_zone}"
}

resource "aws_internet_gateway" "jenkins" {
  vpc_id = "${aws_vpc.jenkins.id}"
}

resource "aws_security_group" "load_balancers_jenkins" {
  name = "load_balancers_jenkins"
  description = "Allows all traffic"
  vpc_id = "${aws_vpc.jenkins.id}"

  # TODO: do we need to allow ingress besides TCP 80 and 443?
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  # TODO: this probably only needs egress to the ECS security group.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_jenkins" {
  name = "ecs_jenkins"
  description = "Allows all traffic"
  vpc_id = "${aws_vpc.jenkins.id}"

  # TODO: remove this and replace with a bastion host for SSHing into individual machines.
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = [
      "${aws_security_group.load_balancers_jenkins.id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "jenkins" {
  name = "${var.ecs_cluster_name}"
}

resource "aws_autoscaling_group" "ecs-cluster" {
  availability_zones = [
    "${var.availability_zone}"]
  name = "ASG ${var.ecs_cluster_name}"
  min_size = "${var.min_instance_size}"
  max_size = "${var.max_instance_size}"
  desired_capacity = "${var.desired_instance_capacity}"
  health_check_type = "EC2"
  health_check_grace_period = 300
  launch_configuration = "${aws_launch_configuration.ecs.name}"
  load_balancers = ["${aws_elb.jenkins-elb.name}"]
  vpc_zone_identifier = [
    "${aws_subnet.jenkins.id}"]
}

resource "template_file" "user_data" {
  template = "${file("templates/user_data.tpl")}"

  vars {
    ecs_cluster_name = "${var.ecs_cluster_name}"
    jenkins_host_dir = "${var.jenkins_host_dir}"
  }
}

resource "aws_launch_configuration" "ecs" {
  name = "ECS ${var.ecs_cluster_name}"
  image_id = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"
  security_groups = [
    "${aws_security_group.ecs_jenkins.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.ecs.name}"
  key_name = "${var.key_name}"
  associate_public_ip_address = true
  user_data = "${template_file.user_data.rendered}"
}

resource "aws_iam_role" "ecs_host_role_jenkins" {
  name = "ecs_host_role_jenkins"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_instance_role_policy_jenkins" {
  name = "ecs_instance_role_policy_jenkins"
  policy = "${file("policies/ecs-instance-role-policy.json")}"
  role = "${aws_iam_role.ecs_host_role_jenkins.id}"
}

resource "aws_iam_role" "ecs_service_role_jenkins" {
  name = "ecs_service_role_jenkins"
  assume_role_policy = "${file("policies/ecs-role.json")}"
}

resource "aws_iam_role_policy" "ecs_service_role_policy_jenkins" {
  name = "ecs_service_role_policy_jenkins"
  policy = "${file("policies/ecs-service-role-policy.json")}"
  role = "${aws_iam_role.ecs_service_role_jenkins.id}"
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs-instance-profile-jenkins"
  path = "/"
  roles = [
    "${aws_iam_role.ecs_host_role_jenkins.name}"]
}

resource "aws_s3_bucket" "jenkins_data" {
  bucket = "mycompany-${var.ecs_cluster_name}-data"
  acl = "private"
}
