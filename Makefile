BOOT = ./boot
MAKE = make

all:boot A.img
	tools/a.out
	dd if=sysimg of=A.img bs=512 count=2 conv=notrunc
boot:
	cd $(BOOT) && $(MAKE)

clean:
	cd $(BOOT) && $(MAKE) clean
