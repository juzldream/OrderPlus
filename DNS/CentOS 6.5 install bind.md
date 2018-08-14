*注释：*

&nbsp;&nbsp;&nbsp;&nbsp;`yum list all`        #查找yum源有哪些安装包

&nbsp;&nbsp;&nbsp;&nbsp;`yum list all | grep "^bind"`

&nbsp;&nbsp;&nbsp;&nbsp;`yum info bind-devel.x86_64 ` #查找对应安装包相关信息

&nbsp;&nbsp;&nbsp;&nbsp;`rpm -qi lrzsz `#查找`lrzsz`相关信息
    
---

1. `yum` 安装

    `yum install bind`

2. 配置文件说明
    ```
    [root@testplus ~]# rpm -ql bind
    /etc/named
    /etc/named.conf               #主配置文件
    /etc/rc.d/init.d/named        #脚本
    /etc/rndc.key                 #key
    /etc/sysconfig/named          #服务脚本配置文件
    /usr/sbin/named               #主程序
    /usr/sbin/named-checkconf     #检查配置文件
    /usr/sbin/named-checkzone     #检查区域配置文件
    /usr/sbin/rndc                #远程控制工具
    /usr/sbin/rndc-confgen        #生成/etc/rndc.conf配置文件
    /var/named                    #区域配置文件
    /var/named/data
    /var/named/dynamic
    /var/named/named.ca           #13个root域名
    /var/named/named.empty
    /var/named/named.localhost    #将localhost解析为127.0.0.1
    /var/named/named.loopback     #本地服务器正反向解析
    ```

3. 配置文件详细配置

    - /etc/【name.cond】
        
        ```
        [root@testplus etc]# ll named.conf -d
        -rw-r----- 1 root named 1008 Jul 19  2010 named.conf
        ```
        ```
        options {
        directory       "/var/named";
        };
        
        zone “ZOME NAME” IN {
                type {master|slave|hint|forward};
                file "区域数据文件"；
        };
        ```
        ```
        named-checkconf 
        named-checkzone 
        named-checkzone "." /var/named/named.ca 
        named-checkzone "localhost" /var/named/named.localhost 
        named-checkzone "0.0.127.in-addr-arpa" /var/named/named.localhost 
        ```
        `netstat -anp | grep 53`
        ```
        zone "0.0.127.in-addr.arpa" IN {
        type master;
        file "named.loopback";
        };
        
        zone "juzldream.com" IN {
                type master;
                file "juzldream.com";
        };
        
        zone "5.168.192-in-addr.arpa" IN {
                type master;
                file "192.168.5.zone";
        };
        ```
    - /var/name/【juzldream.com】
       
        ```
       
        $TTL 600
        juzldream.com.    IN  SOA  ns1.juzldream.com. addmin.juzldream.com. (
                                                        20180812
                                                        1H
                                                        5M
                                                        2D
                                                        6H)
                          IN  NS   ns1
                          IN  MX 10 mail
        ns1               IN  A     192.168.5.131
        mail              IN  A     192.168.5.132
        www               IN  A     192.168.5.131
        www               IN  A     192.168.5.133
        ftp               IN  CNAME www
        pc1               IN  A     192.168.5.111
        pc2               IN  A     192.168.5.112
        pc3               IN  A     192.168.5.113
        pc4               IN  A     192.168.5.114
        pc5               IN  A     192.168.5.115

    
        ```
    - /var/name/192.168.5.zone 【反向域配置】
    
        ```
        $TTL 600
        @    IN  SOA  ns1.juzldream.com. addmin.juzldream.com. (
                                                        20180812
                                                        1H
                                                        5M
                                                        2D
                                                        6H)
        @                 IN  NS   ns1.juzldream.com.
        1                 IN  PTR  ns1.juzldream.com.
        1                 IN  PTR  www.juzldream.com.
        2                 IN  PTR  mail.juzldream.com.
        3                 IN  PTR  www.juzldream.com.
        111               IN  PTR  pc1.juzldream.com.
        112               IN  PTR  pc2.juzldream.com.
        113               IN  PTR  pc3.juzldream.com.
        114               IN  PTR  pc4.juzldream.com.
        115               IN  PTR  pc5.juzldream.com.

        ```
        
4. 工具介绍
    
    - dig 【Domain  Information Groper ： 域名信息搜索器】
    
    &nbsp;&nbsp;-t  资源类型

    &nbsp;&nbsp;-x 反向查找
    
    ```
    dig -t NS .    #查询所有root域地址
    dig -t NS . @A.ROOT-SERVERS.NET.    #通过这A.ROOT-SERVERS.NET.台服务器查询所有root域地址
    

	dig -t {NS|SOA|A|MX} 
	dig -t NS juzldream.com
	dig -t MX juzldream.com
	dig -t A www.juzldream.com
	dig -t CNAME ftp.juzldream.com
	dig -t SOA juzldream.com

    ```
    
    - host
    
    ```
    host -t a www.juzldream.com
 	host -t ns juzldream.com
  	host -t NS juzldream.com
  	host -t MX juzldream.com
	host -t SOA juzldream.com
	```
	
    - nolookup
    
    &nbsp;&nbsp;![](https://mmbiz.qpic.cn/mmbiz_png/4iaE7bB4HCjdTTwLET1ualicxtc2lFCVJjtbfd84JeLWFse5nyibE7nianiaSAdY4NtryKMvT2HFyLYKLZsRicQ3SAyA/0?wx_fmt=png)

5. 附加说明

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DNS 监听端口 : TCP/54、UPD/53

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;套接字：IP：PORT

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;DNS主服务日志：
/var/log/messages