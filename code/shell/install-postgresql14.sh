yum install -y cmake make gcc zlib zlib-devel gcc-c++ perl readline readline-devel  python36 tcl openssl ncurses-devel openldap pam flex


groupadd postgres
adduser -g postgres postgres

echo "123" | passwd --stdin postgres

mkdir -p /home/postgres/{postgre14,pgdata}

mkdir -p /home/postgres
chmod -R 775 /home/postgres
chown -R postgres:postgres /home/postgres


echo "postgres soft   nofile         65535" >> /etc/security/limits.conf
echo "postgres hard   nofile        65535" >> /etc/security/limits.conf


# firewall-cmd --zone=public --add-port=5432/tcp --permanent;
# firewall-cmd --reload


cat >>  ~/.bash_profile <<"EOF"
export PGPORT=5432
export PGDATA=/home/postgres/pgdata
export PGHOME=/home/postgres/postgre14
export LD_LIBRARY_PATH=$PGHOME/lib:$LD_LIBRARY_PATH
export PATH=$PGHOME/bin:$PATH:.
EOF
source  ~/.bash_profile

su - postgres
tar -xzvf ./postgresql-14.0.tar.gz -C /home/postgres
cd  /home/postgres/postgresql-14.0
./configure --prefix=/home/postgres/postgre14
make  && make install


/home/postgres/postgre14/bin/initdb -D $PGDATA  -E UTF8 --locale=en_US.utf8 -U postgres

cat >> /home/postgres/pgdata/postgresql.conf <<"EOF"
listen_addresses = '*'
port=5432
logging_collector = on
log_directory = 'pg_log'
log_filename = 'postgresql-%a.log'
EOF

cat   > /home/postgres/pgdata/pg_hba.conf << EOF
# TYPE  DATABASE    USER    ADDRESS       METHOD
local      all       all                    trust
host      all       all    0.0.0.0/0        md5
EOF


cp /home/postgres/postgre14/bin/pg_ctl /usr/bin
#启动命令
pg_ctl start
#重启命令
pg_ctl restart
#查看数据库运行状态
pg_ctl status
#停止数据库
pg_ctl stop