# Pré-requisitos do Projeto

Este documento detalha todos os pré-requisitos necessários para executar o projeto Among Us CFTV.

## Ferramentas Locais

- [Terraform](https://developer.hashicorp.com/terraform/downloads) instalado
- [AWS CLI](https://aws.amazon.com/cli/) instalado e configurado
- Git instalado

## Conta AWS

1. **Usuário IAM com as seguintes permissões**:
   - Acesso programático (Access Key + Secret Key)
   - Políticas necessárias:
     * S3FullAccess
     * CloudFrontFullAccess
     * Route53FullAccess
     * ACMFullAccess
     * DynamoDBFullAccess

2. **Domínio no Route53**:
   - Zona hospedada configurada no Route53
   - Servidores DNS propagados

3. **Certificado SSL/TLS no ACM**:
   - Deve ser solicitado na região `us-east-1` (requisito do CloudFront)
   - Pode ser validado via DNS (recomendado) ou email
   - Deve cobrir o domínio principal e subdomínios (exemplo: *.seudominio.com)

   ```bash
   # Solicitar o certificado (substitua example.com pelo seu domínio)
   aws acm request-certificate \
     --domain-name example.com \
     --validation-method DNS \
     --subject-alternative-names "*.example.com" \
     --region us-east-1

   # O comando acima retornará um ARN do certificado. Guarde-o para usar nos próximos comandos.
   # Para verificar o status e obter os registros DNS para validação:
   aws acm describe-certificate \
     --certificate-arn arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERTIFICATE_ID \
     --region us-east-1

   # Se você estiver usando Route53, pode criar o registro de validação automaticamente:
   aws acm wait certificate-validated \
     --certificate-arn arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERTIFICATE_ID \
     --region us-east-1
   ```

4. **Recursos para Backend do Terraform**:

   a. **Bucket S3 para estado**:
   ```bash
   # Criar bucket para o backend
   aws s3 mb s3://seu-bucket-de-backend

   # Habilitar versionamento no bucket
   aws s3api put-bucket-versioning \
     --bucket seu-bucket-de-backend \
     --versioning-configuration Status=Enabled
   ```

   b. **Tabela DynamoDB para lock**:
   ```bash
   # Criar tabela para lock state
   aws dynamodb create-table \
     --table-name terraform-state-lock \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
   ```

## GitHub

1. **Secrets do GitHub Actions**:
   - `AWS_ACCESS_KEY_ID`: Access Key do usuário IAM
   - `AWS_SECRET_ACCESS_KEY`: Secret Key do usuário IAM

## Variáveis do Projeto

Copie o arquivo `terraform.tfvars.example` para `terraform.tfvars` e configure as seguintes variáveis:

```hcl
domain_name         = "seudominio.com"
environment         = "prod"
backend_bucket_name = "seu-bucket-de-backend"
```

## Verificação

Use esta checklist para garantir que todos os pré-requisitos foram atendidos:

- Terraform instalado (`terraform -version`)
- AWS CLI instalado e configurado (`aws configure list`)
- Domínio registrado no Route53
- Certificado SSL/TLS solicitado e validado no ACM
- Bucket S3 para backend criado
- Tabela DynamoDB para lock criada
- Secrets configurados no GitHub
- Arquivo terraform.tfvars configurado
