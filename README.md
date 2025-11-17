![CI Pipeline](https://github.com/IsabelaEtt/devops-pucrs-fase02/actions/workflows/ci.yml/badge.svg)

# Projeto DevOps Fase 2

API simples desenvolvida para demonstrar práticas de DevOps, com foco em Integração Contínua (CI) e Infraestrutura como Código (IaC).

## 💻 Sobre o Projeto

- API Node.js/Express que retorna mensagem "Hello World"
- Pipeline de CI/CD com GitHub Actions
- Infraestrutura AWS provisionada via Terraform
- Testes automatizados com Jest e Supertest

## 🚀 Início Rápido

```bash
# Instalação
npm install

# Executar API (http://localhost:3000)
npm start

# Executar Testes
npm test
```

## 📍 Endpoints

| Endpoint | Método | Descrição | Resposta |
|----------|---------|------------|-----------|
| `/` | GET | Mensagem principal | `{ "message": "Hello World" }` |
| `/health` | GET | Health check | `{ "status": "OK" }` |

## ⚙️ CI/CD Pipeline

O pipeline (`.github/workflows/ci.yml`) é executado em pushes para `main` e pull requests, incluindo:

1. **Build e Testes**
   - Compatibilidade Node.js 18.x e 20.x
   - Testes unitários e relatório de cobertura

2. **Qualidade e Segurança**
   - Verificação de estrutura do projeto
   - Auditoria de segurança (npm audit)

## 🏗️ Infraestrutura

Recursos AWS provisionados via Terraform:
- S3 Bucket com versionamento para artefatos

## 🛠️ Tecnologias

- **Backend:** Node.js, Express
- **Testes:** Jest, Supertest
- **CI/CD:** GitHub Actions
- **IaC:** Terraform
- **Cloud:** AWS (S3)
  - Criptografia AES256
  - Bloqueio de acesso público (segurança)

### Workflow de Infraestrutura

O arquivo `.github/workflows/terraform.yml` automatiza:
- ✅ `terraform init` - Inicialização
- ✅ `terraform validate` - Validação
- ✅ `terraform plan` - Planejamento (em PRs)
- ✅ `terraform apply` - Aplicação automática (push na main)

### Como Usar

#### Pré-requisitos
1. Conta AWS
2. Configurar secrets no GitHub:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

#### Uso Local

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

#### Uso Automático

O Terraform é executado automaticamente via GitHub Actions:
- **Push na main** → Aplica mudanças automaticamente
- **Pull Request** → Mostra o plano de mudanças
- **Manual** → Via workflow_dispatch