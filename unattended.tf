################################################################################
# Standard AWS provider config
################################################################################

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

################################################################################
# We need to create an S3 bucket to host the files required for an unattended
# bootstap of the Chef client
################################################################################

# Creates the S3 bucket
resource "aws_s3_bucket" "chefboot" {
    bucket = "${lower("${var.environment}-${var.project_name}-chefboot")}"
    acl    = "private"
}

################################################################################
# We need to create an IAM role, an IAM instance profile and IAM policy to allow
# AWS instances to access the contents of our S3 bucket
################################################################################

# Creates IAM role
resource "aws_iam_role" "chefboot" {
    name               = "chefboot_role"
    path               = "/"
    assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Creates IAM instance profile for IAM role
resource "aws_iam_instance_profile" "chefboot" {
    name  = "chefboot_instance_profile"
    path  = "/"
    roles = ["${aws_iam_role.chefboot.name}"]
}

# Creates IAM policy to grant read-only access to S3 bucket and its contents
resource "aws_iam_policy" "chefboot" {
    name   = "chefboot_policy"
    path   = "/"
    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.chefboot.bucket}",
        "arn:aws:s3:::${aws_s3_bucket.chefboot.bucket}/*"
      ]
    }
  ]
}
POLICY
depends_on = ["aws_s3_bucket.chefboot"]
}

# Attaches IAM policy to IAM role
resource "aws_iam_policy_attachment" "chefboot" {
    name = "chefboot_policy_attachment"
    roles = ["${aws_iam_role.chefboot.name}"]
    policy_arn = "${aws_iam_policy.chefboot.arn}"
}

################################################################################
# We need to create the relevant client configuration files within the S3 bucket
################################################################################

# Creates client.rb file
resource "template_file" "client_rb" {
    template = "${file("./templates/client_rb.txt")}"
    vars {
      chef_server_url = "${var.chef_server_url}"
      validator_pem = "${var.validation_key}"
      validation_client_name = "${var.validation_client_name}"
      }
}

resource "aws_s3_bucket_object" "client_rb" {
    bucket = "${aws_s3_bucket.chefboot.bucket}"
    key = "client.rb"
    content = "${template_file.client_rb.rendered}"
    depends_on = ["aws_s3_bucket.chefboot"]
}

# Creates first_run.json file
resource "template_file" "first_run" {
    template = "${file("./templates/first_run.txt")}"
    vars {
      run_list = "${var.run_list}"
      }
}

resource "aws_s3_bucket_object" "first_run_json" {
    bucket = "${aws_s3_bucket.chefboot.bucket}"
    key = "first_run.json"
    content = "${template_file.first_run.rendered}"
    depends_on = ["aws_s3_bucket.chefboot"]
}

# Copies validator.pem file
resource "aws_s3_bucket_object" "validator_pem" {
    bucket = "${aws_s3_bucket.chefboot.bucket}"
    key = "${var.validation_key}"
    source = "${var.validation_key_location}${var.validation_key}"
    depends_on = ["aws_s3_bucket.chefboot"]
}

################################################################################
# We need to generate a cloud_init file to be run on our AWS instances at first
# and run to initiate the unattended bootstap of the Chef client
################################################################################

# Creates cloud_init file from ./cloud_init.txt template
resource "template_file" "cloud_init" {
    template = "${file("./templates/cloud_init.txt")}"
    vars {
      chef_version = "${var.chef_version}"
      s3_bucket = "${aws_s3_bucket.chefboot.bucket}"
      }
}

################################################################################
# We can create AWS instances as shown below
################################################################################

# Creates AWS instance
resource "aws_instance" "example" {
    ami = "ami-8b8c57f8"
    instance_type = "t2.micro"
#   Gives the instance permission to download files from our S3 bucket
    iam_instance_profile = "${aws_iam_instance_profile.chefboot.name}"
#   Applies our cloud_init file to the instance for execution on first run
    user_data = "${template_file.cloud_init.rendered}"
#   This line is required to assign an EC2 key pair for SSH access to instance
#    key_name = "${var.key_name}"
    depends_on = ["aws_iam_instance_profile.chefboot"]
}
