# Usar imagem do Python como base
FROM python:3.9-slim

# Criar diretório de trabalho
WORKDIR /app

# Instalar dependências
COPY requirements.txt ./
RUN pip install -r requirements.txt

# Copiar código do backend para o container
COPY . .

# Expor a porta 80
EXPOSE 80

# Comando para iniciar o servidor Flask
CMD ["flask", "run", "--host=0.0.0.0", "--port=80"]
