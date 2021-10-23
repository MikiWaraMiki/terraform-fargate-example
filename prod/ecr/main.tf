resource "aws_ecr_repository" "backend" {
  name = "backend"

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = var.environment
    PJ_Prefix   = var.pj_prefix
  }
}

resource "aws_ecr_repository" "frontend" {
  name = "frontend"

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = var.environment
    PJ_Prefix   = var.pj_prefix
  }
}
