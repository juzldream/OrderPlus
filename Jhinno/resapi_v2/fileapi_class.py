#!/usr/bin/python
# -*- coding: UTF-8 -*-
#Date:13-09-2017
#Author:jhinno
#Version=2.0


import os
from tool_class import Tools


class Files():
    '''
    文件管理api
    '''
    

    def rename_file(self,url,no,appform_top,old_file_name,new_file_name,access_token,expect):
        '''
        重命名文件。
        '''
        path = appform_top + "logs/" + new_file_name
        url = url + "renamefile?old_file_name=" + appform_top + "logs/" + old_file_name + "&new_file_name=" + new_file_name + "&token=" + access_token
        s = Tools().access_web(url)
        if expect == "1":
            if s["result"] == "success" and os.path.isfile(path):        
                log = url + "\n文件重命名成功," + " portal.log 文件命名为："  + new_file_name + "\n[文件重命名 CASE-EXPECT-TRUE] 测试: PASS。" + "\n"
                print Tools().putlog(1,log)
                return ""
            else:
                log = url + "\n文件重命名失败: " + s['message'] + "\n[文件重命名 CASE-EXPECT-TRUE] 测试: Failure。" + "\n"
                Tools().savetestdata("output.xml",no,"renamefile",url,"renamefile 重命名文件测试",log)
                print Tools().putlog(2,log)
                return ""
        else:
            if s["result"] == "success" and os.path.isfile(path): 
                log = url + "\n文件重命名失败: " + s['message'] + "\n[文件重命名 CASE-EXPECT-FALSE] 测试: Failure。" + "\n"
                Tools().savetestdata("output.xml",no,"renamefile",url,"renamefile 重命名文件测试",log)
                print Tools().putlog(2,log)
                return ""
            else:
                log = url + "\n文件重命名失败: " + s['message'] + "\n[文件重命名 CASE-EXPECT-FALSE] 测试: PASS。" + "\n"
                print Tools().putlog(1,log)
                return ""




