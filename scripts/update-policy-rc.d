#!/bin/bash 
# Author: Geoffrey Papilion
# License: GPLv2
#  
# update-policy-rc.d [--set|--set-system-default|--del|--del-system-default] [<init-id>] 
#                    [enable|disable]
#
# Simple script to update policy-rc.d setting for matching /usr/sbin/policy-rc.d script.
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

case $1 in
"--set")
  shift;
  INIT_ID=$1; 
  shift; 
  check_status $1
  shift
  mkdir -p $POLICY_PATH/$INIT_ID
  echo $STATUS > $POLICY_PATH/$INIT_ID/default-policy
  ;;

"--set-ssytem-default")
  shift; 
  check_status $1
  shift
  mkdir -p $POLICY_PATH/default-policy
  echo $STATUS > $POLICY_PATH/default-policy/default-policy
  ;;

"--del")
  shift;
  INIT_ID=$1; 
  shift; 
  rm $POLICY_PATH/$INIT_ID/default-policy
  ;;

"--del-system-default")
  shift;
  INIT_ID=$1; 
  shift; 
  rm $POLICY_PATH/default-policy/default-policy
  ;;

*)
  echo " update-policy-rc.d [--set|--set-system-default|--del|--del-system-default] [<init-id>] "
  echo "                    [enable|disable]"
  echo ""
  echo " Simple script to update policy-rc.d setting for matching /usr/sbin/policy-rc.d script."
  echo ""
  echo " usage examples: "
  echo "  Disable invoke-rc.d apache2: "
  echo "        update-policy-rc.d --set apache2 disable"
  echo ""
  echo "  Enable invoke-rc.d apache2: "
  echo "        update-policy-rc.d --set apache2 enable"
  echo ""
  echo "  Disable invoke-rc.d from starting daemons: "
  echo "        update-policy-rc.d --set-system-default disable"
  echo ""
  echo "  Remove system wide default config: "
  echo "        update-policy-rc.d --del-system-default   "
  echo ""
  ;;

esac

