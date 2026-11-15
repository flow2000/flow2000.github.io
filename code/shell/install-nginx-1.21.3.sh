#!/bin/sh
echo "----------------------------------start install nginx -----------------------------"
yum install -y gcc-c++  
yum -y install openssl openssl-devel
yum install -y zlib zlib-devel
yum install -y pcre pcre-devel
#安装失败看https://blog.csdn.net/qq_41688840/article/details/123299876
if [ 'grep "nginx" /etc/passwd | wc -l' ]; then
echo "adding user nginx"
groupadd nginx
useradd -s /sbin/nologin -M -g nginx nginx
else
echo "user nginx exsits"
fi

echo "-----------------------------------downloading nginx-------------------------------"
wget http://nginx.org/download/nginx-1.21.3.tar.gz
tar -xvf nginx-1.21.3.tar.gz
cd nginx-1.21.3

echo "------------------------------------configuring nginx,plz wait----------------------"
./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-http_realip_module --with-http_stub_status_module

if [ $? -ne 0 ];then
echo "configure failed ,please check it out!"
else
echo "make nginx, please wait for 20 minutes"
make
fi

if [ $? -ne 0 ];then
echo "make failed ,please check it out!"
else
echo "install nginx, please wait for 20 minutes"
make install
fi

chown -R nginx.nginx /usr/local/nginx
ln -s /lib64/libpcre.so.0.0.1 /lib64/libpcre.so.1
cp /usr/local/nginx/sbin/nginx /usr/bin
nginx
iptables -I INPUT 3 -s 0.0.0.0/0 -p tcp --dport 80 -j ACCEPT
echo "----------------------------------start install nginx success-----------------------------"