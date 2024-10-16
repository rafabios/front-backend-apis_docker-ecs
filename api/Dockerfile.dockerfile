# Usar imagem do Python como base
FROM python:3.9-slim

# Criar diretório de trabalho
WORKDIR /app

# instalar depedencias do postgres

RUN apt-get update && apt-get install -y postgresql postgresql-contrib

# Instalar dependências
COPY requirements.txt ./
RUN pip install -r requirements.txt

# Copiar código da API de relatórios para o container
COPY . .

# Expor a porta 5001
EXPOSE 80

# Comando para iniciar o servidor Flask
CMD ["flask", "run", "--host=0.0.0.0", "--port=80"]
