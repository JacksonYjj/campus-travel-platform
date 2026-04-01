<template>
  <div class="admin-users-container">
    <el-card shadow="never">
      <template #header>
        <div class="card-header">
          <span>用户管理</span>
          <div class="filter-actions">
            <el-input v-model="searchQuery" placeholder="搜索用户名或手机号" style="width: 200px; margin-right: 10px;" clearable />
            <el-select v-model="roleFilter" placeholder="全部角色" style="width: 120px; margin-right: 10px;">
              <el-option label="全部角色" value="" />
              <el-option label="普通学生" value="STUDENT" />
              <el-option label="认证车主" value="DRIVER" />
              <el-option label="认证团长" value="ORGANIZER" />
            </el-select>
            <el-button type="primary" @click="fetchData">查询</el-button>
          </div>
        </div>
      </template>

      <el-table :data="filteredData" style="width: 100%" v-loading="loading">   
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="username" label="用户名" width="120" />
        <el-table-column prop="realName" label="真实姓名" width="100" />
        <el-table-column prop="role" label="角色" width="100">
          <template #default="scope">
            <el-tag :type="getRoleTag(scope.row.role)">{{ getRoleName(scope.row.role) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="phone" label="联系电话" width="130" />
        <el-table-column prop="creditScore" label="信誉分" width="80" align="center" />
        <el-table-column prop="status" label="账号状态" width="100">
          <template #default="scope">
            <el-switch
              v-model="scope.row.status"
              active-value="active"
              inactive-value="banned"
              style="--el-switch-on-color: #13ce66; --el-switch-off-color: #ff4949"
              @change="handleStatusChange(scope.row)"
            />
          </template>
        </el-table-column>
        <el-table-column label="操作" fixed="right">
          <template #default="scope">
            <el-button link type="primary" size="small" @click="handleDetail(scope.row)">详情</el-button>
            <el-button link type="warning" size="small" @click="handleResetPassword(scope.row)">重置密码</el-button>
          </template>
        </el-table-column>
      </el-table>
      
      <div class="pagination-container">
        <el-pagination background layout="prev, pager, next" :total="filteredData.length" />     
      </div>
    </el-card>

    <!-- 用户详情弹窗 -->
    <el-dialog v-model="detailDialogVisible" title="用户详情" width="500px">
      <el-descriptions :column="1" border v-if="currentUserDetail">
        <el-descriptions-item label="用户 ID">{{ currentUserDetail.id }}</el-descriptions-item>
        <el-descriptions-item label="用户名">{{ currentUserDetail.username }}</el-descriptions-item>
        <el-descriptions-item label="真实姓名">{{ currentUserDetail.realName }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentUserDetail.phone }}</el-descriptions-item>
        <el-descriptions-item label="角色">{{ getRoleName(currentUserDetail.role) }}</el-descriptions-item>
        <el-descriptions-item label="信誉分">
          <el-tag :type="currentUserDetail.creditScore >= 80 ? 'success' : 'danger'">{{ currentUserDetail.creditScore }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="账号状态">
          <el-tag :type="currentUserDetail.status === 'active' ? 'success' : 'danger'">
            {{ currentUserDetail.status === 'active' ? '正常' : '封禁' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="注册时间">2024-03-01 10:00:00 (模拟)</el-descriptions-item>
      </el-descriptions>
      <template #footer>
        <span class="dialog-footer">
          <el-button type="primary" @click="detailDialogVisible = false">确认</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import axios from 'axios'

const loading = ref(false)
const searchQuery = ref('')
const roleFilter = ref('')

const tableData = ref([])

const filteredData = computed(() => {
  return tableData.value.filter(item => {
    const username = item.username || ''
    const phone = item.phone || ''
    const matchQuery = (username.includes(searchQuery.value) || phone.includes(searchQuery.value))
    const matchRole = roleFilter.value ? item.role === roleFilter.value : true
    return matchQuery && matchRole
  })
})

const fetchData = async () => {
  loading.value = true
  try {
    const res = await axios.get('/api/admin/users')
    if (res.data && res.data.data) {
      tableData.value = res.data.data
    }
  } catch (err) {
    ElMessage.error('获取用户列表失败')
    console.error(err)
  } finally {
    loading.value = false
  }
}

const detailDialogVisible = ref(false)
const currentUserDetail = ref(null)

const handleDetail = (row) => {
  currentUserDetail.value = { ...row }
  detailDialogVisible.value = true
}

const handleResetPassword = (row) => {
  ElMessageBox.confirm(
    `确定要将用户【${row.username}】的密码重置为默认密码(123456)吗？`,
    '重置密码确认',
    {
      confirmButtonText: '确定重置',
      cancelButtonText: '取消',
      type: 'warning',
    }
  ).then(async () => {
    try {
      await axios.put(`/api/admin/users/${row.id}/reset-password`)
      ElMessage.success(`用户 ${row.username} 密码已成功重置为 123456`)
    } catch (err) {
      ElMessage.error('重置密码失败')
    }
  }).catch(() => {})
}

const getRoleName = (role) => {
  const map = { 'STUDENT': '学生', 'DRIVER': '车主', 'ORGANIZER': '团长', 'ADMIN': '管理员' }
  return map[role] || '未知'
}

const getRoleTag = (role) => {
  const map = { 'STUDENT': 'info', 'DRIVER': 'success', 'ORGANIZER': 'warning', 'ADMIN': 'danger' }
  return map[role] || 'info'
}

const handleStatusChange = async (row) => {
  try {
    const newStatus = row.status
    await axios.put(`/api/admin/users/${row.id}/status`, { status: newStatus })
    const action = newStatus === 'active' ? '解封' : '封禁'
    ElMessage.success(`已${action}用户: ${row.username}`)
  } catch (err) {
    ElMessage.error('更新状态失败')
    // Revert switch on fail
    row.status = row.status === 'active' ? 'banned' : 'active'
  }
}

onMounted(() => {
  fetchData()
})
</script>

<style scoped>
.admin-users-container {
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