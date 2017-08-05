#!/bin/bash

function check_exists()
{
  [[ "$2" == "" ]] && echo "Missing $1" && exit 1
}

function default_if_empty()
{
  if [[ "$2" == "" ]]; then 
    echo $1
  else
    echo $2
  fi
}


USAGE="$0 <portal> <target iqn> <volume size> <start LUN> <stop LUN>"

PORTAL=$1
check_exists "Portal, $USAGE" $PORTAL
IQN=$2
check_exists "Target IQN, $USAGE" $IQN
SIZE=$3
check_exists "Size, $USAGE" $SIZE
LUNSTART=$4
check_exists "Start LUN, $USAGE" $LUNSTART
LUNSTOP=$5
check_exists "Stop LUN, $USAGE" $LUNSTOP

for lun in $(seq $LUNSTART $LUNSTOP); do

  oc process -f iscsi-pv-template.yaml PORTAL=$PORTAL IQN=$IQN LUN=$lun SIZE=$SIZE | oc create -f -

done
