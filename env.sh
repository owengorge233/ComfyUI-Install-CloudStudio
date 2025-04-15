#! /bin/bash
echo 'export http_proxy=http://proxy.cloudstudio.work:8081' >> ~/.bashrc
echo 'export HTTP_PROXY=http://proxy.cloudstudio.work:8081' >> ~/.bashrc
echo 'export https_proxy=http://proxy.cloudstudio.work:8081' >> ~/.bashrc
echo 'export HTTPS_PROXY=http://proxy.cloudstudio.work:8081' >> ~/.bashrc
echo 'export no_proxy=127.0.0.1,localhost,.local,.tencent.com,tencentyun.com,ppa.launchpad.net,0.0.0.0' >> ~/.bashrc
echo 'export NO_PROXY=127.0.0.1,localhost,.local,.tencent.com,tencentyun.com,ppa.launchpad.net,0.0.0.0' >> ~/.bashrc

# （可选）保存到 zshrc
echo 'export http_proxy=http://proxy.cloudstudio.work:8081' >> ~/.zshrc
echo 'export HTTP_PROXY=http://proxy.cloudstudio.work:8081' >> ~/.zshrc
echo 'export https_proxy=http://proxy.cloudstudio.work:8081' >> ~/.zshrc
echo 'export HTTPS_PROXY=http://proxy.cloudstudio.work:8081' >> ~/.zshrc
echo 'export no_proxy=127.0.0.1,localhost,.local,.tencent.com,tencentyun.com,ppa.launchpad.net,0.0.0.0' >> ~/.zshrc
echo 'export NO_PROXY=127.0.0.1,localhost,.local,.tencent.com,tencentyun.com,ppa.launchpad.net,0.0.0.0' >> ~/.zshrc
echo 'export HF_ENDPOINT=https://hf-mirror.com' >> ~/.bashrc   

source ~/.bashrc

pip install -U huggingface_hub

# Git 设置全局代理
git config --global http.proxy http://proxy.cloudstudio.work:8081
git config --global https.proxy http://proxy.cloudstudio.work:8081

# 修复 apt update 失败问题
cp /etc/apt/sources.list /etc/apt/sources.list.bak.`date +'%F-%T'`
sed -i 's/http:\/\/mirrors.cloud.tencent.com/https:\/\/mirrors.cloud.tencent.com/g' /etc/apt/sources.list

# 支持通过 ssh 方式 clone github 仓库
apt update -y && apt install -y socat
if [ ! -d ~/.ssh ]; then
    echo "创建SSH目录并设置权限..."
    mkdir -vp ~/.ssh || { echo "目录创建失败"; exit 1; }
    chmod 700 ~/.ssh || { echo "权限设置失败"; exit 1; }
fi
cat << EOF >> ~/.ssh/config
Host github.com
    Hostname ssh.github.com
    Port 443
    User git
    ProxyCommand socat - PROXY:proxy.cloudstudio.work:%h:%p,proxyport=8081
EOF
chmod 600 ~/.ssh/config