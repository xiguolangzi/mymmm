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

# 4 查看远程仓库挂载情况
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

```

