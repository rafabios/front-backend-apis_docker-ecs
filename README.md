
# Projeto de Deploy com AWS ECS, Docker e Fargate

Este guia detalha como construir, empacotar e implantar um sistema composto por um **Frontend em Angular**, um **Backend em Flask**, e uma **API de Relatórios em Flask** utilizando **Docker** e **AWS ECS (Elastic Container Service)** com **Fargate**. Além disso, integraremos um banco de dados **PostgreSQL** hospedado no **AWS RDS**.

## Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Estrutura do Projeto](#estrutura-do-projeto)
3. [Construção das Imagens Docker](#construção-das-imagens-docker)
4. [Configuração do AWS ECR](#configuração-do-aws-ecr)
5. [Push das Imagens para o ECR](#push-das-imagens-para-o-ecr)
6. [Configuração do AWS ECS com Fargate](#configuração-do-aws-ecs-com-fargate)
    - [6.1. Criar Cluster no ECS](#61-criar-cluster-no-ecs)
    - [6.2. Definir Task Definitions](#62-definir-task-definitions)
    - [6.3. Criar Serviços no ECS](#63-criar-serviços-no-ecs)
    - [6.4. Configurar Load Balancer (Opcional)](#64-configurar-load-balancer-opcional)
7. [Configuração do Banco de Dados AWS RDS PostgreSQL](#configuração-do-banco-de-dados-aws-rds-postgresql)
8. [Configuração de Variáveis de Ambiente](#configuração-de-variáveis-de-ambiente)
9. [Monitoramento e Logs](#monitoramento-e-logs)
10. [Considerações Finais](#considerações-finais)

---

## Pré-requisitos

Antes de começar, assegure-se de ter os seguintes pré-requisitos:

- **Conta AWS** com permissões adequadas para ECS, ECR, RDS, IAM, e outros serviços necessários.
- **AWS CLI** instalada e configurada.
- **Docker** instalado.
- **Node.js** e **npm** instalados (para o frontend Angular).
- **Python 3.9** e **pip** instalados (para o backend e API).
- Conhecimento básico em Docker, AWS e serviços relacionados.

## Estrutura do Projeto

Organize seu projeto da seguinte maneira:

```
project-root/
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   ├── package-lock.json
│   └── ... (código do Angular)
├── backend/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py
├── api-reports/
│   ├── Dockerfile
│   ├── requirements.txt
│   └── app.py
└── docker-compose.yml (opcional para desenvolvimento local)
```

## Construção das Imagens Docker

### 1. Frontend (Angular)

**Dockerfile:**

```dockerfile
# Usar uma imagem do Node.js como base para build
FROM node:16 as build

# Criar diretório de trabalho
WORKDIR /app

# Copiar arquivos do projeto
COPY package.json package-lock.json ./

# Instalar dependências
RUN npm install

# Copiar o restante do código
COPY . .

# Buildar a aplicação Angular
RUN npm run build --prod

# Utilizar uma imagem NGINX para servir o frontend
FROM nginx:alpine

# Copiar a build do Angular para o NGINX
COPY --from=build /app/dist/your-angular-app /usr/share/nginx/html

# Expor a porta 80
EXPOSE 80

# Iniciar o NGINX
CMD ["nginx", "-g", "daemon off;"]
```

### 2. Backend (Python Flask)

**Dockerfile:**

```dockerfile
# Usar imagem do Python como base
FROM python:3.9-slim

# Criar diretório de trabalho
WORKDIR /app

# Instalar dependências
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o código do backend
COPY . .

# Expor a porta 5000
EXPOSE 5000

# Definir variável de ambiente para o Flask
ENV FLASK_APP=app.py

# Iniciar o servidor Flask
CMD ["flask", "run", "--host=0.0.0.0"]
```

**Exemplo de `app.py`:**

```python
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/healthcheck')
def healthcheck():
    return jsonify({"status": "healthy"})

@app.route('/backend-call')
def backend_call():
    return jsonify({"message": "Chamada do backend ao API de relatórios"})

if __name__ == "__main__":
        app.run(debug=True)
```

**requirements.txt:**

```
Flask==2.0.3
```

### 3. API de Relatórios (Python Flask)

**Dockerfile:**

```dockerfile
# Usar imagem do Python como base
FROM python:3.9-slim

# Criar diretório de trabalho
WORKDIR /app

# Instalar dependências
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copiar o código da API de relatórios
COPY . .

# Expor a porta 5001
EXPOSE 5001

# Definir variável de ambiente para o Flask
ENV FLASK_APP=app.py

# Iniciar o servidor Flask
CMD ["flask", "run", "--host=0.0.0.0", "--port=5001"]
```

**Exemplo de `app.py`:**

```python
import os
import psycopg2
from flask import Flask, jsonify

app = Flask(__name__)

@app.route('/healthcheck')
def healthcheck():
    return jsonify({"status": "API healthy"})

@app.route('/db-check')
def db_check():
    try:
        conn = psycopg2.connect(
            dbname=os.getenv('POSTGRES_DB'),
            user=os.getenv('POSTGRES_USER'),
            password=os.getenv('POSTGRES_PASSWORD'),
            host=os.getenv('POSTGRES_HOST')
        )
        conn.close()
        return jsonify({"status": "Connected to the database"})
    except Exception as e:
        return jsonify({"status": "Failed to connect to the database", "error": str(e)})

if __name__ == "__main__":
    app.run(debug=True, port=5001)
```

**requirements.txt:**

```
Flask==2.0.3
psycopg2-binary==2.9.3
```

## Configuração do AWS ECR

O **AWS Elastic Container Registry (ECR)** é um serviço de registro de contêineres gerenciado. Precisamos criar repositórios para armazenar as imagens Docker do frontend, backend e API de relatórios.

### Passos:

1. **Autenticar no AWS CLI:**

   ```bash
   aws configure
   ```

   Insira suas credenciais AWS, região e formato de saída preferido.

2. **Criar Repositórios no ECR:**

   ```bash
   aws ecr create-repository --repository-name frontend
   aws ecr create-repository --repository-name backend
   aws ecr create-repository --repository-name api-reports
   ```

   Isso criará três repositórios no ECR para armazenar as imagens Docker.

## Push das Imagens para o ECR

### 1. Fazer Login no ECR

Recupere o comando de login do ECR e execute-o:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

Substitua `<account-id>` pela ID da sua conta AWS e ajuste a região conforme necessário.

### 2. Construir, Taggear e Fazer Push das Imagens

#### Frontend (Angular)

```bash
# Navegue para o diretório frontend
cd frontend

# Buildar a imagem
docker build -t frontend .

# Taggear a imagem para o ECR
docker tag frontend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/frontend:latest

# Push para o ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/frontend:latest
```

#### Backend (Flask)

```bash
# Navegue para o diretório backend
cd ../backend

# Buildar a imagem
docker build -t backend .

# Taggear a imagem para o ECR
docker tag backend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/backend:latest

# Push para o ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/backend:latest
```

#### API de Relatórios (Flask)

```bash
# Navegue para o diretório api-reports
cd ../api-reports

# Buildar a imagem
docker build -t api-reports .

# Taggear a imagem para o ECR
docker tag api-reports:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/api-reports:latest

# Push para o ECR
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/api-reports:latest
```

## Configuração do AWS ECS com Fargate

### 6.1. Criar Cluster no ECS

1. **Acesse o Console AWS ECS:**

   Navegue para o console do ECS [aqui](https://console.aws.amazon.com/ecs/home).

2. **Criar Cluster:**

   - Clique em **Clusters** no menu lateral.
   - Clique em **Create Cluster**.
   - Selecione **Networking only** (para Fargate).
   - Clique em **Next step**.
   - Defina um nome para o cluster, por exemplo, `my-cluster`.
   - Clique em **Create**.

### 6.2. Definir Task Definitions

As **Task Definitions** definem como os containers devem ser executados.

#### Frontend Task Definition

1. **Criar uma Task Definition:**

   - No console do ECS, vá para **Task Definitions**.
   - Clique em **Create new Task Definition**.
   - Selecione **Fargate** e clique em **Next step**.
   - Nome da Task Definition: `frontend-task`.
   - Role: Selecione ou crie uma IAM role adequada.
   - Clique em **Add container**.

2. **Configurar o Container:**

   - **Container name:** `frontend`
   - **Image:** `<account-id>.dkr.ecr.us-east-1.amazonaws.com/frontend:latest`
   - **Memory Limits:** Por exemplo, `512` MiB.
   - **Port Mappings:** Host port `80`, Container port `80`.
   - Clique em **Add**.

3. **Configurações de Rede:**

   - Clique em **Create**.

Repita o processo para **backend** e **api-reports**.

#### Backend Task Definition

1. **Criar uma Task Definition:**

   - Nome: `backend-task`.
   - Role: Adequada para acessar outros serviços se necessário.

2. **Configurar o Container:**

   - **Container name:** `backend`
   - **Image:** `<account-id>.dkr.ecr.us-east-1.amazonaws.com/backend:latest`
   - **Memory Limits:** `512` MiB.
   - **Port Mappings:** Host port `5000`, Container port `5000`.
   - **Environment Variables:**
     - `API_REPORTS_URL=http://api-reports:5001`
   - Clique em **Add**.

3. **Clique em Create**.

#### API de Relatórios Task Definition

1. **Criar uma Task Definition:**

   - Nome: `api-reports-task`.
   - Role: Adequada para acessar o RDS.

2. **Configurar o Container:**

   - **Container name:** `api-reports`
   - **Image:** `<account-id>.dkr.ecr.us-east-1.amazonaws.com/api-reports:latest`
   - **Memory Limits:** `512` MiB.
   - **Port Mappings:** Host port `5001`, Container port `5001`.
   - **Environment Variables:**
     - `POSTGRES_HOST=<rds-endpoint>`
     - `POSTGRES_DB=<dbname>`
     - `POSTGRES_USER=<dbuser>`
     - `POSTGRES_PASSWORD=<dbpassword>`
   - Clique em **Add**.

3. **Clique em Create**.

### 6.3. Criar Serviços no ECS

Para cada Task Definition, crie um serviço que mantenha os containers em execução.

#### Serviço Frontend

1. **No Cluster criado, clique em **Services** e depois em **Create**.
2. **Configurações:**
   - **Launch type:** Fargate.
   - **Task Definition:** `frontend-task`.
   - **Service name:** `frontend-service`.
   - **Number of tasks:** `1`.
3. **Configurar VPC e Sub-redes:**
   - Selecione a VPC adequada.
   - Selecione sub-redes públicas.
   - **Assign Public IP:** ENABLED.
4. **Configurar Load Balancer (Opcional):**
   - Pode-se configurar um ALB para gerenciar o tráfego.
5. **Clique em **Next step**, revise e **Create Service**.

Repita o processo para **backend** e **api-reports**.

#### Serviço Backend

- **Service name:** `backend-service`.
- **Task Definition:** `backend-task`.
- **Port:** `5000`.

#### Serviço API de Relatórios

- **Service name:** `api-reports-service`.
- **Task Definition:** `api-reports-task`.
- **Port:** `5001`.

### 6.4. Configurar Load Balancer (Opcional)

Se desejar balancear o tráfego para o frontend, backend ou API, configure um **Application Load Balancer (ALB)**.

1. **Criar um ALB:**

   - No console do EC2, vá para **Load Balancers**.
   - Clique em **Create Load Balancer**.
   - Selecione **Application Load Balancer**.
   - Defina nome, esquema (Internet-facing), e listeners (por exemplo, HTTP na porta 80).
   - Selecione as sub-redes e grupos de segurança apropriados.
   - Clique em **Create**.

2. **Configurar Listeners e Regras:**

   - Configure regras para rotear tráfego para os serviços backend e frontend conforme necessário.

3. **Associar Serviços ao ALB:**

   - Ao criar os serviços no ECS, associe-os ao ALB configurado.

## Configuração do Banco de Dados AWS RDS PostgreSQL

### Passos:

1. **Criar uma Instância RDS PostgreSQL:**

   - No console AWS, vá para **RDS**.
   - Clique em **Create database**.
   - Selecione **PostgreSQL**.
   - Escolha a versão desejada.
   - Configure as especificações da instância.
   - Defina as credenciais de administrador.
   - Escolha a VPC e sub-redes apropriadas.
   - Configure o **Security Group** para permitir conexões da VPC onde o ECS está executando.
   - Clique em **Create database**.

2. **Obter Endpoint do RDS:**

   - Após a criação, no console do RDS, selecione a instância e copie o **endpoint**.

## Configuração de Variáveis de Ambiente

As variáveis de ambiente são essenciais para conectar os serviços entre si e com o banco de dados.

### Passos:

1. **No ECS, edite as Task Definitions** para incluir as variáveis de ambiente necessárias.

2. **Frontend:**

   - Se necessário, defina variáveis como a URL do backend.

3. **Backend:**

   - `API_REPORTS_URL=http://api-reports:5001`

4. **API de Relatórios:**

   - `POSTGRES_HOST=<rds-endpoint>`
   - `POSTGRES_DB=<dbname>`
   - `POSTGRES_USER=<dbuser>`
   - `POSTGRES_PASSWORD=<dbpassword>`

   > **Segurança:** Para evitar expor senhas diretamente, considere usar o **AWS Secrets Manager** ou **AWS Systems Manager Parameter Store** para armazenar e acessar credenciais de forma segura.

## Monitoramento e Logs

Utilize o **AWS CloudWatch** para monitorar logs e métricas dos seus serviços.

### Passos:

1. **Configurar Logs nas Task Definitions:**

   - Ao definir os containers nas Task Definitions, configure a integração com o CloudWatch Logs.
   - Especifique um grupo de logs e prefixo para cada serviço.

2. **Acessar Logs no CloudWatch:**

   - No console do CloudWatch, vá para **Logs**.
   - Encontre os grupos de logs correspondentes aos seus serviços.
   - Monitore logs em tempo real para depuração e monitoramento.

3. **Configurar Alarmes:**

   - Configure alarmes para métricas críticas, como uso de CPU, memória ou falhas nas aplicações.

## Considerações Finais

- **IAM Roles:** Assegure-se de que as Task Definitions tenham as permissões IAM necessárias para acessar outros serviços AWS, como ECR, S3, Secrets Manager, etc.

- **Segurança:** 
  - Use **Security Groups** para controlar o tráfego entre os serviços e o RDS.
  - Considere implementar **HTTPS** para comunicação segura com o frontend usando certificados no ALB.

- **Escalabilidade:** Configure políticas de escalonamento automático no ECS para ajustar a quantidade de tarefas com base na demanda.

- **CI/CD:** Integre ferramentas de CI/CD, como **AWS CodePipeline** ou **GitHub Actions**, para automatizar a construção, teste e implantação das imagens Docker.

- **Backup e Recuperação:** Implemente estratégias de backup para o RDS e outras partes críticas do sistema.

Seguindo este guia, você conseguirá implantar e gerenciar seu sistema no **AWS ECS com Fargate**, aproveitando a escalabilidade, resiliência e gestão simplificada de containers oferecidas pela AWS.

---

**Referências:**

- [Documentação do AWS ECS](https://docs.aws.amazon.com/ecs/)
- [Documentação do AWS ECR](https://docs.aws.amazon.com/ecr/)
- [Documentação do AWS RDS](https://docs.aws.amazon.com/rds/)
- [Docker Documentation](https://docs.docker.com/)
- [Flask Documentation](https://flask.palletsprojects.com/)

