resource "aws_s3_bucket" "bucket" {
  bucket        = "amongus.dellabeneta.online"
  force_destroy = true

  tags = {
    Name        = "AmongUs"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = "amongus.dellabeneta.online"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.bucket.arn}/*"
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.access_block]
}


resource "aws_s3_bucket_website_configuration" "website_configuration" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

module "template_files" {
  source   = "hashicorp/dir/template"
  base_dir = "src"
}

resource "aws_s3_object" "objects" {
  for_each     = module.template_files.files
  bucket       = "amongus.dellabeneta.online"
  key          = each.key
  content_type = each.value.content_type
  source       = each.value.source_path
  content      = each.value.content
  etag         = each.value.digests.md5

  depends_on = [aws_s3_bucket_website_configuration.website_configuration]
}

output "s3_bucket_properties" {
  value = {
    domain_name   = aws_s3_bucket.bucket.bucket_domain_name
    force_destroy = aws_s3_bucket.bucket.force_destroy
    id            = aws_s3_bucket.bucket.id
    //website_endpoint = aws_s3_bucket.bucket.website_endpoint
  }
}

