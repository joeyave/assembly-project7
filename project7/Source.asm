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

    day_message db "input day:", 10, 13, 0
    month_message db "input month:", 10, 13, 0
    year_message db "input year:", 10, 13, 0
    century_message db "input century:", 10, 13, 0
    new_line_message db 10, 13, 0

    day dw ?
    month dw ?
    year dw ?
    century dw ?

    result dd ?

.code
main proc
    .while eax == eax
        ; Ввод данных.
        invoke input_data, addr day_message
        mov day, ax

        invoke input_data, addr month_message
        sub ax, 2
        test ax, ax
        jns not_signed
            add ax, 12
        not_signed:
        mov month, ax

        invoke input_data, addr year_message
        mov year, ax
        invoke input_data, addr century_message
        mov century, ax

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

; Выводит запрос, который передан в качесве параметра, на консоль.
; Возвращает:
;   eax - число.
input_data proc msg_var:ptr dword
    .data 
    buff dw 128 dup(?)

    .code
    invoke StdOut, msg_var
    invoke StdIn, addr buff, lengthof buff
    invoke atodw, addr buff
    ret
input_data endp

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
    xor edx, edx
    mov eax, ecx
    test eax, eax
    jns not_signed
    neg eax
    not_signed:
    mov ecx, 7
    div ecx
    ret
day_of_week endp
end main