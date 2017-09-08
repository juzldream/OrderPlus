#!/usr/bin/python
# -*- coding: UTF-8 -*-


import xml.dom.minidom
dom = xml.dom.minidom.parse("myself.xml")

root = dom.documentElement


resapi_nodes = root.getElementsByTagName('resapi')

for node in resapi_nodes:
    no = node.getAttribute('no')
    url = node.getElementsByTagName('url')
    apiname = node.getElementsByTagName('apiname')
    error = node.getElementsByTagName('error')
    print url[0].childNodes[0].nodeValue
    print apiname[0].childNodes[0].nodeValue
    print error[0].childNodes[0].nodeValue
    print no
