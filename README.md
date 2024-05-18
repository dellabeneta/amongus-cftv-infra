<img src="https://drive.google.com/uc?export=view&id=1NdAMje_y8jW29H5DWmX6t8gV1Q-AFOci" width="1000">

# Website S3 e CloudFront com Terraform

Este projeto Terraform implanta um site estático na AWS usando o S3 para armazenamento e o CloudFront para entrega de conteúdo. O site estático é, na verdade, um pequeno jogo do AmongUs criado pelo pessoal da https://codigofonte.tv/, todos os créditos dessa aplicação pertencem aos mesmos. O Terraform foi todo criado por mim.

## Arquitetura básica:

<img src="https://drive.google.com/uc?export=view&id=15p6Jj3Zg0dE5TpLkvwwoFoUUKF8i4Dcy" width="1000">

---

Utilizei módulos apenas para a etapa de upload dos aquivos da aplicação. Foi a única forma que encontrei dos mesmos não "quebrarem" o site após o provisionamento feito pelo Terraform.

Vamos detalhar os motivos pelos quais as tecnologias mencionadas são vantajosas para a hospedagem de páginas estáticas e a infraestrutura como código (IaC):

### Terraform

**Infraestrutura como Código (IaC)**
- **Automação e Consistência**: Terraform permite a criação e gerenciamento de infraestrutura de forma automatizada e repetível. Isso reduz erros manuais e garante que o ambiente esteja sempre em um estado conhecido.
- **Versionamento e Colaboração**: Com Terraform, é possível versionar a infraestrutura da mesma forma que se versiona o código, facilitando a colaboração entre equipes e o rastreamento de mudanças.
- **Portabilidade**: Terraform é compatível com múltiplos provedores de nuvem e serviços, permitindo a portabilidade da infraestrutura entre diferentes ambientes (AWS, GCP, Azure, etc.).

### S3 (Amazon Simple Storage Service)

**Hospedagem de Páginas Estáticas**
- **Praticidade**: S3 permite a hospedagem de sites estáticos de forma extremamente simples e rápida. Basta fazer o upload dos arquivos HTML, CSS, JavaScript e quaisquer outros assets.
- **Custo Efetivo**: O custo de armazenar e servir arquivos estáticos no S3 é muito baixo. Em muitos casos, para sites de pequeno porte ou com pouco tráfego, os custos podem ser próximos de zero devido à camada gratuita da AWS.
- **Escalabilidade e Durabilidade**: S3 oferece escalabilidade automática, suportando picos de tráfego sem necessidade de intervenção manual, além de garantir durabilidade e disponibilidade dos dados.

### CloudFront

**Content Delivery Network (CDN)**
- **Desempenho e Latência**: CloudFront distribui o conteúdo através de uma rede global de pontos de presença (PoPs), reduzindo a latência e melhorando o tempo de carregamento para os usuários, independentemente de onde eles estejam no mundo.
- **Certificados SSL/TLS**: CloudFront permite a configuração de HTTPS com certificados SSL/TLS, aumentando a segurança da aplicação sem custo adicional para os certificados padrão.
- **Custo Efetivo**: Para muitos casos de uso, especialmente para sites de baixo a médio tráfego, os custos associados ao CloudFront podem ser bastante baixos, especialmente considerando os benefícios em termos de desempenho e segurança.

### Melhorias
- **Workflow para deploy**: Criar uma pipeline para atualizar e deployar, na AWS/S3, mudanças feitas no código fonte da aplicação.

### Conclusão

Combinar Terraform, S3 e CloudFront proporciona uma infraestrutura robusta, escalável e de baixo custo para a hospedagem de páginas estáticas. Terraform facilita a gestão e automação da infraestrutura, enquanto S3 oferece um meio prático e econômico para armazenar e servir conteúdo estático. CloudFront, por sua vez, melhora o desempenho e a segurança do site com custos adicionais mínimos, tornando este trio uma escolha excelente para muitos projetos de hospedagem na nuvem.
