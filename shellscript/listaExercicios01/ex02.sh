#!/bin/bash
#Leia 3 números e mostre o maior.

if [ $(($1 > $2)) ] && [ $(($1 > $3)) ]; then
    echo "$1 é o maior número!"
elif [ $(($2 > $1)) ] && [ $(($2 > $3)) ]; then
    echo "$2 é o maior número!"
else
    echo "$3 é o maior número!"
fi

#pedindo valores
echo "pressione ENTER para rodar a versão que solicita dados"
read -r dummy #apenas para pausa o programa

echo "Digite 3 valores e a seguir o script vai mostrar qual o maior entre eles!"
read -r -p "1° Valor: " valor1; read -r -p "2° Valor: " valor2; read -r -p "3° Valor: " valor3

if [ $((valor1 > valor2)) ] && [ $((valor1 > valor3)) ]; then
    echo "$valor1 é o maior!"
elif [ $((valor2 > valor1)) ] && [ $((valor2 > valor3)) ]; then
    echo "$valor2 é o maior!"
else
    echo "$valor3 é o maior!"
fi



