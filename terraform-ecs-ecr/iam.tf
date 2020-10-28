resource "aws_iam_role" "ecs-host-role" {
  name               = "ecs_host_role_devops_${aws_ecs_cluster.ecs_cluster.name}"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs-instance-role-policy" {
  name   = "ecs_instance_role_policy_${aws_ecs_cluster.ecs_cluster.name}"
  policy = file("policies/ecs-instance-role-policy.json")
  role   = aws_iam_role.ecs-host-role.id
}

resource "aws_iam_role" "ecs-service-role" {
  name               = "ecs_service_role_devops_${aws_ecs_cluster.ecs_cluster.name}"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs-service-role-policy" {
  name   = "ecs_service_role_devops_policy_${aws_ecs_cluster.ecs_cluster.name}"
  policy = file("policies/ecs-service-role-policy.json")
  role   = aws_iam_role.ecs-service-role.id
}

resource "aws_iam_instance_profile" "ecs" {
  name = "ecs_instance_profile"
  path = "/"
  role = aws_iam_role.ecs-host-role.name
}