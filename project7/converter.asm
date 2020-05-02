.model flat, stdcall

.data
    szCmpi PROTO :DWORD,:DWORD,:DWORD
    StrLen PROTO :DWORD

    days_of_the_week db "sunday   monday   tuesday  wednesdaythursday friday   saturday "
    months db "march    april    may      june     july     august   septemberoctober  november december january  february "
    nine dd 9
    input_len dw ?
.code
; ��������� ���� �� ���� �������:
;   1. ��������� ����� ������ � ��� ��������.
;   2. ��������� �������� ������ � ��� �����.
; ��� ����, ����� ������� ����� ������, ����� � ������ ����������
; �������� ��������������� ����� (1 ��� 2).

; ��������� ��������� ����� Stack Frame.
;   [ebp+8] - ����� ������.
;   [ebp+12] - ����� ��� �������� ������ (� ����������� �� ������ ������).
;   [ebp+16] - ���������.
converter proc
    push ebp
    mov ebp, esp

    ; ��� ���������� ������� ����� � ��������.
    mov eax, [ebp+8]
    .if eax == 1
        lea esi, days_of_the_week
        mov eax, [ebp+12]

        mul nine
        add esi, eax
        mov ecx, nine
        mov edi, [ebp+16]
        rep movsb

    ; ��� ���������� ������� �������� � �����.
    .elseif eax == 2
        mov ebx, 1

        mov esi, [ebp+12]
        invoke StrLen, esi
        mov input_len, ax
        mov edi, offset months
        .while eax == eax
            ; ��� ������� ���������� ��� ������ � ���������� 0 � eax, ���� ��� �����.
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