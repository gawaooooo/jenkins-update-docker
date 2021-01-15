# Jenkins update 検証 Docker

jenkinsを更新する際やpluginを導入する際の検証環境として使う

## ファイル構成

- Dockerfile
    - `centos:centos7` imageを利用
    - Jenkinsのバージョンを指定してrpmでインストール

### backupディレクトリ
- jenkins plugin等のバックアップファイルを置く
- `backup/backup_xxxxx.tar.gz` ファイルの内容を復元する

### scriptディレクトリ
- `docker-build-run.sh`
    - Docker imageの作成と、Docker Containerの起動を行う
- `docker-exec.sh`
    - Docker Containerにログインする
- `jennkins-update.sh`
    - Docker Containerにログイン後、Jenkinsを最新版に更新するために実行する

## 使い方

### Jenkinsバックアップファイルの配置
Dockerで再現したい状態のバックアップファイル(tar.gz)を `backup` ディレクトリに配置

### `docker-build-run.sh`　を実行してDocker imageの作成とContainer起動をし、指定したJenkinsバージョンの動作を確認する


`docker-build-run.sh` の使い方を見る

```bash
$ bash script/docker-build-run.sh -h
Usage: docker-build-run.sh [OPTION]...
Dockerfileからdocker imageを作成し、containerを起動する

    -j JENKINS VERSION  更新前のJenkins version
    -b BACKUP FILE      復元するjenkins backup file name(tar.gzファイルのファイル名)
    -i DOCKER IMAGE     buildするDocker image name
    -t DOCKER IMAGE TAG buildするDocker image tag
    -c DOCKER CONTAINER Docker container name
    -o HOSTNAME         Docker container　起動時のホスト名

    -h                  display this help ane exit
    -V                  display version information and exit
Example:
    docker-build-run.sh -j 2.204.2-1.1 -b backup -i web/jenkins -t latest
```

**./backup/backup_test.tar.gz** ファイルを復元する場合

```bash
$ bash ./script/docker-build-run.sh -b backup_test

initialJenkinsVer = 2.204.2-1.1, backup = backup_test, dockerImage = web/jenkins, dockerImageTag = latest, dockerContainer = web-jenkins, dockerHostname = localhost
docker build tag -> web/jenkins:latest, container name -> web-jenkins, container hostname -> localhost
docker containerを作り直します(同名のcontainerが存在する場合は強制削除)...

~~省略~~

=> => naming to docker.io/web/jenkins:latest
Error: No such container: web-jenkins # TODO: 初回起動時に出てしまう
17e16b7393cfc96c86e31cc2e08a088fa6a5c464ec8ca85fe6fe4b318797e56e
```

`http://localhost:8080` にアクセスし、Jenkinsが動作しているか確認

指定したJenkinsのバージョンになっているか確認


指定されたバックアップファイルのデータで復元しているので、バックアップされているユーザーでログインできる

### Containerにログインする

```bash
$ bash script/docker-exec.sh
container name -> web-jenkins
[root@localhost tmp]#
```

Container名を `hoge` にしている場合

```bash
$ bash script/docker-exec.sh hoge
container name -> hoge
```

### yumでJenkinsを最新バージョンにアップデートする

**Containerにログインした状態で実行**

```bash
[root@localhost tmp]# pwd
/tmp

[root@localhost tmp]# ls
akuma1863248762427951874jar   hsperfdata_jenkins  jenkins-backup     jetty-0.0.0.0-8080-war-_-any-3559354772016457245.dir  winstone839309672606307168.jar
backup_20201213164107.tar.gz  hsperfdata_root     jenkins-update.sh  jna3214363028558459478jar

[root@localhost tmp]# bash jenkins-update.sh
Loaded plugins: fastestmirror, ovl
Loading mirror speeds from cached hostfile
 * base: ftp-srv2.kddilabs.jp
 * extras: ftp-srv2.kddilabs.jp
 * updates: ftp-srv2.kddilabs.jp
Installed Packages
Name        : jenkins
Arch        : noarch
Version     : 2.204.2
Release     : 1.1
Size        : 60 M
Repo        : installed
Summary     : Jenkins Automation Server
URL         : http://jenkins.io/
License     : MIT/X License, GPL/CDDL, ASL2

~~省略~~

Updated:
  jenkins.noarch 0:2.263.2-1.1

Complete!
```

`http://localhost:8080` にアクセスし、Jenkinsが動作しているか確認


更新されたバージョンになっているか確認
