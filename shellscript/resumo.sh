#!/bin/sh
#Comentários são feitos com # e os blocos onde existem comandos que podem ser descomentados para teste estão entre linhas de [-]

# ==============================================================================
# 0. DIFERENÇA ENTRE #!/bin/sh E #!/bin/bash
# ==============================================================================
# A primeira linha (shebang) define qual interpretador executa o script.
#   - #!/bin/sh   -> Shell padrão POSIX: mais simples, leve e portátil. Em alguns sistemas (ex: Debian/Ubuntu) é o 'dash', que não tem recursos extras do bash (ex: read -p, read -n, [[ ]], arrays).
#   - #!/bin/bash -> Bash: tudo do sh + recursos extras. Mais prático, porém menos portátil (pode não existir em sistemas minimalistas).
# Dica: use /bin/sh se precisa rodar em qualquer lugar; use /bin/bash se precisa dos recursos extras.


# ==============================================================================
# 1. COMANDOS BÁSICOS
# ==============================================================================

#[clear] - Comando que limpa a tela

#[echo "Hello, World!"] - Escreve na tela o que está depois dele.


# ==============================================================================
# 2. VARIÁVEIS
# ==============================================================================

#AS variáveis no shell são definidas pelo simbolo [$] com o nome dela logo após. Sendo assim sua estrutura é: [$var]  Ex: [$exemplo], [$teste], [$etc]
#Os valores atribuídos às variáveis são todos tratados como strings e o shell armazena os valores como sequências de caracteres. Para forçá-lo a identificar algo com valor numérico, precisamos usar comandos que o forcem a interpretar aquilo da forma correta. Ex: ((a+b)). O '(())' o força a tratar o que estiver dentro dos parênteses duplos como números inteiros.


# ==============================================================================
# 3. PARÂMETROS POSICIONAIS
# ==============================================================================

#No shellscript, os parâmetros passados são capturados de forma automática por variáveis especiais (parâmetros posicionais), sendo elas $1, $2, $3, etc. Cada número corresponde à ordem em que o parâmetro foi inserido no terminal. A partir do 10, usamos {}. Ex: ${10}
#[S#] informa a quantidade total dos parâmetros passados
#[$@] ou [$*] Representam todos os parâmetros passados de uma só vez.

#-----------------------------------------------------------
#echo "Olá, vamos testar uma passagem de parâmetros agora!"
#echo "Os 3 parâmetros inseridos nesse script vão aparecer na próxima linha:"
#echo "\$1= $1 | \$2= $2 | \$3= $3"
#-----------------------------------------------------------


# ==============================================================================
# 4. ASPAS
# ==============================================================================

#As aspas possuem diferenças. Quando usamos apenas as [''] aspas simples, tudo dentro do texto é passado de forma literal, nada é interpretado.
#Quando usamos as [""] aspas duplas, elas mantêm os espaços intactos, protegem contra erros e leem o valor das variáveis.
#Quando usamos as [``] crases, o shell olha para o comando inserido dentro delas, o executa em segundo plano e então joga o seu resultado onde as crases estavam (é recomendado usar [$()] ao invez das crases.). Ex:

#-----------------------------------------------------------
echo "Hoje é `date`" #Forma mais antiga.
echo "hoje é $(date)" #Mais comum e normal
# linha acima vai escrever a data atual, dia, hora e fuso.
#-----------------------------------------------------------


# ==============================================================================
# 5. PONTO E VÍRGULA [;]
# ==============================================================================

#O uso de [;] dentro do shellscript serve como um separador de comandos, que permite a execução de múltiplas instruções em uma mesma linha de forma sequencial.
#Ex: [mkdir teste; cd teste; touch teste.txt] vai criar o diretório, depois vai entrar nele e criar um arquivo de texto.

#Também é usado como estrutura de controle em uma linha, como para escrever blocos if, for e while de forma compacta, sem quebras de linha, e para encerramento de blocos [case:], onde é usado o [;;] duplo.


#!/bin/bash

# ==============================================================================
# 6. COMANDO PRINTF (Saída de Dados Formatada)
# ==============================================================================
# O 'printf' exibe textos e variáveis na tela com controle total de formatação. Diferente do 'echo', ele é 100% padronizado em qualquer sistema Linux/Unix.
#
# CARACTERÍSTICAS PRINCIPAIS:
#   - NÃO pula linha automaticamente no final (você deve usar \n).
#   - Separa o "molde do texto" (entre aspas) dos "valores" (variáveis no final).
#   - Se você usar aspas simples no molde ('...'), não precisa escapar cifrões ($).
#
# PRINCIPAIS MARCADORES (Placeholders):
#   - %s   -> Substitui por String (texto)
#   - %d   -> Substitui por Número Inteiro (decimal)
#   - %.2f -> Substitui por Número Decimal (ex: %.2f limita a 2 casas decimais)
#   - \n   -> Quebra de linha (Enter)
#   - \t   -> Tabulação (espaço de Tab)
#
# EXEMPLOS PRÁTICOS (descomentar só as linhas de comando entre as linhas de [-] e executar). Todos os exemplos do printf funcionam tanto no sh quanto no bash:
#
#   - Básico com texto e número: [sh e bash]
#-----------------------------------------------------------
#nome="Ana"; idade=20
#printf "Nome: %s | Idade: %d anos\n" "$nome" "$idade"
#-----------------------------------------------------------
#
#   - Exibindo cifrão literal sem precisar de barra invertida (\): [sh e bash]
#-----------------------------------------------------------
#printf '$1 = %s | $2 = %s\n' "$1" "$2"
#-----------------------------------------------------------
#
#   - Múltiplos valores (devem seguir a ordem exata dos marcadores): [sh e bash]
#-----------------------------------------------------------
#item="Arroz"; qtd=2; valor=10.50
#printf "Produto: %s | Qtd: %d | Preço: R$ %.2f\n" "$item" "$qtd" "$valor"
#-----------------------------------------------------------
#   (Nota: se der erro de número no %.2f, seu sistema usa vírgula como decimal (pt_BR): troque valor=10.50 por valor=10,50)
#
#   - Repetição automática (1 marcador para vários valores repete o molde): [sh e bash]
#-----------------------------------------------------------
#printf "Item: %s\n" "Arroz" "Feijão" "Macarrão"
#-----------------------------------------------------------


# ==============================================================================
# 7. COMANDO READ (Entrada de Dados e Pausas)
# ==============================================================================
# O 'read' pausa a execução do script, lê o que o usuário digita no teclado e armazena o conteúdo dentro de uma ou mais variáveis.
#
# PRINCIPAIS OPÇÕES (Exclusivas do #!/bin/bash):
#   -p "Texto" -> Exibe a mensagem de pergunta na mesma linha antes de ler.
#   -s         -> Modo silencioso (oculta o que é digitado; ideal para senhas).
#   -n X       -> Lê exatamente X caracteres e avança sem precisar apertar Enter.
#   -t X       -> Define um tempo limite (timeout) de X segundos para responder.
#   -r         -> Modo bruto (impede que barras invertidas '\' quebrem o texto).
#
# EXEMPLOS PRÁTICOS (descomentar só as linhas de comando entre as linhas de [-] e executar). Cada exemplo indica se funciona só no bash ou também no sh:
#
#   - Leitura simples com pergunta na mesma linha: [SÓ bash]
#-----------------------------------------------------------
#read -p "Digite seu nome: " usuario
#printf "Olá, %s!\n" "$usuario"
#-----------------------------------------------------------
#{
#   - Leitura de senha (oculta caracteres na tela): [SÓ bash]
#-----------------------------------------------------------
#read -s -p "Digite sua senha: " senha
#echo ""   # Necessário para pular linha após o usuário dar Enter
#printf "Senha recebida com %d caracteres\n" "${#senha}"
#-----------------------------------------------------------
#
#   - Múltiplos valores na mesma pergunta (separados por espaço): [SÓ bash]
#-----------------------------------------------------------
#read -p "Digite nome, idade e cidade: " nome idade cidade
#printf "Nome: %s | Idade: %s | Cidade: %s\n" "$nome" "$idade" "$cidade"
#-----------------------------------------------------------
#   (Nota: se digitar mais palavras que variáveis, a última absorve o resto).
#
#   - Pausa estilo "Pressione qualquer tecla para continuar": [SÓ bash]
#-----------------------------------------------------------
#read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."
#echo ""
#-----------------------------------------------------------
#
#   - Compatibilidade com #!/bin/sh puro (onde -p e -n não existem): [sh e bash]
#-----------------------------------------------------------
#printf "Digite seu nome: "; read usuario
#printf "Pressione ENTER para continuar..."; read dummy
#printf "Olá, %s!\n" "$usuario"
#-----------------------------------------------------------

#================================================================================
#8.ESTRUTURAS CONDICIONAIS (if, elif, else e case)
#================================================================================
#
# o if no shellscript funciona verificando se o comando seguinte a ele executou corretamente e não com uma condição como nas outras linguagens de programação
#ele apenas age assim quando usamos a condição dentro do [ ], basicamente o if executa o comando "test" no comando seguinte a ele e sua ação depende do resultado dele
#if [condição]; then
#	echo '...'
#
#elif [condição]; then
#   echo '...'
#
#else
#   echo '...'
#fi
#
#-----------------------------------------------------------------
##!/bin/bash
#read -p "Digite uma opção (iniciar/parar/status): " opcao
#
#case "$opcao" in
#    iniciar)
#        ;;#
#        echo "Iniciando..."
#        ;;
#    parar|encerrar)
#        echo "Parando..."
#        ;;
#    status)
#        echo "Tudo certo"
#        ;;
#    *)
#        echo "Opção inválida"
#esac
#-------------------------------------------------------------------
#case "$1" in
#    [0-9]*) echo "Começa com número" ;;
#    [a-zA-Z]*) echo "Começa com letra" ;;
#    *) echo "Outro" ;;
#esac
#-------------------------------------------------------------------


