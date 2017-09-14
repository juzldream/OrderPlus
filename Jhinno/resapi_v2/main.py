#!/usr/bin/python
# -*- coding: UTF-8 -*-
#Date:23-08-2017
#Author:jhinno
#Version=2.0


from tool_class import Tools
from fileapi_class import Files 
from jobapi_class import Jobs
import time




class Test_rest_api():

	tool = Tools()
	file = Files()
        job  = Jobs()
	# 获取 api 测试用例数据。
	api_param = tool.readtestdata("case_data.json")
	baseurl = api_param['baseUrl'][0]['head'] + api_param['baseUrl'][0]['IP'] + api_param['baseUrl'][0]['port'] + api_param['baseUrl'][0]['footer'] 
        print 'gloab...'
        for x in range(len(api_param['login'])):
            no       = api_param['login'][x]['no']
            username = api_param['login'][x]['username']
            password = api_param['login'][x]['password']
            expect   = api_param['login'][x]['expect']
            if api_param['login'][x]['expect'] == "1":
                access_token = job.login(no,username,password,baseurl,expect)


	def test_jobs_manage(self):
            '''
	    作业管理类api测试。
	    '''
    	    a = Test_rest_api()
	    
	    # 测试登录[login]appform rest api ,
	    # 分别得到用户名：username；密码：password；URL：baseUrl；expect:[1|0]
	    # 登录成功返回 token 值，由于后续api测试。
   	    for x in range(len(a.api_param['login'])):
                no       = a.api_param['login'][x]['no']
                username = a.api_param['login'][x]['username']
                password = a.api_param['login'][x]['password']
                expect   = a.api_param['login'][x]['expect']
	        s = a.job.login(no,username,password,a.baseurl,expect)
         	if s:
         		access_token = s

            # 测试注销[logout]appform rest api ,
	    # 得到成功登录用户token值：access_token
       	    for x in range(len(a.api_param['logout'])):
                
                s = a.job.logout(a.baseurl,a.api_param['logout'][x]['no'],a.api_param['logout'][x]['token'],a.api_param['logout'][x]['expect'])
                
                # print s
       


	    a.job.logout(a.baseurl,"000",access_token,"1")




	def test_files_manage(self):
   	    '''
	    文件管理类api测试。
	    '''
	    m = Test_rest_api()
            # 测试文件重命名[renamefile]appform rest api ,
	    # 分别得到旧文件名：appform 安装位置：appform_top,
	    # ole_file_name；重命名文件名：new_file_name；URL：baseUrl；expect:[1|0]，token值:access_token
            for x in range(len(m.api_param['renamefile'])):
            	appform_top   = m.api_param['appform_top']
                no            = m.api_param['renamefile'][x]['no']
            	old_file_name = m.api_param['renamefile'][x]['old_file_name']
            	new_file_name = m.api_param['renamefile'][x]['new_file_name']
                expect        = m.api_param['renamefile'][x]['expect']
            	print m.file.rename_file(m.baseurl,no,appform_top,old_file_name,new_file_name,m.access_token,expect)



def main():
    begin = time.time()
    ic = Test_rest_api()
    ic.test_jobs_manage()
    ic.test_files_manage()
    end = time.time()
    localtime = end - begin
    msg = ic.tool.htmldispose(localtime)
    ic.tool.sendmail(msg)

if __name__ == '__main__':
    main()
