#!/bin/bash
#
# Asiainfo DNS Cache Management Program
# Copyright(c) Asiainfo,Inc. All rights reserved.
#
# Support 3 cache product types: 1. bind_cache 2. dns_cache 3. dns_cache_pro
# Tested on Redhat Enterprise Linux 5.x,6.x,7.x (all) and solaris 5.10 (bind_cache)
# Note: Some important functions need root privelege, so should set the sudo properly first.

# Version History
# ver-3.0.0  2016-12-09  First version.
#

SHELL_VERSION=3.0.0

USAGE()
{
    echo "Asiainfo DNS Cache Management Program (version ${SHELL_VERSION})"
    echo "Usage: $0 <management_action>"
    echo "Available actions listed below:"
    echo "       get_system_info:   show the system informatin,such as hostname, OS type,cpu, memory, etc."
    echo "    product_auto_check:   detect the product infomation,such as name, type, config directory, etc."
    echo "                          and save it in productinfo.cfg"
    echo "      get_product_info:   show the product informatin saved in productinfo.cfg"
    echo "         reload_config:   reload the configuration"
    echo "         update_config:   update the configuration files and then reload"
    echo "           cache_query:   reload the configuration"
    echo "           cache_flush:   update the configuration files and then reload"
    echo "                 start:   startup the program"
    echo "                  stop:   stop the program"
    echo "                status:   show the current status of the program"
    echo "           start_route:   startup the ospf route deamons"
    echo "            stop_route:   stop the ospf route deamons"
    echo "          route_status:   show the current status of the ospf route"
    echo "   run_control_command:   run the custom control command"
    echo "        run_os_command:   run the custom OS command"
    echo "            run_plugin:   run the plugin program"
}

INFO ()
{
    echo "`date '+%Y-%m-%d %H:%M:%S'` INFO $1" | tee -a ${MGMT_LOG_FILE} >&2
}

WARN ()
{
    echo "`date '+%Y-%m-%d %H:%M:%S'` WARN $1" | tee -a ${MGMT_LOG_FILE} >&2
}

ERROR ()
{
    echo "`date '+%Y-%m-%d %H:%M:%S'` ERROR $1" | tee -a ${MGMT_LOG_FILE} >&2
}


# only support Linux and SunOS
get_system_info()
{
    INFO "BEGIN ${FUNCNAME[0]}"

    # 1)  system type
    SYSTEM_TYPE=`uname`
	if [ "${SYSTEM_TYPE}" != "Linux" ] && [ "${SYSTEM_TYPE}" != "SunOS" ]
	then
	    ERROR "Unsupported System: ${SYSTEM_TYPE}"
	    return 1
	fi
	echo "SYSTEM_TYPE=${SYSTEM_TYPE}"

    # 2)  host name
    HOST_NAME=`hostname`
    echo "HOST_NAME=${HOST_NAME}"

    # 3) the OS info
    OS_TYPE=`uname -r`
    echo "OS_TYPE=${OS_TYPE}"

    # 4) vendor, machine type,machine serial
	if [ "${SYSTEM_TYPE}" = "Linux" ]
	then
		VENDOR=`/usr/sbin/dmidecode -t 1 | grep "Manufacturer: " | awk -F"Manufacturer: " '{ print $2}'`
		MACHINE_TYPE=`/usr/sbin/dmidecode -t 1 | grep "Product Name: " | awk -F"Product Name: " '{ print $2}'`
		MACHINE_SERIAL=`/usr/sbin/dmidecode -t 1 | grep "Serial Number: " | awk -F"Serial Number: " '{ print $2}'`
	else
		VENDOR=`/usr/bin/showrev | grep "Hardware provider: " | nawk -F"Hardware provider: " '{ print $2}'`
		MACHINE_TYPE=`uname -i`
        MACHINE_SERIAL=`/usr/bin/showrev | grep "Hostid: " | nawk -F"Hostid: " '{ print $2}'`
	fi
    echo "VENDOR=${VENDOR}"
    echo "MACHINE_TYPE=${MACHINE_TYPE}"
    echo "MACHINE_SERIAL=${MACHINE_SERIAL}"

    # 5) cpu, memory
	if [ "${SYSTEM_TYPE}" = "Linux" ]
	then
		CPU_MODEL=`cat /proc/cpuinfo  | grep "model name" | awk -F": " '{ print $2 }' | head -1`
		CPU_NUM=`cat /proc/cpuinfo  | grep "model name" | wc -l`
		MEMORY="`free -m | grep 'Mem:' | awk '{ print $2 }'` Megabytes"
	else
		CPU_MODEL=`/usr/sbin/prtdiag -v | grep "MHz" | grep "SUNW," | head -1 | nawk -F"SUNW," '{ print $2 }' | nawk '{ print $1 }'`
		CPU_NUM=`/usr/sbin/prtdiag -v | grep "MHz" | grep "SUNW," | wc -l`
		MEMORY=`/usr/sbin/prtconf | grep "Memory size: " | head -1 | nawk -F"Memory size: " '{ print $2 }'`
	fi
    echo "CPU_MODEL=${CPU_MODEL}"
    echo "CPU_NUM=${CPU_NUM}"
    echo "MEMORY=${MEMORY}"

    # 5) network IPs
	if [ "${SYSTEM_TYPE}" = "Linux" ]
	then
		IP_SET=`/sbin/ifconfig -a  | grep "inet addr:"  | awk -F"inet addr:" '{print $2}' | grep -v "127.0.0.1" | awk '{print $1}'`
	else
	    IP_SET=`/usr/sbin/ifconfig -a   | grep "inet "  | grep -v "127.0.0.1" | awk '{print $2}'`
	fi
    for IP in ${IP_SET}
    do
        MACHINE_IP="${IP};${MACHINE_IP}"
    done
    echo "MACHINE_IP=${MACHINE_IP}"

    INFO "END ${FUNCNAME[0]}"
    return 0
}

#check the product running enviroment and generate the default configuration if succeed.
product_auto_check ()
{
    INFO "BEGIN ${FUNCNAME[0]}"
    PROGRAM=""
    PRODUCT_NAME=""
    PRODUCT_VERSION=""
    PRODUCT_CONFIG_DIR=""

    # 1) get the product type
    if [ -f ${PRODUCT_DIR}/sbin/named ]
    then
        PRODUCT_NAME=bind_cache
        PROGRAM="${PRODUCT_DIR}/sbin/named"
    elif [ -f ${PRODUCT_DIR}/bin/dns_cache ]
    then
        PRODUCT_NAME=dns_cache
        PROGRAM="${PRODUCT_DIR}/bin/dns_cache"
    elif [ -f ${PRODUCT_DIR}/bin/dns_cache_pro ]
    then
        PRODUCT_NAME=dns_cache_pro
        PROGRAM="${PRODUCT_DIR}/bin/dns_cache_pro"
    fi

    if [ "${PRODUCT_NAME}" = "" ]
    then
        ERROR "Can't find product in ${PRODUCT_DIR}! Please set the correct directory or upgrade the software."
        return 1
    else
        INFO "Find the product: ${PRODUCT_NAME}"
    fi

    # 2) get the product version
    if [ "${PRODUCT_NAME}" = "bind_cache" ]
    then
        # We only support bind_cache version greater than "3.0.1"
        # Version info like: BIND 9.10.2-P4-v3.0.1 ; BIND 9.10.2-P4-v3.1.1; dns_recursive 3.x.x; bind_cache 3.x.x
        VERSIONINFO=`${PROGRAM} -v | grep "[3-9]\.[0-9].*\.[0-9].*" | tail -1`
        if [ "${VERSIONINFO}" = "" ]
        then
            ERROR "The version is too old. You should upgrade the main version to 3(3.x.x) or larger!"
        elif [ "${VERSIONINFO}" = "BIND 9.10.2-P4-v3.0.1" ]
        then
            PRODUCT_VERSION="3.0.1"
        elif  [ "${VERSIONINFO}" = "BIND 9.10.2-P4-v3.1.1" ]
        then
            PRODUCT_VERSION="3.1.1"
        else
            PRODUCT_VERSION=`echo "${VERSIONINFO}" | awk '{ print $2 }'`
        fi
    elif [ "${PRODUCT_NAME}" = "dns_cache" ]
    then
        # We try to get version info from program itself by first (dns_cache version >= 3.2).
        VERSIONINFO=`${PROGRAM} -v | grep "[3-9]\.[0-9].*\.[0-9].*" | tail -1`
        if [ "${VERSIONINFO}" = "" ]
        then
            # It must be older than 3.2, so try to get the version info from readme.txt
            WARN "Can't get version info from: ${PROGRAM} -v"
            README_TXT="${PRODUCT_DIR}/readme.txt"
            if [ ! -f ${README_TXT} ]
            then
                ERROR "${README_TXT} does not exists!"
                ERROR "Can't find the product version!"
                return 1
            fi
            #readme.txt contains Chinese characters and is maybe dos format. :O
            VERSIONINFO=`cat ${README_TXT} | awk '{sub("\r$","",$0); print $0}' |grep -P "^\xC8\xED\xBC\xFE\xB0\xE6\xB1\xBE\xA3\xBA" | tail -1 | grep "[3-9]\.[0-9].*\.[0-9].*"`
            if [ "${VERSIONINFO}" = "" ]
            then
                ERROR "The version is too old. You should upgrade the main version to 3(3.x.x)!"
                return 1
            else
                PRODUCT_VERSION=`echo "${VERSIONINFO}" | awk -F"\xA3\xBA" '{ print $2 }'`
            fi
        else
            #  Version info like: "dns_cache version 3.x.x"
            PRODUCT_VERSION=`echo "${VERSIONINFO}" | awk '{ print $3 }'`
        fi
    elif [ "${PRODUCT_NAME}" = "dns_cache_pro" ]
    then
        # We try to get version info from program itself.
        # Version info like: "dns_cache_pro version 3.x.x"
        VERSIONINFO=`${PROGRAM} -v | grep "[3-9]\.[0-9].*\.[0-9].*" | tail -1`
        PRODUCT_VERSION=`echo "${VERSIONINFO}" | awk '{ print $3 }'`
    fi

    # check if some error happens
    if [ "${PRODUCT_VERSION}" = "" ]
    then
        ERROR "Can't get the product version! Please set the correct directory or upgrade the software."
        return 1
    else
        INFO "Find the product version: ${PRODUCT_VERSION}"
    fi


    # 3) get the product configuration directory
    if [ "${PRODUCT_NAME}" = "bind_cache" ]
    then
        if [ -d ${PRODUCT_DIR}/etc ]
        then
            PRODUCT_CONFIG_DIR="${PRODUCT_DIR}/etc"
        fi
    elif [ "${PRODUCT_NAME}" = "dns_cache" ]
    then
        if [ -d ${PRODUCT_DIR}/config ]
        then
            PRODUCT_CONFIG_DIR="${PRODUCT_DIR}/config"
        fi
    elif [ "${PRODUCT_NAME}" = "dns_cache_pro" ]
    then
        if [ -d ${PRODUCT_DIR}/config ]
        then
            PRODUCT_CONFIG_DIR="${PRODUCT_DIR}/config"
        fi
    fi

    # check if some error happens
    if [ "${PRODUCT_CONFIG_DIR}" = "" ]
    then
        ERROR "Can't get the config directory! Please set the correct directory or upgrade the software."
        return 1
    else
        INFO "Find the config directory: ${PRODUCT_CONFIG_DIR}"
    fi

    # 4) get the control command
    if [ "${PRODUCT_NAME}" = "bind_cache" ]
    then
        RNDC_CMD="${PRODUCT_DIR}/sbin/rndc"
        if [ ! -f ${RNDC_CMD} ]
        then
            ERROR "${RNDC_CMD} not found!"
            return 1
        fi

        NAMED_CONF="${PRODUCT_CONFIG_DIR}/named.conf"
        if [ ! -f ${NAMED_CONF} ]
        then
            ERROR "${NAMED_CONF} not found!"
            return 1
        fi

        # get rndc port
        # rndc port in config file should like this: "inet 127.0.0.1 port 953"
        RNDC_PORT=`grep "inet.* port" ${NAMED_CONF} | awk -F"port" '{print $2}'`
        if [ "${RNDC_PORT}" = "" ]
        then
            ERROR "Can't find rndc port in the ${NAMED_CONF}!"
            return 1
        fi
        CONTROL_CMD="${RNDC_CMD} -p ${RNDC_PORT}"
    elif [ "${PRODUCT_NAME}" = "dns_cache" ] || [ "${PRODUCT_NAME}" = "dns_cache_pro" ]
    then
        CMDSH_CMD="${PRODUCT_DIR}/bin/cmdsh3"
        if [ ! -f ${CMDSH_CMD} ]
        then
            ERROR "${CMDSH_CMD} not found!"
            return 1
        fi

        if [ "${PRODUCT_NAME}" = "dns_cache" ]
        then
            CACHE_CONF="${PRODUCT_CONFIG_DIR}/dns_cache.conf"
        else
            CACHE_CONF="${PRODUCT_CONFIG_DIR}/dns_cache_pro.conf"
        fi
        if [ ! -f ${CACHE_CONF} ]
        then
            ERROR "${CACHE_CONF} not found!"
            return 1
        fi

        # get cmdsh port
        # cmdsh port in config file should like this: "listen_port = 15000"
        CMDSH_PORT=`grep "^listen_port" ${CACHE_CONF} | awk -F"=" '{print $2}'`
        if [ "${CMDSH_PORT}" = "" ]
        then
            ERROR "Can't find cmdsh port in the ${CACHE_CONF}!"
            return 1
        fi
        CONTROL_CMD="${CMDSH_CMD} 127.0.0.1 ${CMDSH_PORT} 2"
    else
        ERROR "Unknown Product Name: ${PRODUCT_NAME}!"
        return 1
    fi

    # save check result to product configuration file
    INFO "Write the result to ${PRODUCT_INFO_FILE}"
    echo "#This is generated by management auto check program" > ${PRODUCT_INFO_FILE}
    echo "#Generate Time: `date '+%Y-%m-%d %H:%M:%S'`" >> ${PRODUCT_INFO_FILE}
    echo "PROGRAM=${PROGRAM}" >> ${PRODUCT_INFO_FILE}
    echo "PRODUCT_NAME=${PRODUCT_NAME}" >> ${PRODUCT_INFO_FILE}
    echo "PRODUCT_VERSION=${PRODUCT_VERSION}" >> ${PRODUCT_INFO_FILE}
    echo "PRODUCT_CONFIG_DIR=${PRODUCT_CONFIG_DIR}" >> ${PRODUCT_INFO_FILE}
    echo "CONTROL_CMD=\"${CONTROL_CMD}\"" >> ${PRODUCT_INFO_FILE}
    echo "#End" >> ${PRODUCT_INFO_FILE}

    INFO "END ${FUNCNAME[0]}"
    return 0
}

get_product_info()
{
    INFO "BEGIN ${FUNCNAME[0]}"

    if [ ! -f ${PRODUCT_INFO_FILE} ]
    then
        ERROR "${PRODUCT_INFO_FILE} does not exists!"
        return 1
    fi

    cat ${PRODUCT_INFO_FILE}
    if [ $? -ne 0 ]
    then
        ERROR "cat ${PRODUCT_INFO_FILE} failed."
        return 1
    fi

    INFO "END ${FUNCNAME[0]}"
    return 0
}

source_product_info()
{
    # source product info
    if [ ! -f ${PRODUCT_INFO_FILE} ]
    then
        ERROR "${PRODUCT_INFO_FILE} does not exists!"
        return 1
    fi
    . ${PRODUCT_INFO_FILE}
    return 0
}

reload_config()
{
    INFO "BEGIN ${FUNCNAME[0]}"

    source_product_info
    if [ $? -ne 0 ]
    then
        ERROR "source_product_info FAILED!"
        return 1
    fi

    if [ "${CONTROL_CMD}" = "" ]
    then
        ERROR "CONTROL_CMD is NULL!"
        return 1
    fi

    if [ "${PRODUCT_NAME}" = "bind_cache" ]
    then
        CONFIG_RELOAD_PARAM="reload"
        SUCCESS_FLAG="server reload successful"
    elif [ "${PRODUCT_NAME}" = "dns_cache" ] || [ "${PRODUCT_NAME}" = "dns_cache_pro" ]
    then
        CONFIG_RELOAD_PARAM="config reload"
        SUCCESS_FLAG="reload configure succeed."
    else
        ERROR "Unknown product name: ${PRODUCT_NAME} !"
        return 1
    fi

    CMD_EXE_LOG=${MGMT_LOG_DIR}/cmdExeTmp.log
    ${CONTROL_CMD} "${CONFIG_RELOAD_PARAM}" >${CMD_EXE_LOG} 2>&1
    NUM=`cat ${CMD_EXE_LOG} | grep "${SUCCESS_FLAG}" | wc -l`
	if [ ${NUM} -lt 1 ]
	then
	    ERROR "reload config FAILED! See details below:"
	    ERROR "`cat ${CMD_EXE_LOG}`"
		return 1
    else
        INFO "reload config OK!"
	fi

    INFO "END ${FUNCNAME[0]}"
    return 0
}

update_config()
{
    # Rollback WHEN Update Config Failed
    ROLLBACK()
    {
        INFO "[ROLLBACK] begin to rollback ..."
        BACKUP_FILE=${BACKUP_CONFIG_DIR}/config_backup.tar
        if [ "${PRODUCT_CONFIG_DIR}" = "" ]
        then
            ERROR "[ROLLBACK] PRODUCT_CONFIG_DIR is NULL!"
            return 1
        fi

        if [ ! -d ${PRODUCT_CONFIG_DIR} ]
        then
            ERROR "[ROLLBACK] PRODUCT_CONFIG_DIR:${PRODUCT_CONFIG_DIR} does not exists!"
            return 1
        fi

        # clear the direcotry first
        cd ${PRODUCT_CONFIG_DIR}
        rm -rf *
        if [ $? -ne 0 ]
        then
            ERROR "[ROLLBACK] rm -f ${PRODUCT_CONFIG_DIR}/* FAILED!"
            return 1
        else
            INFO "[ROLLBACK] rm -f ${PRODUCT_CONFIG_DIR}/* OK."
        fi

        # copy files from backup
        INFO "[ROLLBACK] tar xvf ${BACKUP_FILE} ..."
        tar xvf ${BACKUP_FILE}
        if [ $? -ne 0 ]
        then
            ERROR "[ROLLBACK] tar xvf ${BACKUP_FILE} FAILED!"
            return 1
        else
            INFO "[ROLLBACK] tar xvf ${BACKUP_FILE} OK."
        fi

        reload_config
        if [ $? -ne 0 ]
        then
            ERROR "[ROLLBACK] Reload config after rollback config FAILED!"
            return 1
        else
            INFO "[ROLLBACK] Reload config after rollback config OK."
        fi
        INFO "[ROLLBACK] Rollback OK."
        return 0
    }
    # delete expired config backups
    DELEXPIREDCONFIG()
    {
		RESERVE_NUM=20
		cd ${UPDATE_CONFIG_BASE}
		NUM=`ls -rt | grep "newconfig" | wc -l`
		if [ ${NUM} -gt ${RESERVE_NUM} ]
		then
			INFO "The config dirs count[${NUM}] are larger than ${RESERVE_NUM}. Delete the old ones."
			DELETE_NUM=`expr ${NUM} - ${RESERVE_NUM}`
			for d in `ls -rt | grep "newconfig" | head -${DELETE_NUM}`
			do
				rm -rf ${d}
				if [ $? -ne 0 ]
				then
					WARN "Delete directory ${d} FAILED!"
				else
					INFO "Delete directory ${d} OK."
				fi
			done
		fi
	}

    INFO "BEGIN ${FUNCNAME[0]}"

    NEW_CONFIG="$1"
    if [ "${NEW_CONFIG}" = "" ]
    then
        ERROR "The parameter(new config directory) is NULL!"
        ERROR "Should run like this: ${FUNCNAME[0]} newconfig20161203205301"
        return 1
    fi

    # source product info
    if [ ! -f ${PRODUCT_INFO_FILE} ]
    then
        ERROR "${PRODUCT_INFO_FILE} does not exists!"
        return 1
    fi
    . ${PRODUCT_INFO_FILE}

    # check current config directory
    if [ ! -d ${PRODUCT_CONFIG_DIR} ]
    then
        ERROR "${PRODUCT_CONFIG_DIR} does not exists!"
        return 1
    fi

    # new config files are located here,
    UPDATE_CONFIG_BASE=${MGMT_DIR}/update_config
    NEW_CONFIG_DIR=${UPDATE_CONFIG_BASE}/${NEW_CONFIG}
    INFO "New config directory is ${NEW_CONFIG_DIR}"
    if [ ! -d ${NEW_CONFIG_DIR} ]
    then
        ERROR "${NEW_CONFIG_DIR} does not exists!"
        return 1
    fi

    ADD_LIST=${NEW_CONFIG_DIR}/add_files.list
    if [ ! -f ${ADD_LIST} ]
    then
        ERROR "${ADD_LIST} does not exists!"
        return 1
    fi

    DELETE_LIST=${NEW_CONFIG_DIR}/delete_files.list
    if [ ! -f ${DELETE_LIST} ]
    then
        ERROR "${DELETE_LIST} does not exists!"
        return 1
    fi

    # Someone else is running update_config?
    PID_FILE="${UPDATE_CONFIG_BASE}/update_config.pid"
    if [ -f ${PID_FILE} ]
    then
        WARN "${PID_FILE} already exists. Someone(pid:`cat ${PID_FILE}`) is updating the config!"
        INFO "Wait for 10 seconds..."
        sleep 10
        if [ -f ${PID_FILE} ]
        then
            ERROR "${PID_FILE} still exists. I abort!"
            return 1
        fi
    fi

    echo $$ > ${PID_FILE}
    if [ $? -ne 0 ]
    then
        ERROR "Create the ${PID_FILE} FAILED!"
        return 1
    fi
    # remove pidfile when exit
    trap 'rm -f ${PID_FILE}' INT TERM EXIT

    # 1) backup current config files
    INFO "backup ${PRODUCT_CONFIG_DIR} ..."
    BACKUP_CONFIG_DIR=${NEW_CONFIG_DIR}/backup
    mkdir -p ${BACKUP_CONFIG_DIR}
    if [ $? -ne 0 ]
    then
        ERROR "mkdir ${BACKUP_CONFIG_DIR} failed"
        return 1
    fi

    BACKUP_FILE=${BACKUP_CONFIG_DIR}/config_backup.tar
    cd ${PRODUCT_CONFIG_DIR}
    INFO "Backup ${PRODUCT_CONFIG_DIR} as ${BACKUP_FILE} ... "
    tar cvf ${BACKUP_FILE} *
    if [ $? -ne 0 ]
    then
        ERROR "Backup ${PRODUCT_CONFIG_DIR} as ${BACKUP_FILE} FAILED!"
        return 1
    else
        INFO "Backup ${PRODUCT_CONFIG_DIR} as ${BACKUP_FILE} OK."
    fi

    # 2) add new files (check)
    # check the files first
    INFO "Check the files in the add list ..."
    while read LINE
    do
        # trim and ignore blank lines
        ADD_FILE=`echo ${LINE}`
        if [ "${ADD_FILE}" = "" ]
        then
            continue
        fi

        SRC_FILE=${NEW_CONFIG_DIR}/add_files/${ADD_FILE}
        if [ ! -f ${SRC_FILE} ]
        then
            ERROR "${SRC_FILE} does not exists!"
            return 1
        fi
    done < ${ADD_LIST}
    INFO "Check the files in the add list OK."

    # 3) delete unused files
	INFO "Delete Files from Product Config Dir Begin."
	DEL_FILES_NUM=0;
	DEL_FILES_WARN_NUM=0;
    while read LINE
    do
        # trim and ignore blank lines
        DELETE_FILE=`echo ${LINE}`
        if [ "${DELETE_FILE}" = "" ]
        then
            continue
        fi
        DELETE_FILE=${PRODUCT_CONFIG_DIR}/${DELETE_FILE}
        if [ $(ls ${DELETE_FILE} 2>/dev/null | wc -l) -gt 0 ]
        then
            rm -rf ${DELETE_FILE}
            if [ $? -ne 0 ]
            then
                ERROR "Delete ${DELETE_FILE} FAILED!"
                ROLLBACK
                return 1
            else
				DEL_FILES_NUM=$(($DEL_FILES_NUM+1))
                #INFO "Delete ${DELETE_FILE} OK."
            fi
        else
            # If the file to be deleted is not found, we ignore and continue.
			DEL_FILES_WARN_NUM=$(($DEL_FILES_WARN_NUM+1))
            # WARN "${DELETE_FILE} is not found, so ignore it!"
        fi
    done < ${DELETE_LIST}
	INFO "Delete Files from Product Config Dir End ($DEL_FILES_NUM files delete, $DEL_FILES_WARN_NUM files not found)."

    # 4) add new files (copy files)
    # copy files to product config dir
	INFO "Copy Files to Product Config Dir Begin."
	COPY_FILES_NUM=0;
    while read LINE
    do
        # trim and ignore blank lines
        ADD_FILE=`echo ${LINE}`
        if [ "${ADD_FILE}" = "" ]
        then
            continue
        fi
		
        SRC_FILE=${NEW_CONFIG_DIR}/add_files/${ADD_FILE}
        DST_FILE=${PRODUCT_CONFIG_DIR}/${ADD_FILE}
        DST_DIR=`dirname ${DST_FILE}`
        if [ ! -d ${DST_DIR} ]
        then
            mkdir -p ${DST_DIR}
            if [ $? -ne 0 ]
            then
                ERROR "mkdir ${DST_DIR} FAILED!"
                ROLLBACK
                return 1
            fi
        fi
        cp -f ${SRC_FILE} ${DST_FILE}
        if [ $? -ne 0 ]
        then
            ERROR "Copy ${SRC_FILE} to ${DST_FILE} FAILED!"
            ROLLBACK
            return 1
        else
			COPY_FILES_NUM=$(($COPY_FILES_NUM+1))
            #INFO "Copy ${SRC_FILE} to ${DST_FILE} OK."
        fi
    done < ${ADD_LIST}
	INFO "Copy Files to Product Config Dir End ($COPY_FILES_NUM files)."
	
    #  5) reload config
    reload_config
    if [ $? -ne 0 ]
    then
        ERROR "Reload config after update config FAILED!"
		ROLLBACK
		# delete expired config backups, reserve 20
		DELEXPIREDCONFIG
        return 1
    else
        INFO "Reload config after update config OK."
		# delete expired config backups, reserve 20
		DELEXPIREDCONFIG
    fi

    rm -f ${PID_FILE}
    INFO "END ${FUNCNAME[0]}"
    return 0
}

cache_query()
{
    INFO "BEGIN ${FUNCNAME[0]}"
    QUERY_DDOMAIN="$1"

    source_product_info
    if [ $? -ne 0 ]
    then
        ERROR "source_product_info FAILED!"
        return 1
    fi

    if [ "${CONTROL_CMD}" = "" ]
    then
        ERROR "CONTROL_CMD is NULL!"
        return 1
    fi

    if [ "${PRODUCT_NAME}" = "bind_cache" ]
    then
		DUMP_FILE=$(grep "dump-file" ${PRODUCT_CONFIG_DIR}/named.conf | awk -F"\"" '{print $2}')
		${CONTROL_CMD} "dumpdb" 2>/dev/null
		if [ "${DUMP_FILE}" == "" ] ;then DUMP_FILE="${PRODUCT_DIR}/named_dump.db";fi
		for((i=1;i<=10;i++));do if [ $(tail -10 ${DUMP_FILE} 2>/dev/null|grep "Dump complete"|wc -l ) -gt 0 ] ; then break; else sleep 0.5; fi; done
		cat ${DUMP_FILE}  2>/dev/null|awk -F"\t" 'BEGIN{ISANSWER=0;IGNORECASE=1;domainname="'${QUERY_DDOMAIN}'";isfind=0;temp="";view=""} {if($0=="; answer") ISANSWER=1;else if(index($0,"; ")==1) ISANSWER=0;if(index($0,"; Start ")>0){split($0,b," ");temp=b[3];if(temp=="view"){temp=b[4];}}; if(temp==view||view==""){if(index($1,";")!=1){ if($1!=""){isfind=0;if($1==domainname||$1==(domainname".")){isfind=1;if(ISANSWER==1) print temp "\t" $0;}} else{if(isfind==1) if(ISANSWER==1) print temp "\t" $0;} }}}'
    elif [ "${PRODUCT_NAME}" = "dns_cache" ] || [ "${PRODUCT_NAME}" = "dns_cache_pro" ]
    then
		for DOMAIN_TYPE in a aaaa ns cname mx soa opt ptr a6 srv ; do
		{  
			DOMAIN_RES=$(${CONTROL_CMD} "show cache entry ${QUERY_DDOMAIN} ${DOMAIN_TYPE}")  
		    flock -s 200
			echo "${DOMAIN_RES}"
		} 200>/tmp/lock_cache_query 2>/dev/null  &  
		done
		wait
		echo "`date '+%Y-%m-%d %H:%M:%S'` INFO $1" | tee -a ${MGMT_LOG_FILE} >&2
    else
        ERROR "Unknown product name: ${PRODUCT_NAME} !"
        return 1
    fi
    INFO "END ${FUNCNAME[0]}"
    return 0
}

cache_flush()
{
    INFO "BEGIN ${FUNCNAME[0]}"
    QUERY_DDOMAIN="$1"

    source_product_info
    if [ $? -ne 0 ]
    then
        ERROR "source_product_info FAILED!"
        return 1
    fi

    if [ "${CONTROL_CMD}" = "" ]
    then
        ERROR "CONTROL_CMD is NULL!"
        return 1
    fi

    if [ "${PRODUCT_NAME}" = "bind_cache" ]
    then
		if [ "${QUERY_DDOMAIN}" == "" ] ; then 
		  ${CONTROL_CMD} "flush" >&2
		else 
		  ${CONTROL_CMD} "flushname ${QUERY_DDOMAIN}" >&2
		fi
	elif [ "${PRODUCT_NAME}" = "dns_cache" ] || [ "${PRODUCT_NAME}" = "dns_cache_pro" ]
    then
		if [ "${QUERY_DDOMAIN}" == "" ] ; then 
		  ${CONTROL_CMD} "cache del_all" >&2
		else 
		  ${CONTROL_CMD} "cache delete ${QUERY_DDOMAIN}" >&2
		fi
    echo "`date '+%Y-%m-%d %H:%M:%S'` INFO $1" | tee -a ${MGMT_LOG_FILE} >&2
    else
        ERROR "Unknown product name: ${PRODUCT_NAME} !"
        return 1
    fi
    INFO "END ${FUNCNAME[0]}"
    return 0
}

set_machineid() {
    INFO "BEGIN ${FUNCNAME[0]}"

    source_product_info
    if [ $? -ne 0 ]
    then
        ERROR "source_product_info FAILED!"
        return 1
    fi

    MACHINEID=$1
    if [ "${MACHINEID}" = "" ]
    then
        ERROR "MACHINEID is NULL!"
        return 1
    fi

    #machineid saved in global_config.txt in main config directory,such as "machineid = 10"
    if [ "${PRODUCT_CONFIG_DIR}" = "" ]
    then
        ERROR "PRODUCT_CONFIG_DIR is NULL!"
        return 1
    fi

    MACHINEID_FILE="${PRODUCT_CONFIG_DIR}/global_config.txt"
    if [ ! -f ${MACHINEID_FILE} ]
    then
        INFO "${MACHINEID_FILE} doesn't exists. so create it."
    else
        # this file exists. override it.
        OLD_MACHINEID=`cat ${MACHINEID_FILE} | grep "machineid" | head -1 | awk -F"=" '{print $2}'`
        WARN "${MACHINEID_FILE} (machineid = ${OLD_MACHINEID}) exists. so override it."
    fi

    echo "machineid = ${MACHINEID}" > ${MACHINEID_FILE}
    if [ $? -ne 0 ]
    then
        ERROR "Set machineid(${MACHINEID}) in ${MACHINEID_FILE} FAILED!"
        return 1
    else
        INFO "Set machineid(${MACHINEID}) in ${MACHINEID_FILE} OK."
    fi

    INFO "END ${FUNCNAME[0]}"
    return 0
}

start()
{
    INFO "BEGIN ${FUNCNAME[0]}"

    source_product_info
    if [ $? -ne 0 ]
    then
        ERROR "source_product_info FAILED!"
        return 1
    fi

    #check the current status
    get_status
    if [ ${STATUS} = "running" ]
    then
        WARN "${PRODUCT_NAME} has alrealy been running!"
        return 0
    fi

    # check whether the start shell exists.

    START_SHELL=${MGMT_DIR}/bin/start_server.sh
    if [ ! -f ${START_SHELL} ]
    then
        # the start shell not exists, we try to create it.
        if [ "${PRODUCT_NAME}" = "bind_cache" ]
        then
            SERVER_PROGRAM_FILE=${PRODUCT_DIR}/sbin/named
            if [ -f ${SERVER_PROGRAM_FILE} ]
            then
                echo "echo \"\`date\` Begin start the server... \""  > ${START_SHELL}
                echo "${SERVER_PROGRAM_FILE} -5" >> ${START_SHELL}
            else
                ERROR "${SERVER_PROGRAM_FILE} doesn't exists!"
                return 1
            fi
        elif [ "${PRODUCT_NAME}" = "dns_cache" ] || [ "${PRODUCT_NAME}" = "dns_cache_pro" ]
        then
            INNER_START_FILE=${PRODUCT_DIR}/bin/start.sh
            if [ -f ${INNER_START_FILE} ]
            then
                # we use the product start shell if exists.
                echo "echo \"\`date\` Begin start the server... \""  > ${START_SHELL}
                echo "cd ${PRODUCT_DIR}/bin; sh start.sh" >> ${START_SHELL}
            else
                SERVER_PROGRAM_FILE=${PRODUCT_DIR}/bin/${PRODUCT_NAME}
                if [ -f ${SERVER_PROGRAM_FILE} ]
                then
                    echo "echo \"\`date\` Begin start the server... \""  > ${START_SHELL}
                    echo "cd ${PRODUCT_DIR}/bin; ./${PRODUCT_NAME} &" >> ${START_SHELL}
                else
                    ERROR "${SERVER_PROGRAM_FILE} doesn't exists!"
                    return 1
                fi
            fi
        fi
    fi

    # begin to run the start shell
    cd ${MGMT_DIR}/bin
    sh ${START_SHELL} > ${MGMT_LOG_DIR}/start_server.log 2>&1
    if [ $? -ne 0 ]
    then
        ERROR "run start shell FAILED!"
    else
        INFO "run start shell OK!"
    fi
    
    #wait for a while
    sleep 3

    #check the status again
    get_status
    if [ ${STATUS} != "running" ]
    then
        ERROR "${PRODUCT_NAME}'s status is still not running after start! Some error must happened!"
        return 1
    fi

    INFO "END ${FUNCNAME[0]}"
    return 0
}

stop() {
    INFO "BEGIN ${FUNCNAME[0]}"

    source_product_info
    if [ $? -ne 0 ]
    then
        ERROR "source_product_info FAILED!"
        return 1
    fi

    #check the current status
    get_status
    if [ ${STATUS} = "stopped" ]
    then
        WARN "${PRODUCT_NAME} has alrealy been stopped!"
        return 0
    fi

    # check whether the stop shell exists.
    STOP_SHELL=${MGMT_DIR}/bin/stop_server.sh
    if [ ! -f ${STOP_SHELL} ]
    then
        INNER_STOP_FILE=${PRODUCT_DIR}/bin/stop.sh
        if [ -f ${INNER_STOP_FILE} ]
        then
            # we use the product stop shell if exists.
            echo "cd ${PRODUCT_DIR}/bin; sh stop.sh" > ${STOP_SHELL}
        else
            if [ "${PRODUCT_NAME}" = "bind_cache" ]
            then
                SERVER_NAME=named
            elif [ "${PRODUCT_NAME}" = "dns_cache" ] || [ "${PRODUCT_NAME}" = "dns_cache_pro" ]
            then
                SERVER_NAME="${PRODUCT_NAME}"
            else
                ERROR "Unknown product name(${PRODUCT_NAME})"
                return 1
            fi
            echo "echo \"\`date\` Begin stop the server... \""  > ${STOP_SHELL}
            echo "SERVER_NAME=${SERVER_NAME}" >> ${STOP_SHELL}
            echo "SERVER_PID=\`ps -u \${LOGNAME} | grep \${SERVER_NAME} | grep -v \"grep\" | awk '{print \$1}' | head -1\`"  >> ${STOP_SHELL}
            echo "if [ \"\${SERVER_PID}\" = \"\" ]"  >> ${STOP_SHELL}
            echo "then" >> ${STOP_SHELL}
            echo "echo \"\`date\` \${SERVER_NAME} is not running.\""  >> ${STOP_SHELL}
            echo "else" >> ${STOP_SHELL}
            echo "echo \"\`date\` Killing the server: pid(\${SERVER_PID}) !\"" >> ${STOP_SHELL}
            echo "kill -9 \${SERVER_PID}" >> ${STOP_SHELL}
            echo "fi" >> ${STOP_SHELL}
        fi
    fi

    # begin to run the stop shell
    cd ${MGMT_DIR}/bin
    sh ${STOP_SHELL} > ${MGMT_LOG_DIR}/stop_server.log 2>&1
    if [ $? -ne 0 ]
    then
        ERROR "run stop shell FAILED!"
    else
        INFO "run stop shell OK!"
    fi
    
    #wait for a while
    sleep 3

    #check the status again
    get_status
    if [ ${STATUS} = "running" ]
    then
        ERROR "${PRODUCT_NAME}'s status is still running after stop! Some error must happened!"
        return 1
    fi

    INFO "END ${FUNCNAME[0]}"
    return 0
}

get_status()
{
    INFO "BEGIN ${FUNCNAME[0]}"

    STATUS="unknown"

    source_product_info
    if [ $? -ne 0 ]
    then
        ERROR "source_product_info FAILED!"
    fi

    if [ "${CONTROL_CMD}" = "" ]
    then
        ERROR "CONTROL_CMD is NULL!"
    fi

    
    if [ "${PRODUCT_NAME}" = "bind_cache" ]
    then
        RUNNING_FLAG=`${CONTROL_CMD} "status" 2>&1 | grep "server is up and running" | wc -l`
    elif [ "${PRODUCT_NAME}" = "dns_cache" ] || [ "${PRODUCT_NAME}" = "dns_cache_pro" ]
    then
        RUNNING_FLAG=`${CONTROL_CMD} "show cli" 2>&1 | grep "ip-address" | wc -l`
    else
        ERROR "Unknown product ${PRODUCT_NAME}!"
    fi

    if [ ${RUNNING_FLAG} -lt 1 ]
    then
        INFO "${PRODUCT_NAME} is not running."
        STATUS="stopped"
    else
        INFO "${PRODUCT_NAME} is running."
        STATUS="running"
    fi

    INFO "END ${FUNCNAME[0]}"
    return 0
}

status()
{
    INFO "BEGIN ${FUNCNAME[0]}"
    
    get_status
    echo "STATUS=${STATUS}"
    
    INFO "END ${FUNCNAME[0]}"
    return 0
}


run_control_command()
{
    INFO "BEGIN ${FUNCNAME[0]}"

    source_product_info
    if [ $? -ne 0 ]
    then
        ERROR "source_product_info FAILED!"
        return 1
    fi

    if [ "${CONTROL_CMD}" = "" ]
    then
        ERROR "CONTROL_CMD is NULL!"
        return 1
    fi

    ${CONTROL_CMD} "${1}"
    if [ $? -ne 0 ]
    then
        ERROR "Run control command: ${1} FAILED!"
    else
        INFO "Run control command: ${1} OK!"
    fi

    INFO "END ${FUNCNAME[0]}"
    return 0
}

run_os_command()
{
    INFO "BEGIN ${FUNCNAME[0]}"

    OS_CMD_SHELL=${MGMT_DIR}/bin/os_cmd.sh
    echo "$1" > ${OS_CMD_SHELL}
    sh ${OS_CMD_SHELL}
    if [ $? -ne 0 ]
    then
        ERROR "Run OS command: ${OS_CMD} FAILED!"
    else
        INFO "Run OS command: ${OS_CMD} OK!"
    fi

    INFO "END ${FUNCNAME[0]}"
    return 0
}

run_plugin()
{
    INFO "BEGIN ${FUNCNAME[0]}"

    PLUGIN_SHELL=$1
    PLUGIN_DIR=${MGMT_DIR}/plugins
    if [ ! -f ${PLUGIN_DIR}/${PLUGIN_SHELL} ]
    then
        ERROR "plugin ${PLUGIN_SHELL} not found!"
        return 1
    fi
    
    cd ${PLUGIN_DIR}    
    sh ${PLUGIN_SHELL}
    if [ $? -ne 0 ]
    then
        ERROR "Run plugin: ${PLUGIN_SHELL} FAILED!"
        return 1
    else
        INFO "Run plugin: ${PLUGIN_SHELL} OK!"
    fi

    INFO "END ${FUNCNAME[0]}"
    return 0
}

start_route()
{
    INFO "BEGIN ${FUNCNAME[0]}"

    source_product_info
    if [ $? -ne 0 ]
    then
        ERROR "source_product_info FAILED!"
        return 1
    fi
    
    #check zebra deamon file
    ZEBRA_DEAMON=""
    for P in "/usr/sbin/zebra" "/usr/local/sbin/zebra"
    do
        if [ -f ${P} ]
        then 
            ZEBRA_DEAMON=${P}
            break
        fi
    done
    if [ "${ZEBRA_DEAMON}" = "" ]
    then
        ERROR "Can't find the zebra deamon file."
        return 1
    fi

    RUNNING_FLAG=`ps -ef | grep "zebra -d" | grep -v "grep" | wc -l`
    if [ ${RUNNING_FLAG} -gt 0 ]
    then
        WARN "zebra is already running."
    else
        #start zebra
        ${ZEBRA_DEAMON} -d
        if [ $? -ne 0 ]
        then
            ERROR "run ${ZEBRA_DEAMON} FAILED!"
            return 1
        else
            INFO "run ${ZEBRA_DEAMON} OK!"
        fi
    fi
    
    #check ospfd deamon file
    OSPFD_DEAMON=""
    for P in "/usr/sbin/ospfd" "/usr/local/sbin/ospfd"
    do
        if [ -f ${P} ]
        then 
            OSPFD_DEAMON=${P}
            break
        fi
    done
    if [ "${OSPFD_DEAMON}" = "" ]
    then
        ERROR "Can't find the ospfd deamon file."
        return 1
    fi

    RUNNING_FLAG=`ps -ef | grep "ospfd -d" | grep -v "grep" | wc -l`
    if [ ${RUNNING_FLAG} -gt 0 ]
    then
        WARN "ospfd is already running."
    else
        #start ospfd
        ${OSPFD_DEAMON} -d
        if [ $? -ne 0 ]
        then
            ERROR "run ${OSPFD_DEAMON} FAILED!"
            return 1
        else
            INFO "run ${OSPFD_DEAMON} OK!"
        fi
    fi

    INFO "END ${FUNCNAME[0]}"
    return 0
}

stop_route()
{
    INFO "BEGIN ${FUNCNAME[0]}"

    source_product_info
    if [ $? -ne 0 ]
    then
        ERROR "source_product_info FAILED!"
        return 1
    fi
    
    #stop zebra deamon
    ZEBRA_PID=`ps -ef | grep "zebra -d" | grep -v "grep" | head -1 | awk '{print $2}' `
    if [ "${ZEBRA_PID}" = "" ]
    then
        WARN "zebra is not running!"
    else
        INFO "kill zebra(pid:${ZEBRA_PID}"
        kill -9 ${ZEBRA_PID}
    fi

    #stop ospfd deamon
    OSPFD_PID=`ps -ef | grep "ospfd -d" | grep -v "grep" | head -1 | awk '{print $2}' `
    if [ "${OSPFD_PID}" = "" ]
    then
        WARN "ospfd is not running!"
    else
        INFO "kill ospfd(pid:${OSPFD_PID}"
        kill -9 ${OSPFD_PID}
    fi

    INFO "END ${FUNCNAME[0]}"
    return 0
}

route_status()
{
    INFO "BEGIN ${FUNCNAME[0]}"

    ROUTE_STATUS="unknown"

    RUNNING_FLAG=`ps -ef | grep "zebra -d" | grep -v "grep" | wc -l`
    if [ ${RUNNING_FLAG} -gt 0 ]
    then
        INFO "zebra is running."
        ZEBRA_RUNNING="1"
    else
        INFO "zebra is not running."
        ZEBRA_RUNNING="0"
    fi
    
    RUNNING_FLAG=`ps -ef | grep "ospfd -d" | grep -v "grep" | wc -l`
    if [ ${RUNNING_FLAG} -gt 0 ]
    then
        INFO "ospfd is running."
        OSPFD_RUNNING="1"
    else
        INFO "ospfd is not running."
        OSPFD_RUNNING="0"
    fi
    
    if [ "${ZEBRA_RUNNING}" = "1" ] && [ "${OSPFD_RUNNING}" = "1" ]
    then
        ROUTE_STATUS="running"
    else
        ROUTE_STATUS="stopped"
    fi
    
    echo "ROUTE_STATUS=${ROUTE_STATUS}"

    INFO "END ${FUNCNAME[0]}"
    return 0
}


INIT()
{
#should run as root (sudo)
if [ ${LOGNAME} != "root" ]
then
    ERROR "Must run this shell as root!"
    return 1
fi

#MGMT_DIR=`dirname $0`
#MGMT_DIR=`cd ${MGMT_DIR}; pwd`
MGMT_DIR="$( cd "$( dirname "$0"  )" && cd .. && pwd  )"
MGMT_LOG_DIR=${MGMT_DIR}/log
MGMT_LOG_FILE=${MGMT_LOG_DIR}/manage.log

MGMT_ETC_DIR=${MGMT_DIR}/etc
PRODUCT_INFO_FILE=${MGMT_ETC_DIR}/productinfo.cfg

cd ${MGMT_DIR}
if [ $? -ne 0 ]
then
    ERROR "Can't cd ${MGMT_DIR}!"
    return 1
fi

# source enviroments
CFG_FILE=${MGMT_ETC_DIR}/manage.cfg
if [ ! -f ${CFG_FILE} ]
then
    ERROR "${CFG_FILE} does not exists!"
    return 1
fi
. ${CFG_FILE}

return 0
}

###################################################################
# program starts here

SHELL_CMD="$0 $* (pid:$$)"
INFO "------------------------------------------------------------"
INFO "running: ${SHELL_CMD}"

RETVAL=0

LANG=C
export LANG

INIT
if [ $? -ne 0 ]
then
    ERROR "Init failed!"
    RETVAL=1
else
    case "$1" in
        get_system_info)
                get_system_info || RETVAL=$?
                ;;
        product_auto_check)
                product_auto_check || RETVAL=$?
                ;;
        get_product_info)
                get_product_info || RETVAL=$?
                ;;
        set_machineid)
                set_machineid $2 || RETVAL=$?
                ;;
        update_config)
                update_config $2 || RETVAL=$?
                ;;
        reload_config)
                reload_config || RETVAL=$?
                ;;
        update_config)
                update_config $2 || RETVAL=$?
                ;;
        cache_query)
                cache_query $2 || RETVAL=$?
                ;;
        cache_flush)
                cache_flush $2 || RETVAL=$?
                ;;
        start)
                start || RETVAL=$?
                ;;
        stop)
                stop || RETVAL=$?
                ;;
        status)
                status || RETVAL=$?
                ;;
        start_route)
                start_route || RETVAL=$?
                ;;
        stop_route)
                stop_route || RETVAL=$?
                ;;
        route_status)
                route_status || RETVAL=$?
                ;;
        run_control_command)
                run_control_command "$2" || RETVAL=$?
                ;;
        run_os_command)
                run_os_command "$2" || RETVAL=$?
                ;;
        run_plugin)
                run_plugin "$2" || RETVAL=$?
                ;;
        *)
                ERROR "unknown management action!"
                USAGE
                RETVAL=2
    esac
fi

if [ ${RETVAL} -eq 0 ]
then
INFO "EXEC SUCCESS: ${SHELL_CMD}"
else
ERROR "RETVAL=${RETVAL}"
ERROR "EXEC FAILED: ${SHELL_CMD}"
fi
INFO "============================================================"
exit ${RETVAL}
