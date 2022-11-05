#!/bin/bash -x
#
# Função: Faz Backup da vm com UUID especificado no repositório listado tb com uuid
# Autor: Davi Nunes (davi.nunes@gmail.com) / Data: 25-07-2017
# Versão: 2.0
# Requerimentos: Este script precisa ser executado no prompt de algum Servidor XEN
# Observações: Faz Backup de Apenas uma VM.

######################
#	CONFIGURAÇÕES	 #
######################


NOME_VM=$1		# NOME DO BACKUP DA VM
vm_uuid=$2 		# UUID DA VM A REALIZAR BACKUP
ABORTAR=0		# DECIDIR SE ABORTA OU NÃO

CHAT=" bash /root/telegram.sh ${NOME_VM} "

# Chama o script auxiliar que limpa arquivos em excesso do repositório
MNT=" bash /root/mnt.sh"

$CHAT "Iniciando tarefa de Backup de ${NOME_VM} com uid ${vm_uuid}"

### Marcação de tempo do Script
datainicial=`date +%s`
dataarquivo=$(date +%d-%m-%Y_%H-%M-%S)
###

# Verifica se existe a pasta no ponto de montagem
if [ ! -d "/tmp/bkp" ]; then
	mkdir /tmp/bkp
fi

# Tentando Estabelecer Ponto de Montagem
mount -t cifs //100.64.63.1/xen -o username="Blue",password='yuk11nn4',vers=3.0 /tmp/bkp

# Se consegui montar a pasta
if [ $? -eq 0 ] 
	then 
		# echo -e "\n$(date +%d-%m-%Y_%H:%M:%S): Consegui criar o Ponto de Montagem /tmp/${NOME_VM}!" >> historico_backup
		$CHAT "Consegui criar o Ponto de Montagem: /tmp/bkp"
	else
		# echo -e "\n$(date +%d-%m-%Y_%H:%M:%S): NÃO Consegui criar o Ponto de Montagem /tmp/${NOME_VM} e portanto estarei abortando!" >> historico_backup
		$CHAT "Falha ao tentar montar /tmp/bkp"
		ABORTAR+=1
		
fi



if [ $ABORTAR -eq 1 ] 
	then 
		# echo -e "\n$(date +%d-%m-%Y_%H:%M:%S): Falha no mapeamento de rede!" >> historico_backup
		$CHAT "Operação foi abortada!"
		exit 0
fi



# echo -e "\n$(date +%d-%m-%Y_%H:%M:%S): Iniciando backup da máquina virtual de UUID $vm_uuid para o Arquivo ${NOME_VM}_${dataarquivo}" >> historico_backup
$CHAT "Iniciando backup da máquina virtual de UUID $vm_uuid para o Arquivo ${NOME_VM}_${dataarquivo}"

# TIRA SNAPSHOT DA VM E ARMAZENA O NOVO UUID NA VERIAVEL
SNAP_ID=$(xe vm-snapshot uuid="$vm_uuid" new-name-label=$NOME_VM)
# echo -e "\n$(date +%d-%m-%Y_%H:%M:%S): Snapshot criado!" >> historico_backup
$CHAT "...Snapshot criado..."

# CONVERTE O SNAP EM TEMPLATE
xe template-param-set is-a-template=false ha-always-run=false uuid=$SNAP_ID
# echo -e "\n$(date +%d-%m-%Y_%H:%M:%S): Snapshot convertido em VM" >> historico_backup
$CHAT "...Snapshot convertido em VM..."

# Exporta o UUID para um local remoto e o transforma em um arquivo .xva


if [ ! -d "/tmp/bkp/${NOME_VM}" ]; then
	mkdir /tmp/bkp/${NOME_VM}
fi
$CHAT "Exportando para ${NOME_VM}/${NOME_VM}_${dataarquivo}.xva"
xe vm-export vm=$SNAP_ID filename=/tmp/bkp/${NOME_VM}/${NOME_VM}_${dataarquivo}.xva
$CHAT "Transferência concluída, será realizado manutenção da quantidade de backups no repositório"

$MNT /tmp/bkp/${NOME_VM}/

# echo -e "\n$(date +%d-%m-%Y_%H:%M:%S): VM exportada com Sucesso!" >> historico_backup

# REMOVE O SNAPSHOT FEITO NESTE SCRIPT
xe vm-uninstall uuid=$SNAP_ID force=true
# echo -e "\n$(date +%d-%m-%Y_%H:%M:%S): Snapshot Removido do Disco!" >> historico_backup
$CHAT "Removi snapshot do servidor"

# Desmonta os Pontos de Montagem
umount /tmp/bkp

# echo -e "\n$(date +%d-%m-%Y_%H:%M:%S): Pastas desmontadas!" >> historico_backup
$CHAT "Pasta desmontada"

#########
#	Calculo de Tempo do SCRIPT
datafinal=`date +%s`
soma=`expr $datafinal - $datainicial`
resultado=`expr 10800 + $soma`
tempo=`date -d @$resultado +%H:%M:%S`
# echo -e "\nTempo gasto: $tempo \n#################################################\n" >> historico_backup
$CHAT "Concluido em ${tempo}h"
