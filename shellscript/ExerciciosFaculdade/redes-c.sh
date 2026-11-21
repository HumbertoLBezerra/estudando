#!/bin/bash
#
#redes-c.sh
#
#c) Receber uma string como argumento e informar se é um arquivo, diretório ou inexistente.

if test -e "$1"; then #O primeiro if verifica se existe
    if test -f "$1"; then # Verifica se é um arquivo
        echo "$1 É um arquivo!"
    elif test -d "$1"; then # Verifica se é um diretório
        echo "$1 É um diretório"
    fi
else
    echo "$1 Inexistente!" # Caso não seja encontrado vai dizer que é inexistente
fi