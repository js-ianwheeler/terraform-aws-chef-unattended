# Creates first_run.json file
resource "template_file" "first_run" {
    template = "${file("./templates/first_run.txt")}"
    vars {
      run_list = "${var.run_list}"
      }
}

resource "aws_s3_bucket_object" "first_run_json" {
    bucket = "${var.s3_bucket}"
    key = "${var.server_name}-first_run.json"
    content = "${template_file.first_run.rendered}"
}

# Creates cloud_init file from ./cloud_init.txt template
resource "template_file" "cloud_init" {
    template = "${file("./templates/cloud_init.txt")}"
    vars {
      server_name = "${var.server_name}"
      chef_version = "${var.chef_version}"
      s3_bucket = "${var.s3_bucket}"
    }
}

# Creates AWS instance
resource "aws_instance" "instance" {
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
#   Gives the instance permission to download files from our S3 bucket
    iam_instance_profile = "${var.iam_instance_profile}"
#   Applies our cloud_init file to the instance for execution on first run
    user_data = "${template_file.cloud_init.rendered}"
#   This line is required to assign an EC2 key pair for SSH access to instance
   key_name = "${var.ssh_key_name}"
    tags {
        "Name" = "${var.server_name}"
        "Description" = "${var.description}"
    }
}
