# 《springBoot3使用工厂模式处理业务》

## 一 业务背景：

```java
// 订单根据不同的操作类型，处理订单数据 OperateType = Integer
1-拣货	PICK
2-复核	CHECK
3-打包	PACK
4-确认	CONFIRM
5-生成发票	GENERATE_INVOICE
```

## 二 定义操作策略接口

```java
/**
 * 订单操作策略
 */
public interface OrderOperationStrategy {
    /**
     * 返回该策略支持的操作类型（如拣货=2）
     */
    Integer getOperateType();

    /**
     * 执行操作
     */
    SalesOrderVo execute(SalesOrderVo salesOrderVo);
}
```

## 三 构建操作策略工厂

```java
/**
 * 订单操作策略工厂
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class OrderOperationStrategyFactory {

    private final Map<Integer, OrderOperationStrategy> strategyMap;

    /**
     * 通过构造器自动注入所有策略
     */
    @Autowired
    public OrderOperationStrategyFactory(List<OrderOperationStrategy> strategies) {
        // 打印注册日志（调试用）
        strategies.forEach(strategy ->
            log.info("注册策略: 类型={}, 实现类={}",
                strategy.getOperateType(),
                strategy.getClass().getSimpleName())
        );

        // 转换为Map: Key=操作类型, Value=策略实例
        this.strategyMap = strategies.stream()
            .collect(Collectors.toMap(
                OrderOperationStrategy::getOperateType,
                Function.identity(),
                (existing, replacement) -> {
                    log.warn("重复策略类型: {}, 使用{}替代{}",
                            existing.getOperateType(),
                            existing.getClass().getSimpleName(),
                            replacement.getClass().getSimpleName());
                    return existing;
                }
            ));
    }


    /**
     * 根据操作类型获取策略
     */
    public OrderOperationStrategy getStrategy(Integer operateType) {
        return strategyMap.get(operateType);
    }
}

```

## 四 业务操作类型 - 实现策略接口

```java
/**
 * 举例 - 打包操作
 */
@Service
@Slf4j
@RequiredArgsConstructor
public class PackOperationStrategy implements OrderOperationStrategy{

    private final SalesOrderMapper salesOrderMapper;

    @Override
    public Integer getOperateType() {
        return SalesOrderConstants.ORDER_OPERATE_TYPE_PACK;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public SalesOrderVo execute(SalesOrderVo salesOrderVo) {
        // 打包处理
        salesOrderVo.setOrderStatus(SalesOrderConstants.ORDER_STATUS_PACK);
        if (salesOrderVo.getOrderDirection().equals(SalesOrderConstants.ORDER_DIRECTION_SALES)){
            // 销售订单打包
            System.out.println("-------------- 业务处理 销售订单打包成功");

        } else if (salesOrderVo.getOrderDirection().equals(SalesOrderConstants.ORDER_DIRECTION_RETURN)){
            // 退货订单打包
            throw new ServiceException("暂不支持的退货打包环节！");

        } else {
            throw new ServiceException("未知的订单方向！");
        }
        int res =  salesOrderMapper.updateSalesOrder(salesOrderVo);
        if (res > 0){
            return salesOrderVo;
        } else {
            throw new ServiceException("打包业务处理失败！");
        }
    }
}
```

## 五 业务中调用

```java
private final OrderOperationStrategyFactory orderOperationStrategyFactory;

/**
* 其他操作处理 (初始化、拣货、复核、打包、确认、生成发票、作废)
* @param salesOrderVo
* @return
*/
@Override
public SalesOrderVo updateByOtherOperate(SalesOrderVo salesOrderVo) {
  // 1. 参数校验
  validateOperation(salesOrderVo);
  // 2. 获取策略并执行
  return Optional.ofNullable(orderOperationStrategyFactory.getStrategy(salesOrderVo.getOperateType()))
    .orElseThrow(() -> new ServiceException("未知操作类型"))
    .execute(salesOrderVo);
}
```











