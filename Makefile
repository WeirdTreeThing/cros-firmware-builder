.PHONY: all build-docker build-qemu-img emu

all: build-docker build-qemu-img emu

build-docker:
	docker build -t corerom:latest docker

build-qemu-img:
	docker run -v ${PWD}:${PWD} -w ${PWD} --rm -it corerom:latest ./builder.sh qemu

emu:
	qemu-system-x86_64 -enable-kvm -M q35 -m 2G -serial stdio -vga std -cpu host -smp 2 -bios build/qemu/qemu.rom
