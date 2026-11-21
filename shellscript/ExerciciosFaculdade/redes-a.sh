#!/bin/bash
#
#redes-a.sh
#
#a) Receber 2 números como entrada, e informar a relação entre eles (maior, menor ou igual).

#Trocar, por . caso digitar errado
valor1="${1//,/.}"
valor2="${2//,/.}"

if [[ $valor1 =~ ^[0-9]+([.][0-9]+)?$ ]] && [[ $valor2 =~ ^[0-9]+([.][0-9]+)?$ ]]; then #Verifica se é um número válido
    if awk -v valor1="$valor1" -v valor2="$valor2" 'BEGIN {exit !(valor1 > valor2)}'; then #Verifica qual se o 1° valor é maior que o 2°
        echo "$valor1 > $valor2"
    elif awk -v valor1="$valor1" -v valor2="$valor2" 'BEGIN {exit !(valor1 < valor2)}'; then #Caso o 1° não seja maior que o 2°, ele verifica se o 2° é maior que o 1°, caso falso ele vai dizer que são iguais!
        echo "$valor1 < $valor2"
    else
        echo "$valor1 = $valor2"
    fi
else
    echo "Erro! Algum dos valores inseridos é inválido!"
fi

#Recebendo entrada pelo read

read -r -p "Insira um valor qualquer: " valor1
read -r -p "Insira novamente um valor qualquer: " valor2

#Trocar, por . caso digitar errado
valor1="${valor1//,/.}"
valor2="${valor2//,/.}"

if [[ $valor1 =~ ^[0-9]+([.][0-9]+)?$ ]] && [[ $valor2 =~ ^[0-9]+([.][0-9]+)?$ ]]; then #Verifica se é um número válido
    if awk -v valor1="$valor1" -v valor2="$valor2" 'BEGIN {exit !(valor1 > valor2)}'; then #Verifica qual se o 1° valor é maior que o 2°
        echo "$valor1 > $valor2" e
    elif awk -v valor1="$valor1" -v valor2="$valor2" 'BEGIN {exit !(valor1 < valor2)}'; then #Caso o 1° não seja maior que o 2°, ele verifica se o 2° é maior que o 1°, caso falso ele vai dizer que são iguais!
        echo "$valor1 < $valor2"
    else
        echo "$valor1 = $valor2"
    fi
else
    echo "Erro! Algum dos valores inseridos é inválido!"
fi
