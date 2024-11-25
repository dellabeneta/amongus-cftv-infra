# Pré-requisitos do Projeto

Este documento detalha todos os pré-requisitos necessários para executar o projeto.

## Ferramentas Locais

- [Terraform](https://developer.hashicorp.com/terraform/downloads) v1.0.0 ou superior
- [AWS CLI](https://aws.amazon.com/cli/) v2.0.0 ou superior
- Git instalado

## Conta AWS

1. **Usuário IAM com as seguintes permissões**:
   - Acesso programático (Access Key + Secret Key)
   - Políticas recomendadas (princípio do menor privilégio):
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Action": [
             "s3:CreateBucket",
             "s3:PutBucketPolicy",
             "s3:GetBucketPolicy",
             "s3:PutBucketWebsite",
             "s3:PutObject",
             "s3:GetObject",
             "s3:DeleteObject"
           ],
           "Resource": [
             "arn:aws:s3:::seu-bucket-*",
             "arn:aws:s3:::seu-bucket-*/*"
           ]
         },
         {
           "Effect": "Allow",
           "Action": [
             "cloudfront:CreateDistribution",
             "cloudfront:UpdateDistribution",
             "cloudfront:GetDistribution",
             "cloudfront:DeleteDistribution",
             "cloudfront:CreateInvalidation"
           ],
           "Resource": "*"
         },
         {
           "Effect": "Allow",
           "Action": [
             "route53:GetHostedZone",
             "route53:ChangeResourceRecordSets",
             "route53:ListResourceRecordSets"
           ],
           "Resource": "arn:aws:route53:::hostedzone/*"
         },
         {
           "Effect": "Allow",
           "Action": [
             "acm:RequestCertificate",
             "acm:DescribeCertificate",
             "acm:ListCertificates",
             "acm:DeleteCertificate"
           ],
           "Resource": "*"
         }
       ]
     }
     ```

2. **Domínio no Route53**:
   - Zona hospedada configurada no Route53
   - Servidores DNS propagados
   - Para verificar a zona hospedada:
     ```bash
     aws route53 list-hosted-zones
     ```

3. **Certificado SSL/TLS no ACM**:
   - Deve ser solicitado na região `us-east-1` (requisito do CloudFront, pois o CloudFront é um serviço global)
   - Pode ser validado via DNS (recomendado) ou email
   - Deve cobrir o domínio principal e subdomínios (exemplo: *.seudominio.com)

   ```bash
   # Solicitar o certificado (substitua example.com pelo seu domínio)
   aws acm request-certificate \
     --domain-name example.com \
     --validation-method DNS \
     --subject-alternative-names "*.example.com" \
     --region us-east-1

   # O comando retornará um ARN do certificado no formato:
   # arn:aws:acm:us-east-1:123456789012:certificate/12345678-1234-1234-1234-123456789012
   
   # Para verificar o status e obter os registros DNS para validação:
   aws acm describe-certificate \
     --certificate-arn SEU_CERTIFICATE_ARN \
     --region us-east-1

   # Se você estiver usando Route53, pode criar o registro de validação automaticamente:
   aws acm wait certificate-validated \
     --certificate-arn SEU_CERTIFICATE_ARN \
     --region us-east-1
   ```

4. **Recursos para Backend do Terraform** (na região `us-east-1`):

   a. **Bucket S3 para estado**:
   ```bash
   # Criar bucket para o backend (substitua NOME_BUCKET pelo nome desejado)
   aws s3 mb s3://NOME_BUCKET --region us-east-1

   # Habilitar versionamento no bucket
   aws s3api put-bucket-versioning \
     --bucket NOME_BUCKET \
     --versioning-configuration Status=Enabled
   
   # Habilitar criptografia por padrão
   aws s3api put-bucket-encryption \
     --bucket NOME_BUCKET \
     --server-side-encryption-configuration '{
       "Rules": [
         {
           "ApplyServerSideEncryptionByDefault": {
             "SSEAlgorithm": "AES256"
           }
         }
       ]
     }'
   ```

   b. **Tabela DynamoDB para lock**:
   ```bash
   # Criar tabela para lock state
   aws dynamodb create-table \
     --table-name terraform-state-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
     --region us-east-1
   ```

## GitHub

1. **Secrets do GitHub Actions**:
   - `AWS_ACCESS_KEY_ID`: Access Key do usuário IAM
   - `AWS_SECRET_ACCESS_KEY`: Secret Key do usuário IAM
   
   Para adicionar os secrets:
   1. Vá para Settings > Secrets and variables > Actions
   2. Clique em "New repository secret"
   3. Adicione cada secret com seu respectivo valor

## Variáveis do Projeto

Copie o arquivo `terraform.tfvars.example` para `terraform.tfvars` e configure as seguintes variáveis:

```hcl
domain_name         = "seudominio.com"
environment         = "prod"
backend_bucket_name = "seu-bucket-de-backend"
```

## Verificação

Use esta checklist para garantir que todos os pré-requisitos foram atendidos:

• Terraform instalado (`terraform -version`)
• AWS CLI instalado e configurado (`aws configure list`)
• Domínio registrado no Route53 (`aws route53 list-hosted-zones`)
• Certificado SSL/TLS solicitado e validado no ACM (`aws acm list-certificates --region us-east-1`)
• Bucket S3 para backend criado (`aws s3 ls s3://seu-bucket-de-backend`)
• Tabela DynamoDB para lock criada (`aws dynamodb describe-table --table-name terraform-state-lock --region us-east-1`)
• Secrets configurados no GitHub (verificar em Settings > Secrets)
• Arquivo terraform.tfvars configurado
