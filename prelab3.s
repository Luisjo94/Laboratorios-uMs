; Arcchivo:	prelab3.s
; Dispositivo:	PIC16F887
; Autor:	Luis J. Archila
; Compilador	pic-as v2.32
    
PROCESSOR 16F887

; PIC16F887 Configuration Bit Settings
#include <xc.inc>

; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO oscillator: I/O function on RA6/OSC2/CLKOUT pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = ON             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR pin function is digital input, MCLR internally tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = ON              ; Low Voltage Programming Enable bit (RB3/PGM pin has PGM function, low voltage programming enabled)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

/*
PSECT udata_bank0 ; common memory
  cont:    DS	2 ; 1 byte
  */
  
;----Vector Reset----
 PSECT resVect, class=CODE, abs, delta=2
 ORG 00h	;posición 0000h para el reset
 resetVec:
     PAGESEL main
     goto main
     
PSECT code, delta=2, abs
 ORG 100h	; posición para el código

;configuración
 main:
    call    config_io
    call    clock_conf
    call    tmr0_conf 
    banksel PORTA
    
 ;----loop principal----
 loop:
    btfsc   T0IF
    goto    $-1
    call    tmr0_restart
    call    only4bit
    goto    loop

;----subrutinas----
tmr0_conf:
    banksel TRISA
    bcf	    T0CS    ;reloj interno
    bcf	    PSA	    ;prescaler asignado al tmr0
    bsf	    PS2
    bsf	    PS1
    bsf	    PS0	    ;PS = 111 = 1:256
    banksel PORTA
    call tmr0_restart
    return
    
tmr0_restart:
    movlw   12	;empezar a contar desde 12
    movwf   TMR0
    bcf	    T0IF
    return
    
config_io:
    banksel ANSEL   ;banco 11
    clrf    ANSEL
    clrf    ANSELH
    
    banksel TRISA   ;banco 01
    clrf    TRISA
    
    banksel PORTA   ;banco 00
    clrf    PORTA
    return
    
clock_conf:
    banksel OSCCON
    ; 250 KHz
    bcf	    IRCF2 ;0
    bsf	    IRCF1 ;1
    bcf	    IRCF0 ;0
    bsf	    SCS	    ;reloj interno
    return
    
only4bit:
    incf    PORTA
    btfsc   PORTA, 4
    bcf	    PORTA, 4
    return
    
END


