# -*- coding: UTF-8 -*- 

#import re #正则处理
import requests #get请求
from bs4 import BeautifulSoup
import lxml

import sys
reload(sys)
sys.setdefaultencoding('utf-8')

def GirlGet(url):
    header = {'User-Agent':'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36 SE 2.X MetaSr 1.0'}
    GetHtml = requests.get(url, headers=header,timeout=20)
    GetHtml.encoding = 'utf-8'
    html = GetHtml.text
    print(html)
    return html

def GirlSpider(html):
    MySoup = BeautifulSoup(html, 'lxml')
    PictureList = MySoup.ul
    MyPicture = PictureList.find_all('img')
    for each in MyPicture:
        name = each.get('alt')
        link = each.get('src')
        picture = requests.get(link, timeout=20)
        with open('H:\meizigui\%s.jpg' %name, 'wb') as file:
            file.write(picture.content)
            print('%s已保存成功' %name)



for x in range(1,2):
    url = 'http://www.mmjpg.com/home/%s' %x
    HtmlText = GirlGet(url)
    GirlSpider(HtmlText)