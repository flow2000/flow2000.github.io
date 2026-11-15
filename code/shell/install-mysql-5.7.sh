#!/bin/sh
#下载 提示：本脚本只支持centos 7 安装MySQL版本5.7
# 安装完成后脚本会打印出MySQL的root用户的初始登录密码
# mysql -u root -p
# 输入初始密码即可登录


#wget https://repo.huaweicloud.com/mysql/Downloads/MySQL-5.7/mysql-5.7.36-el7-x86_64.tar.gz
REMOVE=`rpm -qa | grep -i mariadb-libs`
#卸载系统预置的mariadb
yum remove $REMOVE -y
#安装依赖库
yum install libaio -y
yum install libncurses* -y
yum install wget -y

mkdir -p /usr/local/mysql/{data,log}
chown -R mysql.mysql /usr/local/mysql/

#下载
wget https://repo.huaweicloud.com/mysql/Downloads/MySQL-5.7/mysql-5.7.36-el7-x86_64.tar.gz
tar -zxvf mysql-5.7.36-el7-x86_64.tar.gz
mv mysql-5.7.36-el7-x86_64 mysql
mv mysql /usr/local/
useradd -s/sbin/nlogin -M mysql
id mysql

#编辑my.cnf
cat << EOF > /etc/my.cnf
[client]
port = 3306
socket = /tmp/mysql.sock
 
[mysqld]
server_id=10
port = 3306
user = mysql
character-set-server = utf8mb4
default_storage_engine = innodb
log_timestamps = SYSTEM
socket = /tmp/mysql.sock
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data/
pid-file = /usr/local/mysql/data/mysql.pid
max_connections = 1000
max_connect_errors = 1000
table_open_cache = 1024
max_allowed_packet = 128M
open_files_limit = 65535
log-bin=mysql-bin
#####====================================[innodb]==============================
innodb_buffer_pool_size = 1024M
innodb_file_per_table = 1
innodb_write_io_threads = 4
innodb_read_io_threads = 4
innodb_purge_threads = 2
innodb_flush_log_at_trx_commit = 1
innodb_log_file_size = 512M
innodb_log_files_in_group = 2
innodb_log_buffer_size = 16M
innodb_max_dirty_pages_pct = 80
innodb_lock_wait_timeout = 30
innodb_data_file_path=ibdata1:1024M:autoextend
 
#####====================================[log]==============================
log_error = /usr/local/mysql/log/mysql-error.log 
slow_query_log = 1
long_query_time = 1 
slow_query_log_file = /usr/local/mysql/log/mysql-slow.log
 
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
EOF
 
#编译
/usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --innodb_undo_tablespaces=3 --explicit_defaults_for_timestamp
#授权
chown -R mysql:mysql /usr/local/mysql
cp /usr/local/mysql/support-files/mysql.server /etc/init.d/mysql
chmod +x /etc/init.d/mysql
chkconfig --add mysqld
chkconfig --list
cp /usr/local/mysql/bin/* /usr/local/sbin/
cd /lib/systemd/system
## 启动服务并查看
/etc/init.d/mysql start
netstat -lntup|grep mysql
grep "password" /usr/local/mysql/log/mysql-error.log 
