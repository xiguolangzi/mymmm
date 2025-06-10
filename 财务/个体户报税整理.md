# vue3 表格下拉展示，控制同时只展示单条数据

## 1 技术背景：

```
vue3 + element-plus
```

## 2 组件中使用

```vue
<template>
  <el-table class="table-container" v-loading="loading" :data="customerList" size="small"
            @selection-change="handleSelectionChange" resizable  ref="customerTable" 
            @expand-change="handleExpandChange" row-key="customerId">
    <el-table-column type="expand">
      <template #default="props">
        <div style="padding: 10px 50px;">
          <el-descriptions title=">>> 发票信息: " :column="5" size="small">
            <el-descriptions-item label="纳税人税号:">{{ props.row.invoiceNif }}</el-descriptions-item>
            <el-descriptions-item label="纳税人名称:">{{ props.row.invoiceNombre }}</el-descriptions-item>
            <el-descriptions-item label="纳税人电话:">{{ props.row.invoicePhone }}</el-descriptions-item>
            <el-descriptions-item label="纳税人邮编:">{{ props.row.invoicePostcode }}</el-descriptions-item>
            <el-descriptions-item label="纳税人地址:">{{ props.row.invoiceAddress }}</el-descriptions-item>
          </el-descriptions>
          <el-descriptions title=">>> 联系人信息: " :column="5" size="small">
            <el-descriptions-item label="联系人名称:">{{ props.row.contactName }}</el-descriptions-item>
            <el-descriptions-item label="联系人电话:">{{ props.row.contactPhone }}</el-descriptions-item>
            <el-descriptions-item label="联系人邮箱:">{{ props.row.contactEmail }}</el-descriptions-item>
            <el-descriptions-item label="联系人地址:" :span="2">{{ props.row.contactAddress }}</el-descriptions-item>
          </el-descriptions>
          <el-descriptions title=">>> 更新信息: " :column="5" size="small">
            <el-descriptions-item label="创建人:">{{ props.row.createBy }}</el-descriptions-item>
            <el-descriptions-item label="创建时间:">{{ parseTime(props.row.createTime, '{y}-{m}-{d}')
              }}</el-descriptions-item>
            <el-descriptions-item label="修改人:">{{ props.row.updateBy }}</el-descriptions-item>
            <el-descriptions-item label="修改时间:">{{ parseTime(props.row.updateTime, '{y}-{m}-{d}')
              }}</el-descriptions-item>
            <el-descriptions-item label="备注:">{{ props.row.remark }}</el-descriptions-item>
          </el-descriptions>
        </div>
      </template>
    </el-table-column>
    <el-table-column type="selection" width="55" align="center" />
    <el-table-column label="客户分类" align="center" prop="categoryVo.categoryName" min-width="120"
                     show-overflow-tooltip />
    <el-table-column label="客户编码" align="center" prop="customerCode" show-overflow-tooltip />
    <el-table-column label="客户名称" align="center" prop="customerName" show-overflow-tooltip />
    <el-table-column label="客户类型" align="center" prop="invoiceRegimen" show-overflow-tooltip>
      <template #default="scope">
  <dict-tag :options="invoice_regimen" :value="scope.row.invoiceRegimen" />
      </template>
    </el-table-column>
    <el-table-column label="交易类型" align="center" prop="invoiceCalificacion" show-overflow-tooltip>
      <template #default="scope">
  <dict-tag :options="invoice_calificacion" :value="scope.row.invoiceCalificacion" />
      </template>
    </el-table-column>
    <el-table-column label="客户等级" align="center" prop="leverId">
      <template #default="scope">
  <span>{{ scope.row.levelName?? '--' }}</span>
      </template>
    </el-table-column>
    <el-table-column label="客户状态" align="center" prop="customerStatus">
      <template #default="scope">
  <dict-tag :options="project_general_status" :value="scope.row.customerStatus" />
      </template>
    </el-table-column>
    <el-table-column label="绑定业务员" align="center" prop="salesmanName" show-overflow-tooltip>
      <template #default="scope">
  <span>{{ scope.row.salesmanName?? '--' }}</span>
      </template>
    </el-table-column>
    <el-table-column label="发掘客户者" align="center" prop="findByName" show-overflow-tooltip>
      <template #default="scope">
  <span>{{ scope.row.findByName?? '--' }}</span>
      </template>
    </el-table-column>
    <el-table-column label="操作" align="center" class-name="small-padding fixed-width">
      <template #default="scope">
  <el-button link type="primary" icon="Edit" @click="handleUpdate(scope.row)"
             v-hasPermi="['order:customer:edit']">修改</el-button>
  <el-button link type="danger" icon="Delete" @click="handleDelete(scope.row)"
             v-hasPermi="['order:customer:remove']">删除</el-button>
      </template>
    </el-table-column>
  </el-table>
</template>

<script setup name="Customer">
  // ---------------------- 3 el-table-expand - 客户列表展开 start --------------------------
  const customerTable = ref(null);
  const expandedRow = ref(null);
  /** 控制单行展示 */
  const handleExpandChange = (row) => {
    if (expandedRow.value && expandedRow.value !== row) {
      customerTable.value.toggleRowExpansion(expandedRow.value, false);
    }
    expandedRow.value = row;
  };
  // ----------------------- 7 el-table-expand - 客户列表展开  end --------------------------
</script>
```

