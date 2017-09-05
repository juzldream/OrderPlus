#!/bin/bash
#program:This is a about delete it is loetup creat img file .
#date:2017-02-11
#author:racher
#email:1576768715@qq.com


# type menu option.

function menu(){
        cat <<END
1.[Please Input create img filenum]
2.[Please Input mount dir site]
END
}


# funtion module.

function createfile(){
	for((i=0;i<$1;i++));
	do
        	cd /home
        	dd if=/dev/zero of=disk$i.img bs=10M count=10 2>err.txt
       		losetup /dev/loop0 disk$i.img 2>>err.txt 1>/dev/null
        	mkfs.ext3 /dev/loop$i 2>>err.txt 1>/dev/null
        	if [ -d /test$i/ ];
       		then
                	echo "cannot create directory 'test$i': File exists." >>err.txt
        	else
                	mkdir /test$i/
                	mount -t ext4 /dev/loop$i /test$i/
        	fi
	done
}
#echo -e "\033[37;31;5mWait for a moment. ...\033[39;49;0m"
read -p "Please enter the number of directories created. :" num 
#echo "you selected $num $dir"
createfile $num
