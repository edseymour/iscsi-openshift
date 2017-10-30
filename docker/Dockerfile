FROM centos:7
MAINTAINER Ed Seymour, eseymour@redhat.com

RUN yum install -y targetcli hostname && mkdir /iscsi_disks

ADD init.sh /
ADD deinit.sh /

VOLUME [ '/iscsi_disks' ]
EXPOSE 3260 

ENTRYPOINT /init.sh
