### s3 bucket creation ###
resource "aws_s3_bucket" "BucketA" {
  bucket = "genomicsengland-bucket-a-with-exif"
  acl    = "private"
}

resource "aws_s3_bucket" "BucketB" {
  bucket = "genomicsengland-bucket-b-without-exif"
  acl    = "private"
}


### Lamda function creation ###

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "Image"
  description   = "Image processer lambda function"
  handler       = "index.lambda_handler"
  runtime       = "python3.8"

  source_path = "./src/index.py"
}


### cloudwatch event rule ###

resource "aws_cloudwatch_event_target" "Lamda" {
  depends_on = [module.lambda_function]
  rule = aws_cloudwatch_event_rule.console.name
  arn  = module.lambda_function.lambda_function_arn
}

resource "aws_cloudwatch_event_rule" "console" {
  name        = "capture-BucketA-PutObject"
  description = "capture-BucketA-PutObject"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "PutObject"
    ],
    "requestParameters": {
      "bucketName": [
        "genomicsengland-bucket-a-with-exif"
      ]
    }
  }
}
PATTERN
}


### IAM Role ###

resource "aws_iam_user" "userA" {
  name = "USER-A"
}

resource "aws_iam_user_policy" "userA" {
  name = "userA"
  user = aws_iam_user.userA.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*",
                "s3:Write*"
            ],
            "Resource": "arn:aws:s3:::genomicsengland-bucket-a-with-exif"
        }
    ]
}
EOF
}



resource "aws_iam_user" "userB" {
  name = "USER-B"
}

resource "aws_iam_user_policy" "userB" {
  name = "userB"
  user = aws_iam_user.userB.name

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "arn:aws:s3:::my-buckgenomicsengland-bucket-b-without-exif"
        }
    ]
}
EOF
}
