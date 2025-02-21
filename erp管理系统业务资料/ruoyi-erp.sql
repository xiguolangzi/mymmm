-- ----------------------------
-- 1、商品分类表 - dept
-- ----------------------------
drop table if exists sys_erp_product_category;
create table sys_erp_product_category (
  category_id       bigint(20)      not null auto_increment    comment '商品分类id',
  parent_id         bigint(20)      default 0                  comment '父类id',
  ancestors         varchar(50)     default ''                 comment '祖级列表',
  category_name     varchar(30)     default ''                 comment '商品分类名称',
  order_num         int(4)          default 0                  comment '显示顺序',
  status            char(1)         default '0'                comment '商品分类状态（0正常 1停用）',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time 	    datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  tenant_id         bigint(20)      default '1'                comment '租户id',
  primary key (category_id)
) engine=innodb auto_increment=200 comment = '商品分类表';

-- ----------------------------
-- 2、品牌管理表 - post
-- ----------------------------
drop table if exists sys_erp_brand;
create table sys_erp_brand
(
  brand_id      bigint(20)      not null auto_increment    comment '品牌ID',
  brand_code    varchar(64)     not null                   comment '品牌编码',
  brand_name    varchar(50)     not null                   comment '品牌名称',
  brand_sort    int(4)          default null               comment '显示顺序',
  status        char(1)         not null                   comment '品牌状态（0正常 1停用）',
  create_by     varchar(64)     default ''                 comment '创建者',
  create_time   datetime                                   comment '创建时间',
  update_by     varchar(64)     default ''			       comment '更新者',
  update_time   datetime                                   comment '更新时间',
  remark        varchar(500)    default null               comment '备注',
  tenant_id     bigint(20)      default '1'                comment '租户id',
  primary key (brand_id)
) engine=innodb comment = '品牌管理表';

-- ----------------------------
-- 3、单位表
-- ----------------------------
drop table if exists sys_erp_unit;
CREATE TABLE sys_erp_unit (
  uint_id 				bigint(20) 		not null auto_increment    comment '单位ID',
  unit_type				char(1)			not null 				   comment '单位类型(0基础单位，1转换单位)',
  unit_base				int				default '1'				   comment '单位数量',
  conversion_rate		DECIMAL(10, 4) 	default '1'				   comment '换算率(如1箱=24个)',
  tenant_id         	bigint(20)      default '1'                comment '租户id',
  create_by         	varchar(64)     default ''                 comment '创建者',
  create_time 	    	datetime                                   comment '创建时间',
  update_by         	varchar(64)     default ''                 comment '更新者',
  update_time       	datetime                                   comment '更新时间',
  primary key (uint_id)
) engine=innodb auto_increment=100 comment = '单位表';


-- ----------------------------
-- 4、商品表 - user
-- ----------------------------
drop table if exists erp_product;
create table erp_product (
  product_id        bigint(20)      not null auto_increment    comment '商品ID',
  category_id       bigint(20)      not null	               comment '商品分类ID',
  unit_id	        bigint(20)      not null	               comment '计量单位',
  brand_id       	bigint(20)      default null	           comment '商品品牌ID',
  product_name      varchar(30)     not null                   comment '商品名称',
  product_image     varchar(100)    default ''                 comment '商品主图',
  product_price     decimal(10,2)   default null               comment '商品价格',
  length			decimal(10,2)	default null			   comment '长(cm)',
  width				decimal(10,2)	default null			   comment '宽(cm)',
  height			decimal(10,2)	default null			   comment '高(cm)',
  volume			decimal(10,2)	default null			   comment '体积(m3)',
  weight			decimal(10,2)	default null			   comment '重量(kg)',
  cost_method		char(1)			default '0'				   comment '成本计算(0移动加权平均 1先进先出 2实际成本)',
  product_status	char(1)			default '0'				   comment '商品状态(0在售 1停售)',
  brand_sort     	int(4)          default null               comment '显示顺序',
  product_attr		varchar(500)	default null			   comment '商品销售属性',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time       datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  remark            varchar(500)    default null               comment '备注',
  tenant_id         bigint(20)      default '1'                comment '租户id',
  primary key (product_id)
) engine=innodb auto_increment=100 comment = '商品表';


-- ----------------------------
-- 5、商品sku表 
-- ----------------------------
drop table if exists erp_product_sku;
CREATE TABLE erp_product_sku (
  sku_id 			bigint(20) 		not null auto_increment    comment 'skuID',
  product_id 		bigint(20) 		not null 				   comment '商品ID',
  sku_code 			varchar(255) 	not null 				   comment 'suk编号',
  sku_value 		json 			not null 				   comment 'suk属性值，json表示',
  sku_image     	varchar(100)    default ''                 comment 'sku对应图片',
  sku_price1     	decimal(10,2)   not null               	   comment 'sku销售价格1',
  sku_price2     	decimal(10,2)   default null               comment 'sku销售价格2',
  sku_price3     	decimal(10,2)   default null               comment 'sku销售价格3',
  sku_stock     	int   			default '0'                comment 'sku库存',
  tenant_id         bigint(20)      default '1'                comment '租户id',
  create_by         varchar(64)     default ''                 comment '创建者',
  create_time 	    datetime                                   comment '创建时间',
  update_by         varchar(64)     default ''                 comment '更新者',
  update_time       datetime                                   comment '更新时间',
  primary key (sku_id)
) engine=innodb auto_increment=100 comment = 'sku表';

-- ----------------------------
-- 6、商品批次表 - 用于计算成本使用
-- ----------------------------
drop table if exists erp_product_batch;
CREATE TABLE erp_product_batch (
  batch_id 				bigint(20) 		not null auto_increment    comment '批次ID',
  sku_id				bigint(20)		not null 				   comment 'sukId',
  batch_code 			varchar(255)  	not null				   comment '批次编码',
  production_time   	datetime                                   comment '生产日期',
  expiration_time   	datetime                                   comment '过期日期',
  purchase_quantity		int				not null				   comment '采购数量',
  sales_quantity		int				default '0'				   comment '销售数量',
  rest_quantity			int				not null				   comment '剩余数量',
  tenant_id         	bigint(20)      default '1'                comment '租户id',
  create_by         	varchar(64)     default ''                 comment '创建者',
  create_time 	    	datetime                                   comment '创建时间',
  update_by         	varchar(64)     default ''                 comment '更新者',
  update_time       	datetime                                   comment '更新时间',
  primary key (batch_id)
) engine=innodb auto_increment=100 comment = '商品批次表';


-- ----------------------------
-- 7、仓库表
-- ----------------------------
drop table if exists sys_erp_warehouse;
CREATE TABLE sys_erp_warehouse (
  warehouse_id 			bigint(20) 		not null auto_increment    comment '仓库ID',
  warehouse_name		varchar(255)	not null 				   comment '仓库名称',
  warehouse_location 	varchar(255)  	default null			   comment '仓库位置',
  tenant_id         	bigint(20)      default '1'                comment '租户id',
  create_by         	varchar(64)     default ''                 comment '创建者',
  create_time 	    	datetime                                   comment '创建时间',
  update_by         	varchar(64)     default ''                 comment '更新者',
  update_time       	datetime                                   comment '更新时间',
  primary key (warehouse_id)
) engine=innodb auto_increment=100 comment = '仓库表';


-- ----------------------------
-- 7、商品库存表
-- ----------------------------
drop table if exists erp_product_inventory;
CREATE TABLE erp_product_inventory (
  inventory_id 			bigint(20) 		not null auto_increment    comment '库存记录ID',
  sku_id				bigint(20)	 	not null 				   comment 'sukId',
  batch_id 				bigint(20)  	not null				   comment '批次编码',
  qyantity   			int				not null				   comment '库存数量',
  warehouse_id   		bigint(20)  	not null                   comment '仓库ID',
  tenant_id         	bigint(20)      default '1'                comment '租户id',
  create_by         	varchar(64)     default ''                 comment '创建者',
  create_time 	    	datetime                                   comment '创建时间',
  update_by         	varchar(64)     default ''                 comment '更新者',
  update_time       	datetime                                   comment '更新时间',
  primary key (inventory_id)
) engine=innodb auto_increment=100 comment = '商品库存表';



