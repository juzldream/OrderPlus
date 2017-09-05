#!/usr/bin/python
# -*- coding: UTF-8 -*-


import smtplib
from email.mime.text import MIMEText
from email.header import Header


from_addr = "rzhou@jhinno.com"

password  = "Juzl150702"

to_addr   = "1576768715@qq.com"

title = "appform 4.0"
content = "使用badmin reconfig检查unischeduler存在问题时，使用userreconfig的api http://192.168.149.131:8080/jhsecurity/ws/user/userreconfig?token =访问页面返回的xml结果是成功。"
test_api = "login"
mail_msg = """
<table border="1">
	<tr>
		<th>测试环境</th>
		<td>""" + title + """</td>
	</tr>
	<tr>
		<th>测试 api</th>
		<td>""" + test_api + """</td>
	</tr>
	<tr>
		<th>问题</th>
		<td>""" + content + """</td>
	</tr>
</table>
"""

msg = MIMEText(mail_msg,'html','utf-8')
msg["Subject"] = "【resapi】resapi userreconfig功能有问题"
msg["From"]    = from_addr
msg["To"]      = to_addr

try:
	s = smtplib.SMTP_SSL("smtp.jhinno.com", 465)
	s.login(from_addr, password)
	s.sendmail(from_addr,[to_addr,], msg.as_string())
	s.quit()
	print("Success!")
except smtplib.SMTPException:
    print("Error :无法发送邮件")
    
