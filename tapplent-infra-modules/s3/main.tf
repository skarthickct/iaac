resource "aws_s3_bucket" "s3_bucket_1" {
  bucket = var.bucket_name              # bucket name for Loki logs

}
