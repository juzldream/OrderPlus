#!/bin/python
# -*- coding:utf-8 -*-
#Date:05-09-2017
#Author:racher
#Version=.1

import xlrd
import xlwt



def readdata(filename="test.xlsx",start,finish):
        '''
        读取 resapi test plan 数据,按照每行进行读取，返回测试数据列表。
        start : 从start行开始读取数据
        finish :读取到finish-1 行结束
        '''
        wordbook = xlrd.open_workbook(filename)
        # return wordbook.sheet_names()
        data_sheet = wordbook.sheets()[1]
        row_list = []
        for i in range(start,finish):
            row_list.append(data_sheet.row_values(i))
        return row_list

