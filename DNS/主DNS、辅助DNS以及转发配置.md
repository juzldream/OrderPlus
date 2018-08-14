**规划：**

- 域名：juzldream.com（192.168.5.128）
- 客户端：PC1\~PC5（192.168.5.131~192.168.5.131）

1. 主DNS服务配置
-
    ```
    options {
    	directory "var/named";
    }；
    
    zone "." {
    	type hint;
    	file "named.ca";
    };
    
    zone "juzldream.com" {
    	type master;
    	file:"juzldream.com.zone" ;
    };
    
    zone "5.168.192.in-addr.arpa" {
    	type master;
    	file:"192.168.5.zone" ;
    };
    ```
2. 辅助服务器 named. conf 文件配置

    ```
    options {
    	directory "var/named";
    	allow-transfer {192.168.5.166;};
    }；
    
    zone "juzldream.com" {
    	type slave;
    	file:"slaves/juzldream.com.zone" ;
    	masters {192.168.5.128;}
    };
    
    
    zone "5.168.192.in-addr.arpa" {
    	type slave;
    	file:"slaves/192.168.5.zone" ;
    	masters {192.168.5.128;}
    };
    ```
3. 转发服务器 named. conf 文件配置

    ```
    options {
    	directory "var/named";
    	forwarders {
    		22.20.78.3;
    		28.70.34.21;
    	};
    	forward only;
    }；
    ```
4. 递归服务器 named.conf 文件配置

    ```
    options {
    	dirctory "/var/named";
    	recursion yes;         #定义递归功能
    	allow-recursion  {172.10.0.0/16;}；#定义给172.10.0.0网段递归
    };
    ```