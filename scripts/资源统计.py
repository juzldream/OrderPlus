#!/usr/bin/python
# -*- coding:utf-8 -*-
# author:racher
# date:17-11-06


import re

file_name = raw_input("please input your file name:")

file = open(file_name)
line = file.readlines()
sum_mem = 0
sum_cpu = 0
for i in range(len(line)):
    g =re.search(r"Memory使用率：(\d+)(.*)% CPU使用率?",line[i])
    sum_mem += float(g.groups()[0] + g.groups()[1])
    f = re.search(r"CPU使用率：(\d+)(.*)% disk读写比?",line[i])
    sum_cpu += float(f.groups()[0] + f.groups()[1])


print "CPU使用率：" + str(sum_cpu/len(line)) + "\n内存使用率：" + str(sum_mem/len(line))


file.close()
