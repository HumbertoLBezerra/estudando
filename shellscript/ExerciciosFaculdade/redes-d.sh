#!/bin/bash
#
#redes-d.sh
# Uso: rodar de dentro de ExerciciosFaculdade: ./redes-d.sh nome_do_arquivo
#
#d) Receber como argumento o nome de um arquivo a ser criado.
# Antes de criar, o script deve verificar se o arquivo já existe e, em caso positivo, emitir um alerta ao usuário.

if test -e "$1"; then
    echo "Erro! Esse arquivo já existe!"
else
    touch "$1" #Cria o arquivo
    echo "$1" > ./logs/redes-d.log #Cria o log novo
fi