.code16


.global _start

.text
    BOOTSEG = 0x07c0  #注意实际地址=段地址*16+偏移 
    INITSEG = 0x9000  #将整段代码移动到这个位置
    SETUPSEG = 0x9020 #SETUP程序位置
    STACk_SETUP = 0xfef4

#    ljmp    $BOOTSEG,$_start
_start:
    mov     $BOOTSEG,%ax
    mov     %ax,%ds
    mov     $INITSEG,%ax
    mov     %ax,%es
    mov     $256,%cx
    xor     %si,%si
    xor     %di,%di
    rep
    movsw
    ljmp    $INITSEG,$go

go:
    mov     %cs,%ax
    mov     %ax,%ds
    mov     %ax,%es
    mov     $STACk_SETUP,%dx   #将栈地址ss:sp设置为0x9000:fef4,据说要将后面12字节保存一些奇怪的东西
    mov     %ax,%ss
    mov     %dx,%sp

    push    $0
    pop     %fs
    mov     $0x78,%bx
    
    
    movw     %fs:(%bx),%si
    inc      %bx
    inc      %bx
    movw     %fs:(%bx),%ds

    mov     %dx,%di
    mov     $6,%cx
   # cld
    
   # call    DispStr
    
    rep
    movsw
#ds，es被使用过，重新修改
    mov     %cs,%ax
    mov     %ax,%ds
    mov     %ax,%es
    
    call    DispStr
    jmp     .

DispStr:
    push    %ax
    push    %bp
    push    %cx
    push    %dx
    mov     $BootMessage,%ax
    mov     %ax,%bp
    mov     $0x10,%cx
    mov     $0x1301,%ax
    mov     $0x00c,%bx
    mov     $0x0,%dx
    int     $0x10
    pop     %dx
    pop     %cx
    pop     %bp
    pop     %ax
    ret
BootMessage: .string "Hello,OS world!"
.org 510
.short 0xaa55 
.end


