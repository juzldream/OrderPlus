#!/bin/bash
#program:This is a about delete it is loetup creat img file .
#date:2017-02-11
#author:racher
#email:1576768715@qq.com

for((i=0;i<2;i++));
do
	umount /test$i/
	losetup -d /dev/loop$i
	rm -rf disk$i.img /test$i/ err.txt
done
