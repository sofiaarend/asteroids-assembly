;PROJETO  
;######################################################################################################################################################################################
;												[MARIA DUARTE]	[SOFIA AREND]									    
;   											  [86474]		   [86513]									   
;######################################################################################################################################################################################

;CONSTANTES
ESCREVER		EQU		FFFEh 					; o que escreve
CURSOR			EQU		FFFCh					; zona onde vai escrever

CURSOR_CORD		EQU		FFF4h
ESCREVER_CORD	EQU		FFF5h

INT_MASK_ADDR   EQU 	FFFAh					; o sitio das interrupcoes 
INT_MASK		EQU		1100000000011111b
MASK_SEM_TIMER	EQU		0100000000000000b

SP_INICIAL      EQU     FDFFh
TimerValue 		EQU 	FFF6h 					; endereço do Temporizador
TimerControl	EQU 	FFF7h 					; endereço do controlo do temporizador
TimeLong 		EQU 	0001h
EnableTimer 	EQU 	0001h 

CARDINAL		EQU     '#'
LIM_1F			EQU		004Fh					; coluna 80 linha 0
LIM_2F			EQU		174Fh					; culuna 80 linha 23 
POS_INICIAL		EQU		0502h 					; correspode a posicao inicial do corpo da nave 
CORPO			EQU		')'
CANHAO			EQU		'>'
ASA_S			EQU		'\'
ASA_I			EQU		'/'
ESPACO			EQU     ' '
LETRA__			EQU		'-'
POS_GAMEOVER	EQU		0C0Dh
POS_LETRA1		EQU		0C23h
POS_FIM_DO_JOGO	EQU		0C22h
POS_F_1			EQU		0C32h
POS_LETRA2		EQU		0E20h
POS_F_2			EQU		0E35h
POS_TIRO		EQU		0000h
MASCARA			EQU		1000000000010110b

ASTEROIDE		EQU		'*'


;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;TABELA DE INTERRUPCOES
				ORIG	FE00h
I0				WORD	BOTAO_I0
I1				WORD	BOTAO_I1
I2				WORD	BOTAO_I2
I3				WORD	BOTAO_I3
I4				WORD	BOTAO_I4

				ORIG	FE0Eh
IE				WORD	SAIR

				ORIG 	FE0Fh 				; FE0Fh = FE00h + Fh (Fh = 15)
INT15 			WORD 	TEMP 				; Preenchimento da posição 15 da Tabela de
											; Interrupções

;--------------------------------
;--------------------------------

;FLAGS e str's
				ORIG 	8000h
AST				TAB		20				
MENSAGEM_1		STR		'Prepare-se ',FIM_MENSAGEM
MENSAGEM_2		STR		'Prima o botao IE',FIM_MENSAGEM
FIM_MENSAGEM	STR		'@'
FIM_TEXTO		STR     'Fim do jogo.',FIM_MENSAGEM
TEXT3			STR		'OPS!!MORREU... E AGORA? TRY AGAIN',FIM_MENSAGEM



Flagbaixo		WORD	0000h
Flagcima		WORD	0000h
Flagesquerda	WORD	0000h
Flagdireita		WORD	0000h
Flag_IE			WORD	0000h
Flagtiro		WORD	0000h
Timer			WORD	0000h
Flageesc_ast	WORD	0000h
Flagasteroide	WORD	0000h
FlagExisteTiro	WORD 	0000h 
NUM_ALEATORIO	WORD	0421h
POS_OBS			WORD	0000h
POS_AST			WORD	0000h
POS_NAVE		WORD	0000h	
LINHA_RANDOM	WORD	0000h
contador		WORD	0004h
CONTADOR_12		WORD	0000h


;--------------------------------

;--------------------------------

				ORIG	0000h
				MOV		R7, FFFFh
				MOV		M[CURSOR], R7
				MOV     R7, SP_INICIAL
                MOV     SP, R7			;inicializar o cursor, permitindo o seu posicionamento na janela de texto
				MOV     R7, INT_MASK
				MOV		M[INT_MASK_ADDR],R7 	;ativar as interrupcoes
				MOV 	R7,TimeLong
				MOV 	M[TimerValue],R7 ; definir valor de contagem do timer
				MOV 	R7,EnableTimer
				MOV 	M[TimerControl],R7 ; inicia contagem	

				ENI
				MOV		R1,POS_INICIAL
				CALL 	ESCREVE_TELA_1
				CALL	ESCREVE_TELA_2
				CALL	BOTON
				CALL 	LINHA1
				CALL	LINHA2
				CALL	ESCREVE_NAVE

Ciclo_jogo:		CALL	down
				CALL	up
				CALL	left
				CALL	right
				CALL	shoot
				CALL	Reset
				
				BR 		Ciclo_jogo
FIM_DO_JOGO:  	CALL	LIMPA_ECRA
				CALL	CREATE_FINAL
				RET
				

				;CALL	FimJogo_
		
Reset:			CMP M[Timer], R0
				CALL.NZ ResetTimer
				RET
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------				
;															LIMITES SUPERIOR E INFERIOR				
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;LIMITE SUPERIOR 
LINHA1:			PUSH 	R3
				MOV 	R3,0000h
				MOV 	R2,CARDINAL
CICLO_1:		MOV 	M[CURSOR],R3 
				MOV 	M[ESCREVER],R2			;mandamos escrever # nas poscições
				INC 	R3						;incremeto da posicao para a coluna a seguir
				CMP     R3,LIM_1F				;comparar a coluna em que se encontra com a coluna final da primeira linha para saber quando parar de colocar #
				BR.NZ   CICLO_1 				;senao tiver chegado a ultima coluna volta a fazer tudo de novo 
				POP		R3						; escreve nessa posicao e incrementa, passando para a seguinte
				RET
;--------------------------------------
;--------------------------------------				
;LIMITE INFERIOR
		
LINHA2:			PUSH  	R3
				MOV 	R3,1700h
				MOV 	R2,CARDINAL
CICLO_2:		MOV 	M[CURSOR],R3 
				MOV 	M[ESCREVER],R2			;mandamos escrever # nas poscições
				INC 	R3						;incremeto da posicao para a coluna a seguir
				CMP     R3,LIM_2F				;comparar a coluna em que se encontra com a coluna final da primeira linha para saber quando parar de colocar #
				BR.NZ   CICLO_2 				;senao tiver chegado a ultima coluna volta a fazer tudo de novo
				POP		R3						; escreve nessa posicao e incrementa, passando para a seguinte
				RET
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------  
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------  
;															FUNCOES QUE ESCREVEM E APAGAM A NAVE
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------  
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------- 

;DEFENIR A NAVE 
ESCREVE_NAVE:	PUSH    R1						;aponta o cursor para a posicao do corpo da nave e escreve o caracter que lhe corresponde
                MOV 	R6,CORPO
				MOV 	M[CURSOR],R1
				MOV 	M[ESCREVER],R6

				MOV 	R6,CANHAO				;aponta o cursor para a posicao do canhao da nave e escreve o caracter que lhe corresponde
				INC 	R1
				MOV 	M[CURSOR],R1
				MOV 	M[ESCREVER],R6

				MOV 	R6, ASA_S				;aponta o cursor para a posicao da asa superior da nave e escreve o caracter que lhe corresponde
				DEC 	R1						
				SUB 	R1, 0100h
				MOV 	M[CURSOR],R1
				MOV 	M[ESCREVER], R6

				MOV 	R6, ASA_I				;aponta o cursor para a posicao da nave inferior e escreve o caracter que lhe corresponde
				ADD 	R1, 0200h
				MOV 	M[CURSOR],R1
				MOV 	M[ESCREVER], R6
				
                POP     R1
				RET
;--------------------------------------
;--------------------------------------
APAGA_NAVE:     PUSH    R1
                MOV     R6, ESPACO 				;vais subsittuir cada parte da nave por um espaco apagando-a 

				MOV 	M[CURSOR],R1
				MOV 	M[ESCREVER],R6

				INC 	R1
				MOV 	M[CURSOR],R1
				MOV 	M[ESCREVER],R6

				DEC 	R1
				SUB 	R1, 0100h        
				MOV 	M[CURSOR],R1
				MOV 	M[ESCREVER], R6

				ADD 	R1, 0200h
				MOV 	M[CURSOR],R1
				MOV 	M[ESCREVER], R6
				
                POP     R1
				RET
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;														FLAGS RELACIONADAS COM O MOVIMENTO DA NAVE 
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
BOTAO_I0:		INC 	M[Flagbaixo] 				;Interrupcao 0 , alteracao da Flagbaixo que permite o movimento da nave para baixo
				RTI
				
down:			CMP		M[Flagbaixo],R0 			;Verifica se vai haver movimento da nave para baixo 
				CALL.NZ	desce
				RET
				
;---------------------------------------------------
;---------------------------------------------------
				
BOTAO_I1:		INC		M[Flagcima]					;Interrupcao 1, alteracao da Flagcima que permite o movimento da nave para cima 
				RTI
				
up: 			CMP		M[Flagcima],R0				;Verifica se vai haver movimento da nave para cima
				CALL.NZ 	sobe
				RET

;---------------------------------------------------
;---------------------------------------------------
	
				
BOTAO_I2:		INC 	M[Flagesquerda]				;Interrupcao 2, alteracao da Flagesquerda que permite o movimento da nave para a esquerda 
				RTI
				
left:			CMP		M[Flagesquerda],R0			;Verifica se vai haver movimento da nave para a esquerda
				CALL.NZ	esquerda
				RET
				
;---------------------------------------------------
;---------------------------------------------------

BOTAO_I3:		INC		M[Flagdireita]				;Interrupcao 3, alteracao da Flagdireita que permite o movimento da nave para a direita 
				RTI
				
right:			CMP		M[Flagdireita],R0			;Verifica se vai haver movimento da nave para a direita
				CALL.NZ	direita
				RET
			
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;															PRIME IE E VAI PARA O MENU PRINCIPAL
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------

SAIR:			INC		M[Flag_IE]					;Interrupcao E, alteracao da Flag_IE que permite o inicio do jogo 
				RTI
				
BOTON:			CMP		M[Flag_IE],R0				;Verifica se o botao IE foi primido, se sim vai chamar a funcao BOTAO
				BR.Z	BOTON
				CALL 	BOTAO
				RET
				
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;															FUNCOES RELACIONADAS COM O TIRO
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
				
BOTAO_I4:		INC 	M[Flagtiro]					;Interrupcao 4, alteracao da Flagtiro que permite a criacao do primeiro tiro da nave  
				RTI	

;---------------------------------------------------
;---------------------------------------------------
				
shoot:			CMP		M[Flagtiro],R0				;Verifica se vai haver criacao do tiro na primeira posicao, isto e, a seguir do canhao da nave
				CALL.NZ	cria_tiro
				RET	

;---------------------------------------------------
;---------------------------------------------------
				
cria_tiro:      PUSH 	R3							;Tal como o nome indica esta funcao serve para criar o tiro 
				PUSH 	R2
				PUSH 	R1							;Aqui e necessario decidir quando o tiro pode ser criado, tendo em conta que o programa so cria um unico tiro
				CMP 	M[FlagExisteTiro], R0		;Ele verifica se existe tiro ou nao, se existir, se a flag for 1 ele nao cria um tiro 
				BR.NZ	Fim_cria_tiro				; se a flag for 0 entao quer dizer que nao ha tiro, logo pode criar um 
				MOV 	R3,LETRA__					;aponta-se o cursor para a posicao a frente do canhao da nave
				ADD		R1,0002h					;isto indica que esta e a posicao na qual vai escrever
				MOV 	M[POS_TIRO], R1				;nesta ele escreve o caracter correspondente ao tiro '-'
				MOV		M[CURSOR],R1
				MOV		M[ESCREVER],R3
				MOV		M[Flagtiro],R0				;coloca a flagtiro a zero pois ja criou o tiro
				MOV		R2, 1						; coloca a flagexistetiro tambem a zero pelo mesmo motivo
				MOV		M[FlagExisteTiro], R2		; ou seja oocorre uma actualizacao dos valores das flags
Fim_cria_tiro:	POP 	R1
				POP		R2
				POP 	R3
				RET

;---------------------------------------------------
;---------------------------------------------------
esc_tiro:		PUSH R1								
				PUSH R3								
				MOV R3, LETRA__
				MOV R1, M[POS_TIRO]
				MOV M[CURSOR], R1
				MOV	M[ESCREVER],R3
				POP R3
				POP R1
				RET
;---------------------------------------------------
;---------------------------------------------------				
apaga_tiro:		PUSH	R1
				MOV		R1,M[POS_TIRO]
				MOV 	R2,ESPACO	
				MOV		M[CURSOR],R1
				MOV		M[ESCREVER],R2
				POP		R1
				RET
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------

				
TEMP:			PUSH	R7
				PUSH	R3
				
				MOV 	R7,TimeLong
				MOV 	M[TimerValue],R7 			; definir valor de contagem do timer
				MOV 	R7,EnableTimer
				MOV 	M[TimerControl],R7 			;inicia contagem
				
				INC 	M[CONTADOR_12]
				INC		M[Timer]
				
				MOV     R7,12						;Verifica se a posicao e divisivel por 12 
				CMP		M[CONTADOR_12],R7
				BR.Z	DUAS_FLAGS					;se isto acontecer vai incrementar as duas flags associadas a esta situacao
				
				MOV		R3,2						;Verifica se a posicao e par 
				MOV		R4,M[CONTADOR_12]
				DIV		R4,R3						;se isto acontecer vai incrementar a duas flag associada a esta situacao
				CMP		R3,R0
				BR.Z	UMA_FLAG
				BR		FIM_1
				
FIM_1:			POP		R3							;se a posicao sao for impar ele nao incrementa nenhuma flag,fazendo simplesmente RET
				POP		R7
				RTI
				
DUAS_FLAGS:		INC		M[Flageesc_ast]				
				INC		M[Flagasteroide]			
				MOV		M[CONTADOR_12],R0
				BR		FIM_1
				
UMA_FLAG:		INC		M[Flagasteroide]
				BR		FIM_1
				
;------------------------------------------
;------------------------------------------
				
TIMER:			CMP		M[Timer],R0
				CALL.NZ	move_tiro
				RET
				
move_tiro:		PUSH	R1
				PUSH 	R2
				PUSH 	R3
				CMP 	M[FlagExisteTiro],  R0		;Rotina so e efetuada quando FlagEscreveTiro=1
				BR.Z	FINAL
				MOV		R1,M[POS_TIRO]
				MOV		M[CURSOR],R1
				CMP		R1,R0
				BR.Z	FINAL
				CALL	apaga_tiro
				INC		R1
				MVBL    R2,R1
				MOV     R3,0000h
				MVBL    R3,174Eh
				CMP		R3,R2
				CALL.Z	AtivaExisteTiro
				CMP     R3,R2
				BR.Z	FINAL
				MOV 	M[POS_TIRO], R1
				CALL 	esc_tiro								
FINAL:			DEC		M[Timer]
				POP		R3
				POP 	R2
				POP 	R1
				RET
				
AtivaExisteTiro:MOV		M[FlagExisteTiro], R0
				MOV 	M[Flagtiro],R0
				RET

esc_ast:		CMP	M[Flageesc_ast],R0
				CALL.NZ	ESC_AST
				RET

move_ast:		CMP		M[Flagasteroide],R0
				CALL.NZ	MOVE_OBS
				RET

				
;--------------------------------------
BOTAO:			CALL    APAGA_MENS
				DEC		M[Flag_IE]
				RET	
;--------------------------------------
;--------------------------------------
sobe:			CALL	APAGA_NAVE       ;movimento para cima da nave
				SUB		R1,0100h		 ;tendo em conta a primeira linha do ecra do jogo
				MOV     R2, R0			 ;nao permite a nave passar por esta
				MVBH    R2,R1
				MOV     R3,0000h
				MVBH    R3,0150h
				CMP     R3,R2
				BR.NZ   CONTINUA_1
				ADD		R1,0100h
				CALL    ESCREVE_NAVE
				DEC     M[Flagcima]
				RET
CONTINUA_1:		MOV		M[POS_NAVE],R1
				CALL 	CORDENADAS
				CALL	ESCREVE_NAVE
				DEC		M[Flagcima]
				RET
;--------------------------------------
;--------------------------------------
				
desce:			CALL    APAGA_NAVE		;movimento para baixo da nave
				ADD     R1,0100h		;tendo em conta a ultima linha do ecra do jogo
				MOV		R2,R0			;nao permite a nave passar por esta
				MVBH    R2,R1
				MOV     R3,0000h
				MVBH    R3,1650h
				CMP     R3,R2
				BR.NZ   CONTINUA_2
				SUB		R1,0100h
				CALL    ESCREVE_NAVE
				DEC		M[Flagbaixo]
				RET
CONTINUA_2:		MOV		M[POS_NAVE],R1
				CALL CORDENADAS
				CALL    ESCREVE_NAVE
				DEC     M[Flagbaixo]
				RET
;--------------------------------------
;--------------------------------------

direita:		CALL	APAGA_NAVE		;movimento para a direita da nave 
				INC     R1				; tendo em conta a ultima coluna do ecra do jogo
				MOV		R2,R0 			;nao permite a nave passar por esta
				MVBL    R2,R1
				MOV     R3,0000h
				MVBL    R3,174Eh
				CMP     R3,R2
				BR.NZ	CONTINUA_3
				DEC 	R1
				CALL	ESCREVE_NAVE
				DEC 	M[Flagdireita]
				RET
				
CONTINUA_3:		MOV		M[POS_NAVE],R1
				CALL CORDENADAS
				CALL    ESCREVE_NAVE
				DEC 	M[Flagdireita]
				RET
;--------------------------------------
;--------------------------------------
				
esquerda:		MOV	R2,R0			  ;movimento para a esquerda da nave 
				MVBL R2,R1			  ;tendo em conta a primeira coluna do ecra do jogo
				CMP		R2,R0		  ;nao permite a nave passar por esta
				BR.Z	MANTEM
				CALL   	APAGA_NAVE
				DEC		R1
				MOV		M[POS_NAVE],R1
				CALL CORDENADAS
				CALL	ESCREVE_NAVE
MANTEM:			DEC 	M[Flagesquerda]
				RET
				



;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;																				MENSAGEM INICIAL DE JOGO
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

ESCREVE_TELA_1:	PUSH	R4					
				PUSH	R2					 
				MOV		R4, POS_LETRA1		;Vai escrever letra a letra comparando com @
				MOV		R2, MENSAGEM_1		;quando chega ao @ ele para de escrever
				MOV		R3,M[R2]
ESCREVE_TELA:	MOV		M[CURSOR],R4
				MOV		M[ESCREVER],R3
				INC   	R2
				INC		R4
				MOV		R3,M[R2]
				CMP		R3,FIM_MENSAGEM
				BR.NZ	ESCREVE_TELA
				POP 	R2
				POP 	R4
				
				RET
				

ESCREVE_TELA_2: PUSH	R4
				PUSH	R2
				MOV		R4, POS_LETRA2		;Vai escrever letra a letra comparando com @
				MOV		R2, MENSAGEM_2		;quando chega ao @ ele para de escrever
				MOV		R3,M[R2]
ESCREVE_TELA2:	MOV		M[CURSOR],R4
				MOV		M[ESCREVER],R3
				INC   	R2
				INC		R4
				MOV		R3,M[R2]
				CMP		R3,FIM_MENSAGEM
				BR.NZ	ESCREVE_TELA2
				POP 	R2
				POP 	R4
				
				RET

APAGA_MENS:    	PUSH 	R5
				POP		R3
				MOV 	R5, MENSAGEM_1
				MOV 	R3, ESPACO
CICLO1:			MOV 	M[CURSOR], R5
				MOV 	M[ESCREVER], R3
				INC 	R5		  
				CMP 	R5,POS_F_1
				BR.NZ 	CICLO1
;--------------------------------------------------------------------------------------------------------------------------------------------------
				MOV 	R5, MENSAGEM_2
				MOV 	R3, ESPACO
CICLO2:			MOV 	M[CURSOR], R5
				MOV 	M[ESCREVER], R3
				INC 	R5		  
				CMP 	R5, POS_F_2
				BR.NZ 	CICLO2								
				POP 	R3													
				POP 	R5
				RET	
				



RANDOM:			PUSH	R1
				PUSH	R2
				MOV		R1, MASCARA
				MOV		R2, M[NUM_ALEATORIO]
				SHR		R2, 1			; isola 1ºbit
				BR.NC	RANDOM1				
				MOV		R2, M[NUM_ALEATORIO]
				XOR		R2, R1
				ROR		R2, 1
				BR		RANDOM2
RANDOM1:		MOV		M[NUM_ALEATORIO], R2
				ROR		R2, 1
RANDOM2:		MOV		M[NUM_ALEATORIO], R2
				MOV		R1, 0016h
				DIV		R2, R1
				INC		R1
				MOV		M[LINHA_RANDOM], R1
				POP		R2
				POP		R1
				RET
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------			
POS_AST_BH:		PUSH	R1
				CALL	RANDOM
				MOV		R1, M[LINHA_RANDOM]
				SHL		R1, 8
				MVBL	R1, 004Eh
				MOV		M[POS_OBS], R1
				POP		R1
				RET
			
APAGA_AST:		PUSH	R2
				PUSH	R3
				MOV 	R2,M[POS_OBS]
				MOV 	R3,ESPACO
				MOV 	M[CURSOR],R2
				MOV 	M[ESCREVER],R3
				POP 	R3
				POP	R2
				RET
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------			
ESC_AST:		PUSH	R5
				PUSH	R4
				PUSH	R1
				MOV		R1, 8000h
				DEC		R1
POS_OCUPADA:	INC		R1
				CMP		M[R1], R0
				BR.NZ	POS_OCUPADA
				CMP		R1, 800Eh
				BR.Z	FIM_AST
				CALL	POS_AST_BH
				MOV		R5, M[POS_OBS]
				MOV		R4, ASTEROIDE
				MOV		M[CURSOR], R5
				MOV		M[ESCREVER], R4
				MOV		M[R1], R5
				;DEC		M[contador]
FIM_AST:		MOV		M[POS_OBS],R0
				POP		R1
				POP		R4
				POP		R5
				MOV		M[Flageesc_ast],R0
				RET
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------					
MOVE_OBS:			PUSH	R6
					PUSH	R5
					PUSH	R4
					PUSH	R2
					PUSH	R1
					
					MOV		R1, 8000h  				;VAI COMPARAR AS POSICOES DE MEMORIA ONDE SE ENOCNTRAM OS ASTEROIDES 
					DEC		R1						; VE SE  essa POSCISAO ESTA VAZIA OU NAO, SE NAO ESTIVER VAI PARA A FUNCAO MOVER  
CICLO_MOVE:			INC		R1						; Na funcao mover ele apaga o asteroide que esta nessa posicao, e o escreve na anterior
					CMP		M[R1], R0				;Quando esta vazio, ele verifica se ja chegou a ultima posicao guardada com o Tab, se não volta a fazer
					BR.NZ	MOVER					; a funcao a partir do incremento da posicao, criando assim um ciclo
MOVEU:				CMP		R1, 8013h
					BR.NZ	CICLO_MOVE
					MOV		M[Flagasteroide],R0
					
					POP		R1
					POP		R2
					POP		R4
					POP		R5
					POP		R6
					RET
					
MOVER:				MOV		R2, M[R1]				; nesta funcao ele vai mover os asteroides apagando e escrevendo-os nas posicoes decrementadas
					MOV		R4, ESPACO
					MOV		M[CURSOR], R2
					MOV		M[ESCREVER], R4
					DEC		M[R1]
					MOV		R2, M[R1]
					MOV		R4, ASTEROIDE
					MOV		M[CURSOR], R2
					MOV		M[ESCREVER], R4
					MOV 	M[POS_AST],R2
					
					CALL	COLISAO
					
					MOV 	R6,M[R1]
					AND		R6,00FFh				;aqui tem em conta o limite lateral da esquerda, ele verifica que quando o ast se encontra na 
					CMP		R6,R0					;coluna 0 ele apaga-o novamente, ou seja o asteroide move-se desde a posicao random ate a coluna 
					BR.Z	APAGA					; 00, nesta ele desaparece pois ja percoreu tudo o que tinha de percorrer 
					JMP		MOVEU
					
					
APAGA:				MOV		M[CURSOR],R2
					MOV 	R5,ESPACO
					MOV		M[ESCREVER],R5
					MOV		M[R1],R0
					JMP		MOVEU
;--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------					
ResetTimer:			CALL	esc_ast
					CALL	move_ast
					CALL 	move_tiro
					CALL	colisao_TIRO_AST
					;CALL	COL_AST_NAVE
					MOV		M[Timer], R0
					
					RET

;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
;---------------------------------------------------------------------------------------------------------------------------------------------------------------------
					
colisao_TIRO_AST:	PUSH	R1
					PUSH	R2
					PUSH	R4
					PUSH	R5
					MOV R1,AST
					MOV R4,R1
					ADD R4, 20
					MOV R3,M[POS_TIRO]
					DEC R1
CICLO_AST_TIRO:		INC R1
					CMP M[R1],R3
					CALL.Z COLIDE
					INC R3 
					CMP	M[R1],R3
					CALL.Z	COLIDE
					DEC R3
					CMP R1, R4
					BR.NZ CICLO_AST_TIRO
					POP	R5
					POP	R4
					POP	R2
					POP	R1
					RET 
					
COLIDE:				PUSH R2
					PUSH R3
					PUSH R4
					PUSH R5
					PUSH R6
					
					MOV R3,M[R1]
					MOV R5, ESPACO
					MOV M[CURSOR],R3
					MOV M[ESCREVER],R5
					MOV M[R1],R0
					MOV R4,M[POS_TIRO]
					MOV M[CURSOR],R4
					MOV M[ESCREVER],R5
					MOV M[POS_TIRO],R0
					MOV	R2,M[POS_TIRO]
					MOV	R6,ESPACO
					MOV	M[ESCREVER],R6
					MOV	M[CURSOR],R2
					MOV	R6,CARDINAL
					MOV M[ESCREVER],R6
					MOV M[CURSOR],R0
					MOV M[FlagExisteTiro],R0
					
					POP	R6
					POP	R5
					POP	R4
					POP	R3
					POP	R2
					RET
					
					
CORDENADAS:	PUSH R2
			PUSH R3
			PUSH R4
			PUSH R5
			PUSH R6
			MOV R3, R0
			MOV R2, M[POS_NAVE]
			INC	R2
			MVBH R3, R2            ; R3 - XX00
			SHR R3, 8
			AND R2, 00FFh		;elimina os 8 bits mais significativos, fica com as colunas 
			MOV R4, 8000h
			MOV M[CURSOR_CORD], R4
			MOV R5, 000Ah
			MOV	R6, 000Ah
			DIV R3, R5
			DIV	R3, R6
			ADD R5, 0030h
			ADD	R6, 0030h
			MOV M[ESCREVER_CORD], R6
			INC R4
			MOV M[CURSOR_CORD], R4
			MOV M[ESCREVER_CORD], R5
			INC R4
			INC R4
			MOV M[CURSOR_CORD], R4
			MOV R5, 000Ah
			MOV	R6, 000Ah
			DIV R2, R5
			DIV	R2, R6
			ADD R5, 0030h
			ADD	R6, 0030h
			MOV M[ESCREVER_CORD], R6
			INC R4
			MOV M[CURSOR_CORD], R4
			MOV M[ESCREVER_CORD], R5
			POP	R6
			POP R5
			POP R4
			POP R3
			POP R2
			RET
					

COLISAO:		PUSH	R1
				PUSH	R2
				
				MOV		R1, M[POS_NAVE]	; Posicao atual do canhao
				INC 	R1
				CMP		R2, R1				; Compara a posicao atual do canhao da nave com a posicao dos asteroides
				CALL.Z	FIM_DO_JOGO
				
				SUB		R1, 0101h			; Compara a posicao atual da asa superior da nave com a posicao dos asteroides
				CMP		R2, R1
				CALL.Z	FIM_DO_JOGO
				
				ADD		R1, 0100h			; Compara a posicao atual do corpo da nave com a posicao dos asteroides
				CMP		R2, R1
				JMP.Z	FIM_DO_JOGO
				
				ADD		R1, 0100h			; Caompara a posicao atual da asa inferior da nave com a posicao dos asteroides
				CMP		R2, R1
				CALL.Z	FIM_DO_JOGO
				
				POP		R2
				POP		R1
				RET
				
LIMPA_ECRA:		PUSH	R1
				PUSH	R2	
				
				MOV		R1, AST
				MOV		R2,R1
				ADD		R2, 20
				DEC		R1
				
LIMPA_AST:		INC		R1
				MOV		M[R1],R0
				CMP		R1,R2
				BR.NZ	LIMPA_AST

				CALL	LIMPA_ECRA2

				POP		R2
				POP		R1
				RET

				
LIMPA_ECRA2:	PUSH	R2
				PUSH	R3
				PUSH	R4
				
				MOV		R2,R0
				MOV		R3,R0
				MOV		R4,ESPACO

LIMPA_LINHA:	MOV		M[CURSOR],R2
				MOV		M[ESCREVER],R4
				INC		R2
				CMP		R2,4Fh
				BR.NZ	LIMPA_LINHA
				MOV		R2,R0
				ADD		R3,0100h
				ADD		R2,R3
				CMP		R3,1700h
				BR.NZ	LIMPA_LINHA
				
				POP		R4
				POP		R3
				POP		R2
				RET
				
CREATE_FINAL:	PUSH    R7
				PUSH	R5
				PUSH	R6
				
				MOV 	R6, POS_GAMEOVER
				MOV		R5, TEXT3
				MOV		R7, M[R5]
MESS_AUX3:		MOV		M[CURSOR], R6
				MOV 	M[ESCREVER], R7
				INC 	R6
				INC 	R5
				MOV     R7,M[R5]
				CMP		R7, FIM_MENSAGEM
				BR.NZ	MESS_AUX3			
				
				POP R6
				POP	R5
				POP	R7
				RET			
	
				
;LIMITES 
APAGA_LINHAS:	PUSH 	R3
				MOV 	R3,0000h
				MOV 	R2,ESPACO
C_APAGA_L1:		MOV 	M[CURSOR],R3 
				MOV 	M[ESCREVER],R2			
				INC 	R3					
				CMP     R3,LIM_1F				
				BR.NZ   C_APAGA_L1 
				
				MOV 	R3,1700h
				MOV 	R2,ESPACO
C_APAGA_L2:		MOV 	M[CURSOR],R3 
				MOV 	M[ESCREVER],R2			
				INC 	R3						
				CMP     R3,LIM_2F				
				BR.NZ   C_APAGA_L2 
				
				POP		R3
				RET