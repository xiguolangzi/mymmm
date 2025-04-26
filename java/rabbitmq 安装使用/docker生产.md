# 《docker》

## 一.docker 安装

```
参考视频：https://www.bilibili.com/video/BV1BE6PYUESb?spm_id_from=333.788.videopod.episodes&vd_source=90ff53fe44d29e00ed0199e3c93004c2&p=6
```





## 二.docker 镜像

### 	1 检索镜像

```bash
docker search rabbitmq
# name	: 镜像名称
# description	: 镜像描述
# stars	: 镜像starts数量
# official	: 是否官方[OK]
# 查看所有镜像的版本 https://hub.docker.com
```

### 	2 下载镜像

```bash
docker pull rabbitmq:版本号
# 查看所有镜像的版本 https://hub.docker.com
```

### 	3 查看镜像列表

```bash
docker images
```

### 	4 删除镜像

```bash
docker rmi 镜像名称
```



## 三.docker 操作容器

### 	1 常用命令

```bash
# 1 运行 docker run
	-d 		# 后台运行
	--name	# 容器名称
	-p 		# 端口映射 外部端口:内部端口
	-v		# 目录挂载(外部挂载目录:映射容器内部的目录)
	-e		# 配置

# 2 查看 docker ps : 查看所有运行中的容器信息
	docker ps		# 查看所有运行中的容器信息
	docker ps -a 	# 查看所有容器信息,包括停止的容器
	docker ps -aq	# 只返回所有容器的ID
# 3 停止 docker stop
	docker stop 容器名称/容器ID
# 4 启动 docker start
	docker start 容器名称/容器ID
# 5 状态 docker stats：查看你资源占用信息
	docker start 容器名称/容器ID
# 6 进入 docker exec
	docker exec -it 容器名称				# 进入到容器
	docker exec -it 容器名称 /bin/bash		# 进入到容器 , 并使用终端方式进行交互

# 7 删除 docker rm
	docker rm 容器名称/容器ID			# 删除之前需要停止容器
	docker em -f 容器名称/容器ID		# 强制删除
	docker rm $(docker ps -aq)		# 删除所有容器

# 8 查看容器运行的日志
	docker logs 容器名称/容器ID
	
# 9 查看容器的细节(网络等配置信息)
docker inspect 容器名

```

### 	2 保存自定义镜像

```bash
# 1 提交 docker commit
	docker commit -m "修改容器信息" 容器名称/容器ID 自定义的镜像名:版本号 
    docker images	# 可以查看到自定义新增的容器
	
# 2 保存 docker save
	docker save 自定义的镜像名:版本号
	docker save -o 自定义的镜像名.tar  自定义的镜像名:版本号		# 在当前路径下 生成 tar包

# 3 加载 docker load
	docker load -i 自定义的镜像名.tar	# 生成自定义的镜像
```

### 	3 分享社区

```bash
# 1 登录 docker login
	docker login -> 用户名 密码	# https://hub.docker.com 的用户名密码
# 2 命名 docker tag
	docker tag 自定义的镜像名 用户名/新镜像名	# 生成的镜像名 = "用户名/新镜像名"
# 3 推送 docker push
	docker push 用户名/新镜像名


```



## 四. docker存储

### 	1 目录挂载

```bash
docker run -d -p 99:80 -v /app/nghtml:/usr/share/nginx/html --name mynginx nginx
# -v 将内部目录/usr/share/nginx/html 挂载到 外部目录 /app/nghtml
# 初始安装容器的时候，会直接加载外部目录，如果外部目录是空就会安装容器失败！
```

### 	2 卷映射

```bash
docker run -d -p 99:80 -v /app/nghtml:/usr/share/nginx/html -v nghtml:/etc/nginx --name mynginx nginx
# -v nghtml:/etc/nginx 此处的 -v 不是目录挂载，而是卷映射
# 卷映射的区别是 ：
	# 1 没有指定的目录 只有卷名称；
	# 2 卷映射会自动映射初始内容，不影响启动容器；
	# 3 卷默认路径：/var/lib/docker/volumes/卷名称
```

### 	3 查看存储

```bash
docker volume ls
```



## 五.自定义网络

### 	1 查看容器的细节

```bash
# 1 查看容器的细节(网络等信息)
docker inspect 容器名

```

### 	2 创建自定义网络

```bash
# 创建自定义网络
docker network create mynet
```

### 	3 容器加入自定义网络

```bash
# 启动容器绑定自定义网络
docker run -d -p 88:80 --name app1 --network mynet nginx	# --network 自定义网络名称 绑定自定义网络
```

### 	4 redis 主从同步

```bash
# 1 redis 主 master
docker run -d -p 6379:6379 \
-v /app/rd1:/bitnami/redis/data \
-e REDIS_REPLICATION_MODE=master \
-e REDIS_PASSWORD=123456 \
--network mynet --name redis01 \
bitnami/redis

# 2 redis 从 master
docker run -d -p 6380:6379 \
-v /app/rd2:/bitnami/redis/data \
-e REDIS_REPLICATION_MODE=slave \
-e REDIS_PASSWORD=123456 \
-e REDIS_MASTER_HOST=redis01 \
-e REDIS_MASTER_PORT_NUMBER=6379 \
-E REDIS_MASTER_PASSWORD=123456 \
--network mynet --name redis02 \
bitnami/redis

# 3 可能出现的问题：/app/rd1 目录权限会导致启动失败，给777权限就好了
```



## 六 docker compose

### 	1 compose.yaml文件

```yaml
# 1 名称
name: myblog
# 2 部署容器
services:
	# 服务名
	mysql:
		# 2.1 容器名 --name
		container_name: mysql
		# 2.2 镜像文件
		image: mysql:8.0
		# 2.3 端口映射 -p
		ports:
			- "3306:3306"
		# 2.4 环境变量 -e
		environment:
			- MYSQL_ROOT_PASSWORD=123456
			- MYSQL_DATABASE=wordpress
		# 2.5 挂载目录/挂载卷 -v
		volumes:
			- mysql-data:/var/lib/mysql
			- /app/myconfig:/etc/mysql/conf.d
		# 2.6 自启动 --restart
		restart: always
		# 2.7 绑定网络 --network
		networks:
			- blog
			
	
	wordpress:
		image: wordpress
		ports:
			- "8080:80"
		environment:
			WORDPRESS_DB_HOST: mysql
			WORDPRESS_DB_USER: root
			WORDPRESS_DB_PASSWORD: 123456
			WORDPRESS_DB_nAME: wordpress
        volumes:
        	- wordpress:/var/www/html
        restart: always
        networks:
			- blog
		# 2.8 依赖容器
		depends_on:
			- mysql

# 3 声明 卷
volumes:
	mysql-data:
	wordpress:
# 4 声明 自定义网络
networks:
	blog:
```

### 	2 启动 compose.yaml文件

```bash
# 1 后台启动，默认文件名"compose.yaml"
docker compose up -d	

# 2 指定compose文件名
docker compose -f 文件名.yaml up -d

# 3 清除容器(不清除挂载和映射)
docker compose -f 文件名.yaml down

# 4 清除容器(清除挂载和映射)
docker compose -f 文件名.yaml down --rmi all -v
```



## 七 制作自己的镜像

### 	1 编写dockerfile 文件的指令

```bash
FROM			# 指令镜像基础环境
RUN				# 运行自定义命令
CMD				# 容器启动命令与参数
LABEL			# 自定义标签
EXPOSE			# 指定暴露端口
ENV				# 环境变量
ADD				# 添加文件到镜像
COPY			# 复制文件到镜像
ENTRYPOINT		# 容器固定启动命令
VOLUME			# 数据卷
USER			# 指定用户和用户组
WORKDIR			# 指定默认工作目录
ARG				# 指定构造参数
```

### 	2 示例  vim Dockerfile -> wq

```bash
# 所需环境 jdk17
FROM openjdk:17

# 自定义标签
LABEL author=hubiao

# 当前路径下的jar包复制到镜像的jar包
COPY okyun.jar /okyun.jar

# 暴露端口
EXPOSE 8080

# 启动命令 java -jar /okyun.jar
ENTRYPOINT ["java","-jar","/okyun.jar"]

```

### 	3 制作镜像

```bash
# 1 okyun.jar 与 DockerFile 要在同一目录下

# 2 运行命令
docker build -f Dockerfile -t myapp:v1.0 .
	# -f 指定 Dockerfile 文件
	# -t 镜像名
	# . jar包所在目录 ./
```



## 八 生产部署

### 	1 compose.yaml 文件

```yaml
name: okyun

services:
  rabbitmq:
    container_name: rabbitmq
    hostname: rabbitmq-okyun  # 固定主机名，用于生成稳定节点名,持久化数据必须设置！！
    image: rabbitmq:3.12.14-management
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: "1.5"
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
    	- RABBITMQ_PLUGINS_DIR=/plugins
      - RABBITMQ_DEFAULT_VHOST:okyun
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=123456
    command: 
      - bash
      - -c
      - |
        # 启动时确保插件激活
        rabbitmq-plugins enable rabbitmq_delayed_message_exchange
        rabbitmq-server
    volumes:
      # ✅ 改成挂载单个插件（只放 .ez 文件即可）
      - ./rabbitmq/plugins/rabbitmq_delayed_message_exchange-3.12.0.ez:/plugins/rabbitmq_delayed_message_exchange-3.12.0.ez
      - ./rabbitmq/data:/var/lib/rabbitmq
      - ./rabbitmq/log:/var/log/rabbitmq
      - ./rabbitmq/config/rabbitmq.conf:/etc/rabbitmq/rabbitmq.conf
    restart: unless-stopped
    networks:
      - okyun

volumes:
  rabbitmq_plugin:
    driver: local

networks:
  okyun:
    driver: bridge
```

### 	2 初始化文件 init.sh

```bash
#!/bin/bash

set -e  # 遇到错误立即退出

# 检查 docker-compose
command -v docker-compose >/dev/null 2>&1 || { echo >&2 "❌ docker-compose 未安装，退出。"; exit 1; }

# 创建必要目录
mkdir -p ./rabbitmq/data ./rabbitmq/log ./rabbitmq/config ./rabbitmq/plugins

# 设置权限
chown -R 999:999 ./rabbitmq
find ./rabbitmq -type d -exec chmod 775 {} \;

# 下载延时插件
PLUGIN_FILE="./rabbitmq/plugins/rabbitmq_delayed_message_exchange-3.12.0.ez"
if [ ! -f "$PLUGIN_FILE" ]; then
  echo "⬇️ 正在下载插件..."
  wget -P ./rabbitmq/plugins/ \
    https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/v3.12.0/rabbitmq_delayed_message_exchange-3.12.0.ez \
    || { echo "❌ 插件下载失败，请检查网络或 URL 是否正确"; exit 1; }
fi
  
# 生成 RabbitMQ 配置文件
cat > ./rabbitmq/config/rabbitmq.conf << 'EOF'
# 内存阈值 (60%)
vm_memory_high_watermark.relative = 0.6
# 磁盘空间警报 (1GB)
disk_free_limit.absolute = 1GB
# 默认虚拟主机
default_vhost = okyun
# 其他配置 (按需添加)
loopback_users.guest = false
EOF

chmod 644 ./rabbitmq/config/rabbitmq.conf
chown -R 999:999 ./rabbitmq/data ./rabbitmq/log

# 启动服务
docker-compose down -v
docker-compose up -d

echo "⏳ 等待 RabbitMQ 启动..."
sleep 10

# 修复 .erlang.cookie 权限
docker exec rabbitmq bash -c "chmod 600 /var/lib/rabbitmq/.erlang.cookie || true"

# 验证插件启用
echo "🔍 插件启用状态："
docker exec rabbitmq rabbitmq-plugins list | grep delayed
```

### 	3 运行初始化文件

```bash
chmod +x init.sh && ./init.sh
```



## 九 docker 查用命令

```bash
# 1 查看你镜像
docker images

# 2 查看容器
docker ps
dpcker ps -a

# 3 移除容器
docker stop rabbitmq && docker rm rabbitmq

# 4 查看容器日志
docker logs rabbitmq

# 5 指定compose文件名
docker compose up -d
docker compose -f 文件名.yaml up -d

# 6 清除容器(不清除挂载和映射)
docker compose down
docker compose -f 文件名.yaml down
```



