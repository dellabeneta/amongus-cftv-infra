# Website S3 e CloudFront com Terraform

Este projeto Terraform implanta um site estático na AWS usando o S3 para armazenamento e o CloudFront para entrega de conteúdo. O site estático é, na verdade, um pequeno jogo do AmongUs criado pelo pessoal da https://codigofonte.tv/, todos os créditos dessa aplicação pertencem aos mesmos.

## Pré-requisitos

### 1. Ferramentas Necessárias
- AWS CLI configurado com as credenciais apropriadas
- Terraform instalado (versão >= 1.0)

### 2. Recursos AWS Manuais (Bootstrap)

Antes de executar o Terraform, é necessário criar manualmente alguns recursos fundamentais. Estes recursos são críticos e têm um ciclo de vida independente do projeto.

#### 2.1 Backend do Terraform (S3 + DynamoDB)

```bash
# 1. Criar bucket S3 para estados do Terraform
aws s3api create-bucket \
    --bucket terraformstates.<seu_dominio> \
    --region sa-east-1 \
    --create-bucket-configuration LocationConstraint=sa-east-1

# 2. Habilitar versionamento no bucket
aws s3api put-bucket-versioning \
    --bucket terraformstates.<seu_dominio> \
    --versioning-configuration Status=Enabled

# 3. Habilitar criptografia no bucket
aws s3api put-bucket-encryption \
    --bucket terraformstates.<seu_dominio> \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# 4. Criar tabela DynamoDB para locking
aws dynamodb create-table \
    --table-name terraformstates-lock \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region sa-east-1
```

#### 2.2 Certificado SSL/TLS (ACM)

```bash
# 1. Solicitar o certificado wildcard
aws acm request-certificate \
    --domain-name "*.<seu_dominio>" \
    --validation-method DNS \
    --region us-east-1  # Obrigatório para uso com CloudFront

# 2. Obter informações de validação DNS
aws acm describe-certificate \
    --certificate-arn <ARN_DO_CERTIFICADO> \
    --region us-east-1

# 3. Criar registro CNAME para validação
aws route53 list-hosted-zones-by-name \
    --dns-name <seu_dominio>

aws route53 change-resource-record-sets \
    --hosted-zone-id <HOSTED_ZONE_ID> \
    --change-batch file://route53-changes.json

# 4. Verificar status da validação
aws acm describe-certificate \
    --certificate-arn <ARN_DO_CERTIFICADO> \
    --region us-east-1
```

> **Nota**: O certificado SSL deve estar na região us-east-1 para ser usado com CloudFront.

### 3. Permissões AWS Necessárias
Para executar este projeto, sua conta AWS precisa ter permissões para:
- S3 (criar/modificar buckets e políticas)
- CloudFront (criar/modificar distribuições)
- Route53 (modificar registros DNS)
- ACM (ler certificados)

## Arquitetura

### Diagrama de Recursos Terraform
![Terraform Resources Graph](terraform-graph.png)

O diagrama acima mostra as dependências entre os recursos do Terraform:
- O S3 bucket (`aws_s3_bucket.bucket`) é o recurso base
- Configurações do bucket (policy, website, access block) dependem do bucket principal
- CloudFront distribution depende do certificado ACM e do bucket S3
- Route53 record depende do CloudFront e da zona DNS

## Como Usar

1. Clone este repositório
2. Certifique-se de que todos os pré-requisitos foram atendidos
3. Atualize as variáveis no arquivo `terraform.tfvars` com seu domínio
4. Inicialize o Terraform:
   ```bash
   terraform init
   ```
5. Revise as mudanças planejadas:
   ```bash
   terraform plan
   ```
6. Aplique as mudanças:
   ```bash
   terraform apply
   ```

## Estrutura do Backend

O projeto utiliza um backend remoto na AWS com as seguintes características:

### S3 Bucket
- **Nome**: `terraformstates.<seu_dominio>`
- **Região**: sa-east-1
- **Versionamento**: Habilitado
- **Criptografia**: AES-256

### DynamoDB
- **Nome da Tabela**: `terraformstates-lock`
- **Região**: sa-east-1
- **Chave Primária**: LockID (String)
- **Capacidade**: 5 unidades de leitura/escrita

## Componentes da Infraestrutura

### Bucket S3
- **Finalidade**: Hospedagem do site estático
- **Acesso**: Público (somente leitura)
- **Website**: Habilitado
- **Versionamento**: Desabilitado

### CloudFront
- **Origem**: Bucket S3
- **Comportamento**: 
  - Cache otimizado para conteúdo estático
  - HTTPS obrigatório
  - TLSv1.2_2021

### Route53
- **Registros**: Alias para CloudFront
- **Subdomínio**: `amongus.<seu_dominio>`

### ACM (Certificate Manager)
- **Tipo**: Wildcard (`*.<seu_dominio>`)
- **Região**: us-east-1 (requisito CloudFront)
- **Validação**: DNS

## Características Técnicas

**Segurança**
- HTTPS obrigatório
- Bucket S3 acessível apenas via CloudFront
- TLS 1.2 ou superior

**Content Delivery Network (CDN)**
- **Desempenho e Latência**: Distribuição global através de PoPs
- **Certificados SSL/TLS**: HTTPS com certificados gerenciados
- **Cache**: Melhor performance com caching na edge

## Melhorias Planejadas

- [ ] **Github Actions**: Pipeline para deploy automático de mudanças no código fonte
- [ ] **.tfvars**: Parametrização de variáveis específicas do projeto
- [ ] **Monitoramento**: Adicionar CloudWatch Alarms

## Variáveis do Projeto

### Variáveis Obrigatórias
- `domain_name`: Seu domínio principal (ex: exemplo.com.br)
- `environment`: Ambiente de deploy (dev/prod)
- `region`: Região principal da AWS (default: sa-east-1)

### Variáveis Opcionais
- `tags`: Mapa de tags para recursos AWS
- `cloudfront_price_class`: Classe de preço do CloudFront (default: PriceClass_100)

## Deploy do Site

### 1. Preparação dos Arquivos
1. Clone o repositório do jogo
2. Build os arquivos estáticos
3. Copie os arquivos para uma pasta local

### 2. Upload para S3
Após a infraestrutura estar pronta:
```bash
# Sincronizar arquivos com o bucket S3
aws s3 sync ./dist s3://amongus.<seu_dominio> --delete

# Invalidar cache do CloudFront (se necessário)
aws cloudfront create-invalidation --distribution-id <DISTRIBUTION_ID> --paths "/*"
```

## Troubleshooting

### Problemas Comuns

1. **Erro de Certificado SSL**
   - Verifique se o certificado está na região us-east-1
   - Confirme se a validação DNS está completa

2. **Acesso Negado ao S3**
   - Verifique a política do bucket
   - Confirme se o CloudFront está usando o OAI correto

3. **CloudFront 403**
   - Verifique se o index.html existe no bucket
   - Confirme as configurações de default root object

## Custos Estimados

Os custos mensais aproximados (região sa-east-1):

1. **S3**
   - Armazenamento: ~$0.025 por GB/mês
   - Requisições: Variável por uso

2. **CloudFront**
   - Transferência: $0.085 por GB (primeiros 10TB)
   - Requisições: $0.0075 por 10,000 HTTPS

3. **Route53**
   - Zona hospedada: $0.50/mês
   - Consultas: $0.40 por milhão

> Nota: Valores aproximados, consulte a calculadora AWS para estimativas precisas.

## Contribuindo

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Padrões de Código
- Siga as [convenções de nomenclatura do Terraform](https://www.terraform-best-practices.com/naming)
- Documente todas as variáveis
- Mantenha o graph.dot atualizado
- Atualize o diagrama quando necessário

## Pipeline CI/CD (Planejado)

### GitHub Actions

```yaml
name: Terraform CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  terraform:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1

      - name: Terraform Format
        run: terraform fmt -check

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate

      - name: Terraform Plan
        run: terraform plan

      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

> Nota: Pipeline ainda não implementado. PRs são bem-vindos!
