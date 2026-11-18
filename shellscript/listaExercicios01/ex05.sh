#!/bin/bash
#Calculadora: leia dois números e uma operação (+ - * /) usando case. Trate a divisão por zero

echo "esse script pode executar operações com os seguintes operadores: (+ - * /). Você deve inserir dois valores e selecionar a operação." 
read -p "Insira o 1° valor: " valor1; read -p "Insira o 2° valor: " valor2
clear
printf "Digite 1 para Soma (+)\nDigite 2 para Subitração (-)\nDigite 3 para Multiplicação (*)\nDigite 4 para Divisão (/)\n"
read -p "" opcao

#Trocar , por . caso digitar errado
valor1="${valor1//,/.}"
valor2="${valor2//,/.}"

case "$opcao" in
    1)
    printf "%s+%s=" "$valor1" "$valor2"
    awk -v valor1="$valor1" -v valor2="$valor2" 'BEGIN { printf "%.2f\n", valor1+valor2 }'
    ;;
    2)
    printf "%s-%s=" "$valor1" "$valor2"
    awk -v valor1="$valor1" -v valor2="$valor2" 'BEGIN { printf "%.2f\n", valor1-valor2 }'
    ;;
    3)
    printf "%s*%s=" "$valor1" "$valor2"
    awk -v valor1="$valor1" -v valor2="$valor2" 'BEGIN { printf "%.2f\n", valor1*valor2 }'
    ;;
    4)
    if ((valor2 == 0)); then
        echo "Divisão por 0! Inválida!"
    else
        printf "%s/%s=" "$valor1" "$valor2"
        awk -v valor1="$valor1" -v valor2="$valor2" 'BEGIN { printf "%.2f\n", valor1/valor2}'
    fi
    ;;
    *)
    echo "operação inválida!" >&2
    ;;
esac