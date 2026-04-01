<template>
  <div class="admin-orders-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>订单管理</span>
          <div class="filter-actions">
            <el-input v-model="searchQuery" placeholder="搜索订单号" style="width: 200px; margin-right: 10px;" clearable />
            <el-select v-model="typeFilter" placeholder="全部类型" style="width: 120px; margin-right: 10px;">
              <el-option label="全部类型" value="" />
              <el-option label="拼车订单" value="carpool" />
              <el-option label="约团订单" value="group" />
            </el-select>
            <el-select v-model="statusFilter" placeholder="全部状态" style="width: 120px; margin-right: 10px;">
              <el-option label="全部状态" value="" />
              <el-option label="已支付" value="paid" />
              <el-option label="待支付" value="pending" />
              <el-option label="已完成" value="completed" />
              <el-option label="已取消/退款" value="cancelled" />
            </el-select>
            <el-button type="primary" @click="fetchData">查询</el-button>
          </div>
        </div>
      </template>

      <el-table :data="filteredData" style="width: 100%" v-loading="loading">   
        <el-table-column prop="orderNo" label="订单号" width="160" />
        <el-table-column prop="type" label="类型" width="90">
          <template #default="scope">
            <el-tag :type="scope.row.type === 'carpool' ? 'success' : 'warning'">
              {{ scope.row.type === 'carpool' ? '拼车' : '约团' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="title" label="行程/商品名称" show-overflow-tooltip />
        <el-table-column prop="payer" label="支付用户" width="110" />
        <el-table-column prop="amount" label="金额(元)" width="90" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag v-if="scope.row.status === 'paid'" type="success">已支付</el-tag>
            <el-tag v-else-if="scope.row.status === 'pending'" type="info">待支付</el-tag>
            <el-tag v-else-if="scope.row.status === 'completed'" type="primary">已完成</el-tag>
            <el-tag v-else type="danger">已取消</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="170" />
        <el-table-column label="操作" fixed="right" width="140">
          <template #default="scope">
            <el-button link type="primary" size="small">详情</el-button>     
            <el-button 
              v-if="scope.row.status === 'paid'" 
              link type="danger" 
              size="small" 
              @click="handleRefund(scope.row)">
              强制退款
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination-container">
        <el-pagination background layout="prev, pager, next" :total="3" />     
      </div>
    </el-card>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const searchQuery = ref('')
const typeFilter = ref('')
const statusFilter = ref('')

const tableData = ref([
  { orderNo: 'ORD20240401001', type: 'carpool', title: '东校区侧门 -> 高铁南站', payer: 'student01', amount: '15.00', status: 'completed', createTime: '2024-04-01 08:30:00' },
  { orderNo: 'ORD20240401002', type: 'group', title: '周末清远漂流主题团预付款', payer: 'student02', amount: '120.00', status: 'paid', createTime: '2024-04-01 09:15:00' },
  { orderNo: 'ORD20240401003', type: 'carpool', title: '西区宿舍楼 -> 万达广场', payer: 'student03', amount: '10.00', status: 'pending', createTime: '2024-04-01 10:00:00' }
])

const filteredData = computed(() => {
  return tableData.value.filter(item => {
    const matchQuery = item.orderNo.includes(searchQuery.value)
    const matchType = typeFilter.value ? item.type === typeFilter.value : true  
    const matchStatus = statusFilter.value ? item.status === statusFilter.value : true
    return matchQuery && matchType && matchStatus
  })
})

const fetchData = () => {
  loading.value = true
  setTimeout(() => {
    loading.value = false
  }, 400)
}

const handleRefund = (row) => {
  ElMessageBox.confirm(`确定要为订单 ${row.orderNo} 执行强制退款吗？此操作不可逆。`, '强制退款', {
    confirmButtonText: '执行退款',
    cancelButtonText: '取消',
    type: 'error',
  }).then(() => {
    row.status = 'cancelled'
    ElMessage.success('退款操作已提交系统处理')
  }).catch(() => {})
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.admin-orders-container {
  padding: 10px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}
.filter-actions {
  display: flex;
  align-items: center;
  font-weight: normal;
}
.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>