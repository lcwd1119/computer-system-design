#include 	<p16Lf1826.inc>		; Include file locate at defult directory
;
a		equ 0x25
c		equ 0x24
ans		equ 0x23
;***************************************
;           Program start              *
;***************************************
			org 	0x00		; reset vector
			
			clrw	
			movlw	.5
			movwf	a
			movlw	.3
			movwf	c
			clrf	ans
			clrw
loop		addwf	a,0
			movwf	ans
			decfsz	c,1
			goto	loop
			movwf	PORTB
			goto	$
			end