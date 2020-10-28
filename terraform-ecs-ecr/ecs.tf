resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cluster"
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "ecs-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "ecs-task",
      "image": "${aws_ecr_repository.repo.repository_url}:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000,
          "protocol": "tcp"
        }
      ],
      "memory": 1024,
      "cpu": 512
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"] # Stating that we are using ECS Fargate
  network_mode             = "awsvpc"    # Using awsvpc as our network mode as this is required for Fargate
  memory                   = 1024        # Specifying the memory our container requires
  cpu                      = 512         # Specifying the CPU our container requires
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
      #identifiers = ["ec2.amazonaws.com"]
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
  desired_count   = 2
  depends_on      = [aws_alb_listener.listener]

  load_balancer {
    target_group_arn = aws_alb_target_group.target_group.arn
    container_name   = aws_ecs_task_definition.ecs_task.family
    container_port   = 3000
  }


  network_configuration {
    #subnets = [aws_subnet.devops_subnet_a.id, aws_subnet.devops_subnet_b.id, aws_subnet.devops_subnet_c.id]
    subnets = aws_subnet.devops_subnet.*.id
    #assign_public_ip = true # Providing our containers with public IPs
  }
}

resource "aws_security_group" "service_security_group" {
  name        = "ecs_security_group"
  description = "Allows inbound access from the ALB only"
  vpc_id      = aws_vpc.devops_vpc.id
  depends_on  = [aws_security_group.load_balancer_security_group]

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
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
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
  key_name                    = aws_key_pair.devops_generated_key.key_name
  associate_public_ip_address = true
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER='${aws_ecs_cluster.ecs_cluster.name}' > /etc/ecs/ecs.config"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecsTaskExecutionRole.name
}

data "template_file" "app" {
  template = file("templates/nextjs_app.json.tpl")

  vars = {
    docker_image_url_nextjs = aws_ecr_repository.repo.repository_url
    region                  = var.region
  }
}

resource "aws_autoscaling_group" "ecs-cluster" {
  name                 = "${aws_ecs_cluster.ecs_cluster.name}_auto_scaling_group"
  min_size             = var.autoscale_min
  max_size             = var.autoscale_max
  desired_capacity     = var.autoscale_desired
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.ecs.name
  #vpc_zone_identifier  = [aws_subnet.devops_subnet_a.id, aws_subnet.devops_subnet_b.id, aws_subnet.devops_subnet_c.id]
  vpc_zone_identifier = aws_subnet.devops_subnet.*.id
}

# resource "aws_key_pair" "devops" {
#   key_name   = "${aws_ecs_cluster.ecs_cluster.name}_key_pair"
#   public_key = file(var.ssh_pubkey_file)
# }

#Generate private key for ansible to access EC2 instance
resource "tls_private_key" "test_devops" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "cloud_pem_private" {
  filename = "key/${aws_key_pair.devops_generated_key.key_name}.pem"
  content  = tls_private_key.test_devops.private_key_pem
  provisioner "local-exec" {
    command = "chmod 400 ${self.filename}"
  }
}

resource "aws_key_pair" "devops_generated_key" {
  key_name   = "${aws_ecs_cluster.ecs_cluster.name}_key_pair"
  public_key = tls_private_key.test_devops.public_key_openssh
}