#!/usr/bin/python
# -*- coding: UTF-8 -*-
#Date:23-08-2017
#Author:rzh
#Version=.1


from tool_class import Tools



class main():

	bart = Tools()
	# 获取 appform 访问 URL。
	baseurl = ((bart.readdata(0,1))[0][2]).encode("utf-8")
	p = bart.readdata(3,4) 
	username = p[0][1]
	password = p[0][2]
	expect = p[0][3]
	# 登录 appform 获得 token 。
	# token = bart.login(username.encode("utf-8"),password.encode("utf-8"),baseurl,expect.encode("utf-8"))
	# print token

	def main(self):

	    baseurl = main().baseurl

	    
	    # 获取登录的用户名和密码,测试 appform 登录 api 。
	    s = main().bart.readdata(3,10)
	    for i in range(0,7):
	    	username = s[i][1]
	    	password = s[i][2]
	    	expect = s[i][3]
    		token = main().bart.login(username.encode("utf-8"),password.encode("utf-8"),baseurl,expect.encode("utf-8"))



if __name__ == '__main__':
	main().main()
	# main().tesst()
