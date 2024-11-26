```mermaid
flowchart TD
    subgraph AWS Cloud
        R53[Route53 DNS] -->|DNS Resolution| CF[CloudFront Distribution]
        CF -->|Cache and Serve Content| S3[S3 Bucket]
        ACM[ACM Certificate] -.->|SSL/TLS| CF
        
        subgraph S3 Configuration
            S3 -->|Stores| ST[Static Files]
            S3 -->|Configured with| BP[Bucket Policy]
            S3 -->|Has| WH[Website Hosting]
        end
        
        subgraph CloudFront Config
            CF -->|Uses| OAI[Origin Access Identity]
            CF -->|Has| CD[Cache Distribution]
            CF -->|Configured with| BH[Behaviors]
        end
    end
    
    U[User] -->|Access Website| R53

    style AWS Cloud fill:#ff9900,stroke:#232f3e
    style U fill:#85bbf0,stroke:#5a5a5a
    style R53 fill:#945200,stroke:#232f3e
    style CF fill:#ff9900,stroke:#232f3e
    style S3 fill:#3b48cc,stroke:#232f3e
    style ACM fill:#ff9900,stroke:#232f3e
```

# Arquitetura do Projeto Terraform S3 AmongUs

Este diagrama representa a arquitetura da infraestrutura AWS implementada através do Terraform. O fluxo de funcionamento é o seguinte:

1. O usuário acessa o website através do domínio configurado
2. O Route53 resolve o DNS para o CloudFront
3. O CloudFront serve o conteúdo do S3, utilizando cache quando possível
4. O certificado ACM garante a conexão HTTPS
5. O S3 armazena os arquivos estáticos do site

## Componentes Principais

- **Route53**: Gerenciamento de DNS
- **CloudFront**: CDN para distribuição de conteúdo
- **S3**: Armazenamento dos arquivos estáticos
- **ACM**: Gerenciamento de certificados SSL/TLS
