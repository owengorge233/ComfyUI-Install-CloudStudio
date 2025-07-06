# ComfyUI-Install-CloudStudio
Installation ComfyUI and flux models on a Tencent HAI Cloud Studio
安装过程：
启动高性能工作空间后：
1) 新建终端，在此终端操作
2) 拉取程序 
git clone https://github.com/owengorge233/ComfyUI-Install-CloudStudio.git  
3) 修改token等 
* 打开左侧的资源浏览器后，修改/workspace/ComfyUI-Install-CloudStudio/cpolartokens.txt文件，替换第一行为自己的极点云token
* 打开左侧的资源浏览器后，修改/workspace/ComfyUI-Install-CloudStudio/10cpolar.sh文件，把最后一行的comfyuics替换为自己的极点云预留的子域名zhaoliangzhi1，注意：没有引入空格
4) 把.sh文件改为可执行文件: 执行下面的指令,回车 
chmod +x  /workspace/ComfyUI-Install-CloudStudio/*.sh   
5) 切换目录: 执行下面的指令,回车 
cd /workspace/ComfyUI-Install-CloudStudio  
6) 配置环境：执行下面的指令,回车
./1env.sh
7) 输入exit退出终端，因为./1env.sh配置了环境，为使得配置生效，故退出然后新建终端。
exit
8) 新建终端，在此终端操作
9) 切换环境: 执行下面的指令,回车
conda activate comfyui
10) 切换目录: 执行下面的指令,回车
cd /workspace/ComfyUI-Install-CloudStudio
11) 安装comfyui: 执行下面的指令,回车 
./2setupcomfyui.sh
12) 安装自定义节点: 执行下面的指令,回车
./3nodes.sh 
13) 安装模型: 执行下面的指令,回车
./4models.sh 
14) 安装极点云客户端:  执行下面的指令,回车
./9setupcpolar.sh

安装完毕后：
启动ComfyUI:
1) 新建终端，在此终端操作
2) 切换环境: 执行下面的指令,回车
   conda activate comfyui
3) 切换目录: 执行下面的指令,回车
   cd /workspace/ComfyUI
4) 启动comfyui: 执行下面的指令,回车
   python main.py

启动极点云客户端:
1) 新建终端，在此终端操作
2) 切换环境: 执行下面的指令,回车
   conda activate comfyui
3) 切换目录: 执行下面的指令,回车
   cd /workspace/-Install-CloudStudio
4) 启动极点云客户端: 执行下面的指令,回车
   ./10cpolar.sh

使用一段时间后，磁盘空间不够了，释放空间：
1) 新建终端，在此终端操作
2) 切换环境: 执行下面的指令,回车
   conda activate comfyui
3) 切换目录: 执行下面的指令,回车
   cd /workspace/-Install-CloudStudio
4) 释放空间: 执行下面的指令,回车
   ./13clearcache.sh
