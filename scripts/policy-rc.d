#!/bin/bash
# Author: Geoffrey Papilion (papilion@hypergeometric.com)
# License: GPLv2 (http://www.gnu.org/licenses/gpl-2.0.html)
# 
# policy-rc.d [options] --quiet <initscript> <actions> [<runlevels>]
#
# A script that should comply to the /usr/sbin/policy-rc.d for management
# of package restarts in debian and ubuntu systems
# 
# The script assumes you can define policies in /etc/policy-rc.d/<init-id>/<run-level>/<action>
# This script chooses the most specfic policy first, and policy is evaulated in
# the following order: 
#  <initd-id>/<run-level>/<action>
#  <initd-id>/<action>
#  <initd-id>/<run-level>/default-policy
#  <initd-id>/default-policy
#  action-<action>/<run-level>/default-policy
#  action-<action>/default-policy
#  default-policy/<run-level>/default-policy
#  default-policy/default-policy
#  $DEFAULT_STATUS (defined in script)
#
# --list will produce the exit status for a given id for each run-level and action. 

set -e

POLICY_LOCATION="/etc/policy-rc.d"
DEFAULT_STATUS=0;
LIST=1;
QUIET=1;

POSITION_COUNT="0"
for ARG in $@; do
  case "$ARG" in 
  "--quiet")
    if [ $POSITION_COUNT -ge 2 ]; then
      echo "--quiet needs to be 1st or 2nd argument"
      exit 103
    fi
    QUIET="0";
    shift;
  ;;

  "--list")
    if [ $POSITION_COUNT -ge 2 ]; then
      echo "--list needs to be 1st or 2nd argument"
      exit 103
    fi
    LIST="0"
    shift
  ;;
  esac
  POSITION_COUNT=$(($POSITION_COUNT+1)) 

done

# ONLY ONE INITSCRIPT IS ALLOWED AT A TIME
INIT_SCRIPT=$1;

# actions are only passed without the list option
# ACTIONS ARE SUPPOSEDLY PASSED AS A SINGLE ARGUMENT
if [ "$LIST" -eq "1" ]; then
  ACTIONS=$2
  # SHIFTING 2 
  shift 2;
else 
  shift;
fi

# find runlevels
while [ $# -gt 0 ]; do
   case "$1" in 

   "0") 
     RUN_LEVELS="$RUN_LEVELS $1" 
   ;;

   "1") 
     RUN_LEVELS="$RUN_LEVELS $1" 
   ;;

   "2") 
     RUN_LEVELS="$RUN_LEVELS $1" 
   ;;

   "3") 
     RUN_LEVELS="$RUN_LEVELS $1" 
   ;;

   "4") 
     RUN_LEVELS="$RUN_LEVELS $1" 
   ;;

   "5") 
     RUN_LEVELS="$RUN_LEVELS $1" 
   ;;

   "6") 
     RUN_LEVELS="$RUN_LEVELS $1" 
   ;;

   "S") 
     RUN_LEVELS="$RUN_LEVELS $1" 
   ;;

   # NOT REQUIRED BUT BEING DEFENSIVE 
   "start")
     ACTIONS="$ACTIONS $1"
   ;;

   "restart")
     ACTIONS="$ACTIONS $1"
   ;;

   "force-start")
     ACTIONS="$ACTIONS $1"
   ;;

   "stop")
     ACTIONS="$ACTIONS $1"
   ;;

   "force-stop")
     ACTIONS="$ACTIONS $1"
   ;;

   "("*")")
     ACTIONS="$ACTIONS $1"
   ;;

   esac
  shift;
done


list_policy(){
  if [ -z $RUN_LEVELS ]; then
     RUN_LEVELS="1 2 3 4 5 6 S"
  fi
  for RUNLEVEL in $RUN_LEVELS; do
    ACTIONS="start stop restart force-stop force-start (start) (stop) (restart)"
    for ACTION in $ACTIONS; do
      if [ -e "$POLICY_LOCATION/$INIT_SCRIPT/$RUNLEVEL/$ACTION" ]; then 
         POLICY_IS=$(cat $POLICY_LOCATION/$INIT_SCRIPT/$RUNLEVEL/$ACTION)
      elif [ -e "$POLICY_LOCATION/$INIT_SCRIPT/$ACTION" ]; then 
         POLICY_IS=$(cat $POLICY_LOCATION/$INIT_SCRIPT/$ACTION)
      elif [ -e "$POLICY_LOCATION/$INIT_SCRIPT/$RUNLEVEL/default-policy" ]; then
         POLICY_IS=$(cat $POLICY_LOCATION/$INIT_SCRIPT/$RUNLEVEL/default-policy)
      elif [ -e "$POLICY_LOCATION/$INIT_SCRIPT/default-policy" ]; then
         POLICY_IS=$(cat $POLICY_LOCATION/$INIT_SCRIPT/default-policy)
      elif [ -e "$POLICY_LOCATION/action-$ACTION/$RUNLEVEL/default-policy" ]; then 
         POLICY_IS=$(cat $POLICY_LOCATION/action-$ACTION/$RUNLEVEL/default-policy)
      elif [ -e "$POLICY_LOCATION/action-$ACTION/default-policy" ]; then 
         POLICY_IS=$(cat $POLICY_LOCATION/action-$ACTION/default-policy)
      elif [ -e "$POLICY_LOCATION/default-policy/$RUNLEVEL/default-policy" ]; then
         POLICY_IS=$(cat $POLICY_LOCATION/default-policy/$RUNLEVEL/default-policy)
      elif [ -e "$POLICY_LOCATION/default-policy/default-policy" ]; then
         POLICY_IS=$(cat $POLICY_LOCATION/default-policy/default-policy)
      else 
         POLICY_IS=$DEFAULT_STATUS
      fi
      echo "$INIT_SCRIPT:${RUNLEVEL}:$ACTION:$POLICY_IS" 
    done
  done
}


should_run(){

  RETURN_CODE="$DEFAULT_STATUS"

  for ACTION in $ACTIONS; do

    # Use current run level

    if [ -z "$RUN_LEVELS" ] ; then
     RUN_LEVELS=$(runlevel |awk '{print $2}') 
    fi
    
    for RUNLEVEL in $RUN_LEVELS; do 
      if [ -e "$POLICY_LOCATION/$INIT_SCRIPT/$RUNLEVEL/$ACTION" ]; then 
         TMP_RETURN=$(cat $POLICY_LOCATION/$INIT_SCRIPT/$RUNLEVEL/$ACTION)
         RETURN_CODES="$RETURN_CODES $TMP_RETURN"
      elif [ -e "$POLICY_LOCATION/$INIT_SCRIPT/$ACTION" ]; then 
         TMP_RETURN=$(cat $POLICY_LOCATION/$INIT_SCRIPT/$ACTION)
         RETURN_CODES="$RETURN_CODES $TMP_RETURN"
      elif [ -e "$POLICY_LOCATION/$INIT_SCRIPT/$RUNLEVEL/default-policy" ]; then
         TMP_RETURN=$(cat $POLICY_LOCATION/$INIT_SCRIPT/$RUNLEVEL/default-policy)
         RETURN_CODES="$RETURN_CODES $TMP_RETURN"
      elif [ -e "$POLICY_LOCATION/$INIT_SCRIPT/default-policy" ]; then
         TMP_RETURN=$(cat $POLICY_LOCATION/$INIT_SCRIPT/default-policy)
         RETURN_CODES="$RETURN_CODES $TMP_RETURN"
      elif [ -e "$POLICY_LOCATION/action-$ACTION/$RUNLEVEL/default-policy" ]; then 
         TMP_RETURN=$(cat $POLICY_LOCATION/action-$ACTION/$RUNLEVEL/default-policy)
         RETURN_CODES="$RETURN_CODES $TMP_RETURN"
      elif [ -e "$POLICY_LOCATION/action-$ACTION/default-policy" ]; then 
         TMP_RETURN=$(cat $POLICY_LOCATION/action-$ACTION/default-policy)
         RETURN_CODES="$RETURN_CODES $TMP_RETURN"
      elif [ -e "$POLICY_LOCATION/default-policy/$RUNLEVEL/default-policy" ]; then
         TMP_RETURN=$(cat $POLICY_LOCATION/default-policy/$RUNLEVEL/default-policy)
         RETURN_CODES="$RETURN_CODES $TMP_RETURN"
      elif [ -e "$POLICY_LOCATION/default-policy/default-policy" ]; then
         TMP_RETURN=$(cat $POLICY_LOCATION/default-policy/default-policy)
         RETURN_CODES="$RETURN_CODES $TMP_RETURN"
      fi
    done

  done 
  
  # The highest code wins if multiple actions are specified 
  for CODE in $RETURN_CODES; do

    if [ -z "$RETURN" ]; then
       RETURN="$CODE"
    fi 
 
    if [ "$CODE" -gt "$RETURN" ]; then
       RETURN="$CODE"
    fi

  done 
  
  return $RETURN

}

if [ "$LIST" -eq "0" ]; then
  list_policy
else
 exit $(should_run)
fi
