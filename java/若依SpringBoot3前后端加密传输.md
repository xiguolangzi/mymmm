# 若依SpringBoot3前后端加密传输

## 一 生成公钥私钥

### 1 生成地址

```java
// 生成密钥的地址：
http://web.chacuo.net/netrsakeypair
```

### 2 生成公钥私钥

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmMH98Xd4fGJxkmg//dde
AARWIf8SDZlG+bAVsmoqYtU/AcPziwfmAj7Na8YRrOR1bv1oykB2OjgaS7hjupC6
kMDA+TgbH7Q3vPLETlQ7knAr1rj2K8kylxnTbri/zQORMYFP43xxvw2MpzWydwmR
uNocAYKvhSy5unIJ/eeuR4BWAVjQtnajiDR6+XD6lE1JVfwkJUSYueYf8bqCMmDM
H5ALwfNEue23/Vw45cA4MoF7ehj6MtSDdgzyrPKhOfcFdChnk0sj3sGzKkY5G89Q
gyAodgWrInmh1+mG/BpLyLb3fghrVRb4heWG285RUF5WqU/9sYMlcyD4PD7A58ST
gwIDAQAB
-----END PUBLIC KEY-----

-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCYwf3xd3h8YnGS
aD/9114ABFYh/xINmUb5sBWyaipi1T8Bw/OLB+YCPs1rxhGs5HVu/WjKQHY6OBpL
uGO6kLqQwMD5OBsftDe88sROVDuScCvWuPYryTKXGdNuuL/NA5ExgU/jfHG/DYyn
NbJ3CZG42hwBgq+FLLm6cgn9565HgFYBWNC2dqOINHr5cPqUTUlV/CQlRJi55h/x
uoIyYMwfkAvB80S57bf9XDjlwDgygXt6GPoy1IN2DPKs8qE59wV0KGeTSyPewbMq
Rjkbz1CDICh2BasieaHX6Yb8GkvItvd+CGtVFviF5YbbzlFQXlapT/2xgyVzIPg8
PsDnxJODAgMBAAECggEAeQl9BU78kNIP20nvKlrziF/nP5iz3UKOElmLV4r3esgs
3GE/H/JqNW09px+R8cQzqHXyCg95njfF3imEG9eBfCC+xrnGBCDv6S8SjF4Btc5b
bg+wPpF1HHTCKwEIOJGTAf7MJhv8pL0/rV3Gwrs6U5W+ixPZr1P49dpWQHDKjqvQ
FX4fD6LejtJHkwiuSbCj+BG6nNzzmqffHx1C7brci0EhHV9qkys+m1KNGjueihIC
AdBGIG9JAsd55Ym4sAV3MvC8E5lbdgDMkHoVEHdpxuyXapxcpd+fnWqIIBNqG1w+
j3Uma/z3f59Bci8WQW3M912N24Yel2fdZoSwUoKBAQKBgQDHXyNKIprej5WFFM1R
QNYGvaqIPZ1rbxbdo5DJu2362NZ8JLI+JBB9Yl1pZFs4RbqMe+Zs+p9Kzp4BPw6P
W+tuOAGnYgVlpcCNBlgWuEZWir1+BuKu4jhKty2nZuHQbPzSXqflXAJUkRSxstv6
JW9naLmyRkUqpHRHZGkfmEl6cwKBgQDEJW6mkucEvG67+FuPXQPzjieh6BbJoZkj
vrNuqLtQtrRLRgMHC8I+Zg/s0xvqPqZ0edQEIBV3Mcik7pAw+fAa/9lgNylZ+Kh6
GaSr0mqEr6rjHLrAStfkaewoutQE98G/T8pFNUmhLEYAVrui2Vpf+8rrk4eGACOT
jDgdlmDusQKBgEP+l1t+R9ElqPm1KXzPnu63msRSNzDfty2pzgRu7shBUY0POtbk
l9cbR/5copujdEbbLq/2HYN2yf5k0gNkdvulEDNUw8Bx8iRmiH5fJGX5dTzY/lBk
iIw6wtA3z0W1FdhtPdeENKtAu40LEejTAZaD6ej5/DbZ1WpPvWZwGocvAoGASS6+
LiA5WacEmdV8M+08gC7V0q7Jccl9XbzVLcB+wwqoEj24+3QDsUxbPL03eRqO+H5M
AI4H9ET626621c8rKqey7xclso/4LDZNHl6Pp5nzZHFfrEdAbdSnbDroyEG4ZCzd
Bx1ur1fZdl7l+0ilU5Kaj3Kn6fM7Ut3KQh/NYsECgYBw/V0qpe5hBrZ84GD/ssBk
GxScf75sdoINt2hCjANc8b921UlZyBHsI/UKGuzjplciKWuT/P0eoMsbCWUzqa/S
DSbOg+Tb616OP63AHYqX/wyaqEcOpnO+35m/NH2/pEGoKtuwNhlbSC7mQQthHZ/F
XlANX0eBmc9zksvou46kqg==
-----END PRIVATE KEY-----
```

## 二 前端实现加密

### 1 引用加密插件

```
插件名："jsencrypt": "3.3.2"
```

### 2 封装加密方法

```javascript
import JSEncrypt from 'jsencrypt/bin/jsencrypt.min'

// 注意密钥格式、信息 别写错了
const publicKey = 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuEBVkUu4gQWrir5LGHzY\n' +
  't/BV1WcAFaUkGLFX4mBXfS9KKUOT69POUap5gyoAncqTS0+wStSWXoN54Wj9etBC\n' +
  'uZbe+vbutsy88hSinIUo5/7e+GxHpWRIjbSpV3pC6ejPWbuyeoODWeI4c8Em7xdd\n' +
  'V98WpqCIYyab56sITR9O2OikNw5C48SM49l24YX4UDjTHUK3eXfMxE1PJgaoQyrj\n' +
  '/GysS6qIzY3KmnJPzgAHCD/0eaL6xGSV4l1NzPmOoTvAtyCNAkR94prbvQcLNt7p\n' +
  '7+2Yjos3mbR3SbArscy3yQ95upg/ZT2WV7EwWN7fTrW5islmWjT9yJKbZ3GB/nwD\n' +
  'eQIDAQAB';

// 传递后端加密
export function encryptForJava(txt) {
  const encryptor = new JSEncrypt()
  encryptor.setPublicKey(publicKey) // 设置公钥
  return encryptor.encrypt(txt) // 对数据进行加密
}
```

### 3 举例使用 - 登录业务

```javascript
// 登录方法
export function login(tenantCode, username, password, code, uuid) {
  // 前->后 端传输加密
  password = encryptForJava(password)
  
  const data = {
    tenantCode,
    username,
    password,
    code,
    uuid
  }
  return request({
    url: '/login',
    headers: {
      isToken: false,
      repeatSubmit: false,
      tenantCode: data.tenantCode
    },
    method: 'post',
    data: data
  })
}
```

## 三 后端实现加密解密

### 1 配置密钥信息

```yaml
# application.yaml 配置
rsa:
  public-key: |
    MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuEBVkUu4gQWrir5LGHzY
    t/BV1WcAFaUkGLFX4mBXfS9KKUOT69POUap5gyoAncqTS0+wStSWXoN54Wj9etBC
    uZbe+vbutsy88hSinIUo5/7e+GxHpWRIjbSpV3pC6ejPWbuyeoODWeI4c8Em7xdd
    V98WpqCIYyab56sITR9O2OikNw5C48SM49l24YX4UDjTHUK3eXfMxE1PJgaoQyrj
    /GysS6qIzY3KmnJPzgAHCD/0eaL6xGSV4l1NzPmOoTvAtyCNAkR94prbvQcLNt7p
    7+2Yjos3mbR3SbArscy3yQ95upg/ZT2WV7EwWN7fTrW5islmWjT9yJKbZ3GB/nwD
    eQIDAQAB
  private-key: |
    MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC4QFWRS7iBBauK
    vksYfNi38FXVZwAVpSQYsVfiYFd9L0opQ5Pr085RqnmDKgCdypNLT7BK1JZeg3nh
    aP160EK5lt769u62zLzyFKKchSjn/t74bEelZEiNtKlXekLp6M9Zu7J6g4NZ4jhz
    wSbvF11X3xamoIhjJpvnqwhNH07Y6KQ3DkLjxIzj2XbhhfhQONMdQrd5d8zETU8m
    BqhDKuP8bKxLqojNjcqack/OAAcIP/R5ovrEZJXiXU3M+Y6hO8C3II0CRH3imtu9
    Bws23unv7ZiOizeZtHdJsCuxzLfJD3m6mD9lPZZXsTBY3t9OtbmKyWZaNP3Ikptn
    cYH+fAN5AgMBAAECggEAT03hhphA4ce+/gjJ6dBSt1kKmL+smaRq1PYADb/J6Gfi
    U8Byep6/vwbRJlN90GzQ2SmDh7HYxvVwEEVQVPwuvBLkBsEiHiwhZ1DabOQjpzdc
    YTC55cY0NEn+WViWVHeQR98yAul4L8fe5HPOfjpgQuISrcWK7qI/mIdVG1zOYy2D
    L8BWNjXOfi6dHBT40YLGzi5zJOatSl079dyzAUli/wmu47ApVeFQ9UHnhOLhYGUJ
    IW5la7JFYcBHE24Cddc6c9L1Z8EkKpFq3LgKAFiZVqfHrUzaA4bt7pyzmtKn9fDd
    wIGFfB19dFaqiqnPlCKHCL4u7j9Ev3YuFSBmCBN4AQKBgQDvATc94dqrotfmM1wn
    2aQuFziKpN4vTMaCtRiIbUTmrx9Y5ZTTmfnziAmKqz2A3AhV2r1WS9AozpIKsm8k
    AQ7zA9cQZ28icIeWAiE864nxJVL73/6ZGX95ycXbfwjw8vqKujnn09Ec/41vr8HM
    QlbPfIBbqmEBj756kCCVZTZTaQKBgQDFWmZuE/SVIRY6L2Dy0YUtXULwZNjCoWVX
    9P1vko4Zr6MpdTHnrb7CZJIJwc/4thsSlRmQfG46ErnnAj61ztf//KPd8Qbo6ovj
    4KALpAeiQTpa22COFsczUjlJKPqjw2pIJWclM+ImahuhkwCqhJVD+1xuCnQfFUyG
    9tb+hwj9kQKBgQCDV4izEh3oOnopAEqBf8IQriQdVNLg7XEdvUV5G4tEtjIk2S17
    R1+rrDOKJ+aJnOFbxPRNqyX+dt6c0EfxYj+D3rVeR2k0ZOCt2AfKAapxgdBjqEmy
    euep1u9LWzlfqDd06zgNJUMCi5F/MffvNvmb1lB3j171y7eihPfTAabkGQKBgG8R
    EEJ1IpnnFA5M6b/eIJhGO0z1RHRMxq84poTrMuPL0ASd+ycKxie61+F73OJ5AkVz
    +f4xuQsfzNXwkoBZV4Cumz5lzmC411+44/mJJ+6tzPyjJ/TvZs5AQRMmZ+BQMvlF
    a4Ypa+X4o3JMO/y7PxISXZNkeLOhlf8C3j5CmtGxAoGAU/V0N/Dlm9RR9Hx0YbgY
    Np/WbtAnknaL3oLxGokVDXt4IPIvtdPnMADf5N18EIOuKZJCBfO7c1GtAslTrTxA
    Y+s9cKStyhkMxZbXmS3Q5ZKbmNhwVYeIW/P+qWg8ER6WSFMNU7NSQmGSu8Cmw4QH
    YIgrmdZ3LS+WAUsNPJet3wM=
```

### 2 获取密钥配置

```java
package com.okyun.common.utils.sign;

/**
 * RSA 配置
 */
@Configuration
@Data
@ConfigurationProperties(prefix = "rsa")
public class RsaProperties {

    /** 前端加密后端解密 公钥 */
    private String publicKey;

    /** 前端加密后端解密 私钥 */
    private String privateKey;

}
```

### 3 封装方法

```java
package com.okyun.common.utils.sign;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.codec.binary.Base64;
import org.springframework.stereotype.Component;

import javax.crypto.Cipher;
import java.nio.charset.StandardCharsets;
import java.security.*;
import java.security.spec.*;

/**
 * RSA公钥/私钥/签名工具包
 */
@Component
@RequiredArgsConstructor
@Slf4j
public class RsaUtils {

    private final RsaProperties rsaProperties;

    /**
     * 使用公钥加密
     * 用途：前端传输密码、身份证、手机号等敏感信息时，加密发送到后端
     * @param content
     * @return
     * @throws Exception
     */
    public String encryptByPublicKey(String content) throws Exception {
        // 获取 Base64 编码的公钥 → 生成 PublicKey 对象
        PublicKey publicKey = getPublicKey();
        // 用 Cipher.getInstance("RSA") 初始化加密模式
        Cipher cipher = Cipher.getInstance("RSA");
        cipher.init(Cipher.ENCRYPT_MODE, publicKey);
        // 使用 cipher.doFinal() 加密字节数组
        byte[] encrypted = cipher.doFinal(content.getBytes(StandardCharsets.UTF_8));
        //最终返回 Base64 编码的密文字符串
        return Base64.encodeBase64String(encrypted);
    }

    /**
     * 使用私钥解密
     * 用途：后端接收加密数据后，解密使用
     * @param encryptedText
     * @return
     * @throws Exception
     */
    public String decryptByPrivateKey(String encryptedText) throws Exception {
        // 获取 Base64 编码的私钥 → 生成 PrivateKey 对象
        PrivateKey privateKey = getPrivateKey();
        Cipher cipher = Cipher.getInstance("RSA");
        cipher.init(Cipher.DECRYPT_MODE, privateKey);
        byte[] decrypted = cipher.doFinal(Base64.decodeBase64(encryptedText));
        return new String(decrypted, StandardCharsets.UTF_8);
    }

    /**
     * 私钥签名
     * 用途：防篡改、数据来源校验
     * @param content
     * @return
     * @throws Exception
     */
    public String sign(String content) throws Exception {
        PrivateKey privateKey = getPrivateKey();
        Signature signature = Signature.getInstance("SHA256withRSA");
        signature.initSign(privateKey);
        signature.update(content.getBytes(StandardCharsets.UTF_8));
        return Base64.encodeBase64String(signature.sign());
    }

    /**
     * 公钥验签
     * 用途：校验签名有效性
     * @param content
     * @param sign
     * @return
     * @throws Exception
     */
    public boolean verify(String content, String sign) throws Exception {
        PublicKey publicKey = getPublicKey();
        Signature signature = Signature.getInstance("SHA256withRSA");
        signature.initVerify(publicKey);
        signature.update(content.getBytes(StandardCharsets.UTF_8));
        return signature.verify(Base64.decodeBase64(sign));
    }

    /**
     * 生成一对 RSA 公钥/私钥
     * 用途：本地测试或密钥初次生成
     * @return
     * @throws Exception
     */
    public RsaKeyPair generateKeyPair() throws Exception {
        KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
        generator.initialize(2048);
        KeyPair keyPair = generator.generateKeyPair();
        String pubKey = Base64.encodeBase64String(keyPair.getPublic().getEncoded());
        String priKey = Base64.encodeBase64String(keyPair.getPrivate().getEncoded());
        return new RsaKeyPair(pubKey, priKey);
    }

    /**
     * 获取公钥
     * 用途：由配置项注入读取并解析
     * @return
     * @throws Exception
     */
    private PublicKey getPublicKey() throws Exception {
        byte[] bytes = Base64.decodeBase64(rsaProperties.getPublicKey());
        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(bytes);
        // 获取公钥
        return KeyFactory.getInstance("RSA").generatePublic(keySpec);
    }

    /**
     * 获取私钥
     * 用途：由配置项注入读取并解析
     * @return
     * @throws Exception
     */
    private PrivateKey getPrivateKey() throws Exception {
        byte[] bytes = Base64.decodeBase64(rsaProperties.getPrivateKey());
        PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(bytes);
        // 获取私钥
        return KeyFactory.getInstance("RSA").generatePrivate(keySpec);
    }


}


/**
 * RSA密钥对
 */
@Data
@AllArgsConstructor
public class RsaKeyPair {
    private final String publicKey;
    private final String privateKey;

}

```

### 4 举例使用 - 登录业务

```java
package com.okyun.web.controller.system;

@PostMapping("/login")
    public AjaxResult login(@RequestBody LoginBody loginBody)
    {
        AjaxResult ajax = AjaxResult.success();
        try {
            // RSA 解密：前端加密传来的密码
            String rawPassword = rsaUtils.decryptByPrivateKey(loginBody.getPassword());

            // 生成令牌
            String token = loginService.login(
                    loginBody.getTenantCode(),
                    loginBody.getUsername(), // 用户名通常不加密
                    rawPassword,
                    loginBody.getCode(),
                    loginBody.getUuid()
            );
            ajax.put(Constants.TOKEN, token);
            return ajax;
        } catch (Exception e) {
            return AjaxResult.error("解密失败：" + e.getMessage());
        }
    }
```

























