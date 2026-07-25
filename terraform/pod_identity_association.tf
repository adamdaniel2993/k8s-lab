
data "aws_iam_policy_document" "trust" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

data "aws_iam_policy_document" "read_db_secret" {
  statement {
    effect    = "Allow"
    actions   = [
      "secretsmanager:GetSecretValue",
      "kms:Decrypt"
    ]
    resources = [
      "arn:aws:secretsmanager:us-east-1:674288684391:secret:/linkstore/test/rds/postgres/master-*"
    ]
  }
}

resource "aws_iam_role" "pod_read_db_secret" {
  name               = "eks-pod-read-db-secret"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_policy" "read_db_secret" {
  name   = "read-db-secret"
  policy = data.aws_iam_policy_document.read_db_secret.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.pod_read_db_secret.name
  policy_arn = aws_iam_policy.read_db_secret.arn
}


resource "aws_eks_pod_identity_association" "example" {
  cluster_name    = module.eks.cluster_name
  namespace       = "linkstore"
  service_account = "linkstore-sa"
  role_arn        = aws_iam_role.pod_read_db_secret.arn
}