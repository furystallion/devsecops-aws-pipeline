# IAM role for AWS Config
resource "aws_iam_role" "config_role" {
  name = "devsecops-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "config.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# Attach correct AWS managed policy
resource "aws_iam_role_policy_attachment" "config_role_attach" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

# Config Recorder
resource "aws_config_configuration_recorder" "recorder" {
  name     = "devsecops-recorder"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
  }
}

# Config Delivery Channel
resource "aws_config_delivery_channel" "channel" {
  name           = "devsecops-channel"
  s3_bucket_name = aws_s3_bucket.logs.id

  depends_on = [aws_config_configuration_recorder.recorder, aws_s3_bucket_policy.logs_policy]
}

# Enable Recorder
resource "aws_config_configuration_recorder_status" "status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.channel]
}
