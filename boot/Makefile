all:boot.bin setup.bin
boot.o:boot.s
	as -o boot.o boot.s 
setup.o:setup.s
	as -o setup.o setup.s 
boot.bin:boot.o
	ld --oformat binary -o boot.bin boot.o -Ttext 0x0000 
setup.bin:setup.o
	ld --oformat binary -o setup.bin setup.o -Ttext 0x0000 

clean:
	rm boot.o boot.bin
