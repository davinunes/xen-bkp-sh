#!/bin/bash
#
# Função: Backup via Stream usando API HTTP (Bypassa limitação do 'xe')
# Autor: Davi Nunes (Adaptado por Gemini)
# Versão: 5.0 (API HTTP Edition)
#
# Uso: ./exporta-vm-http.sh <NOME_BKP> <UUID_VM> <IP_FTP> <USER_FTP> <SENHA_FTP> <SENHA_ROOT_XEN>

set -o pipefail

# Parâmetros
NOME_VM=$1
VM_UUID=$2
FTP_IP=$3
FTP_USER=$4
FTP_PASS=$5
XEN_USER="root"
XEN_PASS=$6       # <--- NOVO PARÂMETRO: Senha local do XenServer

# Validação simples
if [ $# -ne 6 ]; then
    echo "ERRO: Faltam parâmetros."
    echo "Uso: $0 <Nome> <UUID_VM> <IP_FTP> <User_FTP> <Pass_FTP> <Pass_Root_Xen>"
    exit 1
fi

### Marcação de tempo
DATA_ARQUIVO=$(date +%d-%m-%Y_%H-%M-%S)
ARQUIVO_FINAL="${NOME_VM}_${DATA_ARQUIVO}.xva"

echo "========================================================"
echo "INICIANDO BACKUP VIA API HTTP (LOCALHOST)"
echo "VM UUID: $VM_UUID"
echo "Destino: $ARQUIVO_FINAL"
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
    echo "ERRO: Falha ao criar snapshot."
    exit 1
fi

xe template-param-set is-a-template=false ha-always-run=false uuid=$SNAP_UUID

# 3. O Stream via HTTP
echo "[2/3] Baixando via HTTP Local e Enviando para FTP..."
echo "      Isso contorna o erro de '/dev/stdout: File exists'"

# URL Mágica de Exportação do Xen (requer autenticação)
XEN_EXPORT_URL="https://localhost/export?uuid=${SNAP_UUID}"

# curl -k (ignora SSL local) -u (autentica no Xen) -> pipe -> curl (upload FTP)
curl -k -u "${XEN_USER}:${XEN_PASS}" "${XEN_EXPORT_URL}" | \
curl $CURL_OPTS --user "$FTP_USER:$FTP_PASS" -T - "$FTP_URL"

STATUS_PIPE=$?

# 4. Limpeza
echo "[3/3] Removendo snapshot..."
xe vm-uninstall uuid=$SNAP_UUID force=true

if [ $STATUS_PIPE -eq 0 ]; then
    echo "SUCESSO: Backup finalizado via API."
else
    echo "FALHA: Erro no transporte dos dados."
    exit 1
fi
