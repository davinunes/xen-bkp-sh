#!/bin/bash
#
# Função: Backup via Stream API HTTP (Versão Log Limpo - Sem Barra de Progresso)
# Autor: Davi Nunes (Adaptado por Gemini)
# Versão: 5.1 (Clean Log Edition)
#
# Uso: ./exporta-vm-clean.sh <NOME_BKP> <UUID_VM> <IP_FTP> <USER_FTP> <SENHA_FTP> <SENHA_ROOT_XEN>

# Se qualquer parte do pipe falhar, o script assume erro
set -o pipefail

# Parâmetros
NOME_VM=$1
VM_UUID=$2
FTP_IP=$3
FTP_USER=$4
FTP_PASS=$5
XEN_USER="root"
XEN_PASS=$6

if [ $# -ne 6 ]; then
    echo "ERRO: Número incorreto de parâmetros."
    echo "Uso: $0 <Nome> <UUID_VM> <IP_FTP> <User_FTP> <Pass_FTP> <Pass_Root_Xen>"
    exit 1
fi

### Marcação de tempo
DATA_INICIAL=$(date +%s)
DATA_ARQUIVO=$(date +%d-%m-%Y_%H-%M-%S)
ARQUIVO_FINAL="${NOME_VM}_${DATA_ARQUIVO}.xva"

echo "========================================================"
echo "INICIANDO BACKUP (MODO SILENCIOSO)"
echo "VM UUID: $VM_UUID"
echo "Destino: $ARQUIVO_FINAL"
echo "Data:    $(date)"
echo "========================================================"

# 1. Configura URL do FTP
if [[ $FTP_IP =~ ":" ]]; then
    FTP_URL="ftp://[${FTP_IP}]/${ARQUIVO_FINAL}"
    CURL_OPTS="-g --ftp-create-dirs" 
else
    FTP_URL="ftp://${FTP_IP}/${ARQUIVO_FINAL}"
    CURL_OPTS="--ftp-create-dirs"
fi

# 2. Cria Snapshot
echo "[1/3] Criando snapshot da VM..."
SNAP_UUID=$(xe vm-snapshot uuid="$VM_UUID" new-name-label="SNAPSHOT_BKP_${NOME_VM}")

if [ -z "$SNAP_UUID" ]; then
    echo "ERRO: Falha ao criar snapshot. Verifique espaço no SR ou estado da VM."
    exit 1
fi

xe template-param-set is-a-template=false ha-always-run=false uuid=$SNAP_UUID

# 3. O Stream via HTTP (Silencioso)
echo "[2/3] Transferindo dados (Isso pode demorar, o terminal ficará parado)..."

# URL de Exportação
XEN_EXPORT_URL="https://localhost/export?uuid=${SNAP_UUID}"

# EXPLICANDO AS FLAGS NOVAS:
# -k : Ignora SSL (localhost)
# -u : Usuário e Senha
# -s : Silent (Não mostra barra de progresso nem tabela)
# -S : Show Errors (Se der erro, imprime na tela mesmo estando em modo silent)

curl -k -u "${XEN_USER}:${XEN_PASS}" -sS "${XEN_EXPORT_URL}" | \
curl $CURL_OPTS --user "$FTP_USER:$FTP_PASS" -T - -sS "$FTP_URL"

STATUS_PIPE=$?

# 4. Limpeza e Relatório
echo -e "\n[3/3] Removendo snapshot..."
xe vm-uninstall uuid=$SNAP_UUID force=true > /dev/null

DATA_FINAL=$(date +%s)
TEMPO_GASTO=$((DATA_FINAL - DATA_INICIAL))
TEMPO_FORMATADO=$(date -d@$TEMPO_GASTO -u +%H:%M:%S)

echo "--------------------------------------------------------"
if [ $STATUS_PIPE -eq 0 ]; then
    echo "SUCESSO: Backup finalizado!"
    echo "Arquivo: $ARQUIVO_FINAL"
    echo "Tempo:   $TEMPO_FORMATADO"
else
    echo "FALHA: Ocorreu um erro durante a transferência."
    exit 1
fi
echo "--------------------------------------------------------"
