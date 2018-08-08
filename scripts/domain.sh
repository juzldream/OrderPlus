#!/bin/bash
 cat domain.txt | while read line
 do
     echo $line":" >> ./domain.result
     nslookup $line |grep Address |grep -v "127.0.0.1"  >> ./domain.result
 done
