# 《rabbitmq使用》

## 一. linux 安装

### 	1 compose 安装： 
​	-- 参考docker资料

```yaml
name: okyun

services:
  rabbitmq:
    container_name: rabbitmq
    hostname: rabbitmq-okyun  # 固定主机名，用于生成稳定节点名,持久化数据必须设置！！！
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
      - RABBITMQ_DEFAULT_VHOST:okyun
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=123456
    volumes:
      - rabbitmq_plugin:/plugins	# 不可以挂载本地，否则倾向原生的插件
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



### 	2 版本：
​	-- rabbitmq:3.12.14-managent

### 	3 配置：
​	-- 限制内存
	-- 限制磁盘大小
	-- cpu使用百分比限制
​	-- 账号/密码
	-- 挂载 ：持久化路径、日志路径、 配置文件

## 二. springBoot3 配置

### 	1 配置信息

```xml
<!-- rabbitmq -->
<dependency>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-starter-amqp</artifactId>
</dependency>
```



```yaml
# Spring配置
spring:
  # rabbitmq配置
  rabbitmq:
    host: 192.168.1.44
    port: 5672
    username: admin
    password: 123456
    virtual-host: okyun
    publisher-confirm-type: none  # 生产确认机制 - 开启消息确认  correlated
    publisher-returns: false      # 生产确认机制 - 开启消息回退 true
    template:
      mandatory: true                   # 确保消息回退可用（必须配置）
    listener:
      simple:
        acknowledge-mode: manual  # 手动ACK,防止丢失消息
```

### 	2 处理序列化

```java
// RabbitMQConfig 自定义配置项
/**
* 消息转换器 - 表单JSON序列化
* @return
*/
@Bean
public Jackson2JsonMessageConverter jackson2JsonMessageConverter() {
  return new Jackson2JsonMessageConverter();
}
    
/**
* 创建消息模板
* @param connectionFactory
* @return
*/
@Bean
public org.springframework.amqp.rabbit.core.RabbitTemplate rabbitTemplate(ConnectionFactory connectionFactory) {
  org.springframework.amqp.rabbit.core.RabbitTemplate template = new org.springframework.amqp.rabbit.core.RabbitTemplate(connectionFactory);
  template.setMessageConverter(jackson2JsonMessageConverter()); // JSON 格式转换器
  return template;
}
```



## 三. 可靠性

### 	1 生产者可靠性

#### 		1.1 确认机制

```java
// 1 Applacation.yaml 配置 开启确认机制     
publisher-confirm-type: correlated  # 开启消息确认  correlated
publisher-returns: true      # 开启消息回退 true
  
// 2 自定义类 RabbitMqProducerConfirmConfig
 -- 确认消息是否到达交换机
 -- 确认消息是否到达队列
 -- 判断 ack ，成功/失败 -> 如果失败 重新发送消息
 
// 3 发送消息需要传递 UUID
try {
  // 生成唯一消息ID
  CorrelationData correlationData = new CorrelationData(UUID.randomUUID().toString());
  log.info("异步处理 库存, 订单信息 : {}",salesOrder);
  for (int i = 0; i < 1000000; i++)
  {
    rabbitTemplate.convertAndSend(OrderDirectMQConfig.ORDER_EXCHANGE, OrderDirectMQConfig.ORDER_ROUTER_KEY, salesOrder, correlationData);
  }

}catch (Exception e){
  log.error("异步处理 库存失败:",e);
}
```

#### 		1.2 持久化

```java
/**
* direct 类型的交换机
* @return
*/
@Bean
public DirectExchange orderExchange() {
  // 1 持久化交换机 true
  return new DirectExchange(ORDER_EXCHANGE, true, false);
}

/**
* 持久化队列 durable
* @return
*/
@Bean
public Queue orderQueue() {
  System.out.println("创建队列：" + ORDER_QUEUE);
  // 2 持久化队列
  return QueueBuilder.durable(ORDER_QUEUE)	
    .lazy() 
    .withArgument("x-dead-letter-exchange", "dead.letter.exchange")  
    .withArgument("x-dead-letter-routing-key", "dead.letter.routingKey")
    .build();
}


try {
  CorrelationData correlationData = new CorrelationData(UUID.randomUUID().toString());
  log.info("异步处理 库存, 订单信息 : {}",salesOrder);
  for (int i = 0; i < 1000000; i++)
  {
    // 3 消息持久化
    rabbitTemplate.convertAndSend(
                    OrderDirectMQConfig.ORDER_EXCHANGE,
                    OrderDirectMQConfig.ORDER_ROUTER_KEY,
                    salesOrder,
                    message -> {
                        // 3.1 消息持久化 .setDeliveryMode(2)
                        message.getMessageProperties().setDeliveryMode(MessageDeliveryMode.PERSISTENT);
                        return message;
                    }
            );

}catch (Exception e){
  log.error("异步处理 库存失败:",e);
}

// 4 持久化必须设置 固定主机名，否则每次compose重新启动都会生成新的容器ID，导致持久化文件名变化，最后持久化失败！！！
	compose.yaml 参数设置
	-- hostname: rabbitmq-okyun  # 固定主机名，用于生成稳定节点名,持久化数据必须设置！！
```

#### 		1.3 惰性模式

```java

/**
* 持久化队列 durable
* @return
*/
@Bean
public Queue orderQueue() {
  System.out.println("创建队列：" + ORDER_QUEUE);
  return QueueBuilder.durable(ORDER_QUEUE)
    .lazy() // 1 设置为惰性队列，已磁盘存储为主，先磁盘在缓存
    .withArgument("x-dead-letter-exchange", "dead.letter.exchange")  // 指定死信交换机
    .withArgument("x-dead-letter-routing-key", "dead.letter.routingKey") // 指定死信路由键
    .build();
}
```



### 	2 消费者可靠性

#### 	2.1 消费者确认机制

```yaml
listener:
  simple:
    acknowledge-mode: auto  # manual 手动ACK,防止丢失消息； auto 自动ACK，默认为自动ACK; none 不做处理,默认为自动ACK
    
    # 使用场景：
    -- 支付、库存等严格业务 使用 手动确认 manual’
    -- 简单业务、允许重试的业务 使用 自动确认 auto；
```

#### 	2.2 重试机制

```yaml
listener:
  simple:
    acknowledge-mode: auto  # manual 手动ACK,防止丢失消息； auto 自动ACK，默认为自动ACK; none 不做处理,默认为自动ACK
    retry:
    enabled: true
    initial-interval: 1000  # 初始重试间隔 1 秒
    multiplier: 2.0          # 每次重试间隔 *2
    max-attempts: 3          # 最大重试 3 次
    
 
```

#### 	2.3 错误队列 error

```bash
# 绑定死信队列，处理失败直接写入死信队列！
```



### 	3 幂等性

#### 		3.1 校验消息ID

```bash
#  1 开启消息ID
配置 RabbitMQConfig 消息转换器中启用消息ID
/**
     * 消息转换器 - 表单JSON序列化
     * @return
     */
     @Bean
     public Jackson2JsonMessageConverter jackson2JsonMessageConverter() {
       Jackson2JsonMessageConverter jjmConverter = new Jackson2JsonMessageConverter();
       // 启用消息ID UUID 生成
       jjmConverter.setCreateMessageIds(true);
       return jjmConverter;
    }
    
 # 2 处理消息将消息ID写入数据库
 
 # 3 每次处理消息检查是否有相同的消息ID，有则不处理
 
 # 4 这种方式的缺点：植入了外部业务，增加了数据库的操作，所以不推荐
```

#### 	3.2 业务层处理

```bash
# 1 处理消息时，sql判断
	-- 修改支付状态举例，每次修改添加状态条件；
	-- 删除操作原本就是幂等；
```



### 	4 兜底方案

```bash
# 1 如果确实消息处理异常

# 2 将异常消息放到私信队列

# 3 定时任务轮训 处理异常消息
	-- 查询待处理的订单数据
	-- 根据支付数据、订单数据 对比，如果存在已支付的数据，修改订单状态！

# 4 人工介入处理

```



## 四 延时消息

### 	1 延时消息 - 使用场景

```bash
# 1 使用场景
	-- 抢购付款环节，限制1分钟之内支付，未支付直接取消消息发送！
	-- 1分钟倒计时，如果付款，直接发送消息，处理后续业务！
	
# 2 实现方式1
	-- 通过消息设置延时过期时间 30s；
	-- 过期后 消息发送到私信队列；
	-- 处理死信队列中的消息；
	
# 3 实现方式2
	-- 使用插件 rabbitmq_delayed_message_exchage
	-- 将插件放到 rabbitmq docker挂载的插件目录中
	-- 重启容器 执行插件的命令: docker run ... rabbitmq-plugins enable rabbitmq_delayed_message_exchage
	-- 交换机添加 delay 配置
	-- 发送消息时添加 delay配置 .setDelay(5000)
	
# 4 延时消息不推荐，应为只要是延时消息都会有监听时钟，增加内存的使用！

# 5 如果必须使用延时消息；
	-- 将延时设置成多个时间段，比如1分钟 拆成 10s 10s 20s 20s
	-- 10s 后交换机 发送到队列 -> 队列检查判断是否支付，如果未支付继续发送 一次 时间段的延时发送 -> 最后错误处理，取消订单！
	-- 这样如果常规下10s可以处理的业务，就不至于等到1分钟的内存占用！
```

### 2 安装 延时插件	

```bash
# 1 github 下载延时插件 rabbitmq_delayed_message_exchange
地址：https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases

# 2 下载对应的版本：
我的是 3.12.14 所以插件版本 3.12.0
插件文件格式：rabbitmq-delayed-message-exchange-3.12.0.ez

# 3 将插件放到 rabbitmq 安装映射路径下
docker inspect rabbitmq
	{
  	"Type": "volume",
  	"Name": "okyun_rabbitmq_plugin",
  	"Source": "/var/lib/docker/volumes/okyun_rabbitmq_plugin/_data",
  	"Destination": "/plugins",
  	"Driver": "local",
  	"Mode": "z",
  	"RW": true,
  	"Propagation": ""
  },
cd /var/lib/docker/volumes/okyun_rabbitmq_plugin/_data
-> 将插件放入该目录下
	
# 4 执行安装执行插件的命令
docker exec -it rabbitmq rabbitmq-plugins enable rabbitmq_delayed_message_exchange
	
# 5	成功安装如下：
hubiao@hubiao-ideacentre-Y700-34ISH:~$ docker exec -it rabbitmq rabbitmq-plugins enable rabbitmq_delayed_message_exchange
Enabling plugins on node rabbit@5d5294e1246a:
rabbitmq_delayed_message_exchange
The following plugins have been configured:
  rabbitmq_delayed_message_exchange
  rabbitmq_management
  rabbitmq_management_agent
  rabbitmq_prometheus
  rabbitmq_web_dispatch
Applying plugin configuration to rabbit@5d5294e1246a...
The following plugins have been enabled:
  rabbitmq_delayed_message_exchange

started 1 plugins.
hubiao@hubiao-ideacentre-Y700-34ISH:~$ 

# 6 验证延时插件
docker exec -it rabbitmq rabbitmq-plugins list | grep delayed

# 7 重启rabbitmq 容器
docker compose down
docker compose up -d

```

### 3   使用 延时插件

#### 		3.1 配置延时交换机

```java
package com.ruoyi.rabbitmq.config;

import org.springframework.amqp.core.*;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.HashMap;
import java.util.Map;

/**
 * 订单初始化队列配置
 */
@Configuration
public class OrderDirectMQConfig {

    /**
     * 订单交换机
     */
    public static final String ORDER_EXCHANGE = "order.exchange";
    /**
     * 订单队列
     */
    public static final String ORDER_QUEUE = "order.queue";
    /**
     * 订单路由键
     */
    public static final String ORDER_ROUTER_KEY = "order.routingKey";
    /**
     * 延时消息专用交换机
      */
    public static final String DELAYED_ORDER_EXCHANGE = "order.delayed.direct";

    /**
     * direct 类型的交换机
     * @return
     */
    @Bean
    public DirectExchange orderExchange() {
        return new DirectExchange(ORDER_EXCHANGE, true, false);
    }

    /**
     * 延迟交换机
     * @return
     */
    @Bean
    public CustomExchange delayedOrderExchange() {
        Map<String, Object> args = new HashMap<>();
        args.put("x-delayed-type", "direct"); // 使用 direct 类型路由
        return new CustomExchange(DELAYED_ORDER_EXCHANGE, "x-delayed-message", true, false, args);
    }


    /**
     * 持久化队列 durable
     * @return
     */
    @Bean
    public Queue orderQueue() {
        System.out.println("创建队列：" + ORDER_QUEUE);
        return QueueBuilder.durable(ORDER_QUEUE)
                .lazy() // 设置为惰性队列 （等效于 x-queue-mode=lazy）
                .withArgument("x-dead-letter-exchange", "dead.letter.exchange")     // 指定死信交换机
                .withArgument("x-dead-letter-routing-key", "dead.letter.routingKey") // 指定死信路由键
                .build();
    }

    /**
     * 常规绑定
     * @param orderQueue
     * @param orderExchange
     * @return
     */
    @Bean
    public Binding orderBinding(Queue orderQueue, DirectExchange orderExchange) {
        return BindingBuilder.bind(orderQueue).to(orderExchange).with(ORDER_ROUTER_KEY);
    }

    /**
     * 延时消息绑定
     */
    @Bean
    public Binding delayedOrderBinding() {
        return BindingBuilder.bind(orderQueue()).to(delayedOrderExchange()).with(ORDER_ROUTER_KEY)
                .noargs(); // CustomExchange需要noargs()
    }
}

```

#### 	3.2 正常发送消息

```java
/**
     * 通过MQ异步更新库存
     * @param salesOrder
     */
    private void updateInventoryByMQ(SalesOrder salesOrder) {
        // 异步处理 库存
        long start = System.currentTimeMillis();
        try {
            log.info("异步处理 库存, 订单信息 : {}",salesOrder);
            rabbitTemplate.convertAndSend(OrderDirectMQConfig.ORDER_EXCHANGE, OrderDirectMQConfig.ORDER_ROUTER_KEY, salesOrder);
        }catch (Exception e){
            log.error("异步处理 库存失败:",e);
        }
        log.info("处理耗时: {}ms", System.currentTimeMillis() - start);
    }
```

#### 	3.3 发送延时消息

```java
@Component
@Slf4j
public class InventoryConsumer {

    @Autowired
    private RabbitTemplate rabbitTemplate;


    /**
     * 监听订单队列，处理库存扣减
     * @param salesOrder
     * @param channel
     * @param deliveryTag
     * @throws IOException
     */
    @RabbitListener(queues = OrderDirectMQConfig.ORDER_QUEUE)
    public void processMessage(@Payload SalesOrder salesOrder , Channel channel,
                               @Header(AmqpHeaders.DELIVERY_TAG) long deliveryTag,
                               @Header(name = "x-retry-count", required = false) Integer retryCount
    ) throws IOException {
        try
        {
            // 处理库存扣减
            System.out.println("Received Order: " + salesOrder);
            // 手动 ACK 确认消息
            channel.basicAck(deliveryTag, false);
        } catch (LockAcquisitionException e)
        {
            // 锁获取失败的特殊处理
            int newRetryCount = (retryCount == null) ? 1 : retryCount + 1;
            if (newRetryCount > 3)
            {
                // 超过最大重试次数进入死信队列
                log.error("重试第 {} 次，发送死信队列消息：{}", newRetryCount, salesOrder);
                channel.basicNack(deliveryTag, false, false);
            } else
            {
                // 1 重新通过延时交换机 将消息延时发送到队列
                rabbitTemplate.convertAndSend(
                        OrderDirectMQConfig.DELAYED_ORDER_EXCHANGE,
                        OrderDirectMQConfig.ORDER_ROUTER_KEY,
                        salesOrder,
                        message -> {
                            // 5.1 持久化
                            message.getMessageProperties().setDeliveryMode(MessageDeliveryMode.PERSISTENT);
                            // 5.2 设置消息头部属性：重试次数
                            message.getMessageProperties().setHeader("x-retry-count", newRetryCount);
                            // 5.3 设置消息头部属性：延迟时间
                            message.getMessageProperties().setHeader("x-delay", calculateDelay(newRetryCount));
                            return message;
                        }
                );
                log.info("重试第 {} 次，延迟 {}ms 重新发送消息：{}", newRetryCount, calculateDelay(newRetryCount), salesOrder);
                // 确认原消息
                channel.basicAck(deliveryTag, false);
            }
        }
        catch (Exception e)
        {
            // 发生异常，拒绝消息并发送到死信队列
            log.error("消费异常订单数据: {}, 异常报错信息：",salesOrder, e);
            // 手动 NACK，失败的直接 拒绝， 不重回队列， 直接写入死信队列
            channel.basicNack(deliveryTag, false, false);
        }
    }

    /**
     * 动态退避策略（示例：10s, 20s, 30s）
     */
    private int calculateDelay(int retryCount) {
        return 10_000 * retryCount;
    }
}
```

## 五 . 常见问题解决

### 1  rabbitmq 配置了持久化不生效

​	1.1 问题原因：

```bash
# 1 查看服务部署挂载的数据目录
cd /home/files/rabbitmq/data/mnesia

# 2 每次重启mq服务，数据文件名都会更新，导致读取最新的数据文件无法获取到之前持久的数据；

# 3 需要解决办法就需要数据文件名固定不变，所以需要添加 hostname 配置；
```

​	1.2 解决问题：部署rabbitmq环境时需要添加配置:  " hostname "

```yaml
# compose.yaml
name: okyun

services:
  rabbitmq:
    container_name: rabbitmq
    hostname: rabbitmq-okyun  # 注意：固定主机名，用于生成稳定节点名,持久化数据必须设置！！！
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
      - RABBITMQ_DEFAULT_VHOST:okyun
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=123456
    volumes:
      - rabbitmq_plugin:/plugins
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

