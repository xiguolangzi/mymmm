# 《RustDesk 远程部署使用》

## 1 服务器部署：

### 1.1 设置路由器
hHhaJY3mDra9!
```
// 1 路由器 开放端口：
-- 直接设置 "NAP/ACP"
-- TCP：21114-21119
-- UDP：21116

// 2 服务器 防火墙开放端口：
-- TCP：21114-21119
-- UDP：21116
sudo ufw allow 21115/tcp
sudo ufw allow 21116/tcp
sudo ufw allow 21116/udp
sudo ufw allow 21117/tcp
sudo ufw allow 21117/tcp
sudo ufw allow 21118/tcp
sudo ufw allow 21119/tcp
```

### 1.2 docker 安装

1Panel liunx左面管理平台 - 部署docker 服务

​	-- 1 【容器】-【编排】- 创建编排
	-- 2 文件名随意命名，后缀为.yaml -> 粘贴如下代码，修改IP及key信息，并点击确认开始编排

```yaml
networks:
  rustdesk-net:
    external: false
services:
  hbbs:
    container_name: hbbs
    ports:
      - 21115:21115
      - 21116:21116 # 自定义 hbbs 映射端口
      - 21116:21116/udp # 自定义 hbbs 映射端口
      - 21118:21118 # web client
    image: rustdesk/rustdesk-server
    command: hbbs -r <你的服务器IP/域名>:21117 -k <自定义key> # 填入个人域名或 IP + hbbr 暴露端口 并输入自定key
    volumes:
      - /data/rustdesk/hbbs:/root # 自定义挂载目录
    networks:
      - rustdesk-net
    depends_on:
      - hbbr
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 64M
  hbbr:
    container_name: hbbr
    ports:
      - 21117:21117 # 自定义 hbbr 映射端口
      - 21119:21119 # web client
    image: rustdesk/rustdesk-server
    command: hbbr -k <自定义key> #输入自定义key
    #command: hbbr
    volumes:
      - /data/rustdesk/hbbr:/root # 自定义挂载目录
    networks:
      - rustdesk-net
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 64M
  rustdesk-api:
    container_name: rustdesk-api
    environment:
      - TZ=Asia/Shanghai
      - RUSTDESK_API_RUSTDESK_ID_SERVER=<你的服务器IP/域名>:21116 #输入你的服务器IP/域名
      - RUSTDESK_API_RUSTDESK_RELAY_SERVER=<你的服务器IP/域名>:21117 #输入你的服务器IP/域名
      - RUSTDESK_API_RUSTDESK_API_SERVER=http://<你的服务器IP/域名>:21114 #输入你的服务器IP/域名
      - RUSTDESK_API_RUSTDESK_KEY=<自定义key> #输入自定义key
    ports:
      - 21114:21114
    image: lejianwen/rustdesk-api
    volumes:
      - /data/rustdesk/api:/app/data #将数据库挂载出来方便备份
    networks:
      - rustdesk-net
    restart: unless-stopped

```

通过以上操作，我们直接在docker里创建了服务器和API容器，ID/中继服务器可以直接使用！

### 1.3 后台访问服务器

http://<你的服务器IP/域名>:21114 -> 默认账号 admin admin



### 1.4 部署自己的客户端

将配置信息写入代码中 ，

文档：https://www.smianao.com/1323.html  

视频：https://www.bilibili.com/video/BV18q23YgEGF?spm_id_from=333.788.videopod.sections&vd_source=90ff53fe44d29e00ed0199e3c93004c2



### 1.5 定期修改key

--1Panel -> 容器 -> 编排 -> 修改key -> 重启容器！


------------------------------若依环境部署：
机器：192.168.1.44
前端：1panel 部署网站
后端：/home/ruoyi-vue/server
后端文件：/home/ruoyi/uploadFile
后端日志: /home/ruoyi/log
后端执行命令：nohup java -jar ruoyi-admin.jar &


