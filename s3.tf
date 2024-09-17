resource "aws_s3_bucket" "alb_logging" {
  bucket = "aws-alb-logging-564546"
  
}

resource "aws_s3_bucket_policy" "logging_policy" {
  bucket = aws_s3_bucket.alb_logging.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::${var.elb_account_id}:root"
          },
          "Action" : "s3:PutObject",
          "Resource" : "${aws_s3_bucket.alb_logging.arn}/*"
        }
      ]
    }
  )
}
