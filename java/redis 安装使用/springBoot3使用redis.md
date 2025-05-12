# 《springBoot3 中使用redis》

## 一 springDataRedis 直接使用redis

### 1 maven配置

```xml
<!-- 直接操作 redis -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

### 2 配置 application.yaml 

```yaml
spring:
	  data:
      # redis 配置
      redis:
        # 地址
        host: 192.168.1.44
        # 端口，默认为6379
        port: 6379
        # 数据库索引
        database: 0
        # 密码
        password: 19910129
        # 连接超时时间
        timeout: 10s
        lettuce:
          pool:
            # 连接池中的最小空闲连接
            min-idle: 0
            # 连接池中的最大空闲连接
            max-idle: 8
            # 连接池的最大数据库连接数
            max-active: 8
            # #连接池最大阻塞等待时间（使用负值表示没有限制）
            max-wait: -1ms
```

### 3 创建配置文件

```java
package com.okyun.framework.config;

import org.springframework.cache.annotation.CachingConfigurerSupport;
import org.springframework.cache.annotation.EnableCaching;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.redis.connection.RedisConnectionFactory;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.script.DefaultRedisScript;
import org.springframework.data.redis.serializer.StringRedisSerializer;

/**
 * redis配置
 */
@SuppressWarnings("deprecation")
@Configuration
@EnableCaching
public class RedisConfig extends CachingConfigurerSupport
{
    @Bean
    @SuppressWarnings(value = { "unchecked", "rawtypes" })
    public RedisTemplate<Object, Object> redisTemplate(RedisConnectionFactory connectionFactory)
    {
        // 1 创建redis模板对象
        RedisTemplate<Object, Object> template = new RedisTemplate<>();
        // 2 设置连接工厂对象，去application中的连接信息
        template.setConnectionFactory(connectionFactory);

        // 3 自定义序列化器
        FastJson2JsonRedisSerializer serializer = new FastJson2JsonRedisSerializer(Object.class);

        // 4 使用StringRedisSerializer来序列化和反序列化redis的key值
        template.setKeySerializer(new StringRedisSerializer());
        // 5 使用fastjson2序列化器来序列化和反序列化redis的value值
        template.setValueSerializer(serializer);

        // 6 Hash的key也采用StringRedisSerializer的序列化方式
        template.setHashKeySerializer(new StringRedisSerializer());
        // 7 Hash的value也采用fastjson2序列化器
        template.setHashValueSerializer(serializer);
        // 8 刷新缓存
        template.afterPropertiesSet();
        // 9 返回
        return template;
    }

    @Bean
    public DefaultRedisScript<Long> limitScript()
    {
        DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>();
        redisScript.setScriptText(limitScriptText());
        redisScript.setResultType(Long.class);
        return redisScript;
    }

    /**
     * 限流脚本
     */
    private String limitScriptText()
    {
        return "local key = KEYS[1]\n" +
                "local count = tonumber(ARGV[1])\n" +
                "local time = tonumber(ARGV[2])\n" +
                "local current = redis.call('get', key);\n" +
                "if current and tonumber(current) > count then\n" +
                "    return tonumber(current);\n" +
                "end\n" +
                "current = redis.call('incr', key)\n" +
                "if tonumber(current) == 1 then\n" +
                "    redis.call('expire', key, time)\n" +
                "end\n" +
                "return tonumber(current);";
    }
}

```

### 4 封装直接使用redis 的方法

```jade
package com.okyun.common.core.redis;

import java.util.Collection;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import com.okyun.common.utils.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.BoundSetOperations;
import org.springframework.data.redis.core.HashOperations;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.stereotype.Component;

/**
 * spring redis 工具类
 **/
@SuppressWarnings(value = { "unchecked", "rawtypes" })
@Component
public class RedisCache
{
    @Autowired
    public RedisTemplate redisTemplate;

    /**
     * 缓存基本的对象，Integer、String、实体类等
     *
     * @param key 缓存的键值
     * @param value 缓存的值
     */
    public <T> void setCacheObject(final String key, final T value)
    {
        redisTemplate.opsForValue().set(key, value);
    }

    /**
     * 缓存基本的对象，Integer、String、实体类等
     *
     * @param key 缓存的键值
     * @param value 缓存的值
     * @param timeout 时间
     * @param timeUnit 时间颗粒度
     */
    public <T> void setCacheObject(final String key, final T value, final Integer timeout, final TimeUnit timeUnit)
    {
        redisTemplate.opsForValue().set(key, value, timeout, timeUnit);
    }

    /**
     * 设置有效时间
     *
     * @param key Redis键
     * @param timeout 超时时间
     * @return true=设置成功；false=设置失败
     */
    public boolean expire(final String key, final long timeout)
    {
        return expire(key, timeout, TimeUnit.SECONDS);
    }

    /**
     * 设置有效时间
     *
     * @param key Redis键
     * @param timeout 超时时间
     * @param unit 时间单位
     * @return true=设置成功；false=设置失败
     */
    public boolean expire(final String key, final long timeout, final TimeUnit unit)
    {
        return redisTemplate.expire(key, timeout, unit);
    }

    /**
     * 获取有效时间
     *
     * @param key Redis键
     * @return 有效时间
     */
    public Long getExpire(final String key)
    {

        return redisTemplate.getExpire(key, TimeUnit.MINUTES);
    }

    /**
     * 判断 key是否存在
     *
     * @param key 键
     * @return true 存在 false不存在
     */
    public Boolean hasKey(String key)
    {
        return redisTemplate.hasKey(key);
    }

    /**
     * 获得缓存的基本对象。
     *
     * @param key 缓存键值
     * @return 缓存键值对应的数据
     */
    public <T> T getCacheObject(final String key)
    {
        if (StringUtils.isEmpty(key)){
            return null;
        }
        ValueOperations<String, T> operation = redisTemplate.opsForValue();
        return operation.get(key);
    }

    /**
     * 删除单个对象
     *
     * @param key
     */
    public boolean deleteObject(final String key)
    {
        return redisTemplate.delete(key);
    }

    /**
     * 删除集合对象
     *
     * @param collection 多个对象
     * @return
     */
    public boolean deleteObject(final Collection collection)
    {
        return redisTemplate.delete(collection) > 0;
    }

    /**
     * 缓存List数据
     *
     * @param key 缓存的键值
     * @param dataList 待缓存的List数据
     * @return 缓存的对象
     */
    public <T> long setCacheList(final String key, final List<T> dataList)
    {
        Long count = redisTemplate.opsForList().rightPushAll(key, dataList);
        return count == null ? 0 : count;
    }

    /**
     * 获得缓存的list对象
     *
     * @param key 缓存的键值
     * @return 缓存键值对应的数据
     */
    public <T> List<T> getCacheList(final String key)
    {
        return redisTemplate.opsForList().range(key, 0, -1);
    }

    /**
     * 缓存Set
     *
     * @param key 缓存键值
     * @param dataSet 缓存的数据
     * @return 缓存数据的对象
     */
    public <T> BoundSetOperations<String, T> setCacheSet(final String key, final Set<T> dataSet)
    {
        BoundSetOperations<String, T> setOperation = redisTemplate.boundSetOps(key);
        Iterator<T> it = dataSet.iterator();
        while (it.hasNext())
        {
            setOperation.add(it.next());
        }
        return setOperation;
    }

    /**
     * 获得缓存的set
     *
     * @param key
     * @return
     */
    public <T> Set<T> getCacheSet(final String key)
    {
        return redisTemplate.opsForSet().members(key);
    }

    /**
     * 缓存Map
     *
     * @param key
     * @param dataMap
     */
    public <T> void setCacheMap(final String key, final Map<String, T> dataMap)
    {
        if (dataMap != null) {
            redisTemplate.opsForHash().putAll(key, dataMap);
        }
    }

    /**
     * 获得缓存的Map
     *
     * @param key
     * @return
     */
    public <T> Map<String, T> getCacheMap(final String key)
    {
        return redisTemplate.opsForHash().entries(key);
    }

    /**
     * 往Hash中存入数据
     *
     * @param key Redis键
     * @param hKey Hash键
     * @param value 值
     */
    public <T> void setCacheMapValue(final String key, final String hKey, final T value)
    {
        redisTemplate.opsForHash().put(key, hKey, value);
    }

    /**
     * 获取Hash中的数据
     *
     * @param key Redis键
     * @param hKey Hash键
     * @return Hash中的对象
     */
    public <T> T getCacheMapValue(final String key, final String hKey)
    {
        HashOperations<String, String, T> opsForHash = redisTemplate.opsForHash();
        return opsForHash.get(key, hKey);
    }

    /**
     * 获取多个Hash中的数据
     *
     * @param key Redis键
     * @param hKeys Hash键集合
     * @return Hash对象集合
     */
    public <T> List<T> getMultiCacheMapValue(final String key, final Collection<Object> hKeys)
    {
        return redisTemplate.opsForHash().multiGet(key, hKeys);
    }

    /**
     * 删除Hash中的某条数据
     *
     * @param key Redis键
     * @param hKey Hash键
     * @return 是否成功
     */
    public boolean deleteCacheMapValue(final String key, final String hKey)
    {
        return redisTemplate.opsForHash().delete(key, hKey) > 0;
    }

    /**
     * 获得缓存的基本对象列表
     *
     * @param pattern 字符串前缀
     * @return 对象列表
     */
    public Collection<String> keys(final String pattern)
    {
        return redisTemplate.keys(pattern);
    }
}

```

### 5 业务使用redis

```java
package com.okyun.framework.web.service;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import com.okyun.common.constant.Constants;
import com.okyun.common.utils.DateUtils;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import com.okyun.common.constant.CacheConstants;
import com.okyun.common.core.domain.model.LoginUser;
import com.okyun.common.core.redis.RedisCache;
import com.okyun.common.utils.ServletUtils;
import com.okyun.common.utils.StringUtils;
import com.okyun.common.utils.ip.AddressUtils;
import com.okyun.common.utils.ip.IpUtils;
import com.okyun.common.utils.uuid.IdUtils;
import eu.bitwalker.useragentutils.UserAgent;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;

/**
 * token验证处理
 */
@Component
public class TokenService
{
    private static final Logger log = LoggerFactory.getLogger(TokenService.class);

    // 令牌自定义标识
    @Value("${token.header}")
    private String header;

    // 令牌秘钥
    @Value("${token.secret}")
    private String secret;

    // 令牌有效期（默认30分钟）
    @Value("${token.expireTime}")
    private int expireTime;

    // 是否允许账户多终端同时登录（true允许 false不允许）
    @Value("${token.soloLogin}")
    private boolean soloLogin;

    protected static final long MILLIS_SECOND = 1000;

    protected static final long MILLIS_MINUTE = 60 * MILLIS_SECOND;

    private static final Long MILLIS_MINUTE_TEN = 20 * 60 * 1000L;

    @Autowired
    private RedisCache redisCache;

    /**
     * 根据token生成 - redis - 用户登录的key
     * @param token
     * @return
     */
    private String getTokenKey(String token)
    {
        return CacheConstants.LOGIN_TOKEN_KEY + token;
    }

    /**
     * 根据userId生成 - redis - 单点登录记录的key
     * @param userId
     * @return
     */
    private String getUserIdKey(Long userId)
    {
        return CacheConstants.LOGIN_USERID_KEY + userId;
    }

    public String getTokenInTokenKey(String userKey)
    {
        if (StringUtils.isEmpty(userKey))
        {
            return null;
        }
        // 从getTokenKey中分割出token部分
        return userKey.replaceFirst(CacheConstants.LOGIN_TOKEN_KEY, "");
    }

    /**
     * 根据userId生成 - redis - 异地登录记录的key
     * @param token
     * @return
     */
    private String getRemoteLoginKey(String token)
    {
        return CacheConstants.REMOTE_LOGIN_KEY + token;
    }

    /**
     * 根据userId生成 - redis - 强制退出记录的key
     * @param token
     * @return
     */
    private String getForceQuitKey(String token)
    {
        return CacheConstants.FORCE_QUIT_KEY + token;
    }

    /**
     * 获取用户身份信息
     *
     * @return 用户信息
     */
    public LoginUser getLoginUser(HttpServletRequest request)
    {
        // 获取请求头携带的token
        String token = getToken(request);
        if (StringUtils.isNotEmpty(token))
        {
            try
            {
                Claims claims = parseToken(token);
                // 解析对应的权限以及用户信息
                String uuid = (String) claims.get(Constants.LOGIN_USER_KEY);
                String userKey = getTokenKey(uuid);
                LoginUser user = redisCache.getCacheObject(userKey);
                return user;
            }
            catch (Exception e)
            {
                log.error("获取用户信息异常:'{}'", e.getMessage());
                return null;
            }
        }
        return null;
    }

    /**
     * 获取请求头中token解析后的 uuid
     * @param request
     * @return
     */
    public String getUuid(HttpServletRequest request)
    {
        // 获取请求头携带的token
        String token = getToken(request);
        if (StringUtils.isNotEmpty(token))
        {
            try
            {
                Claims claims = parseToken(token);
                // 解析对应的权限以及用户信息
                return (String) claims.get(Constants.LOGIN_USER_KEY);
            }
            catch (Exception e)
            {
                log.error("获取用户信息异常:'{}'", e.getMessage());
                return null;
            }
        }
        return null;
    }

    /**
     * 设置用户身份信息
     */
    public void setLoginUser(LoginUser loginUser)
    {
        if (StringUtils.isNotNull(loginUser) && StringUtils.isNotEmpty(loginUser.getToken()))
        {
            refreshToken2(loginUser);
        }
    }

    /**
     * 创建token令牌
     *
     * @param loginUser 用户信息
     * @return 令牌
     */
    public String createToken(LoginUser loginUser)
    {
        String token = IdUtils.fastUUID();
        loginUser.setToken(token);
        setUserAgent(loginUser);
        refreshToken2(loginUser);

        Map<String, Object> claims = new HashMap<>();
        claims.put(Constants.LOGIN_USER_KEY, token);
        return generateToken(claims);
    }

    /**
     * 从数据声明生成令牌
     *
     * @param claims 数据声明
     * @return 令牌
     */
    private String generateToken(Map<String, Object> claims)
    {
        String token = Jwts.builder()
                .setClaims(claims)
                .signWith(SignatureAlgorithm.HS512, secret).compact();
        return token;
    }

    /**
     * 从请求头中 获取token
     * @param request
     * @return token
     */
    private String getToken(HttpServletRequest request)
    {
        // 获取请求头中的token字段
        String token = request.getHeader(header);
        // 存在token -> 格式化 token
        if (StringUtils.isNotEmpty(token) && token.startsWith(Constants.TOKEN_PREFIX))
        {
            token = token.replace(Constants.TOKEN_PREFIX, "");
        }
        // 返回正常格式的 token
        return token;
    }

    /**
     * 解析token 获取数据体
     * @param token 令牌
     * @return 数据声明
     */
    private Claims parseToken(String token)
    {
        return Jwts.parser()
                .setSigningKey(secret)
                .parseClaimsJws(token)
                .getBody();
    }

    /**
     * 解析token 获取用户名
     * @param token 令牌
     * @return 用户名
     */
    public String getUsernameFromToken(String token)
    {
        Claims claims = parseToken(token);
        return claims.getSubject();
    }

    /**
     * 验证令牌有效期，相差不足20分钟 -> 自动刷新缓存
     * @param loginUser
     * @return 令牌
     */
    public void verifyToken(LoginUser loginUser)
    {
        long expireTime = loginUser.getExpireTime();
        long currentTime = System.currentTimeMillis();
        if (expireTime - currentTime <= MILLIS_MINUTE_TEN)
        {
            refreshToken2(loginUser);
        }
    }

    /**
     * 刷新令牌有效期 - 单点登录维护的方法
     * @param loginUser 登录信息
     */
    public void refreshToken2(LoginUser loginUser)
    {
        loginUser.setLoginTime(System.currentTimeMillis());
        loginUser.setExpireTime(loginUser.getLoginTime() + expireTime * MILLIS_MINUTE);
        // 根据uuid将loginUser缓存
        String userKey = getTokenKey(loginUser.getToken());
        redisCache.setCacheObject(userKey, loginUser, expireTime, TimeUnit.MINUTES);
        if (!soloLogin)
        {
            // 缓存用户唯一标识，防止同一帐号，同时登录
            String userIdKey = getUserIdKey(loginUser.getUser().getUserId());
            redisCache.setCacheObject(userIdKey, userKey, expireTime, TimeUnit.MINUTES);
        }
    }

    /**
     * 刷新令牌有效期
     * @param loginUser 登录信息
     */
    public void refreshToken(LoginUser loginUser)
    {
        loginUser.setLoginTime(System.currentTimeMillis());
        loginUser.setExpireTime(loginUser.getLoginTime() + expireTime * MILLIS_MINUTE);
        // 根据uuid将loginUser缓存
        String userKey = getTokenKey(loginUser.getToken());
        redisCache.setCacheObject(userKey, loginUser, expireTime, TimeUnit.MINUTES);
    }

    /**
     * 设置用户代理信息
     * @param loginUser 登录信息
     */
    public void setUserAgent(LoginUser loginUser)
    {
        UserAgent userAgent = UserAgent.parseUserAgentString(ServletUtils.getRequest().getHeader("User-Agent"));
        String ip = IpUtils.getIpAddr();
        loginUser.setIpaddr(ip);
        loginUser.setLoginLocation(AddressUtils.getRealAddressByIP(ip));
        loginUser.setBrowser(userAgent.getBrowser().getName());
        loginUser.setOs(userAgent.getOperatingSystem().getName());
    }

    /**
     * 退出登录 删除用户身份信息 - 单点登录
     */
    public void delLoginUser(String token, Long userId)
    {
        if (StringUtils.isNotEmpty(token))
        {
            String userKey = getTokenKey(token);
            redisCache.deleteObject(userKey);
        }
        if (!soloLogin && StringUtils.isNotNull(userId))
        {
            String userIdKey = getUserIdKey(userId);
            redisCache.deleteObject(userIdKey);
        }
    }

    /**
     * 强制推出删除操作
     * @param token
     */
    public void delLoginUser(String token)
    {
        if (StringUtils.isNotEmpty(token))
        {
            try
            {
                String userKey = getTokenKey(token);
                LoginUser loginUser = redisCache.getCacheObject(userKey);
                if (loginUser != null)
                {
                    String userIdKey = getUserIdKey(loginUser.getUser().getUserId());
                    redisCache.deleteObject(userIdKey);
                    redisCache.deleteObject(userKey);
                    // 登记 强制退出的 token
                    setForceQuitToken(token);
                }
            }
            catch (Exception e)
            {
                log.error("强制退出登录异常：'{}'", e.getMessage());
            }
        }
    }

    // ================= 异地登录  Token 处理 ======================
    /**
     * 记录 异地登录的token
     * @param token
     */
    public void setRemoteLoginToken(String token){
        if (StringUtils.isNotEmpty(token))
        {
            try
            {
                String remoteLoginKey = getRemoteLoginKey(token);
                // 创建当前时间，时间格式是 yyyy-mm-dd hh:mm:ss
                String currentTime = DateUtils.getTime();
                redisCache.setCacheObject(remoteLoginKey, currentTime, 1, TimeUnit.DAYS);
            }
            catch (Exception e)
            {
                log.error("异地登录的token记录异常：'{}'", e.getMessage());
            }
        }
    }

    /**
     * 获取异地登陆的时间
     * @param token
     */
    public String getRemoteLoginToken(String token)
    {
        if (StringUtils.isEmpty(token))
        {
            return null;
        }
        try
        {
            String remoteLoginKey = getRemoteLoginKey(token);
            String currentTime = redisCache.getCacheObject(remoteLoginKey);
            if (StringUtils.isNotEmpty(currentTime))
            {
                return currentTime;
            }
            return null;
        }
        catch (Exception e)
        {
            log.error("获取异地登录的token异常：'{}'", e.getMessage());
            return null;
        }
    }

    /**
     * 删除异地登录的记录
     * @param token
     */
    public void removeRemoteLoginToken(String token)
    {
        if (StringUtils.isNotEmpty(token))
        {
            try
            {
                String remoteLoginKey = getRemoteLoginKey(token);
                redisCache.deleteObject(remoteLoginKey);
            }
            catch (Exception e)
            {
                log.error("删除异地登录的记录异常：'{}'", e.getMessage());
            }
        }
    }

    // ================= 强制退出 Token 处理 ======================
    /**
     * 记录 强制退出 的token
     * @param token
     */
    public void setForceQuitToken(String token)
    {
        if (StringUtils.isNotEmpty(token))
        {
            try
            {
                String forceQuitKey = getForceQuitKey(token);
                // 创建当前时间，时间格式是 yyyy-mm-dd hh:mm:ss
                String currentTime = DateUtils.getTime();
                redisCache.setCacheObject(forceQuitKey, currentTime,1, TimeUnit.DAYS);
            }
            catch (Exception e)
            {
                log.error("强制退出的token记录异常：'{}'", e.getMessage());
            }
        }
    }

    /**
     * 获取 强制退出 的时间
     * @param token
     */
    public String getForceQuitToken(String token)
    {
        if (StringUtils.isEmpty(token))
        {
            return null;
        }
        try
        {
            String forceQuitKey = getForceQuitKey(token);
            String currentTime = redisCache.getCacheObject(forceQuitKey);
            if (StringUtils.isNotEmpty(currentTime))
            {
                return currentTime;
            }
            return null;
        }
        catch (Exception e)
        {
            log.error("获取强制退出的token异常：'{}'", e.getMessage());
            return null;
        }
    }

    /**
     * 删除 强制退出 的记录
     * @param token
     */
    public void removeForceQuitKey(String token)
    {
        if (StringUtils.isNotEmpty(token))
        {
            try
            {
                String forceQuitKey = getForceQuitKey(token);
                redisCache.deleteObject(forceQuitKey);
            }
            catch (Exception e)
            {
                log.error("删除异地登录的记录异常：'{}'", e.getMessage());
            }
        }
    }

}

```



## 二 springCache 注解方式使用redis

### 1 maven配置

```xml
<!-- 通过注解操作缓存 -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
<!-- redis客户端 决定缓存使用redis -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```

### 2 开启注解缓存功能

```java
@SpringBootApplication(exclude = { DataSourceAutoConfiguration.class })
@EnableCaching // 启动类上开启注解缓存功能
public class OkYunApplication{......}
```

### 3 配置 application.yaml

```yaml
# 添加TTL管理
custom:
  cache:
    ttl:
      tenantCostMethod: 600    # 缓存10分钟
      userCache: 3600          # 缓存1小时
      menuCache: 300           # 缓存5分钟
```

### 4 创建一个配置类  CustomCacheProperties.java

```java
package com.okyun.framework.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

/**
 * 自定义注解缓存配置属性：可配置 缓存名与其对应的 TTL，单位：秒
 */
@Data
@Component
@ConfigurationProperties(prefix = "custom.cache")
public class CustomCacheProperties {

    /**
     * 缓存名与其对应的 TTL，单位：秒
     */
    private Map<String, Long> ttl = new HashMap<>();
}

```

### 5 RedisConfig.java  中新增  cacheManager 方法

```java
/**
     * 注解缓存管理器
     * @param redisConnectionFactory    // Redis 连接工厂
     * @param customCacheProperties     // 自定义缓存配置
     * @return
     */
@Bean
public CacheManager cacheManager(RedisConnectionFactory redisConnectionFactory, CustomCacheProperties customCacheProperties) {
    // 全局默认配置
    RedisCacheConfiguration defaultConfig = RedisCacheConfiguration.defaultCacheConfig()
            .entryTtl(Duration.ofMinutes(30))
            .serializeKeysWith(RedisSerializationContext.SerializationPair.fromSerializer(new StringRedisSerializer()))
            .serializeValuesWith(RedisSerializationContext.SerializationPair.fromSerializer(new FastJson2JsonRedisSerializer<>(Object.class)))
            .disableCachingNullValues()
      			// 自定义前缀（去掉默认 ::）
            .computePrefixWith(cacheName -> cacheName + ":"); // 或者 return "" 表示不加分隔

    // 构建每个 cacheName 对应的配置
    Map<String, RedisCacheConfiguration> configMap = new HashMap<>();
    customCacheProperties.getTtl().forEach((cacheName, ttlSeconds) -> {
        configMap.put(cacheName, defaultConfig.entryTtl(Duration.ofSeconds(ttlSeconds)));
    });

    return RedisCacheManager.builder(redisConnectionFactory)
            .cacheDefaults(defaultConfig)
            .withInitialCacheConfigurations(configMap)
            .transactionAware()
            .build();
}

```

### 6 常用注解

```java
// 1 添加到启动类上，开始缓存注解功能
@EnableCaching	
// 2 在方法上先查询缓存，如果有数据直接返回缓存，如果没有数据，则调用方法并将返回值放到缓存中
@Cacheable(cacheNames = "tenantCostMethod", key = "'tenantId_' + #tenantId")	
// 3 将方法的返回值更新缓存
@CachePut(cacheNames = "tenantCostMethod", key = "'tenantId_' + #tenantId")
// 4 删除指定缓存
@CacheEvict(cacheNames = "tenantCostMethod", key = "'tenantId_' + #tenantId")	
// 5 删除所有缓存
@CacheEvict(cacheNames = "tenantCostMethod", allEntries = true)	

```

