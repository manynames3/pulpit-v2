data "tls_certificate" "github_actions" {
  count = var.create_github_actions_role ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}

data "aws_caller_identity" "current" {
  count = var.create_github_actions_role ? 1 : 0
}

data "aws_region" "current" {
  count = var.create_github_actions_role ? 1 : 0
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  count = var.create_github_actions_role ? 1 : 0

  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions[0].certificates[0].sha1_fingerprint]

  tags = var.tags
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  count = var.create_github_actions_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions[0].arn]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repository}:*"]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  count = var.create_github_actions_role ? 1 : 0

  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role[0].json
  tags               = var.tags
}

data "aws_iam_policy_document" "github_actions_ecr" {
  count = var.create_github_actions_role ? 1 : 0

  statement {
    sid = "EcrAuth"

    actions = [
      "ecr:GetAuthorizationToken",
    ]

    resources = ["*"]
  }

  statement {
    sid = "PushImagesToProjectRepositories"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]

    resources = [
      "arn:aws:ecr:${data.aws_region.current[0].name}:${data.aws_caller_identity.current[0].account_id}:repository/${var.ecr_repository_prefix}/*"
    ]
  }
}

resource "aws_iam_policy" "github_actions_ecr" {
  count = var.create_github_actions_role ? 1 : 0

  name   = "${var.role_name}-ecr-push"
  policy = data.aws_iam_policy_document.github_actions_ecr[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "github_actions_ecr" {
  count = var.create_github_actions_role ? 1 : 0

  role       = aws_iam_role.github_actions[0].name
  policy_arn = aws_iam_policy.github_actions_ecr[0].arn
}
