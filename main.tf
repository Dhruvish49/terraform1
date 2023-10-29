resource "aws_iam_user" "full_access_user" {
  name = "IAM_USER"
}

resource "aws_iam_policy" "full_access_policy" {
  name        = "iam_rights"  
  description = "Policy with full access to AWS resources"
  
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "full_access_attachment" {
  name       = "FullAccessAttachment"
  users      = [aws_iam_user.full_access_user.name]
  policy_arn = aws_iam_policy.full_access_policy.arn
}

//resource "aws_iam_user" "limited_access_user" {
  //name = "LimitedUser"  
//}

resource "aws_iam_user_policy_attachment" "s3_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  user = aws_iam_user.limited_access_user.name
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "dhurvish-patel"  
  acl    = "private"
}

resource "aws_s3_object" "example_object" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "sample1.txt"  
  source = "/Users/dhruvishpatel/Downloads/sample1.txt"  
}


# Grant the limited_access_user permission to read and write to the S3 object
resource "aws_iam_user_policy_attachment" "s3_object_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"  
  user = aws_iam_user.limited_access_user.name
}

# Remove the IAM policy attachment
#resource "aws_iam_user_policy_attachment" "s3_access" {
  #user = aws_iam_user.limited_access_user.name
  #policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#}

# Now, wait for a short period to ensure the policy is detached.
resource "null_resource" "wait_for_detach" {
  triggers = {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "sleep 120"
  }
}

# Finally, remove the IAM user
resource "aws_iam_user" "limited_access_user" {
  name = "LimitedUser"  
  force_destroy = true
}

