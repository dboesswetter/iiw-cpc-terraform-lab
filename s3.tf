resource "aws_s3_bucket" "myS3_bucket" {
  bucket = "my-log-bucket-pascalwende-02102001"
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.myS3_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::127311923021:root"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::my-log-bucket-pascalwende-02102001/AWSLogs/568225090681/*"
      },
    ]
  })
}


