# 《springBoot3 中使用webClient》

## 一 webClient 基础配置

### 1  maven配置

```xml
<!-- HTTP客户端 -->
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-webflux</artifactId>
</dependency>
```

### 2  application.yaml	配置连接信息 

```yaml
webClient:
  api:
    base-url: https://api.xxxx.es:5244/v1/ # api基础地址
    endpoints:  # 断点配置
      f1: /components/schemas/AltaFacturaRequest
      f2: /components/schemas/FacturaSimplificadaRequest
    headers:  # 请求头配置
      content-type: application/json; charset=utf-8
      accept: application/json
    connect-timeout: 2000    # 仅限建立连接的时间 的超时
    response-timeout: 3000   # 包含连接建立 + 数据传输 + 响应接收 的超时
    mono-timeout: 5000       # 包含前两者 + 业务逻辑处理时间 的超时
```

### 3 创建配置类

```java
@Data
@Configuration
@ConfigurationProperties(prefix = "webClient.api")
public class VerifacApiConfig {
    /** 基础路径 */
    private String baseUrl;

    /** 方法路径 */
    private Map<String, String> endpoints;

    /** 请求头 */
    private Map<String, String> headers;

    /** 仅限建立连接的时间 的超时 */
    private int connectTimeout;

    /** 包含连接建立 + 数据传输 + 响应接收 的超时*/
    private int responseTimeout;

    /** 包含前两者 + 业务逻辑处理时间 的超时 */
    private int monoTimeout;

}
```

### 4 创建WebClient工厂

```java

/**
 * 创建WebClient工厂
 * 1-创建WebClient
 * 2-根据发票类型获取对应的方法路径 endpoint
 */
@Component
@RequiredArgsConstructor
public class VerifacWebClientConfig {

    private final VerifacApiConfig apiConfig;


    /**
     * 创建WebClient
     * @return
     */
    public WebClient createClient(){
        return WebClient.builder()
            .baseUrl(apiConfig.getBaseUrl())
            .defaultHeaders(headers -> apiConfig.getHeaders().forEach(headers::add))
            .clientConnector(new ReactorClientHttpConnector(
                HttpClient.create()
                        // API 建立连接的时间 超时设置
                        .option(ChannelOption.CONNECT_TIMEOUT_MILLIS, apiConfig.getConnectTimeout())
                        // API 连接建立 + 数据传输 + 响应接收 超时设置
                        .responseTimeout(Duration.ofMillis(apiConfig.getResponseTimeout()))

            ))
            .build();
    }

    /**
     * 根据发票类型获取对应的方法路径 endpoint
     * @param invoiceType
     * @return
     */
    public String getEndpointForInvoiceType(String invoiceType){
        return apiConfig.getEndpoints().getOrDefault(
            invoiceType.toLowerCase(),
            apiConfig.getEndpoints().get("f2") // 默认简化发票
        );
    }


}

```

### 5 封装webClient

```jade

/**
 * 验证接口客户端
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class VerifacApiClient {

    private final TaxInvoiceHandlerFactory handlerFactory;
    private final VerifacWebClientConfig webClientConfig;
    private final VerifacApiConfig apiConfig;
    private final RabbitTemplate rabbitTemplate;

    /**
     * 上传发票（Reactive 风格）
     * @param invoice 发票数据
     * @return Mono 包装的返回结果
     */
    public Mono<TaxUploadResult> uploadInvoiceReactive(VerifacInvoice invoice) {
        TaxInvoiceHandler handler = handlerFactory.getHandler(invoice.getInvoiceTipo());
        //String endpoint = webClientConfig.getEndpointForInvoiceType(invoice.getInvoiceTipo());

        return webClientConfig.createClient()
                .post() // 发送请求
                .uri(endpoint)  // 设置请求地址
                .bodyValue(handler.buildRequest(invoice))   // 设置请求体
                .retrieve() // 发送请求并获取响应
                .onStatus(HttpStatusCode::isError, response ->
                        // 如果 HTTP 状态码是错误码（4xx/5xx）
                        response.bodyToMono(ApiErrorResponse.class)
                                // TODO: 包装成自定义异常 还要处理 html类型的异常
                                .flatMap(errorBody -> Mono.error(new InvoiceApiException(errorBody.getMensaje(), errorBody.getCodigo())))
                )
                // 将 HTTP 响应的 body 反序列化为 TaxInvoiceResponse 类型（由 handler 决定
                .bodyToMono(handler.getResponseType())
                // 连接建立 + 数据传输 + 响应接收 + 业务逻辑处理时间 的超时设置
                .timeout(Duration.ofMillis(apiConfig.getMonoTimeout()))
                .flatMap(response -> {
                    // 发送到MQ处理
                    return sendToMqAsync(invoice, response)
                            .map(success -> new TaxUploadResult(
                                    invoice,
                                    true,
                                    response.getFactura().getQr()
                            ));
                })
                .onErrorResume(e -> handleError(e, invoice));
    }


    /**
     * 异步发送到MQ（示例方法）
     */
    private Mono<Boolean> sendToMqAsync(VerifacInvoice invoice, TaxInvoiceResponse response) {
        return Mono.fromCallable(() -> {
            long start = System.currentTimeMillis();
            log.info("异步处理 发送发票到MQ, 发票信息 : {}",response);
            // 1 关键：注入响应数据
            TaxInvoiceHandler handler = handlerFactory.getHandler(invoice.getInvoiceTipo());
            handler.handleResponse(response, invoice);
            // 2. 发送到MQ（携带完整领域对象）
            rabbitTemplate.convertAndSend(
                    OrderDirectMQConfig.ORDER_EXCHANGE,
                    OrderDirectMQConfig.INVOICE_ROUTER_KEY,
                    invoice,
                    message -> {
                        // 消息持久化
                        message.getMessageProperties().setDeliveryMode(MessageDeliveryMode.PERSISTENT);
                        return message;
                    }
            );
            log.info("已发送MQ异步处理,处理耗时: {}ms", System.currentTimeMillis() - start);
            // 返回发送结果
            return true;
        }).subscribeOn(Schedulers.boundedElastic());
    }

    /**
     * 统一错误处理
     */
    private Mono<TaxUploadResult> handleError(Throwable e, VerifacInvoice invoice) {
        String errorMsg;
        if (e instanceof InvoiceApiException) {
            errorMsg = e.getMessage();
            log.error(errorMsg);
        } else if (e instanceof IllegalArgumentException) {
            errorMsg = "税务接口参数错误: " + e.getMessage();
            log.error(errorMsg);
        } else if (e instanceof IllegalStateException) {
            errorMsg = "税务接口状态错误: " + e.getMessage();
            log.error(errorMsg);
        } else if (e instanceof NullPointerException) {
            errorMsg = "税务接口返回结果为空";
        } else if (e instanceof ConnectTimeoutException) {
            errorMsg = "税务接口网络或服务器问题导致连接超时";
            log.error(errorMsg);
        } else if (e instanceof ReadTimeoutException) {
            errorMsg = "税务接口网络或服务器问题导致响应超时";
            log.error(errorMsg);
        } else if (e instanceof TimeoutException) {
            errorMsg = "税务接口网络或服务器问题导致处理超时";
            log.error(errorMsg);
        } else {
            errorMsg = "税务响应非规定的JSON结果异常！: " + e.getMessage();
            log.error(errorMsg, e);
        }

        return Mono.just(new TaxUploadResult(
                invoice,
                false,
                errorMsg
        ));
    }

    @Data
    @AllArgsConstructor
    public static class TaxUploadResult {
        private VerifacInvoice invoice;
        private boolean success;
        private String errorMessage;

    }


}
```



## 二 请求/响应 处理工厂

### 1 发票处理器工厂

```java
/**
 * 发票处理器工厂
 */
@Component
@RequiredArgsConstructor
public class TaxInvoiceHandlerFactory {

    private final List<TaxInvoiceHandler> handlers;

    /**
     * 根据发票类型获取发票处理器
     * @param invoiceType
     * @return
     */
    public TaxInvoiceHandler getHandler(String invoiceType) {
        return handlers.stream()
                .filter(handler -> handler.getSupportedType().equalsIgnoreCase(invoiceType))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException(
                        String.format("No tax invoice handler found for invoice type %s", invoiceType)
                ));
    }
}
```

### 2 定义处理器接口

```java
/**
 * 发票处理器
 */
public interface TaxInvoiceHandler {

    /**
     * 返回处理器支持的发票类型
     */
    public String getSupportedType();

    /**
     * 构建API请求对象
     */
    public TaxInvoiceRequest buildRequest(VerifacInvoice invoice);

    /**
     * 处理API响应
     */
    public void handleResponse(TaxInvoiceResponse response, VerifacInvoice invoice);

    /**
     * 返回响应体的Java类型
     */
    public Class<? extends TaxInvoiceResponse> getResponseType();
}
```

### 3 接口实现A

```java

/**
 * 完整发票处理器
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class AltaFacturaHandler implements TaxInvoiceHandler {

    private final ITenantService tenantService;


    /**
     * 支持发票类型 F2
     * @return
     */
    @Override
    public String getSupportedType() {
        return FacturaConstants.FACTURA_TIPO_COMPLETA;
    }

    /**
     * 构建请求
     * @param invoice
     * @return
     */
    @Override
    public TaxInvoiceRequest buildRequest(VerifacInvoice invoice) {
        // 构建简易发票发票信息
        AltaFacturaRequest request = new AltaFacturaRequest();

        // 1 发行方信息
        Tenant tenant = tenantService.selectTenantByTenantId(invoice.getTenantId());
        Emisor emisor = new Emisor();
        emisor.setNif(tenant.getInvoiceTaxNumber());
        emisor.setCodigo(tenant.getApiKey());
        request.setEmisor(emisor);
        // 2 操作类型
        request.setOperacion(invoice.getInvoiceOperacion());
        // 3 交易唯一标识
        request.setIdTransaccion(invoice.getOrderNo());
        // 4 明细
        List<DesgloseNormal> desgloses = invoice.getVerifacInvoiceDetailList().stream()
            .map(invoiceDetail -> {
                DesgloseNormal desglose = new DesgloseNormal();
                desglose.setRegimen(invoiceDetail.getDetailRegimen());
                desglose.setCalificacion(invoiceDetail.getDetailCalificacion());
                desglose.setBase(invoiceDetail.getDetailBase());
                desglose.setTipoIva(invoiceDetail.getDetailTipoIva());
                desglose.setCuotaIva(invoiceDetail.getDetailCuotaIva());
                desglose.setTipoRe(invoiceDetail.getDetailTipoRe());
                desglose.setCuotaRe(invoiceDetail.getDetailCuotaRe());

                return desglose;
            }).toList();
        request.setDesglose(desgloses);

        return request;

    }

    /**
     * API响应 发送给MQ
     * @param response
     * @param invoice
     */
    @Override
    public void handleResponse(TaxInvoiceResponse response, VerifacInvoice invoice) {
        if (response instanceof AltaFacturaResponse altaFacturaResponse) {
            // 1 发行方信息
            invoice.setEmisorNombre(altaFacturaResponse.getEmisor().getNombre());
            // 2 基础信息
            invoice.setInvoiceOperacion(altaFacturaResponse.getOperacion());
            // 3 发票明细
            invoice.setInvoiceIdFactura(altaFacturaResponse.getFactura().getIdFactura());
            invoice.setInvoiceTipo(altaFacturaResponse.getFactura().getTipo());
            invoice.setInvoiceSerie(altaFacturaResponse.getFactura().getSerie());
            invoice.setInvoiceNumero(altaFacturaResponse.getFactura().getNumero());
            invoice.setInvoiceFecha(altaFacturaResponse.getFactura().getFecha());
            invoice.setInvoiceHora(altaFacturaResponse.getFactura().getHora());
            invoice.setInvoiceImporteImpuestos(altaFacturaResponse.getFactura().getImporteImpuestos());
            invoice.setInvoiceImporteTotal(altaFacturaResponse.getFactura().getImporteTotal());
            invoice.setInvoiceDescripcion(altaFacturaResponse.getFactura().getDescripcion());
            invoice.setInvoiceEstado(altaFacturaResponse.getFactura().getEstado());
            invoice.setInvoiceQr(altaFacturaResponse.getFactura().getQr());
            invoice.setInvoiceMillisegundos(altaFacturaResponse.getFactura().getMillisegundos());
            // 4 AltaFacturaResponse 没有明细 desglose

            // 5. 校验数据合法性（示例）
            if (altaFacturaResponse.getFactura().getQr() == null) {
                invoice.setInvoiceStatus(FacturaConstants.INVOICE_STATUS_RESPONSE_EXCEPTION);
                invoice.setApiResponse("API返回的QR码为空");
            }
        }


    }

    /**
     * 响应类型
     * @return
     */
    @Override
    public Class<? extends TaxInvoiceResponse> getResponseType() {
        return AltaFacturaResponse.class;
    }
}

```

### 4 接口实现B

```java

/**
 * 简易发票处理器
 */
@Component
@Slf4j
@RequiredArgsConstructor
public class FacturaSimplificadaHandler implements TaxInvoiceHandler {

    private final ITenantService tenantService;


    /**
     * 支持发票类型 F2
     * @return
     */
    @Override
    public String getSupportedType() {
        return FacturaConstants.FACTURA_TIPO_SIMPLIFICADA;
    }

    /**
     * 构建请求
     * @param invoice
     * @return
     */
    @Override
    public TaxInvoiceRequest buildRequest(VerifacInvoice invoice) {
        // 构建简易发票发票信息
        FacturaSimplificadaRequest request = new FacturaSimplificadaRequest();

        // 1 发行方信息
        Tenant tenant = tenantService.selectTenantByTenantId(invoice.getTenantId());
        Emisor emisor = new Emisor();
        emisor.setNif(tenant.getInvoiceTaxNumber());
        emisor.setCodigo(tenant.getApiKey());
        request.setEmisor(emisor);
        System.out.println("###########################  发行者信息");
        System.out.println("tenant：" + tenant);
        System.out.println("发行者：" + emisor);
        System.out.println("###########################  发行者信息");
        // 2 操作类型
        request.setOperacion(invoice.getInvoiceOperacion());
        // 3 交易唯一标识
        request.setIdTransaccion(invoice.getOrderNo());
        // 4 发票信息

        // 5 明细信息
        List<DesgloseSimplificado> desgloses = invoice.getVerifacInvoiceDetailList().stream()
            .map(detail -> {
                DesgloseSimplificado desglose = new DesgloseSimplificado();
                desglose.setTipoIva(detail.getDetailTipoIva());
                desglose.setTotal(detail.getDetailSumaTotal());

                return desglose;
            }).toList();
        request.setDesglose(desgloses);


        System.out.println("###########################  请求信息");
        System.out.println(request);
        System.out.println("###########################  请求信息");

        return request;

    }

    /**
     * API响应 发送给MQ
     * @param response
     * @param invoice
     */
    @Override
    public void handleResponse(TaxInvoiceResponse response, VerifacInvoice invoice) {
        if (response instanceof FacturaSimplificadaResponse simplificadaResponse) {
            // 1 发行方信息
            invoice.setEmisorNombre(simplificadaResponse.getEmisor().getNombre());
            // 2 基础信息
            invoice.setInvoiceOperacion(simplificadaResponse.getOperacion());
            // 3 发票明细
            invoice.setInvoiceIdFactura(simplificadaResponse.getFactura().getIdFactura());
            invoice.setInvoiceTipo(simplificadaResponse.getFactura().getTipo());
            invoice.setInvoiceSerie(simplificadaResponse.getFactura().getSerie());
            invoice.setInvoiceNumero(simplificadaResponse.getFactura().getNumero());
            invoice.setInvoiceFecha(simplificadaResponse.getFactura().getFecha());
            invoice.setInvoiceHora(simplificadaResponse.getFactura().getHora());
            invoice.setInvoiceImporteImpuestos(simplificadaResponse.getFactura().getImporteImpuestos());
            invoice.setInvoiceImporteTotal(simplificadaResponse.getFactura().getImporteTotal());
            invoice.setInvoiceDescripcion(simplificadaResponse.getFactura().getDescripcion());
            invoice.setInvoiceEstado(simplificadaResponse.getFactura().getEstado());
            invoice.setInvoiceQr(simplificadaResponse.getFactura().getQr());
            invoice.setInvoiceMillisegundos(simplificadaResponse.getFactura().getMillisegundos());
            // 4 发票明细
            simplificadaResponse.getDesglose().forEach(desglose -> {
                invoice.getVerifacInvoiceDetailList().add(
                    VerifacInvoiceDetail.builder()
                        .detailBase(desglose.getBase())
                        .detailTipoIva(desglose.getTipoIva())
                        .detailCuotaIva(desglose.getCuotaIva())
                        .build());
            });

            // 2. 校验数据合法性（示例）
            if (simplificadaResponse.getFactura().getQr() == null) {
                invoice.setInvoiceStatus(FacturaConstants.INVOICE_STATUS_RESPONSE_EXCEPTION);
                invoice.setApiResponse("API返回的QR码为空");
            }
        }
    }

    /**
     * 响应类型
     * @return
     */
    @Override
    public Class<? extends TaxInvoiceResponse> getResponseType() {
        return FacturaSimplificadaResponse.class;
    }
}

```

## 三  业务使用

```java

@Slf4j
@Service
@RequiredArgsConstructor
public class VerifacApiServiceImpl implements IVerifacApiService {

    private final VerifacApiClient verifacApiClient;

    /**
     * 发票上传
     * @param invoice
     * @return
     */
    @Override
    public VerifacApiClient.TaxUploadResult uploadInvoiceBySalessOrder(VerifacInvoice invoice) {
        try {
            // 调用API
            VerifacApiClient.TaxUploadResult apiResult = verifacApiClient.uploadInvoiceReactive(invoice)
                    .block(Duration.ofSeconds(5));
            // 异常响应结果为空处理
            if (apiResult == null) {
                apiResult = new VerifacApiClient.TaxUploadResult(invoice, false, "API税务接口无响应！");
            }
            if (apiResult.isSuccess() && apiResult.getInvoice() == null){
                apiResult.setSuccess(false);
                apiResult.setErrorMessage("API税务接口没有返回响应数据！");
                log.error("API税务接口返回数据异常！异常原因：{}", apiResult.getErrorMessage());
            }
            // 返回结果
            return apiResult;

        } catch (Exception e) {
            // 处理异常
            log.error("API税务接口请求异常！异常原因：{}", e.getMessage());
            return new VerifacApiClient.TaxUploadResult(invoice, false, "API税务接口请求异常！");
        }
    }

    /**
     * 死信队列中的发票信息重新发送API重新入列处理
     * @param invoice
     * @return
     */
    @Override
    public VerifacApiClient.TaxUploadResult uploadInvoiceByDeadLetterInvoiceResend(VerifacInvoice invoice) {
        try {
            // 调用API
            VerifacApiClient.TaxUploadResult apiResult = verifacApiClient.uploadInvoiceReactive(invoice)
                    .block(Duration.ofSeconds(5));
            // 异常响应结果为空处理
            if (apiResult == null) {
                apiResult = new VerifacApiClient.TaxUploadResult(invoice, false, "API税务接口无响应！");
            }
            if (apiResult.isSuccess() && apiResult.getInvoice() == null){
                apiResult.setSuccess(false);
                apiResult.setErrorMessage("API税务接口没有返回响应数据！");
                log.error("API税务接口返回数据异常！异常原因：{}", apiResult.getErrorMessage());
            }
            // 返回结果
            return apiResult;

        } catch (Exception e) {
            // 处理异常
            log.error("API税务接口请求异常！异常原因：{}", e.getMessage());
            return new VerifacApiClient.TaxUploadResult(invoice, false, "API税务接口请求异常！");
        }
    }
}


```

