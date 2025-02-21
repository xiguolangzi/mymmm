# 《Git 部署 CI/DI》

1. ## 安装 Git 环境

   ```java
   // 1 安装
   yum install git -y

   // 2 查看 git 相关插件
   yum serch git

   // 3 安装 git 插件
   yum install git-core git-web -y
   ```

2. ## 部署 Git

   ```java
   // 1 创建账号密码
   useradd username
   passwd pwd

   // 2 创建目录
   mkdir /git-root/
   cd /git-root/
       
   // 3 查看配置信息
   git config --list

   ```

   ​









