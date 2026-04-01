<template>
  <div class="user-appeals-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>申诉与审核管理</span>
          <el-radio-group v-model="statusFilter" size="small" @change="fetchData">
            <el-radio-button label="all">全部</el-radio-button>
            <el-radio-button label="pending">待审核</el-radio-button>
            <el-radio-button label="approved">已通过</el-radio-button>
            <el-radio-button label="rejected">已驳回</el-radio-button>
          </el-radio-group>
        </div>
      </template>

      <el-table :data="tableData" style="width: 100%" v-loading="loading">
        <el-table-column prop="id" label="单号" width="100" />
        <el-table-column prop="type" label="类型" width="120">
          <template #default="scope">
            <el-tag :type="scope.row.type === 'appeal' ? 'danger' : 'warning'">
              {{ scope.row.type === 'appeal' ? '订单申诉' : '车主资质审核' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="submitter" label="提交人" width="120" />
        <el-table-column prop="description" label="描述/理由" show-overflow-tooltip />
        <el-table-column prop="submitTime" label="提交时间" width="180" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="scope">
            <el-tag v-if="scope.row.status === 'pending'" type="info">待处理</el-tag>
            <el-tag v-else-if="scope.row.status === 'approved'" type="success">已通过</el-tag>
            <el-tag v-else type="danger">已驳回</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="150" fixed="right">
          <template #default="scope">
            <el-button 
              v-if="scope.row.status === 'pending'" 
              link type="primary" size="small" 
              @click="handleAudit(scope.row)">
              立即审核
            </el-button>
            <el-button 
              v-else 
              link type="info" size="small">
              查看详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination-container">
        <el-pagination background layout="prev, pager, next" :total="1" />
      </div>
    </el-card>

    <!-- 审核对话框 -->
    <el-dialog v-model="dialogVisible" title="信息审核" width="500px">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="提交人">{{ currentItem.submitter }}</el-descriptions-item>
        <el-descriptions-item label="审核类型">{{ currentItem.type === 'appeal' ? '订单申诉' : '资质审核' }}</el-descriptions-item>
        <el-descriptions-item label="详细说明">{{ currentItem.description }}</el-descriptions-item>
      </el-descriptions>
      <div style="margin-top: 20px;">
        <el-input
          v-model="auditRemark"
          :rows="3"
          type="textarea"
          placeholder="请输入审核备注(选填)"
        />
      </div>
      <template #footer>
        <span class="dialog-footer">
          <el-button type="danger" @click="submitAudit('rejected')">予以驳回</el-button>
          <el-button type="success" @click="submitAudit('approved')">审核通过</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

const loading = ref(false)
const statusFilter = ref('pending')
const tableData = ref([])

const dialogVisible = ref(false)
const currentItem = ref({})
const auditRemark = ref('')

// Mock data
const mockData = [
  { id: 'A001', type: 'appeal', submitter: 'student01', description: '司机一直未到达指定地点，电话打不通，申请取消订单全额退款。', submitTime: '2024-04-01 10:20:00', status: 'pending' },
  { id: 'A002', type: 'driver_audit', submitter: 'student02', description: '上传了车辆行驶证与驾驶证信息，申请成为车主。', submitTime: '2024-04-01 11:05:00', status: 'pending' },
  { id: 'A003', type: 'appeal', submitter: 'organizer01', description: '团员恶意破坏活动秩序，申请扣除其信誉分。', submitTime: '2024-03-30 15:30:00', status: 'approved' },
  { id: 'A004', type: 'driver_audit', submitter: 'student05', description: '驾照照片模糊不清', submitTime: '2024-03-29 09:10:00', status: 'rejected' }
]

const fetchData = () => {
  loading.value = true
  setTimeout(() => {
    if (statusFilter.value === 'all') {
      tableData.value = mockData
    } else {
      tableData.value = mockData.filter(item => item.status === statusFilter.value)
    }
    loading.value = false
  }, 500)
}

onMounted(() => {
  fetchData()
})

const handleAudit = (row) => {
  currentItem.value = row
  auditRemark.value = ''
  dialogVisible.value = true
}

const submitAudit = (resultStatus) => {
  const actionText = resultStatus === 'approved' ? '通过' : '驳回'
  ElMessageBox.confirm(`确定要 ${actionText} 该审核请求吗?`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  }).then(() => {
    // 模拟提交
    const index = mockData.findIndex(item => item.id === currentItem.value.id)
    if (index !== -1) {
      mockData[index].status = resultStatus
    }
    ElMessage.success(`操作成功，已${actionText}`)
    dialogVisible.value = false
    fetchData()
  }).catch(() => {})
}
</script>

<style scoped>
.user-appeals-container {
  padding: 10px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: bold;
}
.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>