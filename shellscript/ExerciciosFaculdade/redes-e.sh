#!/bin/bash
#
# redes-e.sh
# Uso: rodar de dentro de ExerciciosFaculdade: ./redes-e.sh "string"
#e) Receber como argumento uma string, que deverá ser enviada (como conteúdo) para o arquivo criado no script anterior.
#Caso o arquivo de destino não possua permissão de escrita, deve ser emitido um alerta ao usuário
read -r caminho < ./logs/redes-d.log

if [ ! -e "$caminho" ]; then
    echo "Erro: o arquivo '$caminho' não existe." >&2
    exit 1
fi

if [ -w "$caminho" ]; then
    printf '%s\n' "$1" >> "$caminho"
else
    echo "Alerta: o arquivo '$caminho' não possui permissão de escrita para o usuário atual." >&2
    exit 1
fi