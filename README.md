![CI](https://github.com/IsabelaEtt/devops-pucrs-fase02/actions/workflows/ci.yml/badge.svg)
![CD](https://github.com/IsabelaEtt/devops-pucrs-fase02/actions/workflows/cd.yml/badge.svg)
![Terraform](https://github.com/IsabelaEtt/devops-pucrs-fase02/actions/workflows/terraform.yml/badge.svg)

# Projeto DevOps Fase 2

API simples desenvolvida para demonstrar práticas de DevOps, com foco em Integração Contínua (CI), Entrega Contínua (CD) e Infraestrutura como Código (IaC).

## 💻 Sobre o Projeto
- 🚀 **API RESTful** em Node.js/Express
- 🔄 **CI/CD separado** com GitHub Actions
- 🐳 **Containerização** com Docker
- ☁️ **Infraestrutura AWS** provisionada via Terraform
- 🧪 **Testes automatizados** com Jest e Supertest
- 📦 **Múltiplos artefatos** (Docker Image + S3 Package)
- 🔒 **Segurança integrada** com auditorias automáticas


## 📚 Índice

- [Início Rápido](#-início-rápido)
- [API Endpoints](#-api-endpoints)
- [CI/CD Pipeline](#️-cicd-pipeline)
- [Infraestrutura](#️-infraestrutura)
- [Configuração e Deploy](#-configuração-e-deploy)
- [Tecnologias](#️-tecnologias)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Documentação Adicional](#-documentação-adicional)



## 🚀 Início Rápido

### Desenvolvimento Local

```bash
# 1. Clone o repositório
git clone https://github.com/IsabelaEtt/devops-pucrs-fase02.git
cd devops-pucrs-fase02

# 2. Instale as dependências
npm install

# 3. Execute a aplicação (http://localhost:3000)
npm start

# 4. Execute os testes
npm test
```

### Com Docker

```bash
# Build da imagem
npm run docker:build

# Execute o container
npm run docker:run

# Usando docker-compose (recomendado)
npm run docker:compose
```

## 📍 API Endpoints

| Endpoint | Método | Descrição | Resposta |
|----------|---------|------------|-----------|
| `/` | GET | Mensagem principal | `{ "message": "Hello World" }` |
| `/health` | GET | Health check | `{ "status": "OK" }` |

---

## ⚙️ CI/CD Pipeline

O projeto utiliza **workflows separados** para CI e CD, garantindo melhor controle, segurança e clareza no processo de deployment.

### 🏗️ Arquitetura do Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│                     DEVELOPER WORKFLOW                          │
│                   git push origin main                          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
        ┌──────────────────────────────────────────┐
        │  WORKFLOW 1: CI (Continuous Integration) │
        │       .github/workflows/ci.yml           │
        └──────────────────────────────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        │                                     │
        ▼                                     ▼
      ┌──────────┐    ┌──────────┐    ┌──────────┐
      │  Tests   │    │ Quality  │    │ Security │  ← Jobs executam em paralelo
      │  Node    │    │ Checks   │    │  Audit   │
      │  18/20   │    │          │    │          │
      └──────────┘    └──────────┘    └──────────┘
        │                                     │
        └──────────────────┬──────────────────┘
                           │
                           ▼
                  ┌────────────────┐
                  │   CI Status    │
                  │   All Passed   │
                  └────────────────┘
                           │
                           │     workflow_run trigger
                           │    (somente se CI passar)
                           ▼
        ┌──────────────────────────────────────────┐
        │  WORKFLOW 2: CD (Continuous Delivery)    │
        │       .github/workflows/cd.yml           │
        └──────────────────────────────────────────┘
                           │
                           ▼
                  ┌────────────────┐
                  │  Check CI      │
                  │  Verify Status │
                  └────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        ▼                                     ▼
  ┌────────────────┐              ┌────────────────┐
  │  Build Docker  │              │   Deploy S3    │  ← Jobs executam
  │  Push to GHCR  │              │   Upload Zip   │    em paralelo
  └────────────────┘              └────────────────┘
        │                                     │
        └──────────────────┬──────────────────┘
                           ▼
                  ┌────────────────┐
                  │     Summary    │
                  │     Report     │
                  └────────────────┘
                           │
        ┌──────────────────┴──────────────────┐
        ▼                                     ▼
┌──────────────────┐              ┌──────────────────┐
│  GHCR Registry   │              │   AWS S3 Bucket  │
│  Docker Image    │              │   .zip Package   │
│  :latest         │              │   latest.zip     │
└──────────────────┘              └──────────────────┘
```

### 📋 Fluxo do Pipeline

1. Developer faz push para `main`
2. CI dispara automaticamente executando 3 jobs em paralelo:
   - Testes em Node.js 18.x e 20.x
   - Verificações de qualidade do código
   - Auditoria de segurança (npm audit)
3. CI verifica resultados - todos os jobs devem passar
4. Se CI passar → CD dispara automaticamente via `workflow_run`
5. CD verifica sucesso do CI antes de prosseguir
6. CD executa 2 jobs em paralelo:
   - Build e push da imagem Docker para GitHub Container Registry
   - Criação e upload do pacote .zip para S3
7. Artefatos disponíveis → Aplicação pronta para deployment

> 💡 **Segurança Garantida**: Se CI falhar, CD **não é executado**, garantindo que apenas código validado seja deployado!

### 📊 Métricas do Pipeline

| Métrica | CI | CD | Total |
|---------|----|----|-------|
| **Duração** | ~2-3 min | ~2-3 min | ~4-6 min |
| **Jobs Paralelos** | 3 | 2 | 5 |
| **Artefatos Gerados** | Coverage + Security Report | Docker Image + S3 Package | 4 |
| **Node Versions** | 18.x, 20.x | 20.x | - |

### 🔨 Detalhes: CI - Continuous Integration

**Arquivo**: `.github/workflows/ci.yml`  
**Trigger**: Push/PR para `main`, manual

**Jobs**:

1. **Test** - Testes Automatizados
   - Matrix strategy: Node.js 18.x e 20.x
   - Executa suite de testes completa
   - Gera relatório de cobertura
   - Upload de artefatos de cobertura

2. **Quality** - Verificação de Qualidade
   - Valida estrutura do projeto
   - Verifica arquivos essenciais
   - Garante padrões de código

3. **Security** - Auditoria de Segurança
   - npm audit para vulnerabilidades
   - Relatório JSON de segurança
   - Upload de audit report

4. **CI Status** - Verificação Final
   - Consolida resultados de todos os jobs
   - Falha se qualquer job anterior falhar
   - Gatekeeping para CD

### 🚀 Detalhes: CD - Continuous Delivery

**Arquivo**: `.github/workflows/cd.yml`  
**Trigger**: Automático quando CI passa na `main`, manual

> ⚠️ **Importante**: CD **APENAS** executa se CI completar com sucesso!

**Jobs**:

1. **Check CI** - Verificação de Pré-requisito
   - Confirma que CI passou
   - Bloqueia CD se CI falhou

2. **Build Docker** - Build e Publicação
   - Build da imagem Docker otimizada
   - Login no GitHub Container Registry (GHCR)
   - Push com múltiplas tags: `latest`, `main`, `main-{sha}`
   - Cache para builds incrementais

3. **Deploy S3** - Upload de Artefatos
   - Cria pacote de deployment (.zip)
   - Inclui código fonte e dependências
   - Upload para S3 com versionamento
   - Mantém versão específica e `latest.zip`

4. **Deployment Summary** - Relatório Final
   - Status consolidado do deployment
   - Links para artefatos gerados
   - Confirmação de sucesso

---

## 🏗️ Infraestrutura

### AWS Resources (Terraform)

Toda a infraestrutura é provisionada como código usando Terraform:

**Recursos provisionados**:
- 🪣 **S3 Bucket** (`devops-pucrs-artifacts-bucket`)
  - Versionamento habilitado
  - Criptografia AES256
  - Bloqueio de acesso público
  - Lifecycle policies para otimização

**Arquivo**: `.github/workflows/terraform.yml`  
**Trigger**: Mudanças em `terraform/**`, manual

**Workflow**:
1. `terraform init` - Inicialização do backend
2. `terraform validate` - Validação de sintaxe
3. `terraform plan` - Preview de mudanças (PRs)
4. `terraform apply` - Aplicação automática (main)

### Uso Local do Terraform

```bash
cd terraform

# Inicializar
terraform init

# Ver plano de mudanças
terraform plan

# Aplicar mudanças
terraform apply

# Destruir recursos (cuidado!)
terraform destroy
```

---

## 🔧 Configuração e Deploy

### Pré-requisitos

1. **Conta AWS** com permissões para S3
2. **GitHub Secrets** configurados (Settings > Secrets and variables > Actions):
   - `AWS_ACCESS_KEY_ID` - Chave de acesso AWS
   - `AWS_SECRET_ACCESS_KEY` - Chave secreta AWS
   - `GITHUB_TOKEN` - Gerado automaticamente pelo GitHub

3. **Permissões do GitHub Actions** (Settings > Actions > General):
   - ☑️ Read and write permissions

### Setup Inicial

```bash
# 1. Clone o repositório
git clone https://github.com/IsabelaEtt/devops-pucrs-fase02.git
cd devops-pucrs-fase02

# 2. Configure os secrets no GitHub (via UI)

# 3. Provisione a infraestrutura
cd terraform
terraform init
terraform apply

# 4. Faça um push para main
git add .
git commit -m "feat: iniciar pipeline CI/CD"
git push origin main

# 5. Acompanhe os workflows na aba Actions
```

### Workflow Completo de Deploy

```
Developer → git push main
    ↓
CI executa (2-3 min)
    ↓
CI passa ✅
    ↓
CD dispara automaticamente
    ↓
CD executa (2-3 min)
    ↓
Artefatos disponíveis:
  • ghcr.io/<owner>/devops-pucrs-fase02:latest
  • s3://devops-pucrs-artifacts-bucket/releases/latest.zip
```

### Usando os Artefatos

#### Docker Image (GHCR)

```bash
# Pull da imagem
docker pull ghcr.io/<seu-usuario>/devops-pucrs-fase02:latest

# Executar
docker run -d -p 3000:3000 ghcr.io/<seu-usuario>/devops-pucrs-fase02:latest

# Verificar
curl http://localhost:3000/health
```

#### Package S3

```bash
# Download
aws s3 cp s3://devops-pucrs-artifacts-bucket/releases/latest.zip ./app.zip

# Extrair
unzip app.zip -d app

# Executar
cd app
npm start
```

### Redeploy Manual

Útil para redeployar sem executar testes novamente:

```bash
# No GitHub:
Actions → CD - Continuous Delivery → Run workflow → main → Run workflow
```

---

## 🛠️ Tecnologias

### Backend
- **Node.js** - Runtime JavaScript
- **Express** - Framework web minimalista

### Testes
- **Jest** - Framework de testes
- **Supertest** - Testes de API HTTP

### DevOps & CI/CD
- **GitHub Actions** - Automação de workflows
- **Docker** - Containerização
- **Docker Compose** - Orquestração local

### Cloud & IaC
- **AWS S3** - Armazenamento de artefatos
- **Terraform** - Infraestrutura como código
- **GitHub Container Registry (GHCR)** - Registry de imagens Docker

### Segurança
- **npm audit** - Auditoria de dependências
- **AES256 Encryption** - Criptografia no S3
- **Public Access Block** - Segurança no S3
