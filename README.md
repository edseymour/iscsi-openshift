ISCSI target pod for demonstrating ISCSI Targets in simple OpenShift clusters (not for production)

This project is based on https://github.com/jhou1/docker-iscsi

# Target Setup
ISCSI target setup needs to run a privileged container with `SYS_MODULE` capability and `/lib/modules` mount directory. 

First use the `scc.yml` to create a new Security Context Configuration

```
oc create -f scc.yml
```

The template does not include a service account, and runs the container using the host project's default service account. Therefore, once the SCC is created you'll need to add this service account to the SCC created above: 

```
oc adm policy add-scc-to-user storagescc system:servieaccount:<your iscsi project>:default
```
## Prepare the target node

The iscsi target service is designed to be locked to a specific OpenShift Node that provides the underlying disk storage. The template allows for a set of devices to be passed and automatically configured, or alternatively a device wildcard. The simplest method for creating suitable devices for the ISCSI target is to use logical volumes. 

The following example assumes a single disk `/dev/sdb` was attached to the server. The disk is used to create a set of logical volumes, which then can be passed to the ISCSI Target service:

```
[root@target-node ~] pvcreate /dev/sdb
[root@target-node ~] vgcreate iscsi /dev/sdb
[root@target-node ~] for vol in $(seq 0 9); do lvcreate -L 1Gi --name vol$vol iscsi; done
[root@target-node ~] for vol in $(seq 10 14); do lvcreate -L 10Gi --name vol$vol iscsi; done
[root@target-node ~] for vol in $(seq 15 19); do lvcreate -L 50Gi --name vol$vol iscsi; done
``` 
The above creates 20 volumes: 10x 1Gi, 5x 10Gi, and 5x 50Gi in size. 

Take a note of the `target-node` IP address, this will be used for the Target's portal. 

## Create the ISCSI Target Container
Use the `iscsi-build-template.yaml` to create an ImageStream and build configuration. 

## Create the ISCSI Target

The `iscsi-deploy-template.yaml` template can be used to provision and configure the ISCSI Target. It takes the following parameters:

 * DEVS - a space separated list of devices from which to create LUNs, wildcards are accepted.        
 * DEVPATH - a volume mount path to devices, required to allow the container to 'see' the target devices
 * HOSTNODE - the OpenShift Node name of the target server
 * ACL_IQNS - a spare separated list of client (initiator) IQNs
 * TARGET_NAME - the IQN for the target

For example: 
```
# oc process -f iscsi-deploy-template.yaml DEVS=/dev/iscsi/* DEVPATH=/dev/iscsi HOSTNODE=target-node ACL_IQNS=iqn.1994-05.com.redhat:7417c798910 TARGET_NAME=iqn.2016-04.cluster.local:storage.target00
```

# Create Persistent Volumes
The `scripts/iscsi-pv-template.yaml` can be used to create new persistent volumes, alternatively, the script `create-pvs.sh` can be used to batch up this process. 

The template takes the following parameters:

 * PORTAL - the Portal IP (assumes the target is operating on 3260)
 * IQN - the Target IQN
 * LUN - the LUN ID (integer value)
 * SIZE - the size of the iscsi disk

The script takes a start and end LUN id value, to generate a set of PVs with the same Portal, IQN, and SIZE parameters. 

