#!/bin/bash

################################################################
#autho:guofei
#接口入库主程序
#程序说明
#定时扫描接口子程序目录，后台线程超过10个就不在启动新的线程
################################################################


cd `dirname $0`
PRO_DIR=`pwd`
LGO_DIR=${PRO_DIR}/log
PRO_CHILD_DIR=${PRO_DIR}/pro_child
PRO_MAIN_DIR=${PRO_DIR}/pro_main

ls ${PRO_CHILD_DIR}/*_sh > ${PRO_DIR}/running_child_pro
if [ ! -s ${PRO_DIR}/running_child_pro ];then
rm ${PRO_DIR}/running_child_pro
exit 0
fi
#扫描后台进程，不足10个启动新的子程序
CHILD_THREAD_COUNT=`cat ${PRO_DIR}/running_child_pro|wc -l`
CUR_THREAD_COUNT=`ls ${PRO_MAIN_DIR}/*_sh|wc -l`
MAX_THREAD_COUNT=10
while [ $CUR_THREAD_COUNT -lt $MAX_THREAD_COUNT ]
do
  if [ $CHILD_THREAD_COUNT -gt 0 ];then
  PRO_CHILD_PATH=`sed -n '1,1p' ${PRO_DIR}/running_child_pro`
  PRO_CHILD=${PRO_CHILD_PATH##*/}
  #为了避免移动目录，所以直接进入目录后移动文件
  cd ${PRO_CHILD_DIR}
  mv ${PRO_CHILD} ${PRO_MAIN_DIR}/
  PRO_CHILD_CYCLE=${PRO_CHILD%_*}
  LOG_FILE=${PRO_CHILD_CYCLE%_*}_log_`date +%F`
  chmod 770 ${PRO_MAIN_DIR}/${PRO_CHILD}
  #echo "nohup sh -x  ${PRO_MAIN_DIR}/${PRO_CHILD} >>${LGO_DIR}/${LOG_FILE} 2>&1 &"
  nohup sh -x  ${PRO_MAIN_DIR}/${PRO_CHILD} &
  sed -i '1d' ${PRO_DIR}/running_child_pro
  fi
  CUR_THREAD_COUNT=`expr $CUR_THREAD_COUNT + 1`
  CHILD_THREAD_COUNT=`cat ${PRO_DIR}/running_child_pro|wc -l`
done
rm ${PRO_DIR}/running_child_pro