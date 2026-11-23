#!/bin/bash
#
#redes-f.sh
#necessário rodar como sudo
#
#f) Criar um usuário, a partir de um login informado como argumento. O script deverá verificar se o login desejado já existe no sistema e emitir um alerta, caso já exista.
# O usuário deve ser criado sem a necessidade de envio de informações adicionais ou senha
if [ -z "$1" ]; then 
	echo "Uso: $0 <login>" >&2
	exit 1
fi
if id "$1" 2>/dev/null; then
	echo "O usuário $1 informado já existe!" >&2
else
	useradd -m -s /bin/bash "$1"
fi
