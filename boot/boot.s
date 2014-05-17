.code16


.text
BOOTSEG = 0x07c0
INITSEG = 0x9000

.global _start

_start:
    mov     $BOOTSEG,%ax
    mov     %ax,%ds
    mov     $INITSEG,%ax
    mov     %ax,%es
    mov     $256,%cx
    sub     %si,%si
    sub     %di,%di
    rep
    movsb
    ljmp    $INITSEG,$go
go:
    mov     %cs,%ax
    mov     %ax,%ds
    mov     %ax,%es
    call    DispStr
    jmp     .
DispStr:
    mov     $BootMessage,%ax
    mov     %ax,%bp
    mov     $0x10,%cx
    mov     $0x1301,%ax
    mov     $0x00c,%bx
    mov     $0x0,%dl
    int     $0x10
    ret
BootMessage: .string "Hello,OS world!"
.org 510
.short 0xaa55 
.end


