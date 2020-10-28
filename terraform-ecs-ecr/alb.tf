resource "aws_alb" "application_load_balancer" {
  name               = "devops-lb-tf" # Naming our load balancer
  load_balancer_type = "application"
  # subnets = [ # Referencing the default subnets
  #   aws_subnet.devops_subnet_a.id,
  #   aws_subnet.devops_subnet_b.id,
  #   aws_subnet.devops_subnet_c.id
  # ]
  subnets = aws_subnet.devops_subnet.*.id
  # Referencing the security group
  security_groups = [aws_security_group.load_balancer_security_group.id]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  name        = "devops-alb-sg"
  description = "allow incoming HTTP traffic only"
  vpc_id      = aws_vpc.devops_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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
  tags = {
    Name = "devops-alb-sg"
  }
}

resource "aws_alb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.devops_vpc.id
  health_check {
    matcher = "200,301,302"
    path    = "/"
  }
}

resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.target_group.arn
  }
}

output "url" {
  value = "http://${aws_alb.application_load_balancer.dns_name}/"
}


