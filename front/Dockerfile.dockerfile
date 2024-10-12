# Usar uma imagem do Node.js como base
FROM node:16 as build

# Criar diretório de trabalho
WORKDIR /app

# Copiar arquivos do projeto para o diretório de trabalho
COPY package.json ./
COPY package-lock.json ./

# Instalar dependências do Angular
RUN npm install

# Copiar código para o container
COPY . .

# Buildar a aplicação Angular
RUN npm run build --prod

# Utilizar uma imagem NGINX para servir o frontend
FROM nginx:alpine

# Copiar a build Angular para a pasta do NGINX
COPY --from=build /app/dist/your-angular-app /usr/share/nginx/html

# Expor a porta 80
EXPOSE 80

# Comando para rodar o NGINX
CMD ["nginx", "-g", "daemon off;"]
