all:boot.bin
boot.o:
	as -o boot.o boot.s
boot.bin:boot.o
	ld --oformat binary -o boot.bin boot.o -Ttext 0x7c00

clean:
	rm boot.o boot.bin
