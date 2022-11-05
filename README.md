# xen-bkp-sh

bkpall.sh: Chama várias vezes o arquivo bkp-vm.sh

bkp-vm.sh: recebe como parâmetro um uid e uma string e executa backup de uma vm no xenserver

telegram.sh: é utilizado pelos outros scripts para enviar mensagens via telegram

mnt.sh: deleta arquivos de backup muito antigos

log.sh: é utilizado pelo mnt.sh para escrever log

# exemplo de agendamentos no cron:

```bash
57 22 * * 1-5 bash /root/bkp.sh sped2018_64bits e9d8c9a5-a745-f5a3-93b2-8534daefc19d
57 23 * * 5 bash /root/bkp2.sh sped2018_64bits2 e9d8c9a5-a745-f5a3-93b2-8534daefc19d
15 19 * * 1-5 bash /root/bkp.sh zimbra 0747178c-6cb8-8853-ad62-70b619b671e5
15 20 * * 5 bash /root/bkp2.sh zimbra2 0747178c-6cb8-8853-ad62-70b619b671e5
05 21 * * 1-5 bash /root/bkp.sh SisBol 8d248ea9-1337-9ad3-131d-f35f748d92b4
05 22 * * 5 bash /root/bkp2.sh SisBol2 8d248ea9-1337-9ad3-131d-f35f748d92b4
01 05 * * 1-5 bash /root/bkp.sh Simatex deec9dfb-740c-3bab-d03b-b9feaf066264
01 06 * * 5 bash /root/bkp2.sh Simatex2 deec9dfb-740c-3bab-d03b-b9feaf066264
57 04 * * 2 bash /root/bkp.sh Siscop2 61cb1016-409a-dc45-83d9-ea7087c8e440
57 03 * * 1-5 bash /root/bkp.sh SisGep 05981513-3dc5-4b06-9ec7-07859e410152
57 02 * * 1-5 bash /root/bkp2.sh SisGep2 05981513-3dc5-4b06-9ec7-07859e410152
```
