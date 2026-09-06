if [ -z "${MAVEN_HOME}" ]; then
	echo "----------------------------------start yum install maven -----------------------------"
	
	#下载maven 下载地址可更改
	wget https://repo.huaweicloud.com/apache/maven/maven-3/3.8.3/binaries/apache-maven-3.8.3-bin.tar.gz
	tar -xzvf apache-maven-3.8.3-bin.tar.gz
	
	#拷贝maven到安装目录
	rm -rf /usr/local/maven/
	cp -f apache-maven-3.8.3/ /usr/local/maven/
	
	echo "Begin to config environment variables,please waiting..."
	
	#删除配置文件中原有的环境变量
	sed -ie '/MAVEN_HOME/d' /etc/profile
	
	#修改maven的环境变量，直接写入配置文件
	echo "export MAVEN_HOME=/usr/local/maven" >>/etc/profile
	echo "export PATH=\$PATH:\$MAVEN_HOME/bin" >>/etc/profile
	
	# maven换源请参考网上教程
	# rm -rf /usr/local/maven/conf/settings.xml
	# cp -f /root/settings.xml /usr/local/maven/conf
	
	#运行后直接生效
	source /etc/profile
	echo "----------------------------------yum install maven success -----------------------------"
else
	echo "本机已安装maven无需再次安装"
fi
