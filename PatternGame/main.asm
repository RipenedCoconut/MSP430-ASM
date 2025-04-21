;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.

;-------------------------------------------------------------------------------
            .text           				; Assemble into program memory.
            .retain            				; Override ELF conditional linking
            .retainrefs       				; And retain any sections that have

; Sequence of bytes indicating if round will display a red (0) or green (1) LED
game_seq: 	.byte	1, 0, 1, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 0, 1
			.byte 	0, 1, 0, 0, 1, 1, 0, 0, 0, 1, 0, 1, 1, 0, 0, 1

; Constants containing values for red LED, green LED, and array length
RED: 		.set	0						; Red LED symbolic value
GRN:		.set	1						; Green LED symbolic value
LENGTH: 	.set 	32						; Array length

; Game variables - 16 bit
index:		.word	0						; Current step in sequence
streak:		.word	0						; Current streak

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------

; This section initializes the buttons and LEDs
			bic.b 	#BIT0, &P1OUT			; Set red LED low
			bis.b 	#BIT0, &P1DIR			; Set output direction of red LED

			bic.b 	#BIT7, &P9OUT			; Set green LED low
			bis.b	#BIT7, &P9DIR			; Set output direction of green LED

			bis.b 	#BIT1, &P1REN			; Enable resistor button P1.1
			bis.b 	#BIT1, &P1OUT			; Pull up resistor button P1.1
			bis.b 	#BIT1, &P1IES			; Falling edge trigger P1.1
			bis.b 	#BIT1, &P1IE			; Interrupts enabled P1.1

			bis.b 	#BIT2, &P1REN			; Enable resistor button P1.2
			bis.b 	#BIT2, &P1OUT			; Pull up resistor button P1.2
			bis.b 	#BIT2, &P1IES			; Falling edge tigger P1.2
			bis.b 	#BIT2, &P1IE			; Interrupts enabled P1.2

			bic.w 	#LOCKLPM5, &PM5CTL0		; Remove GPIO block

			clr.b	&P1IFG					; Clear interrupt so LEDs stay low

			nop
			eint							; Enable interrupts
			nop
; End of button and LED setup

			call #new_game					; Start a new game

			nop
			bis.w	#GIE|LPM3, SR			; Enable LPM3 to save power
			nop								; Satisfies MSP430 requirements

;-------------------------------------------------------------------------------
; Subroutine: delay
; Creates a delay using arithmetic to stall the processor
;
; Subroutine does not modify any core registers in R4-R15
; Subroutine does not modify any variables defined in .data or .text
;-------------------------------------------------------------------------------
delay:
			push 	#0
countdown:
			decd.w	0(SP)
			jnz		countdown

			add.w	#2, SP
			ret

;-------------------------------------------------------------------------------
; Subroutine: LEDs_off
; Turns off both LEDs
;
; Output: BIT0 in P1OUT
;		  BIT7 in P9OUT
;
; Subroutine does not modify any core registers in R4-R15
;-------------------------------------------------------------------------------
LEDs_off:
			bic.b	#BIT0, &P1OUT			; Red LED off
			bic.b	#BIT7, &P9OUT			; Green LED off

			ret								; Return to caller

;-------------------------------------------------------------------------------
; Subroutine: new_game
; Starts a new game by clearing index and streak, shuts off LEDs
;
; Input: Subroutine LEDs_off
;		 Constant RED
;		 Variable index
;		 Variable streak
;		 Byte array game_seq
;
; Output: BIT0 in P1OUT
;		  BIT7 in P9OUT
;
; Subroutine does not modify any core registers in R4-R15
; Subroutine clears index and streak in .text
; Subroutine accesses RED in .text
;-------------------------------------------------------------------------------
new_game:
; Reset the game variables, turn off LEDs, setup register for use
			clr.w	&index					; Reset the index variable
			clr.w	&streak					; Reset the streak to zero
			call	#LEDs_off				; Turn off LEDs
			push.w	R4						; Save R4 to stack
			clr.w	R4						; Clear index

; Checks the first color in game_seq and sets the light accordingly
			cmp.w	#RED, game_seq(R4)		; Check first
			jne		grn_on					; Jump to green LED on
			bis.b	#BIT0, &P1OUT			; Red LED on
			jmp		end_ng					; Skip green LED command

grn_on:		bis.b	#BIT7, &P9OUT			; Green LED on

; End subroutine: return register to inital value
end_ng:		pop.w	R4						; Return R4
			ret								; Return to caller

;-------------------------------------------------------------------------------
; Subroutine: game_over
; Blinks red light 3 times
;
; Input: Subroutine LEDs_off
;		 Subroutine delay
;
; Output: BIT0 in P1OUT
;
; Subroutine does not modify any core registers in R4-R15
; Subroutine does not modify any variables defined in .data or .text
;-------------------------------------------------------------------------------
game_over:
; Setup register for use, turn off LEDs
			push.w	R4						; Push R4 to stack
			clr.w	R4						; Clear R4
			call 	#LEDs_off				; Clear LEDs

; Flashes the red LED three times with delays between
flash_z:
			call 	#delay					; Call timer subroutine
			xor.b	#BIT0, &P1OUT			; Toggle Red LED
			inc.w	R4						; Counter ++
			cmp.w	#6, R4					; Compare counter (R4) to 6
			jne		flash_z					; Loop for three blinks

; Turn off LEDs and return register to initial value
			call	#LEDs_off				; Clear LEDs
			pop.w	R4						; Return R4 from stack
			ret								; Return to caller

;-------------------------------------------------------------------------------
; Subroutine: display_score
; Blinks both lights based on current score held in variable {streak}
;
; Input: Subroutine LEDs_off
;		 Subroutine delay
;		 Variable streak
;
; Output: BIT0 in P1OUT
;		  BIT7 in P9OUT
;
; Subroutine does not modify any core registers in R4-R15
; Subroutine accesses streak in .text
;-------------------------------------------------------------------------------
display_score:
; Setup reigsters for use, turn off LEDs
			push.w	R4						; Push R4 to stack
			push.w	R5						; Push R5 to stack
			clr.w	R4						; Clear R4
			mov.w	&streak, R5				; Copy Streak to R5
			add.w	R5, R5					; Double R5 for loop
			call 	#LEDs_off				; Clear LEDs

; Run LED flash loop for each point socred in streak
flash_lp:
			call 	#delay					; Call timer subroutine
			xor.b	#BIT0, &P1OUT			; Toggle Red LED
			xor.b	#BIT7, &P9OUT			; Toggle Green LED
			inc.w	R4						; Counter ++
			cmp.w	R5, R4					; Compare counter (R4) to streak
			jne		flash_lp				; Loop for three blinks

; End subroutine: return reigsters to initial values and turn off LEDs
			call	#LEDs_off				; Clear LEDs
			pop.w	R5						; Return R5 from stack
			pop.w	R4						; Return R4 from stack
			ret								; Exit subroutine

;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------

; game_master subroutine is called everytime there is an inerrupt on buttons
; P1.1 or P1.2. It is responsible for checking if the right button was pressed,
; tallying the score, and either displaying the score or ending the game.
game_master:
; turn off LEDs, run delay then set up registers
			call	#LEDs_off				; Clear LEDs
			call 	#delay					; Delay for clarity

			push.w	R4						; Save R4 to stack
			push.w	R5						; Save R5 to stack
			push.w	R6						; Save R6 to stack
			clr.w	R5						; Set R5 as "red pressed" (0)

; Check which button triggered the interrupt and hold value in R5
			bit.b	#BIT2, &P1IFG			; Check if P1.2 interrupt
			jnc		streak_set				; Leave as red if not
			inc.w	R5						; Set R5 as "green pressed" (1)

; Check if press was accurate
streak_set:
			mov.w	&index, R6				; Copy index to R6
			cmp.b 	R5, game_seq(R6)		; Check if current value is correct
			jnz		incorrect				; If not the same, call zonk

			inc.w	&streak					; Add one to the streak
			call	#display_score          ; Blink the score
			jmp		next_round				; Jump to next round

; Call wrong answer (game_over) subroutine and restart game
incorrect:	call	#game_over				; Display incorrect lights
			call	#new_game				; Start new game
			jmp		end_gm					; Leave game_master

; Initiate the next round
next_round:	call	#delay					; Delay for smooth transition

			cmp.w	&index, &LENGTH			; Check index value against max
			jlo		increment				; Jump if in bounds
			clr.w	&index					; Reset index if out of bounds

; Increment to next round color
increment:	inc.w	&index					; Increment index for next light
			mov.w	&index, R4				; Copy index to R4

			cmp.b	#RED, game_seq(R4)		; Check whether next step is 1 or 0
			jnz		grn_light				; Jump if 1

			bis.b	#BIT0, &P1OUT			; Red LED on
			jmp 	end_gm					; Skip green to end of routine

grn_light:	bis.b	#BIT7, &P9OUT			; Green LED on

; End the game_master subroutine & remove register modifications
end_gm:		bic.b	#BIT1, &P1IFG			; Clear button 1 interrupt
			bic.b	#BIT2, &P1IFG			; Clear button 2 interrupt

			pop.w	R6						; Return R6 to stack
			pop.w 	R5						; Return R5 to stack
			pop.w	R4						; Return R4 to stack
			reti							; End interrupt

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".int37"
            .short	game_master				; Call game_master on interrupt

            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
