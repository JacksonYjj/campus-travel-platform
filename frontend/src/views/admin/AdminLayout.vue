<template>
  <div class="admin-layout">
    <el-container>
      <el-aside width="240px" class="sidebar">
        <div class="logo">CAMPUS TRAVEL<br/><span style="font-size: 14px">管理后台</span></div>
        <el-menu :router="true" :default-active="route.path" class="el-menu-vertical" background-color="#2b2f3a" text-color="#fff" active-text-color="#409eff">
          <el-menu-item index="/admin"><el-icon><Monitor /></el-icon>数据看板</el-menu-item>
          <el-menu-item index="/admin/users"><el-icon><UserFilled /></el-icon>用户管理</el-menu-item>
          <el-menu-item index="/admin/orders"><el-icon><List /></el-icon>订单管理</el-menu-item>
          <el-menu-item index="/admin/appeals"><el-icon><Warning /></el-icon>申诉与审核</el-menu-item>
        </el-menu>
      </el-aside>
      <el-main class="main-content">
        <header class="top-nav">
          <div class="breadcrumb">后台管理系统 / {{ routeNameMap[route.path] || '当前页面' }}</div>
          <div class="user-profile">
            <el-dropdown trigger="click">
              <span class="el-dropdown-link" style="cursor: pointer; display: flex; align-items: center;">
                <el-avatar :size="32" src="https://cube.elemecdn.com/0/88/03b0d39583f48206768a7534e55bcpng.png" />
                <span class="username" style="margin-left: 10px; font-weight: bold;">平台管理员</span>
                <el-icon class="el-icon--right"><arrow-down /></el-icon>
              </span>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item @click="logout">退出管理员登录</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </header>

        <div class="content-wrapper">
          <router-view />
        </div>
      </el-main>
    </el-container>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

const route = useRoute()
const router = useRouter()

const routeNameMap = {
  '/admin': '数据看板',
  '/admin/users': '用户管理',
  '/admin/orders': '订单管理',
  '/admin/appeals': '申诉与审核'
}

const logout = () => {
  localStorage.removeItem('token')
  localStorage.removeItem('user')
  router.push('/login')
}
</script>

<style scoped lang="scss">
.admin-layout {
  height: 100vh;
  background-color: #f0f2f5;
  .sidebar { 
    background: #2b2f3a; 
    color: white; 
    .logo { 
      height: 80px; 
      line-height: normal;
      padding-top: 15px;
      text-align: center; 
      font-size: 20px; 
      font-weight: bold; 
      color: #fff; 
      border-bottom: 1px solid #1f2229;
    } 
    .el-menu {
      border-right: none;
    }
  }
  .top-nav { 
    height: 60px; 
    background: white; 
    padding: 0 20px; 
    display: flex; 
    justify-content: space-between; 
    align-items: center; 
    box-shadow: 0 1px 4px rgba(0,21,41,0.08); 
  }
  .content-wrapper {
    padding: 20px;
  }
}
</style>