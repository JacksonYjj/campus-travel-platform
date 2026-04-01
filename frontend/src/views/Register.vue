<template>
  <div class="register-container">
    <el-card class="register-card">
      <template #header>
        <div class="card-header">
          <h2>加入校园出行</h2>
          <span>创建您的账号，开启便捷校内互助之旅</span>
        </div>
      </template>
      <el-form :model="regForm" :rules="rules" ref="regFormRef" label-position="top">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="regForm.username" placeholder="建议使用学号或常用名" />
        </el-form-item>
        <el-form-item label="密码" prop="password">
          <el-input v-model="regForm.password" type="password" placeholder="请输入密码" show-password />
        </el-form-item>
        <el-form-item label="确认密码" prop="checkPass">
          <el-input v-model="regForm.checkPass" type="password" placeholder="请再次输入密码" show-password />
        </el-form-item>
        
        <el-divider content-position="left">实名信息（可选）</el-divider>
        
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="真实姓名" prop="realName">
              <el-input v-model="regForm.realName" placeholder="姓名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="手机号" prop="phone">
              <el-input v-model="regForm.phone" placeholder="手机号" />
            </el-form-item>
          </el-col>
        </el-row>

        <el-form-item label="学校" prop="schoolName">
          <el-input v-model="regForm.schoolName" placeholder="所在学校" />
        </el-form-item>

        <el-button type="primary" class="register-btn" @click="handleRegister" :loading="loading">立即注册</el-button>
        <div class="login-link">
          已有账号？<el-link type="primary" @click="$router.push('/login')">返回登录</el-link>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import axios from 'axios'

const router = useRouter()
const loading = ref(false)
const regFormRef = ref(null)

const regForm = reactive({
  username: '',
  password: '',
  checkPass: '',
  realName: '',
  phone: '',
  schoolName: ''
})

const validatePass = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请输入密码'))
  } else {
    if (regForm.checkPass !== '') {
      regFormRef.value.validateField('checkPass')
    }
    callback()
  }
}

const validatePass2 = (rule, value, callback) => {
  if (value === '') {
    callback(new Error('请再次输入密码'))
  } else if (value !== regForm.password) {
    callback(new Error('两次输入密码不一致!'))
  } else {
    callback()
  }
}

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [{ validator: validatePass, trigger: 'blur', required: true }],
  checkPass: [{ validator: validatePass2, trigger: 'blur', required: true }],
  phone: [{ pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号', trigger: 'blur' }]
}

const handleRegister = async () => {
  await regFormRef.value.validate()
  loading.value = true
  try {
    const submitData = {
      username: regForm.username,
      passwordHash: regForm.password, // 后端服务中字段名为 passwordHash
      realName: regForm.realName,
      phone: regForm.phone,
      schoolName: regForm.schoolName
    }
    const res = await axios.post('/api/auth/register', submitData)
    if (res.data.success) {
      ElMessage.success('注册成功，请登录')
      router.push('/login')
    } else {
      ElMessage.error('注册失败，请稍后重试')
    }
  } catch (error) {
    ElMessage.error('注册异常：' + (error.response?.data?.message || '服务器连接失败'))
  } finally {
    loading.value = false
  }
}
</script>

<style scoped lang="scss">
.register-container {
  min-height: 100vh;
  padding: 40px 0;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  .register-card {
    width: 500px;
    border-radius: 12px;
    box-shadow: 0 8px 16px rgba(0,0,0,0.1);
    .card-header {
      text-align: center;
      h2 { margin-bottom: 8px; color: #67C23A; font-weight: bold; }
      span { font-size: 14px; color: #909399; }
    }
  }
  .register-btn { width: 100%; height: 45px; font-size: 16px; border-radius: 8px; margin-top: 10px; }
  .login-link { margin-top: 20px; text-align: center; font-size: 14px; }
}
</style>