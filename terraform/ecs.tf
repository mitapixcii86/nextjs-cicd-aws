resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cluster"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "ecs-task" # Naming our first task
  container_definitions    = <<DEFINITION
  [
    {
      "name": "ecs-task",
      "image": "${aws_ecr_repository.repo.repository_url}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "memory": 512,
      "cpu": 256
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 512         # Specifying the memory our container requires
  cpu                      = 256         # Specifying the CPU our container requires
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_service" "ecs_service" {
  name            = "ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  launch_type     = "FARGATE"
  desired_count   = 3
  depends_on      = [aws_alb_listener.listener]

  load_balancer {
    target_group_arn = aws_alb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.ecs_task.family
    container_port   = 3000
  }


  network_configuration {
    subnets          = [aws_subnet.devops_subnet_a.id, aws_subnet.devops_subnet_b.id, aws_subnet.devops_subnet_c.id]
    assign_public_ip = true # Providing our containers with public IPs
  }
}

resource "aws_security_group" "service_security_group" {
  name        = "ecs_security_group"
  description = "Allows inbound access from the ALB only"
  vpc_id      = aws_vpc.devops_vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer_security_group.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "ecs" {
  name                        = aws_ecs_cluster.ecs_cluster.name
  image_id                    = lookup(var.amis, var.region)
  instance_type               = var.instance_type
  security_groups             = [aws_security_group.load_balancer_security_group.id]
  iam_instance_profile        = aws_iam_instance_profile.ecs.name
  key_name                    = aws_key_pair.devops.key_name
  associate_public_ip_address = true
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${aws_ecs_cluster.ecs_cluster.name}' > /etc/ecs/ecs.config"
}

# data "template_file" "app" {
#   template = file("templates/nextjs_app.json.tpl")

#   vars = {
#     docker_image_url_nextjs = aws_ecr_repository.repo.repository_url
#     region                  = aws.region
#   }
# }

resource "aws_autoscaling_group" "ecs-cluster" {
  name                 = "${aws_ecs_cluster.ecs_cluster.name}_auto_scaling_group"
  min_size             = var.autoscale_min
  max_size             = var.autoscale_max
  desired_capacity     = var.autoscale_desired
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.ecs.name
  vpc_zone_identifier  = [aws_subnet.devops_subnet_a.id, aws_subnet.devops_subnet_b.id, aws_subnet.devops_subnet_c.id]
}

resource "aws_key_pair" "devops" {
  key_name   = "${aws_ecs_cluster.ecs_cluster.name}_key_pair"
  public_key = file(var.ssh_pubkey_file)
}
