#!bin/sh
cd ~
FILE=/root/redis-5.0.8.tar.gz

# 判断文件是否存在
if test -f "$FILE"; then
    echo "$FILE exist"
	else
		wget http://download.redis.io/releases/redis-5.0.8.tar.gz
fi
# 解压安装包
tar -zxvf redis-5.0.8.tar.gz
# 重命名
mv redis-5.0.8 redis
# 移动文件
mv -f redis /usr/local/redis

cd /usr/local/redis
mkdir data

make MALLOC=lib
make install

mkdir -p /etc/redis
cp /usr/local/redis/redis.conf /etc/redis/6354.conf

cd /etc/init.d
touch redis
chmod 777 redis
cat << EOF > redis

REDISPORT=6354
EXEC=/usr/local/redis/src/redis-server
CLIEXEC=/usr/local/redis/src/redis-cli
password="Admin123"

PIDFILE=/var/run/redis_${REDISPORT}.pid
CONF="/etc/redis/${REDISPORT}.conf"

case "$1" in
    start)
        if [ -f $PIDFILE ]
        then
                echo "$PIDFILE exists, process is already running or crashed"
        else
                echo "Starting Redis server..."
                $EXEC $CONF
        fi
        ;;
    stop)
        if [ ! -f $PIDFILE ]
        then
                echo "$PIDFILE does not exist, process is not running"
        else
                PID=$(cat $PIDFILE)
                echo "Stopping ..."
                $CLIEXEC -a $password  -p $REDISPORT shutdown
                while [ -x /proc/${PID} ]
                do
                    echo "Waiting for Redis to shutdown ..."
                    sleep 1
                done
                echo "Redis stopped"
        fi
        ;;
    *)
        echo "Please use start or stop as first argument"
        ;;
esac
EOF

chkconfig --add redis
chkconfig --list redis

service redis start
