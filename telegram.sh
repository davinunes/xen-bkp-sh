MyToken="---"
chatID="467782812"
Message="Xen:%0A -Tarefa: "
Message+=$1
Message+="%0A"
Message+=$2
curl "https://api.telegram.org/bot$MyToken/sendMessage?chat_id=$chatID&text=$Message"
