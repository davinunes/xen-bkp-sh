MyToken="5523001812:AAHKOGVxTvcgY0WlhBIVI4Na7uK_arNcLlc"
chatID="467782812"
Message="Xen:%0A -Tarefa: "
Message+=$1
Message+="%0A"
Message+=$2
curl "https://api.telegram.org/bot$MyToken/sendMessage?chat_id=$chatID&text=$Message"
