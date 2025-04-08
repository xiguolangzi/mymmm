# 《rabbitmq使用》

## 一. linux 安装

### 	1 compose 安装： 
​	-- 参考docker资料

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
     * 持久化队列 durable
     * @return
     */
@Bean
public Queue orderQueue() {
  System.out.println("创建队列：" + ORDER_QUEUE);
  return QueueBuilder.durable(ORDER_QUEUE)	// 1 durable 持久化
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
    // 2 发送队列消息 默认持久化
    rabbitTemplate.convertAndSend(OrderDirectMQConfig.ORDER_EXCHANGE, OrderDirectMQConfig.ORDER_ROUTER_KEY, salesOrder, correlationData);
  }

}catch (Exception e){
  log.error("异步处理 库存失败:",e);
}
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
    .lazy() // 设置为惰性队列
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

### 	1 生产者指定时间发送消息

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

​	







