#!bin/sh
cd ~
FILE=/root/redis-5.0.8.tar.gz
REDIS_PATH=/www/redis
REDIS_PORT=6379
REDIS_PWD=123456
EXEC=$REDIS_PATH/src/redis-server
CLIEXEC=$REDIS_PATH/src/redis-cli
PIDFILE=/var/run/redis_$REDIS_PORT.pid
CONF=$REDIS_PATH/conf/$REDIS_PORT.conf

# 判断文件是否存在
if test -f "$FILE"; then
    echo "$FILE exist"
	else
		wget https://mirrors.huaweicloud.com/redis/redis-5.0.8.tar.gz
fi
rm -rf redis-5.0.8
rm -rf redis

mkdir -p $REDIS_PATH/data
mkdir -p $REDIS_PATH/conf
mkdir -p $REDIS_PATH
mkdir -p $REDIS_PATH/data

# 解压安装包
tar -zxvf redis-5.0.8.tar.gz

# 重命名
mv -f redis-5.0.8 redis
mv -f redis $REDIS_PATH

cd $REDIS_PATH/redis

make MALLOC=lib
make install

rm -rf $REDIS_PATH/conf/$REDIS_PORT.conf

cp ./redis.conf  $REDIS_PATH/conf/$REDIS_PORT.conf

sed -i "s/bind 127.0.0.1/bind 0.0.0.0/g" $REDIS_PATH/conf/$REDIS_PORT.conf
sed -i "s/port 6379/port $REDIS_PORT/g" $REDIS_PATH/conf/$REDIS_PORT.conf
sed -i "s/# requirepass foobared/requirepass $REDIS_PWD/g" $REDIS_PATH/conf/$REDIS_PORT.conf
sed -i "s/daemonize no/daemonize yes/g" $REDIS_PATH/conf/$REDIS_PORT.conf

cd /etc/init.d
touch redis
chmod 777 redis
cat << EOF > redis
# chkconfig:   2345 90 10
# description:  Redis is a persistent key-value database

REDIS_PORT=$REDIS_PORT
EXEC=$REDIS_PATH/redis/src/redis-server
CLIEXEC=$REDIS_PATH/redis/src/redis-cli
REDIS_PWD=$REDIS_PWD

PIDFILE=/var/run/redis_$REDIS_PORT.pid
CONF=$REDIS_PATH/conf/$REDIS_PORT.conf

case "\$1" in

    start)
        if [ -f \$PIDFILE ]
        then
                echo "\$PIDFILE exists, process is already running or crashed"
        else
                echo "Starting Redis server..."
                \$EXEC \$CONF
        fi
        ;;
    stop)
        if [ ! -f \$PIDFILE ]
        then
                echo "\$PIDFILE does not exist, process is not running"
        else
                echo "Stopping ..."
                \$CLIEXEC -a \$REDIS_PWD  -p \$REDIS_PORT shutdown
                echo "Redis stopped"
        fi
        ;;
    *)
        
        echo "Please use start or stop as first argument \$1"
        ;;
esac
EOF

chkconfig --add redis
chkconfig --list redis

service redis start

rm -rf /root/redis-5.0.8.tar.gz
rm -rf /root/redis