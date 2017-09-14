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
from xml.etree.ElementTree import ElementTree,Element  
import xml.dom.minidom
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
        try:
            req = requests.get(url=url)
            s = req.json() 
            return s      
        except requests.exceptions.ConnectTimeout:
            return "appform 请求超时！"
        except requests.exceptions.InvalidSchema:
            return "没有找到连接适配器！"
        except requests.exceptions.ConnectionError:
            return "appform 连接不上！"
        except :
                return "unkown error."


    def readtestdata(self,case_file):
        '''
        读取json数据，用于api测试。
        '''
        try:
            f = open(case_file)
            s = json.load(f) 
        except ValueError:
            return "给定的 json 数据格式有误！"
        except IOError:
            return "没有找到文件或文件读取失败！"
        else:
            return s


    def readxmldata(self):
        '''
        读取xml数据，用于发送邮件。
        '''
        try:
            dom = xml.dom.minidom.parse("output.xml")
            root = dom.documentElement
            resapi_nodes = root.getElementsByTagName('resapi')
            output_xml = []
            for node in resapi_nodes:
                no = node.getAttribute('no')
                name = node.getElementsByTagName('name')
                url = node.getElementsByTagName('url')
                title = node.getElementsByTagName('title')
                error = node.getElementsByTagName('error')
                output_xml += [no,name[0].childNodes[0].nodeValue,url[0].childNodes[0].nodeValue,title[0].childNodes[0].nodeValue,error[0].childNodes[0].nodeValue]
            return output_xml
        except IOError:
            return "没有找到文件或文件读取失败！"
        except :
            return "unkown error."


    def savetestdata(self,filename,no,apitext,url,title,error):
        try:
            tree = ElementTree()  
            tree.parse(filename)  

            root=tree.getroot()  

            element = Element('resapi',{'no':no}) 

            one = Element('name')  
            one.text = apitext.decode('utf-8')
            element.append(one)

            two = Element('url')
            two.text = url.decode('utf-8')
            element.append(two)

            three = Element('title')
            three.text = title.decode('utf-8')
            element.append(three)

            four = Element('error')
            four.text = error.decode('utf-8')
            element.append(four)

            root.append(element)  


            tree.write(filename,encoding='utf-8') 
            return ""
        except IOError:
            return "没有找到文件或文件读取失败！"
        except :
            return "unkown error."


    def putlog(self,level,info):
        '''
        打印log到控制台和文件。
        '''
        try:
            f = open("resapi.log","a")

            times = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
            title = "[" + times + "] " + "[resapi test] "
            dict_level = {1:"INFO : ",2:"ERROR : "}
            level = dict_level[level]
            info  = info
            content = title + level + info + "\n"

            f.write(content)
            return content
            f.close()
        except :
            return "unkown error."        

    def htmldispose(self,localtime):
        '''
        处理邮件数据信息。
        '''
        s = Tools().readxmldata()
        l = time.asctime( time.localtime(time.time()) )
        msg = '<table width="100%" border="0" cellspacing="0" cellpadding="0" align="center"><tr><td align="center"'\
        ' style="font-size:26px;font-weight:700;border-bottom:1px dashed #CCC;color:#255e95" height="60">rest api test report</td>'\
        '</tr><tr><td align="right" height="25">' + l + '</td></tr></table></br>'
        msg += '''
        <table width="100%" border="0" cellspacing="1" cellpadding="4" bgcolor="#cccccc" class="tabtop13" align="center">
          <tr>
            <th  width="20%" style="background:#e9faff !important;text-align:center;font-family: 微软雅黑;font-size: 16px;font-weight: bold;color: #255e95;background: url(../images/ico3.gif) no-repeat 15px center;background-color:#e9faff;">测试环境</th>
            <th  width="20%" style="background:#e9faff !important;text-align:center;font-family: 微软雅黑;font-size: 16px;font-weight: bold;color: #255e95;background: url(../images/ico3.gif) no-repeat 15px center;background-color:#e9faff;">总共耗时</th>
            <th  width="20%" style="background:#e9faff !important;text-align:center;font-family: 微软雅黑;font-size: 16px;font-weight: bold;color: #255e95;background: url(../images/ico3.gif) no-repeat 15px center;background-color:#e9faff;">测试case总数</th>
            <th  width="20%" style="background:#e9faff !important;text-align:center;font-family: 微软雅黑;font-size: 16px;font-weight: bold;color: #255e95;background: url(../images/ico3.gif) no-repeat 15px center;background-color:#e9faff;">成功</th>
            <th  width="20%" style="background:#e9faff !important;text-align:center;font-family: 微软雅黑;font-size: 16px;font-weight: bold;color: #255e95;background: url(../images/ico3.gif) no-repeat 15px center;background-color:#e9faff;">失败</th>
          </tr>
          <tr>
            <td style="background:#f3f3f3 !important;text-align:center">appform 3.2.2</td>
            <td style="background:#f3f3f3 !important;text-align:center">''' + str(localtime) + '''</td>
            <td style="background:#f3f3f3 !important;text-align:center">'''  + str(len(s)/5) + '''</td>
            <td style="background:#f3f3f3 !important;text-align:center">'''  + str(len(s)/5) + '''</td>
            <td style="background:#f3f3f3 !important;text-align:center">'''  + str(len(s)/5) + '''</td>
          </tr>
        '''

        for x in range(len(s)/5):
            msg+= '''
                <tr>
                    <th style="background:#e9faff !important;text-align:center;font-family: 微软雅黑;font-size: 16px;font-weight: bold;color: #255e95;background: url(../images/ico3.gif) no-repeat 15px center;background-color:#e9faff;">问题编号</th>
                    <td colspan="4" style="background:#f3f3f3 !important;">''' + s[5*x] + '''</td>
                </tr>
                  <tr>
                    <th style="background:#e9faff !important;text-align:center;font-family: 微软雅黑;font-size: 16px;font-weight: bold;color: #255e95;background: url(../images/ico3.gif) no-repeat 15px center;background-color:#e9faff;">测试api</th>
                    <td colspan="4" style="background:#f3f3f3 !important;">''' + s[5*x + 1] + '''</td>
                  </tr>
                  <tr>
                    <th style="background:#e9faff !important;text-align:center;font-family: 微软雅黑;font-size: 16px;font-weight: bold;color: #255e95;background: url(../images/ico3.gif) no-repeat 15px center;background-color:#e9faff;">api访问地址</th>
                    <td colspan="4" style="background:#f3f3f3 !important;">'''+ s[5*x + 2] +'''</td>
                  </tr>
                  <tr>
                    <th style="background:#e9faff !important;text-align:center;font-family: 微软雅黑;font-size: 16px;font-weight: bold;color: #255e95;background: url(../images/ico3.gif) no-repeat 15px center;background-color:#e9faff;">简单描述</th>
                    <td colspan="4" style="background:#f3f3f3 !important;">'''   + s[5*x + 3] + '''</td>
                  </tr>
                  <tr>
                    <th style="background:#e9faff !important;text-align:center;font-family: 微软雅黑;font-size: 16px;font-weight: bold;color: #255e95;background: url(../images/ico3.gif) no-repeat 15px center;background-color:#e9faff;">错误详细信息</th>
                    <td colspan="4" style="background:#f3f3f3 !important;">''' + s[5*x + 4] +'''</td>
                  </tr>

            '''
          
        msg += '</table>'
        return msg


    def sendmail(self,msg):
            from_addr = "rzhou@jhinno.com"
            password  = "Juzl150702"
            to_addr1   = "1576768715@qq.com"
            to_addr   = "rzhou@jhinno.com"
            # to_addr2   = "bzhang1@jhinno.com"


            # title = title
            # content = connect
            subject = 'resapi test report.'
            mail_msg = msg

            msg = MIMEText(mail_msg,'html','utf-8')
            msg["Subject"] = subject
            msg["From"]    = from_addr
            msg["To"]      = to_addr

            try:
                s = smtplib.SMTP_SSL("smtp.jhinno.com", 465)
                s.login(from_addr, password)
                s.sendmail(from_addr,[to_addr,to_addr1], msg.as_string())
                s.quit()
                return "Success!"
            except smtplib.SMTPException:
                return "Error :无法发送邮件"





    
     
    


   