#!/bin/sh
echo "----------------------------------uninstall old java -----------------------------"
rpm -qa | grep java | xargs rpm -e --nodeps
rpm -qa | grep jdk | xargs rpm -e --nodeps
rpm -qa | grep gcp | xargs rpm -e --nodeps
sed -ie '/JAVA_HOME/d' /etc/profile
echo "finished"
echo "----------------------------------start yum install java-1.8.0-openjdk -----------------------------"
yum install java-1.8.0-openjdk* -y

cat >> /etc/profile<<EOF
export JAVA_HOME=/usr/lib/jvm/java
export CLASSPATH=.:\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar:\$JAVA_HOME/jre/lib/rt.jar
export PATH=\$PATH:\$JAVA_HOME/bin
EOF

source /etc/profile

java -version

echo "----------------------------------yum install java-1.8.0-openjdk success -----------------------------"