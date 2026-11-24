#!/bin/bash
#
#redes-a.sh
#
#a) Receber 2 números como entrada, e informar a relação entre eles (maior, menor ou igual).
#ps: sei que da pra fazer com que se não for informados valores inicialmente ele executar um read para aceitar, mas não tive tempo de aprender a fazer isso ainda.
#Trocar, por . caso digitar errado
valor1="${1//,/.}"
valor2="${2//,/.}"
re_numero='^[+-]?([0-9]+([.,][0-9]+)?|[.,][0-9]+)$' # Regex para aceitar números com casas decimais e negativos sem problemas

if [[ $valor1 =~ $re_numero ]] && [[ $valor2 =~ $re_numero ]]; then #Verifica se é um número válido
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

if [[ $valor1 =~ $re_numero ]] && [[ $valor2 =~ $re_numero ]]; then #Verifica se é um número válido
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
