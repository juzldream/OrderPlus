#!/usr/bin/python
# -*- coding: UTF-8 -*-

from xml.etree.ElementTree import ElementTree,Element  


def savetestdata(filename,apitext,url,title,error):
	tree=ElementTree()  
	tree.parse('myself.xml')  

	root=tree.getroot()  

	element=Element('resapi',{'no':'001'}) 

	one=Element('apiname')  
	one.text='copyfile测试'.decode('utf-8')
	element.append(one)

	two=Element('url')
	two.text='http://192.168.158.120/appform/ws/ping?'.decode('utf-8')
	element.append(two)

	three=Element('title')
	three.text='给定密码不正确。'.decode('utf-8')
	element.append(three)

	four=Element('error')
	four.text='给定密码不正确。'.decode('utf-8')
	element.append(four)

	root.append(element)  


	tree.write('myself.xml',encoding='utf-8')  


savetestdata("myself.xml","copyfile测试","copyfile?","文件copy api测试","测试未通过，token值给定的不正确。")
