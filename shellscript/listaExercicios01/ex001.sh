#!/bin/bash
#Leia um número e verifique se ele é par ou impar

if [ $((1%2)) -eq 0 ]; then
    echo "$1 é Par"
else
    echo "$1 é Impar"
fi

read dummy

read -p "Digite um número para verificar se ele é par ou ímpar" valor

if [ $((valor%2)) -eq 0 ]; then
    echo "$valor é Par"
else
    echo "$valor é ímpar"
fi
