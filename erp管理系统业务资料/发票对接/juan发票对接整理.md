# 《发票对接指南》

## 1 发票类型：

### 1.1 发票（完整发票）

```bash
# Factura (factura completa)
-- 发票格式：

-- 发票规则

```

### 1.2 简化发票

```bash
# 1.2.1 Factura simplificada - 没有对方信息；
# 1.2.2 Factura simplificada cualificada (como la simplificada pero con datos de destinatario) - 包含对方信息；
-- 发票格式：

-- 发票规则

```

### 1.3 替代简化发票的发票

```bash
# Factura sustitutiva de facturas simplificadas
-- 发票格式：

-- 发票规则
	1 需要备注："*Sustituye a la factura simplificada Nº [XXX], emitida el [DD/MM/YYYY]*"

```

### 1.4 差额修正发票（用于退货或价格变动的情况）

```bash
# Factura rectificativa por diferencias (para los casos de devoluciones o cambios de precios)
-- 发票格式：

-- 发票规则
	1. 发票上，需要注明所修正的发票（序列号、编号和日期）

```

### 1.5 替换修正发票（用于需要完全用新发票替换原发票的情况，发票接收方异常修改）

```bash
# Factura rectificativa por sustitución (para los casos en que es preciso sustituir completamente la factura por otra nueva)
-- 发票格式：

-- 发票规则
	1. 发票上，应注明被替代的简化发票（序列号、编号和日期）(serie, número y fecha)

```

### 1.6 作废发票

```bash
# anulación de una factura
-- 发票格式：

-- 发票规则
	1 使用场景：开具发票后，发现存在严重错误或交易最终未完成;
```

### 1.7 负数发票 ( 无票退货 )

```bash
# factura negativa
-- 发票格式：

-- 发票规则
	1. 不需要指定发票来源，即不需要  注明所修正的发票（序列号、编号和日期）；
	2. 使用场景：销售终端开具简易发票；
	3. 不是最佳的解决方案：到目前为止，税务局对这些负数发票没有提出异议！！！

```

## 2 Verifactu发送发票 - 权限：

### 	2.1	企业负责人

```bash
#	Responsable del negocio

```

### 	2.2	获得税务局授权的代表企业的咨询公司

```bash
#	Asesoría autorizada para representación ante Hacienda

```

### 	2.3 	在税务局注册并获得企业授权的社会合作者

```bash
#	Colaborador social dado de alta en Hacienda y con autorización por parte del negocio

```



## 3 操作类型 operacion

```java

```

## 4 发票类型 tipo

```java

```

## 5 数据模型

### 	5.1 发行方相关模型

#### 			**5.1.1 Emisor (请求中的发行方)**

```yaml
{
  "type": "object",
  "properties": {
    "nif": {
      "type": "string",
      "pattern": "^[A-Za-z][0-9]{8}$"  # 西班牙税号格式: 1字母+8数字
    },
    "codigo": {
      "type": "string"  # 企业代码
    }
  },
  "required": ["nif", "codigo"]  # 这两个字段都是必填的
}
```

#### 				**5.1.2 EmisorResponse (响应中的发行方)**

```yaml
{
  "type": "object",
  "properties": {
    "nombre": {"type": "string"},  # 企业名称
    "nif": {"type": "string"}      # 税号
  }
}
```

### 		5.2 发票请求模型

#### 				**5.2.1 AltaFacturaRequest (标准发票请求)**

```yaml
{
  "type": "object",
  "properties": {
    "emisor": {"$ref": "#/components/schemas/Emisor"},
    "id_transaccion": {"type": "string"},  # 交易ID
    "operacion": {"type": "string"},       # 操作类型(固定为"alta_factura")
    "desglose": {
      "type": "array",
      "items": {"$ref": "#/components/schemas/DesgloseNormal"}  # 标准明细
    }
  }
}
```

#### 	**5.2.2 FacturaSimplificadaRequest (简易发票请求)**

```yaml
{
  "type": "object",
  "properties": {
    "emisor": {"$ref": "#/components/schemas/Emisor"},
    "id_transaccion": {"type": "string"},
    "operacion": {"type": "string"},
    "desglose": {
      "type": "array",
      "items": {"$ref": "#/components/schemas/DesgloseSimplificado"}  # 简易明细
    }
  }
}
```

### 	5.3 明细模型

#### 			**5.3.1 DesgloseNormal (标准明细)**

```yaml
{
  "type": "object",
  "properties": {
    "base": {"type": "number"},      # 税基
    "tipo_iva": {"type": "integer"}, # 增值税率(整数)
    "cuota_iva": {"type": "number"}  # 增值税金额
  }
}

"desglose": [
    {
      "base": 178.02,
      "tipo_iva": 21,
      "cuota_iva": 37.38,
      "suma_total": 215.4
    },
    {
      "base": 115.96,
      "tipo_iva": 10,
      "cuota_iva": 11.6,
      "suma_total": 342.96
    },
    {
      "base": 332.48,
      "tipo_iva": 4,
      "cuota_iva": 13.3,
      "suma_total": 688.74
    }
  ]
```

#### 		**5.3.2 DesgloseSimplificado (简易明细)**

```yaml
{
  "type": "object",
  "properties": {
    "total": {"type": "number"},  // 总金额(含税)
    "tipo_iva": {
      "type": "integer",
      "enum": [4, 10, 21],  # 只允许这三种税率
      "default": 21         # 默认21%
    }
  }
}

```

#### 	**5.3.3 DetalleFactura (发票详情)**

```yaml
{
  "type": "object",
  "properties": {
    "id_factura": {"type": "integer"},  # 发票ID
    "importe_total": {"type": "number"} # 总金额
    # 注意: 实际响应包含更多字段(如QR码、日期等)，但这里只定义了这两个
  }
}

# 举例如下：
"factura": {
    "id_factura": 280,
    "tipo": "F2",
    "serie": "S",
    "numero": 61,
    "fecha": "11-05-2025",
    "hora": "22:56",
    "importe_impuestos": 17.36,	# 税额
    "importe_total": 100,	# 含税金额
    "descripcion": "VENTA DE BAZAR",
    "estado": "Grabada",	# 状态已记录？是否有其他状态？
    "qr": "...",
    "milisegundos": 113
  }
```



### 5.4 响应模型

#### 	**5.4.1 AltaFacturaResponse (标准发票响应)**

```yaml
{
  "type": "object",
  "properties": {
    "emisor": {"$ref": "#/components/schemas/EmisorResponse"},
    "entorn": "pruebas",	# 环境：测试环境
    "factura": {"$ref": "#/components/schemas/DetalleFactura"}  # 发票详情
  }
}
```

#### 	**5.4.2FacturaSimplificadaResponse (简易发票响应)**

```yaml
{
  "type": "object",
  "properties": {
    "emisor": {"$ref": "#/components/schemas/EmisorResponse"},
    "entorn": "pruebas",	# 环境：测试环境
    "factura": {"$ref": "#/components/schemas/DetalleFactura"},
    "desglose": {  # 比 标准响应 多了 明细数组
      "type": "array",
      "items": {"$ref": "#/components/schemas/DesgloseNormal"}
    }
  }
}
```

### 	5.5 开发者信息

​	公司/个人

```xml
<Software>INVOICE_PRO_2024</Software>
<Version>3.2.1</Version>
<Developer>TECH SOLUTIONS S.L.</Developer>
<DeveloperID>B12345678</DeveloperID>
```

### 	5.6 授权书

```

```

### 	5.7 软件注册声明

```

```



## 6 疑问解答

### 	20250513

```java
// 1 用户的 codigo 如何获取？

// 2 如果生产环境，如果获取环境访问权限？什么方式验证权限？

// 2 operacion 操作类型有哪些？比如 "alta_factura" 分别代表什么？

// 3 tipo 发票类型有哪些？比如 F2...

// 3.1 请求时是通过请求路径区分 发票类型的？还是通过传递的 tipo参数进行区分的？

// 4 DetalleFactura 发票详情 如何提现多税率的情况为什么不需要区分税率？
	问题描述：
		-- 相应数据： 标准发票 比 简易发票 少 desglose明细，desglose可以体现 多税率的描述，但是 DetalleFactura 不能区分；
// 5 DesgloseNomal 是不是不限制税率？

// 6 DesgloseSimplificado 是不是限制税率只能是 21 10 4 ，并且默认21，如果有新的税率，或者税率变更怎么处理？

// 7 如何绑定对方信息

// 8 替换发票，如何绑定被替换的发票信息(一对多)

// 9 被替换的发票，状态需要修改吗？被替换的发票如何区分识别是否被替换？

// 10 简易发票限额多少？

// 11 标准发票有限额吗？

// 12 客户授权书，怎么处理？什么方式？

// 13 软件声明，怎么处理？

// 14 IRPF 部分数据怎么处理？

// 15 开发者信息，如何传递？

// 16 请求传递的是 订单唯一编号，响应 的 serie和numero 是做什么的？还有就是 简易发票的编号 和 标准发票的编号是不是连续的，退货发票的编号 独立吗？发票编号是自己生成，还是采用请求返回的  serie和numero  ？

	
```





