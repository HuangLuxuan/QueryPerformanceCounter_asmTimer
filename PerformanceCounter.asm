%include "nasmx.inc"
%include "win32/user32.inc"
%include "win32/kernel32.inc"
%include "win32/windows.inc"
%include "win32/gdi32.inc"

section .bss
hWnd resd 1
hInstance resd 1

hStatic resd 1
hButton resd 1

state resb 1
count resb 8
frq resb 8


section .data

WinMain_className dw __utf16__("WperformanceCounter"),0
WinMain_windowName dw __utf16__("Performance Counter"),0
WinMain_err dw __utf16__("错误"),0
WinMain_errRegClassEx dw __utf16__("调用RegisterClassExW时出错"),0
WinMain_errCreateWindowEx dw __utf16__("调用CreateWindowExW时出错"),0
WinMain_errGetMessage dw __utf16__("调用GetMessageW时出错"),0
WinMain_errQueryPerformanceFrequency dw __utf16__("调用QueryPerformanceFrequency时出错"),0
errorMessageBoxW_errFormatMessageW dw __utf16__("调用FormatMessageW获取错误信息时出错"),0
errorMessageBoxW_errFormatString dw __utf16__("%s(%d)：%s"),0

szStatic dw __utf16__("STATIC"),0
szButton dw __utf16__("BUTTON"),0

szStart dw __utf16__("开始"),0
szStop dw __utf16__("结束"),0

updateLabel_fromat dw __utf16__("%d.%03d,%03d,%03ds"),0ah,0dh,__utf16__("频率%d.%03d,%03dMHz"),0
double_kilo dq 1000.0

section .text

proc cdecl, errorMessageBoxW, dword lpTitle, dword lpMessage
locals
local errCode, dword
local lpErrMsg, dword
local lpMsg, dword
endlocals
    invoke GetLastError
    mov [var(.errCode)],eax
    xor eax,eax
    push eax
    push eax
    lea ecx, [var(.lpErrMsg)]
    push ecx 
    push eax
    push dword [var(.errCode)]
    push eax
    push dword FORMAT_MESSAGE_ALLOCATE_BUFFER|FORMAT_MESSAGE_FROM_SYSTEM
    invoke FormatMessageW
    or eax,eax
    jnz .lbl1
    invoke MessageBoxW, dword [hWnd], dword errorMessageBoxW_errFormatMessageW, dword [argv(.lpTitle)], dword MB_OK|MB_ICONERROR
    return dword [var(.errCode)]
.lbl1:
    invoke lstrlenW, dword [argv(.lpMessage)]
    push eax
    invoke lstrlenW, dword [var(.lpErrMsg)]
    pop ecx
    add eax,ecx
    add eax,32
    shl eax,1
    invoke LocalAlloc, dword LMEM_FIXED, eax
    mov [var(.lpMsg)], eax
    invoke wsprintfW, eax, dword errorMessageBoxW_errFormatString, dword [argv(.lpMessage)], dword [var(.errCode)], dword [var(.lpErrMsg)]
    invoke LocalFree, dword [var(.lpErrMsg)]
    invoke MessageBoxW, dword [hWnd], dword [var(.lpMsg)], dword [argv(.lpTitle)], dword MB_OK|MB_ICONERROR
    invoke LocalFree, dword [var(.lpMsg)]
    return dword [var(.errCode)]
endproc

proc stdcall, NoCRTMain
locals
    push dword SW_SHOWNORMAL
    invoke GetCommandLineA
    push eax
    push dword 0
    invoke GetModuleHandleA, dword NULL
    push eax
proto stdcall, WinMain, dword hInstance, dword hPrevInstance, dword lpCmdLine, dword nShowCmd
    invoke WinMain
    invoke ExitProcess, eax
    int 3
endproc

proc stdcall, WinMain, dword hInstance, dword hPrevInstance, dword lpCmdLine, dword nShowCmd
locals
local wndClassEx, byte, sizeof(WNDCLASSEX)
local lpMsg, DWORD
endlocals
    invoke QueryPerformanceFrequency, dword frq
    or eax,eax
    jnz .lbl1
    invoke errorMessageBoxW, dword WinMain_err, dword WinMain_errQueryPerformanceFrequency
    return eax
.lbl1:
    xor eax,eax
    mov [hWnd],eax
    mov ecx,sizeof(WNDCLASSEX)
    cld
    lea edi,[var(.wndClassEx)]
    rep stosb
    mov [var(.wndClassEx)+WNDCLASSEX.cbSize], dword sizeof(WNDCLASSEX)
    mov [var(.wndClassEx)+WNDCLASSEX.style], dword CS_VREDRAW + CS_HREDRAW
proto stdcall, WinProc, dword hWnd, dword uMsg, dword wParam, dword lParam
    mov [var(.wndClassEx)+WNDCLASSEX.lpfnWndProc], dword WinProc
    mov eax, [argv(.hInstance)]
    mov [hInstance],eax
    mov [var(.wndClassEx)+WNDCLASSEX.hInstance], eax
    mov [var(.wndClassEx)+WNDCLASSEX.hbrBackground], dword COLOR_WINDOWFRAME
    mov [var(.wndClassEx)+WNDCLASSEX.lpszClassName], dword WinMain_className
    invoke RegisterClassExW, dword var(.wndClassEx)
    or eax,eax
    jnz .lbl2
    invoke errorMessageBoxW, dword WinMain_err, dword WinMain_errRegClassEx
    return eax
.lbl2:
    invoke CreateWindowExW, dword 0, dword WinMain_className, dword WinMain_windowName, \
        dword WS_OVERLAPPED|WS_VISIBLE|WS_CAPTION|WS_SYSMENU|WS_THICKFRAME, dword CW_USEDEFAULT, \
        dword CW_USEDEFAULT, dword 200, dword 100, dword NULL, dword NULL, dword [argv(.hInstance)], \
        dword NULL
    or eax,eax
    jnz .lbl3
    invoke errorMessageBoxW, dword WinMain_err, dword WinMain_errCreateWindowEx
    return eax
.lbl3:
    mov [hWnd],eax
    invoke ShowWindow, eax, dword [argv(.nShowCmd)]
    invoke UpdateWindow,dword [hWnd]
.loop:
    invoke GetMessageW, dword var(.lpMsg), dword NULL, dword 0, dword 0
    or eax,eax
    jnz .lbl4
    return 0
.lbl4:
    inc eax
    or eax,eax
    jnz .lbl5
    mov [hWnd],eax
    invoke errorMessageBoxW, dword WinMain_err, dword WinMain_errGetMessage
    return eax
.lbl5:
    invoke TranslateMessage, dword var(.lpMsg)
    invoke DispatchMessageW, dword var(.lpMsg)
    jmp .loop
endproc

proc stdcall, WinProc, dword hWnd, dword uMsg, dword wParam, dword lParam
locals
    mov eax, [argv(.uMsg)]
    cmp eax, WM_CREATE
    jne .lbl1
proto cdecl,onCreateWindow, dword hWnd
    invoke onCreateWindow, dword [argv(.hWnd)]
    return 0
.lbl1:
    cmp eax, WM_DESTROY
    jne .lbl2
    invoke PostQuitMessage,dword 0
    return 0
.lbl2:
    cmp eax, WM_COMMAND
    jne .lbl3
    mov eax, [argv(.lParam)]
    cmp eax, [hButton]
    jne .lbl4
    xor eax,eax
    mov al, [state]
    or eax,eax
    jz .lbl5
    mov byte[state], 0
    invoke KillTimer, dword [hWnd], dword 1
    sub esp,8
    invoke QueryPerformanceCounter, esp
proto cdecl,updateLabel, qword count2
    invoke updateLabel
    add esp,8
    mov ecx,szStart
    jmp .lbl6
.lbl5:
    mov byte[state], 1
    invoke QueryPerformanceCounter, dword count
    invoke SetTimer, dword [hWnd], dword 1, dword 16, dword NULL
    mov ecx,szStop
.lbl6:
    invoke SendMessageW, dword [hButton], WM_SETTEXT, dword 0, ecx
.lbl4:
    return 0
.lbl3:
    cmp eax, WM_TIMER
    jne .lbl8
    sub esp,8
    invoke QueryPerformanceCounter, esp
    invoke updateLabel
    add esp,8
.lbl8:
    invoke DefWindowProcW, dword [argv(.hWnd)], eax, dword [argv(.wParam)], dword [argv(.lParam)]
    return
endproc

proc cdecl,onCreateWindow, dword hWnd
locals
    invoke CreateWindowExW, dword NULL, dword szStatic, dword NULL, dword WS_CHILD|WS_VISIBLE, \
        dword 0, dword 0, dword 184, dword 31, dword [argv(.hWnd)], dword NULL, dword [hInstance], dword 0
    or eax,eax
    jnz .lbl1
    invoke errorMessageBoxW, dword WinMain_err, dword WinMain_errCreateWindowEx
    invoke ExitProcess, eax
    return
.lbl1:
    mov [hStatic], eax
    push eax
    push eax
    mov [count], eax
    mov [count+4], eax
    invoke updateLabel
    add esp,8
    invoke CreateWindowExW, dword NULL, dword szButton, dword szStart, dword WS_CHILD|WS_VISIBLE, \
        dword 0, dword 31, dword 184, dword 30, dword [argv(.hWnd)], dword NULL, dword [hInstance], dword 0
    or eax,eax
    jnz .lbl2
    invoke errorMessageBoxW, dword WinMain_err, dword WinMain_errCreateWindowEx
    invoke ExitProcess, eax
    return
.lbl2:
    mov [hButton],eax
    return
endproc

proc cdecl,updateLabel, qword count2
locals
local dCount, qword
local fctrlw, dword
local ns, dword
local us, dword
local ms, dword
local s, dword
local Hz, dword
local kHz, dword
local MHz, dword
local buf, byte, 256
endlocals
    mov eax, [argv(.count2)]
    sub eax, [count]
    mov [var(.dCount)], eax
    mov eax, [argv(.count2)+4]
    sbb eax, [count+4]
    mov [var(.dCount)+4], eax
    fld qword[double_kilo]
    fild qword[var(.dCount)]
    fild qword[frq]
    fdivp
    fld st0
    fstcw word[var(.fctrlw)]
    or word[var(.fctrlw)],0x0C00
    fldcw word[var(.fctrlw)]
    frndint
    fsub st1,st0
    fistp dword[var(.s)]
    fmul st0,st1
    fld st0
    frndint
    fsub st1,st0
    fistp dword[var(.ms)]
    fmul st0,st1
    fld st0
    frndint
    fsub st1,st0
    fistp dword[var(.us)]
    fmul st0,st1
    frndint
    fistp dword[var(.ns)]
    fild qword[frq]
    fdiv st0,st1
    fdiv st0,st1
    fld st0
    frndint
    fsub st1,st0
    fistp dword[var(.MHz)]
    fmul st0,st1
    fld st0
    frndint
    fsub st1,st0
    fistp dword[var(.kHz)]
    fmul st0,st1
    frndint
    fistp dword[var(.Hz)]
    fstp st0
    invoke wsprintfW, dword var(.buf), dword updateLabel_fromat, \
        dword [var(.s)], dword [var(.ms)], dword [var(.us)], dword [var(.ns)], \
        dword [var(.MHz)], dword [var(.kHz)], dword [var(.Hz)]
    invoke SendMessageW, dword [hStatic], WM_SETTEXT, dword 0, dword var(.buf)
    return
endproc