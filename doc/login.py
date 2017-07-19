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



token = '72B7656A987E7C74DA2C9C2A947FC3B4445B5D69C7BAA46EEAE948791D7AFD8066C49C89199580BD460A381305F1F6AFE8D3E669AA2ADA5B6FF8798B95BF243FDB99252708C76BFABCD453BA3C97E420D572D6BE24528E168C40E6F872ACD388'

# 同步启用信息 [type ? 0 : 新增或修改；1：删除]
url = 'http://192.168.149.131:8080/appform/ws/user/syncDep'
d = {"sysOrgInfoId":"10003","name":"营销部99","type":"0","token":token}
# r = requests.post(url,data=d)
# print r.text
# print r.json()


# 同步人员信息
url = 'http://192.168.149.131:8080/appform/ws/user/syncUser' 
d = {"id":"010","name":"jhinno3","identityCard":"008","role":"Admin","unitName":"otherDep","token":token}
r = requests.post(url,data=d)
print r.text


# 修改用户状态 [0:freezing;1:normal]
url = 'http://192.168.149.131:8080/appform/ws/user/updateUserStatus'
d = {"status":1,"userId":"006","token":token} 
# s = requests.post(url,data=d)
# print s.text
