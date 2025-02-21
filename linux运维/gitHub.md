# 《RustDesk 远程部署使用》

## 1 链接远程仓库：

```bash
# 1 初始化
git init

# 2 然后提交本地文件
git add .
git commit -m "Initial commit"

# 3 添加远程仓库
git remote add <别名> <远程仓库URL>
git remote add github https://github.com/xiguolangzi/mymmm.git
# 3.1 查看远程仓库挂载情况
git remote -v

# 4 添加远程推送分支
git push --set-upstream <别名> <分支名>
git push --set-upstream github main
# 4.1 查看远程仓库挂载情况
git remote -v

# 5 推送到远程仓库
git push -u <别名> <分支名>
git push -u origin main
-- -u 让 Git 记住 origin main，以后只需执行：
git push

# 6 拉取远程仓库
git pull <别名> <分支名>
git pull origin main

```

## 2 创建分支/切换分支

```bash
# 1 确保main分支最新
git checkout main
git pull origin main

# 2 创建新分支
git checkout -b <分支名>
-- dev test main

# 3 查看所有分支
git branch

# 4 查看远程分支
git branch -a

# 5 切换分支
git checkout <分支名>

# 6 删除分支
	--删除远程分支： git push <别名> --delete <分支名> 
	--删除本地分支： git branch -d <分支名>

```

## 3 合并分支

```bash
# 1 强制合并 
--force
git push --force github main

```

## 4 搜索资料技巧

```

```

## 5 工作流程

### 	5.1 创建仓库

```bash
# 1 官网创建仓库
```

### 	5.2 链接远程仓库

```bash
# 1 添加远程仓库
git remote add <别名> <远程仓库URL>
git remote add github https://github.com/xiguolangzi/mymmm.git

# 2 查看远程仓库挂载情况
git remote -v

# 3 修改远程仓库主分支名（master 改成 main）
git branch -M main

# 4 推送到远程仓库
git push -u <别名> <分支名>
git push -u origin main
-- -u 让 Git 记住 origin main，以后只需执行：
git push

# 5 认证授权 -> 账号 密码
```

### 	5.3 推送远程仓库

```bash

```

### 	5.4 创建分支 开发/测试

```bash
# 1 以当前分支为节点，创建分支
git checkout -b dev

# 2 切换分支
git checkout main

```

### 	5.5 开发过程	

```bash
# 1 add 之后 commit 之前的 本地add回滚
git checkout <文件名>

# 2 commit 之后 push 之前 本地commit回滚
git reset HEAD^1
-- HEAD只当前commit的位置，^1 向前回滚1个版本

# 3 如果远程仓库优先于本地
git pull

```

### 	5.6 开发后合并分支

```bash
# 1 当前分支合并其他分支 main
git merge dev

# 2 放弃本次合并
git merge --abort

# 3 合并后删除分支
git branch -D <分支名>

# 4 查看现有分支
git branch
```

### 	5.7  编辑器处理合并请求

```bash
# 1 IDEA

# 2 VSCODE

```

### 	5.8  合并分支

```bash

```

## 6 CI/CD

### 	6.1 准备服务器

```bash
# 1 准备服务器

# 2 下载服务器的 密钥文件，保存起来 后续使用；
	-- 下载密钥文件
# 3 服务器关机 -> 从新开机 绑定密钥对！

# 4 远程访问服务器只能通过 公钥 登录，即 远程访问需要绑定 密钥文件！
	-- 远程访问客户端 需要 绑定密钥文件
	-- 通过公钥登录
	-- 账号密码不能登录！
```

### 	6.2 脚本 

```yaml
# 脚本位置： .git/workflow/xxx.yml
# 学习视频来源：https://www.bilibili.com/video/BV1xa411h7h9?spm_id_from=333.788.player.switch&vd_source=90ff53fe44d29e00ed0199e3c93004c2&p=5；

name: 打包应用并上传腾讯云

# push到 main 分支之后执行脚本工作流
on:
    push:
        branches:
            - main
# 工作流程
jobs:
    build:
        # runs-on 指定job任务运行所需要的虚拟机环境(必填字段)
        runs-on: ubuntu-latest
        steps:
            # 获取源码
            - name: 迁出代码
              # 使用action库  actions/checkout获取源码
              uses: actions/checkout@master

            # 安装Node10
            - name: 安装node.js
              # 使用action库  actions/setup-node安装node
              uses: actions/setup-node@v1
              with:
                  node-version: 14.0.0

            # 安装依赖
            - name: 安装依赖
              run: npm install

            # 打包
            - name: 打包
              run: npm run build

            # 上传阿里云
            - name: 发布到腾讯云
              uses: easingthemes/ssh-deploy@v2.1.1
              env:
                  # 私钥
                  SSH_PRIVATE_KEY: ${{ secrets.PRIVATE_KEY }}
                  # scp参数
                  ARGS: '-avzr --delete'
                  # 源目录
                  SOURCE: 'dist'
                  # 服务器ip：换成你的服务器IP
                  REMOTE_HOST: ${{ secrets.REMOTE_HOST }}
                  # 用户
                  REMOTE_USER: 'root'
                  # 目标地址(存放项目的地址)
                  TARGET: '/www/wwwroot'
```

### 6.3 github 设置

```bash
# 1 配置 服务器IP：
	-- 路径： [Setting] -> [Security] -> [Secretes and variables] -> [Action]
	-- 新建 secrets:
		Name: REMOTE_HOST
		Secret: 84.86.26.212
# 2 配置 密钥：
	-- 路径： [Setting] -> [Security] -> [Secretes and variables] -> [Action]
	-- 新建 secrets:
		Name: PRIVATE_KEY
		Secret: 复制粘贴所有密钥信息
```

