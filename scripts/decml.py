#!/usr/bin/python
# -*- coding: UTF-8 -*-


import xml.dom.minidom
dom = xml.dom.minidom.parse("myself.xml")

root = dom.documentElement


resapi_nodes = root.getElementsByTagName('resapi')

for node in resapi_nodes:
    print node.getAttribute('no')
    url = node.getElementsByTagName('url')
    print url[0].childNodes
    print url[0].childNodes[0].nodeValue
    #apiname = node.getElementsByTagName('apiname')
    #print apiname[0].childNodes[0].nodeValue
