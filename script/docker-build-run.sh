#!/bin/bash

###
# docker-build-run.sh - Dockerfileからdocker imageを作成し、containerを起動する
###

readonly SCRIPT_NAME=${0##*/}
readonly VERSION=1.0.0

print_help()
{
    cat << END
Usage: $SCRIPT_NAME [OPTION]...
Dockerfileからdocker imageを作成し、containerを起動する

    -j JENKINS VERSION  更新前のJenkins version
    -b BACKUP FILE      復元するjenkins backup file name(tar.gzファイルのファイル名)
    -i DOCKER IMAGE     buildするDocker image name
    -t DOCKER IMAGE TAG buildするDocker image tag
    -c DOCKER CONTAINER Docker container name
    -o HOSTNAME         Docker container 起動時のホスト名
    -p PORT             Docker container 起動時のport

    -h                  display this help ane exit
    -V                  display version information and exit
Example:
    $SCRIPT_NAME -j 2.204.2-1.1 -b backup -i web/jenkins -t latest
END
}

print_version()
{
    cat << END
$SCRIPT_NAME version $VERSION
END
}

print_error()
{
    cat << END 1>&2
$SCRIPT_NAME: $1
Try -h option for more information
END
}

# rpm installする更新前jenkins version
# http://mirrors.jenkins-ci.org/redhat-stable/jenkins-{initialJenkinsVersion}.noarch.rpm
initialJenkinsVer=2.204.2-1.1
# 復元するjenkins backup file名.{backup}.tar.gz
backup=backup
# buildするDocker image名
dockerImage=web/jenkins
# buildするDocker image tag名
dockerImageTag=latest
# Docker container名
dockerContainer=web-jenkins
# Docker container起動時ホスト名
dockerHostname=localhost
# Docker container port
dockerPort=8080

while getopts :j:b:i:t:c:o:p:hV option
do
    case "$option" in
        j)
            initialJenkinsVer=$OPTARG
            ;;
        b)
            backup=$OPTARG
            ;;
        i)
            dockerImage=$OPTARG
            ;;
        t)
            dockerImageTag=$OPTARG
            ;;
        c)
            dockerContainer=$OPTARG
            ;;
        o)
            dockerHostname=$OPTARG
            ;;
        p)
            dockerPort=$OPTARG
            ;;
        h)
            print_help
            exit 0
            ;;
        V)
            print_version
            exit 0
            ;;
        \?)
            # 不正なオプションが指定された、
            # または引数が必要なオプションに引数が不足している場合の処理
            print_error "unrecognized option -- '$OPTARG'"
            exit 1
            ;;
    esac
done

shift $((OPTIND - 1))

cat <<END
initialJenkinsVer = $initialJenkinsVer, backup = $backup, dockerImage = $dockerImage, dockerImageTag = $dockerImageTag, dockerContainer = $dockerContainer, dockerHostname = $dockerHostname, dockerPort = $dockerPort
END

echo "docker build tag -> $dockerImage:$dockerImageTag, container name -> $dockerContainer, container hostname -> $dockerHostname, port -> $dockerPort"
echo "docker containerを作り直します(同名のcontainerが存在する場合は強制削除)...."

# docker build
docker build --rm -t $dockerImage:$dockerImageTag --build-arg INITIAL_JENKINS_VERSION=$initialJenkinsVer --build-arg BACKUP_FILE=$backup .

# docker container delete(TODO: 初回は存在しないのでエラーが表示される)
docker rm -f $dockerContainer
# docker run
docker run -it -d --privileged --name $dockerContainer -h $dockerHostname -p $dockerPort:$dockerPort $dockerImage:$dockerImageTag
