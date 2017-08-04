#!/bin/bash -x

# enable dbus
mkdir /run/dbus
dbus-daemon --system

# iscsi vars
[ -z ${TARGET_NAME} ] && TARGET_NAME='iqn.2016-04.test.home:storage.target00'
[ -z ${ACL_IQN} ] && ACL_IQN='iqn.2016-04.test.com:test'

DISKID=1
if [ -z ${DEVS} ] ; then

  mkdir /iscsi_disks

  for dev in /iscsi_disks/disk01.img /iscsi_disks/disk02.img do

    targetcli /backstores/fileio create disk${DISKID} ${dev} 2G
    DISKS="$DISKS /backstores/fileio/${DISKID}"
    DISKID=$((DISKID+1))

  done

else

  for dev in ${DEVS}; do

    targetcli /backstores/block create disk${DISKID} ${dev}
    DISKS="$DISKS /backstores/block/${DISKID}"
    DISKID=$((DISKID+1))

  done

fi

# Create iscsi target
targetcli /iscsi create ${TARGET_NAME}
# Set IP address of the target
targetcli /iscsi/${TARGET_NAME}/tpg1/portals delete 0.0.0.0 3260
targetcli /iscsi/${TARGET_NAME}/tpg1/portals create `hostname -i`
# Set LUN
for disk in $DISKS; do
  targetcli /iscsi/${TARGET_NAME}/tpg1/luns create $disk
done 

# Set ACL
targetcli /iscsi/${TARGET_NAME}/tpg1/acls create ${ACL_IQN}
targetcli ls

# Set auth
#AUTH_USER_ID=5f84cec2
#AUTH_PASSWORD=b0d324e9
#targetcli /iscsi/${TARGET_NAME}/tpg1/acls/${ACL_IQN} set auth userid=${AUTH_USER_ID}
#targetcli /iscsi/${TARGET_NAME}/tpg1/acls/${ACL_IQN} set auth password=${AUTH_PASSWORD}
echo "** iscsi target initialised **"
echo "------------------------------------------------------------------------"

while true
do
    date
    targetcli sessions list
    sleep 30
done
