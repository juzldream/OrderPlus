#!/usr/bin/python
# -*- coding: UTF-8 -*-
#Date:23-08-2017
#Author:rzh
#Version=.1


from tool_class import Tools



class main():

	bart = Tools()
	# 获取 api 测试用例数据。
	api_param = bart.readtestdata("case_data.json")
	baseurl = api_param['baseUrl'][0]['head'] + api_param['baseUrl'][0]['IP'] + api_param['baseUrl'][0]['port'] + api_param['baseUrl'][0]['footer'] 


	def jobs(self):

            m = main()

	    
	    
	    # 获取登录的用户名和密码,测试 appform 登录 api 。
	   
   	    for x in range(len(m.api_param['login'])):
	        # print m.api_param['login'][x]['username']
	        # print m.baseurl
	        s = m.bart.login(m.api_param['login'][x]['username'],m.api_param['login'][x]['password'],m.baseurl,m.api_param['login'][x]['expect'])
            # print s
        # 注销 appform
        # 


	    # print main().bart.logout(baseurl,m.token,"真")




	def files(self):
		pass

if __name__ == '__main__':
	main().jobs()
