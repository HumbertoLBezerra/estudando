#!/bin/bash
#
#redes-b.sh
#
#b) Receber como argumento um número inteiro, e exibir a mensagem “par”, "ímpar". 

if [[ $1 =~ ^[0-9]+?$ ]]; then
    if ((($1%2) != 0)); then
        echo "$1 é Ímpar"
    else
        echo "$1 é par"
    fi
else
    echo "Um valor inválido foi inserido!"
fi