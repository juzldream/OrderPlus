1.关闭防火墙 和 SELINUX
	service iptables stop
	setenforce 0
2.安装samba服务器
	yum -y install samba samba-common samba-client  
3.配置smb.conf 文件
mv /etc/samba/smb.conf /etc/samba/smb.conf.bak
cat /etc/samba/smb.conf.bak | grep -v "#" | grep -v ";" | grep -v "^$" > /etc/samba/smb.confs
[scripts]

        comment = user public directory
        path=/scripts
        browseable = yes
        writable = yes
        public= yes
        valid users = jhadmin
        create mask = 0644
        force create mode = 0644
        directory mask = 0755
        force directory mode = 0755
        write list=smbgrp

4.创建samba用户
groupadd smbgrp
useradd -g smbgrp jhadmin
pdbedit -a -u jhadmin

smbclient -L //192.168.1.24 -U jhadmin
5.启动smb服务
service smb restart
chkconfig smb on
6.wdindos 端连接

