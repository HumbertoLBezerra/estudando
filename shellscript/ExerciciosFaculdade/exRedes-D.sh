#!/bin/bash
#d) Receber como argumento o nome de um arquivo a ser criado.
# Antes de criar, o script deve verificar se o arquivo já existe e, em caso positivo, emitir um alerta ao usuário.

if test -e $1; then
    echo "Erro! Esse arquivo já existe!"
else
    mkdir $1
fi