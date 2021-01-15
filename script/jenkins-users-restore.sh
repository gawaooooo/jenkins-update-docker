#!/bin/bash

###
# jenkins-users-restore.sh - Docker containerにログインして実行する。
#   バックアップデータからログインユーザーを復元する。
#   バックアップデータを復元するJenkins versionが2.138.3の場合にusers migration errorになるので usersを退避してあるため、このシェルを実行して復元
#   /tmp 以下に配置される
#   @see https://stackoverflow.com/questions/49666244/upgrade-jenkins-ci-withourt-losing-user-job-config
###

# jenkins service stop
systemctl stop jenkins

# /var/lib/jenkins/users_tmp/の中身をusersにコピー
cd /var/lib/jenkins

cp -R users_tmp/* users
rm -rf users_tmp
chown jenkins:jenkins -R users

# jenkins service start
systemctl start jenkins
