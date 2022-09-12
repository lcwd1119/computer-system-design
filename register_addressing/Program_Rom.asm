#include 	<p16Lf1826.inc>		; Include file locate at defult directory
;
temp		equ	0x25
temp1		equ 0x24
temp2		equ 0x23
;***************************************
;           Program start              *
;***************************************
			org 	0x00		; reset vector
			
start		movlw 	.6
			movwf	temp1
			clrf	temp
			clrw

loop1		movlw 	.9
			movwf	temp2

loop2		movlw	1
			addwf	temp,1
			movf	temp,0
			movwf	PORTB
			;call	delay
			decfsz	temp2,1
			goto 	loop2
			
			
		
			decfsz	temp1,0
			call	carry_on
			;call	delay
			decfsz	temp1,1
			goto 	loop1
			goto 	start

carry_on	movlw	.7
			addwf	temp,1
			movf	temp,0
			movwf	PORTB
			return
			end	