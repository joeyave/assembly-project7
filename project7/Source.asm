.386
.model flat, stdcall
option casemap :none
include ../dependencies/masm32/include/masm32.inc
include	../dependencies/masm32/include/kernel32.inc
includelib masm32.lib
includelib kernel32.lib

include converter.inc

.data
    input_data proto msg:ptr dword
    day_of_week proto, day:dword, month:dword, year:dword, century:dword

    day_message db "input day: (1-30(31) or 1-28 if february)", 10, 13, 0
    month_message db "input month: (january, february, march, april, may, june, july, august, september, october, november, december)", 10, 13, 0
    year_message db "input year (2020, 0851, 0041 and so on):", 10, 13, 0
    new_line_message db 10, 13, 0

    day dw ?
    month dw ?
    month_string db 128 dup(?)
    buffer db 128 dup(?)
    year dw ?
    century dw ?

    result dd ?

    year_string db 128 dup(?)
.code
main proc
    .while eax == eax
        ; Ввод данных.
        invoke StdOut, addr day_message
        invoke StdIn, addr buffer, lengthof buffer
        invoke atodw, addr buffer
        mov day, ax

        invoke StdOut, addr month_message
        invoke StdIn, addr month_string, lengthof month_string

        push offset month
        push offset month_string
        mov eax, 2
        push eax
        invoke converter

        invoke StdOut, addr year_message
        invoke StdIn, addr year_string, lengthof year_string

        lea esi, year_string
        lea edi, buffer
        mov ecx, 2
        rep movsb
        mov ax, 0
        mov [edi], ax

        invoke atodw, addr buffer
        mov century, ax

        lea edi, buffer
        mov ecx, 2
        rep movsb
        mov ax, 0
        mov [edi], ax

        invoke atodw, addr buffer
        mov year, ax

        ; Перевод номера месяца в название.
        invoke day_of_week, day, month, year, century
   
        ; Передача параметров через стек. 
        ; Переменная result будет использованна для сохранения результата работы процедуры.
        push offset result
        push edx
        ; Выбор режима работы (из номера в название).
        mov eax, 1
        push eax
        invoke converter

        invoke StdOut, addr result
        invoke StdOut, addr new_line_message
        invoke StdOut, addr new_line_message
    .endw
invoke ExitProcess, 0
main endp

; Определяет день недели, где 0 - воскресенье, ..., 7 - суббота.
; Месяца начинаются с марта, то есть 0 - март, ..., 12 - февраль.
; Формула: ([(26 * Mouth - 2) / 10] + Day + Year + [Century / 4] - 2 * C) mod 7.
; Возвращает:
;   edx - число.
day_of_week proc, day_var:dword, month_var:dword, year_var:dword, century_var:dword
    ; [(26 * Mouth - 2) / 10]
    mov eax, month_var
    mov edx, 26
    mul dl
    sub eax, 2
    mov dl, 10
    div dl
    cbw

    ; [(26 * Mouth - 2) / 10] + Day + Year
    add eax, day_var
    mov ecx, year_var
    add eax, ecx
    mov ecx, eax

    ; [Year / 4]
    mov eax, year_var
    mov dl, 4
    div dl
    cbw

    ; [(26 * Mouth - 2) / 10] + Day + Year + [Year / 4]
    add ecx, eax

    ; [Century / 4]
    mov eax, century_var
    div dl
    cbw

    ; [(26 * Mouth - 2) / 10] + Day + Year + [Century / 4]
    add ecx, eax

    ; 2 * C
    mov eax, century_var
    mov dl, 2
    mul dl

    ; [(26 * Mouth - 2) / 10] + Day + Year + [Century / 4] - 2 * C
    sub ecx, eax

    ; ([(26 * Mouth - 2) / 10] + Day + Year + [Century / 4] - 2 * C) mod 7
    mov eax, ecx

    cmp eax, 0
    jge positive
    negative:
    add eax, 7
    cmp eax, 0
    jl negative
    mov edx, eax
    ret

    positive:
    xor edx, edx
    mov ecx, 7
    div ecx
    ret
day_of_week endp
end main