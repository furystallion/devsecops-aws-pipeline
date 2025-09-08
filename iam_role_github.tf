# IAM Role for GitHub Actions to assume
data "aws_iam_policy_document" "github_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:<YOUR_GITHUB_USERNAME>/<YOUR_REPO_NAME>:*"]
    }
  }
}

resource "aws_iam_role" "github_deploy" {
  name               = "github-deploy-role"
  assume_role_policy = data.aws_iam_policy_document.github_trust.json
}

# Attach AdministratorAccess for demo purposes (can tighten later)
resource "aws_iam_role_policy_attachment" "github_attach" {
  role       = aws_iam_role.github_deploy.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "github_deploy_role_arn" {
  value = aws_iam_role.github_deploy.arn
}
