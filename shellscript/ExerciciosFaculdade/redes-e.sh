#!/bin/bash
#
#redes-e.sh
# Uso: rodar de dentro de ExerciciosFaculdade: ./redes-d.sh string
#
#e) Receber como argumento uma string, que deverá ser enviada (como conteúdo) para o arquivo criado no script anterior.
#Caso o arquivo de destino não possua permissão de escrita, deve ser emitido um alerta ao usuário. 

IFS=, read -r caminho < ./logs/redes-d.log
testes=$(stat -c "%A" "$caminho")
#outra forma para o if:
#if  grep -q -i [w] <<< "$testes"; then
if [[ "$testes" == *w* ]]; then
    echo "W"
    echo "$1" >> "$caminho"
else 
    echo "O arquivo em questão não possui permissão de escrita!"
fi

read "dummy"
