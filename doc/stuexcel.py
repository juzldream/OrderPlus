#coding=utf-8
#filename:
#author:rzhou
#function:read execl data
############################

import xlrd
import xlwt
import xlutils.copy

wordbook = xlrd.open_workbook(r'E:\Python\Python35\test.xlsx')

# 抓取所有的sheet页名称
print(wordbook.sheet_names())

data_sheet = wordbook.sheets()[0]
print(data_sheet.name,data_sheet.nrows,data_sheet.ncols)

# 获取第一行内容
rows = data_sheet.row_values(0)
print(rows[0])
rows = data_sheet.row_values(1)
print(rows[0])

nrows = data_sheet.nrows
print(nrows)

for i in range(nrows):
	print(data_sheet.row_values(i)[2:3])




