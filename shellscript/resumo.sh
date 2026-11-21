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


# >> 2.1 VARIÁVEIS POR DENTRO
#   - Atribuição NÃO leva espaços nem [$]: [nome=Ana] está certo. [nome = Ana] faz o shell procurar um COMANDO chamado "nome". O [$] só é usado para LER o valor: [echo $nome].
#   - [$nome] e [${nome}] são a mesma coisa. As chaves servem para separar o nome do texto que vem depois: [${nome}_backup] (sem as chaves, o shell procuraria a variável "nome_backup").
#   - Variável não definida e variável vazia expandem para vazio, mas são diferentes: [${x-padrão}] só troca se x não existir; [${x:-padrão}] troca se x não existir OU estiver vazia.
#   - Mais formas: [${x:=padrão}] usa o padrão e também grava em x | [${x:?mensagem}] aborta o script com a mensagem se x estiver vazia | [${#x}] tamanho do valor.
#   - Variável comum só existe no shell atual. [export nome] também a entrega aos programas que esse shell iniciar (são as variáveis de ambiente, como PATH e HOME). Um script nunca altera as variáveis do terminal que o chamou, a não ser que seja executado com [source script.sh] ou [. script.sh].
#   - Constante: [readonly PI=3]. Variáveis prontas úteis: [$HOME] [$USER] [$PWD] [$PATH] [$RANDOM] (bash).
#   - Nomes: letras, números e _, sem começar por número. Convenção: minúsculas para variáveis comuns e MAIÚSCULAS para as exportadas e constantes.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#nome=Ana
#echo "${nome}_backup"
#echo "[${indefinida-padrao}] [${indefinida:-padrao}]"
#vazia=""
#echo "[${vazia-padrao}] [${vazia:-padrao}]"
#echo "tamanho de nome: ${#nome}"
#: ${contador:=10}
#echo "contador: $contador"
#-----------------------------------------------------------
#
#   - Variável comum contra exportada: [sh e bash]
#-----------------------------------------------------------
#local_so_aqui=1; export exportada=2
#sh -c 'echo "local=[$local_so_aqui] exportada=[$exportada]"'
#-----------------------------------------------------------


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


# >> 3.1 PARÂMETROS ESPECIAIS POR DENTRO
#   $0  -> nome do próprio script
#   $#  -> quantidade de parâmetros
#   $?  -> código de saída do último comando (cada comando novo sobrescreve o valor; para guardar use [rc=$?])
#   $$  -> PID (número do processo) do próprio script
#   $!  -> PID do último processo iniciado em segundo plano
#   "$@" -> cada parâmetro SEPARADO, preservando espaços internos: [um "dois tres"] continua sendo 2 palavras. É a forma certa de repassar parâmetros.
#   "$*" -> todos juntos em UMA só palavra, separados pelo primeiro caractere do IFS (normalmente um espaço).
#   $@ e $* SEM aspas -> o shell separa de novo por espaços e quebra os parâmetros que tinham espaço. Evite.
#   shift -> descarta o $1 e "puxa" os outros (o $2 vira $1 e o $# diminui em 1). [shift 2] descarta dois. Usado para processar parâmetros em um laço.
#
#   - Exemplo: [sh e bash | executar: sh script.sh "um dois" tres]
#-----------------------------------------------------------
#echo "script: $0 | total: $#"
#for p in "$@"; do echo "[$p]"; done
#for p in "$*"; do echo "[$p]"; done
#shift; echo "depois do shift: total=$#, \$1=$1"
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


# >> 4.1 COMO O SHELL PROCESSA UMA LINHA (por que as aspas importam)
# Antes de executar um comando, o shell faz estas etapas, nesta ordem:
#   1. Expansão de chaves (bash): {1..3} vira 1 2 3
#   2. Til: ~ vira o caminho da sua pasta pessoal
#   3. Variáveis [$x], substituição de comandos [$(cmd)] e aritmética [$((1+1))]
#   4. Separação de palavras: o resultado SEM ASPAS é cortado em espaços, tabs e quebras de linha (os caracteres do IFS)
#   5. Curingas de arquivo (glob): * ? [abc] viram a lista de arquivos que casam
#   6. Remoção das aspas
# Só depois o comando roda, já recebendo os argumentos prontos. O programa (ex: ls) NUNCA vê os curingas nem as variáveis: quem expande é o shell.
# Por isso [arquivo="meu arquivo.txt"; rm $arquivo] tenta apagar "meu" e "arquivo.txt" (separação de palavras), enquanto [rm "$arquivo"] apaga o arquivo certo.
#   - Aspas duplas impedem as etapas 4 e 5, mas ainda deixam funcionar [$var] [$(cmd)] [$((conta))] [`cmd`] e a barra invertida (para escapar $ " \ e `).
#   - Aspas simples impedem TUDO (etapas 3, 4 e 5): o texto vai literal.
#   - [$'...'] (bash) é uma forma especial que interpreta escapes como \n e \t.
#   - Substituição de comandos [$(cmd)]: roda o comando em um subshell e troca a expressão pelo texto que ele imprimiu, SEM as quebras de linha do final. Pode ser aninhada: [$(echo $(date))].
#
#   - Separação de palavras e aspas: [sh e bash]
#-----------------------------------------------------------
#arquivo="meu arquivo.txt"
#set -- $arquivo; echo "sem aspas: $# palavras"
#set -- "$arquivo"; echo "com aspas: $# palavra"
#echo 'aspas simples: $arquivo $(date)'
#echo "aspas duplas: $arquivo $((2+3))"
#-----------------------------------------------------------
#
#   - Curingas: quem expande é o shell, antes do echo rodar: [sh e bash]
#-----------------------------------------------------------
#touch a.txt b.txt
#echo *.txt
#echo "*.txt"
#rm a.txt b.txt
#-----------------------------------------------------------
#
#   - Escapes com [$'...']: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#echo $'linha1\nlinha2\tcom tab'
#-----------------------------------------------------------


# ==============================================================================
# 5. PONTO E VÍRGULA [;]
# ==============================================================================

#O uso de [;] dentro do shellscript serve como um separador de comandos, que permite a execução de múltiplas instruções em uma mesma linha de forma sequencial.
#Ex: [mkdir teste; cd teste; touch teste.txt] vai criar o diretório, depois vai entrar nele e criar um arquivo de texto.

#Também é usado como estrutura de controle em uma linha, como para escrever blocos if, for e while de forma compacta, sem quebras de linha, e para encerramento de blocos [case:], onde é usado o [;;] duplo.


# >> 5.1 SEPARADORES E OPERADORES ENTRE COMANDOS
#   cmd1 ; cmd2    -> roda um depois do outro, sempre
#   cmd1 && cmd2   -> cmd2 só roda se cmd1 terminar com sucesso (código 0)
#   cmd1 || cmd2   -> cmd2 só roda se cmd1 FALHAR (código diferente de 0)
#   cmd1 | cmd2    -> a saída do cmd1 vira a entrada do cmd2 (os dois rodam ao mesmo tempo)
#   cmd &          -> roda em segundo plano e devolve o terminal na hora
#   ( cmds )       -> roda em um subshell (uma cópia do shell): mudanças de variáveis e [cd] ali dentro NÃO afetam o shell original
#   { cmds; }      -> agrupa comandos no shell atual (precisa de espaço depois do { e de um ; antes do })
#   Cuidado: [A && B || C] NÃO é um if/else. Se A der certo mas B falhar, o C roda também.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#true && echo "A: o && rodou"; false && echo "nunca aparece"
#false || echo "B: o || rodou"
#true && false || echo "C: roda mesmo com A certo, porque B falhou"
#(cd /tmp; echo "dentro do subshell: $PWD"); echo "fora do subshell: $PWD"
#{ echo "grupo 1"; echo "grupo 2"; }
#-----------------------------------------------------------


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


# >> 6.1 PRINTF POR DENTRO
#   - Formato completo de um marcador: [%[flags][largura][.precisão]tipo]. Ex: [%-10s] texto em 10 colunas alinhado à esquerda | [%5d] inteiro em 5 colunas | [%05d] completa com zeros | [%+d] mostra o sinal | [%8.2f] decimal em 8 colunas com 2 casas | [%x] hexadecimal | [%o] octal | [%c] primeiro caractere | [%%] mostra um % literal.
#   - O molde é REAPROVEITADO enquanto sobrarem argumentos. Se faltar argumento, %s vira vazio e %d vira 0.
#   - As barras ([\n] [\t] [\\]) são interpretadas SÓ no molde. Nos argumentos elas ficam literais; para interpretá-las use o marcador [%b].
#   - Nunca coloque uma variável no lugar do molde ([printf "$var"]): se ela tiver % ou \ o printf se confunde. Use [printf '%s\n' "$var"].
#   - [%d] com valor que não é inteiro (ex: 2.5 ou abc) mostra erro e o código de saída fica diferente de 0. Para decimais use [%f]. (No pt_BR o printf do bash lê o decimal com vírgula: 2,5.)
#   - Para guardar o resultado em uma variável: [printf -v var "formato" args] (bash) ou [var=$(printf "formato" args)] (qualquer shell).
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#printf "[%-10s]\n" "Ana"
#printf "[%5d] [%05d] [%+d]\n" 42 42 42
#printf "%s tem %d anos\n" "Ana" 20 "Bia" 30
#printf "%s e %s\n" "só um"
#printf "%d%%\n" 50
#printf "%s\n" 'barra n literal: \n'
#printf "%b\n" 'barra n interpretada:\nnova linha'
#-----------------------------------------------------------
#
#   - Guardar em variável: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#printf -v texto "%05d" 7; echo "$texto"
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
#
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

# >> 7.1 READ POR DENTRO
#   - O read lê UMA linha da entrada padrão (até o Enter), corta em palavras usando o IFS (por padrão espaço e tab) e coloca cada palavra em uma variável. A última variável recebe o RESTO da linha.
#   - Sem nome de variável, o texto vai para a variável [REPLY] (bash).
#   - Código de saída: 0 se leu uma linha e 1 se chegou ao fim da entrada (EOF, ou Ctrl+D). Por isso [while read linha] termina sozinho no fim de um arquivo.
#   - Sem [-r], a barra invertida é interpretada (uma \ no fim da linha junta com a próxima). Use sempre [read -r].
#   - O read remove os espaços do começo e do fim. Para manter use [IFS= read -r linha].
#   - [IFS=: read -r a b c] muda o separador só para esse comando. Ex: ler os campos do /etc/passwd, separados por [:].
#   - O read lê de onde a entrada padrão estiver apontando: teclado, [< arquivo] ou pipe. Atenção: [echo "a b" | read x y] roda o read em um subshell (veja a seção 9.0) e x e y ficam vazios depois. Use here string no bash ([read x y <<< "a b"]) ou here document.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#echo "Ana 20 Recife PE" | { read -r nome idade resto; echo "nome=$nome idade=$idade resto=$resto"; }
#IFS=: read -r usuario x uid resto <<EOF
#root:x:0:0:root:/root:/bin/bash
#EOF
#echo "usuario=$usuario uid=$uid"
#-----------------------------------------------------------


# ==============================================================================
# 8. ESTRUTURAS CONDICIONAIS (if, elif, else e case)
# ==============================================================================

#o if no shellscript funciona verificando se o comando seguinte a ele executou corretamente e não com uma condição como nas outras linguagens de programação
#ele apenas age assim quando usamos a condição dentro do [ ], basicamente o if executa o comando "test" no comando seguinte a ele e sua ação depende do resultado dele
#
#if [condição]; then
#    echo '...'
#elif [condição]; then
#    echo '...'
#else
#    echo '...'
#fi
#
#CÓDIGO DE SAÍDA: todo comando devolve um número ao terminar, guardado em [$?]. O valor [0] significa sucesso (verdadeiro para o if) e qualquer outro valor significa falha (falso). Por isso o if também funciona direto com comandos, sem os [ ]. Ex: [if grep -q "erro" log.txt; then echo "achou"; fi]
#ATENÇÃO: os [ ] precisam de espaço depois do [ e antes do ]. Ex: [ "$a" -eq 1 ] está certo, ["$a"-eq 1] dá erro. Também coloque as variáveis entre aspas.


# >> 8.0 COMO O IF FUNCIONA POR DENTRO
#   - O if NÃO avalia "condições" como nas outras linguagens. Ele executa um COMANDO e olha o código de saída dele: [0] = sucesso = executa o then | qualquer outro número = falha = vai para o próximo elif/else.
#   - Por isso qualquer comando serve de condição: [if grep -q root /etc/passwd; then ...], [if mkdir pasta; then ...], [if ping -c 1 8.8.8.8; then ...]. Os colchetes NÃO fazem parte da sintaxe do if.
#   - O [ (abre-colchete) é um comando de verdade: existe como programa (/usr/bin/[) e também como comando interno do shell. Ele é o mesmo que o comando [test]: [ -f arq ] e [test -f arq] fazem exatamente a mesma coisa. A única diferença é que o [ exige o ] como último argumento, só por estética.
#   - Isso explica a regra dos espaços: [ é um comando e precisa ser separado dos argumentos, como em [ls -l]. Em [ "$a" -eq 1 ] o shell chama o comando [ passando 4 argumentos: o valor de $a, -eq, 1 e ]. Escrito sem espaços, o shell procuraria um comando de nome estranho e daria "command not found".
#   - O test não imprime nada: ele só devolve o código de saída. 0 = a expressão é verdadeira, 1 = é falsa, 2 = erro de uso (ex: -eq com texto dá "integer expression expected"). No if, os códigos 1 e 2 caem no else.
#   - Como é um comando comum, o shell expande as variáveis ANTES de chamá-lo. Se a variável estiver vazia e sem aspas, o argumento some: [ $nome = Ana ] vira [ = Ana ] e dá erro. Com aspas ([ "$nome" = "Ana" ]) o argumento vazio é mantido.
#   - Regra do test com poucos argumentos: com 1 argumento só, o resultado é verdadeiro se ele não for vazio. Por isso [ -n $x ] com x vazio vira [ -n ] e dá VERDADEIRO (testa se a palavra "-n" não é vazia). Sempre use aspas: [ -n "$x" ].
#   - Dentro de [ ], os símbolos [<] e [>] são redirecionamento do shell, não comparação. Para números use -lt e -gt. Comparar ordem alfabética só funciona direito no [[ ]].
#   - O [[ ]] é diferente: é uma palavra-chave do bash, lida pelo próprio shell (não é um comando). Por isso ele não faz separação de palavras nem glob nas variáveis (as aspas ficam quase opcionais), aceita [&&] [||] [<] [>] direto, [==] com curingas e [=~] com expressão regular.
#   - O [(( ))] (bash) também é do shell: faz aritmética e devolve código 0 se o resultado for diferente de zero e 1 se for zero. Já o [$(( ))] devolve o VALOR da conta, para ser usado dentro de outro comando.
#   - [!] antes de um comando inverte o código de saída: [if ! grep -q x arq; then ...] roda o then quando o grep NÃO achar.
#   - Depois do if/elif/else, o código de saída é o do último comando que rodou dentro do bloco (ou 0 se nenhum bloco rodou).
#
#   - O if executa comandos e olha o código de saída: [sh e bash]
#-----------------------------------------------------------
#[ -f /etc/passwd ]; echo "código de [ -f /etc/passwd ]: $?"
#[ -f /arquivo/inexistente ]; echo "código quando é falso: $?"
#[ 1 -eq abc ] 2>/dev/null; echo "código quando há erro de uso: $?"
#test -d /etc && echo "test e [ são o mesmo comando"
#vazio=""
#[ -n $vazio ] && echo "SEM aspas: [ -n ] deu verdadeiro (armadilha!)"
#[ -n "$vazio" ] || echo "COM aspas: deu falso, como esperado"
#if grep -q root /etc/passwd; then echo "if com comando, sem colchetes"; fi
#if ! grep -q naoexiste /etc/passwd; then echo "if ! inverte o resultado"; fi
#type [ test
#-----------------------------------------------------------
#
#   - Aritmética do bash e código de saída: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#(( 5 > 3 )); echo "(( 5 > 3 )) -> código $?"
#(( 2 > 3 )); echo "(( 2 > 3 )) -> código $?"
#(( x = 3 + 4 )); echo "x=$x"
#-----------------------------------------------------------
# >> 8.1 COMPARAR NÚMEROS
#   -eq -> igual
#   -ne -> diferente
#   -gt -> maior que
#   -ge -> maior ou igual
#   -lt -> menor que
#   -le -> menor ou igual
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#idade=20
#if [ "$idade" -ge 18 ]; then echo "Maior de idade"; else echo "Menor de idade"; fi
#-----------------------------------------------------------
#
#   - No bash também existe o [(( ))], que usa os sinais normais (>=, <, ==): [SÓ bash]
#-----------------------------------------------------------
#idade=20
#if (( idade >= 18 )); then echo "Maior de idade"; fi
#-----------------------------------------------------------


# >> 8.2 COMPARAR TEXTOS
#   =  -> igual
#   != -> diferente
#   -z -> vazio
#   -n -> não vazio
#   (Use [=] com texto e [-eq] com número. Misturar os dois é um erro comum.)
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#nome="Ana"; vazio=""
#if [ "$nome" = "Ana" ]; then echo "Oi, Ana"; fi
#if [ -z "$vazio" ]; then echo "Variável vazia"; fi
#if [ -n "$nome" ]; then echo "Variável com conteúdo"; fi
#-----------------------------------------------------------


# >> 8.3 TESTAR ARQUIVOS E PASTAS
#   -e -> existe
#   -f -> é um arquivo comum
#   -d -> é um diretório
#   -r -> tem permissão de leitura
#   -w -> tem permissão de escrita
#   -x -> tem permissão de execução
#   -s -> existe e não está vazio
#
#   - Exemplo (passar um caminho como parâmetro): [sh e bash | executar: sh script.sh /etc]
#-----------------------------------------------------------
#if [ -d "$1" ]; then echo "$1 é uma pasta"; elif [ -f "$1" ]; then echo "$1 é um arquivo"; else echo "$1 não existe"; fi
#-----------------------------------------------------------


# >> 8.4 COMBINAR CONDIÇÕES
#   !  -> NÃO (inverte a condição)
#   && -> E (as duas precisam ser verdadeiras)
#   || -> OU (basta uma ser verdadeira)
#   (Dentro dos [ ] também existem [-a] e [-o], mas são considerados obsoletos. Prefira usar [ ] && [ ].)
#   (Atalhos sem if: [comando1 && comando2] executa o 2º só se o 1º der certo, e [comando1 || comando2] executa o 2º só se o 1º der errado.)
#
#   - Exemplo: [sh e bash | executar: sh script.sh /etc]
#-----------------------------------------------------------
#idade=30
#if [ "$idade" -ge 18 ] && [ "$idade" -lt 60 ]; then echo "Adulto"; fi
#if [ ! -f "$1" ]; then echo "$1 não é um arquivo"; fi
#[ -d "$1" ] && echo "É uma pasta"
#[ -d "$1" ] || echo "Não é uma pasta"
#-----------------------------------------------------------


# >> 8.5 [ ] OU [[ ]]?
#   [ ]  -> funciona em sh e bash. Obriga o uso de aspas nas variáveis. Não aceita [&&] e [||] dentro dele.
#   [[ ]] -> SÓ bash. Aceita [&&] e [||] dentro, comparação com padrão ([==] com curingas) e expressão regular ([=~]).
#
#   - Exemplo: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#arq="texto.txt"; x=123
#if [[ "$arq" == *.txt ]]; then echo "É um arquivo de texto"; fi
#if [[ "$x" =~ ^[0-9]+$ ]]; then echo "É um número"; fi
#if [[ "$x" -gt 100 && "$arq" != "" ]]; then echo "Duas condições dentro do mesmo [[ ]]"; fi
#-----------------------------------------------------------


# >> 8.6 ERROS COMUNS NO IF
#   - Esquecer as aspas: [ $nome = "Ana" ] quebra se a variável estiver vazia. Use [ "$nome" = "Ana" ].
#   - Esquecer o espaço depois do [ e antes do ].
#   - Usar [=] para número ou [-eq] para texto.
#   - Esquecer o [then] ou o [fi].
#   - Usar [[ ]] em script [#!/bin/sh]: pode dar erro no dash.


# >> 8.7 CASE

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

#o case compara uma variável com vários padrões e é mais limpo que vários elif.
#   - cada bloco termina com [;;] e o case termina com [esac] (case ao contrário)
#   - [a|b] significa "a ou b"
#   - [*] casa com qualquer coisa. Fica por último e funciona como o else
#   - aceita curingas: [?] um caractere qualquer, [*] qualquer sequência, [0-9] um dígito, [a-z] uma letra minúscula
#
#   - Exemplo: [sh e bash | executar: sh script.sh]
#-----------------------------------------------------------
#printf "Digite iniciar, parar ou status: "; read opcao
#case "$opcao" in
#    iniciar) echo "Iniciando..." ;;
#    parar|encerrar) echo "Parando..." ;;
#    status) echo "Tudo certo" ;;
#    *) echo "Opção inválida" ;;
#esac
#-----------------------------------------------------------


# ==============================================================================
# 9. ESTRUTURAS DE REPETIÇÃO (for, while, until, break, continue e seq)
# ==============================================================================
# Qual usar?
#   - for   -> quando você tem uma lista ou sabe quantas vezes repetir
#   - while -> repete ENQUANTO a condição for verdadeira
#   - until -> repete ATÉ a condição ficar verdadeira (é o oposto do while)
# Todos terminam com [done] e têm o [do] antes dos comandos.


# >> 9.0 COMO OS LAÇOS FUNCIONAM POR DENTRO
#   FOR
#   - [for x in lista] primeiro EXPANDE a lista (variáveis, [$(cmd)], curingas, separação de palavras) e só então percorre as palavras resultantes, uma por volta, guardando cada uma em x. Quem manda na separação é o IFS (espaço, tab e quebra de linha).
#   - [for x in $(seq 1 3)]: o seq imprime 1, 2 e 3 em linhas diferentes, o shell captura a saída e a separa em 3 palavras.
#   - [for arq in *.txt]: o shell troca *.txt pela lista de arquivos ANTES do laço começar. Se não existir nenhum arquivo, o padrão não é trocado e x recebe o texto literal "*.txt". Por isso é comum testar [ -e "$arq" ] dentro do laço.
#   - [for x in $(cat arquivo)] ou [$(ls)] separam por QUALQUER espaço, então nomes e linhas com espaço se quebram. Para ler linhas use [while read -r].
#   - Sem o [in lista], o for percorre "$@" (os parâmetros do script).
#   - Depois do laço a variável continua valendo o último item. O código de saída do for é o do último comando executado dentro dele.
#   - O for estilo C [for ((i=0; i<3; i++))] é do bash: o shell avalia a 1ª expressão uma vez, testa a 2ª antes de cada volta e roda a 3ª no fim de cada volta.
#   WHILE E UNTIL
#   - [while COMANDO; do ...] roda o COMANDO a cada volta e olha o código de saída (a mesma lógica do if): 0 -> repete, diferente de 0 -> termina. O [until] é o inverso: repete enquanto o comando FALHAR.
#   - Qualquer comando serve: [while [ "$i" -le 5 ]] (usa o test), [while read -r linha] (termina no fim do arquivo), [while ! ping -c 1 host] (espera o host subir), [while true] (infinito, o true sempre devolve 0).
#   - [while read -r linha; do ...; done < arquivo]: o redirecionamento vale para o laço inteiro, e o read pega a próxima linha a cada volta. Se a última linha do arquivo não terminar com Enter, o read devolve 1 mesmo tendo lido o texto; para não perdê-la use [while read -r linha || [ -n "$linha" ]; do].
#   - ARMADILHA DO PIPE: [cmd | while read ...] roda o laço em um SUBSHELL (cópia do shell). Variáveis alteradas lá dentro somem quando o laço termina. Prefira [done < arquivo] ou, no bash, [done < <(cmd)].
#   - Comandos dentro do laço que também leem a entrada padrão (ssh, cat, read...) "roubam" as linhas do arquivo que o while está lendo. Para evitar use [ssh -n] ou [comando < /dev/null].
#   BREAK E CONTINUE
#   - [break] sai do laço mais interno, [break 2] sai de dois níveis. [continue] pula o resto da volta atual e vai para a próxima avaliação da condição (no while) ou para o próximo item (no for).
#
#   - Armadilha do pipe com while: [sh e bash]
#-----------------------------------------------------------
#contador=0
#printf "a\nb\nc\n" | while read -r l; do contador=$((contador+1)); done
#echo "com pipe: contador=$contador (continua 0, o laço rodou em subshell)"
#printf "a\nb\nc\n" > teste.txt
#while read -r l; do contador=$((contador+1)); done < teste.txt
#echo "com redirecionamento: contador=$contador"
#rm teste.txt
#-----------------------------------------------------------
#
#   - Curinga sem arquivos e separação de palavras no for: [sh e bash]
#-----------------------------------------------------------
#for arq in *.naoexiste; do echo "recebeu: $arq"; [ -e "$arq" ] || echo "(esse arquivo não existe de verdade)"; done
#for x in $(printf "a b\nc\n"); do echo "[$x]"; done
#-----------------------------------------------------------
#
#   - Última linha sem Enter: [sh e bash]
#-----------------------------------------------------------
#printf "um\ndois" > t.txt
#while read -r l; do echo "sem tratar: $l"; done < t.txt
#while read -r l || [ -n "$l" ]; do echo "tratando: $l"; done < t.txt
#rm t.txt
#-----------------------------------------------------------
#
#   - O while olha o código de saída de QUALQUER comando: [sh e bash]
#-----------------------------------------------------------
#n=3
#while [ "$n" -gt 0 ]; do echo "n=$n"; n=$((n-1)); done
#echo "fim: n=$n"
#until grep -q root /etc/passwd; do echo "nunca roda"; done; echo "until: a condição já era verdadeira, nem rodou"
#-----------------------------------------------------------
# >> 9.1 FOR (percorre uma lista)
#   Estrutura: [for variavel in lista; do comandos; done]
#
#   - Lista de valores: [sh e bash]
#-----------------------------------------------------------
#for nome in Ana Bruno Carla; do echo "Olá, $nome"; done
#-----------------------------------------------------------
#
#   - Parâmetros e arquivos ([$@] são todos os parâmetros, use sempre entre aspas): [sh e bash | executar: sh script.sh a b c]
#-----------------------------------------------------------
#for p in "$@"; do echo "Parâmetro: $p"; done
#for arq in *.sh; do echo "Arquivo: $arq"; done
#-----------------------------------------------------------
#
#   - Estilo C (contador): [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#for ((i=1; i<=5; i++)); do echo "$i"; done
#-----------------------------------------------------------


# >> 9.2 WHILE (repete enquanto a condição for verdadeira)
#   Estrutura: [while [ condição ]; do comandos; done]
#   Se esquecer de alterar a variável da condição, vira loop infinito (pare com Ctrl+C).
#
#   - Contador: [sh e bash]
#-----------------------------------------------------------
#i=1
#while [ "$i" -le 5 ]; do echo "$i"; i=$((i + 1)); done
#-----------------------------------------------------------
#
#   - Ler um arquivo linha por linha (uso muito comum): [sh e bash]
#-----------------------------------------------------------
#printf "linha1\nlinha2\nlinha3\n" > teste.txt
#while read -r linha; do echo "Linha: $linha"; done < teste.txt
#rm teste.txt
#-----------------------------------------------------------
#
#   - Loop infinito proposital, com [break] para sair: [sh e bash | executar: sh script.sh]
#-----------------------------------------------------------
#while true; do printf "Digite sair: "; read x || break; [ "$x" = "sair" ] && break; done
#-----------------------------------------------------------


# >> 9.3 UNTIL (repete até a condição ficar verdadeira)
#   Estrutura: [until [ condição ]; do comandos; done]
#
#   - Exemplo: [sh e bash | executar: sh script.sh]
#-----------------------------------------------------------
#until [ "$senha" = "1234" ]; do printf "Senha (é 1234): "; read senha || break; done
#echo "Fim do until"
#-----------------------------------------------------------


# >> 9.4 BREAK E CONTINUE
#   break    -> sai do laço
#   continue -> pula para a próxima volta
#   break 2  -> sai de 2 laços aninhados
#
#   - Exemplo (mostra 1 2 4): [sh e bash]
#-----------------------------------------------------------
#for i in 1 2 3 4 5 6; do [ "$i" -eq 3 ] && continue; [ "$i" -eq 5 ] && break; echo "$i"; done
#-----------------------------------------------------------


# >> 9.5 SEQ (gera sequências de números)
#   seq 5          -> 1 2 3 4 5
#   seq 3 7        -> 3 4 5 6 7
#   seq 0 5 20     -> 0 5 10 15 20 (início, passo, fim)
#   seq 5 -1 1     -> 5 4 3 2 1 (contagem regressiva)
#   seq -w 1 10    -> 01 02 ... 10 (completa com zeros)
#   seq -s, 1 5    -> 1,2,3,4,5 (troca o separador)
#   seq 0 0.5 2    -> aceita decimais (no pt_BR pode mostrar vírgula; use [LC_NUMERIC=C seq 0 0.5 2])
#   O seq funciona em qualquer shell e aceita variáveis. Já o [{1..10}] é SÓ bash e NÃO aceita variáveis ({1..$n} não funciona).
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#seq 5
#seq 0 5 20
#seq 5 -1 1
#seq -w 1 5
#seq -s, 1 5
#n=4
#for i in $(seq 1 "$n"); do echo "Número $i"; done
#-----------------------------------------------------------
#
#   - Com chaves: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#for i in {1..5}; do echo "$i"; done
#-----------------------------------------------------------


# >> 9.6 LAÇOS ANINHADOS, CONTADOR E ACUMULADOR
#   - Laço dentro de laço e soma acumulada: [sh e bash]
#-----------------------------------------------------------
#for i in 1 2 3; do for j in 1 2 3; do echo "$i x $j = $((i * j))"; done; done
#soma=0
#for n in $(seq 1 10); do soma=$((soma + n)); done
#echo "Soma de 1 a 10: $soma"
#-----------------------------------------------------------


# >> 9.7 ERROS COMUNS NAS REPETIÇÕES
#   - Esquecer o [do] ou o [done].
#   - Esquecer de atualizar a variável do while e criar loop infinito.
#   - Usar [{1..$n}]: não funciona, use [seq 1 "$n"].
#   - Usar [for ((...))] ou [{1..10}] em script [#!/bin/sh]: só funcionam no bash.
#   - Esquecer as aspas em ["$@"] e quebrar nomes com espaço.
#   - Usar [for linha in $(cat arquivo)]: quebra a linha a cada espaço. Para ler linhas use [while read -r].



# ==============================================================================
# 10. FUNÇÕES
# ==============================================================================
# Uma função é um bloco de comandos com nome, executado NO PRÓPRIO shell (não cria um processo novo).
#   nome() { comandos; }          ou          function nome { comandos; }   (a 2ª forma é do bash)
#
# COMO FUNCIONA POR DENTRO:
#   - Precisa ser DEFINIDA antes de ser chamada (o shell lê o script de cima para baixo). Depois de definida, é chamada como um comando comum: [nome arg1 arg2].
#   - Dentro dela, [$1] [$2] [$#] e ["$@"] são os argumentos DA FUNÇÃO (os do script ficam escondidos até ela terminar). O [$0] continua sendo o nome do script.
#   - Variáveis são GLOBAIS por padrão: se a função altera uma variável, o resto do script vê a mudança. [local x] cria x só dentro da função (não é POSIX estrito, mas funciona em bash e dash).
#   - [return N] (de 0 a 255) só devolve um CÓDIGO DE SAÍDA, igual ao de um comando, para ser usado em if, && e ||. Sem return, vale o código do último comando executado.
#   - Para devolver um TEXTO ou número, a função imprime com echo/printf e quem chama captura com [$(funcao args)]. A captura roda em um subshell, então variáveis alteradas dentro da função NÃO voltam.
#   - [exit] dentro de uma função encerra o script inteiro, não só a função.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#soma() { echo $(( $1 + $2 )); }
#resultado=$(soma 3 4); echo "3 + 4 = $resultado"
#
#eh_par() { [ $(( $1 % 2 )) -eq 0 ]; }
#if eh_par 10; then echo "10 é par"; fi
#eh_par 7 || echo "7 é ímpar"
#
#x=global
#teste() { local x=local; echo "dentro: $x"; }
#teste; echo "fora: $x"
#
#cumprimentar() { echo "Olá, $1! Você passou $# parâmetro(s)."; }
#cumprimentar Ana
#-----------------------------------------------------------


# ==============================================================================
# 11. ARRAYS (só bash)
# ==============================================================================
#   frutas=(maçã banana "uva verde")    cria um array com 3 itens (as aspas mantêm o espaço)
#   ${frutas[0]}   primeiro item (os índices começam em 0)   |   ${frutas[-1]}   último item (bash 4.3+)
#   "${frutas[@]}" TODOS os itens, cada um como uma palavra   |   ${#frutas[@]}   quantidade de itens
#   ${!frutas[@]}  lista dos índices                          |   frutas+=(kiwi)   acrescenta um item
#   unset 'frutas[1]'   remove um item                        |   ${frutas[@]:1:2}   fatia (a partir do índice 1, 2 itens)
#   - Sem as chaves, [$frutas] mostra só o 1º item. No for, use sempre "${frutas[@]}" entre aspas.
#   - Arrays associativos (chave e valor, bash 4+): [declare -A idade], [idade[Ana]=20], [${idade[Ana]}], [${!idade[@]}] (lista as chaves, em ordem não garantida).
#   - O sh (dash) NÃO tem arrays. Alternativa: [set -- a b c] e usar os parâmetros posicionais ($1, $2, "$@").
#
#   - Exemplo: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#frutas=(maçã banana "uva verde")
#echo "primeiro: ${frutas[0]} | último: ${frutas[-1]} | total: ${#frutas[@]}"
#frutas+=(kiwi)
#for f in "${frutas[@]}"; do echo "- $f"; done
#echo "índices: ${!frutas[@]}"
#echo "fatia: ${frutas[@]:1:2}"
#declare -A idade=([Ana]=20 [Bia]=30)
#idade[Caio]=25
#for nome in "${!idade[@]}"; do echo "$nome tem ${idade[$nome]} anos"; done
#-----------------------------------------------------------


# ==============================================================================
# 12. MANIPULAÇÃO DE TEXTO EM VARIÁVEIS (expansão de parâmetros)
# ==============================================================================
#   ${#var}            tamanho do texto
#   ${var:2}           a partir da posição 2   |   ${var:2:3}   3 caracteres a partir da posição 2 (bash)
#   ${var#padrão}      remove do COMEÇO o MENOR trecho que casa com o padrão   |   ${var##padrão}   remove o MAIOR trecho (POSIX)
#   ${var%padrão}      remove do FIM o MENOR trecho que casa                    |   ${var%%padrão}   remove o MAIOR trecho (POSIX)
#   ${var/a/b}         troca a 1ª ocorrência   |   ${var//a/b}   troca todas (bash)
#   ${var^^}           MAIÚSCULAS   |   ${var,,}   minúsculas (bash 4+)
#   - Os padrões usam curingas ( * ? [ ] ), NÃO expressões regulares.
#   - Comandos úteis para caminhos: [basename caminho .ext] (só o nome) e [dirname caminho] (só a pasta).
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#arq="/home/ana/relatorio.final.txt"
#echo "nome:       ${arq##*/}"
#echo "pasta:      ${arq%/*}"
#echo "extensão:   ${arq##*.}"
#echo "sem a ext.: ${arq%.*}"
#echo "tamanho:    ${#arq}"
#echo "basename:   $(basename "$arq" .txt)  | dirname: $(dirname "$arq")"
#-----------------------------------------------------------
#
#   - Troca e maiúsculas: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#frase="um dois tres"
#echo "${frase/dois/2} | ${frase// /_} | ${frase^^} | ${frase:3:4}"
#-----------------------------------------------------------


# ==============================================================================
# 13. REDIRECIONAMENTO, PIPES E HERE DOCUMENTS
# ==============================================================================
# Todo programa tem 3 canais: 0 = stdin (entrada), 1 = stdout (saída normal) e 2 = stderr (erros). Por padrão os três apontam para o terminal.
#   cmd > arq         grava o stdout em arq (APAGA o conteúdo anterior)   |   cmd >> arq   acrescenta ao final   |   cmd < arq   usa arq como stdin
#   cmd 2> arq        grava só os erros   |   cmd 2>> arq   acrescenta os erros
#   cmd > arq 2>&1    stdout E stderr no mesmo arquivo. A ORDEM importa: [2>&1] significa "mande o 2 para onde o 1 aponta AGORA". Por isso [cmd 2>&1 > arq] não faz o que parece (os erros vão para o terminal). No bash existe o atalho [cmd &> arq].
#   cmd > /dev/null   descarta a saída   |   cmd 2>/dev/null   descarta só os erros
#   cmd1 | cmd2       pipe: o stdout do cmd1 vira o stdin do cmd2. Os dois rodam ao mesmo tempo, cada um em seu processo. Só o stdout passa pelo pipe; o stderr continua indo ao terminal (use [2>&1 |] para passar também).
#   Código de saída de um pipe = o do ÚLTIMO comando. Com [set -o pipefail] (bash) passa a ser o do primeiro que falhar.
#   cmd | tee arq     mostra na tela E grava em arq ([tee -a] acrescenta)
#   >&2               manda uma mensagem para o stderr: [echo "erro" >&2]. É a forma certa de mostrar erros em scripts.
#   HERE DOCUMENT     [cmd <<EOF ... EOF] envia o bloco de texto como stdin. Com [<<'EOF'] (aspas no marcador) nada é expandido; sem aspas as variáveis e [$(...)] são expandidas. [<<-EOF] ignora tabs no começo das linhas.
#   HERE STRING       (bash) [cmd <<< "texto"] envia o texto como stdin.
#   O shell resolve os redirecionamentos ANTES de rodar o comando: [> arq] cria/zera o arquivo mesmo que o comando falhe, e [sort arq > arq] apaga o arquivo antes de o sort conseguir lê-lo.
#
#   - Redirecionamento de saída e de erros: [sh e bash]
#-----------------------------------------------------------
#echo "linha 1" > saida.txt
#echo "linha 2" >> saida.txt
#cat saida.txt
#ls /pasta_inexistente 2> erros.txt; echo "código: $?"; cat erros.txt
#ls /pasta_inexistente > tudo.txt 2>&1; echo "tudo.txt: $(cat tudo.txt)"
#echo "mensagem de erro" >&2
#printf "b\na\n" > x.txt; sort x.txt > x.txt; echo "tamanho depois do sort > x.txt: $(wc -c < x.txt) bytes (foi apagado antes do sort ler)"
#rm saida.txt erros.txt tudo.txt x.txt
#-----------------------------------------------------------
#
#   - Pipe, tee e código de saída: [sh e bash]
#-----------------------------------------------------------
#printf "b\na\nc\n" | sort | tee ordenado.txt
#cat ordenado.txt; rm ordenado.txt
#false | true; echo "código do pipe (vale o do último comando): $?"
#-----------------------------------------------------------
#
#   - Here document: [sh e bash]
#-----------------------------------------------------------
#nome=Ana
#cat <<EOF
#Olá, $nome! Isto foi expandido pelo shell.
#EOF
#cat <<'EOF'
#Aqui nada expande: $nome $(date)
#EOF
#-----------------------------------------------------------
#
#   - Pipefail e here string: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#set -o pipefail; false | true; echo "com pipefail o código do pipe é: $?"
#read -r a b <<< "um dois"; echo "a=$a b=$b"
#-----------------------------------------------------------


# ==============================================================================
# 14. FERRAMENTAS DE TEXTO (grep, sed, awk, cut, sort, uniq, tr, wc, head, tail, find, xargs)
# ==============================================================================
# Todas seguem a ideia do shell: lêem do stdin (ou de arquivos), escrevem no stdout, e podem ser ligadas por pipes.
#
#   grep padrão arq   -> mostra as linhas que contêm o padrão. Código de saída: 0 achou, 1 NÃO achou, 2 erro.
#       -i ignora maiúsculas | -v inverte (linhas que NÃO casam) | -n mostra o nº da linha | -c só conta | -r recursivo em pastas | -l só os nomes dos arquivos
#       -w palavra inteira | -o só o trecho que casou | -q silencioso (só o código de saída, ideal no if) | -E regex estendida (permite + ? | e parênteses)
#       -A 2 / -B 2 / -C 2 mostram linhas depois / antes / ao redor da que casou
#       Regex básica: [.] qualquer caractere | [*] zero ou mais do anterior | [^] começo da linha | [$] fim da linha | [[0-9]] um dígito | [a|b] (com -E) a ou b
#
#   sed 's/velho/novo/g' arq -> editor de fluxo: lê linha por linha e aplica comandos. O [s] troca (sem o [g] troca só a 1ª ocorrência de cada linha).
#       [sed -n '2,4p' arq] mostra só as linhas 2 a 4 | [sed '/padrão/d' arq] apaga as linhas que casam | [sed -E ...] regex estendida
#       O sed NÃO altera o arquivo, só imprime o resultado. Para alterar o arquivo use [-i] (GNU) e, por segurança, [-i.bak] que guarda uma cópia.
#
#   awk 'padrão {ação}' arq -> processa linha por linha, já dividindo em campos: [$1] [$2]... ([$0] é a linha toda). [NF] = nº de campos, [NR] = nº da linha atual.
#       [-F,] define o separador (vírgula). [BEGIN {...}] roda antes da 1ª linha e [END {...}] depois da última (ótimo para somas e médias).
#       Ex: [awk -F, '$2 > 7 {print $1}' arq] imprime o 1º campo das linhas cujo 2º campo é maior que 7.
#
#   cut -d, -f1,3 arq -> recorta colunas por delimitador (-d) e campos (-f) | [cut -c1-5] recorta por posição de caracteres
#   sort -> ordena as linhas | -n numérico | -r inverso | -u remove repetidas | -t, define o separador | -k2 ordena pela coluna 2
#   uniq -> remove linhas repetidas SEGUIDAS (por isso quase sempre vem depois de sort) | -c conta as repetições | -d mostra só as repetidas
#   tr a-z A-Z -> troca caracteres (lê só do stdin) | -d apaga os caracteres | -s comprime repetições (ex: [tr -s " "] vira um espaço só)
#   wc -l / -w / -c -> conta linhas / palavras / bytes   |   head -n 5 / tail -n 5 -> primeiras / últimas linhas   |   tail -n +2 pula o cabeçalho   |   tail -f acompanha um arquivo crescendo (logs)
#
#   find pasta -name "*.txt" -type f -mtime +7 -size +1M -> procura arquivos (por nome, tipo f=arquivo d=pasta, idade em dias, tamanho). Ação: [-exec cmd {} \;] roda cmd para cada arquivo achado ([{}] é o nome) e [-delete] apaga.
#   xargs -> transforma linhas do stdin em ARGUMENTOS de outro comando. [-n1] um argumento por execução | [-I{}] posiciona o argumento. Para nomes com espaço use [find ... -print0 | xargs -0 cmd].
#
#   - Exemplo com um CSV de notas: [sh e bash]
#-----------------------------------------------------------
#printf "nome,nota\nAna,8\nBia,6\nCaio,9\nAna,7\n" > notas.csv
#echo "--- grep -c (conta) e -v (inverte):"; grep -c "Ana" notas.csv; grep -v "nome" notas.csv
#echo "--- cut, sort e uniq -c (quantas vezes cada nome):"; cut -d, -f1 notas.csv | tail -n +2 | sort | uniq -c
#echo "--- sort numérico inverso pela 2ª coluna:"; tail -n +2 notas.csv | sort -t, -k2 -nr
#echo "--- awk: média e nomes com nota > 7:"
#awk -F, 'NR>1 {soma+=$2; n++} END {printf "média = %.2f\n", soma/n}' notas.csv
#awk -F, 'NR>1 && $2>7 {print $1}' notas.csv
#echo "--- sed:"; sed 's/Ana/Aninha/g' notas.csv | head -n 2; sed -n '2,3p' notas.csv; sed '/nome/d' notas.csv | wc -l
#echo "--- tr e wc:"; echo "ola mundo" | tr a-z A-Z; wc -l < notas.csv
#rm notas.csv
#-----------------------------------------------------------
#
#   - grep com regex, -o, -q e código de saída: [sh e bash]
#-----------------------------------------------------------
#printf "ip 192.168.0.10 ok\nsem ip\nip 10.0.0.1 falhou\n" > log.txt
#grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" log.txt
#grep -n "falhou" log.txt
#grep -qi "OK" log.txt && echo "achou (código 0)"
#grep -q "naoexiste" log.txt; echo "não achou -> código $?"
#rm log.txt
#-----------------------------------------------------------
#
#   - find e xargs: [sh e bash]
#-----------------------------------------------------------
#mkdir -p pasta_teste/sub; touch pasta_teste/a.txt pasta_teste/b.log pasta_teste/sub/c.txt
#find pasta_teste -name "*.txt" -type f
#find pasta_teste -type f -name "*.txt" -exec echo "achou: {}" \;
#find pasta_teste -type f -print0 | xargs -0 -n1 echo "arquivo:"
#echo "um dois tres" | xargs -n1
#rm -r pasta_teste
#-----------------------------------------------------------


# ==============================================================================
# 15. PARÂMETROS E OPÇÕES (getopts)
# ==============================================================================
# O getopts lê opções de UMA letra ([-n], [-v], [-h]) e é POSIX (funciona em sh e bash). Não aceita opções longas como --nome.
#   getopts "n:vh" opcao   -> a cada volta do while, a letra lida vai para a variável [opcao]. A letra seguida de [:] ([n:]) exige um valor, que vai para [$OPTARG].
#   Opção inválida (ou valor faltando) faz opcao valer [?]. O [$OPTIND] é o índice do próximo parâmetro: depois do laço, use [shift $((OPTIND - 1))] para sobrarem só os parâmetros normais (os arquivos, por exemplo).
#   Sempre ofereça uma opção [-h] com o modo de uso, e valide parâmetros obrigatórios ([ $# -lt 1 ] && ... exit 1).
#
#   - Exemplo: [sh e bash | executar: sh script.sh -n Ana -v a.txt b.txt]
#-----------------------------------------------------------
#nome="mundo"; verboso=0
#while getopts "n:vh" opcao; do
#    case "$opcao" in
#        n) nome="$OPTARG" ;;
#        v) verboso=1 ;;
#        h) echo "uso: $0 [-n nome] [-v] arquivos..."; exit 0 ;;
#        ?) echo "opção inválida" >&2; exit 1 ;;
#    esac
#done
#shift $((OPTIND - 1))
#echo "nome=$nome verboso=$verboso restante=[$*]"
#-----------------------------------------------------------


# ==============================================================================
# 16. SCRIPTS ROBUSTOS E BOAS PRÁTICAS
# ==============================================================================
# >> 16.1 MODO ESTRITO E DEPURAÇÃO
#   set -e          o script PARA quando um comando falha (código diferente de 0). Não vale para comandos dentro de if/while, de && e ||, nem os precedidos de [!]. Tem comportamentos sutis, não substitui checar os erros importantes.
#   set -u          usar uma variável NÃO definida vira erro (evita acidentes como [rm -rf "$pasta/"*] com $pasta vazia)
#   set -o pipefail (bash) o pipe falha se QUALQUER comando dele falhar
#   Combinação comum: [set -euo pipefail] no bash e [set -eu] no sh.
#   set -x          mostra cada comando antes de executar (depuração)   |   bash -n script.sh   só verifica a sintaxe, sem executar   |   shellcheck script.sh   aponta erros e más práticas (ferramenta externa, vale instalar)
#
#   - Exemplo (dentro de subshells para não encerrar o terminal): [sh e bash]
#-----------------------------------------------------------
#( set -e; echo "antes"; false; echo "NUNCA aparece" ); echo "o subshell terminou com código $?"
#( set -u; echo "$variavel_inexistente" ) 2>&1 | head -n 1
#( set -x; x=1; echo "x vale $x" ) 2>&1
#-----------------------------------------------------------
#
# >> 16.2 TRAP E ARQUIVOS TEMPORÁRIOS
#   trap 'comandos' SINAL   executa os comandos quando o sinal chegar. Sinais comuns: EXIT (quando o script termina, por qualquer motivo), INT (Ctrl+C), TERM (kill), HUP (terminal fechado). [trap - EXIT] remove o trap.
#   mktemp cria um arquivo temporário com nome único e seguro ([mktemp -d] cria uma pasta). Use junto com trap para sempre limpar.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#tmp=$(mktemp)
#trap 'rm -f "$tmp"; echo "limpeza feita: temporário removido"' EXIT
#echo "dados" > "$tmp"; echo "usando $tmp"
#echo "fim do script (o trap roda agora)"
#-----------------------------------------------------------
#
# >> 16.3 COMO EXECUTAR UM SCRIPT E O SHEBANG
#   - [chmod +x script.sh] dá permissão de execução, e [./script.sh] roda usando o interpretador da PRIMEIRA linha (shebang). Se o script rodar com [sh script.sh] ou [bash script.sh], o shebang é ignorado e vale o programa que você digitou.
#   - Por isso as linhas [#!/bin/bash] no meio de um arquivo são só comentários: só a primeira linha conta.
#   - [#!/usr/bin/env bash] procura o bash no PATH (mais portátil que [#!/bin/bash]).
#   - [source script.sh] ou [. script.sh] executa no shell ATUAL (as variáveis e o [cd] ficam valendo depois). Executar normalmente cria um processo filho, que não altera o terminal.
#   - [command -v programa] testa se um programa existe (código 0 se existir): ideal para checar dependências no começo do script. O [id -u] vale 0 para o root.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#command -v ls > /dev/null && echo "ls existe"
#command -v programa_que_nao_existe > /dev/null || echo "programa_que_nao_existe não está instalado"
#if [ "$(id -u)" -eq 0 ]; then echo "rodando como root"; else echo "usuário comum (uid $(id -u))"; fi
#-----------------------------------------------------------
#
# >> 16.4 BOAS PRÁTICAS
#   - Coloque as variáveis SEMPRE entre aspas ("$var", "$@") e use [local] nas funções.
#   - Use [$(...)] em vez de crases, [[ ]] só se o script for bash, e [printf] em vez de [echo] quando o texto vier de variáveis.
#   - Mensagens de erro vão para o stderr ([>&2]) e o script termina com [exit 1] (ou outro código diferente de 0) quando falhar.
#   - Valide a entrada: número de parâmetros, se o arquivo existe, se o usuário é root quando precisa.
#   - Nunca coloque senhas ou tokens dentro do script (use variáveis de ambiente ou um arquivo com permissão [chmod 600]).
#   - Antes de operações destrutivas ([rm], [mv], [sed -i]) ofereça um modo de simulação ([--dry-run]) e confirmação.
#   - Nomes claros, funções pequenas, comentários explicando o PORQUÊ, e um [uso()] com exemplos.
#   - Passe o script pelo ShellCheck antes de considerar pronto.


# ==============================================================================
# 17. PROCESSOS, SEGUNDO PLANO E AGENDAMENTO (cron)
# ==============================================================================
#   cmd &            roda em segundo plano e devolve o terminal na hora   |   $!   PID do último processo em segundo plano
#   wait [PID]       espera o processo terminar e devolve o código de saída dele   |   jobs   lista os trabalhos do terminal atual
#   kill PID         envia o sinal TERM (pede para encerrar, o programa pode limpar tudo)   |   kill -9 PID   mata à força (sem chance de limpeza, só em último caso)
#   nohup cmd &      continua rodando mesmo se o terminal for fechado   |   ps aux   lista processos   |   pgrep nome / pkill nome   acha / encerra por nome
#   sleep N          espera N segundos   |   timeout N cmd   encerra o comando se passar de N segundos (código 124)
#
#   CRON: agenda comandos. Edite com [crontab -e] e liste com [crontab -l]. Formato (5 campos de tempo e depois o comando):
#       minuto  hora  dia-do-mês  mês  dia-da-semana  comando
#       Símbolos: [*] qualquer valor | [*/5] a cada 5 | [1,15] lista | [1-5] intervalo. Dia da semana: 0 ou 7 = domingo, 1 = segunda.
#       */5 * * * *    /home/user/monitor.sh      -> a cada 5 minutos
#       0 2 * * *      /home/user/backup.sh       -> todo dia às 2h
#       30 8 * * 1-5   /home/user/relatorio.sh    -> às 8h30, de segunda a sexta
#   No cron: use CAMINHOS ABSOLUTOS (o PATH é mínimo), dê permissão de execução ao script e redirecione a saída para um log ([>> /var/log/x.log 2>&1]), senão você nunca saberá o que deu errado.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#sleep 1 &
#pid=$!
#echo "rodando em segundo plano com PID $pid"
#wait "$pid"; echo "terminou, código $?"
#timeout 1 sleep 3; echo "o timeout devolveu $? (124 = estourou o tempo)"
#-----------------------------------------------------------


# ==============================================================================
# 18. COMANDOS DE REDE NO SHELL
# ==============================================================================
# ATENÇÃO: use varreduras, testes de porta e capturas de pacotes SOMENTE em redes e máquinas suas ou com autorização.
#   ping -c 1 -W 1 host     1 pacote, espera 1 segundo. Código 0 = respondeu, diferente de 0 = não respondeu (no Linux; no macOS o -W é em milissegundos)
#   ip -br addr             IPs das interfaces   |   ip route   rotas e gateway   |   cat /etc/resolv.conf   servidores DNS
#   ss -tulnp               portas em escuta (t=TCP, u=UDP, l=listening, n=numérico, p=processo; o [p] precisa de root)
#   nc -z -w1 host porta    testa se uma porta TCP abre (o -z não envia dados)   |   (echo > /dev/tcp/host/porta)   o mesmo teste só com bash, sem o nc
#   dig +short dominio      consulta DNS (também nslookup e host)
#   curl -s -o /dev/null -w "%{http_code}" URL   mostra só o código HTTP   |   curl -fsS URL   falha (código diferente de 0) se der erro HTTP   |   curl -m 5   desiste depois de 5 segundos
#   ssh -o BatchMode=yes -o ConnectTimeout=3 usuario@host comando   roda um comando remoto sem pedir senha (precisa de chave SSH)   |   scp / rsync   copiam arquivos
#   traceroute host         caminho até o destino   |   tcpdump -i eth0 -c 10   captura pacotes (precisa de root)
#   - Em scripts, o que vale é o CÓDIGO DE SAÍDA: [if ping ...; then] e [if nc -z ...; then] funcionam como o if explicado na seção 8.0.
#
#   - Exemplo (usa só a própria máquina; se o programa não existir, mostra a mensagem): [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#if ping -c 1 -W 1 127.0.0.1 > /dev/null 2>&1; then echo "127.0.0.1 respondeu"; else echo "127.0.0.1 não respondeu (ou ping indisponível)"; fi
#(echo > /dev/tcp/127.0.0.1/65000) 2>/dev/null && echo "porta 65000 aberta" || echo "porta 65000 fechada"
#-----------------------------------------------------------


# ==============================================================================
# 19. COMO CONSULTAR AJUDA
# ==============================================================================
#   man comando        manual completo (sai com [q]) | comando --help   resumo das opções | help comando   ajuda dos comandos internos do bash ([help test], [help read])
#   type comando       mostra se é um comando interno, um programa ou um apelido | which / command -v   mostram o caminho do programa
#   Pesquisar dentro do man: tecla [/] e o termo, [n] para o próximo resultado.
#
#   - Exemplo: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#help test | head -n 5
#ls --help | head -n 3
#type echo ls cd
#-----------------------------------------------------------
# ==============================================================================
# 20. ARITMÉTICA E NÚMEROS DECIMAIS
# ==============================================================================
# O shell só calcula com INTEIROS. Para decimais é preciso chamar outro programa: awk (o mais prático e já instalado), bc (clássico, pode não estar instalado: [sudo pacman -S bc]) ou printf (só formata, não calcula).
# Qual usar? Para quase tudo, awk.


# >> 20.1 ARITMÉTICA INTEIRA
#   $(( ))  devolve o VALOR da conta (para usar em outro comando)   |   (( ))  (bash) só calcula e devolve código de saída (seção 8.0)
#   Operadores: + - * / % (resto) e ** (potência, SÓ bash). Dentro do $(( )) as variáveis dispensam o [$]: [$((a + b))].
#   A divisão DESCARTA a parte decimal: [$((10/3))] dá 3, e [$((-7/2))] dá -3 (arredonda para zero).
#   Número começando com 0 é lido como OCTAL: [$((010))] dá 8 e [$((08))] dá erro. Para forçar decimal use [$((10#08))] (bash).
#   Outras bases (bash): [$((16#ff))] dá 255 | [$((2#101))] dá 5.
#   Dividir por zero dá erro ("division by 0"): teste o divisor antes.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#a=17; b=5
#echo "soma: $((a + b)) | subtração: $((a - b)) | multiplicação: $((a * b))"
#echo "divisão: $((a / b)) | resto: $((a % b))"
#[ "$b" -ne 0 ] && echo "divisão segura: $((a / b))"
#-----------------------------------------------------------
#
#   - Potência e bases: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#echo "2 elevado a 10: $((2 ** 10)) | hex ff: $((16#ff)) | 08 decimal: $((10#08))"
#-----------------------------------------------------------


# >> 20.2 DECIMAIS COM AWK (a opção mais comum)
#   awk 'BEGIN { ... }'  roda o código sem precisar de arquivo de entrada. Divide em decimal e usa printf para escolher as casas: [%.2f].
#   Operadores: + - * / % ^ (potência). Funções: [sqrt(x)] raiz | [int(x)] corta a parte decimal | [exp] [log] [sin] [cos].
#   Passe variáveis do shell com [-v nome="$valor"]. Nunca coloque [$var] dentro das aspas simples do awk.
#   O gawk (awk padrão do Arch) lê e escreve decimais SEMPRE com ponto, mesmo no pt_BR.
#   Dividir por zero no awk também dá erro: teste antes.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#awk 'BEGIN { printf "%.2f\n", 10/3 }'
#awk 'BEGIN { printf "media: %.2f\n", (7.5 + 8 + 6.25) / 3 }'
#awk 'BEGIN { printf "raiz de 2: %.4f | 2^10: %d\n", sqrt(2), 2^10 }'
#a=5.5; b=2
#awk -v a="$a" -v b="$b" 'BEGIN { printf "%.2f x %.2f = %.2f\n", a, b, a * b }'
#resultado=$(awk -v a="$a" -v b="$b" 'BEGIN { printf "%.2f", a / b }')
#echo "guardado na variável: $resultado"
#-----------------------------------------------------------
#
#   - Somar uma coluna de números (muito usado em pipes): [sh e bash]
#-----------------------------------------------------------
#printf "2.5\n3.5\n4\n" | awk '{ soma += $1 } END { printf "soma: %.2f\n", soma }'
#-----------------------------------------------------------


# >> 20.3 DECIMAIS COM BC (se estiver instalado)
#   [echo "conta" | bc]: o bc lê a conta pelo stdin. [scale=N] define as casas decimais (vale principalmente para divisão; o padrão é 0, ou seja, divide como inteiro).
#   [bc -l] carrega a biblioteca matemática: scale=20 e funções [s(x)] seno, [c(x)] cosseno, [l(x)] logaritmo, [e(x)] exponencial. [sqrt(x)] funciona até sem -l.
#   Operadores: + - * / % ^. O bc NÃO coloca o zero antes do ponto: 1/2 sai como [.50].
#   Verifique se existe com [command -v bc].
#
#   - Exemplo: [sh e bash | precisa do bc instalado]
#-----------------------------------------------------------
#command -v bc > /dev/null || { echo "bc não instalado (sudo pacman -S bc)"; exit 1; }
#echo "scale=2; 10/3" | bc
#echo "scale=2; 5.5 * 2" | bc
#echo "scale=4; sqrt(2)" | bc
#echo "scale=2; 1/2" | bc
#-----------------------------------------------------------


# >> 20.4 PRINTF PARA FORMATAR DECIMAIS
#   O printf NÃO calcula, só formata um número que você já tem: [%.2f] 2 casas | [%8.2f] 8 colunas com 2 casas | [%.0f] sem casas (arredonda) | [%e] notação científica.
#   No pt_BR o printf do bash espera VÍRGULA na entrada ([printf "%.2f" 3,14]) e dá erro com ponto. Para forçar o ponto: [LC_NUMERIC=C printf ...].
#   Os valores vindos do awk podem ser formatados no próprio awk.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#LC_NUMERIC=C printf "%.2f | %8.2f | %.0f\n" 3.14159 3.14159 3.7
#-----------------------------------------------------------


# >> 20.5 ARREDONDAR E TRUNCAR
#   Truncar (cortar): [int(x)] no awk.
#   Arredondar para N casas: [printf "%.Nf"] (no awk ou no shell). Atenção: o valor exatamente na metade tende ao par (2.5 vira 2 e 3.5 vira 4).
#   Arredondar para cima (a partir de .5, números positivos): [int(x + 0.5)].
#   Teto (sempre para cima) e piso: [int()] serve de piso para positivos; para teto some 0.999999 ou compare o resultado com o original.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#awk 'BEGIN { x = 3.7; printf "truncado: %d | arredondado: %.0f | +0.5: %d\n", int(x), x, int(x + 0.5) }'
#awk 'BEGIN { x = 2.5; printf "2.5 -> %.0f | com int(x+0.5): %d\n", x, int(x + 0.5) }'
#-----------------------------------------------------------


# >> 20.6 COMPARAR DECIMAIS
#   [ ] e (( )) só comparam inteiros: [ 3.5 -gt 2 ] dá "integer expression expected" (código de saída 2, seção 8.0).
#   Use o awk e leia o resultado pelo código de saída: [exit !(condição)] sai com 0 (verdadeiro para o if) quando a condição vale.
#   Com o bc: [echo "3.5 > 2.1" | bc] imprime 1 (verdadeiro) ou 0 (falso).
#   Igualdade exata de decimais é traiçoeira (0.1 + 0.2 não é igual a 0.3 no computador). Compare a diferença com uma tolerância: [(a - b) < 0.0001 && (b - a) < 0.0001].
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#a=3.5; b=2.1
#if awk -v a="$a" -v b="$b" 'BEGIN { exit !(a > b) }'; then echo "$a é maior que $b"; else echo "$a não é maior que $b"; fi
#awk 'BEGIN { print (0.1 + 0.2 == 0.3) ? "igual" : "diferente (erro de ponto flutuante)" }'
#-----------------------------------------------------------
#
#   - Com bc: [sh e bash | precisa do bc]
#-----------------------------------------------------------
#[ "$(echo "3.5 > 2.1" | bc)" -eq 1 ] && echo "bc: 3.5 é maior que 2.1"
#-----------------------------------------------------------


# >> 20.7 LER DECIMAIS DO USUÁRIO
#   1. Troque a vírgula por ponto: [valor=${valor//,/.}] (a barra dupla troca TODAS as ocorrências).
#   2. Valide antes de calcular. No bash: [[ "$v" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]. No sh: [case] com padrão (aceita só dígitos e ponto, não barra "1.2.3").
#
#   - Calculadora de duas operandos: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#read -p "Primeiro número: " a
#read -p "Segundo número: " b
#a=${a//,/.}; b=${b//,/.}
#if [[ ! "$a" =~ ^-?[0-9]+(\.[0-9]+)?$ || ! "$b" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then echo "Digite apenas números" >&2; exit 1; fi
#awk -v a="$a" -v b="$b" 'BEGIN {
#    printf "Soma: %.2f\n", a + b
#    printf "Subtração: %.2f\n", a - b
#    printf "Multiplicação: %.2f\n", a * b
#    if (b == 0) print "Divisão: impossível (divisor zero)"
#    else printf "Divisão: %.2f\n", a / b
#}'
#-----------------------------------------------------------
#
#   - Validação em sh puro: [sh e bash]
#-----------------------------------------------------------
#v="3.5"
#case "$v" in ''|*[!0-9.]*) echo "inválido" ;; *) echo "parece um número: $v" ;; esac
#v="abc"
#case "$v" in ''|*[!0-9.]*) echo "inválido" ;; *) echo "parece um número: $v" ;; esac
#-----------------------------------------------------------


# >> 20.8 ATALHO: FUNÇÃO CALC
#   Uma função (seção 10) que recebe a conta como texto e imprime o resultado com 2 casas. Use SÓ com contas escritas por você: o texto é executado pelo awk, então nunca passe entrada do usuário direto.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#calc() { awk "BEGIN { printf \"%.2f\n\", $* }"; }
#calc "10/3"
#calc "(7.5 + 8) / 2"
#-----------------------------------------------------------


# >> 20.9 ERROS COMUNS COM NÚMEROS
#   - Esperar decimal de [$(( ))]: [$((10/3))] dá 3 e [$((3.5 + 1))] dá erro de sintaxe. Use awk.
#   - Usar [-gt] [-eq] com decimal: dá "integer expression expected". Use awk ou bc (20.6).
#   - Digitar vírgula: [3,5] não é número para o awk nem para o bc. Troque por ponto (20.7).
#   - Zero à esquerda: [08] e [09] viram erro de octal no $(( )). Use [10#08] (bash) ou remova o zero.
#   - Colocar [$var] dentro das aspas simples do awk: ele não expande. Use [-v var="$valor"].
#   - Usar [%d] no printf com decimal: dá erro. Use [%.2f] (e [LC_NUMERIC=C] se o sistema estiver em pt_BR).
#   - Comparar decimais com [==]: use tolerância (20.6).
#   - Esquecer que o bc pode não estar instalado: [command -v bc] antes de usar.


# ==============================================================================
# 21. ARQUIVOS, PERMISSÕES E COMPACTAÇÃO
# ==============================================================================
# >> 21.1 COMO LER O ls -l
#   -rwxr-xr-- 1 ana devs 2048 nov 13 10:00 script.sh
#   - 1º caractere: tipo ([-] arquivo comum, [d] diretório, [l] link simbólico). Depois vêm 3 grupos de 3 letras: DONO (u), GRUPO (g) e OUTROS (o), cada um com r (ler), w (escrever) e x (executar). Depois: nº de links, dono, grupo, tamanho em bytes, data e nome.
#   - Em PASTAS o significado muda: r = listar o conteúdo | w = criar e apagar arquivos dentro dela | x = entrar (cd) e acessar os itens.
#
# >> 21.2 CHMOD, CHOWN E UMASK
#   Números (octal): r=4, w=2, x=1, e você SOMA por grupo. rwx=7, rw-=6, r-x=5, r--=4.
#     chmod 755 arq   -> dono rwx, grupo r-x, outros r-x (típico de scripts)
#     chmod 644 arq   -> dono rw-, grupo r--, outros r-- (típico de arquivos de texto)
#     chmod 600 arq   -> só o dono lê e escreve (senhas, tokens, chaves)
#     chmod 700 pasta -> só o dono acessa
#   Letras: [chmod u+x arq] dá execução ao dono | [g-w] tira escrita do grupo | [o=] zera os outros | [a+r] todos podem ler | [-R] recursivo (pastas inteiras).
#   [chown usuario:grupo arq] troca dono e grupo (precisa de root) | [chgrp grupo arq] só o grupo.
#   umask: define o que NÃO será dado a arquivos novos. O sistema parte de 666 (arquivos) e 777 (pastas) e tira a máscara: com [umask 022] arquivos novos ficam 644 e pastas 755. Com [umask 077] tudo novo fica privado.
#   Permissões especiais: SUID (4000, o programa roda como o DONO do arquivo), SGID (2000) e sticky bit (1000, em pastas como /tmp só o dono apaga o próprio arquivo: [chmod 1777]). Arquivos com SUID são alvo de auditoria: [find / -perm -4000 -type f 2>/dev/null].
#
#   - Exemplo (GNU/Linux): [sh e bash]
#-----------------------------------------------------------
#touch arq.sh
#chmod 755 arq.sh; ls -l arq.sh | cut -c1-10
#chmod 600 arq.sh; ls -l arq.sh | cut -c1-10
#chmod u+x,g+r arq.sh; ls -l arq.sh | cut -c1-10
#stat -c "octal=%a simbólico=%A dono=%U" arq.sh
#(umask 077; touch privado.txt); ls -l privado.txt | cut -c1-10
#mkdir pasta; ls -ld pasta | cut -c1-10
#rm -r arq.sh privado.txt pasta
#-----------------------------------------------------------
#
# >> 21.3 COMANDOS DE ARQUIVO
#   cp origem destino | cp -r (pasta) | cp -a (cópia fiel: recursiva, preserva permissões, datas e links) | -i pergunta antes de sobrescrever | -n nunca sobrescreve
#   mv origem destino (move OU renomeia) | -i | -n   |   rm arq | rm -r pasta | rm -f (sem perguntar) | rm -i (pergunta). NÃO existe lixeira: apagou, perdeu.
#   mkdir -p a/b/c (cria a cadeia toda, sem erro se já existir) | touch arq (cria vazio ou atualiza a data) | ls -lah (ocultos e tamanhos legíveis) | ls -lt (por data)
#   stat arq (detalhes) | file arq (tipo REAL do conteúdo) | du -sh pasta (tamanho total) | realpath arq (caminho absoluto) | readlink -f
#
# >> 21.4 CHAVES, [--] E PROTEÇÃO DO RM
#   - Expansão de chaves (bash): [mkdir -p projeto/{src,docs,tests}] | [cp arq{,.bak}] copia arq para arq.bak | [{01..05}] com zeros | [{1..10..2}] com passo. O sh (dash) NÃO expande chaves.
#   - Nomes que começam com [-] viram OPÇÕES: [rm -arquivo] falha. Use [--] para dizer "acabaram as opções": [rm -- "$arq"], [grep -- "$padrao" arq]. Ou use [./-arquivo].
#   - Perigo clássico: [rm -rf "$dir"/*] com $dir vazio vira [rm -rf /*]. Proteja com [${dir:?}] (aborta se vazia) ou [set -u]: [rm -rf "${dir:?}"/*]. Confira também se o caminho NÃO é "/" nem "$HOME" antes de apagar.
#
#   - Chaves: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#mkdir -p projeto/{src,docs,tests}; ls projeto
#touch config.txt; cp config.txt{,.bak}; ls config.txt*
#echo arquivo-{a,b,c}.txt {01..03}
#rm -r projeto config.txt config.txt.bak
#-----------------------------------------------------------
#
#   - O [--] e a proteção com ${var:?}: [sh e bash]
#-----------------------------------------------------------
#touch ./-teste.txt
#rm -teste.txt 2>&1 | head -n 1
#rm -- -teste.txt && echo "removido com --"
#dir=""
#( echo "${dir:?variável vazia}" ) 2>&1 | head -n 1
#-----------------------------------------------------------
#
# >> 21.5 LINKS
#   - Link simbólico ([ln -s alvo nome]): um atalho que aponta para o CAMINHO. Se o original for apagado, o link quebra. É a base dos deploys com versões ([atual -> v3]). Troca atômica: [ln -sfn novo_alvo atual] (o [-n] evita criar o link DENTRO da pasta para onde ele já aponta).
#   - Hard link ([ln alvo nome]): outro NOME para o mesmo conteúdo (mesmo inode). Apagar um nome não apaga o conteúdo enquanto houver outro. Não funciona entre discos diferentes nem com pastas.
#
#   - Exemplo (versões e rollback): [sh e bash]
#-----------------------------------------------------------
#mkdir v1 v2; echo "versao 1" > v1/app.txt; echo "versao 2" > v2/app.txt
#ln -sfn v1 atual; cat atual/app.txt; readlink atual
#ln -sfn v2 atual; cat atual/app.txt; readlink atual
#rm -r v1 v2 atual
#-----------------------------------------------------------
#
# >> 21.6 COMPACTAR, COPIAR, CONFERIR E COMPARAR
#   tar: junta vários arquivos em um só. Letras: c (criar) | x (extrair) | t (listar) | v (mostrar) | f ARQUIVO (nome do arquivo, vem por último no grupo de letras) | z (gzip, .tar.gz) | j (bzip2) | J (xz) | -C pasta (entra na pasta antes).
#     [tar -czf backup.tar.gz pasta/] cria | [tar -tzf backup.tar.gz] lista sem extrair (bom para testar se está íntegro) | [tar -xzf backup.tar.gz -C /destino] extrai em outra pasta
#   gzip arq (gera arq.gz e REMOVE o original) | gzip -k (mantém) | gunzip arq.gz | zip -r arq.zip pasta | unzip arq.zip
#   rsync -a origem/ destino/ copia SÓ o que mudou. [-a] modo arquivo (recursivo, preserva permissões e datas) | [-v] verboso | [-n] simulação | [--delete] apaga no destino o que não existe mais na origem (CUIDADO) | [-z] comprime | [rsync -a origem/ usuario@host:/destino/] via SSH. A barra no final de [origem/] copia o CONTEÚDO; sem ela copia a pasta inteira.
#   sha256sum arq (impressão digital do conteúdo) | [sha256sum -c arq.sha256] confere | usado para provar que um backup ou download não foi corrompido.
#   diff a b (mostra diferenças; código 0 = iguais, 1 = diferentes) | diff -r pasta1 pasta2 | cmp a b (byte a byte) | comm a b (compara listas ORDENADAS)
#
#   - Backup, conferência e restauração: [sh e bash]
#-----------------------------------------------------------
#mkdir dados; echo "a" > dados/1.txt; echo "b" > dados/2.txt
#tar -czf backup.tar.gz dados
#tar -tzf backup.tar.gz
#sha256sum backup.tar.gz > backup.sha256; sha256sum -c backup.sha256
#mkdir restaurado; tar -xzf backup.tar.gz -C restaurado
#diff -r dados restaurado/dados && echo "restauração idêntica ao original"
#echo "alterado" >> dados/1.txt; diff -r dados restaurado/dados > /dev/null; echo "código do diff quando há diferença: $?"
#if command -v rsync > /dev/null; then mkdir copia; rsync -an dados/ copia/; rmdir copia; else echo "(rsync não instalado)"; fi
#rm -r dados restaurado backup.tar.gz backup.sha256
#-----------------------------------------------------------


# ==============================================================================
# 22. USUÁRIOS, SERVIÇOS, PACOTES E MONITORAMENTO
# ==============================================================================
# ATENÇÃO: criar usuários, mexer em serviços e instalar pacotes muda o sistema. Pratique em uma máquina virtual ou container, nunca direto na máquina que você usa.
#
# >> 22.1 USUÁRIOS E GRUPOS
#   id (uid, gid e grupos de quem roda) | id -u (só o uid; 0 = root) | whoami | groups [usuario] | who / w (quem está logado) | last (histórico de logins)
#   /etc/passwd: um usuário por linha, 7 campos separados por [:] -> nome:x:UID:GID:comentário:home:shell. O [x] indica que a senha está em /etc/shadow (só o root lê). UID 0 = root, 1 a 999 = contas de sistema, 1000 ou mais = usuários comuns (na maioria das distros). /etc/group: grupo:x:GID:membros.
#   Administração (precisa de root):
#     useradd -m -s /bin/bash -G grupo1,grupo2 nome   cria o usuário com pasta pessoal, shell e grupos extras
#     passwd nome   define a senha   |   chage -d 0 nome   força trocar a senha no próximo login
#     usermod -aG grupo nome   ADICIONA a um grupo (sem o [-a] SUBSTITUI todos os grupos!)   |   usermod -L nome   bloqueia a conta
#     userdel -r nome   apaga o usuário E a pasta pessoal   |   groupadd grupo   |   gpasswd -d nome grupo   remove do grupo
#   sudo executa um comando como root (ou outro usuário). A configuração fica em /etc/sudoers e deve ser editada SEMPRE com [visudo], que confere a sintaxe. [sudo -l] lista o que você pode fazer. Em scripts nunca coloque senha: use NOPASSWD só onde for realmente necessário e restrito a um comando.
#
#   - Consultas (só leitura): [sh e bash]
#-----------------------------------------------------------
#id; id -u; whoami
#echo "primeiros usuários (nome, uid, shell):"; cut -d: -f1,3,7 /etc/passwd | head -n 3
#echo "usuários comuns (UID >= 1000):"; awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd
#id root > /dev/null 2>&1 && echo "root existe"
#id naoexiste > /dev/null 2>&1 || echo "naoexiste não existe (é assim que se testa em scripts)"
#-----------------------------------------------------------
#
# >> 22.2 SERVIÇOS (systemd)
#   systemctl status nome | start | stop | restart | reload (recarrega a configuração sem parar) | enable (inicia no boot) | disable | is-active nome (imprime active/inactive e devolve 0 se ativo, ótimo no if) | is-enabled | list-units --type=service --state=failed (serviços com falha) | daemon-reload (depois de editar um arquivo .service)
#   start, stop e enable precisam de root. Os arquivos de serviço ficam em /etc/systemd/system/nome.service.
#   journalctl -u nome (logs do serviço) | -n 50 (últimas 50) | -f (acompanha) | --since "1 hour ago" | -p err (só erros) | -b (desde o boot atual) | -t etiqueta (mensagens do [logger -t etiqueta])
#   Timer do systemd: alternativa moderna ao cron. Dois arquivos em /etc/systemd/system/: [meuscript.service] com [ExecStart=/caminho/script.sh] e [meuscript.timer] com [OnCalendar=*-*-* 02:00:00]. Ative com [systemctl enable --now meuscript.timer] e veja com [systemctl list-timers].
#   Sem systemd (containers, Alpine): [service nome status] ou [pgrep nome].
#
#   - Exemplo (se o systemctl existir): [sh e bash]
#-----------------------------------------------------------
#if command -v systemctl > /dev/null; then systemctl is-active --quiet ssh && echo "ssh ativo" || echo "ssh parado ou inexistente"; else echo "systemctl não existe aqui"; fi
#-----------------------------------------------------------
#
# >> 22.3 PACOTES
#   Arch (o seu caso): [pacman -Syu] atualiza tudo | [pacman -S pacote] instala | [pacman -Rns pacote] remove com dependências órfãs | [pacman -Ss termo] busca | [pacman -Qi pacote] info | [pacman -Q] lista os instalados | [pacman -Qo /caminho] qual pacote tem esse arquivo
#   Debian/Ubuntu: [apt update && apt install -y pacote] | [apt remove] | [apt search] | [dpkg -l] | [dpkg -S /caminho]
#   Fedora/RHEL: [dnf install -y pacote] | [dnf remove] | [dnf search] | [rpm -qa] | [rpm -qf /caminho]
#   Detectar a distribuição em script: [. /etc/os-release; echo "$ID"] (arch, debian, ubuntu, fedora...) ou [command -v pacman].
#   Idempotência (rodar duas vezes não quebra nada): [pacman -Qi pacote > /dev/null 2>&1 || sudo pacman -S --noconfirm pacote]. Em scripts use as opções não interativas ([--noconfirm] no pacman, [-y] no apt e no dnf).
#
#   - Exemplo (só leitura): [sh e bash]
#-----------------------------------------------------------
#. /etc/os-release; echo "distribuição: $ID ($NAME)"
#if command -v pacman > /dev/null; then gerenciador=pacman; elif command -v apt > /dev/null; then gerenciador=apt; elif command -v dnf > /dev/null; then gerenciador=dnf; else gerenciador="desconhecido"; fi
#echo "gerenciador de pacotes: $gerenciador"
#-----------------------------------------------------------
#
# >> 22.4 MONITORAMENTO
#   df -h (espaço por partição) | df -h / | df -i (inodes) | du -sh pasta | du -h --max-depth=1 /var | sort -h (subpastas, da menor para a maior) | lsblk (discos) | findmnt
#   free -h (memória; a coluna "available" é a que realmente sobra) | uptime (carga média de 1, 5 e 15 min: compare com o número de CPUs, [nproc]) | vmstat 1 5 | top / htop (interativos) | ps aux (todos os processos) | ps -eo pid,comm,%cpu,%mem --sort=-%mem | head (os que mais usam memória)
#   /proc é um sistema de arquivos virtual do kernel: /proc/cpuinfo, /proc/meminfo, /proc/loadavg, /proc/uptime.
#   Extrair números para usar em if: [uso=$(df / --output=pcent | tail -n 1 | tr -dc '0-9')] (% do /) | [mem=$(free | awk '/^Mem:/ {printf "%d", $3/$2*100}')] (% de memória) | [cut -d' ' -f1 /proc/loadavg] (carga de 1 min)
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#uso=$(df / --output=pcent | tail -n 1 | tr -dc '0-9'); echo "uso do / : $uso%"
#mem=$(free | awk '/^Mem:/ {printf "%d", $3/$2*100}'); echo "memória usada: $mem%"
#echo "carga média (1 min): $(cut -d' ' -f1 /proc/loadavg) | CPUs: $(nproc)"
#if [ "$uso" -gt 80 ]; then echo "ALERTA: disco acima de 80%"; else echo "disco ok"; fi
#ps -eo pid,comm --sort=-%mem | head -n 3
#-----------------------------------------------------------


# ==============================================================================
# 23. REDES: TEORIA E CÁLCULOS
# ==============================================================================
# >> 23.1 CONCEITOS
#   - Modelo TCP/IP (4 camadas): Acesso à rede (Ethernet e Wi-Fi, endereço MAC) -> Internet (IP e ICMP: endereços e rotas) -> Transporte (TCP e UDP: portas) -> Aplicação (HTTP, DNS, SSH...). O modelo OSI detalha em 7 camadas: física, enlace, rede, transporte, sessão, apresentação e aplicação.
#   - IPv4: 32 bits em 4 octetos (0 a 255), como 192.168.0.10. A MÁSCARA diz quais bits identificam a REDE. O prefixo CIDR conta esses bits: /24 = 24 bits de rede = máscara 255.255.255.0.
#   - Endereço de rede = IP AND máscara | Broadcast = rede OR (NOT máscara) | Hosts úteis = 2^(32 - prefixo) - 2 (tira o endereço de rede e o de broadcast).
#   - Faixas privadas (RFC 1918): 10.0.0.0/8, 172.16.0.0/12 e 192.168.0.0/16. Loopback (a própria máquina): 127.0.0.0/8. Link-local (sem DHCP): 169.254.0.0/16.
#   - Gateway = o roteador, a saída para outras redes | DNS = traduz nomes em IPs (porta 53) | DHCP = entrega IP, máscara, gateway e DNS automaticamente (UDP 67 e 68) | ARP = descobre o MAC de um IP na rede local | ICMP = mensagens de controle (ping, traceroute).
#   - TCP: com conexão, confiável e ordenado (HTTP, SSH, e-mail). UDP: sem conexão, rápido e sem garantia de entrega (DNS, VoIP, jogos).
#   - Portas conhecidas: 20/21 FTP | 22 SSH | 23 Telnet (inseguro) | 25 SMTP | 53 DNS | 67/68 DHCP | 80 HTTP | 110 POP3 | 123 NTP | 143 IMAP | 443 HTTPS | 445 SMB | 3306 MySQL | 3389 RDP | 5432 PostgreSQL. Portas abaixo de 1024 são "privilegiadas" (abrir uma exige root).
#
# >> 23.2 OPERAÇÕES COM BITS NO SHELL (base do cálculo de sub-redes)
#   Dentro do [$(( ))] (sh e bash): [&] AND | [|] OR | [^] XOR | [~] NOT | [<<] desloca bits para a esquerda | [>>] para a direita. O shell usa 64 bits, então use [& 0xFFFFFFFF] para ficar em 32.
#   Converter bases: [$((2#1010))] = 10 (bash) | [$((16#ff))] = 255 (bash) | [printf "%x" 255] = ff | [printf "%o" 8] = 10 | binário com o bc: [echo "obase=2; 10" | bc].
#   IP -> número: a*2^24 + b*2^16 + c*2^8 + d, ou [(a<<24) + (b<<16) + (c<<8) + d]. Número -> IP: pegue cada octeto com [(n>>24) & 255], [(n>>16) & 255], [(n>>8) & 255] e [n & 255].
#   Máscara de um prefixo: [(0xFFFFFFFF << (32 - prefixo)) & 0xFFFFFFFF].
#
#   - Calculadora de sub-rede (só aritmética, não usa a rede): [sh e bash]
#-----------------------------------------------------------
#ip2int() { local IFS=.; set -- $1; echo $(( ($1 << 24) + ($2 << 16) + ($3 << 8) + $4 )); }
#int2ip() { echo "$(( ($1 >> 24) & 255 )).$(( ($1 >> 16) & 255 )).$(( ($1 >> 8) & 255 )).$(( $1 & 255 ))"; }
#
#cidr="192.168.10.77/26"
#ip=${cidr%/*}; prefixo=${cidr#*/}
#ipn=$(ip2int "$ip")
#mascara=$(( (0xFFFFFFFF << (32 - prefixo)) & 0xFFFFFFFF ))
#rede=$(( ipn & mascara ))
#broadcast=$(( rede | (~mascara & 0xFFFFFFFF) ))
#echo "IP:        $ip"
#echo "Máscara:   $(int2ip $mascara)"
#echo "Rede:      $(int2ip $rede)/$prefixo"
#echo "Broadcast: $(int2ip $broadcast)"
#echo "Hosts:     $(( (1 << (32 - prefixo)) - 2 ))"
#echo "Faixa de hosts: $(int2ip $((rede + 1))) até $(int2ip $((broadcast - 1)))"
#-----------------------------------------------------------
#
#   - Listar todos os IPs de uma faixa (base de uma varredura, SEM enviar nada pela rede): [sh e bash]
#-----------------------------------------------------------
#ip2int() { local IFS=.; set -- $1; echo $(( ($1 << 24) + ($2 << 16) + ($3 << 8) + $4 )); }
#int2ip() { echo "$(( ($1 >> 24) & 255 )).$(( ($1 >> 16) & 255 )).$(( ($1 >> 8) & 255 )).$(( $1 & 255 ))"; }
#cidr="10.0.0.8/29"; ip=${cidr%/*}; prefixo=${cidr#*/}
#mascara=$(( (0xFFFFFFFF << (32 - prefixo)) & 0xFFFFFFFF ))
#rede=$(( $(ip2int "$ip") & mascara )); broadcast=$(( rede | (~mascara & 0xFFFFFFFF) ))
#for n in $(seq $((rede + 1)) $((broadcast - 1))); do int2ip "$n"; done
#-----------------------------------------------------------
#
# >> 23.3 DNS, ROTAS E HTTP NA PRÁTICA
#   ip -br addr (IPs) | ip route (rotas e gateway) | ip neigh (tabela ARP) | cat /etc/resolv.conf (DNS) | resolvectl status (DNS do systemd-resolved) | /etc/hosts (nomes locais, consultado antes do DNS)
#   dig +short A dominio | dig +short MX dominio | dig -x IP (consulta reversa) | host nome | getent hosts nome (resolve COMO o sistema, incluindo o /etc/hosts)
#   curl -I URL (só os cabeçalhos) | curl -s -o /dev/null -w "%{http_code} %{time_total}s\n" URL (código e tempo) | curl -fsS --max-time 5 URL | wget -q --spider URL (testa sem baixar)
#   Diagnóstico em camadas, de baixo para cima: interface ligada ([ip -br link]) -> IP ([ip -br addr]) -> gateway ([ping] no gateway) -> internet por IP ([ping 1.1.1.1]) -> DNS ([getent hosts nome]) -> aplicação ([curl]). Se o ping por IP funciona e por nome não, o problema é o DNS.
#
#   - Exemplo (consulta local): [sh e bash]
#-----------------------------------------------------------
#getent hosts localhost
#grep -v '^#' /etc/hosts | head -n 3
#-----------------------------------------------------------
#
# >> 23.4 FIREWALL (conceito e comandos)
#   Um firewall decide quais pacotes entram, saem ou passam pela máquina. Política recomendada: BLOQUEAR tudo que entra por padrão e liberar só o necessário (SSH, HTTP, HTTPS), aceitando sempre as conexões já estabelecidas.
#   ufw (simples): [ufw default deny incoming] | [ufw default allow outgoing] | [ufw allow 22/tcp] | [ufw allow from 192.168.0.0/24 to any port 22] | [ufw enable] | [ufw status numbered] | [ufw delete N]
#   nftables (moderno, substitui o iptables): [nft list ruleset] mostra tudo. Arquivo /etc/nftables.conf mínimo:
#       table inet filter {
#         chain input {
#           type filter hook input priority 0; policy drop;
#           ct state established,related accept
#           iif lo accept
#           tcp dport { 22, 80, 443 } accept
#         }
#       }
#   iptables (clássico): [iptables -L -n -v] lista | [iptables -A INPUT -p tcp --dport 22 -j ACCEPT] libera o SSH | [iptables -P INPUT DROP] política de bloquear.
#   CUIDADO: aplicar "policy drop" ou [ufw enable] SEM liberar o SSH antes derruba o seu acesso remoto. Teste em uma VM com acesso pelo console e sempre libere [established,related] e a interface [lo].
#
# >> 23.5 CAPTURA DE TRÁFEGO
#   tcpdump -i any -nn -c 20 port 53   captura 20 pacotes de DNS ([-nn] não resolve nomes nem portas, [-c] limita a quantidade, [any] todas as interfaces). Precisa de root.
#   Filtros: [host 192.168.0.5] | [port 443] | [icmp] | [tcp] | combine com [and], [or], [not].  [-w captura.pcap] grava em arquivo e [-r captura.pcap] lê. O Wireshark abre arquivos .pcap com interface gráfica.
#   Capturar tráfego de terceiros sem autorização é crime em muitos países: use só na SUA rede ou em laboratório.
#   ss -tulnp (portas em escuta) | ss -tn state established (conexões ativas) | ss -s (resumo)


# ==============================================================================
# 24. PADRÕES PARA SCRIPTS PROFISSIONAIS
# ==============================================================================
# >> 24.1 OPÇÕES LONGAS (--dry-run, --help, --arquivo=x)
#   O getopts só entende opções curtas ([-n]). Para opções longas use um laço com while, case e shift. [shift 2] consome a opção e o valor; [--arquivo=x] vem em um parâmetro só e o valor sai com [${1#*=}]. O [--] encerra as opções.
#
#   - Exemplo: [sh e bash | executar: sh script.sh --dry-run --file=dados.txt destino1 destino2]
#-----------------------------------------------------------
#dry_run=0; arquivo=""
#while [ $# -gt 0 ]; do
#    case "$1" in
#        -h|--help) echo "uso: $0 [-n|--dry-run] [-f|--file arquivo | --file=arquivo] destino..."; exit 0 ;;
#        -n|--dry-run) dry_run=1; shift ;;
#        -f|--file) [ $# -ge 2 ] || { echo "falta o valor de $1" >&2; exit 2; }; arquivo="$2"; shift 2 ;;
#        --file=*) arquivo="${1#*=}"; shift ;;
#        --) shift; break ;;
#        -*) echo "opção desconhecida: $1" >&2; exit 2 ;;
#        *) break ;;
#    esac
#done
#echo "dry_run=$dry_run arquivo=$arquivo restante=[$*]"
#-----------------------------------------------------------
#
# >> 24.2 MODO DE SIMULAÇÃO (dry-run) COM UMA FUNÇÃO
#   Uma função [run] executa o comando de verdade OU só o mostra. Todo comando perigoso passa por ela. Em vez de [rm -rf pasta] escreva [run rm -rf pasta].
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#run() { if [ "$dry_run" = 1 ]; then echo "[dry-run] $*"; else "$@"; fi; }
#dry_run=1; run rm -rf algo_importante
#dry_run=0; run echo "executado de verdade"
#-----------------------------------------------------------
#
# >> 24.3 LOG COM DATA E NÍVEIS
#   Padrão: data e hora, nível (INFO, WARN, ERROR) e mensagem. Mensagens de erro vão para o stderr ([>&2]); [tee -a] mostra na tela E grava no arquivo. O [logger -t nome "mensagem"] envia ao log do sistema (veja com [journalctl -t nome]).
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#LOG_FILE=$(mktemp)
#log() { nivel=$1; shift; printf '%s [%s] %s\n' "$(date '+%F %T')" "$nivel" "$*" | tee -a "$LOG_FILE"; }
#log INFO "script iniciado"
#log WARN "disco quase cheio"
#log ERROR "falha ao conectar" >&2
#echo "--- conteúdo do arquivo de log:"; cat "$LOG_FILE"; rm "$LOG_FILE"
#-----------------------------------------------------------
#
# >> 24.4 DATA E HORA (date)
#   date '+%F' (2026-11-13) | '+%T' (23:59:59) | '+%F %T' | '+%Y%m%d_%H%M%S' (bom para nomes de arquivo) | '+%s' (timestamp Unix: segundos desde 1970) | '+%A' dia da semana | '+%u' dia da semana numérico (1 = segunda) | '+%j' dia do ano
#   date -d "yesterday" | date -d "7 days ago" '+%F' | date -d "2026-12-25" '+%s' | date -d @1700000000 (timestamp para data). O [-d] é do GNU date (Linux); no macOS/BSD é diferente.
#   Diferença de datas: converta as duas para timestamp, subtraia e divida por 86400 (segundos em um dia).
#   [$SECONDS] (bash) conta os segundos desde que o script começou: [inicio=$SECONDS; ...; echo "levou $((SECONDS - inicio))s"]. [time comando] mede o tempo de um comando.
#
#   - Exemplo (GNU date): [sh e bash]
#-----------------------------------------------------------
#date '+%F | %T | %Y%m%d_%H%M%S | %A | dia da semana: %u'
#echo "timestamp: $(date +%s)"
#date -d "yesterday" '+ontem: %F'; date -d "7 days ago" '+7 dias atrás: %F'
#d=$(( ( $(date -d "2030-01-01" +%s) - $(date +%s) ) / 86400 )); echo "dias até 2030-01-01: $d"
#date -d @0 -u '+epoch zero: %F %T'
#-----------------------------------------------------------
#
# >> 24.5 CORES NO TERMINAL
#   Códigos ANSI: [\033[0;31m] vermelho | [\033[0;32m] verde | [\033[0;33m] amarelo | [\033[0;34m] azul | [\033[0;35m] magenta | [\033[0;36m] ciano | [\033[1m] negrito | [\033[0m] RESET (volta ao normal). Use [printf] com o marcador [%b], que interpreta o \033 do argumento. O [tput setaf 1] (vermelho), [tput bold] e [tput sgr0] (reset) fazem o mesmo de forma portátil.
#   Só use cores se a saída for um terminal: [ -t 1 ] é verdadeiro quando o stdout é um terminal (e não um pipe ou arquivo). Assim o log em arquivo não fica cheio de códigos.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#if [ -t 1 ]; then VERDE='\033[0;32m'; VERMELHO='\033[0;31m'; RESET='\033[0m'; else VERDE=''; VERMELHO=''; RESET=''; fi
#printf '%b%s%b host1\n' "$VERDE" "ONLINE" "$RESET"
#printf '%b%s%b host2\n' "$VERMELHO" "OFFLINE" "$RESET"
#-----------------------------------------------------------
#
# >> 24.6 MENUS COM SELECT (bash)
#   O [select] monta um menu numerado sozinho e repete até um [break]. A variável recebe o TEXTO da opção e o [$REPLY] o que foi digitado. O prompt é a variável [PS3].
#
#   - Exemplo: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#PS3="Escolha uma opção: "
#select opcao in "Mostrar data" "Mostrar usuário" "Sair"; do
#    case "$opcao" in
#        "Mostrar data") date ;;
#        "Mostrar usuário") whoami ;;
#        "Sair") break ;;
#        *) echo "opção inválida: $REPLY" ;;
#    esac
#done
#-----------------------------------------------------------
#
# >> 24.7 FLOCK (impedir duas execuções ao mesmo tempo)
#   Se o cron disparar o script de novo antes de a execução anterior acabar, as duas rodam juntas e podem estragar arquivos. O [flock] usa um arquivo de trava: [flock -n arquivo.lock comando] (o [-n] desiste na hora, com código 1, se já estiver travado). A trava é liberada sozinha quando o processo termina, mesmo se der erro.
#   No cron: [*/5 * * * * flock -n /tmp/monitor.lock /home/user/monitor.sh]   |   Dentro do script (bash): [exec 9>/tmp/meu.lock; flock -n 9 || { echo "já está rodando" >&2; exit 1; }]
#
#   - Exemplo (precisa do flock): [sh e bash]
#-----------------------------------------------------------
#if command -v flock > /dev/null; then
#    trava=$(mktemp)
#    flock -n "$trava" sh -c 'echo "pegou a trava"; flock -n "$0" true || echo "segunda tentativa recusada (já está travado)"' "$trava"
#    flock -n "$trava" true && echo "depois que a primeira terminou, a trava está livre"
#    rm -f "$trava"
#else echo "flock não instalado"; fi
#-----------------------------------------------------------
#
# >> 24.8 PASTA DO SCRIPT E ARQUIVO DE CONFIGURAÇÃO
#   - Pasta do próprio script (para achar arquivos ao lado dele, mesmo rodando de outro lugar ou pelo cron): [DIR=$(cd "$(dirname "$0")" && pwd)]. No bash, [${BASH_SOURCE[0]}] é mais confiável que o [$0] quando o arquivo é carregado com [source].
#   - Configuração em arquivo separado: [. "$DIR/config.sh"]. O config.sh só tem [VARIAVEL=valor]. Nunca versione senhas: coloque o config.sh no .gitignore e entregue um [config.exemplo].
#   - Valores padrão que o usuário pode sobrescrever pelo ambiente: [LIMITE=${LIMITE:-80}] e rode [LIMITE=90 ./script.sh].
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#DIR=$(cd "$(dirname "$0")" && pwd); echo "pasta do script: $DIR"
#printf 'LIMITE=70\nDESTINO=/tmp/bkp\n' > "$DIR/config.sh"
#. "$DIR/config.sh"; echo "do config: LIMITE=$LIMITE DESTINO=$DESTINO"
#rm "$DIR/config.sh"
#unset LIMITE; LIMITE=${LIMITE:-80}; echo "sem config, valor padrão: $LIMITE"
#-----------------------------------------------------------
#
# >> 24.9 CÓDIGOS DE SAÍDA PADRONIZADOS
#   0 sucesso | 1 erro geral | 2 uso incorreto (opção ou parâmetro inválido) | 124 o [timeout] estourou | 126 comando encontrado, mas sem permissão de execução | 127 comando não encontrado | 128+N terminado pelo sinal N: 130 = Ctrl+C (sinal 2), 137 = kill -9 (sinal 9), 143 = kill (sinal 15).
#   Defina códigos próprios e documente-os no [--help]. Ex: 0 ok, 1 erro, 2 uso, 3 dependência faltando, 4 sem permissão.
#
#   - Exemplo: [sh e bash]
#-----------------------------------------------------------
#sh -c 'exit 3'; echo "exit 3 -> $?"
#naoexiste_cmd 2>/dev/null; echo "comando inexistente -> $?"
#touch sem_exec.sh; ./sem_exec.sh 2>/dev/null; echo "sem permissão de execução -> $?"; rm sem_exec.sh
#sh -c 'kill -9 $$' 2>/dev/null; echo "morto por kill -9 -> $?"
#-----------------------------------------------------------
#
# >> 24.10 MODELO DE SCRIPT PROFISSIONAL (copie e adapte)
#   Junta tudo: modo estrito, ajuda, opções, log, limpeza com trap, validação de entrada e uma função main.
#
#   - Modelo: [SÓ bash | executar: bash script.sh --dry-run /etc/passwd /arquivo_que_nao_existe]
#-----------------------------------------------------------
#set -euo pipefail
#
#dry_run=0
#uso() {
#    cat <<EOF
#Uso: ${0##*/} [opções] ARQUIVO...
#  -n, --dry-run   só mostra o que faria
#  -h, --help      mostra esta ajuda
#EOF
#}
#log() { printf '%s [%s] %s\n' "$(date '+%F %T')" "$1" "$2" >&2; }
#erro() { log ERROR "$1"; exit "${2:-1}"; }
#limpar() { [ -z "${tmp:-}" ] || rm -f "$tmp"; }
#trap limpar EXIT
#
#while [ $# -gt 0 ]; do
#    case "$1" in
#        -h|--help) uso; exit 0 ;;
#        -n|--dry-run) dry_run=1; shift ;;
#        --) shift; break ;;
#        -*) uso >&2; erro "opção desconhecida: $1" 2 ;;
#        *) break ;;
#    esac
#done
#[ $# -ge 1 ] || { uso >&2; erro "informe ao menos um arquivo" 2; }
#
#main() {
#    local arq
#    for arq in "$@"; do
#        [ -f "$arq" ] || { log WARN "ignorando $arq (não é um arquivo)"; continue; }
#        if [ "$dry_run" = 1 ]; then log INFO "[dry-run] processaria $arq"; else log INFO "processando $arq"; fi
#    done
#}
#main "$@"
#-----------------------------------------------------------


# ==============================================================================
# 25. DADOS: AWK AVANÇADO, ARRAYS, CSV, JSON E ALERTAS
# ==============================================================================
# >> 25.1 AWK COM ARRAYS (contar e agrupar)
#   O awk tem arrays associativos (chave e valor). [c[$1]++] conta quantas vezes cada valor da 1ª coluna aparece. Variável que não existe vale 0 (ou vazio), por isso não precisa declarar. [for (k in c) print k, c[k]] percorre o array em ordem NÃO garantida: ordene depois com [sort].
#   Mais recursos: [/regex/ {...}] só nas linhas que casam | [NR>1] pula o cabeçalho | [$3 >= 400] por condição | [BEGIN {FS=","; OFS=";"}] separadores de entrada e saída | [length($0)] | [substr($1,1,3)] | [split($1, partes, ".")] divide em um array | [tolower()] e [toupper()] | [sprintf("%05d", n)] | [!visto[$0]++] só a 1ª vez que a linha aparece (remove duplicadas mantendo a ordem).
#   Somar: [s += $2] e dividir no END | máximo: [if ($2 > max) max = $2].
#
#   - Contagens em um log de acessos: [sh e bash]
#-----------------------------------------------------------
#printf "10.0.0.1 GET /a 200\n10.0.0.2 GET /b 404\n10.0.0.1 GET /c 200\n10.0.0.3 POST /a 500\n10.0.0.1 GET /b 404\n" > acesso.log
#echo "--- acessos por IP:"; awk '{c[$1]++} END {for (ip in c) print c[ip], ip}' acesso.log | sort -nr
#echo "--- por código HTTP:"; awk '{s[$4]++} END {for (cod in s) printf "HTTP %s: %d\n", cod, s[cod]}' acesso.log | sort
#echo "--- taxa de erros:"; awk '$4 >= 400 {erros++} END {printf "%d erros em %d requisições (%.0f%%)\n", erros, NR, erros/NR*100}' acesso.log
#echo "--- linhas sem repetir a 1ª coluna (mantém a ordem):"; awk '!visto[$1]++ {print $1}' acesso.log
#rm acesso.log
#-----------------------------------------------------------
#
#   - Falhas de login SSH (o IP é o 4º campo contando do FIM da linha): [sh e bash]
#-----------------------------------------------------------
#printf "Failed password for root from 1.2.3.4 port 5555 ssh2\nFailed password for ana from 1.2.3.4 port 5556 ssh2\nAccepted password for bia from 5.6.7.8 port 22 ssh2\nFailed password for root from 9.9.9.9 port 7 ssh2\n" > auth.log
#grep "Failed password" auth.log | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr
#grep "Failed password" auth.log | awk '{u[$4]++} END {for (n in u) print u[n], n}' | sort -nr
#rm auth.log
#-----------------------------------------------------------
#
# >> 25.2 MAPFILE (arquivo para array) E CSV
#   - [mapfile -t arr < arquivo] (bash 4+, também [readarray]) lê as linhas do arquivo para um array; o [-t] tira a quebra de linha. [mapfile -t arr < <(comando)] lê a saída de um comando. No sh use [while IFS= read -r linha; do ...; done < arquivo].
#   - CSV simples: [while IFS=, read -r campo1 campo2; do ...; done < arq.csv]. Para PULAR o cabeçalho sem criar subshell, agrupe: [{ read -r cabecalho; while ...; done; } < arq.csv]. Esse método NÃO entende vírgulas dentro de aspas; para CSV complexo use [csvkit], [python] ou o [FPAT] do gawk.
#
#   - Exemplo: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#printf "ana\nbia\ncaio\n" > nomes.txt
#mapfile -t nomes < nomes.txt
#echo "total: ${#nomes[@]} | primeiro: ${nomes[0]} | último: ${nomes[-1]}"
#for n in "${nomes[@]}"; do echo "- $n"; done
#rm nomes.txt
#-----------------------------------------------------------
#
#   - CSV pulando o cabeçalho: [sh e bash]
#-----------------------------------------------------------
#printf "nome,usuario,grupo\nAna Silva,ana,devs\nBia Costa,bia,rh\n" > usuarios.csv
#{ read -r cabecalho; while IFS=, read -r nome usuario grupo; do echo "criar usuário '$usuario' ($nome) no grupo $grupo"; done; } < usuarios.csv
#rm usuarios.csv
#-----------------------------------------------------------
#
# >> 25.3 JSON COM JQ
#   O jq lê e filtra JSON (instale: [pacman -S jq]). [jq '.campo' arq.json] | [-r] sem aspas na saída | [.lista[]] percorre uma lista | [.lista | length] conta | [select(.cpu > 50)] filtra | [-c] um objeto por linha | [curl -s URL | jq -r '.chave'] lê uma API.
#   NUNCA monte JSON à mão com aspas e variáveis: se o valor tiver aspas ou quebra de linha, quebra tudo. Crie com [jq -n --arg nome "$valor" '{nome: $nome}'], que escapa tudo sozinho.
#
#   - Exemplo (precisa do jq): [sh e bash]
#-----------------------------------------------------------
#if command -v jq > /dev/null; then
#    printf '{"servidores":[{"nome":"web1","ativo":true,"cpu":35},{"nome":"db1","ativo":false,"cpu":80}]}' > s.json
#    jq -r '.servidores[] | "\(.nome): ativo=\(.ativo) cpu=\(.cpu)%"' s.json
#    jq '.servidores | length' s.json
#    jq -r '.servidores[] | select(.cpu > 50) | .nome' s.json
#    jq -n --arg msg 'texto com "aspas"' '{texto: $msg}'
#    rm s.json
#else echo "jq não instalado (sudo pacman -S jq)"; fi
#-----------------------------------------------------------
#
# >> 25.4 ALERTAS POR WEBHOOK E E-MAIL
#   Exemplos (NÃO execute com URLs reais em testes; guarde token e URL em um arquivo com [chmod 600], nunca dentro do script):
#     Telegram: curl -fsS --max-time 10 -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" -d chat_id="$CHAT_ID" --data-urlencode text="$mensagem"
#     Discord:  curl -fsS --max-time 10 -H "Content-Type: application/json" -d "$(jq -n --arg c "$mensagem" '{content: $c}')" "$WEBHOOK_URL"
#     Slack:    curl -fsS --max-time 10 -H "Content-type: application/json" --data "$(jq -n --arg t "$mensagem" '{text: $t}')" "$WEBHOOK_URL"
#     E-mail:   echo "corpo" | mail -s "assunto" destino@exemplo.com   (precisa de um servidor de e-mail configurado, como postfix ou msmtp)
#   Boas práticas: [curl -fsS --max-time 10] (falha em erro HTTP, mostra erros e não trava), poucas tentativas ([--retry 2]), e NUNCA derrube o script de monitoramento porque o alerta falhou: [enviar_alerta "$msg" || log WARN "alerta não enviado"].
#   Evite spam: avise só quando o estado MUDAR. Guarde o último estado em um arquivo, compare e grave.
#
#   - Alerta só na mudança de estado (o envio é simulado com echo): [sh e bash]
#-----------------------------------------------------------
#estado_arq=$(mktemp)
#echo "OK" > "$estado_arq"
#for atual in OK OK FALHA FALHA OK; do
#    anterior=$(cat "$estado_arq")
#    if [ "$atual" != "$anterior" ]; then echo "MUDOU de $anterior para $atual -> enviar alerta"; echo "$atual" > "$estado_arq"; else echo "continua $atual (sem alerta)"; fi
#done
#rm "$estado_arq"
#-----------------------------------------------------------


# ==============================================================================
# 26. AMBIENTE DO SHELL: BASH, ZSH, PATH E ARQUIVOS DE CONFIGURAÇÃO
# ==============================================================================
# O shell do TERMINAL onde você digita (provavelmente o zsh, pelo [%] que apareceu no fim da linha) é diferente do shell que executa o SCRIPT (o do shebang). Veja o seu: [echo $SHELL] (shell padrão do usuário) | [ps -p $$ -o comm=] (shell atual) | [chsh -s /bin/bash] troca o padrão.
#
# >> 26.1 ARQUIVOS DE CONFIGURAÇÃO, PATH E ALIAS
#   - bash: [~/.bashrc] (terminais interativos) e [~/.bash_profile] ou [~/.profile] (login). zsh: [~/.zshrc] (interativo) e [~/.zprofile] (login). As alterações valem em novos terminais ou depois de [source ~/.zshrc].
#   - PATH: lista de pastas (separadas por [:]) onde o shell procura comandos, da ESQUERDA para a direita: a primeira que tiver o comando vence. Para chamar seus scripts de qualquer lugar: [mkdir -p ~/bin; cp script.sh ~/bin/meuscript; chmod +x ~/bin/meuscript] e, no .zshrc ou .bashrc, [export PATH="$HOME/bin:$PATH"]. Nunca coloque [.] nem uma pasta vazia no PATH (risco de segurança).
#   - alias: apelido de comando do TERMINAL: [alias ll='ls -lah'] | [alias] lista | [unalias ll] remove. Em scripts os aliases não funcionam por padrão: use funções.
#   - Funções no .bashrc ou .zshrc viram mini-comandos: [mkcd() { mkdir -p "$1" && cd "$1"; }]
#   - Prompt: bash usa [PS1] (exemplo: '\u@\h:\w\$ ') e zsh usa [PROMPT] (exemplo: '%n@%m:%~ %# '). Histórico: [history] | Ctrl+R busca | [!!] repete o último comando | [!$] último argumento do comando anterior.
#
#   - Exemplo (instalar um script no PATH, só nesta execução): [sh e bash]
#-----------------------------------------------------------
#echo "shell padrão: $SHELL"
#echo "$PATH" | tr ':' '\n' | head -n 3
#mkdir -p bin_teste; printf '#!/bin/sh\necho "olá do meuscript"\n' > bin_teste/meuscript; chmod +x bin_teste/meuscript
#command -v meuscript > /dev/null || echo "meuscript ainda não está no PATH"
#PATH="$PWD/bin_teste:$PATH"; meuscript; command -v meuscript
#rm -r bin_teste
#-----------------------------------------------------------
#
# >> 26.2 DIFERENÇAS ENTRE ZSH E BASH (no terminal)
#   - Arrays do zsh começam no ÍNDICE 1 (no bash, em 0). [${arr[-1]}] funciona nos dois.
#   - Variável SEM aspas não é separada em palavras no zsh (no bash é). [arq="a b"; ls $arq] procura um arquivo chamado "a b" no zsh, e dois arquivos ("a" e "b") no bash.
#   - Curinga sem resultado: [ls *.xyz] dá ERRO ("no matches found") no zsh. O bash passa o texto literal.
#   - [read -p "texto" var] NÃO mostra o prompt no zsh (lá o [-p] é outra coisa). No zsh use [read "var?texto"]. O [read -a] do bash vira [read -A].
#   - O zsh marca com [%] quando a última saída não terminou com quebra de linha: [unsetopt PROMPT_SP] desativa.
#   - Regra prática: escreva scripts com [#!/bin/bash] (ou sh), que não são afetados pelo zsh, e ao digitar comandos soltos no terminal lembre das regras do zsh.


# ==============================================================================
# 27. TÓPICOS EXTRAS (eval, substituição de processo, variáveis do bash, qualidade)
# ==============================================================================
# >> 27.1 EVAL E SEUS RISCOS
#   O [eval] executa um TEXTO como código, depois de uma segunda expansão. Se parte do texto vier de um usuário, arquivo ou rede, ele pode executar QUALQUER coisa (injeção de comando). Quase sempre há alternativa: arrays ([cmd=(ls -l); "${cmd[@]}"]), [case], [printf -v], expansão indireta [${!nome}] (bash). Se precisar do eval, valide a entrada antes.
#
#   - Demonstração inofensiva do problema: [sh e bash]
#-----------------------------------------------------------
#entrada="x; echo INJETADO"
#echo "com eval:"; eval "echo $entrada"
#echo "sem eval:"; echo "$entrada"
#-----------------------------------------------------------
#
# >> 27.2 RECURSOS DO BASH
#   - Substituição de processo: [<(comando)] vira um "arquivo" com a saída do comando. Ex: [diff <(sort a.txt) <(sort b.txt)]. Também evita o subshell do pipe: [while read ...; done < <(cmd)].
#   - Expansão indireta: [nome=var; var=10; echo "${!nome}"] mostra 10.
#   - Variáveis úteis: [$LINENO] linha atual | [${FUNCNAME[0]}] função atual | [$BASH_VERSION] | [${PIPESTATUS[@]}] código de cada comando do último pipe | [$RANDOM] | [$SECONDS] | [$HOSTNAME] | [$UID] e [$EUID] | [$PPID].
#   - Depuração com mais informação: [PS4='+ ${BASH_SOURCE}:${LINENO}: '; set -x] mostra arquivo e linha de cada comando. [trap 'echo "erro na linha $LINENO" >&2' ERR] avisa onde um comando falhou.
#
#   - Exemplo: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#nome=var; var=10; echo "indireta: ${!nome}"
#diff <(printf "b\na\n" | sort) <(printf "a\nb\n") && echo "iguais depois de ordenar"
#false | true | false; echo "PIPESTATUS: ${PIPESTATUS[*]}"
#f() { echo "função ${FUNCNAME[0]} chamada na linha $LINENO"; }; f
#(trap 'echo "falhou na linha $LINENO"' ERR; false) || echo "o subshell terminou com código $?"
#-----------------------------------------------------------
#
# >> 27.3 QUALIDADE E TESTES
#   - ShellCheck: analisa o script e aponta erros e más práticas ([shellcheck script.sh]; no Arch: [pacman -S shellcheck]). Para ignorar um aviso consciente: [# shellcheck disable=SC2086] na linha de cima.
#   - shfmt: formata o código de forma padronizada ([shfmt -w -i 4 script.sh]).
#   - Bats: testes automatizados. Arquivo [teste.bats]: [@test "soma 2 + 3" { run ./soma.sh 2 3; [ "$status" -eq 0 ]; [ "$output" = "5" ]; }]. Rode com [bats teste.bats].
#   - Integração contínua (GitHub Actions): rode ShellCheck e Bats a cada push, em [.github/workflows/ci.yml].


# ==============================================================================
# 28. GIT E GITHUB PARA OS SEUS SCRIPTS
# ==============================================================================
#   git init | git status | git add arq (ou [git add -p] para escolher pedaços) | git commit -m "mensagem" | git log --oneline | git diff (o que mudou e não foi adicionado) | git diff --staged | git restore arq (descarta alterações) | git switch -c nome (cria e troca de branch) | git merge nome | git remote add origin URL | git push -u origin main | git pull | git clone URL
#   - Mensagens de commit: curtas, no imperativo, uma ideia por commit ("Adiciona verificador de conectividade", "Corrige validação de parâmetros").
#   - [.gitignore] lista o que NÃO versionar, um padrão por linha: [config.sh], [*.log], [*.tmp], [.env], [relatorios/].
#   - O bit de execução é versionado: se esqueceu o [chmod +x], use [git update-index --chmod=+x script.sh]. [git ls-files -s] mostra o modo (100755 = executável).
#   - Problema clássico vindo do Windows: finais de linha CRLF fazem o script falhar com "bad interpreter: /bin/bash^M". Verifique com [file script.sh]. Corrija com [sed -i 's/\r$//' script.sh] (ou [dos2unix]) e previna com um arquivo [.gitattributes] contendo [*.sh text eol=lf].
#   - NUNCA faça commit de senhas, tokens ou chaves SSH. Se enviou por engano, considere a credencial COMPROMETIDA: revogue e troque (apagar o commit depois não basta). Ferramentas de varredura: gitleaks, git-secrets.
#   - Estrutura sugerida de repositório: README.md | script.sh (ou bin/) | lib/ | exemplos/ | tests/ | config.exemplo | .gitignore | .gitattributes | LICENSE. Para vários exercícios: uma pasta por exercício ou por projeto, com o índice no README da raiz.
#
#   - Repositório de teste que ignora o config.sh (precisa do git): [sh e bash]
#-----------------------------------------------------------
#if command -v git > /dev/null; then
#    git init -q repo_teste && cd repo_teste
#    git config user.email "teste@exemplo.com"; git config user.name "Teste"
#    printf '#!/bin/sh\necho oi\n' > a.sh; chmod +x a.sh
#    printf 'config.sh\n*.log\n' > .gitignore; touch config.sh x.log
#    git add -A; git commit -q -m "Adiciona script de exemplo"
#    echo "arquivos não versionados (vazio = tudo certo):"; git status --short
#    git ls-files -s a.sh
#    git log --oneline
#    cd .. && rm -rf repo_teste
#else echo "git não instalado"; fi
#-----------------------------------------------------------
#
#   - Finais de linha CRLF quebram o shebang: [sh e bash]
#-----------------------------------------------------------
#printf '#!/bin/sh\r\necho oi\r\n' > crlf.sh; chmod +x crlf.sh
#./crlf.sh 2>&1 | head -n 1
#sed -i 's/\r$//' crlf.sh; ./crlf.sh
#rm crlf.sh
#-----------------------------------------------------------


# ==============================================================================
# 29. EXPRESSÕES REGULARES (REGEX)
# ==============================================================================
# Uma expressão regular é um PADRÃO que descreve o formato de um texto. O shell compara o texto com o padrão e responde "casa" (sucesso, código 0) ou "não casa" (código 1). Serve para validar entradas, buscar e trocar trechos de texto.
#
# ONDE USAR (cada ferramenta aceita regex de um jeito):
#   - [grep -E 'padrão' arquivo]  -> mostra as linhas que casam. Opções úteis: -o (só o trecho que casou) | -q (não imprime, só devolve o código) | -v (linhas que NÃO casam) | -i (ignora maiúsculas) | -c (conta as linhas) | -n (mostra o número da linha).
#   - [sed -E 's/padrão/troca/g']  -> substitui o que casou.
#   - [awk '$1 ~ /padrão/']  -> testa uma coluna. [!~] é "não casa".
#   - [[ $var =~ padrão ]]  -> testa uma variável (SÓ bash). Não coloque o padrão entre aspas.
#   - Use sempre a opção -E (regex estendida) no grep e no sed. Sem ela, os símbolos + ? | { } ( ) precisam de barra invertida.
#
# IMPORTANTE: REGEX NÃO É GLOB. No [case], no [ls] e em [*.txt] o asterisco significa "qualquer coisa". Na regex, o asterisco significa "repete o item anterior". O equivalente de [*.txt] em regex é [.*[.]txt$].
#
# >> 29.1 ÂNCORAS E CLASSES (posição e "um caractere entre vários")
#   - [^]      início do texto (da linha).
#   - [$]      fim do texto (da linha).
#   - [.]      qualquer caractere (um só).
#   - [[abc]]  um caractere entre a, b ou c.
#   - [[0-9]]  um dígito. [[a-z]] uma minúscula. [[A-Za-z]] uma letra. [[A-Za-z0-9_]] letra, dígito ou sublinhado.
#   - [[^0-9]] um caractere que NÃO é dígito (o [^] dentro dos colchetes nega).
#   - Sem as âncoras, o padrão pode casar em qualquer pedaço do texto. Com [^...$] ele precisa casar o texto INTEIRO.
#
#   - Exemplo (âncoras e classes): [sh e bash | executar: sh script.sh]
#-----------------------------------------------------------
#echo "tem dígito em algum lugar?"; echo "abc12x" | grep -E '[0-9]'
#echo "só dígitos do começo ao fim?"; echo "abc12x" | grep -E '^[0-9]+$' || echo "não"
#echo "começa com letra:"; printf "abc\n123\nx9\n" | grep -E '^[a-z]'
#echo "termina com .sh:"; printf "a.sh\nb.txt\nc.sh\n" | grep -E '[.]sh$'
#echo "não é dígito:"; echo "a1b2" | grep -oE '[^0-9]'
#-----------------------------------------------------------
#
# >> 29.2 QUANTIFICADORES (quantas vezes o item ANTERIOR se repete)
#   - [+]     uma ou mais vezes.
#   - [*]     zero ou mais vezes.
#   - [?]     zero ou uma vez (opcional).
#   - [{3}]   exatamente 3 vezes.
#   - [{2,4}] de 2 a 4 vezes.
#   - [{2,}]  2 ou mais vezes.
#   - O quantificador vale só para o item imediatamente antes dele: em [ab+] o [+] vale para o b; para repetir "ab" use o grupo [(ab)+].
#   - A regex é "gulosa": pega o trecho mais longo possível. Em [echo "<a><b>" | grep -oE '<.+>'] sai [<a><b>] inteiro, e não só [<a>]. Para pegar só [<a>] use [<[^>]+>].
#
#   - Exemplo (quantificadores): [sh e bash | executar: sh script.sh]
#-----------------------------------------------------------
#echo "5 ou mais dígitos:"; printf "123\n12345\n1234567\n" | grep -E '^[0-9]{5,}$'
#echo "sinal opcional:"; printf "15\n-15\n+15\n" | grep -E '^-?[0-9]+$'
#echo "cor ou colour:"; printf "color\ncolour\ncolr\n" | grep -E '^colou?r$'
#echo "gulosa:"; echo "<a><b>" | grep -oE '<.+>'
#echo "não gulosa (usando [^>]):"; echo "<a><b>" | grep -oE '<[^>]+>'
#-----------------------------------------------------------
#
# >> 29.3 GRUPOS, "OU" E ESCAPE
#   - [( )]  agrupa, para aplicar um quantificador ao conjunto: [^([0-9]{1,3}[.]){3}[0-9]{1,3}$].
#   - [|]    "ou": [^(sim|não)$] casa "sim" ou "não" (o texto inteiro).
#   - [\.] ou [[.]]  ponto literal. Sem o escape, o ponto é "qualquer caractere": [1.5] casa "125". Dentro de colchetes os símbolos já perdem o significado especial, por isso [[.]] é a forma mais segura. Para outros símbolos, escape com barra: [\$] [\*] [\(] [\+] [\?] [\|] [\\].
#   - Dentro de [ ]: o [-] precisa ficar no começo ou no fim ([[-+0-9]] ou [[0-9-]]) e o [^] não pode ser o primeiro.
#
#   - Exemplo (grupos, ou e escape): [sh e bash | executar: sh script.sh]
#-----------------------------------------------------------
#echo "formato de IPv4:"; printf "192.168.0.1\n10.0.0\n999.1.1.1\n" | grep -E '^([0-9]{1,3}[.]){3}[0-9]{1,3}$'
#echo "sim ou não:"; printf "sim\nnão\ntalvez\n" | grep -E '^(sim|não)$'
#echo "ponto sem escape casa errado:"; echo "125" | grep -E '^1.5$'
#echo "ponto escapado não casa:"; echo "125" | grep -E '^1[.]5$' || echo "não casou, correto"
#echo "hora HH:MM:"; printf "09:30\n23:59\n24:00\n7:5\n" | grep -E '^([01][0-9]|2[0-3]):[0-5][0-9]$'
#-----------------------------------------------------------
#   (Nota: o padrão do IPv4 só confere a FORMA. [999.1.1.1] passa. Para validar de verdade, separe as 4 partes e compare cada uma com 255.)
#
# >> 29.4 CLASSES POSIX (nomes no lugar de intervalos)
#   - Funcionam dentro de colchetes duplos: [[[:digit:]]] é um dígito. Evitam problemas de idioma (locale) com intervalos como [a-z], que em alguns sistemas incluem maiúsculas.
#   - [[:digit:]] dígito | [[:alpha:]] letra | [[:alnum:]] letra ou dígito | [[:upper:]] maiúscula | [[:lower:]] minúscula | [[:space:]] espaço, tab ou quebra de linha | [[:blank:]] espaço ou tab | [[:punct:]] pontuação.
#   - Atalhos como [\d], [\w] e [\s] NÃO existem no grep -E padrão. Use [[0-9]], [[A-Za-z0-9_]] ou [[:space:]]. (O [grep -P] tem esses atalhos, mas não é padrão em todos os sistemas.)
#
#   - Exemplo (classes POSIX): [sh e bash | executar: sh script.sh]
#-----------------------------------------------------------
#printf "abc\nABC\n123\na1\n" | grep -E '^[[:lower:]]+$'
#printf "abc\nABC\n123\na1\n" | grep -E '^[[:alnum:]]+$'
#echo "a   b	c" | grep -oE '[[:space:]]+' | wc -l
#-----------------------------------------------------------
#
# >> 29.5 NA PRÁTICA: GREP, SED, AWK E [[ =~ ]]
#   - [grep -q] só devolve o código, então serve direto no if: [if echo "$x" | grep -Eq '^[0-9]+$'; then ...; fi]. Funciona em sh e bash, mas cria processos. Para texto que está em variável, em sh prefira o [case].
#   - [sed -E 's/(parte1)(parte2)/\2 \1/'] os parênteses "capturam" partes que podem ser reusadas na troca como [\1], [\2]... Em [sed -E] o [&] representa o trecho inteiro que casou.
#   - [awk '$2 ~ /^[0-9]+$/'] mostra só as linhas em que a coluna 2 é número. [awk '$2 !~ /^[0-9]+$/ {print "linha " NR " inválida"}'] aponta as erradas.
#   - [[ $x =~ padrão ]] (SÓ bash): se casar, o array [BASH_REMATCH] guarda o resultado: [${BASH_REMATCH[0]}] é o trecho inteiro e [${BASH_REMATCH[1]}], [${BASH_REMATCH[2]}]... são os grupos de parênteses.
#   - Guarde padrões longos em variável e use SEM aspas: [re='^[0-9]+$'; [[ $n =~ $re ]]]. Entre aspas o padrão vira texto literal.
#   - [case] também testa formato, mas com GLOB e não regex: [case "$n" in ''|*[!0-9]*) echo "não é número";; esac] funciona em qualquer sh.
#
#   - Exemplo (grep, sed e awk): [sh e bash | executar: sh script.sh]
#-----------------------------------------------------------
#n="2026"
#if echo "$n" | grep -Eq '^[0-9]+$'; then echo "$n é número"; else echo "$n não é número"; fi
#echo "troca a ordem de dia/mês/ano:"; echo "18/11/2026" | sed -E 's/([0-9]{2})\/([0-9]{2})\/([0-9]{4})/\3-\2-\1/'
#echo "remove espaços do começo e do fim:"; echo "   texto   " | sed -E 's/^[[:space:]]+|[[:space:]]+$//g' | cat -A
#echo "coluna 2 é número?"; printf "a 10\nb x\nc 30\n" | awk '$2 ~ /^[0-9]+$/ {print $1 " ok"} $2 !~ /^[0-9]+$/ {print $1 " inválido"}'
#echo "case (glob):"; for x in 12 1a ""; do case "$x" in ''|*[!0-9]*) echo "'$x' não é número";; *) echo "'$x' é número";; esac; done
#-----------------------------------------------------------
#
#   - Exemplo (regex dentro do bash, com grupos): [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#re='^([0-9]{2}):([0-9]{2})$'
#h="14:35"
#if [[ $h =~ $re ]]; then
#    echo "tudo: ${BASH_REMATCH[0]} | hora: ${BASH_REMATCH[1]} | minuto: ${BASH_REMATCH[2]}"
#else
#    echo "formato inválido"
#fi
#[[ "abc" =~ ^[0-9]+$ ]] || echo "abc não é número"
#-----------------------------------------------------------
#
# >> 29.6 RECEITAS PRONTAS (copie e adapte; todas com [grep -E] ou [[ =~ ]])
#   - Inteiro:                  [^[0-9]+$]
#   - Inteiro com sinal:        [^[+-]?[0-9]+$]
#   - Decimal com ponto:        [^[0-9]+([.][0-9]+)?$]
#   - Decimal com ponto ou vírgula: [^[0-9]+([.,][0-9]+)?$]
#   - Só letras (sem acento):   [^[A-Za-z]+$]
#   - Nome de usuário Linux:    [^[a-z_][a-z0-9_-]{0,31}$]
#   - Hora HH:MM:               [^([01][0-9]|2[0-3]):[0-5][0-9]$]
#   - Data DD/MM/AAAA (forma):  [^[0-9]{2}/[0-9]{2}/[0-9]{4}$]
#   - CEP:                      [^[0-9]{5}-?[0-9]{3}$]
#   - IPv4 (forma):             [^([0-9]{1,3}[.]){3}[0-9]{1,3}$]
#   - Endereço MAC:             [^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$]
#   - E-mail (simples):         [^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$]
#   - Linha de comentário:      [^[[:space:]]*#]
#   - Linha vazia ou só espaços: [^[[:space:]]*$]
#   - Extensão do arquivo:      [[.]sh$]
#
#   - Teste das receitas: [SÓ bash | executar: bash script.sh]
#-----------------------------------------------------------
#testa() { if [[ $2 =~ $1 ]]; then echo "casa    : '$2'"; else echo "NÃO casa: '$2'"; fi; }
#testa '^[+-]?[0-9]+$' "-42"
#testa '^[+-]?[0-9]+$' "4.2"
#testa '^[0-9]+([.,][0-9]+)?$' "10,50"
#testa '^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$' "aa:bb:cc:00:11:22"
#testa '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$' "ana@exemplo.com"
#testa '^[0-9]{5}-?[0-9]{3}$' "60000-000"
#testa '^[[:space:]]*#' "   # comentário"
#-----------------------------------------------------------
#
# >> 29.7 ERROS COMUNS
#   - Esquecer o [-E] no grep e no sed: [+], [?], [|], [{}] e [()] viram texto comum e o padrão "não funciona".
#   - Esquecer as âncoras na validação: [[0-9]+] aceita "abc12x"; use [^[0-9]+$].
#   - Padrão entre aspas no [[ =~ ]]: vira comparação literal. Use variável sem aspas.
#   - Ponto sem escape: [.] casa qualquer caractere. Para o ponto de verdade use [[.]] ou [\.].
#   - Aspas duplas no padrão do grep: o shell expande [$] e crases antes do grep ver. Use aspas SIMPLES no padrão: [grep -E '^[0-9]+$'].
#   - Misturar glob com regex: [*.txt] (glob) não é [.*[.]txt$] (regex).
#   - Usar regex para tudo: para validar IP, data ou e-mail de verdade a regex só confere a forma; confira os valores com aritmética ou com ferramentas próprias.
#   - Dica de depuração: use [grep -o] para ver exatamente o trecho que casou, e [grep -v] para ver o que ficou de fora.
