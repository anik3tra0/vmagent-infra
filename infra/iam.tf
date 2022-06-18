# Create IAM Roles
# Create EC2 Trustee role. Check Tag Description
resource aws_iam_role "ec2-trustee" {
  name = "ec2-trustee"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "EC2 trustee"
    Description = "This role needs to be attached to any AWS Service that needs to have the ability to assume role"
  }
}

# Create VMAgent SD role. Check Tag Description
resource aws_iam_role "vmagent-sd-role" {
  name = "vmagent-sd-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          AWS = aws_iam_role.ec2-trustee.arn
        }
      },
    ]
  })

  tags = {
    Name        = "VMAgent Service Discovery Role"
    Description = "This role needs to be provided to VMAgent to allow EC2 Service Discovery"
  }
}

resource "aws_iam_instance_profile" "ec2-trustee-profile" {
  name = "ec2-trustee-profile"
  role = aws_iam_role.ec2-trustee.name
}


resource aws_iam_policy "ec2_read_only_inline_policy" {
  name        = "ec2-metadata-attr-read-only-policy"
  description = "Attach this policy to any role that requires underlying resource to access EC2 metadata"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action   = "ec2:Describe*"
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.vmagent-sd-role.name
  policy_arn = aws_iam_policy.ec2_read_only_inline_policy.arn
}
