#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

# Parse command line options
while getopts "p:" opt; do
  case $opt in
    p) password="$OPTARG" ;;
    *) echo "Invalid option" >&2
       exit 1 ;;
  esac
done

# Check if required options are provided
if [ -z "$password" ]; then
  echo "Usage: $0 -p <password>"
  exit 1
fi

# create base
mkdir -p /opt/mysql/conf
mkdir -p /opt/mysql/logs
mkdir -p /opt/mysql/data


# write config to config file
tee "/opt/mysql/conf/my.conf" > /dev/null <<EOL
[mysqld]
user=mysql
character-set-server=utf8
default_authentication_plugin=mysql_native_password
secure_file_priv=/var/lib/mysql
expire_logs_days=7
sql_mode=STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION
max_connections=1000

[client]
default-character-set=utf8

[mysql]
default-character-set=utf8
EOL

# start docker container
docker run --restart=always --privileged=true  \
-v /opt/mysql/data/:/var/lib/mysql \
-v /opt/mysql/logs/:/var/log/mysql \
-v /opt/mysql/conf/my.cnf:/etc/mysql/conf.d/my.cnf \
-p 3306:3306 --name my-mysql \
-e MYSQL_ROOT_PASSWORD=$password -d mysql:8.2.0

# run script
# curl -sSL https://github.com/ReasonDuan/lazy-script/raw/main/database/docker-mysql.sh | sudo bash -s -- -p 123456
# curl -sSL https://gitee.com/ReasonDuan/lazy-script/raw/main/database/docker-mysql.sh | sudo bash -s -- -p 123456
