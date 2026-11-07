.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
INCLUDE Irvine32.inc

.data
    prompt      BYTE "Enter expression: ", 0
    resultMsg   BYTE " = ", 0
    errorMsg    BYTE "Error: Division by zero!", 0

    equation    BYTE 256 DUP(0)
    eqIndex     DWORD 0

    currentNum  SDWORD 0
    result      SDWORD 0
    lastOp      BYTE '+'
    curOp       BYTE 0
    isNegative  BYTE 0
    termChar    BYTE 0

.code


AppendChar PROC
    push ebx
    mov ebx, DWORD PTR eqIndex    
    cmp ebx, 254
    ja  skip_write
    
    mov [equation + ebx], al
    inc ebx
    mov eqIndex, ebx
skip_write:
    pop ebx
    ret
AppendChar ENDP


IntToString PROC
    
    pushad
    cmp eax, 0
    jne IT_not_zero
    mov al, '0'
    call AppendChar
    popad
    ret

IT_not_zero:
    mov ecx, 0          
    cmp eax, 0
    jge IT_positive
    neg eax
    push eax            ;save the number, AL is about to be overwritten
    mov al, '-'         
    call AppendChar
    pop eax             ; restore the number

IT_positive:
    mov ebx, 10
IT_div_loop:
    xor edx, edx
    div ebx            
    push edx            
    inc ecx
    cmp eax, 0
    jne IT_div_loop

IT_write:
    cmp ecx, 0
    je IT_done
    pop ebx             
    add bl, '0'        
    mov al, bl
    call AppendChar
    dec ecx
    jmp IT_write

IT_done:
    popad
    ret
IntToString ENDP

main PROC
    mov result, 0
    mov lastOp, '+'
    mov currentNum, 0
    mov isNegative, 0

    mov edx, OFFSET prompt
    call WriteString

InputLoop:
    call ReadChar       
    call WriteChar     

    ; termination check
    cmp al, '='
    je ProcessFinal
    cmp al, '?'
    je ProcessFinal

    ; digit?
    cmp al, '0'
    jb CheckSign
    cmp al, '9'
    ja CheckSign

    ; it's a digit: accumulate
    push ebx
    ; convert ascii to number
    sub al, '0'
    movzx ebx, al           ; ebx = digit (0..9)

    mov eax, currentNum
    mov ecx, 10
    mul ecx                 ; EDX:EAX = currentNum * 10
    add eax, ebx
    mov currentNum, eax

    pop ebx
    jmp InputLoop

CheckSign:
    cmp al, '-'
    jne CheckOperator

    ; '-' maybe a negative sign or subtraction operator
    mov eax, currentNum
    cmp eax, 0
    jne ProcessOperator     
    cmp isNegative, 0
    jne InputLoop           ; already negative sign
    mov isNegative, 1
    jmp InputLoop

CheckOperator:
    
    cmp al, '+'
    je ProcessOperator
    cmp al, '-'
    je ProcessOperator
    cmp al, '*'
    je ProcessOperator
    cmp al, '/'
    je ProcessOperator
    jmp InputLoop           

ProcessOperator:
    
    mov curOp, al

    
    mov eax,currentNum
    cmp isNegative, 1
    jne PO_not_negative
    neg eax
PO_not_negative:

    
    call IntToString

    push eax            ; push the number BEFORE AppendChar overwrites AL
   
    mov al, ' '
    call AppendChar
    mov al, curOp
    call AppendChar
    mov al, ' '
    call AppendChar

    mov al, lastOp
    cmp al, '+'
    je DoAdd
    cmp al, '-'
    je DoSub
    cmp al, '*'
    je DoMul
    cmp al, '/'
    je DoDiv
    jmp PO_ResetVars

DoAdd:
    pop eax
    add result, eax
    jmp PO_ResetVars

DoSub:
    pop eax
    sub result, eax
    jmp PO_ResetVars

DoMul:
    pop eax
    push ebx
    mov ebx, eax
    mov eax, result
    imul ebx
    mov result, eax
    pop ebx
    jmp PO_ResetVars

DoDiv:
    pop eax
    cmp eax, 0
    je DivZero
    push ebx
    mov ebx, eax
    mov eax, result
    cdq
    idiv ebx
    mov result, eax
    pop ebx
    jmp PO_ResetVars

PO_ResetVars:
    mov currentNum, 0
    mov isNegative, 0
    mov al, curOp
    mov lastOp, al
    jmp InputLoop

ProcessFinal:
    mov termChar, al
    mov eax, currentNum
    cmp isNegative, 1
    jne PF_not_negative
    neg eax
PF_not_negative:

   
    call IntToString

    push eax            ; push the number before anything touches AL
    
    

    mov ebx, eqIndex
    mov BYTE PTR [equation + ebx], 0

    mov al, lastOp
    cmp al, '+'
    je FinalAdd
    cmp al, '-'
    je FinalSub
    cmp al, '*'
    je FinalMul
    cmp al, '/'
    je FinalDiv
    jmp DisplayResult

FinalAdd:
    pop eax
    add result, eax
    jmp DisplayResult

FinalSub:
    pop eax
    sub result, eax
    jmp DisplayResult

FinalMul:
    pop eax
    push ebx
    mov ebx, eax
    mov eax, result
    imul ebx
    mov result, eax
    pop ebx
    jmp DisplayResult

FinalDiv:
    pop eax
    cmp eax, 0
    je DivZero
    push ebx
    mov ebx, eax
    mov eax, result
    cdq
    idiv ebx
    mov result, eax
    pop ebx
    jmp DisplayResult

DisplayResult:
    call Crlf
    mov edx, OFFSET equation
    call WriteString
    mov edx, OFFSET resultMsg
    call WriteString
    mov eax, result
    call WriteInt
    call Crlf
    INVOKE ExitProcess, 0

DivZero:
    call Crlf
    mov edx, OFFSET errorMsg
    call WriteString
    call Crlf
    INVOKE ExitProcess, 1

main ENDP
END main