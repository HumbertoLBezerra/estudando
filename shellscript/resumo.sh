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
#for i in 1 2 3; do for j in 1 2 3; do echo "$i x $j = $((i * j))"; done; done#!/bin/sh
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