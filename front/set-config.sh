#!/bin/bash

# Script para configurar o projeto Angular com serviços e componentes necessários

# Saia imediatamente se um comando falhar
set -e

# Função para verificar se um comando existe
command_exists () {
    command -v "$1" >/dev/null 2>&1 ;
}

# Verificar se o Angular CLI está instalado
if ! command_exists ng ; then
    echo "Angular CLI não está instalado. Instalando..."
    npm install -g @angular/cli
else
    echo "Angular CLI encontrado."
fi

# Definir o diretório do frontend
FRONTEND_DIR="frontend"

# Verificar se o diretório frontend existe
if [ ! -d "$FRONTEND_DIR" ]; then
    echo "Diretório '$FRONTEND_DIR' não encontrado. Criando e inicializando um novo projeto Angular..."
    mkdir $FRONTEND_DIR
    cd $FRONTEND_DIR
    # Inicializar um novo projeto Angular sem instalar dependências e com configurações padrão
    ng new . --skip-install --defaults
else
    echo "Diretório '$FRONTEND_DIR' encontrado. Navegando para o diretório..."
    cd $FRONTEND_DIR
fi

# Instalar dependências do projeto
echo "Instalando dependências do projeto..."
npm install

# Gerar o serviço ApiService
echo "Gerando o serviço ApiService..."
ng generate service services/api

# Gerar os componentes necessários
echo "Gerando os componentes Home, Healthcheck e BackendCall..."
ng generate component home
ng generate component healthcheck
ng generate component backend-call

# Importar HttpClientModule no app.module.ts se ainda não estiver importado
APP_MODULE="src/app/app.module.ts"

if ! grep -q "HttpClientModule" $APP_MODULE ; then
    echo "Importando HttpClientModule no app.module.ts..."
    # Inserir a importação de HttpClientModule após BrowserModule
    sed -i.bak "/import { BrowserModule } from '@angular\/platform-browser';/a import { HttpClientModule } from '@angular/common/http';" $APP_MODULE
    # Adicionar HttpClientModule aos imports do NgModule
    sed -i.bak "/imports: \[/a \    HttpClientModule," $APP_MODULE
else
    echo "HttpClientModule já está importado no app.module.ts."
fi

# Atualizar app-routing.module.ts com as rotas necessárias
ROUTES_CONTENT="
import { HomeComponent } from './home/home.component';
import { HealthcheckComponent } from './healthcheck/healthcheck.component';
import { BackendCallComponent } from './backend-call/backend-call.component';

const routes: Routes = [
  { path: '', component: HomeComponent },
  { path: 'healthcheck', component: HealthcheckComponent },
  { path: 'backend-call', component: BackendCallComponent },
  { path: '**', redirectTo: '' } // Redireciona rotas desconhecidas para a página inicial
];
"

APP_ROUTING="src/app/app-routing.module.ts"

echo "Atualizando $APP_ROUTING com as rotas necessárias..."

# Fazer backup do arquivo de rotas
cp $APP_ROUTING ${APP_ROUTING}.bak

# Remover rotas existentes entre 'const routes:' e '];'
sed -i.bak "/const routes:/,/];/d" $APP_ROUTING

# Adicionar as novas rotas
echo "$ROUTES_CONTENT" > tmp_routes.ts
cat tmp_routes.ts >> $APP_ROUTING
rm tmp_routes.ts

# Atualizar app.component.html para incluir <router-outlet>
APP_COMPONENT_HTML="src/app/app.component.html"
echo "Atualizando $APP_COMPONENT_HTML para incluir <router-outlet>..."
echo "<router-outlet></router-outlet>" > $APP_COMPONENT_HTML

# Atualizar environment.ts para configuração de desenvolvimento
ENV_DEV="src/environments/environment.ts"
echo "Configurando $ENV_DEV para ambiente de desenvolvimento..."
cat > $ENV_DEV <<EOL
export const environment = {
  production: false,
  backendUrl: 'http://localhost:5000' // URL do backend para desenvolvimento
};
EOL

# Atualizar environment.prod.ts para configuração de produção
ENV_PROD="src/environments/environment.prod.ts"
echo "Configurando $ENV_PROD para ambiente de produção..."
cat > $ENV_PROD <<EOL
export const environment = {
  production: true,
  backendUrl: 'http://<seu-backend-url-em-producao>' // Substitua pelo endpoint real do backend
};
EOL

# Informar ao usuário que a configuração foi concluída
echo "Configuração do projeto Angular concluída com sucesso!"

echo "Lembre-se de substituir '<seu-backend-url-em-producao>' em $ENV_PROD pelo endpoint real do seu backend em produção."
echo "Você também pode personalizar os componentes gerados conforme necessário."
