# Linux 操作系统 安装及命令

## 一  docker



## 二 Ubantu Linux

### 1 安装操作系统：

#### 	1.1  制作启动盘：

##### 			A 下载  rufus

​		制作启动盘的工具，可以将 镜像文件写入 U盘中；
		下载官网：https://rufus.ie/zh/

##### 			B 下载 Ubantu 镜像文件 

​		官网：https://ubuntu.com/download/desktop

##### 			C 制作启动盘：

​		制作启动盘会清空启动盘信息，先备份好！

#### 	1.2 安装操作系统

​		Boot 界面 -> 直接选择 启动U盘 -> 安装系统；

#### 	1.3 安装必要软件：

```dockerfile
# 1 先升级 apt 包管理工具
sudo apt update

# 2 安装查看网络配置 ifconfig
sudo apt install net-tools

# 3 安装远程 ssh服务
sudo apt install openssh-server
# 3.1 启动并设置开机自启动
sudo systemctl start ssh
sudo systemctl enable ssh
# 3.2 查看安装状态
sudo systemctl status ssh
```

#### 	1.4 设置固定 ip

```bash
# 1 查看网卡名称
ip addr

# 2 修改配置文件 
sudo vim /etc/netplan/01-netcfg.yaml

# 3 文件内容如下：
network:
  version: 2
  ethernets:
    enp0s3:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      gateway4: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
# dhcp4: no 表示禁用 DHCP
# addresses 指定固定 IP 地址和子网掩码，例如 192.168.1.100/24
# gateway4 指定默认网关，例如 192.168.1.1
# nameservers 指定 DNS 服务器地址，例如 Google 的公共 DNS 8.8.8.8 和 8.8.4.4

```



### 2 快捷键

```bash
# 1 开启终端
ctrl + alt + t

# 2 
```



### 3 常用命令

```bash
# 1 安装软件
sudo apt install 软件名

# 2 重启
shutdown -r now
shutdown -r 10	# 10分钟之后
shutdown -r 20:35	# 20:35 时

# 3 关机
shutdown -h now
shutdown -h 10
shutdown -c # 取消关机

# 4 文件编辑
mkdir -p /mydata/redis/conf
touch 文件名
vim 文件名 -> i -> esc -> :wq!
cat 文件名

# 5 查看系统时区
date -R
# 5.1 选择时区
tzselect

# 上传文件
rz

# 6 docker 验证容器时区
docker exec -it nacos-server date

# 7 docker 自启动 容器
docker update 容器名 --restart=always
docker update mysql --restart=always

# 8 docker 切换网卡
docker network connect okYun sentinel-dashboard
docker inspect sentinel-dashboard

# 9 docker 卸载容器
docker stop mysql2 && docker rm mysql2



```



### 4 安装docker

```bash
======== Ubantu版本 ： Ubuntu 24.04 LTS ============
# 0 先卸载docker ,避免之前安装过
sudo apt remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logratate docker-logratate docker-engime

# 1 更新现有的软件包列表并安装系统更新
sudo apt update
sudo apt upgrade -y

# 2 安装了 Docker 所需的依赖包
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y

# 3 确保从官方源下载的软件包的真实性，添加 Docker 的官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 4 将 Docker 软件包源添加到 APT 源列表中
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 5 更新软件包列表以包含 Docker 软件包
sudo apt update

# 6 安装 Docker CE (Community Edition)
sudo apt install docker-ce -y

# 7 启动并验证 Docker
sudo systemctl start docker
sudo systemctl enable docker
sudo systemctl status docker

# 8 运行测试容器
sudo docker run hello-world

# 9 为了允许非 root 用户运行 Docker 命令，需要将用户添加到 docker 组中
sudo usermod -aG docker $USER

# 10 使用以下命令应用更改
newgrp docker

# 11 验证非 root 用户是否可以运行 Docker
docker run hello-world

# 12 切换到root用户
sudo -i

# 13 修改 docker 配置
sudo cat > /etc/docker/daemon.json << EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2",
  "live-restore": true
}
EOF

# 14 修改完配置重启docker
sudo systemctl restart docker

```

### 9 时区处理

#### 	9.1 环境部署时区

​	A docker 默认是 **UTC时区**，0时区；
	B 如果容器默认不是 UTC时区，创建容器时 需要确定时区 e TZ=UTC
	C 数据库配置设置时区 UTC 方式如下：

```bash
# 方案一 ：配置文件设置时区
[mysqld]
default-time-zone='+00:00'

# 方案二 ：创建容器设置时区
docker run -d -e TZ=UTC -e MYSQL_ROOT_PASSWORD=my-secret-pw --name mysql-container mysql:latest --default-time-zone='+00:00'

# docker 验证容器时区
docker exec -it 容器ID date
```

#### 	9.2 后端时区

​	统一使用 UTC时间，TZ=UTC

```java
@RestController
public class TimeController {

    @GetMapping("/time")
    public ResponseEntity<String> getCurrentTime() {
        Instant now = Instant.now();
        return ResponseEntity.ok(now.toString());
    }
}
```

#### 	9.3 前端时区处理

​	前端要求 根据不同时区，展示对应的时间 -> 将 UTC时间 转成 当地时间，考虑夏令时！

```js
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Local Time Display</title>
</head>
<body>
    <div id="localTime"></div>

    <script>
        fetch('/time')
            .then(response => response.text())
            .then(utcDateStr => {
                const utcDate = new Date(utcDateStr);
                const userTimeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
                const localDateStr = new Intl.DateTimeFormat('en-US', {
                    timeZone: userTimeZone,
                    year: 'numeric',
                    month: '2-digit',
                    day: '2-digit',
                    hour: '2-digit',
                    minute: '2-digit',
                    second: '2-digit'
                }).format(utcDate);
                document.getElementById('localTime').textContent = localDateStr;
            })
            .catch(error => console.error('Error fetching time:', error));
    </script>
</body>
</html>

```



### 5 创建自定义网络

```bash
# 查看已有网卡
docker network ls

# 创建自定义网卡
docker network create okYun

# 查看网卡信息
 docker network inspect okYun
```

### 6 安装 Mysql

#### 	6.1 拉取镜像

拉取所需版本的镜像

```bash
#  拉取镜像
docker pull mysql:5.7
docker pull mysql
```

#### 	6.2 准备配置文件

字符集默认的话不需要配置配置文件conf

```bash
# 2 准备配置文件
==== conf/xxx.cnf 配置字符集 =====
[client]
default_character_set=utf8mb4
[mysql]
default_character_set=utf8mb4
[mysqld]
character_set_server=utf8mb4
collation_server=utf8mb4_unicode_ci
init_connect='SET NAMES utf8mb4'

==== init/xxx.sql 初始化数据库、表 ======
-- 导出 hmall 的数据库结构
CREATE DATABASE IF NOT EXISTS `hmall` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `hmall`;

-- 导出  表 hmall.address 结构
CREATE TABLE IF NOT EXISTS `address` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL COMMENT '用户ID',
  `province` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '省',
  `city` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '市',
  `town` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '县/区',
  `mobile` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '手机',
  `street` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '详细地址',
  `contact` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '联系人',
  `is_default` varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '是否是默认 1默认 0否',
  `notes` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL COMMENT '备注',
  PRIMARY KEY (`id`) USING BTREE,
  KEY `user_id` (`user_id`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=64 DEFAULT CHARSET=utf8mb3 ROW_FORMAT=COMPACT;
。。。。。。
```

#### 	6.3 安装mysql

```bash
# 创建并启动容器 + 挂载数据卷 + 配置网络
docker run -d -e TZ=UTC -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --name mysql2 -p 3307:3306 -e MYSQL_ROOT_PASSWORD=123456 -v /mydata/mysql2/data:/var/lib/mysql -v /mydata/mysql2/conf:/etc/mysql/conf.d -v /mydata/mysql2/init:/docker-entrypoint-initdb.d --network okYun  --restart=always mysql --default-time-zone='+00:00'
# -d 后台运行
# --name 容器名
# -p 容器与宿主机端口映射
# -e 配置信息
# -v 挂载数据卷
# --netwoek 绑定网卡
# -v /etc/localtime:/etc/localtime:ro 确保容器时区与宿主机一致
# 设置时区 -e TZ=UTC --default-time-zone='+00:00'
```

#### 	6.4 mysql 开机自启动

```bash
# 设置docker 自启动 容器
docker update 容器名 --restart=always
docker update mysql --restart=always
```

### 7 安装redis

#### 	7.1 拉取镜像

```bash
docker pull redis
```

#### 	7.2 配置文件

​	/mydata/redis/conf/redis.conf
		--bind 		允许外网访问
		--requirepass	设置登录需要密码

```
cat > /mydata/redis/conf/redis.conf << EOF
bind 0.0.0.0
requirepass 19910129
EOF
```

#### 	7.3 安装redis

```bash
docker run -it --network okYun -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro --name redis --restart=always -p 6379:6379 -d -v /mydata/redis/conf:/usr/local/etc/redis  redis redis-server /usr/local/etc/redis/redis.conf

#-v /etc/localtime:/etc/localtime:ro 容器时区与宿主机一致
```

#### 	7.4 设置开机自启动

```bash
docker update redis --restart=always

# 查看redis配置
docker inspect redis
```

#### 	7.5 登录redis

```bash
# 登录命令
docker exec -it redis redis-cli -h your-server-ip -p 6379 -a yourpassword
docker exec -it redis redis-cli -a 19910129
```



### 8 安装 nacos

#### 	8.1 拉取镜像

```bash
# docker 拉取 nacos 镜像 -slim代表精简版，更小更安全
docker pull nacos/nacos-server:v2.2.3-slim

# 删除镜像
docker rmi nacos
```

#### 	8.2 配置文件

将 Nacos 配置文件 放到 / nacos/ custom.env

```bash
# 表示优先使用 主机名(hostname) 还是 IP地址(ip)
PREFER_HOST_MODE=hostname
# Nacos 单服务节点的配置
MODE=standalone
# 下面的都是数据库配置
SPRING_DATASOURCE_PLATFORM=mysql
MYSQL_SERVICE_HOST=192.168.1.37
MYSQL_SERVICE_DB_NAME=nacos
MYSQL_SERVICE_PORT=3306
MYSQL_SERVICE_USER=root
MYSQL_SERVICE_PASSWORD=123456
MYSQL_SERVICE_DB_PARAM=characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true&useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=Europe/Madrid
# Nacos 2.2.0 开始需要开启鉴权
NACOS_AUTH_ENABLE=true
# Nacos 登录的用户名密码 - 没有如下的配置，启动 Nacos 会报错！！
NACOS_AUTH_IDENTITY_KEY=nacos123
NACOS_AUTH_IDENTITY_VALUE=nacos123
# Nacos JWT秘钥 Base64秘文
NACOS_AUTH_TOKEN=SecretKey012345678901234567890123456789012345678901234567890987456213
```

#### 	8.3 初始化nacos表

​	A mysql-schema.sql 文件获取：
		官网找到指定的版本，下载 -> 解压后，可以得到初始化sql文件
		D:\001 谷歌下载\nacos-server-2.2.3\nacos\conf 

​	B nacos 数据库，运行 mysql-schema.sql 文件

#### 	8.4 安装 nacos

```bash
# 1 安装 nacos
docker run -d --name nacos -e TZ=Europe/Madrid --env-file /mydata/nacos/custom.env -p 8848:8848 -p 9848:9848 -p 9849:9849 --restart=always nacos/nacos-server:v2.2.3-slim

# --env-file /nacos/custom.env 读取配置数据库文件
# -p 8848:8848 前段管理端口
# -e TZ=Europe/Madrid 容器时区与宿主机一致

# 2 查看安装过程日志 - 如果日志报错要解决错误问题
docker logs nacos -f

# 3 验证时区
docker exec -it nacos-server date

# 4 移除 nacos 容器
docker stop nacos && docker rm nacos
```



### 10 一键部署容器

#### 	10.1 Docker Compose ：

​	通过独立的docker-compsoe.yml模版文件，关联多个docker容器的快速部署；
	一个 Docker Compose 文件对应一个项目；

#### 	10.2 compose 文件格式

```yaml
# 0 项目版本
version: "3.8"

# 1 服务配置
services:
  # 1.1 微服务
  mysql:
    image: mysql            # 镜像文件
    container_name: mysql   # 服务名称
    ports:                  # 端口映射
      - "3306:3306"         
    environment:            # -e 配置项
      TZ: Asia/Shanghai
      MYSQL_ROOT_PASSWORD: 123
    volumes:                # 数据挂载
      - "./mysql/conf:/etc/mysql/conf.d"
      - "./mysql/data:/var/lib/mysql"
      - "./mysql/init:/docker-entrypoint-initdb.d"
    networks:               # 绑定网络
      - hm-net
  # 1.2 jar包部署
  hmall:
    build:                  # 构建镜像
      context: .
      dockerfile: Dockerfile
    container_name: hmall
    ports:
      - "8080:8080"
    networks:
      - hm-net
    depends_on:             # 依赖容器，compos 会先创建 mysql 再创建 该容器
      - mysql
  nginx:
    image: nginx
    container_name: nginx
    ports:
      - "18080:18080"
      - "18081:18081"
    volumes:
      - "./nginx/nginx.conf:/etc/nginx/nginx.conf"
      - "./nginx/html:/usr/share/nginx/html"
    depends_on:             # 依赖后端服务容器
      - hmall
    networks:
      - hm-net
# 2 网络配置
networks:
  hm-net:
    name: hmall
```

#### 	10.3 compos 命令

​	A 先将 jar包 和 compose.yml 配置文件 放置到指定目录 /data/project ；

​	B 执行compose命令，一键部署：

```bash
# 一键部署命令
docker compose up -d -f ./docker-compose.yml -p okyunProject

# compose 命令格式
docker compose [option] [command]

# option 参数：
-f	指定compose文件的路径和名称, 默认是当前路径下的 docker-compose.yml
-p	指定peoject名称, 默认是root

# commands 参数：
up		创建并启动所有容器
down	停止并移除所有容器和网络
ps		列出所有启动的容器
logs	查看指定容器的日志
stop	停止指定容器
start	启动指定容器
restart	重启指定容器
top		查看运行的进程
exec	进入指定容器
```

## 三 控制面板 1Panel

### 1 环境安装

```java
// 1 先安装 docker

// 2 按照官网提示安装 1panel

// 3 查看日志
docker logs openresty

// 4 登录信息
http://192.168.1.44:18500
账号：hubiao
密码：19910129
```

### 2 web 界面访问

```java
// Ip + 端口
http://192.168.1.44:18500

// 查看端口
netstat -ntlp
```

### 3 忘记密码

```java
// 修改密码
1pctl update password
```









