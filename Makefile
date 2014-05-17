BOOT = ./boot
MAKE = make

all:A.img
	dd if=boot/boot.bin of=A.img bs=512 count=1 conv=notrunc

boot:
	cd $(BOOT) && $(MAKE)
