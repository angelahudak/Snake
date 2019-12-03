;       TTL Program Title for Listing Header Goes Here
;****************************************************************
;Snake with embedded systems and mixed ARM Assembly and C99
;Name:      Gabriel Dombrowski && Angela Hudak
;Date:      19 November 2019
;Class:     CMPE-250
;Section:   CMPE 250.01/.02 L2 Teusdays 1400
;---------------------------------------------------------------
;Keil Template for KL46 Assembly with Keil C startup
;R. W. Melton
;November 13, 2017
;****************************************************************
;Assembler directives
            THUMB
            GBLL  MIXED_ASM_C
MIXED_ASM_C SETL  {TRUE}
            OPT   64  ;Turn on listing macro expansions
;****************************************************************
;Include files
            GET  MKL46Z4.s     ;Included by start.s
            OPT  1   ;Turn on listing
;****************************************************************
;EQUates
UART0_IRQ_PRIORITY_3	EQU 3
;---------------------------------------------------------------
;NVIC_ICER
NVIC_ICER_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;NVIC_ICPR
NVIC_ICPR_UART0_MASK  EQU  UART0_IRQ_MASK
;---------------------------------------------------------------
;NVIC_IPR0-NVIC_IPR7
UART0_IRQ_PRIORITY    EQU  3
NVIC_IPR_UART0_MASK   EQU (3 << UART0_PRI_POS)
NVIC_IPR_UART0_PRI_3  EQU (UART0_IRQ_PRIORITY << UART0_PRI_POS)
;---------------------------------------------------------------
;NVIC_ISER
NVIC_ISER_UART0_MASK  EQU  UART0_IRQ_MASK
NVIC_ICER_PIT_MASK    EQU  PIT_IRQ_MASK
PIT_IRQ_PRIORITY    EQU  0
NVIC_IPR_PIT_MASK   EQU  (3 << PIT_PRI_POS)
NVIC_IPR_PIT_PRI_0  EQU  (PIT_IRQ_PRIORITY << PIT_PRI_POS)
NVIC_ISER_PIT_MASK    EQU  PIT_IRQ_MASK
;---------------------------------------------------------------
PIT_LDVAL_10ms  EQU  239999
;---------------------------------------------------------------
PIT_MCR_EN_FRZ  EQU  PIT_MCR_FRZ_MASK
;---------------------------------------------------------------
PIT_TCTRL_CH_IE  EQU  (PIT_TCTRL_TEN_MASK :OR: PIT_TCTRL_TIE_MASK)
NVIC_ICPR_PIT_MASK    EQU  PIT_IRQ_MASK
;Port A
PORT_PCR_SET_PTA1_UART0_RX  EQU  (PORT_PCR_ISF_MASK :OR: PORT_PCR_MUX_SELECT_2_MASK)
PORT_PCR_SET_PTA2_UART0_TX  EQU  (PORT_PCR_ISF_MASK :OR: PORT_PCR_MUX_SELECT_2_MASK)
SIM_SOPT2_UART0SRC_MCGPLLCLK  EQU  (1 << SIM_SOPT2_UART0SRC_SHIFT)
SIM_SOPT2_UART0_MCGPLLCLK_DIV2 EQU (SIM_SOPT2_UART0SRC_MCGPLLCLK :OR: SIM_SOPT2_PLLFLLSEL_MASK)
SIM_SOPT5_UART0_EXTERN_MASK_CLEAR  EQU  (SIM_SOPT5_UART0ODE_MASK :OR: SIM_SOPT5_UART0RXSRC_MASK :OR: SIM_SOPT5_UART0TXSRC_MASK)
;---------------------------------------------------------------
UART0_BDH_9600  EQU  0x01
;SBR = 48 MHz / (9600 * 16) = 312.5 --> 312 = 0x138
UART0_BDL_9600  EQU  0x38
UART0_C1_8N1  EQU  0x00
UART0_C2_T_R    EQU  (UART0_C2_TE_MASK :OR: UART0_C2_RE_MASK)
UART0_C2_T_RI   EQU  (UART0_C2_RIE_MASK :OR: UART0_C2_T_R)
UART0_C2_TI_RI  EQU  (UART0_C2_TIE_MASK :OR: UART0_C2_T_RI)
UART0_C3_NO_TXINV  EQU  0x00
UART0_C4_OSR_16           EQU  0x0F
UART0_C4_NO_MATCH_OSR_16  EQU  UART0_C4_OSR_16
UART0_C5_NO_DMA_SSR_SYNC  EQU  0x00
UART0_S1_CLEAR_FLAGS  EQU  (UART0_S1_IDLE_MASK :OR: UART0_S1_OR_MASK :OR: UART0_S1_NF_MASK :OR: UART0_S1_FE_MASK :OR: UART0_S1_PF_MASK)
UART0_S2_NO_RXINV_BRK10_NO_LBKDETECT_CLEAR_FLAGS  EQU  (UART0_S2_LBKDIF_MASK :OR: UART0_S2_RXEDGIF_MASK)
;---------------------------------------------------------------
;Managment record struct field displacements
IN_PTR		EQU 0
OUT_PTR		EQU 4
BUF_STRT	EQU 8
BUF_PAST	EQU 12
BUF_SIZE	EQU 16
NUM_ENQD	EQU 17
;---------------------------------------------------------------
;Stack management struct field displacements 
STACK_POINTER	EQU	0
STACK_SIZE		EQU	4
NUM_STACKED		EQU	5
;---------------------------------------------------------------	
;Queue structure sizes
Q_BUF_SZ	EQU 80
Q_REC_SZ	EQU 18
;---------------------------------------------------------------
;Stack structure sizes
STACK_REC_SZ	EQU		6
STACK_SZ		EQU		Q_BUF_SZ
;---------------------------------------------------------------
;ASCII Converts
LOWER_UPPER_SEPERATION		EQU		32
;---------------------------------------------------------------
;printing values
CR          EQU  0x0D
LF          EQU  0x0A
NULL        EQU  0x00
TRUE		EQU	 0x01
FALSE		EQU	 0x00
;****************************************************************
;Snake values
MAX_SNAKE EQU 864  ;18 x 48 => total # of possible occupied spaces
;****************************************************************
;MACROs
;****************************************************************
;Program
;C source will contain main ()
;Only subroutines and ISRs in this assembly source
            AREA    MyCode,CODE,READONLY
;-----------------------------------------------------------------
			;EXPORTS
            EXPORT  DIVU
            EXPORT  GetCharI
            EXPORT  PutCharI
            EXPORT  UART0_IRQHandler
			EXPORT	PIT_IRQHandler
            EXPORT  Init_UART0_IRQ
			EXPORT	Init_PIT_IRQ
            EXPORT  PutStringI
            EXPORT  PutNumHexI
            EXPORT  NewLineI
            EXPORT  PutNumI
			EXPORT	ReadSnakeQ
			EXPORT  ReadFirstQ
			EXPORT	InitSnakeQs
				
			;variables
			EXPORT	GameActive
			EXPORT	Velocity
			EXPORT	GameWon
			EXPORT	GameLost
			EXPORT	SnakeQXRecord
			EXPORT	SnakeQYRecord
;-----------------------------------------------------------------
			;IMPORTS
			IMPORT	advanceTheSnake
			IMPORT	nextSpaveValid
			
;-----------------------------------------------------------------
;>>>>> begin subroutine code <<<<<
;################################################################
;InitSnakeQs - initializes the both X and Y snake queues for the game
;	Input - null
;	Output - null
;################################################################
InitSnakeQs		PROC	{R0-R13,LR}
				PUSH	{R0-R3,LR}
	
				POP		{R0-R3,PC}
				ENDP
;################################################################
;ReadSnakeQ - finds the index value in a queue
;Inputs - R0:index
;	  	  R1:=QRecord
;Output - R0:value at QBuffer[index]
;################################################################
ReadSnakeQ		PROC	{R0-R13,LR}
				PUSH	{R0-R3,LR}

				;ToDo

				POP	{R0-R3,PC}
				ENDP
;################################################################
;ReadFirstQ -  reads the first byte in a queue without dequeuing it
; Input - R0 =QRecord
; Output - R0 first byte in the queu
;################################################################
ReadFirstQ		PROC	{R0-R13,LR}
				PUSH	{R0-R3,LR}
				
				POP		{R0-R3,PC}
				ENDP
;################################################################
;INIT_PIT_IRQ - initializes the KL46 to inteerupt every 0.01s from
;				PIT channel 0
;Inputs - null
;Outputs - null
;modifies - APSR
;################################################################
Init_PIT_IRQ	PROC	{R0-R13,LR}
				PUSH	{R0-R7,LR}
				
				;enable clock for PIT module
				LDR		R0,=SIM_SCGC6
				LDR		R1,=SIM_SCGC6_PIT_MASK
				LDR		R2,[R0,#0]
				ORRS	R2,R2,R1
				STR		R2,[R0,#0]
				
				;Disable PIT Timer 0
				LDR		R0,=PIT_CH0_BASE
				LDR		R1,=PIT_TCTRL_TEN_MASK
				LDR		R2,[R0,#PIT_TCTRL_OFFSET]
				BICS	R2,R2,R1
				STR		R2,[R0,#PIT_TCTRL_OFFSET]
				
				;Set PIT interrupt priority
				LDR		R0,=PIT_IPR
				LDR		R1,=NVIC_IPR_PIT_MASK
				LDR		R2,[R0,#0]
				BICS	R2,R2,R1
				STR		R2,[R0,#0]
				
				;clear any pending interrupts
				LDR		R0,=NVIC_ICPR
				LDR		R1,=NVIC_ICPR_PIT_MASK
				STR		R1,[R0,#0]
				
				;unmask PIT Interrupts
				LDR		R0,=NVIC_ISER
				LDR		R1,=NVIC_ISER_PIT_MASK
				STR		R1,[R0,#0]
				
				;Enable PIT module
				LDR		R0,=PIT_BASE
				LDR		R1,=PIT_MCR_EN_FRZ
				STR		R1,[R0,#PIT_MCR_OFFSET]
				
				;Set PIT timer 0 period for 0.01
				LDR		R0,=PIT_CH0_BASE
				LDR		R1,=PIT_LDVAL_10ms
				STR		R1,[R0,#PIT_LDVAL_OFFSET]
				
				;enable pit timer 0 interrupt
				LDR		R2,=PIT_TCTRL_CH_IE
				STR		R2,[R0,#PIT_TCTRL_OFFSET]
				
				;clear PIT channel 0 interrupt
				;LDR		R1,=PIT_TFLG_TIF_MASK
				;STR		R1,[R0,#PIT_TFLG_OFFSET]
				
				POP		{R0-R7,PC}
				ENDP
;################################################################
;PIT_ISR - ISR for the PIT module
;Interrupt
;################################################################
PIT_IRQHandler	PROC	{R0-R13,LR}
				PUSH	{R0-R7,LR}
				
				CPSID	I					;mask interrupts
				
				;TODO
				
ClearInterrupt	LDR		R0,=PIT_CH0_BASE
				LDR		R1,=PIT_TFLG_TIF_MASK
				STR		R1,[R0,#PIT_TFLG_OFFSET];clear PIT channel 0 interrupt
				
				CPSIE	I					;unmask interrupts
				
				POP		{R0-R7,PC}
				ENDP
;################################################################
;UART0_IRQHandler
;################################################################
UART0_IRQHandler	PROC	{R0-R13,LR}
			PUSH	{R0-R7,LR}
			
			CPSID   I	                ;mask other interupts
			
			;Push any registers other than (r0-r3,r12)
			PUSH	{R4-R7}
			
			MOVS	R0,#0x80			;only seventh HIGH
			LDR		R1,=UART0_C2
			LDRB	R1,[R1,#0]
			ANDS	R0,R0,R1
			BEQ		TestRDRF			;if (C2_TIE == '1')
			
			LDR		R1,=UART0_BASE
			MOVS	R0,#UART0_S1_TDRE_MASK
			LDRB	R2,[R1,#UART0_S1_OFFSET]
			ANDS	R2,R2,R0
			BEQ		TestRDRF			;if (TDRE == '1') 
			
			LDR		R1,=QTransmitRecord
			BL		Dequeue				;dequeue from TXQueue
			BCS		DQFailure
			LDR		R1,=UART0_BASE
			STRB	R0,[R1,#UART0_D_OFFSET];write char to UART0 data register
			B		TestRDRF
			
DQFailure	LDR		R0,=UART0_C2_T_RI
			LDR		R1,=UART0_C2
			STRB	R0,[R1,#0]			;Disable TXInterrupt
			B		TestRDRF
			
TestRDRF	LDR		R1,=UART0_BASE
			MOVS	R0,#UART0_S1_RDRF_MASK
			LDRB	R2,[R1,#UART0_S1_OFFSET]
			ANDS	R2,R2,R0
			BEQ		ISRFin				;if(RDRF == '1')
			
			LDR		R3,=GameActive
			LDRB	R3,[R3,#0]
			CMP		R3,#TRUE
			BNE		NormRecieve
			;if Snake is running
			LDRB	R0,[R1,#UART0_D_OFFSET]
			LDR		R1,=Velocity
			LDRB	R2,[R1,#0]
			;TODO: make sure 180 degree turns aren't possible
			
			STRB	R0,[R1,#0]
			B		ISRFin
			
NormRecieve	LDRB	R0,[R1,#UART0_D_OFFSET];read a char from UART0 recieve register
			LDR		R1,=QRecieveRecord
			BL		Enqueue				;enqueue char to RXQueue

ISRFin		POP		{R4-R7}
			CPSIE   I       			;unmask interupts

			
			POP		{R0-R7,PC}
			ENDP
;################################################################
;GetCharI - get char subroutine but for interupt
;	Input	- null
;	Output	-R0:ACSII value dequeued
;	Modifies-APSR
;################################################################
GetCharI	PROC	{R0-R13,LR}
			PUSH	{R1-R7,LR}
			
GetCharLoop CPSID   I          				;mask interupts
			LDR		R1,=QRecieveRecord
			BL		Dequeue					;critical code
			CPSIE   I       				;unmask interupts

			BCS		GetCharLoop
			
			POP		{R1-R7,PC}
			ENDP
;################################################################
;PutCharI - putchar subroutine but for interput
;	Input	-R0:ASCII character to enqueue
;	Output	-null
;	Modifies-APSR
;################################################################
PutCharI	PROC	{R0-R13,LR}
			PUSH	{R0-R7,LR}
			
			
PutCharLoop CPSID   I       				;mask interupts
			LDR		R1,=QTransmitRecord		;enqueue character
			BL		Enqueue
			CPSIE   I       				;unmask interupts
			
			BCS		PutCharLoop
			
			;enable Tx
			LDR		R1,=UART0_C2_TI_RI
			LDR		R2,=UART0_C2
			STRB	R1,[R2,#0]
			
			POP		{R0-R7,PC}
			ENDP
;################################################################
;Init_UART0_IRQ - initializes the UART0 for interupts
;################################################################
Init_UART0_IRQ	   PROC {R0-R14}
				   PUSH {R0-R3,LR}
				   
				   ;SELECT MCGPLLCLK / 2 AS UART0 CLOCK SOURCE
				   LDR  R0,=SIM_SOPT2
				   LDR  R1,=SIM_SOPT2_UART0SRC_MASK
				   LDR  R2,[R0,#0]
				   BICS R2,R2,R1
				   LDR  R1,=SIM_SOPT2_UART0_MCGPLLCLK_DIV2
				   ORRS R2,R2,R1
				   STR  R2,[R0,#0]
				   
				   ;ENABLE EXTERNAL CONNECTION FOR UART0
				   LDR  R0, =SIM_SOPT5
				   LDR  R1, =SIM_SOPT5_UART0_EXTERN_MASK_CLEAR
				   LDR  R2,[R0,#0]
				   BICS R2,R2,R1
				   STR  R2,[R0,#0]		;update sim_sopt5
				   
				   ;ENABLE CLOCK FOR UART0 MODULE
				   LDR  R0,=SIM_SCGC4
				   LDR  R1,=SIM_SCGC4_UART0_MASK
				   LDR  R2,[R0,#0]
				   ORRS R2,R2,R1
				   STR  R2,[R0,#0]		;update sim_scgc4
				   
				   ;ENABLE CLOCK FOR PORT A
				   LDR  R0,=SIM_SCGC5
				   LDR  R1,=SIM_SCGC5_PORTA_MASK
				   LDR  R2,[R0,#0]
				   ORRS R2,R2,R1
				   STR  R2,[R0,#0]		;update sim_scgc5
				   
				   ;CONNECT PORT A PIN 1 (PTA1) TO UART0 RX (J1 PIN 02)
				   LDR  R0,=PORTA_PCR1
				   LDR  R1,=PORT_PCR_SET_PTA1_UART0_RX
				   STR  R1,[R0,#0]
				   
				   ;CONNECT PORT A PIN 2 (PTA2) TO UART0 TX (J1 PIN 04)
				   LDR  R0,=PORTA_PCR2
				   LDR  R1,=PORT_PCR_SET_PTA2_UART0_TX
				   STR  R1,[R0,#0]
				   
				   ;DISABLE UART0 RECIEVER AND TRANSMITTER
				   LDR  R0,=UART0_BASE
				   MOVS R1,#UART0_C2_T_R
				   LDRB R2,[R0,#UART0_C2_OFFSET]
				   BICS R2,R2,R1
				   STRB R2,[R0,#UART0_C2_OFFSET]
				   
				   ;SET UART0 FOR 9600 BAUD
				   MOVS R1,#UART0_BDH_9600
				   STRB R1,[R0,#UART0_BDH_OFFSET]
				   MOVS R1,#UART0_BDL_9600
				   STRB R1,[R0,#UART0_BDL_OFFSET]
				   MOVS R1,#UART0_C1_8N1
				   STRB R1,[R0,#UART0_C1_OFFSET]
				   MOVS R1,#UART0_C3_NO_TXINV
				   STRB R1,[R0,#UART0_C3_OFFSET]
				   MOVS R1,#UART0_C4_NO_MATCH_OSR_16     
				   STRB R1,[R0,#UART0_C4_OFFSET]     
				   MOVS R1,#UART0_C5_NO_DMA_SSR_SYNC     
				   STRB R1,[R0,#UART0_C5_OFFSET]     
				   MOVS R1,#UART0_S1_CLEAR_FLAGS     
				   STRB R1,[R0,#UART0_S1_OFFSET]     
				   MOVS R1,#UART0_S2_NO_RXINV_BRK10_NO_LBKDETECT_CLEAR_FLAGS     
				   STRB R1,[R0,#UART0_S2_OFFSET]
				   
				   ;Init NVIC for UART0 interrupts
				   LDR R0,=UART0_IPR
				   LDR R2,=NVIC_IPR_UART0_MASK
				   LDR R3,[R0,#0]
				   ORRS R3,R3,R2
				   STR R3,[R0,#0]		            ;set UART0 IRQ Priority
				   
				   LDR R0,=NVIC_ICPR
				   LDR R1,=NVIC_ICPR_UART0_MASK
				   STR R1,[R0,#0]		            ;clear any pending UART0 interrupts
				   
				   LDR R0,=NVIC_ISER
				   LDR R1,=NVIC_ISER_UART0_MASK
				   STR R1,[R0,#0]		            ;umask UART0 interrupts
				   
				   ;Enable recieve interrupt
				   LDR R0,=UART0_C2_T_RI
				   LDR R1,=UART0_C2
				   STRB R0,[R1,#0]                   ;eanble recieve interrupt
				   
				   ;Init recieve and transmit queue
				   LDR  R0,=QRecieveBuffer
				   LDR	R1,=QRecieveRecord
				   MOVS R2,#Q_BUF_SZ
				   BL	InitQueue
				   LDR  R0,=QTransmitBuffer
				   LDR 	R1,=QTransmitRecord
				   MOVS R2,#Q_BUF_SZ
				   BL	InitQueue
				   
				   POP {R0-R3,PC}
				   ENDP
;################################################################
;InitQueue - initializes the queue record struct
;	Input -  R0:QBuffer
;			 R1:QRecord
;			 R2:Q_SZ
;	Output - null
;#################################################################
InitQueue	PROC 	{R0-R2}
			PUSH 	{R0-R2,LR}
			
			STR 	R0,[R1,#IN_PTR]
			STR   	R0,[R1,#OUT_PTR]
			STR   	R0,[R1,#BUF_STRT]		;init pointers (start && current)
			
			ADDS 	R0,R0,R2
			STR  	R0,[R1,#BUF_PAST]
			STRB 	R2,[R1,#BUF_SIZE]		;inti buffer size and buffer past
			
			MOVS 	R0,#0
			STRB 	R0,[R1,#NUM_ENQD] 		;empty queue == 0 elments enqued
			
			POP 	{R0-R2,PC}
			ENDP
;#################################################################
;Dequeue - Attempts to get a character from the queue, if queue is empty C flag
;			in PSR is set (1).
;	Input  - R1:QRecord for dequeue
;	Output - R0:Single value dequeued
;			 R1:QRecord Pointer
;			 C: high if invalid
;	Modifies: APSR
;#################################################################
Dequeue		PROC 	{R2-R5}			;public int dequeue(Address R1){
			PUSH 	{R2-R5,LR}
	
			
			LDRB 	R2,[R1,#NUM_ENQD]
			CMP 	R2,#0
			BEQ 	SetCHighDe			;if !(this.empty()){
			
			LDR 	R0,[R1,#OUT_PTR]	
			LDRB	R0,[R0,#0]			;R0 = M[outPointer];
			
			SUBS	R2,R2,#1
			STRB 	R2,[R1,#NUM_ENQD]	;numberEnqueued --;
			
			LDR 	R2,[R1,#OUT_PTR]
			ADDS 	R2,R2,#1			;outPointer ++;
			STR 	R2,[R1,#OUT_PTR]
			
			LDR 	R3,[R1,#BUF_PAST]
			CMP 	R2,R3
			BLO 	SetCLowDe			;if (outPointer >= bufferPast){
			LDR 	R3,[R1,#BUF_STRT]	;outPointer = bufferStart;}
			STR 	R3,[R1,#OUT_PTR]
			
SetCLowDe	MRS 	R3,APSR				;c == '0';}
            MOVS 	R4,#0x20
            LSLS 	R4,R4,#24
            BICS 	R3,R3,R4
            MSR 	APSR,R3
			B 		EndDequeue
			
SetCHighDe  MRS 	R3,APSR				;else {c == '1';}
            MOVS 	R4,#0x20
            LSLS 	R4,R4,#24
            ORRS 	R3,R3,R4
            MSR 	APSR,R3
	
EndDequeue	POP 	{R2-R5,PC}		;}
			ENDP	
;#################################################################
;Enqueue - Attempts to put a character into the queue, if the queue is full
;			the C flag in PSR is set (1).
;	Input -  R0:Single value to be Enqueued
;			 R1:Pointer for the queues record
;	Output - C: boolean valid (1-invalid, 0-valid)
;	modifies - APSR
;#################################################################
Enqueue		PROC {R2-R4}			;public void Enqueue (int R0, Address R1){
			PUSH {R2-R4,LR}
			
			LDRB 	R2,[R1,#BUF_SIZE]
			LDRB 	R3,[R1,#NUM_ENQD]
			CMP 	R2,R3
			BEQ 	SetCHighEn			;if !(QueueFull){
			
			LDR		R4,[R1,#IN_PTR]
			STRB 	R0,[R4,#0]			;place new value in queue
			
			ADDS 	R3,R3,#1
			STRB 	R3,[R1,#NUM_ENQD]	;incement number enqueued
			
			LDR 	R2,[R1,#IN_PTR]
			ADDS 	R2,R2,#1
			STR 	R2,[R1,#IN_PTR]		;increment in pointer
			
			LDR 	R3,[R1,#BUF_PAST]
			CMP 	R2,R3
			BLO 	SetCLowEn			;if (pointer >= past_buffer){
			LDR 	R3,[R1,#BUF_STRT]
			STR 	R3,[R1,#IN_PTR]		;inPointer == bufferStart;}
			B 		SetCLowEn
			
SetCHighEn	MRS 	R3,APSR				;else {c == '1';}
            MOVS 	R4,#0x20
            LSLS 	R4,R4,#24
            ORRS 	R3,R3,R4
            MSR 	APSR,R3
			B 		EndEnqueue
			
SetCLowEn	MRS 	R3,APSR				;c == '0';
            MOVS 	R4,#0x20
            LSLS 	R4,R4,#24
            BICS 	R3,R3,R4
            MSR 	APSR,R3			
			
EndEnqueue	POP 	{R2-R4,PC}				;}
			ENDP		
;#################################################################
;PutString: Prints a string to the terminal given the 
;			buffer and initial address
;Input - R0: Init address
;Output - null
;Modifies - APSR
;#################################################################
PutStringI		PROC {R0-R14}
				PUSH {R0-R2, LR}
				
				;R0 - print ascii
                ;R1 - address
                ;R2 - address off_set value
				
				MOVS R2,#0				;initialize counter
				MOVS R1, R0				;protect initial address
				
PutStringLoop   LDRB	R0,[R1,R2]
				BL		PutCharI			;print (String[counter])
				ADDS	R2,R2,#1		;increment counter
                CMP     R0, #NULL
                BNE     PutStringLoop
	
EndPutString	POP {R0-R2, PC}
				ENDP
;#################################################################
;PutNumHex - Prints to the terminal the text of a hexadecimal
;	Input - R0:unsigned word variable to be printed
;	Output - null
;#################################################################
PutNumHexI	PROC {R0-R14}
			PUSH {R0-R6,LR}
			
			;R0 - print reg
			;R1 - masked value
			;R2 - mask
			;R3 - counter
			;R4 - shift value
			;R5 - init hexvalue
			MOVS	R1,R0			;init masked value
			MOVS	R5,R0			;protect init hexvalue
			MOVS	R2,#0x0F
			LSLS	R2,R2,#28			;init mask to MSByte
			MOVS	R3,#7			;init counter
			MOVS	R6,#4			;init single nibble shift
			
HexNumLoop	ANDS	R1,R1,R2		;apply mask
			MOVS	R4,R3			;set shift value == counter
			LSLS	R4,R4,#2		;multiply shift by four (4 bits = 1 nibble)
			ASRS	R1,R1,R4		;shift Byte to LSByte
			CMP		R1,#9			;if (masked value < 9) => numeric
			BLE		Numeric
			BGT		Alpha
			
Numeric		ADDS	R1,R1,#48
			MOVS	R0,R1
			BL		PutCharI
			B		Reset
			
Alpha		ADDS	R1,R1,#55
			MOVS	R0,R1
			BL		PutCharI
			B		Reset
			
Reset		CMP		R3,#0
			BEQ		EndHexNum
			SUBS	R3,R3,#1		;increment counter
			RORS	R2,R2,R6		;shift mask to next byte to the right
			MOVS	R1,R5			;reset masked value
			B		HexNumLoop
			

EndHexNum   POP {R0-R6,PC}
            BX LR
            ENDP
;#################################################################
;NewLine - creates a newline on the terminal and move the cursor
;No input/output
;#################################################################
NewLineI	PROC	{R0-R14}
			PUSH	{R0,LR}
			
			MOVS	R0,#LF
			BL		PutCharI
			MOVS	R0,#CR
			BL		PutCharI
			
			POP		{R0,PC}
			ENDP
;#################################################################
;PutNumI - Prints to the terminal screen the text decimal of a byte value
;	Input - R0:value to be printed
;	Output - null
;#################################################################
PutNumI		PROC 	{R0-R2}
			PUSH 	{R0-R2,LR}
			
			CMP		R0,#0
			BNE		NotZero
			MOVS	R0,#'0'
			BL		PutCharI
			B		EndPutNumU
			
			;R0,R1 operating registers
NotZero		MOVS	R2,#0x00
			PUSH	{R2}		;catch endpoint
			MOVS	R1,R0
			
PNULoop		MOVS	R0,#0x0A
			BL		DIVU
			MOVS	R2,R1
			ADDS	R2,R2,#0x30		;convert to ascii+
			PUSH	{R2}			;store value
			MOVS	R1,R0
			CMP		R1,#0x00
			BGT		PNULoop
			
PNUPrint	POP		{R0}
			CMP		R0,#0x00
			BEQ		EndPutNumU
			BL		PutCharI
			B		PNUPrint
			
EndPutNumU	POP		{R0-R2,PC}
			
			ENDP
;#################################################################
;DIVU - Divides R1/R0 where R1 is the result and R0 is the remainder
;	Input - R1: numerator
;			R0: denominator
;	Output - R1:resultant
;			 R0:remainder
;#################################################################
DIVU        PROC {}
            PUSH {R2-R4}
			
            CMP R0,#0      ;if denominator == 0
            BEQ DivZero    ;invalid
            CMP R1,#0      ;
            BEQ CodeZero   ;reseult = 0
            
            MOVS R2,#0     ;Quotent == 0

StartLoop   CMP R1,R0      ;while(dividend >= Divisor){
            BLO EndLoop
            SUBS R1,R1,R0  ;Dividend = Dividend - Divisor
            ADDS R2,R2,#1  ;t = Quotent ++}
            B StartLoop
EndLoop     MOVS R0,R2     ;Remainder == Dividend
            
            B ClearFlag

CodeZero    MOVS R0,#0
            
ClearFlag   MRS R3,APSR
            MOVS R4,#0x20
            LSLS R4,R4,#24
            BICS R3,R3,R4
            MSR APSR,R3
            B AfterC0
            
DivZero     MRS R3,APSR
            MOVS R4,#0x20
            LSLS R4,R4,#24
            ORRS R3,R3,R4
            MSR APSR,R3    ;answer == invalid, C flag high
       

AfterC0     POP {R2-R4}    ;recover R2
            BX LR          ;end subroutine
            ENDP
;#################################################################
;>>>>>   end subroutine code <<<<<
            ALIGN
;**********************************************************************
;Constants
            AREA    MyConst,DATA,READONLY
;>>>>> begin constants here <<<<<
;>>>>>   end constants here <<<<<
;**********************************************************************
;Variables
            AREA    MyData,DATA,READWRITE
QRecieveBuffer	SPACE	Q_BUF_SZ
            ALIGN
QRecieveRecord	SPACE	Q_REC_SZ
            ALIGN
QTransmitBuffer	SPACE	Q_BUF_SZ
            ALIGN
QTransmitRecord	SPACE	Q_REC_SZ
			ALIGN
SnakeQXRecord	SPACE	Q_REC_SZ
			ALIGN
SnakeQXBuffer	SPACE	MAX_SNAKE
			ALIGN
SnakeQYRecord	SPACE	Q_REC_SZ
			ALIGN
SnakeQYBuffer	SPACE	MAX_SNAKE
			ALIGN
;StackRBuffer	SPACE	STACK_SZ
;			ALIGN
;StackRRecord	SPACE	STACK_REC_SZ
Velocity		SPACE	1
GameActive		SPACE	1
GameWon			SPACE	1
GameLost		SPACE	1
			ALIGN
;>>>>> begin variables here <<<<<
;>>>>>   end variables here <<<<<
            END
