resource "aws_elb" "jenkins-elb" {
  name = "jenkins-elb"
  security_groups = ["${aws_security_group.load_balancers_jenkins.id}"]
  subnets = ["${aws_subnet.jenkins.id}"]

  listener {
    lb_protocol = "http"
    lb_port = 80

    instance_protocol = "http"
    instance_port = 8080
  }

  listener {
    lb_protocol = "tcp"
    lb_port = 50000

    instance_protocol = "tcp"
    instance_port = 50000
  }

  /* @todo - handle SSL */
  /*listener {
    instance_port = 5000
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "arn:aws:iam::123456789012:server-certificate/certName"
  }*/

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 5
    timeout = 5
    target = "HTTP:8080/"
    interval = 30
  }

  cross_zone_load_balancing = true
}

resource "template_file" "jenkins_task_template" {
  template = "${file("templates/jenkins.json.tpl")}"

  vars {
    aws_access_key = "${var.access_key}"
    aws_secret_key = "${var.secret_key}"
    s3_bucket = "${aws_s3_bucket.jenkins_data.id}"
    jenkins_repository_url = "${var.jenkins_repository_url}"
  }
}

resource "aws_ecs_task_definition" "jenkins" {
  family = "jenkins"
  container_definitions = "${template_file.jenkins_task_template.rendered}"

  volume {
    name = "jenkins-home"
    host_path = "${var.jenkins_host_dir}"
  }
}

resource "aws_ecs_service" "jenkins" {
  name = "jenkins"
  cluster = "${aws_ecs_cluster.jenkins.id}"
  task_definition = "${aws_ecs_task_definition.jenkins.arn}"
  iam_role = "${aws_iam_role.ecs_service_role_jenkins.arn}"
  desired_count = "${var.desired_service_count}"
  depends_on = [
    "aws_iam_role_policy.ecs_service_role_policy_jenkins",
    "aws_s3_bucket.jenkins_data"
  ]

  load_balancer {
    elb_name = "${aws_elb.jenkins-elb.id}"
    container_name = "jenkins"
    container_port = 8080
  }
}
