
resource "aws_ecr_repository" "link_store" {
  name                 = var.link_store_ecr
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}