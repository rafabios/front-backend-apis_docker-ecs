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

