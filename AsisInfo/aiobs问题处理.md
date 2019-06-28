1. 登录

    ```
    http://111.11.252.233:10003/cgi/opr_login_java.ktcl
    aiobs6super/xtadmin
    
    后台服务：111.11.252.233
    
    log 位置： /data/aiobs/boss/log/bms
    grep 18408968333 log2018*
    grep 158950857 log20180801
    
    telnet localhost 10002
    ps -ef|grep bms12 
    ```

2. lm 重启，批量剔除用户 清理session
    
    ```
    111.11.192.12（radius2）
    ps -ef | grep lm
    pwd aiobs61
    kill -9 4126
    cd /data/aiobs61/ailm/lm
    ./ailm -xxxx -d
    ```
3. 根据BARS踢用户

    ```
    12 服务器
    /data/aiobs61/ailm/adminexpert
    radius2[aiobs61:/data/aiobs61/ailm/adminexpert]./lmadmin 
    0 - print version
    1 - query
    2 - kick user offline
    3 - statistic information
    4 - change user name
    9 - quit
    
    your choice: 2
    
            1 - kick login of user by USER_ID and NAS_IP and NAS_PORT
            2 - kick login of user by USER_ID
            3 - kick users by NAS_IP
            4 - kick users for timeout
            5 - kick login of user by USER_ID and NASPORT_TYPE and AUTHEN_TYPE
            9 - back
    
            your choice: 3
            NAS_IP to kick: 
    nasIP查询：
    cat /data/aiobs61/radius/radius.ini
    NAS404=RiKaZe_HuaWei,111.11.253.118-119,HuaWeiME60_BIND;
    ```
3. 拓扑图

    ![aiobs](https://mmbiz.qpic.cn/mmbiz_png/4iaE7bB4HCjeIHknHGgROBqDGGvW87lbwJYaEftibKd1eUicXpPum6Zn0yeY37V6C0wib9bvGnFpVTzd3ctOo0VslA/0?wx_fmt=png)

4. 磁盘空间定时清理

    ![服务器列表](https://mmbiz.qpic.cn/mmbiz_png/4iaE7bB4HCjeIHknHGgROBqDGGvW87lbwVKzGG7xPicMtZzBo48Krjhdq8FlL742Koic6T67RO26gYbRrljAd8B8Q/0?wx_fmt=png)
    
5. DNS服务器

    ![dns服务器](https://mmbiz.qpic.cn/mmbiz_png/4iaE7bB4HCjeIHknHGgROBqDGGvW87lbw7DK3t5WLWIuv6lxOQH7cYoaHhibUd5tbtbk4gKBEBticWXY8LoeqRBmQ/0?wx_fmt=png)
    
7. 防火墙设置

    ```
    iptables -I INPUT -s 123.138.233.91 -p tcp --dport 8880 -j ACCEPT 
    iptables -I INPUT -s 113.200.0.0/16 -p tcp --dport 22 -j ACCEPT 
    iptables -A INPUT -s 0.0.0.0/0 -p tcp --dport 22 -j REJECT
    
    iptables -L -n --line-number    #显示防火墙策略编号
    iptables -D INPUT 2             #删除第2条策略
    
    /etc/rc.d/init.d/iptables save
    
    service iptables restart
    
    iptables -nL
    iptables -F
    ```
8. 某个时间段活跃用户数

    ```
    /data/nlkfpt/onlinefile
    111.11.192.9
    [root@Portal onlinefile]# cat radius_unseronline_201902132215.csv | wc -l
    ```