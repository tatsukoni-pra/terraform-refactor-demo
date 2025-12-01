resource "aws_s3_bucket" "tatsukoni_terraform_test" {
  bucket = "tatsukoni-terraform-test-s3"

  tags = {
    Name = "tatsukoni-terraform-test-s3"
  }
}
