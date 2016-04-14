output "s3_bucket" {
  value = "${aws_s3_bucket.chefboot.bucket}"
}

output "iam_instance_profile" {
  value = "${aws_iam_instance_profile.chefboot.name}"
}
