#!/bin/sh

# ==============================================
# 服务器环境一键配置脚本
# 功能：整合所有安装脚本，提供模块化安装选项
# 使用方法：./merged-install-linux.sh [必需选项]
# 必需选项：
#   --mysql-user=用户名      设置MySQL普通用户名
#   --mysql-root-pwd=密码    设置MySQL root用户密码
#   --mysql-user-pwd=密码    设置MySQL普通用户密码
#   --redis-pwd=密码         设置Redis密码
# 注意：所有用户和密码参数都是必需的，没有默认值
# ==============================================

# ==============================================
# 解析命令行参数
# ==============================================
while [ $# -gt 0 ]; do
  case "$1" in
    --mysql-user=*)
      MYSQL_USER="${1#*=}"
      ;;
    --mysql-root-pwd=*)
      MYSQL_ROOT_PASSWORD="${1#*=}"
      ;;
    --mysql-user-pwd=*)
      MYSQL_USER_PASSWORD="${1#*=}"
      ;;
    --redis-pwd=*)
      REDIS_PASSWORD="${1#*=}"
      ;;
    *)
      echo "未知参数: $1"
      echo "使用方法: ./merged-install-linux.sh [--mysql-user=用户名] [--mysql-root-pwd=密码] [--mysql-user-pwd=密码] [--redis-pwd=密码]"
      exit 1
      ;;
  esac
  shift
done

# ==============================================
# 配置变量区域 - 可根据需要修改
# ==============================================
# MySQL配置
MYSQL_VERSION="5.7.36"
MYSQL_PORT="3295"
MYSQL_INSTALL_PATH="/www/mysql"
# MySQL配置变量

# Redis配置
REDIS_VERSION="5.0.8"
REDIS_PORT="6354"
REDIS_INSTALL_PATH="/www/redis"

# 检查必需参数是否提供
if [ -z "$MYSQL_USER" ]; then
  echo "错误: 必须通过 --mysql-user 参数指定MySQL用户名"
  echo "使用方法: ./merged-install-linux.sh --mysql-user=用户名 --mysql-root-pwd=密码 --mysql-user-pwd=密码 --redis-pwd=密码"
  exit 1
fi

if [ -z "$MYSQL_ROOT_PASSWORD" ]; then
  echo "错误: 必须通过 --mysql-root-pwd 参数指定MySQL root密码"
  echo "使用方法: ./merged-install-linux.sh --mysql-user=用户名 --mysql-root-pwd=密码 --mysql-user-pwd=密码 --redis-pwd=密码"
  exit 1
fi

if [ -z "$MYSQL_USER_PASSWORD" ]; then
  echo "错误: 必须通过 --mysql-user-pwd 参数指定MySQL用户密码"
  echo "使用方法: ./merged-install-linux.sh --mysql-user=用户名 --mysql-root-pwd=密码 --mysql-user-pwd=密码 --redis-pwd=密码"
  exit 1
fi

if [ -z "$REDIS_PASSWORD" ]; then
  echo "错误: 必须通过 --redis-pwd 参数指定Redis密码"
  echo "使用方法: ./merged-install-linux.sh --mysql-user=用户名 --mysql-root-pwd=密码 --mysql-user-pwd=密码 --redis-pwd=密码"
  exit 1
fi

# 显示配置信息
echo "==============================================="
echo "服务器环境一键配置脚本 - 配置信息"
echo "==============================================="
echo "MySQL root密码: ${MYSQL_ROOT_PASSWORD}"
echo "MySQL 用户名: ${MYSQL_USER}"
echo "MySQL 用户密码: ${MYSQL_USER_PASSWORD}"
echo "Redis密码: ${REDIS_PASSWORD}"
echo "==============================================="
echo ""

# Nginx配置
NGINX_VERSION="1.21.3"
NGINX_INSTALL_PATH="/www/nginx"

# Java配置
JAVA_VERSION="1.8.0"

# 下载镜像源配置
HUAWEI_MIRROR="https://mirrors.huaweicloud.com"
MYSQL_MIRROR="https://repo.huaweicloud.com/mysql/Downloads/MySQL-5.7"
NGINX_MIRROR="http://nginx.org/download"
REDIS_MIRROR="https://mirrors.huaweicloud.com/redis"

# ==============================================
# 工具函数
# ==============================================

# 打印分隔线
echo_separator() {
    echo "----------------------------------------------"
}

# 打印标题
echo_title() {
    echo_separator
    echo "$1"
    echo_separator
}

# 检查命令是否成功执行
check_success() {
    if [ $? -ne 0 ]; then
        echo "错误：$1 执行失败！"
        return 1
    fi
    return 0
}

# ==============================================
# 安装gotop
# ==============================================
install_gotop() {
    echo_title "开始安装 gotop 监控工具"
    
    # 获取最新版本
    function get_latest_release {
        curl --silent "https://api.github.com/repos/$1/releases/latest" | 
        grep '"tag_name":' |                                           
        sed -E 's/.*"([^"]+)".*/\1/'                                   
    }

    function download {
        RELEASE=$(get_latest_release 'cjbassi/gotop')
        ARCHIVE=gotop_${RELEASE}_${1}.tgz
        MAX_RETRIES=4
        RETRY_COUNT=0
        
        # 定义加速源列表
        GITHUB_PROXIES=(
            "https://gh.jasonzeng.dev"
            "https://gh-proxy.com"
            "https://proxy.pipers.cn"
            "http://gh.halonice.com"
            "http://kr2-proxy.gitwarp.com:9980"
            "https://github.com" # 直接使用GitHub作为最后的备选
        )
        
        PROXY_INDEX=0
        MAX_PROXIES=${#GITHUB_PROXIES[@]}
        
        while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
            # 获取当前使用的加速源
            CURRENT_PROXY=${GITHUB_PROXIES[$PROXY_INDEX]}
            echo "尝试下载 gotop 压缩包 (第 $((RETRY_COUNT+1))/$MAX_RETRIES 次，使用加速源: ${CURRENT_PROXY}) ..."
            
            # 构建下载URL
            if [ "$CURRENT_PROXY" = "https://github.com" ]; then
                # 直接使用GitHub，不需要额外的前缀
                DOWNLOAD_URL="https://github.com/cjbassi/gotop/releases/download/${RELEASE}/${ARCHIVE}"
            else
                # 使用代理加速源
                DOWNLOAD_URL="${CURRENT_PROXY}/https://github.com/cjbassi/gotop/releases/download/${RELEASE}/${ARCHIVE}"
            fi
            
            curl -LO --connect-timeout 10 --max-time 30 "$DOWNLOAD_URL"
            
            # 检查压缩包是否成功下载
            if [ -f "$ARCHIVE" ] && [ -s "$ARCHIVE" ]; then
                echo "下载成功，解压文件..."
                chmod +x ${ARCHIVE}
                tar xf ${ARCHIVE}
                rm ${ARCHIVE}
                return 0
            else
                echo "下载失败，找不到或文件为空..."
                rm -f ${ARCHIVE}  # 清理可能不完整的文件
                
                # 切换到下一个加速源
                PROXY_INDEX=$(( (PROXY_INDEX + 1) % MAX_PROXIES ))
                RETRY_COUNT=$((RETRY_COUNT+1))
                
                # 如果所有加速源都尝试过一轮，则等待更长时间再重试
                if [ $((RETRY_COUNT % MAX_PROXIES)) -eq 0 ]; then
                    echo "所有加速源都已尝试一轮，等待5秒后重新开始..."
                    sleep 5
                else
                    sleep 2  # 等待2秒后重试
                fi
            fi
        done
        
        echo "错误：经过 $MAX_RETRIES 次尝试后仍无法成功下载 gotop 压缩包 ${ARCHIVE}"
        echo "请检查网络连接或尝试手动下载并安装。"
        return 1
    }

    ARCH=$(uname -sm)
    case "${ARCH}" in
        # order matters
        Darwin\ *64)        download darwin_amd64   ;;
        Darwin\ *86)        download darwin_386     ;;
        Linux\ armv5*)      download linux_arm5     ;;
        Linux\ armv6*)      download linux_arm6     ;;
        Linux\ armv7*)      download linux_arm7     ;;
        Linux\ armv8*)      download linux_arm8     ;;
        Linux\ aarch64*)    download linux_arm8     ;;
        Linux\ *64)         download linux_amd64    ;;
        Linux\ *86)         download linux_386      ;;
        *)
            echo "\
未找到适合您系统的二进制文件。"
            return 1
            ;;
    esac

    check_success "获取gotop二进制文件"
    
    cp ~/gotop /usr/local/bin
    chmod +x /usr/local/bin/gotop
    
    # 清理临时文件
    echo "清理临时安装文件..."
    rm -f ~/gotop
    
    check_success "安装gotop到系统路径"
    
    echo_title "gotop 安装完成"
}

# ==============================================
# 安装Java 1.8
# ==============================================
install_java() {
    echo_title "开始安装 Java ${JAVA_VERSION}"
    
    echo "移除旧版Java..."
    rpm -qa | grep java | xargs rpm -e --nodeps 2>/dev/null || true
    rpm -qa | grep jdk | xargs rpm -e --nodeps 2>/dev/null || true
    rpm -qa | grep gcp | xargs rpm -e --nodeps 2>/dev/null || true
    sed -ie '/JAVA_HOME/d' /etc/profile 2>/dev/null || true
    
    echo "使用yum安装Java..."
    yum install java-${JAVA_VERSION}-openjdk* -y
    check_success "Java安装"
    
    echo "配置Java环境变量..."
    cat >> /etc/profile<<EOF
export JAVA_HOME=/usr/lib/jvm/java
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/jre/lib/rt.jar
export PATH=\$PATH:\$JAVA_HOME/bin
EOF
    
    source /etc/profile
    
    echo "Java版本信息："
    java -version
    
    echo_title "Java ${JAVA_VERSION} 安装完成"
}

# ==============================================
# 安装MySQL 5.7
# ==============================================
install_mysql() {
    echo_title "开始安装 MySQL ${MYSQL_VERSION}"
    
    echo "卸载系统预置的mariadb..."
    REMOVE=$(rpm -qa | grep -i mariadb-libs)
    if [ -n "$REMOVE" ]; then
        yum remove $REMOVE -y
    fi
    
    echo "安装依赖库..."
    yum install libaio -y
    yum install libncurses* -y
    yum install wget -y
    
    echo "下载MySQL安装包..."
    wget ${MYSQL_MIRROR}/mysql-${MYSQL_VERSION}-el7-x86_64.tar.gz
    check_success "下载MySQL"
    
    echo "解压并安装MySQL..."
    tar -zxvf mysql-${MYSQL_VERSION}-el7-x86_64.tar.gz
    mv mysql-${MYSQL_VERSION}-el7-x86_64 mysql
    
    # 创建安装目录
    mkdir -p $(dirname ${MYSQL_INSTALL_PATH})
    mv mysql ${MYSQL_INSTALL_PATH}
    mkdir -p ${MYSQL_INSTALL_PATH}/{data,log}
    
    # 创建MySQL用户
    if ! id mysql >/dev/null 2>&1; then
        useradd -s/sbin/nlogin -M mysql
    fi
    chown -R mysql.mysql ${MYSQL_INSTALL_PATH}/
    
    echo "配置MySQL配置文件..."
    cat << EOF > /etc/my.cnf
[client]
port = ${MYSQL_PORT}
socket = /tmp/mysql.sock
 
[mysqld]
server_id=10
port = ${MYSQL_PORT}
user = mysql
character-set-server = utf8mb4
default_storage_engine = innodb
log_timestamps = SYSTEM
socket = /tmp/mysql.sock
basedir = ${MYSQL_INSTALL_PATH}
datadir = ${MYSQL_INSTALL_PATH}/data/
pid-file = ${MYSQL_INSTALL_PATH}/data/mysql.pid
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
log_error = ${MYSQL_INSTALL_PATH}/log/mysql-error.log 
slow_query_log = 1
long_query_time = 1 
slow_query_log_file = ${MYSQL_INSTALL_PATH}/log/mysql-slow.log
 
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
EOF
    
    echo "初始化MySQL数据库..."
    ${MYSQL_INSTALL_PATH}/bin/mysqld --initialize --user=mysql --basedir=${MYSQL_INSTALL_PATH} --datadir=${MYSQL_INSTALL_PATH}/data --innodb_undo_tablespaces=3 --explicit_defaults_for_timestamp
    check_success "MySQL初始化"
    
    echo "配置MySQL服务..."
    chown -R mysql:mysql ${MYSQL_INSTALL_PATH}
    cp ${MYSQL_INSTALL_PATH}/support-files/mysql.server /etc/init.d/mysql
    chmod +x /etc/init.d/mysql
    chkconfig --add /etc/init.d/mysql
    cp ${MYSQL_INSTALL_PATH}/bin/* /usr/local/sbin/
    
    echo "启动MySQL服务..."
    /etc/init.d/mysql start
    check_success "MySQL启动"
    
    netstat -lntup|grep mysql
    
    echo "获取MySQL初始密码..."
    INITIAL_PASSWORD=$(grep "password " ${MYSQL_INSTALL_PATH}/log/mysql-error.log | awk '{print $NF}')
    echo "MySQL初始密码: $INITIAL_PASSWORD"
    
    echo "修改MySQL密码并创建用户..."
    ${MYSQL_INSTALL_PATH}/bin/mysql -u root -p"$INITIAL_PASSWORD" --connect-expired-password -e "
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION;
CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_USER_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
"
    check_success "MySQL用户配置"
    
    # 清理安装包
    echo "清理临时安装文件..."
    rm -rf mysql-${MYSQL_VERSION}-el7-x86_64.tar.gz
    
    echo_title "MySQL ${MYSQL_VERSION} 安装完成"
    echo "MySQL安装路径: ${MYSQL_INSTALL_PATH}"
    echo "MySQL端口: ${MYSQL_PORT}"
    echo "Root密码: ${MYSQL_ROOT_PASSWORD}"
    echo "用户 ${MYSQL_USER} 密码: ${MYSQL_USER_PASSWORD}"
}

# ==============================================
# 安装Nginx 1.21.3
# ==============================================
install_nginx() {
    echo_title "开始安装 Nginx ${NGINX_VERSION}"
    
    echo "安装Nginx依赖..."
    yum install -y gcc-c++  
    yum -y install openssl openssl-devel
    yum install -y zlib zlib-devel
    yum install -y pcre pcre-devel
    
    echo "创建Nginx用户..."
    if ! grep -q "nginx" /etc/passwd; then
        groupadd nginx
        useradd -s /sbin/nologin -M -g nginx nginx
    else
        echo "用户nginx已存在"
    fi
    
    echo "下载Nginx..."
    wget ${NGINX_MIRROR}/nginx-${NGINX_VERSION}.tar.gz
    check_success "下载Nginx"
    
    echo "解压并编译Nginx..."
    tar -xvf nginx-${NGINX_VERSION}.tar.gz
    cd nginx-${NGINX_VERSION}
    
    mkdir -p ${NGINX_INSTALL_PATH}
    
    echo "配置Nginx..."
    ./configure --prefix=${NGINX_INSTALL_PATH} --with-http_ssl_module --with-http_realip_module --with-http_stub_status_module
    check_success "Nginx配置"
    
    echo "编译Nginx..."
    make
    check_success "Nginx编译"
    
    echo "安装Nginx..."
    make install
    check_success "Nginx安装"
    
    echo "配置Nginx..."
    chown -R nginx.nginx ${NGINX_INSTALL_PATH}
    ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1 2>/dev/null || true
    cp ${NGINX_INSTALL_PATH}/sbin/nginx /usr/bin
    
    echo "启动Nginx..."
    nginx
    check_success "Nginx启动"
    
    echo "配置防火墙..."
    iptables -I INPUT 3 -s 0.0.0.0/0 -p tcp --dport 80 -j ACCEPT
    
    echo "设置Nginx开机自启..."
    echo "nginx" >> /etc/rc.local
    chmod +x /etc/rc.local
    
    # 清理安装包
    echo "清理临时安装文件..."
    rm -rf ../nginx-${NGINX_VERSION}.tar.gz
    rm -rf ../nginx-${NGINX_VERSION}
    
    echo_title "Nginx ${NGINX_VERSION} 安装完成"
    echo "Nginx安装路径: ${NGINX_INSTALL_PATH}"
}

# ==============================================
# 安装Redis 5.0.8
# ==============================================
install_redis() {
    echo_title "开始安装 Redis ${REDIS_VERSION}"
    
    cd ~
    FILE="/root/redis-${REDIS_VERSION}.tar.gz"
    REDIS_PATH="${REDIS_INSTALL_PATH}"
    REDIS_PORT="${REDIS_PORT}"
    REDIS_PWD="${REDIS_PASSWORD}"
    EXEC="${REDIS_PATH}/src/redis-server"
    CLIEXEC="${REDIS_PATH}/src/redis-cli"
    PIDFILE="/var/run/redis_${REDIS_PORT}.pid"
    CONF="${REDIS_PATH}/conf/${REDIS_PORT}.conf"

    # 判断文件是否存在
    if test ! -f "$FILE"; then
        echo "下载Redis安装包..."
        wget ${REDIS_MIRROR}/redis-${REDIS_VERSION}.tar.gz
        check_success "下载Redis"
    fi
    
    # 清理旧文件
    rm -rf redis-${REDIS_VERSION}
    rm -rf redis

    # 创建目录
    mkdir -p ${REDIS_PATH}/data
    mkdir -p ${REDIS_PATH}/conf
    mkdir -p ${REDIS_PATH}

    # 解压安装包
    echo "解压Redis安装包..."
    tar -zxvf redis-${REDIS_VERSION}.tar.gz

    # 重命名
    mv -f redis-${REDIS_VERSION} redis
    mv -f redis ${REDIS_PATH}

    cd ${REDIS_PATH}/redis

    echo "编译Redis..."
    make MALLOC=lib
    check_success "Redis编译"
    make install
    
    # 配置Redis
    rm -rf ${REDIS_PATH}/conf/${REDIS_PORT}.conf
    cp ./redis.conf ${REDIS_PATH}/conf/${REDIS_PORT}.conf

    sed -i "s/bind 127.0.0.1/bind 0.0.0.0/g" ${REDIS_PATH}/conf/${REDIS_PORT}.conf
    sed -i "s/port 6379/port ${REDIS_PORT}/g" ${REDIS_PATH}/conf/${REDIS_PORT}.conf
    sed -i "s/# requirepass foobared/requirepass ${REDIS_PASSWORD}/g" ${REDIS_PATH}/conf/${REDIS_PORT}.conf
    sed -i "s/daemonize no/daemonize yes/g" ${REDIS_PATH}/conf/${REDIS_PORT}.conf

    # 创建服务脚本
    cd /etc/init.d
    touch redis
    chmod 777 redis
    cat << EOF > redis
# chkconfig:   2345 90 10
# description:  Redis is a persistent key-value database

REDIS_PORT=${REDIS_PORT}
EXEC=${REDIS_PATH}/redis/src/redis-server
CLIEXEC=${REDIS_PATH}/redis/src/redis-cli
REDIS_PASSWORD=${REDIS_PASSWORD}

PIDFILE=/var/run/redis_${REDIS_PORT}.pid
CONF=${REDIS_PATH}/conf/${REDIS_PORT}.conf

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
                \$CLIEXEC -a \$REDIS_PASSWORD  -p \$REDIS_PORT shutdown
                echo "Redis stopped"
        fi
        ;;
    *)
        
        echo "Please use start or stop as first argument \$1"
        ;;
esac
EOF

    echo "添加Redis到系统服务..."
    chkconfig --add redis
    chkconfig redis on
    chkconfig --list redis
    
    # 添加到rc.local确保开机自启
    echo "设置Redis开机自启..."
    if ! grep -q "service redis start" /etc/rc.local; then
        echo "service redis start" >> /etc/rc.local
        chmod +x /etc/rc.local
    fi

    echo "启动Redis服务..."
    service redis start
    check_success "Redis启动"

    # 清理安装包和临时文件
    echo "清理临时安装文件..."
    rm -rf /root/redis-${REDIS_VERSION}.tar.gz
    rm -rf /root/redis
    
    echo_title "Redis ${REDIS_VERSION} 安装完成"
    echo "Redis安装路径: ${REDIS_PATH}"
    echo "Redis端口: ${REDIS_PORT}"
    echo "Redis密码: ${REDIS_PASSWORD}"
}

# ==============================================
# 主菜单
# ==============================================
show_menu() {
    clear
    echo_title "服务器环境一键配置脚本"
    echo "1. 安装 Java ${JAVA_VERSION}"
    echo "2. 安装 MySQL ${MYSQL_VERSION}"
    echo "3. 安装 Nginx ${NGINX_VERSION}"
    echo "4. 安装 Redis ${REDIS_VERSION}"
    echo "5. 安装 gotop 监控工具"
    echo "6. 一键安装所有组件"
    echo "0. 退出"
    echo_separator
    echo -n "请选择要执行的操作 [0-6]: "
}

# ==============================================
# 一键安装所有组件
# ==============================================
install_all() {
    if [ $? -eq 0 ]; then
        install_gotop
    fi
    if [ $? -eq 0 ]; then
        install_java
    fi
    if [ $? -eq 0 ]; then
        install_mysql
    fi
    if [ $? -eq 0 ]; then
        install_nginx
    fi
    if [ $? -eq 0 ]; then
        install_redis
    fi
    echo_title "所有组件安装完成！"
}

# ==============================================
# 主函数
# ==============================================
main() {
    while true; do
        show_menu
        read choice
        case $choice in
            1)
                install_java
                ;;
            2)
                install_mysql
                ;;
            3)
                install_nginx
                ;;
            4)
                install_redis
                ;;
            5)
                install_gotop
                ;;
            6)
                echo "即将开始安装所有组件，这将需要一些时间..."
                install_all
                ;;
            0)
                echo "退出脚本..."
                exit 0
                ;;
            *)
                echo "无效的选择，请重新输入！"
                ;;
        esac
        echo -n "按回车键继续..."
        read
    done
}

# 执行主函数
main