#!/bin/bash
#Receba um caminho como parâmetro ($1) e diga se é arquivo, diretório ou se não existe.

tipo=$(file -b --mime-type "$1") #Descobre o tipo de arquivo

if [ "$tipo" = "inode/directory" ]; then
   echo "diretório"
elif $0; then
    echo "Não Existe!"
else
    echo "é um arquivo"
fi