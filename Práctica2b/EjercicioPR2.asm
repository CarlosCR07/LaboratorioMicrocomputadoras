#INCLUDE <P16F877A.inc>

processor PIC16F877A  ; procesador a utilizar
TEMP equ 0xff
RESULTADO equ 0xfe
cblock
d1
d2
endc
org 0X00              ; Vector de reset
GOTO 0X05             ;Envia PC a la direccion 05
org 0X05              ; Inicio del programa
INICIO                ; Etiqueta INICIO
	BSF         STATUS, RP0        ; Accedemos al banco
    CLRF        TRISA            ; Configuramos PORTA como entrada
    CLRF        TRISB            ; Configuramos PORTB como salida
    BCF         STATUS, RP0        ; Regresamos al banco 0
CICLO                 ; Etiqueta para el ciclo del programa
	MOVF        PORTA, W        ; Movemos el valor de PORTA a W
    ANDLW       0x0F            ; Obtenemos los 4 bits menos significativos
    MOVWF       TEMP        ; guardar el valor en TEMP
    CALL MULTIPLICAR            ; Multiplicamos por 4 los bits
    MOVLW   20                  ; cargar el valor 20 en W
    SUBWF   RESULTADO,W         ; restamos Resultado a W
    BTFSS   STATUS,C           ; VERIFICAMOS SI EL VALOR ES POSITIVO (<20)
    GOTO    desplazamiento_izquierda ; saltar si PORTA*4 < 20
    
    RRF     TEMP,W      ; rotamos TEMP a la derecha para dividir ente 2 (segunda condicion)
    MOVLW   0x07        ; cargar el valor 7 
    SUBWF   TEMP,W      ; restar TEMP a W
    BTFSS   STATUS,C    ; saltar si el resultado de la resta es positivo (PORTA/2 > 7)
    GOTO    desplazamiento_derecha ; saltar si PORTA/2 > 7
    
    MOVLW   0x0F        ; CARGAMOS OXOF EN W PARA VERIFICAR LA CONDICIOM
    SUBWF   TEMP,W      ; RESTAMOS EL VALOR DE LOS 4 BITS CON W
    BTFSS   STATUS,Z    ; SALTAMOS si PORTA - 0x0F ? 0x00)
    GOTO    desplazamiento_centro ; SALTAR A LA ETIQUETA DE LA CONDICION
    
    MOVLW   0x00        ; cargar el valor 0x00 en W
    XORWF   TEMP,W      ; HACEMOS UN XOR DE LOS BITS CON W
    BTFSS   STATUS,Z    ; saltar si el resultado del XOR no es cero
    GOTO    desplazamiento_centro2 ; saltar si PORTA = 0x00

    GOTO    CICLO        ; EMPEZAMOS DE NUEVO SI NO SE CUMPLE INGUNA CANCION


    
    
MULTIPLICAR:
    CLRF RESULTADO   ; Limpiar el registro RESULTADO
    ADDWF W, W        ; Sumar W consigo mismo (multiplicar por 2)
    ADDWF W, W        ; Sumar W consigo mismo nuevamente (Multiplicar por 4)
    MOVWF RESULTADO        ; GUARDA EL RESUKTADO EN TEMP
    RETURN
    
desplazamiento_izquierda:
	BCF PORTB, 0 ; Apagamos el LED
    ;CALL DELAY200 ; Retardo de 200 ms
    RLF PORTB, F ; Desplaza a la izquierda
    BSF PORTB, 7 ; Enciende el LED
    ;CALL DELAY200 ; Retardo de 200 ms
    
desplazamiento_derecha:
	BCF PORTB, 0 ; Apagamos el LED
    ;CALL DELAY150 ; Retardo de 150 ms
	RRF PORTB, F ; Desplazamiento a la derecha del valor en el puerto B
	BSF PORTB, 7 ; Enciende el LED
    ;CALL DELAY150 ; Retardo de 150 ms
    
desplazamiento_centro:
	MOVLW 0x81 ; Cargar el primer valor del desplazamiento
    MOVWF PORTB ; Escribir el valor en el puerto B
    ;CALL DELAY200 ; Esperar 200 ms
    MOVLW 0x42 ; Cargar el segundo valor del desplazamiento
    MOVWF PORTB ; Escribir el valor en el puerto B
    ;CALL DELAY200 ; Esperar 200 ms
    MOVLW 0x24 ; Cargar el tercer valor del desplazamiento
    MOVWF PORTB ; Escribir el valor en el puerto B
    ;CALL DELAY200 ; Esperar 200 ms
    MOVLW 0x18 ; Cargar el cuarto valor del desplazamiento
    MOVWF PORTB ; Escribir el valor en el puerto B
    ;CALL DELAY200 ; Esperar 200 ms
    
desplazamiento_centro2:
   movlw   0x80            ; Encender LED más significativo (RB7)
   movwf   PORTB
   ;call    delay           ; Esperar 50 ms
   movlw   0x00            ; Apagar LED más significativo (RB7)
   movwf   PORTB
   ;call    delay           ; Esperar 50 ms

   movlw   0x40            ; Encender segundo LED más significativo (RB6)
   movwf   PORTB
   ;call    delay           ; Esperar 50 ms
   movlw   0x00            ; Apagar segundo LED más significativo (RB6)
   movwf   PORTB
   ;call    delay           ; Esperar 50 ms

   movlw   0x20            ; Encender LED central (RB5)
   movwf   PORTB
   ;call    delay           ; Esperar 50 ms
   movlw   0x00            ; Apagar LED central (RB5)
   movwf   PORTB
   ;call    delay           ; Esperar 50 ms

   movlw   0x40            ; Encender segundo LED menos significativo (RB6)
   movwf   PORTB
   ;call    delay           ; Esperar 50 ms
   movlw   0x00            ; Apagar segundo LED menos significativo (RB6)
   movwf   PORTB
   ;call    delay           ; Esperar 50 ms

   movlw   0x80            ; Encender LED menos significativo (RB7)
   movwf   PORTB
   ;call    delay           ; Esperar 50 ms
   movlw   0x00            ; Apagar LED menos significativo (RB7)
   movwf   PORTB
   ;call    delay           ; Esperar 50 ms
    
DELAY200
			;199993 cycles
	movlw	0x3E
	movwf	d1
	movlw	0x9D
	movwf	d2
Delay_0
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	Delay_0

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return
	
DELAY150
			;149993 cycles
	movlw	0x2E
	movwf	d1
	movlw	0x76
	movwf	d2
Delay_1
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	Delay_1

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return

delay
			;49993 cycles
	movlw	0x0E
	movwf	d1
	movlw	0x28
	movwf	d2
Delay_2
	decfsz	d1, f
	goto	$+2
	decfsz	d2, f
	goto	Delay_2

			;3 cycles
	goto	$+1
	nop

			;4 cycles (including call)
	return
END