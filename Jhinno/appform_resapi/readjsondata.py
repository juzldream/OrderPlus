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




def readdata(start,finish):
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

