#!/bin/bash 

# iscsi vars
[ -z "${TARGET_NAME}" ] && TARGET_NAME='iqn.2016-04.test.home:storage.target00'

# remove portals
for portal in $(targetcli ls /iscsi/${TARGET_NAME}/tpg1/portals | tail -n +2 | awk '{print $2}'); do
   targetcli /iscsi/${TARGET_NAME}/tpg1/portals delete ${portal%:*} ${portal##*:}
done

for acl in $(targetcli ls /iscsi/${TARGET_NAME}/tpg1/acls | grep iqn | awk '{print $2}'); do
   targetcli /iscsi/${TARGET_NAME}/tpg1/acls delete ${acl}
done

for luns in $(targetcli ls /iscsi/${TARGET_NAME}/tpg1/luns | tail -n +2 | awk '{print $2}'); do
   targetcli /iscsi/${TARGET_NAME}/tpg1/luns delete ${lun}
done

targetcli /iscsi delete ${TARGET_NAME}

for block in $(targetcli ls /backstores/block | tail -n +2 | awk '{print $2}'); do
   targetcli /backstores/block delete ${block}
done
for images in $(targetcli ls /backstores/fileio | tail -n +2 | awk '{print $2}'); do
   targetcli /backstores/fileio delete ${images}
done

targetcli ls

echo "** iscsi target deinitialised **"
echo "------------------------------------------------------------------------"

