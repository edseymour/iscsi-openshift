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


USAGE="$0 <volume size> <start LUN> <stop LUN>"

MAVENURL=$2
check_exists "Maven repository URL, $USAGE" $MAVENURL

SIZE=$1
check_exists "Size, $USAGE" $SIZE
LUNSTART=$2
check_exists "Start LUN, $USAGE" $LUNSTART
LUNSTOP=$3
check_exists "Stop LUN, $USAGE" $LUNSTOP

for lun in $(seq $LUNSTART $LUNSTOP); do

sed 's/%size/'$SIZE'/g' iscsi-pv-template.yaml | sed 's/%lun/'$lun'/g' | oc create -f -

done
