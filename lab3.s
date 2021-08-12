; Archivo lab3.s
; Dispositivo PIC16F887
; Autor Luis J. Archila
; pic-as v2.32 
    
 PROCESSOR 16F887
 #include <xc.inc>
 
 ;configuration word 1
 CONFIG FOSC=INTRC_NOCLKOUT
 CONFIG WDTE=OFF    
 CONFIG PWRTE=ON    
 CONFIG MCLRE=OFF   
 CONFIG CP=OFF	    
 CONFIG CPD=OFF	    
				; configuración del PIC
 CONFIG BOREN=OFF   
 CONFIG IESO=OFF    
 CONFIG FCMEN=OFF   
 CONFIG LVP=ON	    
 
 ;configuration word 2
 CONFIG WRT=OFF	    
 CONFIG BOR4V=BOR40V
 
 PSECT udata_bank0 ; common memory
    cont:	DS  2
    
 ;----Vector Reset----
 PSECT resVect, class=CODE, abs, delta=2
 ORG 00h	;posición 0000h para el reset
 resetVec:
     PAGESEL main
     goto main
     
 PSECT code, delta=2, abs
 ORG 100h	; posición para el código
 
 tabla:
    clrf    PCLATH
    bsf	    PCLATH, 0	; PCLATH = 01
    andlw   0x0f
    addwf   PCL		; PCLATH + PCL + W
    retlw   00111111B ;0
    retlw   00000110B ;1
    retlw   01011011B ;2
    retlw   01001111B ;3
    retlw   01100110B ;4
    retlw   01101101B ;5
    retlw   01111101B ;6
    retlw   00000111B ;7
    retlw   01111111B ;8
    retlw   01101111B ;9
    retlw   01110111B ;A
    retlw   01111100B ;B
    retlw   00111001B ;C
    retlw   01011110B ;D
    retlw   01111001B ;E
    retlw   01110001B ;F
 
 ;----configuración----
 main:
    call    config_io
    call    config_reloj
    banksel PORTA
    
 ;----loop principal----
 loop:
    ;incremetar contador
    btfsc   PORTB, 0
    call    inc_porta
    ;decrementar contador
    btfsc   PORTB, 1
    call    dec_porta
    ;incf    PORTA
    movf    PORTA, w
    call    tabla
    movwf   PORTC
    call    delay
    goto    loop		   
    
 ;----sub rutinas----
 config_io:
    banksel ANSEL
    clrf    ANSEL	; pines digitales
    clrf    ANSELH
    
    banksel TRISA
    clrf    TRISA	; port A como salida
    clrf    TRISC	;port C como salida
    bsf	    TRISB, 0	;pines 0 y 1 PORTB como input
    bsf	    TRISB, 1
    
    banksel PORTA
    clrf    PORTA	;eliminar cualquier valor inicial de los puertos de salida
    clrf    PORTC
    return
 
; ----oscilador a 500KHz----
config_reloj:
    banksel OSCCON
    bcf	    IRCF2	    ; OSCCON, 6 como 1
    bsf	    IRCF1	    ; OSCCON, 5 como 0
    bsf	    IRCF0	    ; OSCCON, 4 como 0
    bsf	    SCS		    ; reloj interno
    return
    
inc_porta:
    call    delay_small
    btfsc   PORTB, 0
    goto    $-1
    incf    PORTA
    btfsc   PORTA, 4	;revisar si se exdece de 4 bits
    bcf	    PORTA, 4	;limpiar el pin si eso pasa
    return
    
dec_porta:
    call    delay_small
    btfsc   PORTB, 1
    goto    $-1
    decf    PORTA
    btfsc   PORTA, 4	;revisar si se exdece de 4 bits
    bcf	    PORTA, 4	;limpiar el puerto si eso pasa
    bcf	    PORTA, 5
    bcf	    PORTA, 6
    bcf	    PORTA, 7
    return
     
 delay:
    movlw   50		    ; valor inicial del contador
    movwf   cont+1
    call    delay_small	    ; rutina de delay
    decfsz  cont+1, 1	    ; decrementar el contador
    goto    $-2		    ; ejecutar dos líneas atrás
    return
    
 END


