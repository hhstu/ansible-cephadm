#!/usr/bin/env bash
#--------------------------------------------
#ping keepalived VIP, restart keepalived if failed, and record the restart record
#--------------------------------------------

VIP={{ groups['vip'][0] }}
#example
#VIP="172.16.244.100"

LOGFILE=/var/log/keepalived_probe.log
LOGFILE_MAXSIZE=1000
LOGFILE_RETAIN_DAY=1

function probe(){
# try 2 time,deadline 2s
  ping -c 1 -w 1 ${VIP} >/dev/null 2>&1
  if [[ $? != 0 ]];then
    echo "`date +%Y-%m-%d_%H:%M:%S` can not connect vip ${VIP},restart keepalived" >> $LOGFILE
    systemctl restart keepalived
  fi
}
function limit_log(){
  if [[ ! -f "$LOGFILE" ]];then
    touch $LOGFILE
  else
    linecount=`wc -l $LOGFILE|awk '{print $1}'`
    #echo $linecount
    if [ ${linecount} -gt ${LOGFILE_MAXSIZE} ];then
      #echo $LOGFILE".`date +%Y-%m-%d_%H:%M:%S`"
      cp $LOGFILE $LOGFILE".`date +%Y-%m-%d_%H:%M:%S`".log
      echo "" > $LOGFILE
    fi
  fi
  find /var/log/keepalived_probe.log.* -type f -ctime +${LOGFILE_RETAIN_DAY} -delete >/dev/null 2>&1
}
limit_log
probe
