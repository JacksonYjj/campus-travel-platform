<template>
  <div class="login-container">
    <el-card class="login-card">
      <template #header>
        <div class="card-header">
          <h2>校园约行系统</h2>
          <span>一站式校园出行服务平台</span>
        </div>
      </template>
      <el-form :model="loginForm" label-position="top">
        <el-form-item label="用户名">
          <el-input v-model="loginForm.username" placeholder="请输入用户名" prefix-icon="User" />
        </el-form-item>
        <el-form-item label="密码">
          <el-input v-model="loginForm.password" type="password" placeholder="请输入密码" prefix-icon="Lock" show-password @keyup.enter="handleLogin" />
        </el-form-item>
        <div class="login-options">
          <el-checkbox v-model="rememberMe">记住我</el-checkbox>
          <el-link type="primary">忘记密码？</el-link>
        </div>
        <el-button type="primary" class="login-btn" @click="handleLogin" :loading="loading">登录</el-button>
        <div class="reg-link">
          还没有账号？<el-link type="primary" @click="$router.push('/register')">立即注册</el-link>
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
const rememberMe = ref(false)
const loginForm = reactive({ username: '', password: '' })

const handleLogin = async () => {
  if (!loginForm.username || !loginForm.password) {
    ElMessage.warning('请输入用户名和密码！')
    return
  }
  loading.value = true
  try {
    const res = await axios.post('/api/auth/login', loginForm)
    localStorage.setItem('token', res.data.token)
    localStorage.setItem('user', JSON.stringify(res.data.user))
    ElMessage.success('登录成功！')
    if (res.data.user && (res.data.user.username === 'admin' || res.data.user.username === 'admin01')) {
      router.push('/admin')
    } else {
      router.push('/dashboard')
    }
  } catch (error) {
    const status = error?.response?.status
    if (status === 401) {
      ElMessage.error('登录失败：用户名或密码错误！')
    } else {
      ElMessage.error('登录失败：服务器异常，请稍后再试！')
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped lang="scss">
.login-container {
  height: 100vh;
  display: flex;
  justify-content: center;
  align-items: center;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  .login-card {
    width: 400px;
    border-radius: 12px;
    box-shadow: 0 8px 16px rgba(0,0,0,0.1);
    .card-header {
      text-align: center;
      h2 { margin-bottom: 8px; color: #409EFF; font-weight: bold; }
      span { font-size: 14px; color: #909399; }
    }
  }
  .login-options {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
  }
  .login-btn { width: 100%; height: 45px; font-size: 16px; border-radius: 8px; }
  .reg-link { margin-top: 20px; text-align: center; font-size: 14px; }
}
</style>