#!/bin/env bash
#
export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin

# 将需要控制的后端IP进行定义
# 使用方式 offline.sh [1|2|all] [start|stop|status] 
# [1|2|all] 控制具体哪个后端IP
M1_1="192.168.0.46"
M1_2="192.168.0.44"
method=$2

CONF_DIR=/usr/local/nginx/conf/
#set_array=(page_m1 api_m1 contact_m1 edmapi_m1 m1api_m1 pageapi_m1 v1_m1api_m1)
set_array=(nginx)
#set_array=(page_m1)

check_OK () {
    if [ $1 == 0 ];then
        echo "$ADDR $2 OK"
    else
        echo "$ADDR $2 fail"
    fi
}

Control () {
case $1 in
start)
    grep "#${ADDR}" ${CONF_DIR}$2 &> /dev/null
    if [ $? != 0 ];then
        echo "${ADDR} $2 aleady online"
        return 44
    fi
    sed -i "s/#${ADDR}/${ADDR}/" ${CONF_DIR}$2
    check_OK $? start && /usr/local/nginx/sbin/nginx -s reload
    ;;
stop)
    grep "#${ADDR}" ${CONF_DIR}$2 &> /dev/null
    if [ $? = 0 ];then
        echo "${ADDR} $2 aleady offline"
        return 55
    fi
    sed -i "s/${ADDR}/#${ADDR}/" ${CONF_DIR}$2
    check_OK $? stop && /usr/local/nginx/sbin/nginx -s reload
    ;;
status)
    grep "#${ADDR}" ${CONF_DIR}$2 &> /dev/null
    if [ $? == 0 ];then
        echo "$ADDR $2 is offline"
    else
        echo "$ADDR $2 is online"
    fi
    ;;
*)
    echo "Usage: You must input [start|stop|status]"
    esac
}

for element in ${set_array[@]};do
    element=${element}.conf
    case $1 in
    1)
        ADDR="server $M1_1"
        Control $method $element
        ;;
    2)
        ADDR="server $M1_2"
        Control $method $element
        ;;
    all)
        for ADDR in "server $M1_1" "server $M1_2";do
            Control $method $element 
        done
        ;;
    *)
        echo "    Error: The Usage is offline.sh [1|2|all] [start|stop|status]"
        exit 5
    esac
done
