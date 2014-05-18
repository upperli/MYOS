all:boot.bin
boot.o:boot.s
	as -o boot.o boot.s 
boot.bin:boot.o
	ld --oformat binary -o boot.bin boot.o -Ttext 0x0000 

clean:
	rm boot.o boot.bin
