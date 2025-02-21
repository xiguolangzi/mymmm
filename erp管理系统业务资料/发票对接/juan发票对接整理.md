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

```

### 1.4 差额修正发票（用于退货或价格变动的情况）

```bash
# Factura rectificativa por diferencias (para los casos de devoluciones o cambios de precios)
-- 发票格式：

-- 发票规则
	1. 发票上，需要注明所修正的发票（序列号、编号和日期）

```

### 1.5 替换修正发票（用于需要完全用新发票替换原发票的情况）

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

### 1.7 ~~负数发票~~

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





