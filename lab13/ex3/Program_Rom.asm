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
			clrf	ans
			movlw	.21
			movwf	a
			movlw	.3
			movwf	c
			
loop		movf	c,0
			subwf	a,1
			incf	ans
			btfss	a,7
			goto	loop
			decf	ans
			movf    ans,0
			movwf	PORTB
			goto	$
			end