# Script para configurar o backend remoto do Terraform
# Este script deve ser executado APENAS UMA VEZ antes de usar o Terraform com backend remoto

set -e

REGION="us-east-2"
STATE_BUCKET="devops-fase-02-terraform-state"
DYNAMODB_TABLE="devops-fase-02-terraform-locks"

echo "=========================================="
echo "Configurando Backend Remoto do Terraform"
echo "=========================================="
echo ""

# Criar bucket S3 para armazenar o state
echo "1. Criando bucket S3: $STATE_BUCKET"
aws s3api create-bucket \
    --bucket $STATE_BUCKET \
    --region $REGION \
    --create-bucket-configuration LocationConstraint=$REGION

# Habilitar versionamento no bucket
echo "2. Habilitando versionamento no bucket..."
aws s3api put-bucket-versioning \
    --bucket $STATE_BUCKET \
    --versioning-configuration Status=Enabled

# Habilitar criptografia
echo "3. Habilitando criptografia no bucket..."
aws s3api put-bucket-encryption \
    --bucket $STATE_BUCKET \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'

# Bloquear acesso público
echo "4. Bloqueando acesso público ao bucket..."
aws s3api put-public-access-block \
    --bucket $STATE_BUCKET \
    --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

# Criar tabela DynamoDB para lock
echo "5. Criando tabela DynamoDB: $DYNAMODB_TABLE"
aws dynamodb create-table \
    --table-name $DYNAMODB_TABLE \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region $REGION

echo ""
echo "=========================================="
echo "✅ Backend configurado com sucesso!"
echo "=========================================="
echo ""
echo "Recursos criados:"
echo "  - S3 Bucket: $STATE_BUCKET"
echo "  - DynamoDB Table: $DYNAMODB_TABLE"
echo ""
