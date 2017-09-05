#!/usr/bin/python
# -*- coding: UTF-8 -*-
#Date:23-08-2017
#Author:rzh
#Version=.1

import requests
import json




def access_web(url):
    '''
    模仿浏览器访问url，返回json数据。
    '''
    req = requests.get(url=url)
    s = req.json() 
    return s      


url = "ttp://192.168.158.120:8080/appform/ws/login?username=GKKb%2boPTGWGyqWBbijvjCQ%3d%3d&password=GKKb%2boPTGWGyqWBbijvjCQ%3d%3d"
s = access_web(url)

print s 
