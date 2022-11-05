#!/bin/bash
#
# Função: Faz Backup da vm com UUID especificado no repositório listado tb com uuid
# Autor: Davi Nunes (davi.nunes@gmail.com)
# Data: 25-07-2017
# Versão: 1.0
# Requerimentos: Este script precisa ser executado no prompt de algum Servidor XEN
# Observações: Faz Backup de Apenas uma VM.

######################
#	CONFIGURAÇÕES	 #
######################

set -x

PastaVerificar=$1		# NOME DO BACKUP DA VM
time_limit=8
MinQde=7
tarefa=" Tarefa: Manutenção de backup"

CHAT=" bash /root/telegram.sh ${tarefa} "
LOG=" bash /root/log.sh"

NumeroDeArquivos=$(ls $PastaVerificar | wc -l)

if [ -f "/root/lista.txt" ]; then
	rm /root/lista.txt
fi

if [ $NumeroDeArquivos -le $MinQde ]
then
    echo "Nada há para apagar!"
else
	echo "Vamos Apagar Alguma coisa!"
	# find $PastaVerificar -type f -ctime +$time_limit -exec ls -lah {} \;
	find $PastaVerificar -maxdepth 1 -type f -ctime +$time_limit -exec $LOG {} \;
	
	
	Lista=$(cat /root/lista.txt)

	cat /root/lista.txt >> deletados.txt

	for ARQ in $(cat /root/lista.txt) ; do
		
		rm -f $ARQ
	done

	$CHAT "Alguns arquivos foram deletados em $PastaVerificar:%0A ${Lista}"
fi





