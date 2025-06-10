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
//1. Al enviar una solicitud POST, ¿qué método de autenticación utiliza la API?
1.- La autenticación se hace para cada petición en el bloque emisor, que está compuesto de nif y codigo.
El nif es el NIF, CIF o NIE del emisor.
El codigo es un código alfanumérico que asigno a cada emisor.
Para pruebas puedes utilizar los del ejemplo:
nif: B12345678
codigo: CODIGO123456

//2. En el campo "emisor", ¿qué es el "código"? ¿Lo proporciona ustedes o debemos generar un código único nosotros mismos?
2.- Queda contestada con la anterior respuesta.

//3. El campo "id_transaccion", ¿es el número de secuencia del pedido? ¿Debe ser consecutivo?
3.- El campo id_transaccion es un código único alfanumérico para cada factura.
Puede ser el pedido, la fecha-hora-minuto-segundo-milisegundo, o cualquier otro campo único.
Es muy importante que no se repitan nunca ni cuando cambia el año.
Sirve por si hay un corte en le proceso.
El emisor no sabe si la factura se ha grabado o no.
Si vuelve a enviar con el mismo id_transaccion si ya se había grabado, devolverá los datos de la factura grabada.
Si no se había grabado, se grabará la factura y se devolverán los datos.

//4. ¿Qué valores incluyen los enumerados para "tipo" y "operación"?
4.- En el bloque "factura" hay un campo "tipo".
Especifica el tipo de factura según el criterio de Hacienda:
F1 - Factura completa
F2 - factura simplificada
F3 - Factura completa sustitutiva de facturas simplificadas
R1 - Factura rectificativa por error
R2 - Factura rectificativa por concurso de acreedores
R3 - Factura rectificativa por incobrable
R4 - Factura rectificativa por otras causas
R5 - Factura rectificativa de factura simplificada
Hay otro campo "tipo" en desglose. No es obligatorio. Debe ser:
01 para operaciones normales con IVA
02 para exportación (venta a Canarias, Ceuta, Melilla o extranjero
03 para operaciones de régimen especial de bienes usados
04 para operaciones de oro de inversión
05 para agencias de viajes
...
11 para alquiler de locales de negocio
18 para operaciones a destinatario en régimen de Recargo de Equivalencia

Salvo casos de negocios especiales, la API entenderá que el 01, salvo si lleva RE que será el 18 o con destinatario extranjero o de Canarias, Ceuta o Melilla, que será 02.

El campo "operacion" de dentro del desglose tampoco es obligatorio.
Será, de forma automática "S1" (factura sujeta a IVA y no exenta de IVA y sin inversión del sujeto pasivo)

//5. ¿Para qué sirve el campo "id_factura"? ¿Es el ID que ustedes asignan al almacenar la factura?
5.- El campo id_factura que se devuelve es un número único que identifica a la factura en la API (independientemente del tipo o del emisor de la factura)

//6. Los campos "serie" y "numero", ¿solo pueden usar los valores proporcionados por ustedes? ¿O podemos personalizarlos con el formato de codificación que el cliente ya utiliza?
6.- Los campos "serie" y "numero" no son obligatorios.
Al crear un emisor se configura con un tipo de factura por defecto (F1 o F2) y con una serie para cada tipo de factura:
Una serie para la F1, una serie para F2, otra serie para F3, ....
Si no se envía el tipo de factura ni su serie, se adjudica de forma automática de ese valor por defecto.
Si llega "serie" se pone esa serie a la factura (que puede ser una serie de las asignadas por defecto o no)
Si no se pone factura, se adjudicará el siguiente número de la serie.
Así se puede ccrear una factura de serie nueva y que empiece por el número que se desee.
Se comprueba el número de factura y si no es el número siguiente a la última de esa serie, se devuelve error.

//7. ¿Qué valores posibles tiene el enumerado "estado"?
7.- El estado actual puede ser "Grabada" o "Anulada"
Es posible que más adelante se creen nuevos estados.

//8. ¿La interfaz de prueba ya está disponible para su uso?
8.- Sí se puede utilizar con los datos de los ejemplos.
Aunque como puede haber varios visitantes es posible que creen facturas también y el número de factura no sea el esperado.


	
```

### 20250528

```java
// 1 同一个NIF如果有多个门店如何区分？

// 2 发票的客户信息、公司信息，当前只传递了NIF和Nombre, 相对于手机号、地址等信息，发票信息需要保存吗？还是说这些信息无关紧要，可以直接通过绑定的客户ID实时获取当前的客户最新的辅助信息？

// 3 由于发票的 客户信息、个体户5.2附加税 信息错误，导致需要修改发票 ，是修改原发票，还是生成新的更正发票？

// 4 上传更正发票 对应的原始发票绑定关系 如何传递？原始发票的状态如何修改？

// 5 由于客户没有付款，导致需要作废发票，如何实现？

// 6 完整发票 替换 多张简易发票，如何传递绑定的多张原始发票信息？

// 7 退货发票 是不是和销售发票法力方式一样， 使用相同的发票类型、一样的serie，只不过数量、金额为负数？

// 8 客户当前发票号 F2025-00025 ，如果客户中途使用我们的发票系统，是不是可以直接使用系统默认返回的发票号 S-1，还是说需要与之前的发票号连续？

// 9.desglose 中的字段："regimen" 和 "calificacion" 有什么用？比如 海岛、欧盟 免税？5.2%个体户附加税？

// 10 个体户5.2% 只针对21%类型的IVA吗？ 其他类型的税率 对应是多少？

// 11.desglose 中 除了 "tipoIva" "tipoRe" 是不是就没有其他的 税率类型了？

```

### 20250603

```java
// 1 verifac 适用于所有西班牙用户吗？比如 西班牙本土、加那利群岛、Ceuta&Melilla、其他地区？

// 2 是不是 非默认 "regimen"="01"和"calificacion"="S1" 的组合，其他组合都需要传递"regimen"和"calificacion"？

// 3 regimen 和 calificacion 的不同组合，是 根据卖家和卖家的区域决定的吗？

```



# 7 资料整理

### 	1 接收方信息

```java
// 1 证件类型
	nif	西班牙的 NIF、NIE 或 CIF。无空格、连字符或特殊字符。
		-- 01 西班牙本地
	documento_extranjero	国外证件号码。
	tipo_documento_extranjero	"02": 增值税号, "03": 护照, "04": 官方证件, "05": 居住证明, "06
		-- 02 欧盟增值税号
		-- 03 护照
		-- 04 居住国官方文件
		-- 05 居住证明
		-- 06 其他文件
```



### 	2 发票类型

```java
// 1 普通发票

// 2 简化发票
	-- 限额 3000 欧元
```



### 	3 税务制度



### 	4 业务类型



### 	5 区域之间的组合



### 	6 关联原发票

```java
// 1 更正发票
"rectificadas": [
    {
        "serie": "C",
        "numero": 345,
        "fecha": "12-06-2022"
    },
    {
        "serie": "C",
        "numero": 221,
        "fecha": "08-06-2022"
    },
    {
        "serie": "C",
        "numero": 125,
        "fecha": "12-05-2022"
    }
]

// 2 替换发票
"sustituidas": [
    {
        "serie": "S",
        "numero": 128,
        "fecha": "12-06-2022"
    },
    {
        "serie": "S",
        "numero": 195,
        "fecha": "13-06-2022"
    },
    {
        "serie": "S",
        "numero": 204,
        "fecha": "15-06-2022"
    }
]
```

