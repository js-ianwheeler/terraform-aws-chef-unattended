# This is your AWS access key - it can be specifed here or provided as an
# environment variable AWS_ACCESS_KEY_ID
variable "access_key" {
#  default = "insert here"
}

# This is your AWS secret key - it can be specifed here or provided as an
# environment variable AWS_SECRET_ACCESS_KEY
variable "secret_key" {
#  default = "insert here"
}

# This is your AWS region - it can be specifed here or provided as an
# environment variable AWS_DEFAULT_REGION
variable "region" {
#  default = "insert here"
}

# This is the EC2 Key Pair that will provide SSH access to your instance
variable "key_name" {
  default = "ssh_access"
}

# This is your project name - it's used to name the S3 bucket
variable "project_name" {
  default = "project"
}

# Environment name - prod or test - it's also used to name the S3 bucket
variable "environment" {
  default = "test"
}

# This is the version of Chef Client that is downloaded and installed
variable "chef_version" {
  default = "12.8.1"
}

# This is the URL of your Chef Server
variable "chef_server_url" {
  default = "https://manage.chef.io/organizations/example/"
}

# This is the name of your Chef validation key
variable "validation_key" {
  default = "example-validator.pem"
}

# This is the local location of your Chef validation key (validator.pem) on your
# laptop - this value is used to upload the file to S3
variable "validation_key_location" {
  default = "~/.chef/"
}

# This is the Chef validator client name
variable "validation_client_name" {
  default = "example-validator"
}

# This variable specifies a Chef role for the EC2 instance - the
# unattended_bootstrap role needs to be created on your Chef Server and should
# be configured with the desired Run List
variable "run_list" {
  default = "role[unattended_bootstrap]"
}
