
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

jmp inicio

boolean db ?
 
num db 20 dup(?) ; tambien para el turno (ya estaba en generodadoaleatorio)  


ancho_tablero db 74  ;con el numero de fila
alto_tablero db 19 ; contando el 0

 
posInicialEEUU_en_X db 32 
posInicialEEUU_en_Y db 1 
limiteEEUU_en_X db 71

limite_en_Y db 15      ;el limite en Y es para ambos

posInicialURSS_en_X db 3 
posInicialURSS_en_Y db 1
limiteURSS_en_X db 29


cant_W_de_EEUU db 40
cant_W_de_URSS db 54 

puntaje db 10,13,'Puntaje: ','$'


eeuuEligeBase db 'EEUU debe elegir su Base Secreta$'
urssEligeBase db 'URSS debe elegir su Base Secreta$'

string_vacio db '                                 $'


ganoURSS db 'Gano URSS porque EEUU se quedo sin pais!$'
ganoEEUU DB 'Gano EEUU porque URSS se quedo sin pais!$'

ganoURSSporBD db 'Gano URSS por destruir la Base Secreta de EEUU$'
ganoEEUUporBD db 'Gano EEUU por destruir la Base Secreta de URSS$'


leTocaAEEUU db 10,13,'Turno de EEUU$'
leTocaAURSS db 10,13,'Turno de URSS$'

               
new_line db 10,13,'$'  ;parte del init_juego            


Base_fue_destruida db ?   ;indica que pais destruyo la base secreta enemiga

cant_W_esCero db ?        ;indica que pais tiene el puntaje en cero

turnos db 3 

ult_pos_de_EEUU_en_x db 31
ult_pos_de_EEUU_en_y db 1

ult_pos_de_URSS_en_x db 3
ult_pos_de_URSS_en_y db 1


mapaArriba db '00..........................WAR GAMES - 1983..............................'
           db '01.......-.....:**:::*=-..-++++:............:--::=WWW***+-++-.............'
           db '02...:=WWWWWWW=WWW=:::+:..::...--....:=+W==WWWWWWWWWWWWWWWWWWWWWWWW+-.....'
           db '03..-....:WWWWWWWW=-=WW*.........--..+::+=WWWWWWWWWWWWWWWWWWWW:..:=.......'
           db '04.......+WWWWWW*+WWW=-:-.........-+*=:::::=W*W=WWWW*++++++:+++=-.........'
           db '05......*WWWWWWWWW=..............::..-:--+++::-++:::++++++++:--..-........'
           db '06.......:**WW=*=...............-++++:::::-:+::++++++:++++++++............'
           db '07........-+:...-..............:+++++::+:++-++::-.-++++::+:::-............'
           db '08..........--:-...............::++:+++++++:-+:.....::...-+:...-..........'
           db '09..............-+++:-..........:+::+::++++++:-......-....-...---.........'
           db '10..............:::++++:-............::+++:+:.............:--+--.-........'
           db '11..............-+++++++++:...........+:+::+................--.....---....'
           db '12................:++++++:...........-+::+::.:-................-++:-:.....'
           db '13.................++::+-.............::++:..:...............++++++++-....'
           db '14.................:++:-...............::-..................-+:--:++:.....'
           db '15.................:+-............................................-.......'
           db '16.................:......................................................'
           db '17.......UNITED STATES.........................SOVIET UNION...............'
           db '18   5   9   13   18   23   28   33   38   43   48   53   58   63   68   .''$'


inicio:
   programa_principal:
    call init_juego

    call eeuuEligeBS
    call urssEligeBS
                                
    call borrar_msj_de_abajo
    
    call jugar 
    
    call informo_ganador
                         
    mov ah,0
    int 16h

    ret
     
;*************************************************************************************************** 
                          

   proc jugar
     
     call genero_turno_aleatorio
      
     cmp num,5   ;si el numero es mayor que 3 . 3<n, el 3 no lo toma seria [5,9]
     jae juega_URSS
     
     cmp num,4        ;si el numero es menor que 4. n<4. no toma el 4, seria [0, 4]
     jbe juega_EEUU
     
     
    sigo_jugando:
     
     mov turnos,3 
      
      
     ;ANTES DE COMENZAR/SEGUIR JUGANDO PREGUNTO POR LA CANT DE W O LA BASE SECRETA 
        
     cmp Base_fue_destruida,1
     je termino_el_juego
     
     cmp Base_fue_destruida,2
     je termino_el_juego 

     cmp cant_W_esCero,1
     je termino_el_juego
     
     cmp cant_W_esCero,2
     je termino_el_juego   
      
     
     
     ;SI NO FUE DESTRUIDA NINGUNA BASE Y LA CANT DE W ESTAN BIEN SIGO JUGANDO
     
     cmp boolean,1                     
     je juega_URSS
      
     cmp boolean,2    
     je juega_EEUU        
     
     jmp sigo_jugando
     
     
    juega_EEUU:
     call jugar_EEUU
     call disparar  
      
     cmp turnos,0  
     je sigo_jugando  
      
     jmp juega_EEUU
     
    juega_URSS:
     call jugar_URSS
     call disparar  
      
     cmp turnos,0
     je sigo_jugando
      
     jmp juega_URSS
      
    termino_el_juego:
     ret 
     endp jugar
      

 
;***********************************************************************************        
        
        
     
   proc init_juego
    ;Se establece el uso de la pantalla en modo texto
    mov al, 3h
    mov ah, 0
    int 10h 
    
    xor cx,cx
    mov bx, offset mapaArriba
    mov cl, alto_tablero
  ptr_cont_fila:  
    push cx
    mov cl, ancho_tablero
    mov ah, 02h
  ptr_fila:
    mov dl, [BX]
    inc bx
    int 21h
    loop ptr_fila
    mov dx, offset new_line
    mov ah, 09h
    int 21h
    pop cx
    loop ptr_cont_fila

    ret
    endp init_juego 
        

;**************************************************************************************     
    
   proc jugar_EEUU
     
     mov boolean,1
     call informar_pais_turno
     call informar_Puntaje

     xor ax,ax
     xor bx,bx
     xor cx,cx
     xor dx,dx
     
     mov ah,02h                  ;esta subfuncion posiciona al cursor en una posicon del mapa

     mov dl,ult_pos_de_EEUU_en_x
     mov dh,ult_pos_de_EEUU_en_y
     mov bh,0
     int 10h    
 
        
    mover_EEUU:
     
     mov ah,0       ;esta subfuncion lee el carater ingresado por teclado, el caracter escrito lo guarda en AL
     int 16h 
     
     cmp al,'a'
     je moverIzq
     
     cmp al,'d'
     je moverDer
     
     cmp al,'w'
     je moverArriba
     
     cmp al,'x'
     je moverAbajo
     
     cmp al,'s'
     je ejecuto_disp_eeuu
     
     jmp mover_EEUU
      
    moverIzq:
      
     mov ah,03h         ;Esta subfuncion guarda en bh=numero de pagina, dh=fila, dl=columna, ch=linea del inicio del cursor, cl=linea del final del cursor 
     mov bh,0h 
     int 10h
    
     cmp dl,posInicialEEUU_en_X         ;pregunto si mi posicion esta justo en 0, o sea que si estoy en el borde izquierdo no me puedo mover
     jna mover_EEUU
     
     dec dl         ;si no estoy aun en el borde izquierdo me muevo hacia la izquierda 
     mov ah,02h     ;con esta subfuncion establezco una nueva posicon para el puntero   
     int 10h
    
     jmp mover_EEUU  
      
    moverDer:
     mov ah,03h
     mov bh,0h
     int 10h 

     cmp dl,limiteEEUU_en_X
     ja mover_EEUU                ;si dl es mayor que el limite no me puedo mover, por lo que regreso al metodo mover
    
     inc dl                       ;me muevo una columna hacia la derecha
     mov ah,02h
     int 10h  
    
     jmp mover_EEUU   


    moverArriba:
     mov ah,03h
     int 10h
     
     cmp dh,posInicialEEUU_en_Y
     jna mover_EEUU
    
     dec dh
     mov ah,02h
     int 10h
    
     jmp mover_EEUU
    
    
    moverAbajo:
     mov ah,03h
     int 10h
    
     cmp dh,limite_en_Y
     ja mover_EEUU
    
     inc dh
     mov ah,02h
     int 10h
    
     jmp mover_EEUU
    
    ejecuto_disp_eeuu:
     call guardo_ult_posiciones
     ret
     endp jugar_EEUU  
    
    
  
  
 ;******************************************************************************************************************************************    

  proc jugar_URSS
     mov boolean,2
     call informar_pais_turno
     call informar_Puntaje
     
     xor ax,ax
     xor bx,bx
     xor cx,cx
     xor dx,dx

    
     mov ah,02h                  ;esta subfuncion posiciona al cursor en una posicon del mapa

     mov dl,ult_pos_de_URSS_en_x
     mov dh,ult_pos_de_URSS_en_y
     mov bh,0
     int 10h    
        
    mover_URSS:

     mov ah,0       ;esta subfuncion lee el carater ingresado por teclado, el caracter escrito lo guarda en AL
     int 16h 
     
     cmp al,'4'
     je moverIzqURSS
     
     cmp al,'6'
     je moverDerURSS
     
     cmp al,'8'
     je moverArribaURSS
     
     cmp al,'2'
     je moverAbajoURSS
     
     cmp al,'0'
     je ejecuto_disp_urss
     
     
     jmp mover_URSS
     
     
    moverIzqURSS:
     mov ah,03h               ;Esta subfuncion guarda en bh=numero de pagina, dh=fila, dl=columna, ch=linea del inicio del cursor, cl=linea del final del cursor 
     mov bh,0h 
     int 10h
    

     cmp dl,posInicialURSS_en_X         ;pregunto si mi posicion esta justo en el limite de urss, o sea que si estoy en el borde izquierdo no me puedo mover
     jna mover_URSS
     
     dec dl                  ;si no estoy aun en el borde izquierdo me muevo hacia la izquierda 
     mov ah,02h              ;con esta subfuncion establezco una nueva posicon para el puntero   
     int 10h 
     
     jmp mover_URSS
   
    moverDerURSS:
     mov ah,03h
     mov bh,0h
     int 10h
     
     cmp dl,limiteURSS_en_X
     ja mover_URSS
     
     inc dl
     mov ah,02h
     int 10h
      
     jmp mover_URSS 
      
    moverAbajoURSS:
     mov ah,03h
     int 10h
     
     cmp dh,limite_en_Y
     ja mover_URSS
     
     inc dh
     mov ah,02h
     int 10h 
     
     jmp mover_URSS
   
      
   
    moverArribaURSS:
     mov ah,03h
     mov bh,0h
     int 10h
     
     cmp dh,posInicialURSS_en_Y
     jna mover_URSS
     
     dec dh
     mov ah,02h
     int 10h
     
     jmp mover_URSS 
      
    ejecuto_disp_urss:
     call guardo_ult_posiciones
     ret 
     endp jugar_URSS
      
      
       
;**************************************************************************************************************************************************************** 

proc disparar 
     
    
;PARA BS Y W
;ESTO POSICIONA UN PUNTERO BX ENCIMA DEL CURSOR, ES PARA VERFICAR LUEGO LA BS Y LAS W    
    
 mov bh,0           ;primero obtengo la posicion del cursor
 mov ah,03          ;Esta subfuncion guarda en bh=numero de pagina, dh=fila, dl=columna, ch=linea del inicio del cursor, cl=linea del final del cursor
 int 10h

 xor bx,bx
 mov bx,offset mapaArriba

 xor cx,cx
 mov cl,dh      ;guardo en cl=cx la cantidad de veces que le tendre que sumar al puntero un ancho de tablero para llegar a la pos del cursor

 cmp dh,0                 ;si mi cursor esta en la fila 0 simplemente me muevo hasta la columna en la que este
 je voy_hasta_xx

me_muevo_en_YY:
 add bx,74
 loop me_muevo_en_YY    ;le sumare un ancho de tablero al puntero, lo que hara sera "bajar a la posicion de abajo"

voy_hasta_xx:
 xor cx,cx
 mov cl,dl    ;dl las columnas q me debo mover
  
 me_muevo_hasta_xx:
  inc bx
  loop me_muevo_hasta_xx
                                          
;se supone que hasta aca ya llegue a la pos del cursor                       
   
                 

;PARA BS Y W

;parte de arriba
sub bx,74
dec bx
CALL verifico_disparo               ;cada que disparo me fijo si es una w o base secreta
mov [bx],0                          ;PARA QUE EL CARACTER SE BORRE DE VERDAD LO CAMBIO A VACIO
inc bx
CALL verifico_disparo
mov [bx],0
inc bx
CALL verifico_disparo
mov [bx],0
dec bx
add bx,74 ;vuelvo al medio medio  

;parte de en medio
dec bx
CALL verifico_disparo
mov [bx],0
inc bx
CALL verifico_disparo
mov [bx],0
inc bx
CALL verifico_disparo
mov [bx],0
dec bx ;vuelvo al medio medio


;parte de abajo
add bx,74
dec bx
CALL verifico_disparo
mov [bx],0
inc bx
CALL verifico_disparo
mov [bx],0
inc bx
CALL verifico_disparo
mov [bx],0
dec bx
sub bx,74  ;vuelvo al medio medio

                          
                          
                          
;"borro" por pantalla
                          
borro_arriba_horizontalE: 

mov bh,0           ;primero obtengo la posicion del cursor
mov ah,03          ;Esta subfuncion guarda en bh=numero de pagina, dh=fila, dl=columna, ch=linea del inicio del cursor, cl=linea del final del cursor
int 10h

dec dl  
dec dh

mov ah,02    ;posiciono el cursor
int 10h                                                       

mov dl,0  ;ahora se sobreescribira por encima de un caracter, un valor nulo  0=nulo
int 21h
mov dl,0
int 21h
mov dl,0
int 21h

mov bh,0
mov ah,03  ;primero vuelvo a preg en las coordenadas en donde estoy
int 10h

sub dl,2       ;modifico las coordenadas
inc dh 

mov ah,02      ;lo posiciono nuevamente
int 10h


borro_medio_horizontalE: 

dec dl           ;voy al carcter de la izq, me muevo una columna a la izq

mov ah,02
int 10h          ;posiciono el cursor 

mov dl,0       ;borro
int 21h
mov dl,0        ;cuando se escribe un caracter el cursor pasa a la pos de al lado, por lo que simplemente vuelvo a escribir el carac vacio
int 21h
mov dl,0
int 21h

mov ah,03
mov bh,0
int 10h 

sub dl,2 
mov ah,02   ;vuelvo a la pos original 
int 10h 


borro_abajo_horizontalE:

inc dh              ;voy a la parte de abajo
dec dl

mov ah,02  
int 10h             ;declaro el cursor debajo (modifique las coordenadas arriba)

mov dl,0            ;borro
int 21h
mov dl,0
int 21h
mov dl,0
int 21h 

mov ah,03  
mov bh,0
int 10h    ;vuelvo a preguntar por las coordenadas

sub dl,2
dec dh

mov ah,02   ;vuelvo a declarar el cursor en el medio (pos original)
int 10h


dec turnos
     
ret
endp disparo
    
    
;************************************************************************************************************************************************************

  proc verifico_disparo

    cmp bx,si             ;si contiene la posicion de la BS de eeuu
    je Base_destruida

    cmp bx,di           ;di contiene la posicion de la BS de urss
    je Base_destruida 
 
    cmp [bx],'W'
    je descontar_Puntaje

    jmp termino 

   Base_destruida:
     ;con la variable boolean ya sabre de quien fue la base destruida
     ;boolean 1=eeuu,   boolean 2=urss . Por lo que Base_fue_destruida guardara el valor de a quien se le destruyo la base 
     ;si aun ninguna base fue destruida la variable Base_fue_destruida no tendra ningun valor, si ese valor cambia terminara 
     ;el juego (se puede ver en el metodo del principio, "proc jugar => sigo_jugando")
     
    xor cx,cx
    mov cl,boolean
    mov Base_fue_destruida,cl
    jmp termino
    
    
   descontar_Puntaje:
   ;antes de descontar el puntaje verifico a quien le pertenece esa W
     cmp boolean,1
     je descuento_URSS
        
     cmp boolean,2
     je descuento_EEUU
        
     jmp termino
        
     descuento_EEUU:
       dec cant_W_de_EEUU          ;dec =reg-1 
       
       cmp cant_W_de_EEUU,00     
       jbe puntaje_cero_de_eeuu
       
       jmp termino
            
       puntaje_cero_de_eeuu:      ;SI EEUU TIENE EL PUNTAJE EN 0 GANA URSS
         MOV cant_W_esCero,1       ;le pongo a cant_W_esCero el boolean del equipo que se quedo en 0
         jmp termino
              
              
     descuento_URSS:
       dec cant_W_de_URSS
       
       cmp cant_W_de_URSS,00   
       jbe puntaje_cero_de_urss
       
       jmp termino
               
       puntaje_cero_de_urss:
         mov cant_W_esCero,2
         jmp termino  

   termino:
     ret 
     endp verifico_disparo     
 

;*******************************************************************************************************************************************************
 
   
;DIBUJO EN PANTALLA A QUIEN LE TOCA   
  proc informar_pais_turno

     mov dl,0h        ;columna en la que quiero que se dibuje la frase
     mov dh,20        ;fila en la que quiero que se dibuje la palabra
     MOV ah,02
     int 10h           ;con la interrupcion ah=02 int 10h lo que hace es ubicar al cursor en una posicion del mapa, en este caso la ubique al fondo para que no se sobreescriba con el mapa
       
     cmp boolean,2
     je le_toca_a_URSS 
       
     cmp boolean,1
     je le_toca_a_EEUU
       
   le_toca_a_URSS:
     mov dx,offset leTocaAURSS
     mov ah,09h            ;con esta subfuncion se imprime en pantalla un string de caracteres al que apunte bx 
     int 21h
     jmp fin 
       
   le_toca_a_EEUU:      
     mov dx,offset leTocaAEEUU
     mov ah,09h
     int 21h 
     jmp fin
           
   fin:
     ret
     endp informar_pais_turno 
   
;*********************************************************************************************************************************************************    
    
proc informar_Puntaje

   ;ESCRIBO PUNTAJE POR PANTALLA  
     mov dh,21  ;ubico cursor
     mov dl,0
     mov ah,2
     int 10h 
     
     mov dx,offset puntaje ;imprimo puntaje
     mov ah,09
     int 21h
    
    
   ;MUESTRO EL NUMERO DEL PUNTAJE   
     cmp boolean,1
     je mostrar_Punt_EEUU
  
     cmp boolean,2
     je mostrar_Punt_URSS
  
   mostrar_Punt_EEUU:
     xor ax,ax
     xor bx,bx
     xor cx,cx
     xor dx,dx
    
     mov al,cant_W_de_EEUU
     mov cl,10
     div cl
     mov bl,al          ;como la div = ah=resto, al=cociente, y necesitamos usar el ah para la interrupcion guardamos en bl y bh
     mov bh,ah
     
     
     mov ah,2     ;muestro el numero
     mov dl,bl
     add dl,30h
     int 21h
     
     mov dl,bh   ;muestro el numero
     add dl,30h
     int 21h

     jmp terminodemostrarpuntaje
     
     
   mostrar_Punt_URSS:
     xor ax,ax
     xor bx,bx
     xor cx,cx
     xor dx,dx

     mov al,cant_W_de_URSS   
     mov cl,10
     div cl
     mov bl,al
     mov bh,ah
     
     mov ah,2
     mov dl,bl
     add dl,30h
     int 21h          ;muestro el numero
     
     mov dl,bh
     add dl,30h       ;muestro el numero
     int 21h
     
     jmp terminodemostrarpuntaje
     
   terminodemostrarpuntaje: 
     ret
     endp informar_Puntaje 

;********************************************************************************************          

    proc genero_turno_aleatorio
     
     mov bx,0    
     mov ah, 2ch ; Esta interrupcion me entrega la hora fragmentada en los registros, 
                 ; CH(h) CL(m) DH(s),DL (centesimo seg)int 21h       ; como este es solo un entero entre 1y6 
                 ;tomo solo los centesimo seg   
     int 21h            
     xor ah,ah
     mov al,dl    ;mueve a al el valor de los centesimos porque la divison lo divide siempre al valor de ax por algo (en 8bits)
     mov bl,10
     div bl   ;Dividuo por 10 y me quedo con el resto. El resto se guarda en ah y el cociente en al

                 ;en este momento ya dividi por 10 mi valor centesimo por lo que tendria un digito entre 0 a 9                 
     mov  num,ah ;en ah el entero generado, en el resto=ah, se guarda el digito con una cifra
     
     ret 
    endp genero_de_quien_es_el_turno  
    


;********************************************************************************************

  proc guardo_ult_posiciones 
    mov ah,03
    int 10h         ;obtengo la posicion del cursor
    
    cmp boolean,1
    je guardo_pos_de_EEUU
    
    cmp boolean,2
    je guardo_pos_de_URSS
                       
    jmp guarde_pos                   
                       
    guardo_pos_de_EEUU:    
    mov ult_pos_de_EEUU_en_x,dl
    mov ult_pos_de_EEUU_en_y,dh
    
    jmp guarde_pos
    
    guardo_pos_de_URSS:
    mov ult_pos_de_URSS_en_x,DL
    mov ult_pos_de_URSS_en_y,DH
    
    jmp guarde_pos

    guarde_pos:
    ret
    endp guardo_ult_posiciones
    
    
;******************************************************************************************** 
 
                     
 proc eeuuEligeBS
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx

    ;DIGO DE QUIEN ES EL TURNO
    
    mov dh,20 ;declaramos el cursor debajo de todo el mapa
    mov dl,0
    mov bh,0
    mov ah,2
    int 10h
    
    mov dx,offset eeuuEligeBase  ;imprimimos por pantalla
    mov ah,09
    int 21h

   
   ;posicionamos el cursor donde debe ir al comienzo del juego
   
    mov ah,02h                  ;esta subfuncion posiciona al cursor en una posicon del mapa
    mov dl,posInicialURSS_en_X
    mov dh,posInicialURSS_en_Y
    mov bh,0
    int 10h 

           
   ;mov bh,0           ;primero obtengo la posicion del cursor para ejecutar las etiquetas mover
   ;mov ah,03          ;Esta subfuncion guarda en bh=numero de pagina, dh=fila, dl=columna, ch=linea del inicio del cursor, cl=linea del final del cursor
   ;int 10h
  
  
  mover_EEUU_BASE:
     
     mov ah,0       ;esta subfuncion lee el carater ingresado por teclado, el caracter escrito lo guarda en AL
     int 16h 
     
     cmp al,'a'
     je moverIzq_BASE
     
     cmp al,'d'
     je moverDer_BASE
     
     cmp al,'w'
     je moverArriba_BASE
     
     cmp al,'x'
     je moverAbajo_BASE
     
     cmp al,'b'
     je USA_choose_Base
     
     jmp mover_EEUU_BASE
      
    moverIzq_BASE:
      
     mov ah,03h         ;para moverme a la izquierda obtengo la posicon del cursor. Esta subfuncion guarda en bh=numero de pagina, dh=fila, dl=columna, ch=linea del inicio del cursor, cl=linea del final del cursor 
     mov bh,0h 
     int 10h
    

     cmp dl,posInicialURSS_en_X         ;pregunto si mi posicion esta justo en 0, o sea que si estoy en el borde izquierdo no me puedo mover
     jna mover_EEUU_BASE
     
     dec dl         ;si no estoy aun en el borde izquierdo me muevo hacia la izquierda 
     mov ah,02h     ;con esta subfuncion establezco una nueva posicon para el puntero   
     int 10h
    
     jmp mover_EEUU_BASE
        
    moverDer_BASE:
     mov ah,03h
     mov bh,0h
     int 10h 

     cmp dl,limiteURSS_en_X
     ja mover_EEUU_BASE                ;si dl es mayor que el limite no me puedo mover, por lo que regreso al metodo mover
    
     inc dl      ;me muevo una columna hacia la derecha
     mov ah,02h
     int 10h  
    
     jmp mover_EEUU_BASE    ;cuando se mueve hacia la derecha vuelvo al procedimiento mover para que se siga moviendo hacia algun otro lado


    moverArriba_BASE:
     mov ah,03h
     int 10h
    
     cmp dh,posInicialURSS_en_Y
     jna mover_EEUU_BASE
    
     dec dh
     mov ah,02h
     int 10h
    
     jmp mover_EEUU_BASE
    
    
    moverAbajo_BASE:
     mov ah,03h
     int 10h
    
     cmp dh,limite_en_Y
     ja mover_EEUU_BASE
    
     inc dh
     mov ah,02h
     int 10h
    
     jmp mover_EEUU_BASE
  

          
;ESTO PARA BASE SECRETA POSICION EN EL VECTOR          
          
 USA_choose_Base: 
  mov bx,offset mapaArriba

  xor cx,cx
  mov cl,dh      ;guardo en cl=cx la cantidad de veces que le tendre que sumar al puntero un ancho de tablero para llegar a la pos del cursor

  cmp dh,0                 ;si mi cursor esta en la fila 0 simplemente me muevo hasta la columna en la que este
  je voy_hasta_x

 me_muevo_en_Y:
  add bx,74
  loop me_muevo_en_Y    ;le sumare un ancho de tablero al puntero, lo que hara sera "bajar a la posicion de abajo"


 voy_hasta_x:
  xor cx,cx
  mov cl,dl    ;dl las columnas q me debo mover
  
  me_muevo_hasta_x:
   inc bx
   loop me_muevo_hasta_x
  
  
 mov si,bx 

;ahora SI tendra la coordenada de la base secreta de eeuu
   
   ret
   endp eeuuEligeBS



 
 
;******************************************************************************************** 
proc urssEligeBS
    
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
    

    ;DIGO DE QUIEN ES EL TURNO
    
    mov dh,20 ;declaramos el cursor debajo de todo el mapa
    mov dl,0
    mov bh,0
    mov ah,2
    int 10h
    
    mov dx,offset urssEligeBase  ;imprimimos por pantalla
    mov ah,09
    int 21h
    
   
   ;luego de imprimir posicionamos el cursor donde debe ir al comi  
    mov ah,02h                  ;esta subfuncion posiciona al cursor en una posicon del mapa

    mov dl,posInicialEEUU_en_X
    mov dh,posInicialEEUU_en_Y
    mov bh,0
    int 10h 
        
    mov bh,0           ;primero obtengo la posicion del cursor
    mov ah,03          ;Esta subfuncion guarda en bh=numero de pagina, dh=fila, dl=columna, ch=linea del inicio del cursor, cl=linea del final del cursor
    int 10h
    
    

   mover_URSS_BASE:
     
     mov ah,0       ;esta subfuncion lee el carater ingresado por teclado, el caracter escrito lo guarda en AL
     int 16h 
     
     cmp al,'4'
     je moverIzqURSS_BASE
     
     cmp al,'6'
     je moverDerURSS_BASE
     
     cmp al,'8'
     je moverArribaURSS_BASE
     
     cmp al,'2'
     je moverAbajoURSS_BASE
     
     cmp al,'9'
     je URSS_CHOOSE_BASE
     
     
     jmp mover_URSS_BASE
     
     
    moverIzqURSS_BASE:
     mov ah,03h                   ;para moverme a la izquierda obtengo la posicon del cursor. Esta subfuncion guarda en bh=numero de pagina, dh=fila, dl=columna, ch=linea del inicio del cursor, cl=linea del final del cursor 
     mov bh,0h 
     int 10h
    

     cmp dl,posInicialEEUU_en_X         ;pregunto si mi posicion esta justo en el limite de urss, o sea que si estoy en el borde izquierdo no me puedo mover
     jna mover_URSS_BASE
     
     dec dl         ;si no estoy aun en el borde izquierdo me muevo hacia la izquierda 
     mov ah,02h     ;con esta subfuncion establezco una nueva posicon para el puntero   
     int 10h 
     
     jmp mover_URSS_BASE
   
    moverDerURSS_BASE:
     mov ah,03h
     mov bh,0h
     int 10h
     
     cmp dl,limiteEEUU_en_X
     ja mover_URSS_BASE
     
     inc dl
     mov ah,02h
     int 10h
      
     jmp mover_URSS_BASE 
      
    moverAbajoURSS_BASE:
     mov ah,03h
     int 10h
     
     cmp dh,limite_en_Y
     ja mover_URSS_BASE
     
     inc dh
     mov ah,02h
     int 10h 
     
     jmp mover_URSS_BASE
   
      
   
    moverArribaURSS_BASE:
     mov ah,03h
     mov bh,0h
     int 10h
     
     cmp dh,posInicialEEUU_en_Y
     jna mover_URSS_BASE
     
     dec dh
     mov ah,02h
     int 10h
     
     jmp mover_URSS_BASE  
    
    
    
 URSS_CHOOSE_BASE:   
    
  
  mov bx,offset mapaArriba

  xor cx,cx
  mov cl,dh      ;guardo en cl=cx la cantidad de veces que le tendre que sumar al puntero un ancho de tablero para llegar a la pos del cursor

  cmp dh,0                 ;si mi cursor esta en la fila 0 simplemente me muevo hasta la columna en la que este
  je voy_hasta_xxx

  me_muevo_en_YYY:
  add bx,74
  loop me_muevo_en_YYY    ;le sumare un ancho de tablero al puntero, lo que hara sera "bajar a la posicion de abajo"

  voy_hasta_xxx:
  xor cx,cx
  mov cl,dl    ;dl las columnas q me debo mover
  
  me_muevo_hasta_xxx:
   inc bx
   loop me_muevo_hasta_xxx  
   
  mov DI,bx

   
 ;ahora DI tendra la coordenada de la base secreta de urss  
                                                                                              
                                                                                             
;******************************************************************************************** 


proc borrar_msj_de_abajo
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
    ;borro el primer renglon de abajo
    mov dh,20 ;declaramos el cursor debajo de todo el mapa
    mov dl,0
    mov bh,0
    mov ah,2
    int 10h
    
    mov dx,offset string_vacio  ;imprimimos por pantalla
    mov ah,09
    int 21h   
    
    ;borro el segundo renglon de abajo
    mov dh,21 ;declaramos el cursor debajo de todo el mapa
    mov dl,0
    mov bh,0
    mov ah,2
    int 10h
    
    mov dx,offset string_vacio  ;imprimimos por pantalla
    mov ah,09
    int 21h
    

    ret 
    endp borrar_lo_de_abajo

;********************************************************************************************                            
  proc informo_ganador
   
    XOR AX,AX
    XOR BX,BX
    XOR CX,CX
    XOR DX,DX
   
    mov ah,0         ;se declara un nuevo modo de video
    mov al, 3h
    int 10h 
  
    cmp Base_fue_destruida,1
    je gano_EEUU_porBaseDestruida
   
    cmp Base_fue_destruida,2  
    je gano_URSS_porBaseDestruida
    
    cmp cant_W_esCero,1
    je gano_URSS
   
    cmp cant_W_esCero,2
    je gano_EEUU 
    
   gano_URSS:
    MOV AH,09 
    MOV DX,OFFSET ganoURSS
    int 21h
    jmp finish
   
   gano_EEUU:
    MOV AH,09
    mov dx, offset ganoEEUU
    int 21h
    jmp finish
          
   gano_EEUU_porBaseDestruida:
    mov ah,09
    mov dx,offset ganoEEUUporBD
    int 21h
    jmp finish
    
   gano_URSS_porBaseDestruida:
    mov ah,09
    mov dx,offset ganoURSSporBD
    int 21h
    jmp finish 
   
        
   finish:
   ret 
   endp informo_ganador