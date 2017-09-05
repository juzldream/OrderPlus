#!/bin/bash
# date:17-08-09
# 统计复制文件所有时间。

filename="cn_windows_10_enterprise_version_1511_x64_dvd_7224788.iso"
jhfsdir="/h/"


int=1
while(( $int <= 10 ))
do
    startime=`date "+%s"`
    echo "文件开始上传时间：`date -d @${startime} '+%b %e %Y %a %T'`"
    cp -r $filename $jhfsdir
    if [ $? == 0 ]
    then
        endtime=`date "+%s"`
	echo "文件上传结束时间：`date -d @${endtime} '+%b %e %Y %a %T'`"
	totaltime=`expr $endtime - $startime`
	echo "复制 ${filename} 文件成功，总共用时：${totaltime} s"
	rm -rf ${jhfsdir}/${filename};sleep 10
    else
        echo "文件复制失败！"
    fi
    let "int++"
done





