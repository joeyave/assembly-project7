.model flat, stdcall

.data
    szCmpi PROTO :DWORD,:DWORD,:DWORD
    StrLen PROTO :DWORD

    days_of_the_week db "sunday   monday   tuesday  wednesdaythursday friday   saturday "
    months db "march    april    may      june     july     august   septemberoctober  november december january  february "
    nine dd 9
    input_len dw ?
.code
; ¬ыполн€ет одну из двух функций:
;   1. ѕереводит номер мес€ца в его название.
;   2. ѕереводит название мес€ца в его номер.
; ƒл€ того, чтобы выбрать режим работы, нужно в первым параметром
; передать соответствующее число (1 или 2).

; ѕринимает параметры через Stack Frame.
;   [ebp+8] - режим работы.
;   [ebp+12] - номер или название мес€ца (в зависимости от режима работы).
;   [ebp+16] - результат.
converter proc
    push ebp
    mov ebp, esp

    ; “ут происходит перевод числа в название.
    mov eax, [ebp+8]
    .if eax == 1
        lea esi, days_of_the_week
        mov eax, [ebp+12]

        mul nine
        add esi, eax
        mov ecx, nine
        mov edi, [ebp+16]
        rep movsb

    ; тут происходит перевод названи€ в число.
    .elseif eax == 2
        mov ebx, 1

        mov esi, [ebp+12]
        invoke StrLen, esi
        mov input_len, ax
        mov edi, offset months
        .while eax == eax
            ; Ёта функци€ сравнивает две строки и записывает 0 в eax, если они равны.
            invoke szCmpi, esi, edi, input_len
            .if !eax
                mov esi, [ebp+16]
                mov [esi], ebx
                pop ebp
                ret 8
            .else
                add edi, nine
                add ebx, 1
            .endif
        .endw   
    .endif

    pop ebp
    ret 8
converter endp
end