# springBoot3项目实战参数校验

## 一 参数验证的常用注解

### 1 字符串 - 常用验证

```bash
-- 1.1 @NotNull	字段值不能为 null
-- 1.2 @NotEmpty	字段值不能为 null 或空（适用于字符串、集合、数组等）
-- 1.3 @NotBlank	字段值不能为 null，且必须包含至少一个非空白字符（适用于字符串）
-- 1.4 @Size
-- 1.5 @Pattern(regexp)	字段值必须匹配指定的正则表达式
```

### 2 数值 - 常用验证

```bash
-- 2.1 @Max	字段值必须小于或等于指定的最大值;
-- 2.2 @Min	字段值必须大于或等于指定的最小值;
-- 2.3 @Digits(integer, fraction)	字段值必须是数字，且整数部分和小数部分的位数不能超过指定值。
-- 2.4 @Positive	字段值必须为正数（大于 0）;
-- 2.5 @Negative	字段值必须为负数（小于 0）;
```

### 3 邮箱 路由 验证

```bash
-- 3.1 @Email
-- 3.2 @URL	字段值必须是有效的 URL。
```

### 4 时间验证 - 常用验证

```bash
-- 4.1 @Past	字段值必须是过去的日期或时间;
-- 4.2 @PastOrPresent	字段值必须是过去或当前的日期或时间。
-- 4.3 @Future	字段值必须是未来的日期或时间。
-- 4.4 @FutureOrPresent	字段值必须是未来或当前的日期或时间。
```

### 5 递归嵌套验证

```bash
-- 5.1 @Valid	用于嵌套验证，表示需要递归验证该字段的对象
```

## 二 项目实战

### 1 类中添加验证注解

```java
/**
 * 商品对象 erp_product
 * 
 * @author hubiao
 * @date 2024-10-16
 */
@EqualsAndHashCode(callSuper = true)
@Data
public class Product extends BaseEntity{
  	/** 商品条码 */
    @NotNull
    @Size( max = 30, message = "商品条码最大长度30个字符")
    @Pattern(regexp = "^[^+-].*", message = "商品条码不能以 + 或 - 开头")  // 区分临时商品
    @Excel(name = "商品条码")
    private String productCode;

		/** 商品单价 */
    @Excel(name = "商品单价")
    @NotNull
    @Min(value = 0, message = "商品单价不能小于0")
    private BigDecimal productPrice;

		... ...

		/** sku信息 通过 "@Valid" 验证ProductSku中的参数注解*/
    @Valid
    private List<ProductSku> productSkuList;
		
}
```

### 2 controller 接收参数 启用参数验证

```java
/**
 * 商品Controller
 * 
 * @author hubiao
 * @date 2024-10-16
 */
@RestController
@RequestMapping("/product/product")
public class ProductController extends BaseController{

  /**
   * 删除商品  1 使用注解 "@NotEmpty" 作用： 列表非空检验
   */
  @PreAuthorize("@ss.hasPermi('product:product:remove')")
  @Log(title = "商品", businessType = BusinessType.DELETE)
	@DeleteMapping("/{productIds}")
    public AjaxResult remove(@NotEmpty(message = "请选择要删除的数据!") @PathVariable List<Long> productIds)
    {
        return toAjax(productService.deleteProductByProductIds(productIds));
    }


		/**
     * 新增商品 2 使用注解"@Valid" 作用：检验 Product 中的注解
     */
    @PreAuthorize("@ss.hasPermi('product:product:add')")
    @Log(title = "商品", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Valid @RequestBody Product product)
    {
        return toAjax(productService.insertProduct(product));
    }
  
}
```

