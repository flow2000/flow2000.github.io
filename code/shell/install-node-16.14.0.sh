if type node >/dev/null 2>&1; then
  echo 'node 已安装'
else
  echo 'node 未安装'
fi
echo "----------------------------------start yum install node -----------------------------"
wget https://cdn.npm.taobao.org/dist/node/latest-v16.x/node-v16.14.0-linux-x64.tar.gz
tar -xvf node-v16.14.0-linux-x64.tar.gz
mv node-v16.14.0-linux-x64 /usr/local/node

#删除配置文件中原有的环境变量
sed -ie '/NODE_HOME/d' /etc/profile
sed -ie '/cnpm/d' /etc/profile

#修改maven的环境变量，直接写入配置文件
echo "export NODE_HOME=/usr/local/node" >>/etc/profile
echo "export PATH=\$NODE_HOME/bin:\$PATH" >>/etc/profile

source /etc/profile

npm install -g cnpm -registry=https://registry.npm.taobao.org
echo "export PATH=/usr/local/node/lib/node_moudles/cnpm/bin:$PATH" >>/etc/profile
source /etc/profile
npm config set registry https://registry.npm.taobao.org
npm install npm -g
source /etc/profile
node -v
npm -v
cnpm -v
echo "----------------------------------yum install node success -----------------------------"