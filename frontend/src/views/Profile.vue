<template>
  <div class="profile-container">
    <el-row :gutter="20">
      <el-col :span="8">
        <el-card shadow="never" class="user-card">
          <div class="avatar-wrap">
            <el-avatar :size="100" :src="userInfo.avatarUrl || 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'" />
          </div>
          <h2 class="username">{{ userInfo.realName || userInfo.username || '未命名用户' }}</h2>
          <div class="user-role">
            <el-tag :type="getRoleTag(userInfo.role)" effect="dark">{{ getRoleName(userInfo.role) || '普通用户' }}</el-tag>
          </div>
          <el-divider />
          <div class="user-stats">
            <div class="stat-item">
              <div class="stat-value">{{ userInfo.creditScore || '--' }}</div>
              <div class="stat-label">信誉分</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ userInfo.completedTrips || 0 }}</div>
              <div class="stat-label">出车次数</div>
            </div>
          </div>
          <el-button type="danger" plain class="logout-btn" @click="logout" style="width:100%; margin-top: 20px;">退出登录</el-button>
        </el-card>
      </el-col>
      <el-col :span="16">
        <el-card shadow="never">
          <template #header>
            <div class="card-header">个人资料设置</div>
          </template>
          <el-form label-width="120px" :model="form">
            <el-form-item label="真实姓名">
              <el-input v-model="form.realName" />
            </el-form-item>
            <el-form-item label="学号/工号">
              <el-input v-model="form.studentId" />
            </el-form-item>
            <el-form-item label="联系电话">
              <el-input v-model="form.phone" />
            </el-form-item>
            <el-form-item label="一句介绍">
              <el-input v-model="form.signature" type="textarea" :rows="3" placeholder="写点什么介绍自己吧..." />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="saveProfile">保存修改</el-button>
            </el-form-item>
          </el-form>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import axios from 'axios'
import { ElMessage } from 'element-plus'

const router = useRouter()
const userInfo = ref({})
const form = ref({
  realName: '',
  studentId: '',
  phone: '',
  signature: ''
})

const getRoleName = (role) => {
  const map = { 'STUDENT': '学生', 'DRIVER': '车主', 'ORGANIZER': '团长/组织者', 'ADMIN': '管理员' }
  return map[role]
}

const getRoleTag = (role) => {
  const map = { 'STUDENT': 'info', 'DRIVER': 'success', 'ORGANIZER': 'warning', 'ADMIN': 'danger' }
  return map[role] || 'info'
}

onMounted(async () => {
  try {
    const res = await axios.get('/api/user/profile')
    const data = res.data || {}
    userInfo.value = data
    form.value.realName = data.realName || ''
    form.value.studentId = data.studentId || ''
    form.value.phone = data.phone || ''
    form.value.signature = data.signature || ''
  } catch (err) {
    ElMessage.error('获取个人信息失败')
    // Fallback to localStorage if API fails
    const localUser = JSON.parse(localStorage.getItem('user') || '{}')
    userInfo.value = localUser
  }
})

const saveProfile = async () => {
  try {
    await axios.post('/api/user/profile', form.value)
    ElMessage.success('资料保存成功')
  } catch (e) {
    ElMessage.error('保存失败')
  }
}

const logout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  router.push('/login')
}
</script>

<style scoped>
.profile-container {
  padding: 20px;
}
.user-card {
  text-align: center;
}
.avatar-wrap {
  margin: 20px 0;
}
.username {
  margin: 0;
  font-size: 20px;
  color: #303133;
}
.user-role {
  margin: 10px 0;
}
.user-stats {
  display: flex;
  justify-content: space-around;
  margin-top: 15px;
}
.stat-item {
  text-align: center;
}
.stat-value {
  font-size: 24px;
  font-weight: bold;
  color: #409EFF;
}
.stat-label {
  font-size: 13px;
  color: #909399;
  margin-top: 5px;
}
.card-header {
  font-weight: bold;
}
</style>
