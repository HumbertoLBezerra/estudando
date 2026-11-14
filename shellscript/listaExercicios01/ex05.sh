#!/bin/bash
#Calculadora: leia dois números e uma operação (+ - * /) usando case. Trate a divisão por zero

echo "esse script pode executar operações com os seguintes operadores: (+ - * /). Você deve inserir dois valores e selecionar a operação." 
read -p "Insira o 1° valor: " valor1; read -p "Insira o 2° valor: " valor2
clear
printf "Digite 1 para Soma (+)\nDigite 2 para Subitração (-)\nDigite 3 para Multiplicação (*)\nDigite 4 para Divisão (/)\n"
read -p "" opcao

case $opcao in
    1)
    awk 'BEGIN { printf "%.2f\n, $valor1 + $valor2}'
    ;;
    2)
    echo "$valor1 - $valor2 Resultado: $(($valor1-$valor2))"
    ;;
    3)
    echo "$valor1 * $valor2 Resultado: $(($valor1*$valor2))"
    ;;
    4)
    echo "scale = 2; $valor1 / $valor2 Resultado: $(($valor1/$valor2))"
    ;;
    *)
    echo "operação inválida!"
esac