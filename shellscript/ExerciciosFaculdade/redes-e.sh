#!/bin/bash
#
#redes-e.sh
# Uso: rodar de dentro de ExerciciosFaculdade: ./redes-d.sh string
#
#e) Receber como argumento uma string, que deverá ser enviada (como conteúdo) para o arquivo criado no script anterior.
#Caso o arquivo de destino não possua permissão de escrita, deve ser emitido um alerta ao usuário. 

IFS=, read -r caminho < ./logs/redes-d.log

if grep <(stat -c "%A" "$caminho"); then
    echo "W"
else 
    Echo "M"
fi
echo "$1" >> "$caminho"
