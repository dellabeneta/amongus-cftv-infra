resource "aws_s3_bucket" "bucket" {
  bucket        = "amongus.dellabeneta.tech"
  force_destroy = true

  tags = {
    Name        = "AmongUs"
    Environment = "Production"
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
  bucket = "amongus.dellabeneta.tech"

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

# Os dois blocos abaixo perderam o sentido e foram comentados a fim de manter
# um histórico ou permitir o reaproveitamento de código para outro projeto. 
# A partir de 20.07.2024, nossa aplicação passou a ser controlada/mantida 
# apenas em seu próprio repositório git em e com um workflow de deploy diretamente
# para o s3 disprado sempre que houver um PUSH para a branch MAIN.

# module "template_files" {
#   source   = "hashicorp/dir/template"
#   base_dir = "src"
# }

# resource "aws_s3_object" "objects" {
#   for_each     = module.template_files.files
#   bucket       = "amongus.dellabeneta.tech"
#   key          = each.key
#   content_type = each.value.content_type
#   source       = each.value.source_path
#   content      = each.value.content
#   etag         = each.value.digests.md5

#   depends_on = [aws_s3_bucket_website_configuration.website_configuration]
# }