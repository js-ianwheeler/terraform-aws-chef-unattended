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

module "s3" {
  source                  = "./modules/s3_unattended"
  environment             = "${var.environment}"
  project_name            = "${var.project_name}"
  chef_server_url         = "${var.chef_server_url}"
  validation_key          = "${var.validation_key}"
  validation_key_location = "${var.validation_key_location}"
  validation_client_name  = "${var.validation_client_name}"
}

################################################################################
# We can create AWS instances as shown below
################################################################################

module "server_1" {
  source                  = "./modules/ec2_unattended"
  server_name             = "example-1"
  description             = "First example server"
  run_list                = "role[unattended_bootstrap]"
  ami                     = "ami-8b8c57f8"
  instance_type           = "t2.micro"
  chef_version            = "${var.chef_version}"
  ssh_key_name            = "${var.ssh_key_name}"
  iam_instance_profile    = "${module.s3.iam_instance_profile}"
  s3_bucket               = "${module.s3.s3_bucket}"
}

module "server_2" {
  source                  = "./modules/ec2_unattended"
  server_name             = "example-2"
  description             = "Second example server"
  run_list                = "role[unattended_bootstrap_2]"
  ami                     = "ami-8b8c57f8"
  instance_type           = "t2.micro"
  chef_version            = "${var.chef_version}"
  ssh_key_name            = "${var.ssh_key_name}"
  iam_instance_profile    = "${module.s3.iam_instance_profile}"
  s3_bucket               = "${module.s3.s3_bucket}"
}
