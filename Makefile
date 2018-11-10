obj-m := tcp_bbr_plus.o

all:
	make -C /lib/modules/`uname -r`/build M=`pwd` modules CC=/usr/bin/gcc-6

clean:
	make -C /lib/modules/`uname -r`/build M=`pwd` clean

install:
	install tcp_bbr_plus.ko /lib/modules/`uname -r`/kernel/net/ipv4
	insmod /lib/modules/`uname -r`/kernel/net/ipv4/tcp_bbr_plus.ko
	depmod -a

uninstall:
	rm /lib/modules/`uname -r`/kernel/net/ipv4/tcp_bbr_plus.ko
