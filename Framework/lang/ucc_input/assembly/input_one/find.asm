;********************************
;*
;* find relative file
;*
;* version 2.5
;*
;*
;* inputs
;*  recl   - 1byte=lo record #
;*  rech   - 1byte=hi record #
;*  rs     - 1byte=record size
;*  recptr - 1byte=first byte
;*            wanted from record
;*
;* outputs
;*  ssnum  - 1byte=side sector #
;*  ssind  - 1byte=index into ss
;*  relptr - 1byte=ptr to first
;*            byte wanted
;*
;********************************

fndrel  jsr  mulply     ; result=rn*rs+rp
        jsr  div254     ; divide by 254
        lda  accum+1    ; save remainder
        sta  relptr
        jsr  div120     ; divide by 120
        inc  relptr
        inc  relptr
        lda  result     ; save quotient
        sta  ssnum
        lda  accum+1    ; save remainder
        asl  a          ; calc index into ss
        clc
        adc  #16        ; skip link table
        sta  ssind
        rts



; multiply

; result=recnum*rs+recptr

;  destroys a,x

mulply  jsr  zerres     ; result=0
        sta  accum+3    ; a=0
        ldx  lindx      ; get index
        lda  recl,x
        sta  accum+1
        lda  rech,x
        sta  accum+2
        bne  mul25      ; adjust for rec #1 &...
        lda  accum+1    ; ...#0 = 1st rec
        beq  mul50
mul25   lda  accum+1
        sec
        sbc  #1
        sta  accum+1
        bcs  mul50
        dec  accum+2
mul50
        lda  rs,x       ; copy recsiz
        sta  temp
mul100  lsr  temp       ; do an add ?
        bcc  mul200     ; no
        jsr  addres     ; result=result+accum+1,2,3
mul200  jsr  accx2      ; 2*(accum+1,2,3)
        lda  temp       ; done ?
        bne  mul100     ; no
        lda  recptr     ; add in last bit
        clc
        adc  result
        sta  result
        bcc  mul400     ; skip no carry
        inc  result+1
        bne  mul400
        inc  result+2
mul400  rts



; divide

; result=quotient ,accum+1=remainder

;  destroys a,x

div254  lda  #254       ; divide by 254
        .byte  skip2    ; skip two bytes
div120  lda  #120       ; divide by 120
        sta  temp       ; save divisor
        ldx  #3         ; swap accum+1,2,3 with
div100  lda  accum,x    ; result,1,2
        pha
        lda  result-1,x
        sta  accum,x
        pla
        sta  result-1,x
        dex
        bne  div100
        jsr  zerres     ; result=0
div150  ldx  #0
div200  lda  accum+1,x  ; divide by 256
        sta  accum,x
        inx
        cpx  #4         ; done ?
        bcc  div200     ; no
        lda  #0         ; zero hi byte
        sta  accum+3
        bit  temp       ; a div120 ?
        bmi  div300     ; no
        asl  accum      ; only divide by 128
        php             ; save carry
        lsr  accum      ; normalize
        plp             ; restore carry
        jsr  acc200     ; 2*(x/256)=x/128
div300  jsr  addres     ; total a quotient
        jsr  accx2      ; a=2*a
        bit  temp       ; a div120 ?
        bmi  div400     ; no
        jsr  accx4      ; a=4*(2*a)=8*a
div400  lda  accum      ; add in remainder
        clc
        adc  accum+1
        sta  accum+1
        bcc  div500
        inc  accum+2
        bne  div500
        inc  accum+3
div500  lda  accum+3    ; test < 256
        ora  accum+2
        bne  div150     ; crunch some more
        lda  accum+1    ; is remainder < divisor
        sec
        sbc  temp
        bcc  div700     ; yes
        inc  result     ; no - fix result
        bne  div600
        inc  result+1
        bne  div600
        inc  result+2
div600  sta  accum+1    ; new remainder
div700  rts



; zero result

zerres  lda  #0
        sta  result
        sta  result+1
        sta  result+2
        rts


; multiply accum by 4

accx4   jsr  accx2

; multiply accum by 2

accx2   clc
acc200  rol  accum+1
        rol  accum+2
        rol  accum+3
        rts



; add accum to result

;  result=result+accum+1,2,3

addres  clc
        ldx  #$fd
add100  lda  result+3,x
        adc  accum+4,x
        sta  result+3,x
        inx
        bne  add100
        rts