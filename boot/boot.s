.code16


.global _start

.text
BOOTSEG = 0x07c0  #注意实际地址=段地址*16+偏移 
INITSEG = 0x9000  #将整段代码移动到这个位置
SETUPSEG = 0x9020 #SETUP程序位置
SYSSEG = 0x1000
STACk_SETUP = 0xfef4
SETUPLEN = 4
SYSSIZE = 0x3000
ENDSEG = SYSSEG + SYSSIZE
ROOT_DEV = 0
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
    movw     %fs:2(%bx),%ds

    mov     %dx,%di
    mov     $6,%cx
    cld
    #将软盘参数转移到0x9000：0xfef4的位置，原始位置在0x0000:0x0078所储存的地址中；0x1E*4 = 0x78
    rep
    movsw

    mov     %dx,%di
    mov     %dx,%bx
    movb    $18,4(%bx)#将表中偏移4出的最大扇区数改为18

#将0x0000:0x0078的中的数据改成0x9000:0xfef4
    mov     $0x78,%bx
    movw    %di,%fs:(%bx)
    movw    %es,%fs:2(%bx)



#ds，es被使用过，重新修改
    mov     %cs,%ax
    mov     %ax,%ds
    mov     %ax,%es
    mov     %ax,%fs
    mov     %ax,%gs

#复位软盘，并且使用第一个软驱
    xor     %ah,%ah
    xor     %dl,%dl
    int     $0x13

#接下来将不断读取软盘，直至成功为止
#INT 0x13参数:
#ah = 0x02 读取磁盘到内存 al = 需要读取的扇区数
#ch = 柱面号    cl = 开始扇区
#dh = 磁头号    dl = 驱动器号
#es:bx 指向数据缓冲区 如果出错，CF 置位,ah是出错码
load_setup:
    call    clear
   # call    clear
    xor     %dx,%dx
    mov     $0x0002,%cx
    mov     $0x0200,%bx
    mov     $0x0200 + SETUPLEN,%ax
    int     $0x13
    jnc     ok_load_setup

#读取出错
    push    %ax
    call    print_nl
    mov     %sp,%bp
    call    print_hex
    pop     %ax

#重试
    xor     %dl,%dl
    xor     %ah,%ah
    int     $0x13
    jmp     load_setup

ok_load_setup:
    xor     %dl,%dl
    mov     $0x08,%ah
    int     $0x13
    xor     %ch,%ch
    mov     %cx,sectors
    mov     $INITSEG,%ax #恢复es 
    mov     %ax,%es

#    mov     $0x03,%ah
#    xor     %bh,%bh
#    int     $0x10
    mov     $0x1010,%dx  
    mov     $7,%cx
    mov     $0x0007,%bx
    mov     $0x1301,%ax
    mov     $LOAD_MESSAGE,%bp
    int     $0x10

load_system:
    mov     $SYSSEG,%ax
    mov     %ax,%es
     
    call    read_it
    call    kill_motor
    call    print_nl

    mov     root_dev,%ax
    or      %ax,%ax
    jne     root_defined
    mov     sectors,%bx
    mov     $0x0208,%ax
    cmp     $15,%bx
    je      root_defined
    mov     $0x021c,%ax
    cmp     $18,%bx
    je      root_defined
undef_root:
    jmp     undef_root
root_defined:
    mov     %ax,root_dev
    ljmp    $SETUPSEG,$0

read_it:
    mov     %es,%ax
    test    $0x0fff,%ax
die:
    jne     die
    xor     %bx,%bx
rp_read:
    mov     %es,%ax
    cmp     $ENDSEG,%ax
    jb      ok1_read
    ret
ok1_read:
    mov     sectors,%ax
    sub     sread,%ax
    mov     %ax,%cx
    shl     $9,%cx
    add     %bx,%cx
    jnc     ok2_read  #无进位时转移应该是上面的加法没有溢出跳转到ok2_read执行
    je      ok2_read  #若零标志位置位也跳转   理解 bx+cx <= 64K
#大于64k时执行
    xor     %ax,%ax
    sub     %bx,%ax
    shr     $9,%ax

ok2_read:
    call    read_track
    mov     %ax,%cx
    add     sread,%ax
    cmp     sectors,%ax
    jne     ok3_read    #若还有未读扇区，跳转到ok3_read
    mov     $1,%ax
    sub     head,%ax
    jne     ok4_read

    incw    track

ok4_read:
    mov     %ax,head
    xor     %ax,%ax
ok3_read:
    mov     %ax,sread
    shl     $9,%cx
    add     %cx,%bx
    jnc     rp_read

    mov     %es,%ax
    add     $0x10,%ah
    mov     %ax,%es
    xor     %bx,%bx
    jmp     rp_read

kill_motor:
    push    %dx
    mov     $0x3f2,%dx
    xor     %al,%al
    outSb
    pop     %dx
    ret
read_track:
    pusha
    #显示一个.########################
    pusha
    mov     $0xe2e,%ax
    mov     $7,%bx
    int     $0x10
    popa
    ##########################
    mov     track,%dx
    mov     sread,%cx
    inc     %cx
    mov     %dl,%ch
    mov     $head,%dx
    mov     %dl,%dh
    and     $0x0100,%dx
    mov     $2,%ah
    push    %dx
    push    %cx
    push    %bx
    push    %ax
    int     $0x13
    jc      bad_rt
    add     $8,%sp
    popa
    ret
bad_rt:
    push    %ax
    call    print_all

    xor     %ah,%ah
    xor     %dl,%dl
    int     $0x13

    add     $10,%sp
    popa
    jmp     read_track

print_all:
    mov     $5,%cx
    mov     %sp,%bp
print_loop:
    push    %cx
    call    print_nl
    jae     no_reg


    mov     $0xe05+0x41-1,%ax
    sub     %cl,%al
    int     $0x10

    mov     $0x3a,%al
    int     $0x10

no_reg:
    add     $2,%bp
    call    print_hex
    pop     %cx
    loop    print_loop
    ret
#清屏
clear:
    mov     $0x0003,%ax
    int     $0x10
    ret
print_nl:
    mov     $0xe0d,%ax
    int     $0x10
    mov     $0xa,%al
    int     $0x10
    ret
#显示 SS：BP中的16进制数
print_hex:
    mov     $4,%cx
    mov     (%bp),%dx
print_digit:
    rol     $4,%dx
    mov     $0xe,%ah
    mov     %dl,%al
    and     $0xf,%al
    add     $0x30,%al
    cmp     $0x39,%al
    jbe     good_digit
    add     $0x41 - 0x30 -0xa,%al
good_digit:
    int     $0x10
    loop    print_digit
    ret
BootMessage: 
    .string "Hello,OS world!"
LOAD_MESSAGE:
    .string "Loading"
sectors:
    .word   0
head:
    .word   0
track:
    .word   0
sread:  
    .word  1+ SETUPLEN

    .org 508
root_dev:
    .word   ROOT_DEV
boot_flag:   
    .word   0xaa55 
    .end


