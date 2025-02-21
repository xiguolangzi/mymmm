# 《Ruoyi - 前后端分离》

## 一、环境部署

### 1 环境部署

```java
// JDK

// Node

// Mysql

// Redis

```

### 2 项目部署

```java
// 后端代码
    1 导入基础的数据库表
    2 修改配置文件： 数据库链接 redis链接
    3 下载项目依赖
// 前端代码
	1 npm install 初始化

// 导入基础的数据库表

```

## 二、 实施使用

### 1 系统管理

#### 1.1 菜单管理

```java
1.主要对菜单层级 展示位置、状态的 编辑处理功能；
2.也可以新增菜单；
```

#### 1.2 数据字典

```java
1 适用于不经常维护的静态数据； // 比如 性别、状态 等
2 数据字典表：sys_dict_type 字典类型，sys_dict_data 字典数据，两个表关联字段 "dict_type"
```

#### 1.3 参数设置

```java
// 系统参数的设置
1 是否开启注册
2 是否开启验证码
3 验证码的方式
......
```

#### 1.4 通知公告

```java
// 目前只提供了 通知的录入
对于通知的界面展示 或者 邮件形式发送 需要二次开发！！！
```

#### 1.5 日志管理

```java
 1 记录 操作日志
 2 记录 登录日志
```

### 2 系统监控

####  2.1 在线用户

#### 2.2 定时任务

```java
// 1 新建任务类
    // 注意1：任务类必须放到 src/main/java/com/ruoyi/quartz/task 路径下
    // 注意2：类上必须注解 @compoment
package com.ruoyi.quartz.task;
import org.springframework.stereotype.Component;
import java.util.Date;
@Component
public class MyTask {
    public void showTime(){
        System.out.println("定时任务开始执行：" + new Date());
    }
}

// 2 控制台 添加该类中方法到定时任务触发器
1 任务名称：任务描述；
2 调用方法：方法全路径 或者 Bean.方法() -> 推荐第二种： myTask.showTime()；
3 cron表达式：定时任务执行的时间间隔；
---
4 启用

// 3 执行策略
1 立即执行：服务重启，会将服务重启之前没有执行的定时任务全部从新执行一次；
2 执行一次：服务重启，只执行最后一次未执行的定时任务；
3 放弃执行：服务重启，之前没有执行的定时任务都不执行；

// 4 是否并发
允许：A B 两个定时任务，如果 A 没执行，B 依然执行；
禁止：A B 两个定时任务，如果 A 没执行，B 等 A 执行完之后再执行；

// 5 有参、无参、多参 的任务传递

// 6 任务定时任务详情、日志记录
```

### 3 系统工具

#### 3.1 表单构建

```java
// 1 制作表单 -> 并到处 .vue 文件

// 2 将导出文件 复制到前端工程
	1 记住组件路径
// 3 创建动态菜单
	1 路由地址：菜单层级关系；
	2 组件路径：组件放置在前端项目的路径；
```

#### 3.2 代码生成

##### 3.2.1 单表

```

```

##### 3.2.2 树表

```java
// 1 基本信息

// 2 字段信息

// 3 生成信息
	1 生成模板：树表
	2 前端类型：Vue3
	---- 其他信息
	3 数编码字段：dept_id
	4 数父编码字段：parent_id
	5 数名称字段：dept_name
```

##### 3.2.3 主子表

```

```

#### 3.3 系统接口 Swagger

```java
// 1 修改后端代码的配置文件 Swagger请求前缀
	pathMapping: /
    修改之后重启后端 -> 前端接口文档就没有请求前缀了！
// 2 接口文档注解
    @Api
    @
```

## 三、项目结构 

### 1 后端项目结构

#### 1.1 结构划分

```java
1 rouyi-admin	// 后台服务
	com.ruoyi.web	// 通用功能的 controller
	com.ruoyi.core.config	// swagger 配置
	com.ruoyi.RuoYiAplication	// springBoot 项目启动类
	com.ruoyi.RuoYiServletInitializer	// war包时的项目启动类(去除自带tomcat)
	resourese	// 各种配置资源文件
    	--i18n					// 国际化
        --META-INF				//	项目的元信息(描述数据的数据)，无需修改
        --mybatis				// mabatis相关的配置
        --application.yml		// 项目中的核心配置
        --application-druid.yml	// 数据库链接配置
        --banner.txt			// 启动时，控制台打印图案
        --logback.xml			// 日志相关配置
2 ruoyi-common	// 通用工具
	com.ruoyi.common.annotation	// 自定义注解
	com.ruoyi.common.config		// 全局配置
	com.ruoyi.common.constant	// 通用常量
	com.ruoyi.common.core		// 核心控制
		--controller
		--domain
			--entity
				--SysDept
				--SysDictData
				--SysSictType
				--SysMenu
				--SysRole
				--SysUser
			--model
				--LoginBody
				--LoginUser
				--RegisterBody
			--AjaxResult
			--BaseEntity
			--R
			--TreeEntity
			--TreeSelect
		--page
		--redis
		--text
	com.ruoyi.common.enums		// 通用枚举
	com.ruoyi.common.exception	// 通用异常
		--
	com.ruoyi.common.filter		// 过滤器处理
	com.ruoyi.common.utils		// 通用工具类
		--
	com.ruoyi.common.xss		// 自定义xss校验,跨站脚本攻击
3 ruoyi-framework	// 框架核心
	com.ruoyi.framework.aspectj		// 自定义 aop
	com.ruoyi.framework.config		// 系统配置
	com.ruoyi.framework.datasource	// 多数据源
	com.ruoyi.framework.intercepter	// 拦截器
	com.ruoyi.framework.manager		// 异步处理
	com.ruoyi.framework.security	//	权限处理
	com.ruoyi.framework.web			//	前端控制
4 ruoyi-generator	// 代码生成 (可移除)
5 ruoyi-quartz		// 定时任务(可移除)
6 ruoyi-system		// 系统模块
```





### 2 前端项目结构

#### 2.1 结构划分

```java
vite.config.js		// vue 配置信息, 端口号，调用转发
package.json		// 项目版本、依赖
node_modules		// 项目依赖包存储
src					// 源代码
	--api
```



### 3  ruoyi 表结构

#### 	3.1 代码生成

```java
gen_table			// 代码生成业务表
gen_table_column	// 代码生成业务表字段
```

#### 	3.2 数据字典

```java
sys_dict_type	// 字典类型表
sys_dict_data	// 字典数据表
```

#### 	3.3 定时任务

```java
sys_job		// 定时任务调度表
sys_job_log	// 定时任务调度日志表
```

#### 	3.4 日志

```java
sys_logininfor	// 系统访问记录
sys_open_log	// 操作日志记录
```

#### 	3.5 通知公告 / 参数设置	

```java
sys_notice	// 通知公告
sys_config	// 参数配置表
```

#### 	3.6 权限

```java
sys_menu		// 菜单权限表
sys_role		// 角色表
sys_role_menu	// 角色菜单关联表
sys_dept		// 部门表
sys_role_dept	// 角色部门关联表
sys_user		// 用户信息表
sys_user_role	// 用户角色关联表
sys_post		// 岗位信息表
sys_user_post	// 用户岗位关联表
```

#### 3.7定时任务 quartz 表结构

```java
qrtz_calendars			// 存储日历信息
qrtz_triggers			// 存储触发器的基本信息
qrtz_cron_triggers		// 存储 cron表达式触发器的详细信息
qrtz_fired_triggers		// 存储已触发的触发器的详细信息
qrtz_blob_triggers		// 存储 blob类型触发器的详细信息
qrtz_scheduler_state	// 存储调度器的状态信息
qrtz_locks				// 存储调度器锁的信息，用于控制并发
qrtz_job_details		// 存储定时任务的详细信息
```

## 四、后端项目

### 1 BaseController 通用controller

```java
// 查看类所有方法 快捷键 alt + 7
initBinder(WebDataBinder):void	// 初始化时间格式
startPage():viod		// 分页查询
startOrderBy():void		// 分页查询
clearPage():void		// 分页查询
getDataTable(List<?>):TableDataInfo	//返回结果
success():AjaxResult				//返回结果
error():AjaxResult					//返回结果
success(String):AjaxResult			//返回结果
success(Object):AjaxResult			//返回结果
error(String):AjaxResult			//返回结果
warn(String):AjaxResult				//返回结果
toAjax(boolean):AjaxResult			//返回结果
toAjax(String):String				//返回结果
rediect(String):String				//返回结果
getLoginUser():LoginUser			// 登录用户相关方法
getUserId():Long					// 登录用户相关方法
getDeptId():Long					// 登录用户相关方法
getUserName():String				// 登录用户相关方法
logger:Logger = LoggerFactory.getLogger(...)	// 日志采集
```

### 2 BaseEntity 基类

```java
 /** 搜索值 - 用于全文检索 */
@JsonIgnore
private String searchValue;

/** 创建者 */
private String createBy;

/** 创建时间 */
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
private Date createTime;

/** 更新者 */
private String updateBy;

/** 更新时间 */
@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
private Date updateTime;

/** 备注 */
private String remark;
```

### 3 后端消息返回

```java
// 1 分页查询
返回 TableDataInfo

// 2 其他返回
AjaxResult
```

##### 		

## 五、 前后端交互流程

### 1 前端拦截器

### 2 前端代理转发

## 六 二次开发

### 1 修改若一包名	-- 忽略处理！！！

#### 		1.1 修改包名、项目名

​	工具：https://gitee.com/lpf_project/RuoYi-MT/releases

​	不推荐修改！！！保持原创！

#### 		1.2 修改项目名

​	不推荐修改！！！保持原创！

#### 		1.3 修改启动类名

​	不推荐修改！！！保持原创！

### 2 创建业务子模块

​	2.1 父组件 -> 新建模块，模块名 【ruoyi-sky】 -> 子模块引入核心模块 【ruoyi-framework】;

```xml
<dependencies>
    <!-- 核心模块-->
    <dependency>
        <groupId>com.ruoyi</groupId>
        <artifactId>ruoyi-framework</artifactId>
    </dependency>
</dependencies>
```

​	2.2 父组件 -> 统一管理模块版本锁定；

```xml
<!-- 外卖平台 -->
<dependency>
    <groupId>com.ruoyi</groupId>
    <artifactId>ruoyi-sky</artifactId>
    <version>${ruoyi.version}</version>
</dependency>
```

​	2.3 ruoyi-admin 模块引入业务模块 -> ruoyi-sky

```xml
<!-- 外卖平台 -->
<dependency>
    <groupId>com.ruoyi</groupId>
    <artifactId>ruoyi-sky</artifactId>
</dependency>
```

### 3 业务数据库设计

​	3.1 设计表结构；

​	3.2 导入表；

### 4 前端界面生成代码

#### 	4.1 代码生成

```
1 主子表
	基础信息 -> 修改 【实体类名称】；
	字段信息 -> 修改 增删改查字段、必填字段；
	生成信息 -> 修改 包路径、包名；选择生成模板【主子表】；设置关联子表 子表名、关联主键；
	下载 -> 解压 -> 导入菜单表、覆盖前后端代码！
```

#### 	4.2 代码改造

```java
// 1 添加 欧元标识
// 2 时间格式
// 3 图片回显支持(本地 + 云端)
// 4 口味子表的数据展示样式
```

#### 	4.3 页面调整

```java
// 1 系统标题
	环境配置：VITE_APP_TITLE = OkYun管理系统
// 2 系统Logo
	替换ico图：public/factory.ico
	替换logo图：asset/logo/logo.png
// 3 icon自定义
	svg图放置到：assets/icon/svg 下
// 4 背景图
	login.vue 修改标题
	login.vue 样式里修改背景图地址
// 5 navbar.vue 源码地址注释掉

```

### 	5 数据权限

```java
// 1 @DataScope 注解实现数据权限的控制 -- xxxServiceIpml.java 中的查询方法
	-- @DataScope(deptAlias = "d", userAlias = "u") -> d = depy_id, u = user_id ;
	-- aop 切面 实现数据SQL 拼接;
	-- 先清空之前的 sql拼接字符串 = ""
    -- 根据当前方法调用的用户角色信息，重新拼接 sql字符产
// 2 数据库添加字段 -> 需要通过部门和用户过滤，所以需要添加部门和用户的ID字段
	部门ID depy_id
	角色ID user_id
// 3 数据库添加了字段，同时需要维护实体类的属性
	userId属性、set方法、get方法
	depyId属性、set方法、get方法
// 4 ${params.datasScope} 实现数据范围过滤 -- xxxMapper.xml 中查询sql拼接
	-- 实现 sql  拼接 数据范围；
	-- 实体类需要继承 BaseEntity, params 是 BaseEntity 的一个属性；
	-- 原始的sql 查询字段需要添加别名 l.;
	-- 修改成多表查询,注意 部门表的别名必须时 d ,用户表的别名必须是 u :
	   // 4.1 修改成多表查询
       left join sys_dept d on l.dept_id = d.dept_id
	   left join sys_user u on l.user_id = u.user_id
        <where>
		...
         // 4.1 数据范围过滤条件，拼接的sql
         ${params.datasScope}
        <where>
 // 5 修改实体类的 新增修改方法
 	-- 新增时维护 部门、角色 的字段，便于数据过滤
 	-- 修改时维护 部门、角色 的字段，便于数据过滤
```

### 6 多数据源

#### 	6.1 多数据源使用

##### 		6.1.1 添加多数据源配置

```yaml
# 配置文件 application-druid.yml, 添加多数据源配置 slave、slave1、slave
# 数据源配置
spring:
    datasource:
        type: com.alibaba.druid.pool.DruidDataSource
        driverClassName: com.mysql.cj.jdbc.Driver
        druid:
            # 主库数据源
            master: ...
            # 从库数据源
            slave: ...
		   slave1: ...
		   slave12: ...
```

##### 		6.1.2 维护 DruidConfig - 多数据源配置

```java
// 文件 package com.ruoyi.framework.config.DruidConfig
@Bean
@ConfigurationProperties("spring.datasource.druid.slave")
@ConditionalOnProperty(prefix = "spring.datasource.druid.slave", name = "enabled", havingValue = "true")
public DataSource slaveDataSource(DruidProperties druidProperties){
    DruidDataSource dataSource = DruidDataSourceBuilder.create().build();
    // Spring Boot 2.0 之后的版本，多数据源的每个数据源的所有配置都需要单独配置，否则不生效！ 
    return druidProperties.dataSource(dataSource);
}

@Bean
@ConfigurationProperties("spring.datasource.druid.slave1")
@ConditionalOnProperty(prefix = "spring.datasource.druid.slave1", name = "enabled", havingValue = "true")
public DataSource slave1DataSource(DruidProperties druidProperties){
    DruidDataSource dataSource = DruidDataSourceBuilder.create().build();
    // Spring Boot 2.0 之后的版本，多数据源的每个数据源的所有配置都需要单独配置，否则不生效！ 
    return druidProperties.dataSource(dataSource);
}

@Bean
@ConfigurationProperties("spring.datasource.druid.slave2")
@ConditionalOnProperty(prefix = "spring.datasource.druid.slave2", name = "enabled", havingValue = "true")
public DataSource slave2DataSource(DruidProperties druidProperties){
    DruidDataSource dataSource = DruidDataSourceBuilder.create().build();
    // Spring Boot 2.0 之后的版本，多数据源的每个数据源的所有配置都需要单独配置，否则不生效！ 
    return druidProperties.dataSource(dataSource);
}

```

##### 		6.1.3 维护多数据源 标识枚举

```java
// 文件 package com.ruoyi.common.enums.DataSourceType
public enum DataSourceType
{
    /**
     * 主库
     */
    MASTER,

    /**
     * 从库
     */
    SLAVE
     /**
     * 从库 1
     */
    SLAVE1
     /**
     * 从库 2
     */
    SLAVE2
}
```

##### 		6.1.4 将多数据源 添加到 数据源集合

```java
// 文件 package com.ruoyi.framework.config.DruidConfig
@Bean(name = "dynamicDataSource")
@Primary
public DynamicDataSource dataSource(DataSource masterDataSource)
{
    // 数据源集合
    Map<Object, Object> targetDataSources = new HashMap<>();
    // 数据源集合 添加主库
    targetDataSources.put(DataSourceType.MASTER.name(), masterDataSource);
    // 数据源集合 添加从库slave
    setDataSource(targetDataSources, DataSourceType.SLAVE.name(), "slaveDataSource");
    // 数据源集合 添加从库slave1
    setDataSource(targetDataSources, DataSourceType.SLAVE1.name(), "slave1DataSource");
    // 数据源集合 添加从库slave2
    setDataSource(targetDataSources, DataSourceType.SLAVE2.name(), "slave2DataSource");
    // 配置动态数据源：如果没有从库，则默认主库
    return new DynamicDataSource(masterDataSource, targetDataSources);
}
```

##### 		6.1.5 添加切面类注解

```JAVA
// 需要切换数据源的 方法 或 类 上添加注解
@DataSource(value = DataSourceType.MASTER/SLAVE/SLAVE1/SLAVE2)
```

##### 		6.1.6 不同类型的数据源

```java
// 1 不同类型数据源，需要引入驱动 
	-- mysql
	--sqlServer
	-- oracle
// 2 application-druid.yml 配置文件去掉语言类型
	--driverClassName: com.mysql.cj.jdbc.Driver
// 3 分页查询 application.yml 配置文件去掉语言类型
	# PageHelper分页插件
    pagehelper:
      helperDialect: mysql
// 4 xxxMapper.xml 文件中的 sql 兼容
	-- 有些mysql语句不兼容 oracle / sqlServer
	-- 比如时间格式化...
    -- 设计大量数据库sql兼容处理，推荐使用第三方插件处理
// 5 其他的和新增从库的方法一致！
```

#### 		6.2 租户分表

```JAVA
// TODO 后续准备在数据权限切面类中进行修改.... 
	-- 1 新增租户 新增表结构；
	-- 2 执行sql 传递参数 租户ID
	-- 3 表名获取方法 -> 拼接表明 = 前缀 + 租户ID
	-- 4 xxxMapper.xml 中 sql 表名通过 ${tableName} 动态获取
```



### 7 国际化

#### 	7.1 前端国际化

##### 7.1.1  pinia 状态管理 language

```js
// 1 通过 pinia 状态管理 language - stores/modules/language.js
import {defineStore} from 'pinia'
// cookie 管理
import Cookies from 'js-cookie'

export const useLanguageStore = defineStore('language', {
  state: () => ({
    language: Cookies.get('language') ||  navigator.language.toLowerCase().split('-')[0] || 'zh' // cookie || 浏览器默认语言 || 默认中文
  }),
  actions: {
    setLanguage(lang) {
      this.language = lang
      Cookies.set('language', lang) // 设置 cookie 本地持久化
    }
  }
})
```

##### 7.1.2 i18n 翻译文件

```
src/lang/language/en.js
src/lang/language/zh.js
src/lang/language/es.js
```

##### 7.1.3 i18n 配置文件

```js
// src/lang/i18n.js
import { createI18n } from "vue-i18n"
// 导入语言包
import zh from "./language/zh.js"
import en from "./language/en.js"
import es from "./language/es.js"
const messages = {
  zh: zh,
  en: en,
  es: es,
}
// 创建 i18n 实例
const i18n = createI18n({
  locale: 'zh',		// 默认语言，再 App.vue中初始化
  fallbackLocale: 'zh', // 备用语言
  messages: messages,
})
export default i18n
```

##### 7.1.4 element-plus 语言包管理

```js
// src/lang/element-plus-i18n.js
import en from 'element-plus/es/locale/lang/en'
import zhCn from 'element-plus/es/locale/lang/zh-cn'
import es from 'element-plus/es/locale/lang/es'
export const elementLocales = {
  en : en,
  es : es,
  zh : zhCn,
}
```

##### 7.1.5 main.js 注册 i18n

```js
import i18n from '@/lang/index'
app.use(i18n)
```

##### 7.1.6 App.vue 初始化 local

```vue
<template>
  <!-- element-plus 国际化组件处理 -->
  <el-config-provider :locale="elementLocales[lang]">
    <router-view></router-view>
  </el-config-provider>
</template>

<script setup>
import useSettingsStore from '@/store/modules/settings'
import { handleThemeStyle } from '@/utils/theme'
// 国际化处理
import { useLanguageStore } from '@/store/modules/language'
import { elementLocales } from '@/lang/element-plus-i18n'
import { useI18n } from 'vue-i18n'
import { computed } from 'vue'
// 获取最新的local值
const languageStore = useLanguageStore()
let lang = computed(() => languageStore.language)
// 实施更新 i18n
const {locale} = useI18n()
locale.value = lang.value

onMounted(() => {
  nextTick(() => {
    // 初始化主题样式
    handleThemeStyle(useSettingsStore().theme)
  })
})
</script>
```

##### 7.1.8 切换语言组件封装

```vue
<template>
    <el-dropdown placement="bottom-end" @command="selectLanguage">
        <!-- 展示给客户，默认看到的 -->
        <span class="el-dropdown-link">
            {{ $t('lang.language') }}
            <svg-icon :icon-class="languageStore.language" />
            <el-icon><CaretBottom/></el-icon>
        </span>
        <!-- 语言下拉列表 -->
        <template #dropdown>
            <el-dropdown-menu>
                <el-dropdown-item command="zh" >中文</el-dropdown-item>
                <el-dropdown-item command="es" >Español</el-dropdown-item>
                <el-dropdown-item command="en" >English</el-dropdown-item>
            </el-dropdown-menu>
        </template> 
    </el-dropdown>
</template>

<script setup name="LangSelect">
import { useI18n } from 'vue-i18n'
import { useLanguageStore } from '@/store/modules/language';
import { CaretBottom } from '@element-plus/icons-vue';
import { changeLanguage } from '../../api/login';
import { ElMessage } from 'element-plus';

const languageStore = useLanguageStore()
// 实时更新 i18n
const {locale} = useI18n()
const {t} = useI18n()
const javaLang = {
    zh : "zh_CN",
    es : "es_ES",
    en : "en_US"
}
const selectLanguage = (key) => {
  languageStore.setLanguage(key)
  locale.value = key
  changeLanguage(javaLang[key]).then(res => {
    //window.location.reload()
    ElMessage.success(t('lang.changeLanguageSuccess'))
  })
}

</script>

<style lang="scss" scoped>
.el-dropdown-link{
  height: 100%;
  margin-left: 10px;
  margin-right: 10px;
  padding: 0;
  display: flex;
  align-items: center;
  // color: $layout-font-color;
  font-size: 25px;
  border: none !important;  // 隐藏组件el-dropdown 的边框
  outline: none !important;  // 隐藏组件el-dropdown 的边框
}
</style>
```



#### 	7.2 后端国际化

##### 	7.2.1 JDK 国际化

```java
// 1 国际化3要素
	-- Local: 不同时区、位置、语言(zh_CN en_US);
	-- baseName_Local.properties : 国际化配置文件（key = value）;
	-- ResourceBundle 资源包: 
		-- ResourceBundle.getBundle(baseName,Local) 
            -> 根据给定的 baseName 和 Local 读取配置文件得到文字信息；
		-- ResourceBundle.getString(key) -> 获取语言文字；

// 2 代码举例
public class i18nTest{
	// local
    public void getLocale(){
		Locale locale = Locale.getDefault();
		// 打印结果是操作系统的语言：zh_CN
		system.out.println(locale);
		// Local的另外一种用法, 结果：zh_CN,en_US
		system.out.println(Locale.CHINA);
		system.out.println(Locale.US);
    }
    
    // I18N 使用
    public void getLocale(){
    	// 1 获取语言标识
		Locale locale = Locale.US;
		// 2 读取指定语言的配置文件
		ResourceBundle i18n = ResourceBundle.getBundle("messages", locale)
		// 3 从指定语言配置文件中获取 翻译后的文字
		String str = i18n.getString("login.username")
		system.out.println(str);
    }

}
```

##### 	7.2.2 SpringBoot 国际化

```java
// com.ruoyi.framework.config.i18nconfig
	-- 1 设置默认语言
	-- 2 添加拦截器，获取参数 "lang" -> 将 "lang" 的值来切换语言
// com.ruoyi.common.utils.MessageUtiles
	-- 1 MessageSource.getMessage(code, args, LocaleContextHolder.getLocale())
		->Spring 的国际化资源接口，主要用于获取不同语言环境下的消息内容
	-- 2 LocaleContextHolder.getLocale()：从 LocaleContextHolder 中获取当前线程的 Locale（语言环境）
// application
	-- 1 配置多语言配置文件的 baseName；
	-- 2 配置编码格式 UTF-8 避免编码乱码；
// sucurityConfig.java
	-- 1 允许匿名访问"/changeLanguage"
// SysLoginController.java
    -- 1 添加访问方法，传递参数"lang"必须和配置文件一致"zh_CN"、"en_US"、"es_ES"
    @GetMapping("/changeLanguage")
    public AjaxResult changeLanguage(String lang)
    {
        return AjaxResult.success();
    }
```

### 8 redis 数据缓存

#### 		8.1 常用数据缓存

```

```

### 9 前端图片展示 懒加载

```

```

### 10 公共数据

```java
// 1 注解sql拼接 加入 共享数据的
	tenantId = 66
// 2 维护常量 
    SystemConfigConstants.COMMON_TENANT_ID = 66
// 3 编辑 / 删除 都需要校验
    公共数据 禁止编辑 禁止删除
```









## 七 技术笔记

### 1 mabatis 使用

#### 	1.1 多表映射

```java
// 1 举例： SysUser -> SysUser 里有 List<SysRole> 和 SysDept
	-- 通过userId 查询 SysUser -> 同时 将关联的 List<SysRole>、SysDept 一并写入；
// 2 xml 中通过 resultMap 标签进行结果映射处理
	// 2.1  SysUserResult 是 SysUser 查询后的结果映射
	<resultMap type="SysUser" id="SysUserResult">
    	<!-- ... -->
	</resultMap>
	// 2.2 association 标签 ： 关联映射
	<association property="dept" javaType="SysDept" resultMap="deptResult" />
    // 2.3 collection 标签：集合映射
    <collection property="roles" javaType="java.util.List" resultMap="RoleResult" />
    
```

```xml
<resultMap type="SysUser" id="SysUserResult">
        <id     property="userId"       column="user_id"      />
        <result property="deptId"       column="dept_id"      />
        <result property="userName"     column="user_name"    />
        <result property="nickName"     column="nick_name"    />
        <result property="email"        column="email"        />
        <result property="phonenumber"  column="phonenumber"  />
        <result property="sex"          column="sex"          />
        <result property="avatar"       column="avatar"       />
        <result property="password"     column="password"     />
        <result property="status"       column="status"       />
        <result property="delFlag"      column="del_flag"     />
        <result property="loginIp"      column="login_ip"     />
        <result property="loginDate"    column="login_date"   />
        <result property="createBy"     column="create_by"    />
        <result property="createTime"   column="create_time"  />
        <result property="updateBy"     column="update_by"    />
        <result property="updateTime"   column="update_time"  />
        <result property="remark"       column="remark"       />
        <association property="dept"    javaType="SysDept"         resultMap="deptResult" />
        <collection  property="roles"   javaType="java.util.List"  resultMap="RoleResult" />
    </resultMap>
	
    <resultMap id="deptResult" type="SysDept">
        <id     property="deptId"    column="dept_id"     />
        <result property="parentId"  column="parent_id"   />
        <result property="deptName"  column="dept_name"   />
        <result property="ancestors" column="ancestors"   />
        <result property="orderNum"  column="order_num"   />
        <result property="leader"    column="leader"      />
        <result property="status"    column="dept_status" />
    </resultMap>
	
    <resultMap id="RoleResult" type="SysRole">
        <id     property="roleId"       column="role_id"        />
        <result property="roleName"     column="role_name"      />
        <result property="roleKey"      column="role_key"       />
        <result property="roleSort"     column="role_sort"      />
        <result property="dataScope"    column="data_scope"     />
        <result property="status"       column="role_status"    />
    </resultMap>
	
	<sql id="selectUserVo">
        select u.user_id, u.dept_id, u.user_name, u.nick_name, u.email, u.avatar, u.phonenumber, u.password, u.sex, u.status, u.del_flag, u.login_ip, u.login_date, u.create_by, u.create_time, u.remark, 
        d.dept_id, d.parent_id, d.ancestors, d.dept_name, d.order_num, d.leader, d.status as dept_status,
        r.role_id, r.role_name, r.role_key, r.role_sort, r.data_scope, r.status as role_status
        from sys_user u
		    left join sys_dept d on u.dept_id = d.dept_id
		    left join sys_user_role ur on u.user_id = ur.user_id
		    left join sys_role r on r.role_id = ur.role_id
    </sql>
```



### 2 通用接口调用



### 3 vue 打印

​	3.1 打印驱动 lodop

​	3.2 vue 插件 kr-print-designer

​	3.3 虚拟表 解决 前端数量量过大的卡死现象，比如分页查询展示 10000条，使用 el-table, 并设置虚拟表的属性！

### 4 security  笔记

#### 	4.1 security 调用流程

```java
// 1 登录认证
LoginController -> LoginServer.login(LoginBody) -> 验证码校验、登录前置校验 -> UserDetailsServiceImpl 密码校验 -> 返回登录认证后的 userDetails -> 将 userDetails 添加到上下文 authentication；

// 2 鉴权
JwtAuthenticationTokenFilter 过滤器 -> 验证请求头中的token有效性:
-> 请求无token 直接放行，没有 Authentication 上下文权限信息 -> AuthenticationEntryPointImpl 鉴权失败处理器  -> 后面的访问会报401 鉴权无效；
-> 请求有token -> 先判断token有效性(过期、异地登录、强制退出) -> 将错误直接返回给前端；
```

#### 	4.2 token涉及的地方

```java
// 1 Tokenserver
// 2 Login流程
// 3 Logout 流程
// 4 强制退出流程
// 5 JTW过滤器
```

### 5 Fork 项目 - 同步原开源项目

```java
// 1 克隆fork项目到本地
git clone https://gitee.com/你的用户名/项目名.git
cd 项目名

// 2 添加 原开源项目的远程地址
git remote add upstream https://gitee.com/原项目的用户名/项目名.git

// 2.1 确认是否添加成功
git remote -v

// 3 从上游原开源项目拉去更新
git fetch upstream

// 4 合并上有更改到本地分支，例如 master分支 -> 这个操作会把原项目的更新同步到你的本地项目中
git checkout springboot3
git merge upstream/springboot3

// 5 IDEA上手动解决合并冲突

// 6 解决合并冲突后 -> 完成合并
git add .
git commit -m "Resolved conflicts and merged upstream changes"

// 7 将更新推送到自己的远程项目
git push origin springboot3

```
### 6 多租户

#### 			6.1 所租户表结构设计

```sql
 -- ----------------------------
 -- 20、租户 表
 -- ----------------------------
drop table if exists sys_tenant;
create table sys_tenant (
    tenant_id       bigint(20)      not null auto_increment     comment '租户唯一标识',
    tax_number      varchar(50)     not null                    comment '税号',
    tenant_name     varchar(100)    not null                    comment '租户名称',
    tenant_type     char(1)         not null                    comment '租户类别（0公司 1个人）',
    status          char(1)         default '1'                 comment '帐号状态（0正常 1停用）',
    phone_number    varchar(20)     not null                    comment '手机号',
    postal_code     varchar(10)     not null                    comment '邮编',
    address         varchar(255)    not null                    comment '地址',
    email           varchar(100)    not null                    comment '邮箱',
    create_by       varchar(64)     default ''                  comment '创建者',
    create_time     datetime                                    comment '创建时间',
    update_by       varchar(64)     default ''                  comment '更新者',
    update_time     datetime                                    comment '更新时间',
    remark          varchar(500)    default null                comment '备注',
    primary key (tenant_id)
) engine=innodb auto_increment=100 comment = '用户信息表';

 -- ----------------------------
 -- 维护 租户id 到其他系统表
 -- ----------------------------
 alter table sys_dept       add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_user       add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_post       add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_role       add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_user_role  add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_role_menu  add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_role_dept  add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_user_post  add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_oper_log   add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_dict_type  add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_dict_data  add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_config     add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_logininfor add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_job        add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_job_log    add column tenant_id bigint(20) default 1 comment '租户id';
 alter table sys_notice     add column tenant_id bigint(20) default 1 comment '租户id';
```

#### 			6.2 security 认证

```java
// 1 "/login" 请求添加 taxNumber 税号参数
	-- 添加请求头 taxNumber:taxNumber
// 2 Security 添加拦截器 GetTenantIdFilter
	-- 1. 只过滤登录"/login"的Post请求；
	-> 2. 获取请求头 "taxNumber"；
    -> 3. 通过taxNumber获取 tenantId；
    -> 4. 将 tenantId 存储到线程中， TenantIdContextHolder；
// 3 UserDetailsServiceImpl 维护
	-> 1 获取TenantIdContextHolder中的tenantId；
	-> 2 通过 tenantId 和 username 确定唯一用户，进行认证 ；
		-- SysUser user = userService.selectUserByUserNameAndTenantId(tenantId, username)
	-> 3 错误密码记录 redis 键值修改成 tenantId+username，解锁方法 redis键一致的问题
	-> 4 返回UserDetails ，即 LoginUser 存储 tenantId；
```

#### 			6.3 Aop 切面拼接Sql

##### 				6.3.1 自定义注解

```java
package com.ruoyi.common.annotation;
/**
 * 多租户表操作拼接sql -> "where tenant_id = #{tenantId}"
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface TenantId {

    /**
     * 表别名，根据引入实体类的别名来获取对应的别名
     * @return
     */
    public String tableAlias() default "";
}
```

##### 				6.3.2 设置切面类

```java
package com.ruoyi.framework.aspectj;

@Aspect
@Component
public class TenantIdAspect {

    public static final String TENANT_ID = "tenantId";

    @Before("@annotation(controllerTenantId)")
    public void doBefore(JoinPoint joinPoint, TenantId controllerTenantId) 
    {
        // 清理数据权限, 防止sql注入，过滤条件BaseEntity的params属性（params.tenantId）
        clearTenantId(joinPoint);
        handleTenantId(joinPoint, controllerTenantId);
    }

    /**
     * BaseEntity 中的 params 属性,赋值 待拼接的sqlStr
     * @param joinPoint
     * @param controllerTenantId
     */
    private void handleTenantId(JoinPoint joinPoint, TenantId controllerTenantId) 
    {
        // 获取操作用户
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (StringUtils.isNotNull(loginUser))
        {
            SysUser user = loginUser.getUser();
            // 管理员不拼接sql
            if (StringUtils.isNotNull(user) && !user.isAdmin())
            {
                // 获取操作用户的租户ID
                Long tenantId = user.getTenantId();
                if (StringUtils.isNotNull(tenantId))
                {
                    Object entity = joinPoint.getArgs()[0];
                    // 只有继承 BaseEntity 的实体类才能使用参数赋值
                    if (StringUtils.isNotNull(entity) && entity instanceof BaseEntity) 
                    {
                        BaseEntity baseEntity = (BaseEntity) entity;
                        // sql拼接 tenant_id
                        StringBuilder sqlStr = new StringBuilder();
                        // 注解是否有别名 -> 决定是否拼接别名
                        if (StringUtils.isNotEmpty(controllerTenantId.tableAlias()))
                        {
                            // 待拼接的sql = "别名.tenant_id = tenantId"
                            sqlStr.append(controllerTenantId.tableAlias())
                                    .append(".tenant_id = ")
                                    .append(tenantId);
                        } 
                        else 
                        {
                            sqlStr.append("tenant_id = ")
                                    .append(tenantId);
                        }
                        // 赋值待拼接的sql
                        baseEntity.getParams().put(TENANT_ID, sqlStr);
                    }
                }
            }
        }
    }


    /**
     * 拼接权限sql前先清空params.tenantId
     * @param joinPoint
     */
    private void clearTenantId(JoinPoint joinPoint) 
    {
        Object params = joinPoint.getArgs()[0];
        if (StringUtils.isNotNull(params) && params instanceof BaseEntity) 
        {
            BaseEntity baseEntity = (BaseEntity) params;
            baseEntity.getParams().put(TENANT_ID, "");
        }
    }
}
```

##### 				6.3.3 维护表 和 实体类

```java
// 1 维护表
alter table tb_dish  add column tenant_id bigint(20) default 1 comment '公司id';
alter table tb_dish  add column dept_id bigint(20) default 1 comment '部门id';
alter table tb_dish  add column user_id bigint(20) default 1 comment '用户id';

// 2 维护实体类
@Excel(name = "公司编号")
private Long tenantId;

@Excel(name = "用户编号")
private Long userId;

@Excel(name = "部门编号")
private Long deptId;

同时维护对应的 set() 、 get() 、还有 toString() 转义方法
```

##### 				6.3.4	方法添加注解

```java
package com.ruoyi.sky.service.impl;

@Override
@TenantId(tableAlias = "s")
@DataScope(deptAlias = "d", userAlias = "u")
public List<Dish> selectDishList(Dish dish)
{
    return dishMapper.selectDishList(dish);
}
```

##### 				6.3.5 sql添加拼接字段

```xml
<!-- 基础sql维护别名 -->
<sql id="selectDishVo">
        select s.id, s.name, s.price, s.image, s.description, s.status, s.create_time, s.update_time, s.tenant_id from tb_dish s
</sql>

<select id="selectDishList" parameterType="Dish" resultMap="DishResult">
    <include refid="selectDishVo"/>
    <!-- 数据范围需要添加 部门、用户 关联表sql -->
    left join sys_dept d on s.dept_id = d.dept_id
    left join sys_user u on s.user_id = u.user_id
    <where>
        <!-- 多租户的拼接 放到最前面 -->
        ${params.tenantId}
        <!-- 注意：基础sql维护别名！！！！ -->
        <if test="name != null  and name != ''"> and s.name like concat('%', #{name}, '%')</if>
        <if test="status != null "> and s.status = #{status}</if>
        <!-- 数据权限的拼接 -->
        ${params.dataScope}
    </where>
</select>
```

#### 		6.4 新增租户 分离表

```java

```

#### 		6.5 表分离sql拼接处理

```java

```

### 7 后端防止重复提交

#### 		7.1 添加注解

```java
// 注解添加到 controller的方法上，主要是 添加的功能 防止重复提交
@RepeatSubmit
```

#### 		7.2 防止重复提交的实现逻辑

```java
// 1 添加过滤器 RepeatableFilter()
如果是HttpServletRequest实例象且Content-Type为application/json
-> 则将request包装为 自定义的 RepeatedlyRequestWrapper() 实体类
-> 通过 RepeatedlyRequestWrapper() 将请求体存储在内存中 , 重复读取inputStream的request

// 1.2 FilterConfig 注册过滤器 RepeatableFilter()

// 2 添加拦截器 RepeatSubmitInterceptor 接口
通过接口实现 SameUrlDataInterceptor -> 验证请求url + token + 请求数据 是否一致
-> 如果判定一直，且两次提交的时间间隔小于 设置的重复提交的时间 -> 判定是重复提交 -> 结束请求，返回错误信息；
-> 如果不是重复提交，存入到redis -> 便于后续的重复提交验证！

// 2.2 ResourcesConfig 注册拦截器 RepeatSubmitInterceptor
package com.ruoyi.framework.config;
```

### 8 数据库主从复制

#### 	8.1 配置 mysql 主从复制

```
// 黑马程序员 mysql 
https://www.bilibili.com/video/BV1jT411r77s/?p=2&spm_id_from=pageDriver&vd_source=90ff53fe44d29e00ed0199e3c93004c2
```

#### 	8.2 全局锁 从库备份数据

```
// 黑马程序员 mysql 
https://www.bilibili.com/video/BV1jT411r77s/?p=2&spm_id_from=pageDriver&vd_source=90ff53fe44d29e00ed0199e3c93004c2
```

#### 	8.3 读写分离

```

```

### 9 添加乐观锁机制

#### 	9.1 乐观锁注解

```java
// 1 乐观锁注解
@OptimisticLock
-- maxRetryTimes() default 3	// 最大重试次数
-- retryWaitTime() default 50	// 每次重试的时间间隔

// 2 乐观锁错误
OptimisticLockException(message)
```

#### 	9.2 乐观锁AOP切面类

```java
// 3 乐观锁切面类
com.ruoyi.framework.aspectj.OptimisticLockAspect
-- 返回 OptimisticLockException 类型的错误，就会重新执行更新操作
-- 控制最多重新执行的次数
-- 控制每次执行的间隔时间
```

#### 	9.3 乐观锁应用

```java
// 4 表、实体类 添加 version 字段
// 5 service实现类的方法上添加注解 @OptimisticLock
	@OptimisticLock(retryTimes = 3)
    @Transactional(rollbackFor = Exception.class)
    public void updateProduct(Product product) 
    {
    	...
        // 6 业务校验
        Product existingProduct = productMapper.selectById(product.getId());
        if (existingProduct == null) {
            throw new BusinessException("PRODUCT_NOT_FOUND", "商品不存在");
        }
        // 7 设置版本号
        product.setVersion(existingProduct.getVersion());
        // 8 更新商品
        int updated = productMapper.updateWithVersion(product);
        if (updated == 0) {
            throw new OptimisticLockException("更新失败");  // 这里会被AOP捕获并作为乐观锁异常处理
        } 
    }
```



### 10 Windows 管理多个版本的node

```bash
// 1 安装 nvm
https://github.com/coreybutler/nvm-windows/releases

// 2 查看已安装的 node 版本
nvm list

// 3 安装特定版本的Node.js
nvm install 20.16.0

// 4 安装最新版本的node
nvm install --lts

// 5 切换 node 版本
nvm use 16.13.1

// 6 查看当前使用的node版本
node -v

```

### 11 若依项目-生成代码

#### 11.1 新增模块

```java
1. 新增模块
2. pom 导入 ruoyi-framework
3. 父组件 管理新增模块版本
4. ruoyi-admin 的pom 导入 新增模块，否则静态资源文件无法获取！
```

#### 11.2 创建数据库表结构

```java
1. 创建表结构；
2. 必须带有"tenant_id"字段，用于租户管理；
```

#### 11.3 生成代码

```java
1.代码生成按照之前的修改；
2.tenant_id字段 需要查询，为了管理使用
```

#### 11.4 生成代码导入

```java
1. 导入数据库文件；
2. 导入vue文件
3. 导入java文件
```

#### 11.5 前端代码修改

```js
// 1 tenant_id 过滤查询；
	// 1.1 导入 useUserStore
    import useUserStore from "@/store/modules/user";
    // 1.2 租户ID字段过滤使用
    const userStore = useUserStore();

    /** 查询列表 */
    function getList() {
      ...
      // 1.3 请求参数增加租户ID
      queryParams.value.tenantId = userStore.tenantId;
      ...
    }

// 2 删除 tenant_id 查询选项；
```

#### 11.6 后端代码修改

```java
// 1 新增修改
	-- 添加 create_by、tenant_id 字段赋值
// 2 修改修改
	-- 添加 update_by 字段赋值
// 3 查询列表修改
	-- 添加 @TenantId注解
	-- xml文件添加${params.tenantId}
// 4 校验插入、修改的数据唯一性
	-- checkXxxxxUnique(xxx)
```

### 12 数据库 sql

```sql
-- 1 单价、数量 类型确定：
	单价: decimal(10,2)
	数量: decimal(10,2)
	总金额: decimal(12,4)
	java -> BigDecimal totalPrice = BigDecimal.valueOf(quantity).multiply(price);

	长度cm: int
	重量g: int
	重量KG: decimal(10,3)
	体积m3: decimal(10,3)
	
-- 2 唯一性校验的最有写法
	SELECT exists(
        select 1 from erp_product where product_name = #{productName} ${params.tenantId}
        <if test="productId != null">
          and product_id != #{productId}
        </if>
    )
    
-- 3 表字段添加索引，减少回表，提速
	-- 3.1 单索引添加
    ALTER TABLE `erp_order_sequence`
    ADD INDEX `idx_tenant_id` (`tenant_id`);
	-- 3.2 组合索引添加
    ALTER TABLE `erp_order_sequence`
    ADD INDEX `idx_tenant_status` (`tenant_id`, `order_type`);
    -- 3.3 删除索引
    ALTER TABLE `erp_order_sequence`
	DROP INDEX `idx_tenant_status`;
    
-- 4 批量更新
	-- 通过入库单 批量更新库库存 单条件 (处理能力 500条每次)
	<update id="batchUpdateInventoryQuantity" parameterType="list">
        UPDATE erp_inventory AS e
        JOIN (
            <foreach collection="list" item="item" separator="UNION ALL">
                SELECT #{item.id} AS id, #{item.quantity} AS quantity
            </foreach>
        ) AS t ON e.id = t.id
        SET e.quantity = e.quantity + t.quantity;
    </update>
    
    --  通过入库单 批量更新库库存 多条件使用临时表 (大表，或者超过500条)

    
 -- 5 分批插入
 	import org.slf4j.Logger;
	import org.slf4j.LoggerFactory;
	private static final Logger log = LoggerFactory.getLogger(StockInServiceImpl.class);
	// 分批插入
    int batchSize = ProductConstants.BATCH_SIZE;
    // 分批执行
    int total = details.size();
    log.info("开始批量插入erp_purchaseOrderDetail，总数据量：{}", total);
    for (int i = 0; i < total; i += batchSize)
    {
       int endIndex = Math.min(i + batchSize, total);
       List<GoodsReceiptsDetails> subList = details.subList(i, endIndex);
       purchaseOrderService.updateReceivedQuantityByPurchaseOrderId(subList);
       log.info("批次插入erp_purchaseOrderDetail，进度：{}/{}", endIndex, total);
   }
   
 -- 6 批量插入 如果主键冲突就修改操作
	-- 6.1 批量插入
    <insert id="batchUpsertInventory">
        INSERT INTO erp_product_inventory
            (warehouse_id, sku_id, batch_no, quantity, average_cost, tenant_id)
        VALUES
            <foreach collection="list" item="item" separator=",">
                (#{item.warehouseId}, #{item.skuId}, #{item.batchNo}, #{item.quantity}, #{item.totalCost}/NULLIF(#{item.quantity},0) , #{item.tenantId})
            </foreach>
        ON DUPLICATE KEY UPDATE
            quantity = quantity + VALUES(quantity),
            average_cost = (average_cost * quantity + #{item.totalCost}) / NULLIF(quantity + VALUES(quantity), 0);
    </insert>

-- 7 临时表处理更新，提高性能和安全 (TEMPORARY 临时表会话结束自动删除，最后手动删除)
<!-- 在同一个事务中处理，确保临时表能被正确删除 -->
<insert id="batchProcessReceipts">
    /* 7.1. 创建临时表 */
    CREATE TEMPORARY TABLE temp_receipt_detail (
        sku_id varchar(32),
        order_id varchar(32),
        received_quantity decimal(10,2)
    );
    
    /* 7.2. 插入数据 */
    INSERT INTO temp_receipt_detail (sku_id, order_id, received_quantity)
    VALUES 
    <foreach collection="list" item="item" separator=",">
        (#{item.skuId}, #{item.purchaseOrderId}, #{item.receivedQuantity})
    </foreach>;
    
    /* 7.3. 更新主表 */
    UPDATE erp_purchase_order_detail d
    JOIN temp_receipt_detail t ON d.sku_id = t.sku_id AND d.order_id = t.order_id
    SET 
        d.received_quantity = d.received_quantity + t.received_quantity,
        d.shortage_quantity = d.shortage_quantity - t.received_quantity
    WHERE d.unit_price > 0;
    
    /* 7.4. 删除临时表 */
    DROP TEMPORARY TABLE IF EXISTS temp_receipt_detail;
</insert>

-- 7 禁用子级
update erp_finance_account set status = #{status} where FIND_IN_SET(#{accountId}, ancestors)

-- 8 批量修改

-- 9 表自动更新时间的字段
ALTER TABLE your_table_name
ADD COLUMN flow_time DATETIME DEFAULT CURRENT_TIMESTAMP;

-- 10 批量插入
<!-- 批量新增 -->
    <insert id="batchInsertSalesPromotionScope">
        INSERT INTO erp_sales_promotion_scope (
            promotion_id,
            is_all_product,
            category_id,
            sku_id,
            tenant_id
        ) VALUES
        <foreach collection="list" item="item" index="index" separator=",">
            (
            #{item.promotionId},
            #{item.isAllProduct},
            #{item.categoryId, jdbcType=BIGINT},  <!-- 使用 jdbcType 指定类型 -->
            #{item.skuId, jdbcType=BIGINT},
            #{item.tenantId, jdbcType=BIGINT}
            )
        </foreach>
    </insert>

```

### 13 vue3 语句

#### 13.1 js / css样式

```scss
// 1 el-table 内容左对其 标题居中 超长部分隐藏 固定在左侧
<el-table-column label="商品名称" header-align="center" prop="productName" show-overflow-tooltip fixed="left" />

// 2 数据获取
const data = { "型号": "AA", "尺寸": "SS" };
for (const [key, value] of Object.entries(data)) {
  console.log(`Key: ${key}, Value: ${value}`);
}

// 3 避免重复赋值同一个变量
A = A.map(item => item...)

// 4 路由缓存:  keep-alive -> 必须 "组件名" 与 "路由配置的name" 保持一致!!!

// 5 if(name) 一下情况都是false 
operateLog === null
operateLog === undefined
operateLog === false
operateLog === 0
operateLog === ''（空字符串）
operateLog === NaN

// 6  if(name == null) 只有  null 和 undefined 是false

```

#### 13.2 开发常见问题：

##### 13.2.1 深拷贝

```javascript
// 1 深拷贝使用 lodash
-- 问题： skuStatus 状态 0 1 变成了 false
-- 解决办法： 重新安装lodash npm install --save lodash

// 2 菜单管理问题
-- 顶级菜单 product
-- 与组件名 product 一致导致其他菜单无法访问
-- 解决办法： 修改顶级菜单 productManage
```

#### 13.3 h函数

```js
// 1 不能使用"-"，需要转成 驼峰; eg: fetch-suggestions -> fetchSuggestions;
// 2 使用 element-plus 组件写法：ElAutocomplete，不可以写成"el-autocomplete";
// 3 样式不能写在 css 中，需要写在 h('span',{style:{样式1，样式2，...}},[h(...),h(..)])
// 4 插槽用法：h(ElAutocomplete,{...},{ 插槽部分(必须是函数表达式) })
// 4.1  默认插槽： default: ({ item }) => h(...) ； 命名插槽： suffix: () => '€'
// 4.2 函数表达式插槽 cellRenderer: ({ rowData }) => {
      return h(ElTooltip, {
        content: rowData.productName,
        placement: 'top'
      },{
      // 插槽必须要是 函数形式：() => {} 
      defaulu: () => h('div', {style: {
          overflow: 'hidden',       // 隐藏溢出部分
          textOverflow: 'ellipsis', // 使用省略号
          whiteSpace: 'nowrap',     // 禁止换行
          cursor: 'pointer'         // 鼠标变成指针，增加交互提示
        } },rowData.productName)
      }
      )   
    }
    
// 5 举例：    
{
    key: 'productCode',
    title: '商品编码',
    width: 180,
    align: 'center',
    cellRenderer: ({ rowData, rowIndex }) => {
      if (form.value.orderStatus === OrderStatusEnum.EDIT) {
        return h(ElAutocomplete, {
          modelValue: rowData.productCode,
          'onUpdate:modelValue': (value) => {
            form.value.items[rowIndex].productCode = value
          },
          fetchSuggestions: queryProducts,
          placeholder: '输入商品编码或名称',
          onSelect: (item) => handleProductSelect(item, rowIndex),
          class: 'full-width',
        }, {
          default: ({ item }) => h('div', { style: { display: 'inline-flex', alignItems: 'center', whiteSpace: 'nowrap' } }, [
            h('div', `${item.productCode} - ${item.productName}`),
            h('small', `库存: ${item.skuStock}`)
          ])
        })
      }
      return rowData.productCode
    }
  }
```

#### 13.4 虚拟表格

```vue
<!-- 1 自适应高度 :fixed="true"补全屏幕留白 -->
<div style="height: 400px">
    <el-auto-resizer>
        <template #default="{ height, width }">
			<el-table-v2
             :columns="columns"
             :data="tableData"
             :width="width"
             :height="height"
             :fixed="true"	
             :row-height="50"
             />
        </template>
    </el-auto-resizer>
</div>

<!-- 2 支持触摸屏 -->
<style>
    // 解决虚拟表格 触屏滚动的问题
    :deep(.el-table-v2__body) > div:nth-child(1) {
      overflow: auto !important;
    }
</style>

<!--  -->
```

#### 13.5 el-tree-select 组件

```vue
<el-table-column label="科目名称" prop="accountId" align="center"  min-width="150px" show-overflow-tooltip>
    <template #default="scope">
		<el-tree-select 
            v-model="scope.row.accountId" 
            :data="accountTree" 
            :props="treeProps"
            value-key="accountId"
            placeholder="请选择科目"
            style="width: 100%;"
            <!-- 这个地方不可以使用 @change ,因为会出现获取不到 row的现象 -->
            @node-click="(data) => handleAccountChange(scope.row, data)"
            :disabled="form.voucherStatus !== VoucherStatusEnum.VOUCHER_STATUS_DRAFT"
         >
        </el-tree-select>
    </template>
</el-table-column>
<script setup name="Voucher">
    // 1 会计科目 - 初始化列表
    const accountList = ref([])
    const accountTree = ref([])
    /** 2 会计科目 - 获取列表 */
    const getAccountList = async () => {
        listAccount()
          .then(response => {
            /** proxy.handleTree 数据类型转换 */
            accountTree.value = proxy.handleTree(response.data, "accountId", "parentId") || [];
            accountList.value = response.data || [];
          })
          .catch(error => {
            ElMessage.error("获取会计科目列表时出错:",error)
          })
    };
    
    /** 3 el-tree-select 配置 */ 
    const treeProps = {
      value: "accountId",
      label: (node) => `${node.accountCode} - ${node.accountName}`, // 自定义显示内容
      children: "children",
      disabled: (node) => node.status == '1'
    };
    
    /** 4 获取指定的会计科目树形列表 */
    const filterAccountTree = (data,currentAssistType) => {
      if (!data || !currentAssistType) {
        return data
      }
      // 用于记录应该保留的节点的ID
      const keepIds = new Set()

      // 第一次遍历：找出所有符合条件的节点及其所有父节点
      const findValidNodes = (node) => {
        if (node.assistTypes.includes(currentAssistType)) { // 假设 'supplier' 是供应商类型的标识
          // 找到符合条件的节点，记录这个节点和它所有的父节点
          let current = node
          while (current) {
            keepIds.add(current.accountId)
            // 通过parentId找父节点
            current = data.find(item => item.accountId === current.parentId)
          }
        }
      }

      // 对原始数据进行遍历
      data.forEach(findValidNodes)

      // 第二次遍历：过滤并重构树
      const filterNode = (nodes) => {
        return nodes
          .filter(node => keepIds.has(node.accountId))
          .map(node => ({
            ...node,
            children: node.children ? filterNode(node.children) : []
          }))
      }

      return filterNode(proxy.handleTree(data, "accountId", "parentId"))
    }
    
    /** 5 获取当前 辅助项类型相关的会计科目列表 */
    const currentAccountTree = computed(() => {
       return filterAccountTree(accountTree.value,form.value.assistType)
    })
</script>
```

#### 13.6 日期选择区间

```vue
<el-form-item label="交易时间" prop="flowDate" style="width: 350px;">
    <el-date-picker
       v-model="dateRange"
       type="daterange"
       value-format="YYYY-MM-DD"
       unlink-panels
       :clearable="false"
       range-separator="至"
       start-placeholder="开始日期"
       end-placeholder="结束日期"
       :default-value="dateRange"
       :disabled-date="disabledDate"
       @change="handleRangeChange"
       style="width: 100%;"
     />
</el-form-item>
<script setup name="FundFlow">
    const currentMonthStart = new Date(new Date().setDate(1));
    const currentMonthEnd = new Date(new Date().getFullYear(), new Date().getMonth() + 1, 0);
    /** 格式化日期为 YYYY-MM-DD */
    const formatDate = (date) => {
      const year = date.getFullYear()
      const month = String(date.getMonth() + 1).padStart(2, '0')
      const day = String(date.getDate()).padStart(2, '0')
      return `${year}-${month}-${day}`
    }
    /** 1 初始化日期 */
    const dateRange = ref([formatDate(currentMonthStart), formatDate(currentMonthEnd)]);

    /** 2 禁用日期 */ 
    const  disabledDate = (time) => {
      // 获取当前日期
      const now = new Date();
      // 计算3个月前的第一天
      const maxRangeStart = new Date( now.getFullYear(), now.getMonth() - 3, 1 );
      // 计算3个月后的最后一天
      const maxRangeEnd = new Date( now.getFullYear(), now.getMonth() + 4, 0 );
      return time.getTime() < maxRangeStart.getTime() || time.getTime() > maxRangeEnd.getTime();
    }
    /** 3 控制最大时间跨度 */
    const handleRangeChange = (dates) => {
      if (dates && dates.length === 2) {
        const [start, end] = dates.map((date) => new Date(date)); // 将字符串转换为 Date 对象
        // 计算月份差
        const monthDiff = (end.getFullYear() - start.getFullYear()) * 12 + (end.getMonth() - start.getMonth());
        // 如果跨度超过3个月，重置为合法范围
        if (monthDiff > 2) {
          const newEnd = new Date(start.getFullYear(), start.getMonth() + 3, 0); // 跨3个月的最后一天
          dateRange.value = [formatDate(start), formatDate(newEnd)]; // 重置范围
          ElMessage.warning("时间跨度不能超过3个月!");
        }
      }
    };
    
    /** ----- java后端请求 实际传参 params = [beginTime,endTime]*/
	listFundFlow(proxy.addDateRange(queryParams.value, dateRange.value))

    /** sql.xml 接受前端传递的参数 params = [beginTime,endTime]*/
    <if test="params.beginTime != null and params.beginTime != ''">
    	and date_format(flow_time,'%Y%m%d') &gt;= date_format(#{params.beginTime},'%Y%m%d')
    </if>
    <if test="params.endTime != null and params.endTime != ''">
         and date_format(flow_time,'%Y%m%d') &lt;= date_format(#{params.endTime},'%Y%m%d')
    </if>
</script>


```

#### 13.7 控制分页查询的数量

```js
export function listCustomer(query = {}) {
  const pageSize = query.pageSize || 20000;
  return request({
    url: '/order/customer/list',
    method: 'get',
    params: { pageSize, ...query }
  })
}
```

#### 13.8 svg-icon 使用

```vue
<!-- synchronizeData 是svg名称，无需引入 已经全局注册 -->
<el-button type="primary" plain @click="handleSynchronizeData">
    <template #icon>
		<svg-icon icon-class="synchronizeData"  />
    </template>
    同步 活动适用范围
</el-button>
```

#### 13.9 父子组件的使用

##### 	13.9.1 子组件代码

```vue
// salesPromotionScope.vue
<template>
  <el-card v-if="promotionScopeType" style="margin-bottom: 10px;" shadow="hover">
    <!-- 添加 slot，让父组件能够传递 el-form-item 进来 -->
    <slot name="promotion-scope-label"></slot>

    <el-divider content-position="left">
      <span>
        {{
          isSkuScope ? "促销活动范围 SKU" :
          isCategoryScope ? "促销活动范围 商品分类" :
          "促销活动范围 全场所有商品"
        }}
      </span>
    </el-divider>

    <!-- 全场所有商品 -->
    <template v-if="isAllScope">
      <p style="text-align: center; padding: 20px; font-weight: bold;">
        该促销活动适用于所有商品，无需额外选择 SKU 或分类。
      </p>
    </template>

    <!-- SKU 绑定 -->
    <template v-if="isSkuScope">
      <el-table :data="salesPromotionScope" border style="width: 100%" ref="salesPromotionScope">
        <el-table-column label="SKU 条码" prop="skuId" align="center" min-width="120px">
          <template #default="scope">
            <el-select-v2 v-model="scope.row.skuId" filterable :options="formattedSkuList"
              placeholder="请输入 SKU Code" style="width: 100%" @change="handleSkuChange(scope.row)"
              :fit-input-width="false" />
          </template>
        </el-table-column>
        <el-table-column label="SKU 名称" align="left" header-align="center" show-overflow-tooltip>
          <template #default="scope">
            <span>{{ scope.row.productSkuVo?.productName }}</span>
          </template>
        </el-table-column>
        <el-table-column label="SKU 规格" align="left" header-align="center" show-overflow-tooltip>
          <template #default="scope">
            <div v-for="(item, index) in getSkuValue(scope.row.productSkuVo?.skuValue)" :key="index">
              <strong v-if="item[0] !== '' && item[0] !== 'skuName'">
                {{ item[0] }}:
              </strong>
              <span v-if="item[0] !== '' && item[1] !== 'skuValue'">
                {{ item[1] }}
              </span>
              <span v-if="item[0] == '' || item[0] == 'skuName'"> -- -- </span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="单价" prop="detailPrice" align="right" header-align="center" min-width="60px" show-overflow-tooltip>
          <template #default="scope">
            <span>{{ formatTwo(scope.row.productSkuVo?.skuPrice1) }} € </span>
          </template>
        </el-table-column>

        <el-table-column label="操作" width="75" align="center">
          <template #default="scope">
            <el-button type="danger" size="small" @click="removeDetail(scope.$index)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-button type="primary" @click="addDetail" v-if="salesPromotionScope.length < 10" style="margin-top: 10px;">
        添加 SKU
      </el-button>
    </template>

    <!-- 分类绑定 -->
    <template v-if="isCategoryScope">
      <el-table :data="salesPromotionScope" border style="width: 100%" ref="salesPromotionScope">
        <el-table-column label="商品分类" prop="categoryId" align="center" min-width="120px">
          <template #default="scope">
            <el-tree-select v-model="scope.row.categoryId" :data="categoryList" 
              :props="{
                value: 'categoryId',
                label: 'categoryName',
                children: 'children',
                disabled: (data) => data.status != StatusEnum.NORMAL
              }" 
              value-key="categoryId" placeholder="请选择商品分类" 
              style="width: 195px" clearable 
            />
          </template>
        </el-table-column>

        <el-table-column label="操作" width="75" align="center">
          <template #default="scope">
            <el-button type="danger" size="small" @click="removeDetail(scope.$index)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <el-button type="primary" @click="addDetail" v-if="salesPromotionScope.length < 10" style="margin-top: 10px;">
        添加 商品分类
      </el-button>
    </template>
  </el-card>
</template>

<script setup>
import { computed, getCurrentInstance } from 'vue';

const props = defineProps({
  promotionScopeType: String,
  salesPromotionScope: Array,
  formattedSkuList: Array,
  categoryList: Array,
  ScopeTypeEnum: Object,
  StatusEnum: Object
});

const isSkuScope = computed(() => props.promotionScopeType === props.ScopeTypeEnum.SKU);
const isCategoryScope = computed(() => props.promotionScopeType === props.ScopeTypeEnum.CATEGORY);
const isAllScope = computed(() => props.promotionScopeType === props.ScopeTypeEnum.ALL);

console.log(props);

const emit = defineEmits(['handleSkuChange', 'removePromotionScopeDetail', 'addPromotionScopeDetail']);

const handleSkuChange = (row) => emit('handleSkuChange', row);
const removeDetail = (index) => emit('removePromotionScopeDetail', index);
const addDetail = () => emit('addPromotionScopeDetail');

</script>

```

##### 	13.9.2 父组件 - 调用子组件

```vue
<!-- 活动适用范围模板 -->
<salesPromotionScope
 	:promotionScopeType="form.salesPromotionRuleDiscount.promotionScopeType"
 	:salesPromotionScope="form.salesPromotionScope"
 	:formattedSkuList="formattedSkuList"
 	:categoryList="categoryList"
 	:ScopeTypeEnum="ScopeTypeEnum"
 	:StatusEnum="StatusEnum"
 	@addPromotionScopeDetail="addSalesPromotionScopeDetail"
 	@removePromotionScopeDetail = "removeSalesPromotionScopeDetail"
 	@handleSkuChange="handleSkuChange"
 >
    <template #promotion-scope-label>
      <el-form-item label="活动适用范围:" >
         <el-radio-group 
           v-model="form.salesPromotionRuleFullReduce.promotionScopeType"
	      @change="handlePromotionScopeTypeChanged"
		>
            <el-radio-button
              v-for="dict in erp_sales_promotion_scope"
              :key="dict.value"
              :label="dict.value"
              :value="dict.value"
            >{{dict.label}}</el-radio-button>
         </el-radio-group>
      </el-form-item>
    </template>
</salesPromotionScope>
```

#### 13.10 表el-table 展开

```vue
<!-- 1 @expand-change="handleExpandChange" 展开操作触发 -->
<!-- 2 row-key="accountId" 展开行绑定的唯一ID -->
<!-- 3 ref="bankAccountList" 绑定 bankAccountList -->
<el-table :data="form.bankAccountList" border style="width: 100%;" ref="bankAccountList" @expand-change="handleExpandChange" row-key="accountId">
	<!-- 4 展开行 type="expand" -->
	<el-table-column type="expand" >
                <template #default="props">
                  <div style="padding: 10px;">
                    <el-descriptions title="发票信息" :column="2" size="small">
                      <el-descriptions-item label="银行名称:">
                        <el-input v-model="props.row.bankName" placeholder="请输入银行名称" type="textarea" maxlength="50" :rows="1"/>
                      </el-descriptions-item>
                      <el-descriptions-item label="账户名称:">
                        <el-input v-model="props.row.accountName" placeholder="请输入银行名称" type="textarea" maxlength="50" :rows="1"/>
                      </el-descriptions-item>
                      <el-descriptions-item label="swiftCode:">
                        <el-input v-model="props.row.swiftCode" placeholder="请输入开户行" type="textarea" maxlength="20" :rows="1"/>
                      </el-descriptions-item>
                      <el-descriptions-item label="备注信息:">
                        <el-input v-model="props.row.remark" placeholder="请输入备注信息" type="textarea" maxlength="50" :rows="1"/>
                      </el-descriptions-item>
                    </el-descriptions>
                  </div>
                </template>
	</el-table-column>
</el-table>
-----------------------------------
<script setup name="Supplier">
    // 5 生成唯一ID
    const generateRowKey = () => `row_${Date.now()}_${Math.random().toString(16).slice(2)}`;
    const initBankAccount = () => {
      return {
        // 6 绑定唯一ID
        accountId: generateRowKey(),
        accountName: null,
        accountNo: null,
        bankName: null,
        swiftCode: null,
        remark: null,
        isDefault: '1'
      }
    }
    
    // -------------------------------- 7 el-table-expand相关 start --------------------------
    // 7.1 初始化 ref 绑定的 bankAccountList
    const bankAccountList = ref(null);
    // 7.2 展开的行
    const expandedRow = ref(null);
    const handleExpandChange = (row) => {
      if (expandedRow.value && expandedRow.value !== row) {
        // 7.3 注意：此处使用的不是form , 而是 ref 绑定的 bankAccountList
        bankAccountList.value.toggleRowExpansion(expandedRow.value, false);
      }
      expandedRow.value = row;
    };
    // -------------------------------- 7 el-table-expand相关 end --------------------------
</script>
```



### 14 订单序列化

```java
// 序号 - 使用
// 1 先插入数据
// 2.1 更新需要之前 预生成序号，检查序号是否冲突
// 2.2 更新序号(避免插入失败导致需要不一致)

// 1 插入主凭证
int res = voucherMapper.insertVoucher(voucher);
// 2 插入凭证明细，确保同事务环境
insertVoucherDetails(voucher);
// 3 维护凭证号
if (res > 0)
{
    // 预校验序号的唯一性
    String voucherNo = sequenceService.preGetNextSequenceUno(voucher.getTenantId(), SequenceConstants.ORDER_SEQUENCE_TYPE_VOUCHER);
    voucher.setVoucherNo(voucherNo);
    if (checkVoucherNoUnique(voucher))
    {
        throw new ServiceException("新增失败！凭证号: " + voucherNo  + " 已存在,凭证号不可重复，请重新添加！");
    }
    // 生成凭证号码
    voucherNo = sequenceService.generateSequenceUno(voucher.getTenantId(), SequenceConstants.ORDER_SEQUENCE_TYPE_VOUCHER);
    voucher.setVoucherNo(voucherNo);
    voucherMapper.updateVoucherNoById(voucher);
}
```



### 15 indexedDB 前端数据库

### 16 java流方式处理数据

```java
List<Long> skuIds = stockIns.stream()
        .flatMap(item -> item.getStockInDetailList().stream())
        .filter(Objects::nonNull)
        .map(StockInDetail::getSkuId)
        .distinct()
        .collect(Collectors.toList());
// 1 stockIns.stream() 将stockIns集合转换为流
// 2 flatMap用于将多个流合并成一个流
// 3 .filter(Objects::nonNull) 过滤掉null值
// 4 .map() 将StockInDetail对象映射转换为其skuId属性
// 5 .distinct() 去除重复的
// 6 .collect(Collectors.toList()) 将流收集回List集合
```

### 17 数据类型

```java
// 1 主键ID
数据库类型 bigint   java类型 long

// 2 日期类型
数据库类型 date     java类型 LocalDate

// 3 时间类型
数据库类型 datetime 	java类型 LocalDateTime  获取当前时间 LocalDateTime.now()
    
// 4 数量 
数据库类型 int	java类型 Integer
```

### 18 redisson 分布式锁

#### 18.1 引入依赖

```xml
// common.pom
<!-- redisson分布式锁 -->
<dependency>
    <groupId>org.redisson</groupId>
    <artifactId>redisson</artifactId>
</dependency>
```

#### 18.2 添加配置

```java
package com.ruoyi.framework.config;
import org.redisson.Redisson;
import org.redisson.config.Config;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.redisson.api.RedissonClient;
@Configuration
public class RedissonConfig {
    @Value("${spring.data.redis.host}")
    private String host;
    @Value("${spring.data.redis.port}")
    private String port;
    @Value("${spring.data.redis.password}")
    private String password;
    @Bean
    public RedissonClient redissonClient() {
        // 配置 config
        Config config = new Config();
        // 添加redis地址，单点地址 config.useSingleServer() ， 集群地址 config.useClusterServer()
        config.useSingleServer().setAddress("redis://" + host + ":" + port).setPassword(password);
        // 创建RedissonClient对象
        return Redisson.create(config);
    }
}

```

#### 18.3 使用锁

```java
package com.ruoyi.finance.service.impl;

// 1 引入依赖
@Autowired
private RedissonClient redissonClient;

// 2 创建锁对象，基于具体的凭证编号缩小锁的粒度
RLock lock = redissonClient.getLock(FinanceConstants.LOCK_CREATE_VOUCHER + ":" + voucher.getTenantId() + ":" + voucher.getVoucherNo());
boolean isLock = false;
try {
    // 获取锁，设置超时释放机制(等待时长、有效时长、时间单位)
    isLock = lock.tryLock(5, 10, TimeUnit.SECONDS);
    if (!isLock) {
        throw new ServiceException("其他人正在操作，请重试！");
    }
    // 业务代码，锁内执行以避免并发问题
    ......
} catch (Exception e) {
    // 记录异常日志
    log.error("新增凭证失败，错误信息: {}", e.getMessage(), e);
    throw new ServiceException("新增凭证过程中发生错误"); // 重新抛出运行时异常
} finally {
    // 释放锁
    if (isLock) {
        lock.unlock();
    }
}

```

### 19 lombok工具

#### 19.1 维护配置

```xml
<!-- lombok 工具 -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>${lombok.version}</version>
    <scope>provided</scope>
</dependency>
```

#### 19.2 使用

```java
// 1 @Data 包含下面四种注解
@Getter 
@Setter 
@ToString重写  
@EqualAndHashCode重写 

// 2 构造函数
@NoArgsConstructor无参构造 
@AllArgsConstructor全参构造  

// 3 继承父类排序字段
@EqualsAndHashCode(callSuper = true)
```

### 20 GIT 仓库使用

#### 20.1 同步更新远程源码

```bash
# 1. 确认当前文件夹的 Git 状态
git remote -v
# 获取到的远程地址如下：
origin  https://gitee.com/your-original-repo.git (fetch)
origin  https://gitee.com/your-original-repo.git (push)

# 2. 同步 Gitee 源的最新更新
git fetch origin
git merge origin/要同步的源码远程分支名

git fetch upstream
git merge upstream/springboot3

# -> 同步后通过编辑器进行合并处理，然后合并

```

#### 20.2 上传私人远程仓库

```bash
# 1. 添加 GitHub 仓库作为新的远程地址（本地命名可修改： github）
git remote add github https://github.com/your-username/your-new-repo.git

# 2. 确认远程仓库设置
git remote -v
# 获取到的远程地址如下：
origin  https://gitee.com/your-original-repo.git (fetch)
origin  https://gitee.com/your-original-repo.git (push)
github  https://github.com/your-username/your-new-repo.git (fetch)
github  https://github.com/your-username/your-new-repo.git (push)

# 3. 推送当前代码到 GitHub 
git push github main		# 本地仓库和远程仓库都是 main 分支
git push github master:main	# 本地是 master分支 远程是main分支

```

#### 20.3 清理远程仓库

```bash
# 1 清理远程仓库
git remote remove origin  # 其中 origin 是远程仓库的名字
```

### 21 springBoot3 

#### 21.1 参数校验

##### 21.1.1 类校验

```java
// 1 在类字段上添加注解
import jakarta.validation.constraints.*;
import lombok.Data;
@Data
public class UserDTO {

    @NotNull(message = "ID 不能为空")
    private Long id;

    @Size(min = 2, max = 10, message = "用户名长度必须在 2 到 10 之间")
    private String username;

    @Min(value = 18, message = "年龄不能小于 18")
    private Integer age;

    @Email(message = "邮箱格式不正确")
    private String email;
    
    @Valid // 确保嵌套对象的校验规则生效(校验对象SalesPromotionRuleFullReduce里的参数)
    private SalesPromotionRuleFullReduce salesPromotionRuleFullReduce;
}

// 2 Controller方法上添加注解 @Valid -> 激活类上的校验注解
@RestController
@RequestMapping("/user")
public class UserController {

    @PostMapping("/create")
    public ResponseEntity<String> createUser(@Valid @RequestBody UserDTO user) {
        return ResponseEntity.ok("用户创建成功");
    }
}

```

##### 21.1.2 单个参数校验

```java
// 1 类上添加注解  @Validated
@RestController
@RequestMapping("/user")
@Validated  // 需要加在类上
public class UserController {

    // 2 方法接收参数上添加注解 @NotNull @Size ......
    @GetMapping("/{id}")
    public ResponseEntity<String> getUser(@NotNull(message = "ID 不能为空") @PathVariable Long id) {
        return ResponseEntity.ok("获取用户信息成功");
    }

    @GetMapping("/search")
    public ResponseEntity<String> searchUser(@Size(min = 3, message = "关键词长度不能小于 3") @RequestParam String keyword) {
        return ResponseEntity.ok("搜索用户成功");
    }
}
```

##### 21.1.3 注解 @Validated 与 @Valid 的区别

```java
// @Valid
	-- 主要用于 @RequestBody 或 @ModelAttribute 绑定的对象校验;
	-- 适用于 类对象参数 的校验

// @Validated
	-- 除了 @Valid 的功能，还可以支持分组校验（@Validated(Group.class)）；
	-- 适用于 @RequestParam、@PathVariable 这些单个参数的校验 ；
```

#### 21.2 继承对象赋值

```java
import org.springframework.beans.BeanUtils;

// 假设你已经有一个 SalesPromotion 对象
SalesPromotion salesPromotion = salesPromotionService.getSalesPromotionById(promotionId);
// 创建 SalesPromotionVo 对象
SalesPromotionVo salesPromotionVo = new SalesPromotionVo();
// 使用 BeanUtils 复制属性
BeanUtils.copyProperties(salesPromotion, salesPromotionVo);
```





## 八 业务规范

### 1 springBoot3

#### 	1.1 mysql

```bash
# 1 必有字段
	-- xxx_id
	-- xxx_status
	-- create_time
	-- create_by
	-- update_time
	-- update_by
	-- remark
	-- tenant_id
	-- del_flag	必须设置默认值 '0'
# 2 检查唯一性写法 
	<select id="checkCodeUnique" resultType="java.lang.Boolean">
        SELECT EXISTS(
            select unit_id from erp_unit where unit_code = #{unitCode} ${params.tenantId}
            <if test="unitId != null">
                and unit_id != #{unitId}
            </if>
        )
    </select>
    -- 2.1 注意：不过滤删除状态，避免新增与删除状态一致的数据！
    -- 2.2 必须添加 ${params.tenantId} 过滤条件 -> 确保公共数据可用！
    
# 3 字段长度：
	code / name : varchar 150 （50个字符）
	remark: varchar 255 （100个字符）
	金额/数量：BigDecimal 10,3
	单价：BigDecimal 10,2
	百分数：BigDecimal 5,2
```

#### 	1.3 实体类

```bash
# 必须通过注解校验参数
	-- 1 字符串验证
	-- 1.1 @NotNull	字段值不能为 null
	-- 1.2 @NotEmpty	字段值不能为 null 或空（适用于字符串、集合、数组等）
	-- 1.3 @NotBlank	字段值不能为 null，且必须包含至少一个非空白字符（适用于字符串）
	-- 1.4 @Size
	-- 1.5 @Pattern(regexp)	字段值必须匹配指定的正则表达式
	-- 2 数值验证
	-- 2.1 @Max	字段值必须小于或等于指定的最大值;
	-- 2.2 @Min	字段值必须大于或等于指定的最小值;
	-- 2.3 @Digits(integer, fraction)	字段值必须是数字，且整数部分和小数部分的位数不能超过指定值。
	-- 2.4 @Positive	字段值必须为正数（大于 0）;
	-- 2.5 @Negative	字段值必须为负数（小于 0）;
	-- 3 特殊验证
	-- 3.1 @Email
	-- 3.2 @URL	字段值必须是有效的 URL。
	-- 4 时间验证
	-- 4.1 @Past	字段值必须是过去的日期或时间;
	-- 4.2 @PastOrPresent	字段值必须是过去或当前的日期或时间。
	-- 4.3 @Future	字段值必须是未来的日期或时间。
	-- 4.4 @FutureOrPresent	字段值必须是未来或当前的日期或时间。
	-- 5 递归嵌套验证
	-- 5.1 @Valid	用于嵌套验证，表示需要递归验证该字段的对象
# 导出使用注解
	-- 1 单属性 @Excel(...)
	-- 2 对象属性 @Excels({...})
	-- 3 列表属性不可以直接使用 @Excels({...}) 会报错
```

#### 	1.4 controller

```bash

```

#### 	1.5 service

```bash
# 1 新增/修改
	-- 必须校验唯一性
# 2 修改/删除
	-- 必须校验租户数据权限 TenantCheckUtils.checkTenantId(class.tenantId)
# 3 删除
	-- 必须先获取原始数据
	-- 根据原始数据是否存在 -> 进一步判断租户数据权限 -> 最后执行删除！
```

#### 	1.6 Mapper.xml

```bash
# 1 查询数据集合
	-- 必须添加删除状态条件	del_flag = '0'  
	-- 必须添加租户拼接条件	${params.tenantId}
# 2 唯一性校验
	-- 2.1 不需要 tenant条件，避免新增与删除状态一致的数据！
    -- 2.2 必须添加 tenant_id 过滤条件；
# 3 通过ID获取数据
	-- 3.1 不需要 tenant条件；
	-- 3.2 不需要 校验删除状态，为了后期查询删除状态的数据做准备！
# 4 修改：
	-- 4.1 不需要 tenant条件，因为修改之前已经校验了租户信息！
	-- 4.2 不需要 校验删除状态，为了后续回复删除的数据！
```



### 2 vue3

### 3 element-plus

### 4 mysql

### 5 mybatis





