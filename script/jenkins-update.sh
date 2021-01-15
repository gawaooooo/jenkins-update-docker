#!/bin/bash

###
# jenkins-update.sh - Docker containerにログインして実行する。jenkins yum update用
#                     /tmp 以下に配置される
###

# @see https://sue445.hatenablog.com/entry/2016/06/14/115409
# skip chown -R
export JENKINS_INSTALL_SKIP_CHOWN=true

# jenkins service stop
systemctl stop jenkins

# jenkins update
yum info jenkins
yum -y install jenkins

# jenkins service start
systemctl start jenkins
