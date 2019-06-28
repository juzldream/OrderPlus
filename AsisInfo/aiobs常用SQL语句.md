1. 根据用户账号查询话单

	`select * from usage_bppp_20170401 t where t.user_name='13659506831';`
2. 根据用户MAC查询话单

	`select * from usage_bppp_20170501 t where t.caller_id='74:1f:4a:69:ad:65';`

3. 查看每个带宽对应的用户数

    ```
    SELECT
    	b.bms_svcfeature_value,
    	count(a.bms_user_name)
    FROM
    	bms_subscription_bppp a,
    	bms_subs_prodfea b
    WHERE
    	a.bms_product_id IN ('90007017', '90007024')
    AND a.bms_svc_type = '801'
    AND a.bms_subscription_status NOT IN ('2', '8')
    AND a.bms_subscription_end_time > sysdate
    AND a.bms_subscription_id = b.bms_subscription_id
    AND b.bms_svcfeature_name = 'ai-output-rate'
    GROUP BY
    	b.bms_svcfeature_value;
    ```
4. 清理表

    ```
    truncate table access_log_2019020100;
    truncate table access_log_2019020101;
    truncate table access_log_2019020102;
    truncate table access_log_2019020103;
    truncate table access_log_2019020104;
    truncate table access_log_2019020105;
    truncate table access_log_2019020106;
    truncate table access_log_2019020107;
    truncate table access_log_2019020108;
    truncate table access_log_2019020109;
    ```
4. 查看数据库表空间占用量:超过90%不正常，告知黄小涛

    ```
    SELECT
    	a.tablespace_name,
    	total,
    	total - free used,
    	trunc ((total - free) / total * 100, 2) || '%' useper
    FROM
    	(
    		SELECT
    			tablespace_name,
    			trunc (sum(bytes) / 1024 / 1024, 2) total
    		FROM
    			dba_data_files
    		GROUP BY
    			tablespace_name
    	) a,
    	(
    		SELECT
    			tablespace_name,
    			trunc (sum(bytes) / 1024 / 1024, 2) free
    		FROM
    			dba_free_space
    		GROUP BY
    			tablespace_name
    	) b
    WHERE
    	a.tablespace_name = b.tablespace_name;
    ```
5. 带宽用户

    ```
    SELECT
    	count(*)
    FROM
    	bms_subscription_bppp
    WHERE
    	bms_svc_type = '801'
    AND bms_subscription_end_time > sysdate
    AND bms_product_id = '90007017'
    OR bms_product_id = '90007024';
    
    -----WLAN用户
    SELECT
    	count(*)
    FROM
    	bms_subscription_bppp
    WHERE
    	bms_product_id IN (
    		'90007018',
    		'90007019',
    		'90007020',
    		'90007021',
    		'90007022',
    		'90007023'
    	)
    AND bms_subscription_end_time > sysdate
    AND bms_user_name NOT LIKE '%tmp%';
    ```
6. 一个宽带账号存在多个VLAN信息的用户

    ```
    SELECT
    	b.bms_node_name,
    	a.user_name,
    	count(DISTINCT a.roam_domain)
    FROM
    	usage_bppp_20170601 a,
    	bms_node b
    WHERE
    	bms_product_id IN ('90007017', '90007024')
    AND a.bms_node_id = b.bms_node_id
    GROUP BY
    	b.bms_node_name,
    	a.user_name
    HAVING
    	count(DISTINCT a.roam_domain) > 1;
    ```
7. 查询用户宽带账号密码
    ```
    SELECT
    	bms_user_password
    FROM
    	bms_subscription_bppp
    WHERE
    	bms_user_name = '18289078400';
    ```

    ```
    [aiobs@CMNET-AIOBS2 ~]$ cd wxj/
    [aiobs@CMNET-AIOBS2 ~/wxj]$ ls crypt.sh 
    crypt.sh
    [aiobs@CMNET-AIOBS2 ~/wxj]$ ./crypt.sh de 87e8b3c085eedce7
    oldpasswd=87e8b3c085eedce7
    newpasswd=147258
    ```
8. 查找现网IPv6用户数

    ```
    SELECT
    	count(DISTINCT user_name)
    FROM
    	usage_bppp_20190401 t
    WHERE
    	(
    		t.framed_v6_prefix IS NOT NULL
    	)
    OR (
    	t.delegated_v6_prefix IS NOT NULL
    );
    ```
9. 本月登录用户数

    ```
    SELECT DISTINCT
    	user_name
    FROM
    	usage_bppp_20181101
    WHERE
    	bms_product_id IN ('90007017', '90007024')
    ```
    
10. 查找每个用户本月使用流量

    ```
    SELECT
    	user_name,
    	sum(
    		output_octets / 1024 / 1024 / 1024
    	)
    FROM
    	usage_bppp_20181101
    WHERE
    	bms_node_id = 894
    GROUP BY
    	user_name
    ```
11. 查询IPv6用户流量使用

    ```
    SELECT
    	sum(
    		output_octets_v6 / 1024 / 1024 / 1024
    	)
    FROM
    	usage_bppp_20190101
    ```
12. 各地市IPv6、家宽用户数

    ```
    /*  各地市家宽用户数 */
	SELECT
		decode (
			bms_node_id,
			891,
			'拉萨',
			892,
			'日客则',
			893,
			'山南',
			894,
			'林芝',
			895,
			'昌都',
			896,
			'那曲',
			897,
			'阿里'
		) AS 地市,
		count(*) AS 数量
	FROM
		bms_subscription_bppp
	WHERE
		bms_svc_type = '801'
	AND bms_subscription_end_time > sysdate
	AND bms_product_id = '90007017'
	OR bms_product_id = '90007024'
	GROUP BY
		bms_node_id ;
	
	/* 各地市IPv6用户数 */
	SELECT
		decode (
			bms_node_id,
			891,
			'拉萨',
			892,
			'日客则',
			893,
			'山南',
			894,
			'林芝',
			895,
			'昌都',
			896,
			'那曲',
			897,
			'阿里'
		) AS 地市,
		count(DISTINCT user_name) AS 用户数
	FROM
		usage_bppp_20181101 t
	WHERE
		(
			(
				t.framed_v6_prefix IS NOT NULL
			)
			OR (
				t.delegated_v6_prefix IS NOT NULL
			)
		)
	GROUP BY
		bms_node_id;
	```
13. 各地市用户带宽及CIT信息
    ```
    select distinct a.bms_user_name as 账号,
                    a.bms_node_id as 地市,
                    c.roam_domain as CIT,
                    b.bms_svcfeature_value as 带宽
      from bms_subscription_bppp a, bms_subs_prodfea b, usage_bppp_20190201 c
     where a.bms_user_name = c.user_name
       and a.bms_subscription_id = b.bms_subscription_id
       and b.bms_svcfeature_value not in ('0000', '0.0.0.0', '0');

    ```
    
15. 各地市活跃家宽用户数

    ```
	  select decode(bms_node_id,
			891,
			'拉萨',
			892,
			'日客则',
			893,
			'山南',
			894,
			'林芝',
			895,
			'昌都',
			896,
			'那曲',
			897,
			'阿里') AS 地市,
		 count(DISTINCT(user_name)) AS 数量
	    from usage_bppp_20190301
	   WHERE bms_product_id IN ('90007017', '90007024')
	   GROUP BY bms_node_id;

    ```
13. 各地市宽带总流量（TB)

    ```
      select decode(bms_node_id,
                  891,
                  '拉萨',
                  892,
                  '日客则',
                  893,
                  '山南',
                  894,
                  '林芝',
                  895,
                  '昌都',
                  896,
                  '那曲',
                  897,
                  '阿里') AS 地市,
           sum(input_octets + output_octets) / 1024 / 1024 / 1024 / 1024 as 总流量
      from usage_bppp_20190301
     where bms_product_id in ('90007017', '90007024')
     GROUP BY bms_node_id;
    ```
14. 曹建

    `select distinct(user_name),NAS_IP,ROAM_DOMAIN from usage_bppp_20190501;`
    
15. 家宽账号对应带宽

    ```
    SELECT DISTINCT
	(c.user_name),
	a.bms_svcfeature_value
    FROM
    	bms_subs_prodfea a,
    	bms_subscription_bppp b,
    	usage_bppp_20190601 c
    WHERE
    	b.bms_product_id IN ('90007017', '90007024')
    AND bms_svcfeature_name = 'ai-output-rate'
    AND a.bms_subscription_id = b.bms_subscription_id
    AND b.bms_svc_type = '801'
    AND b.bms_subscription_status NOT IN ('2', '8','1')  /* 0 :正常 1：加锁
    AND b.bms_subscription_end_time > sysdate
    AND b.bms_user_name = c.user_name;
    ```
    
19. 用户解绑


    ```
    --根据BRAS_IP解绑
    SELECT DISTINCT
    	bms_user_name || '|0.0.0.0|0000|0000'
    FROM
    	bms_subscription_bppp a
    WHERE
    	EXISTS (
    		SELECT
    			*
    		FROM
    			bms_subs_prodfea b
    		WHERE
    			a.bms_subscription_id = b.bms_subscription_id
    		AND b.bms_svcfeature_name = 'NAS-IP-Address'
    		AND b.bms_svcfeature_value = '219.151.32.246'
    	)
    AND a.bms_subscription_status NOT IN (2, 8)
    AND a.bms_subscription_end_time > sysdate
    
    --根据BRAS_ip+vlan进行解绑
    SELECT DISTINCT
    	bms_user_name || '|0.0.0.0|0000|0000'
    FROM
    	bms_subscription_bppp a
    WHERE
    	EXISTS (
    		SELECT
    			*
    		FROM
    			bms_subs_prodfea b
    		WHERE
    			a.bms_subscription_id = b.bms_subscription_id
    		AND b.bms_svcfeature_name = 'NAS-IP-Address'
    		AND b.bms_svcfeature_value = '219.151.32.246'
    	)
    AND a.bms_subscription_status NOT IN (2, 8)
    AND a.bms_subscription_end_time > sysdate
    AND EXISTS (
    	SELECT
    		*
    	FROM
    		bms_subs_prodfea b
    	WHERE
    		a.bms_subscription_id = b.bms_subscription_id
    	AND b.bms_svcfeature_name = 'ai-vlan-id'
    	AND (
    		b.bms_svcfeature_value LIKE '%2676%'
    		OR b.bms_svcfeature_value LIKE '%2677%'
    		OR b.bms_svcfeature_value LIKE '%2686%'
    		OR b.bms_svcfeature_value LIKE '%2687%'
    		OR b.bms_svcfeature_value LIKE '%2319%'
    		OR b.bms_svcfeature_value LIKE '%2320%'
    		OR b.bms_svcfeature_value LIKE '%2321%'
    		OR b.bms_svcfeature_value LIKE '%2322%'
    		OR b.bms_svcfeature_value LIKE '%2323%'
    		OR b.bms_svcfeature_value LIKE '%2354%'
    		OR b.bms_svcfeature_value LIKE '%2355%'
    		OR b.bms_svcfeature_value LIKE '%2356%'
    		OR b.bms_svcfeature_value LIKE '%2357%'
    		OR b.bms_svcfeature_value LIKE '%2358%'
    		OR b.bms_svcfeature_value LIKE '%2359%'
    		OR b.bms_svcfeature_value LIKE '%2360%'
    		OR b.bms_svcfeature_value LIKE '%2361%'
    		OR b.bms_svcfeature_value LIKE '%2362%'
    		OR b.bms_svcfeature_value LIKE '%2363%'
    		OR b.bms_svcfeature_value LIKE '%2364%'
    		OR b.bms_svcfeature_value LIKE '%2365%'
    		OR b.bms_svcfeature_value LIKE '%2370%'
    		OR b.bms_svcfeature_value LIKE '%2373%'
    		OR b.bms_svcfeature_value LIKE '%2374%'
    		OR b.bms_svcfeature_value LIKE '%2385%'
    		OR b.bms_svcfeature_value LIKE '%2386%'
    		OR b.bms_svcfeature_value LIKE '%2393%'
    		OR b.bms_svcfeature_value LIKE '%2820%'
    		OR b.bms_svcfeature_value LIKE '%2264%'
    		OR b.bms_svcfeature_value LIKE '%2284%'
    		OR b.bms_svcfeature_value LIKE '%2285%'
    		OR b.bms_svcfeature_value LIKE '%2315%'
    		OR b.bms_svcfeature_value LIKE '%2337%'
    		OR b.bms_svcfeature_value LIKE '%2338%'
    		OR b.bms_svcfeature_value LIKE '%2366%'
    		OR b.bms_svcfeature_value LIKE '%2419%'
    		OR b.bms_svcfeature_value LIKE '%2455%'
    		OR b.bms_svcfeature_value LIKE '%2456%'
    		OR b.bms_svcfeature_value LIKE '%2457%'
    		OR b.bms_svcfeature_value LIKE '%2458%'
    		OR b.bms_svcfeature_value LIKE '%2459%'
    		OR b.bms_svcfeature_value LIKE '%2701%'
    		OR b.bms_svcfeature_value LIKE '%2607%'
    		OR b.bms_svcfeature_value LIKE '%2608%'
    		OR b.bms_svcfeature_value LIKE '%2609%'
    		OR b.bms_svcfeature_value LIKE '%2610%'
    	)
    );
    ```
