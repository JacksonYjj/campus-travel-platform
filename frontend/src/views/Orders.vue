<template>
  <div class="orders-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>我的订单</span>
          <el-radio-group v-model="orderType" size="small" @change="fetchOrders">
            <el-radio-button label="carpool">拼车订单</el-radio-button>
            <el-radio-button label="group">约团记录</el-radio-button>
          </el-radio-group>
        </div>
      </template>

      <el-table :data="orders" v-loading="loading" style="width: 100%" stripe>
        <el-table-column prop="orderNo" label="订单编号" width="180" />
        <el-table-column prop="title" label="行程/活动" min-width="200" />
        <el-table-column prop="amount" label="金额 (元)" width="100">
          <template #default="{ row }">
            <span class="price">¥{{ row.amount }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="120">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.status === 'PENDING'" type="primary" link size="small">去支付</el-button>
            <el-button v-if="row.status === 'CONFIRMED'" type="danger" link size="small">取消订单</el-button>
            <el-button type="info" link size="small">详情</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import axios from 'axios'
import { ElMessage } from 'element-plus'

const orderType = ref('carpool')
const orders = ref([])
const loading = ref(false)

const getStatusType = (status) => {
  const map = { PENDING: 'warning', CONFIRMED: 'success', CANCELLED: 'info', COMPLETED: 'primary' }
  return map[status] || 'info'
}

const getStatusText = (status) => {
  const map = { PENDING: '待确认/待支付', CONFIRMED: '已确认', CANCELLED: '已取消', COMPLETED: '已完成' }
  return map[status] || status
}

const fetchOrders = async () => {
  loading.value = true
  try {
    const res = await axios.get('/api/orders/list', { params: { type: orderType.value } })
    orders.value = res.data || []
  } catch (err) {
    ElMessage.error('获取订单列表失败')
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchOrders()
})
</script>

<style scoped>
.orders-container {
  padding: 20px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}
.price {
  color: #f56c6c;
  font-weight: bold;
}
</style>
