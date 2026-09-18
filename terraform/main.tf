data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "amazon_linux_2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

locals {
  tags = {
    Project     = var.project_name
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name               = "${var.project_name}-prod-ec2-ssm"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "${var.project_name}-prod-ec2-ssm"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_instance" "prod" {
  ami                         = data.aws_ssm_parameter.amazon_linux_2023.value
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.prod_public.id
  vpc_security_group_ids      = [aws_security_group.prod.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  key_name                    = var.key_name
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(local.tags, {
    Name = "${var.project_name}-prod"
    Role = "todo-platform"
  })
}
