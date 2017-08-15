#coding=utf-8
#filename:
#author:rzhou
#function:write execl data
############################

import xlrd
import xlutils.copy

rb = xlrd.open_workbook('E:\\Python\\Python35\\test.xlsx')

wb = xlutils.copy.copy(rb)

ws = wb.get_sheet(2)

ws.write(3,5,'jhinno.com')

wb.add_sheet('sheetnnn2',cell_overwrite_ok=True)

wb.save('E:\\Python\\Python35\\test.xlsx')