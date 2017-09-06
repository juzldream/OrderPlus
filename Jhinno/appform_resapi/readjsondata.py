#!/bin/python
# -*- coding:utf-8 -*-


import json


def readtestdata():

	try:
		f = open("case_data.json")
		s = json.load(f) 
	except ValueError:
		return "给定的 json 数据格式有误！"
	except IOError:
		return "没有找到文件或文件读取失败！"
	else:
		return s



j = readtestdata()
print j



