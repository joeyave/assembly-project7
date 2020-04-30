.model flat, stdcall

.data
    szCmpi PROTO :DWORD,:DWORD,:DWORD

    days_of_the_week db "sunday   monday   tuesday  wednesdaythursday friday   saturday "
    nine dd 9

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
        mov ebx, 0

        mov esi, [ebp+12]
        mov edi, offset days_of_the_week
        .while eax == eax
            ; ��� ������� ���������� ��� ������ � ���������� 0 � eax, ���� ��� �����.
            invoke szCmpi, esi, edi, nine
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