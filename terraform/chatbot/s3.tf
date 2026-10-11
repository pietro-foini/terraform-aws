resource "aws_s3_bucket" "chatbot_bucket" {
  bucket = "${var.account_name}-chatbot"

  tags = {
    team = "ml"
  }
}

resource "aws_s3_bucket_ownership_controls" "chatbot_bucket" {
  bucket = aws_s3_bucket.chatbot_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_public_access_block" "chatbot_bucket" {
  bucket = aws_s3_bucket.chatbot_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
