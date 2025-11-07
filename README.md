# n8n & Evolution API Self-Hosting on AWS

Este projeto fornece uma infraestrutura totalmente automatizada para auto-hospedagem do n8n e da Evolution API na AWS usando Terraform. Ele foi projetado para segurança e facilidade de implantação, com geração automatizada de chaves sensíveis.

## ✨ Principais Funcionalidades

-   **Implantação Automatizada**: Provisiona toda a infraestrutura, desde a rede até a instância da aplicação, com alguns comandos do Terraform.
-   **Seguro por Padrão**: Gera automaticamente chaves de segurança (`AUTHENTICATION_API_KEY` e `N8N_ENCRYPTION_KEY`) únicas e aleatórias para cada implantação.
-   **Gerenciamento de Estado Remoto**: Utiliza um bucket S3 para o estado remoto do Terraform, permitindo a colaboração em equipe e o bloqueio de estado.
-   **Custo-Benefício**: Utiliza uma instância EC2 `t4g.small` da AWS, que faz parte da família Graviton, oferecendo um bom equilíbrio entre desempenho e custo.
-   **DNS Gerenciado**: Cria automaticamente registros no Route 53 para apontar seus domínios personalizados para a aplicação.

## 🏗️ Arquitetura

A infraestrutura é dividida em duas stacks principais do Terraform:

1.  **`00-remote-state-backend-stack`**: Cria um bucket S3 versionado para armazenar o estado do Terraform (`.tfstate`) remotamente. Esta é a base para um fluxo de trabalho seguro e colaborativo.
2.  **`01-n8n-stack`**: Provisiona todos os recursos necessários da aplicação, incluindo:
    *   **Rede**: Uma VPC personalizada, sub-redes públicas/privadas, um Internet Gateway e tabelas de rotas para criar um ambiente de rede isolado e seguro.
    *   **Instância EC2**: Uma instância `t4g.small` que executa um script de bootstrap (`user_data.sh`) na inicialização para instalar o Docker e iniciar os contêineres do n8n e da Evolution API.
    *   **IP Elástico**: Um endereço IP público estático para a instância, garantindo que os registros de DNS sempre apontem para o local correto.
    *   **Segurança**: Um Security Group para controlar o tráfego (permitindo tráfego HTTP, HTTPS e webhooks do n8n) e uma IAM Role para gerenciamento seguro via AWS Systems Manager (SSM).
    *   **DNS**: Registros "A" no Route 53 para os subdomínios escolhidos, apontando para o IP Elástico.
    *   **Chaves de Segurança**: Utiliza o provedor `random` no Terraform para gerar uma chave de API e uma chave de criptografia fortes e aleatórias, que são passadas de forma segura para a instância EC2 durante sua criação.

## 📋 Pré-requisitos

-   [Terraform](https://www.terraform.io/downloads.html) instalado.
-   AWS CLI instalado e configurado com suas credenciais.
-   Um nome de domínio registrado em uma Zona Hospedada do AWS Route 53.

## 🚀 Passos para Implantação

1.  **Clone o Repositório**
    ```bash
    git clone https://github.com/alisrios/n8n-self-hosting-evolution.git
    cd n8n-self-hosting-evolution
    ```

2.  **Configure Suas Variáveis**
    Navegue até o diretório `01-n8n-stack` e crie um arquivo `terraform.tfvars`. Você pode copiar o arquivo de exemplo:
    ```bash
    cd 01-n8n-stack
    cp terraform.tfvars.example terraform.tfvars
    ```
    Agora, edite o `terraform.tfvars` e defina os valores necessários, especialmente o seu `domain_name` e os `subdomain` para o n8n e a Evolution API.

3.  **Implante o Backend de Estado Remoto**
    Esta stack cria o bucket S3 para armazenar o estado do seu Terraform.
    ```bash
    cd ../00-remote-state-backend-stack
    terraform init
    terraform apply
    ```

4.  **Implante a Stack da Aplicação**
    Isso provisionará a VPC, a instância EC2 e todos os outros recursos.
    ```bash
    cd ../01-n8n-stack
    terraform init
    terraform apply
    ```
    Após a conclusão do `apply`, o Terraform exibirá os outputs.

## 🔑 Acessando Sua Chave de API

A `AUTHENTICATION_API_KEY` para a Evolution API é gerada automaticamente durante o processo de `terraform apply`. Você pode recuperá-la de duas maneiras:

1.  **Output do Terraform**: Após uma implantação bem-sucedida, a chave será mostrada como um output. Você pode visualizá-la novamente a qualquer momento executando:
    ```bash
    terraform output authentication_api_key
    ```

2.  **Na Instância EC2**: A chave também é salva em um arquivo na instância para sua conveniência. Você pode acessá-la conectando-se à instância (por exemplo, via SSM) e visualizando o arquivo:
    ```bash
    cat /home/ec2-user/n8n/.evolution_api
    ```

## 💣 Destruindo a Infraestrutura

Para evitar cobranças contínuas, você pode destruir todos os recursos criados. Execute o comando `destroy` na ordem inversa da criação:

1.  **Destrua a Stack da Aplicação**
    ```bash
    cd 01-n8n-stack
    terraform destroy
    ```

2.  **Destrua o Backend de Estado Remoto**
    ```bash
    cd ../00-remote-state-backend-stack
    terraform destroy
    ```
