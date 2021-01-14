;Vilius Junevicius, 1 užduotis, užduoties numeris - 17

; A program that asks for an heximal number input and prints out the binary value of each hexidecimal digit

.model small        ; atminties modelis
.stack 100h         ; steko dydis
.data               ; duomenu segmentas
       
nauja_eilute db '', 0dh, 0ah, '$' 
blogai db 'Input only hexidecimal numbers (0 - 9 or A - F)', 0dh, 0ah, '$'   
masyvas db 100 dup (?)
spaces db '   ', '$'
dash db ' - ', '$'

.code           ; kodo segmentas
strt:
mov ax,@data    ; ds registro inicializavimas
mov ds,ax
;----------------------------------------------
per_nauja:
MOV SI, 0                          ; Registrai, kuriuos naudosiu su masyvais
MOV DI, 0

skaitymas:
MOV AH, 01h               ; Interupt komanda, kuri perskaito viena simboli ir issaugoja ji AL registre pagal ascii lenteles reiksmes
INT 21h
MOV masyvas[SI], AL       ; Issaugojam irasytas reiksmes i masyva
INC SI                    
CMP masyvas[SI-1], 0Dh   ; Lyginam ivesta reiksme su "enter" paspaudimo reiksme
JNE skaitymas             ; Jeigu dar neivesta "enter" tada persokam i "skaitymas" ir kartojam viska is naujo
DEC SI                    ; Sumazinam SI registra vienu skaiciumi, kad zinotumem, kiek is viso irasyta sesioliktainiu skaimenu neskaiciuojant "enter"


;validacija
tikrinam:
CMP masyvas[DI], 30h
JNL NEVYKDOM
JMP bloga_ivestis
NEVYKDOM:                     ; Jei ivestu skaiciu ar raidziu ascii simbolis nera tarp 30 ar 46 tada sokam i bloga ivestis
CMP masyvas[DI], 46h
JNG gera_ivestis
JMP bloga_ivestis
gera_ivestis:
MOV BL, 3Ah
ascii:
CMP masyvas[DI], BL                  ; Jei ivestu skaiciu ar raidziu ascii simbolis yra tarp 3A ar 41 tada sokam i bloga ivestis
JE bloga_ivestis
INC BL
CMP BL, 41h
JNE ascii
INC DI          
CMP SI, DI                          ; Tikrinam sekanti skaiciu
JNE tikrinam


MOV DI, 0
konvertavimas:
MOV AL, masyvas[DI]
SUB AL, 30h               ; Atimam 30, jei ivestas skaicius nuo 0 - 9
CMP AL, 09h               ; Jeigu skaicius nuo 0 - 9, tada persokam i "skaicius"
JLE skaicius
SUB AL, 07h               ; Atimam dar 7, jeigu ivestas skaicius nuo A - F
skaicius:
MOV masyvas[DI], AL
INC DI
CMP SI, DI
JNE konvertavimas                


MOV DI, 0
sekantis_skaicius:
MOV AH, 02h              ; Interupt komanda, kuri isspausdinanti simboli is DL registro
MOV CX, 0004h            ; Counter registras, kartosim cikla 4 kartus
MOV BL, masyvas[DI]      ; Issisaugojam masyvo viena reiksme BL registre
RCL BL, 4h               ; Perstumiam pirmus keturis nereikalingus nulius i kaire

ciklas:
MOV DL, 00h             ; Nunulinam DL registra, nes is jo bus imama reiksme, kuria spausdinsim
RCL BL, 1h              ; Perstumia viena bita i kaire, kuris atsiduria "carry flag" 
ADC DL, 30h             ; ADC komanda prideda registra, skaiciu ir "carry flag" esanti skaiciu
DEC CX                  
INT 21h                 ; Interupt komanda, isspausdinam 0, jei DL = 30, isspausdinam 1, jei DL = 31
JNZ ciklas              ; Kartojam cikla, kol CX ne nulis

MOV AH, 02h
MOV DX, 'b'
INT 21h
   
MOV AH, 09h       ; Isspausdinam bruksni
MOV DX, offset dash
INT 21h

MOV AH, 02h
MOV DL, masyvas[DI]
ADD DL, 30h
CMP DL, 39h
JLE praleisti
ADD DL, 07h
praleisti:
INT 21h

MOV AH, 02h
MOV DX, 'h'
INT 21h
   
MOV AH, 09h       ; Isspausdinam tarpa
MOV DX, offset spaces
INT 21h

INC DI                  ; Viena masyvo skaiciu isspausdinom, imam kita masyvo skaiciu
CMP SI, DI              ; Kol DI nebus lygus SI (ivesto sesioliktainio skaiciaus skaitmenu kiekiui),
JNE sekantis_skaicius   ;   tol kartosim cikla su sekanciu skaiciumi
JMP pabaiga              ; Uzbaigiam programa

bloga_ivestis:
MOV AH, 09h                      ; Iterupt komanda, kuri isspausdina tai, kas irasyta DX registre
MOV DX, offset blogai           ; Isspausdinam kintamojo "blogai" sakini
INT 21h                   
MOV DX, offset nauja_eilute     ; Isspausdinam nauja eilute
INT 21h 
JMP per_nauja  

pabaiga:
;-----------------------------------------------
MOV AH,4ch      ; Programos darbo pabaiga
INT 21h
end