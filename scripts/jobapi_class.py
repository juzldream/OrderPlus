#!/usr/bin/python
# -*- coding: UTF-8 -*-
#Date:23-08-2017
#Author:rzh
#Version=.1

import logging
import requests
import json
import psycopg2
import xlrd
import xlwt



class Jobs():
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


    def reddata(slef,start,finish):
        '''
        读取 resapi test plan 数据,按照每行进行读取，返回测试数据列表。
        '''
        wordbook = xlrd.open_workbook('test.xlsx')
        # return wordbook.sheet_names()
        data_sheet = wordbook.sheets()[1]
        row_list = []
        for i in range(start,finish):
            row_list.append(data_sheet.row_values(i))
        return row_list


    def login(self,username,password,url):
        '''
        resapi 登录。
        '''
        url = url + "login?username=" + username + "&password=" + password
        s = Tools().access_web(url)
        if s['result'] == "failed":
            return "ooooooo"
        else:
            return s['data'][0]['token']























        def putlog(self,filename,level,message):

            logger = logging.getLogger("resapi test")
            logger.setLevel(logging.DEBUG)
            formatter = logging.Formatter('[%(asctime)s] [%(name)s] [%(levelname)s] : %(message)s')
            fh = logging.FileHandler(filename)
            fh.setLevel(level)
            fh.setFormatter(formatter)
            logger.addHandler(fh)
            ch = logging.StreamHandler()
            ch.setLevel(logging.DEBUG)
            ch.setFormatter(formatter)
            logger.addHandler(ch)
            logger.debug(message),logger.info(message),logger.warn(message),logger.error(message),logger.critical(message)
            # logger.debug(message)
            return ""

     

    def operdb(self,database,user,password,host,port):
        '''
        链接数据库，返回需要的数据。
        '''
        conn = psycopg2.connect(database="bugs",user="postgres",password="postgres",host="192.168.0.100",port=5432)
        cur = conn.cursor()
        # logbugs = "INSERT INTO bugs VALUES ('11190', '37', '', 'normal', 'IN_PROGRESS', '2017-08-09 10:31:45', '2017-08-09 10:42:00', '【resapi】登录api用户密码输入一个字符或者中文时，都可以成功登录', 'Linux', 'Normal', '12', 'All', '90', '4.0', '48', '', '---', '4', '', '2017-08-09 10:42:00', '1', '1', '1', '0.00', '0.00', null, null);"
        cur.close()
        conn.close()


    def submitbug(self):
        '''
        向bugzilla提交bug。
        '''
