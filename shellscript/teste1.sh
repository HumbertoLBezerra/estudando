#!/bin/bash

echo  "Esse script vai ler o seu nome e a sua idade, e depois exibir eles."

read -p "Insira seu nome: " nome; read -p "Insira sua idade:" idade

printf "Nome: %s | Idade: %d\n" "$nome" "$idade"
echo  "pressione ENTER para o script continuar para o próximo passo." ; read dummy; clear

#---------------------------------------------------

echo "vamos calcular alguns números!, insira 3 valores e vamos fazer algumas operações com eles."

read -p "1°Valor:" valor1; read -p "2°Valor:" valor2; read -p "3°Valor:" valor3

printf "Valor1: %d | Valor2: %d | Valor3: %d\n" "$valor1" "$valor2" "$valor3"
