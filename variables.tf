variable "domain_name" {
  description = "Nome do domínio principal (ex: exemplo.com.br)"
  type        = string
}

variable "environment" {
  description = "Ambiente de deploy (dev/prod)"
  type        = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "O ambiente deve ser 'dev' ou 'prod'."
  }
}

variable "region" {
  description = "Região principal da AWS"
  type        = string
  default     = "sa-east-1"
}

variable "tags" {
  description = "Mapa de tags para recursos AWS"
  type        = map(string)
  default     = {}
}

variable "cloudfront_price_class" {
  description = "Classe de preço do CloudFront"
  type        = string
  default     = "PriceClass_100"
  validation {
    condition     = contains(["PriceClass_100", "PriceClass_200", "PriceClass_All"], var.cloudfront_price_class)
    error_message = "Classe de preço inválida. Deve ser PriceClass_100, PriceClass_200 ou PriceClass_All."
  }
}
