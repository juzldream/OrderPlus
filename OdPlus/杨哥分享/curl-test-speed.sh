#!/bin/sh
# 使用curl获取各个CDN节点速度
for url in `cat urlfile`

do


speed=$(curl -r 0-1048576 -L -w %{speed_download} -o/dev/null -s "$url")

IP=`echo $url|awk -F\/ '{print $3}'`

echo -e "$IP\t$speed" #>> result.txt

done