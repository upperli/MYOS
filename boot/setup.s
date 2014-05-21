.code16

.globl _start
INITSEG = 0x9000
.text

_start:
    mov     %cs,%ax    
    mov     %ax,%ds
    mov     %ax,%es

    mov     $0x0003,%ax
    int     $0x10

    mov     $0x1301,%ax
    mov     $0x00,%dx
    mov     $7,%cx
    mov     $0x0007,%bx
    mov     $LOAD_MESSAGE,%bp
    int     $0x10

    jmp     .    
    mov     $INITSEG,%ax
    mov     %ax,%ds
    mov     $0x88,%ah
    int     $0x15
    mov     %ax,2

    mov     $0x12,%ah
    mov     $0x10,%bl
    int     $0x10

    mov     %ax,2
    mov     %bx,10
    mov     %cx,12
    mov     $0x5019,%ax
    cmp     $0x10,%bl
    je      novga
    call    chsvga
novga:
    mov     %ax,14
    mov     $0x03,%ah
    xor     %bh,%bh
    int     $0x10
    mov     %dx,0

    mov     $0x0f,%ah
    int     $0x10
    mov     %bx,4
    mov     %ax,6

    mov     $0x0000,%ax
    mov     %ax,%ds
    mov     0x41*4,%ds
    mov     0x41*4+2,%si
    mov     $INITSEG,%ax
    mov     %ax,%es
    mov     $0x0080,%di
    mov     $0x10,%cx
    rep
    movsb



    mov     $0x0000,%ax
    mov     %ax,%ds
    mov     0x46*4,%ds
    mov     0x46*4+2,%si
    mov     $INITSEG,%ax
    mov     %ax,%es
    mov     $0x0090,%di
    mov     $0x10,%cx
    rep
    movsb

    mov     $0x1500,%ax
    mov     $0x81,%dl
    int     $0x13
    jc      no_disk1
    cmp     $3,%ah
    je      is_disk1
no_disk1:
    mov     $INITSEG,%ax
    mov     %ax,%es
    mov     $0x0090,%di
    mov     $0x10,%cx
    mov     $0x00,%ax
    rep
    stosb


is_disk1:
    cli
    jmp     .

chsvga:

LOAD_MESSAGE:
    .string     "aaaaaaaaa"


