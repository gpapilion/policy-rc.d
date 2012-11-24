#!/bin/bash 
# Author: Geoffrey Papilion
# License: GPLv2
#  
# update-policy-rc.d [--set|--set-system-default|--del|--del-system-default] [<init-id>] 
#                    [enable|disable]
#
# Simple script to update policy-rc.d setting for matchin /usr/sbin/policy-rc.d script.
#
# usage examples: 
#  Disable invoke-rc.d apache2: 
#        update-policy-rc.d --set apache2 disable
#
#  Enable invoke-rc.d apache2: 
#        update-policy-rc.d --set apache2 enable
#
#  Disable invoke-rc.d from starting daemons: 
#        update-policy-rc.d --set-system-default disable
#
#  Remove system wide default config: 
#        update-policy-rc.d --del-system-default   
 

POLICY_PATH=/etc/policy-rc.d

check_status(){
  if [ "$1" == "enable" ]; then
     STATUS=0
  elif [ "$1" == "disable" ]; then
     STATUS=101
  else 
    echo "error: use enable or disable"
    exit -1
  fi
}

if [ "$1" == "--set" ]; then
  shift;
  INIT_ID=$1; 
  shift; 
  check_status $1
  shift
  mkdir -p $POLICY_PATH/$INIT_ID
  echo $STATUS > $POLICY_PATH/$INIT_ID/default-policy
elif [ "$1" == "--set-system-default" ]; then
  shift; 
  check_status $1
  shift
  mkdir -p $POLICY_PATH/default-policy
  echo $STATUS > $POLICY_PATH/default-policy/default-policy
elif [ "$1" == "--del" ]; then
  shift;
  INIT_ID=$1; 
  shift; 
  rm $POLICY_PATH/$INIT_ID/default-policy
elif [ "$1" == "--del-system-default" ]; then
  shift;
  INIT_ID=$1; 
  shift; 
  rm $POLICY_PATH/default-policy/default-policy
fi
