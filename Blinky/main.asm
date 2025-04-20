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
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
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

			nop
			eint							; Enable interrupts
			nop

			clr.b	&P1IFG					; Clear interrupt so LEDs stay low

main:		jmp		main					; End of program
			nop

;-------------------------------------------------------------------------------
; Interrupt Service Routines
;-------------------------------------------------------------------------------
P1_ISR:
			bit.b	#BIT1, &P1IFG			; Check if P1.1 interrupt
			jnc		P2_ISR					; Next check if not

			xor.b	#BIT7, &P9OUT			; Toggle green LED P1.0
			bic.b	#BIT1, &P1IFG			; Clear interrupt bit



P2_ISR:		bit.b	#BIT2, &P1IFG			; Check if P1.2 interrupt
			jnc		return_to_main			; Return from interrupts if not

			xor.b	#BIT0, &P1OUT			; Toggle red LED
			bic.b	#BIT2, &P1IFG			; Clear interrupt bit


return_to_main:

			reti							; Return from interrupt


;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack


;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect	".int37"
            .short	P1_ISR

            .sect   ".reset"                	; MSP430 RESET Vector
            .short  RESET
            
