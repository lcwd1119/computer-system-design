#include 	<p16Lf1826.inc>		; Include file locate at defult directory
;
temp		equ	0x22
tempm		equ 0x21
temp1		equ 0x26
temp2		equ 0x25
temp3		equ 0x24
temp4		equ 0x23
;***************************************
;           Program start              *
;***************************************
			org 	0x00		; reset vector
		
	
start		movlw 	.6
			movwf	temp1
			clrf	temp
			clrf	tempm
			clrw

loop1		movlw 	.9
			movwf	temp2

loop2				movlw 	.6
					movwf	temp3
loop3						movlw 	.9
							movwf	temp4
loop4								movlw	1
									addwf	temp,1
									movf	temp,0
									decfsz	temp4,1
									goto 	loop4

							decfsz	temp3,0
							call	carry_on
							decfsz	temp3,1
							goto 	loop3

					clrf	temp
					movlw	1
					addwf	tempm,1
					movf	tempm,0
					decfsz	temp2,1
					goto 	loop2
			decfsz	temp1,0
			call	carry_on_m
			decfsz	temp1,1
			goto 	loop1
			goto 	start



carry_on	movlw	.7
			addwf	temp,1
			movf	temp,0
			return
carry_on_m	movlw	.7
			addwf	tempm,1
			movf	tempm,0
			return
			end	