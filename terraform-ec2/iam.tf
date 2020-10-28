resource "aws_iam_role" "ec2-host-role" {
  name               = "ec2_host_role_devops_${aws_instance.test_devops}"
  assume_role_policy = file("policies/ec2-role.json")
}

resource "aws_iam_role_policy" "ec2-instance-role-policy" {
  name   = "ec2_instance_role_policy_${aws_instance.test_devops}"
  policy = file("policies/ec2-instance-role-policy.json")
  role   = aws_iam_role.ec2-host-role.id
}

resource "aws_iam_instance_profile" "ec2" {
  name = "ec2_instance_profile"
  path = "/"
  role = aws_iam_role.ec2-host-role.name
}