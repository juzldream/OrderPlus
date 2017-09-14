#!/usr/bin/python
# -*- coding: UTF-8 -*-
#Date:13-09-2017
#Author:jhinno
#Version=2.0


from tool_class import Tools

class Jobs():
    '''
    作业管理api
    '''
    
    def login(self,no,username,password,url,expect):
        '''
        resapi 登录。
        '''
        url = url + "login?username=" + username + "&password=" + password
        s = Tools().access_web(url)

        if expect == "1":
            if s['result'] == "success":
                log = url + " appform 登录成功. \n\n成功获取token值为: " + str(s["data"][0]["token"]) + "\n[用户登录 CASE-EXPECT-TRUE] 测试: PASS。" + "\n"
                print Tools().putlog(1,log)
                return s["data"][0]["token"]
            else:
                print Tools().putlog(2,url)
                log = "appform login failed. " + str(s["message"]) + "\n[用户登录 CASE-EXPECT-TRUE] 测试: FAILURE。" + "\n"
                Tools().savetestdata("output.xml",no,"login",url,"login用户登录测试",log)
                print Tools().putlog(2,log)
                return ""
        else:
            if s['result'] != "success":
                log = "[用户登录 CASE-EXPECT-FALSE] 测试: Failure。" + "\n"
                Tools().savetestdata("output.xml",no,"login",url,"login用户登录测试",log)
                print Tools().putlog(2,log)
                return ""
            else:
                print Tools().putlog(1,url)
                log = "appform login failed." + s["message"] + "\n[用户登录 CASE-EXPECT-FALSE] 测试: PASS。" + "\n"
                print Tools().putlog(1,log)
                return ""


    def logout(self,url,no,token,expect):
        '''
        注销resapi账户。
        '''
        lourl = url + "logout?token=" + token 
        s = Tools().access_web(lourl)
        if expect == "1":
            if s['result'] == "success":
                log = lourl + "\nappform 注销成功。" + "[用户注销 CASE-EXPECT-TRUE] 测试: PASS。" + "\n"
                print Tools().putlog(1,log)
                return ""
            else:
                log = lourl + "\nappform 注销失败。" + s['message'] + "[用户注销 CASE-EXPECT-TRUE] 测试: FAILURE。" + "\n"
                print Tools().putlog(2,log)
                return ""
        else:
            if s['result'] == "success":
                print Tools().putlog(2,url)
                log = "appform 注销成功。" + "[用户注销 CASE-EXPECT-FALSE] 测试: Failure。" + "\n"
                Tools().savetestdata("output.xml",no,"logout",url,"logout用户注销测试",log)
                print Tools().putlog(2,log)
                return ""
            else:
                log = lourl + "\nappform 注销失败。" + s['message'] + "[用户注销 CASE-EXPECT-FALSE]: 测试 PASS。" + "\n"
                print Tools().putlog(1,log)
                return ""
    



