#!/usr/bin/python
# -*- coding: UTF-8 -*-
#Date:23-08-2017
#Author:rzh
#Version=.1

import os
import time
import requests
import json
import psycopg2
import xlrd
import xlwt
import smtplib
from email.mime.text import MIMEText
from email.header import Header
import sys  
reload(sys)  
sys.setdefaultencoding('utf8') 



class Tools():
    '''
    工具类函数。
    '''
    
    def __init__(self):
        '''
        初始化访问地址。
        '''

    def access_web(self,url):
        '''
        模仿浏览器访问url，返回json数据。
        '''
        req = requests.get(url=url)
        s = req.json() 
        return s      


    def readdata(slef,start,finish):
        '''
        读取 resapi test plan 数据,按照每行进行读取，返回测试数据列表。
        start : 从start行开始读取数据
        finish :读取到finish-1 行结束
        '''
        wordbook = xlrd.open_workbook('test.xlsx')
        # return wordbook.sheet_names()
        data_sheet = wordbook.sheets()[1]
        row_list = []
        for i in range(start,finish):
            row_list.append(data_sheet.row_values(i))
        return row_list


    def putlog(self,level,info):
        '''
        打印log到控制台和文件。
        '''
        
        f = open("resapi.log","a")

        times = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
        title = "[" + times + "] " + "[resapi test] "
        dict_level = {1:"INFO :",2:"ERROR :"}
        level = dict_level[level]
        info  = info
        content = title + level + info + "\n"

        f.write(content)

        f.close()
        return content


    def sendmail(self,Subject,title,connect):
            from_addr = "rzhou@jhinno.com"
            password  = "Juzl150702"
            to_addr   = "1576768715@qq.com"
            to_addr1   = "rzhou@jhinno.com"
            to_addr2   = "bzhang1@jhinno.com"


            title = title
            content = connect
            subject = Subject
            mail_msg = """
            <table border="1">
                <tr>
                    <th>测试环境</th>
                    <td>""" + title + """</td>
                </tr>
                <tr>
                    <th>问题</th>
                    <td>""" + content + """</td>
                </tr>
            </table>
            """

            msg = MIMEText(mail_msg,'html','utf-8')
            msg["Subject"] = subject
            msg["From"]    = from_addr
            msg["To"]      = to_addr

            try:
                s = smtplib.SMTP_SSL("smtp.jhinno.com", 465)
                s.login(from_addr, password)
                s.sendmail(from_addr,[to_addr,to_addr1,to_addr2], msg.as_string())
                s.quit()
                return "Success!"
            except smtplib.SMTPException:
                return "Error :无法发送邮件"


    def login(self,username,password,url,expect):
        '''
        resapi 登录。
        '''
        url = url + "login?username=" + username + "&password=" + password
        s = Tools().access_web(url)
        if expect == "真":
            if s['result'] == "success":
                log = url + " appform 登录成功. \n\n成功获取token值为: " + str(s["data"][0]["token"]) + "\n"
                Tools().putlog(1,log)
                log = "[用户登录 CASE-EXPECT-TRUE] 测试: PASS。" + "\n"
                Tools().putlog(1,log)
                return s["data"][0]["token"]
            else:
                log = url + " appform login failed. \n" + str(s["message"]) + "\n"
                Tools().putlog(2,log)
                log = "[用户登录 CASE-EXPECT-TRUE] 测试: FAILURE。" + "\n"
                Tools().putlog(2,log)
                Tools().sendmail("【resapi】login 失败","appform 4.0" ,"给了一个错误的json串")
                return s['message']
        else:
            if s['result'] == "success":
                log = "[用户登录 CASE-EXPECT-FALSE] 测试: Failure。" + "\n"
                Tools().putlog(2,log)
                Tools().sendmail("【resapi】login 失败","appform 4.0" ,"给了一个错误的json串")
            else:
                log = url + " appform login failed." + s["message"] + "\n"
                Tools().putlog(1,log)
                log = "[用户登录 CASE-EXPECT-FALSE] 测试: PASS。" + "\n"
                Tools().putlog(1,log)
                return s['message']


    def logout(self,url,token):
        '''
        注销resapi账户。
        '''
        lourl = url + "logout?token=" + token 
        # s = Tools().access_web(lourl)
        return lourl



    

     

    def operatedb(self,sql):
        '''
        链接数据库，返回需要的数据。
        '''
        # sql = ("INSERT INTO bugs (assigned_to,bug_file_loc,bug_severity,bug_status,creation_ts,delta_ts,short_desc,op_sys,priority,product_id,rep_platform,reporter,VERSION,component_id,resolution,target_milestone,qa_contact,status_whiteboard,lastdiffed,everconfirmed,reporter_accessible,cclist_accessible,estimated_time,remaining_time,deadline,ALIAS) VALUES ('14','','normal','IN_PROGRESS','2017-05-16 17:29:00','2017-08-14 13:36:52','【resapi】resapi userreconfig 功能有问题。','Linux','Normal','12','All','90','4.0','21','','---','4','','2017-08-14 13:36:53','1','1','1','0.00','0.00',NULL,NULL);")

        conn = psycopg2.connect(database="bugs",user="postgres",password="postgres",host="192.168.0.100",port="5432")
        cur = conn.cursor()
        cur.execute(sql)
        conn.commit()
        # rows = cur.fetchall()
        # return rows
        cur.close()
        conn.close()

    
    def submitbug(self):
        '''
        向bugzilla提交bug。
        '''