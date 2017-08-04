FROM centos:7
MAINTAINER Ed Seymour, eseymour@redhat.com

RUN yum install -y targetcli hostname

ADD init.sh /

ENTRYPOINT /init.sh
