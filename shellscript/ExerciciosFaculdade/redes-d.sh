#!/bin/bash
#
#redes-d.sh
#
#d) Receber como argumento o nome de um arquivo a ser criado.
# Antes de criar, o script deve verificar se o arquivo já existe e, em caso positivo, emitir um alerta ao usuário.

if test -e "$1"; then
    echo "Erro! Esse arquivo já existe!"
else
    rm ./logs/redes-d.log #se o log existir, apaga para criar outro
    touch "$1" #Cria o arquivo
    echo "$1" > ./logs/redes-d.log #Cria o log novo
fi