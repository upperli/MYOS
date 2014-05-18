BOOT = ./boot
MAKE = make

all:boot A.img
	dd if=boot/boot.bin of=A.img bs=512 count=1 conv=notrunc

boot:
	cd $(BOOT) && $(MAKE)

clean:
	cd $(BOOT) && $(MAKE) clean
