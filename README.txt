Membros do grupo:
	Igor Fratel Santana 9793565
	Renan Costa Laiz 9779089
	Renan Tiago dos Santos Silva 9793606

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
PRIMEIRA FASE:
Detalhes importantes:
 >No comando SAVE, o novo rbp vai apontar para a posição da pilha onde o antigo rbp está guardado (topo - 1)
 >A ordem esperada de comandos rotineiros para chamar uma função com variáveis locais seria: CALL -> SAVE -> ALC -> FRE -> REST -> RET
 	*No entanto, como a função fatorial recursiva passada para nós como teste não utiliza os comandos SAVE e REST, incluímos o SAVE no CALL e o REST no RET.
 	*Portanto, a ordem fica CALL -> ALC -> FRE -> RET.
 >Estavamos usando o numero de intruções a serem executadas pela maquina virtual como o numero de instruções no programa recebido.
  Isso não é o suficiente para programas com loop, portanto fixamos o número 100000

Como executar:
	python montador < programa.txt > motor.c
	make
	./motor
--------------------------------------------------------------------------------------------------------------------------------------------------------------------



SEGUNDA FASE:

Nosso programa ainda não está executável. Apenas escrevemos as funções pedidas e pretendemos organizar tudo até a terceira fase.


--------------------------------------------------------------------------------------------------------------------------------------------------------------------
TERCEIRA FASE:

>Como executar:

./montador prog0.txt...progN.txt <--- Recebe como argumento os arquivos .txt contendo os programas em linguagem de montagem a serem
																	  	executados pelos robôs do jogo. Gera um arquivo "programas.c" que contém os vetores de programas
																			de todos os programas passados como parâmetro e uma função que retorna esses vetores dado um índice.
																			Será usado pelo nosso programa para criar os robôs com seus devidos programas.

 make                           <--- Compilará os arquivos .c e gerará o executável "jogo", que é o principal do nosso EP

./gerador_terreno      					 <--- Gera o arquivo Terreno.txt que será usado pelo programa

./jogo                           <--- Executa a batalha de robôs

>jogo:
	O arquivo principal do nosso programa é o jogo.c, que de fato gera a simulação do jogo, chamando as funções que criam a arena,
	inserem os robôs, etc.
 	Por esse motivo, o executável gerado pelo comando make do nosso EP será "jogo"

>gerador_terreno.c:
	Programa criado com o intuito de inicializar os atributos da arena, de forma randômica, especificando localização das bases dos exércitos, dos repositórios de cristais (e quantidade de cada repositório), de cada robô e do tipo de terreno que cada célula deve ter. O mapa é inicializado a partir de um arquivo gerado pelo gerador_terreno, mas as posições dos robôs são aleatórias
	Quando executado o comando "./gerador_terreno", será gerado um arquivo Terreno.txt que será lido pelo nosso programa "jogo".

>montador:
	Versão alterada do montador das fases anteriores, para que mais de um programa seja montado.
	Recebe os arquivos de programas em linguagem de montagem e gera um arquivo programas.c conténdo os vetores dos programas,
	semelhante ao motor.c das fases anteriores. No entanto, ele não executa as instruções dos vetores, apenas contém uma função
	que os retorna (será chamada no jogo.c). Por exemplo, se a função "devolve_programa" for chamada com parâmetro 0, ela retornará
	o primeiro vetor de programa a ser montado.

>types.h
  Para evitar problemas de dependência circular nos #include espalhados pelo nosso programa, decidimos mover todas as structs,
	unions e etc para o arquivo types.h, que é incluido por quase todos os programas.

>macros.txt
  Arquivo contendo os "macros" usados para certas instruções e como enxergamos as coordenadas na matriz
	Por exemplo, ao invés de escrevermos um prog0.txt contendo:
		PUSH 0
		SYS 0
	Podemos escrever:
		PUSH CIMA
		SYS MOV
	Isso torna os programas mais claros

>display_game.py
	Fizemos algumas modificações nas instruções recebidas por esse programa, de forma a facilitar o desenvolvimento.
	Ele já conhece os arquivos de imagem das bases e as desenha com a instrução "base numero_arquivo x y".
	A instrução "cristal quantidade x y", desenha até 3 cristais em uma posição especificada
	A instrução "terreno x y tipo", desenha um terreno especificado na posição especificada, sendo que "tipo" pode ser
	"plano", "floresta" ou "rio". Células não especificadas recebem automaticamente o tipo "plano"
	O resto das instruções são iguais à versão anterior, "ri, oi, oj, di, dj".

>PUSHCELL
	Adicionamos uma nova instrução de máquin, chamada PUSHCELL que:
	"Recebe como argumento uma direção, empilha a célula adjacente ao robô que corresponde a essa direção.
	 Caso a célula não exista(por exemplo, se o robô estiver em uma borda), empilha -1."
	Ela foi escrita para ser usada em conjunto com ATR, para empilhar a célula desejada e depois
	receber algum atributo dela.

Vida: Cada robô começa com 10 pontos de vida, sempre que for atacado, perde um ponto. Ao zerar sua vida, o robô é eliminado da arena. 
Se não houverem mais robôs, o exército é eliminado da arena.

Obs 1: Os robôs podem passar em cima dos cristais, uma vez que eles poderiam servir de "barreiras" quando os robôs já estivessem
carregados com um número de cristais suficiente.
Obs 2: O nosso programa não permite receber programas dos jogadores no meio da partida, pelo motivo de que os cristais estão visíveis
após o início do jogo, e mudar o programa já sabendo aonde estão os cristais perderia a graça do jogo, assim como não mostrar os
cristais para os jogadores.
Obs 3: Pergunta-se ao usuário duas vezes o número de exércitos quanto o número de robôs, tais perguntas servem para rodar o
gerador_terreno.c e o jogo.c. Decidimos por não unificar as perguntas em um único código pois pretendemos deixar a comunicação com o
jogador a mais claro possível na quarta e última fase do projeto.
Obs 4: Por definição, decidimos que a arena será de 15 x 15, sendo o número mínimo de exércitos igual
a 2 e o máximo igual a 5, para permitir a boa fluidez e jogabilidade do jogo. Mais do que isso, definiu-se que os exércitos devem ter
entre 1 e 5 robôs.
Obs 5: O que define um robô pertencer a um exército é a cor do hexágono que aparece abaixo do robô, e não os personagens (pokemons) em si.

PARA TESTAR:
Dentro da pasta "programasteste" foram definidos alguns programas a serem inputados junto com um terreno apropriado para o teste.
Vale ressaltar que, os terrenos gerados nessa seção foram gerados apenas para visualização, não possuem aleatoriedade de atributos
como cristais e terrenos, são apenas programas de teste. Para rodá-los, basta colocá-los na pasta "src" e compilar o programa como
especificado acima (não sendo necessário criação de uma arena, uma vez que o Terreno.txt para ambos os testes já está feito).

cristais_e_robos: Dois exércitos, um robô em cada exército. Teste que visa mostrar como os robôs interagem com os cristais quando ambos
dividem a mesma célula.

recolhe_cristal: Dois exércitos, um robô em cada exército. Teste que visa mostrar como os robôs colhem os cristais.

Os arquivos prog0.txt e prog1.txt também representam um teste simples, em que os robôs ficam em loop, não importando em qual arena eles
estão.

---------------------------------------------------------------------------------------------------------------------------------------
QUARTA FASE:
Novos comandos para serem utilizados pelos jogadores em uma linguagem de alto nível:
CRI_CIMA - VERIFICA CRISTAL NA CÉLULA DE CIMA  
CRI_DSUP - VERIFICA CRISTAL NA CÉLULA SUPERIOR DIREITA
CRI_DINF - VERIFICA CRISTAL NA CÉLULA INFERIOR DIREITA
CRI_BAIXO - VERIFICA CRISTAL NA CÉLULA DE BAIXO
CRI_EINF - VERIFICA CRISTAL NA CÉLULA INFERIOR ESQUERDA
CRI_ESUP - VERIFICA CRISTAL NA CÉLULA SUPERIOR ESQUERDA

REC_CIMA - RECOLHE CRISTAL NA CÉLULA DE CIMA    
REC_DSUP - RECOLHE CRISTAL NA CÉLULA SUPERIOR DIREITA 
REC_DINF - RECOLHE CRISTAL NA CÉLULA INFERIOR DIREITA 
REC_BAIXO - RECOLHE CRISTAL NA CÉLULA DE BAIXO
REC_EINF - RECOLHE CRISTAL NA CÉLULA INFERIOR ESQUERDA 
REC_ESUP - RECOLHE CRISTAL NA CÉLULA SUPERIOR ESQUERDA 

MOV_CIMA - MOVE PARA CÉLULA DE CIMA  
MOV_DSUP - MOVE PARA CÉLULA SUPERIOR DIREITA 
MOV_DINF - MOVE PARA CÉLULA INFERIOR DIREITA 
MOV_BAIXO - MOVE PARA CÉLULA DE BAIXO
MOV_EINF - MOVE PARA CÉLULA INFERIOR ESQUERDA 
MOV_ESUP - MOVE PARA CÉLULA SUPERIOR ESQUERDA 

ATQ_CIMA - ATACA O PERSONAGEM INIMIGO NA CÉLULA DE CIMA    
ATQ_DSUP - ATACA O PERSONAGEM INIMIGO NA CÉLULA SUPERIOR DIREITA  
ATQ_DINF - ATACA O PERSONAGEM INIMIGO NA CÉLULA INFERIOR DIREITA  
ATQ_BAIXO - ATACA O PERSONAGEM INIMIGO NA CÉLULA DE BAIXO 
ATQ_EINF - ATACA O PERSONAGEM INIMIGO NA CÉLULA INFERIOR ESQUERDA  
ATQ_ESUP - ATACA O PERSONAGEM INIMIGO NA CÉLULA SUPERIOR ESQUERDA  

DEP_CIMA - DEPOSITA CRISTAL NA CÉLULA DE CIMA (em uma base inimiga)  
DEP_DSUP - DEPOSITA CRISTAL NA CÉLULA SUPERIOR DIREITA (em uma base inimiga)   
DEP_DINF - DEPOSITA CRISTAL NA CÉLULA INFERIOR DIREITA (em uma base inimiga)  
DEP_BAIXO - DEPOSITA CRISTAL NA CÉLULA DE BAIXO (em uma base inimiga)  
DEP_EINF - DEPOSITA CRISTAL NA CÉLULA INFERIOR ESQUERDA (em uma base inimiga)  
DEP_ESUP - DEPOSITA CRISTAL NA CÉLULA SUPERIOR ESQUERDA (em uma base inimiga)  

Nessa fase, fizemos com que o compilador reconheça o condicional else
de forma que seja reconhecida a sintaxe: 
if(condição) {
	código;
	código;
}
else {
	código;
	código;
}
Infelizmente tivemos problemas para implementar o else if, utilizando a solução que encontramos 
para fazer com que o compilador o reconheça.

COMO RODAR O JOGO:
1. Criar o terreno, informando o número de exércitos e com quantos robôs cada exército deve ter através dos comandos:
$ gcc gerador_terreno.c
./a.out

2. Modificar os arquivos progX.txt da pasta "comandos". Por exemplo, se são dois jogadores, os arquivos prog0.txt e prog1.txt devem ser alterados com o código de cada jogador. Se são 3 jogadores, os arquivos prog0.txt, prog1.txt e prog2.txt devem ser alterados e assim por diante. Não é preciso deletar nenhum arquivo dessa pasta, apenas editar os .txt em quantidade apropriada para o número de jogadores, sempre começando pelo prog0.txt. 

3. Rodar o jogo em si, informando o número de exércitos e o de robôs que cada exército deve ter:
$ make
$ ./jogo