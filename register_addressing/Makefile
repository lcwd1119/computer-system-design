# MPLAB IDE generated this makefile for use with GNU make.
# Project: register_addressing.mcp
# Date: Tue Dec 21 00:19:16 2021

AS = MPASMWIN.exe
CC = 
LD = mplink.exe
AR = mplib.exe
RM = rm

register_addressing.cof : Program_Rom.o
	$(CC) /p16F1826 "Program_Rom.o" /u_DEBUG /z__MPLAB_BUILD=1 /z__MPLAB_DEBUG=1 /o"register_addressing.cof" /M"register_addressing.map" /W

Program_Rom.o : Program_Rom.asm D:/Program\ Files/Microchip/MPASM\ Suite/p16Lf1826.inc
	$(AS) /q /p16F1826 "Program_Rom.asm" /l"Program_Rom.lst" /e"Program_Rom.err" /o"Program_Rom.o" /d__DEBUG=1

clean : 
	$(CC) "Program_Rom.o" "Program_Rom.err" "Program_Rom.lst" "register_addressing.cof" "register_addressing.hex"

