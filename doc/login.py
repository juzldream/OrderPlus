#-*- coding:utf-8 -*-

import requests


# 登录
url = 'http://192.168.149.131:8080/appform/ws/login?code=Juzl150702'
# r = requests.get(url)
# s = r.json()
# print s['data'][0]['token']


# 单点登录
# http://192.168.149.131:8080/appform/ssologin?code=Jhadmin123
url = 'http://192.168.149.131:8080/appform/ssologin'
# s = requests.get(url,params={'code':'Jhadmin123'})
# print s.text



token = 'EF7F0BD62D851C74A760E596731B77F3445B5D69C7BAA46EEAE948791D7AFD8066C49C89199580BD460A381305F1F6AFE8D3E669AA2ADA5B6FF8798B95BF243F318E908D8872A92949872BA461CF9D25D4B94AB37DB517B6BC173E7F19DEE059'

# 同步启用信息 [type ? 0 : 新增或修改；1：删除]
url = 'http://192.168.149.131:8080/appform/ws/user/syncDep'
d = {"sysOrgInfoId":"10003","name":"营销部","type":"0","token":token}
# r = requests.post(url,data=d)
# print r.text
# print r.json()


# 同步人员信息
url = 'http://192.168.149.131:8080/appform/ws/user/syncUser' 
d = {"id":"002","name":"jhinno1","identityCard":"612526199302101000","role":"Admin","unitName":"otherDep","token":token}
# r = requests.post(url,data=d)
# print r.text


# 修改用户状态 [0:freezing;1:normal]
url = 'http://192.168.149.131:8080/appform/ws/user/updateUserStatus'
d = {"status":0,"userId":"jhinno1","token":token} 
s = requests.post(url,data=d)
print s.text
