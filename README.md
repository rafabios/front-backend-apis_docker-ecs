# Projeto de Deploy com AWS ECS, Docker e Fargate

Este guia detalha como construir, empacotar e implantar um sistema composto por um **Frontend com Nginx**, um **Backend em Flask**, e uma **API de Relatórios em Flask** utilizando **Docker** e **AWS ECS (Elastic Container Service)** com **Fargate**. Além disso, integraremos um banco de dados **PostgreSQL** hospedado no **AWS RDS**.

## Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Estrutura do Projeto](#estrutura-do-projeto)
3. [Configuração do Frontend com Nginx](#configuração-do-frontend-com-nginx)
    - [1. Arquivos Estáticos do Frontend](#1-arquivos-estáticos-do-frontend)
    - [2. Dockerfile para Nginx](#2-dockerfile-para-nginx)
    - [3. Configuração do Nginx (`nginx.conf`)](#3-configuração-do-nginx-nginxconf)
4. [Configuração do Backend Flask](#configuração-do-backend-flask)
    - [1. Dockerfile para Backend Flask](#1-dockerfile-para-backend-flask)
    - [2. Código do `app.py`](#2-código-do-apppy)
    - [3. Arquivo `requirements.txt`](#3-arquivo-requirementstxt)
5. [Configuração da API de Relatórios Flask](#configuração-da-api-de-relatórios-flask)
    - [1. Dockerfile para API de Relatórios Flask](#1-dockerfile-para-api-de-relatórios-flask)
    - [2. Código do `app.py`](#2-código-do-apppy-1)
    - [3. Arquivo `requirements.txt`](#3-arquivo-requirementstxt-1)
6. [Docker Compose para Desenvolvimento Local](#docker-compose-para-desenvolvimento-local)
7. [Configuração do AWS ECR](#configuração-do-aws-ecr)
8. [Push das Imagens para o ECR](#push-das-imagens-para-o-ecr)
9. [Deploy no AWS ECS com Fargate](#deploy-no-aws-ecs-com-fargate)
    - [1. Criação do Cluster no ECS](#1-criação-do-cluster-no-ecs)
    - [2. Definição das Task Definitions](#2-definição-das-task-definitions)
    - [3. Criação dos Serviços no ECS](#3-criação-dos-serviços-no-ecs)
    - [4. Configuração do Load Balancer](#4-configuração-do-load-balancer)
10. [Configuração do Banco de Dados AWS RDS PostgreSQL](#configuração-do-banco-de-dados-aws-rds-postgresql)
11. [Configuração de Variáveis de Ambiente](#configuração-de-variáveis-de-ambiente)
12. [Monitoramento e Logs](#monitoramento-e-logs)
13. [Considerações Finais](#considerações-finais)

---

## Pré-requisitos

Antes de começar, assegure-se de ter os seguintes pré-requisitos:

- **Conta AWS** com permissões adequadas para ECS, ECR, RDS, IAM, e outros serviços necessários.
- **AWS CLI** instalada e configurada.
- **Docker** instalado.
- Conhecimento básico em Docker, AWS e serviços relacionados.

## Estrutura do Projeto

Organize seu projeto da seguinte maneira:

