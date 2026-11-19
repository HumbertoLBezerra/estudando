#!/bin/bash
#Leia uma idade e classifique: menor de 18, adulto ou idoso (60+).

if (($1 >= 60)); then
    echo "Idoso!"
elif (($1 >= 18)); then
    echo "Adulto!"
else
    echo "Menor de 18!"
fi

#pedindo valores
echo "pressione ENTER para rodar a versão que solicita dados"
read dummy #apenas para pausa o programa

read -p "Por favor digite a sua idade: " idade

if ((idade > 59)); then
    echo "Idoso!"
elif ((idade > 18)); then
    echo "Adulto!"
else
    echo "Menor de 18!"
fi

