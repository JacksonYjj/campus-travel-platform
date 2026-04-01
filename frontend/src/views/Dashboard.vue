<template>
  <div class="dashboard">
    <el-container>
      <el-aside width="240px" class="sidebar">
        <div class="logo">CAMPUS TRAVEL</div>
        <el-menu :router="true" :default-active="route.path" class="el-menu-vertical">
          <el-menu-item index="/dashboard"><el-icon><Monitor /></el-icon>控制面板</el-menu-item>
          <el-menu-item index="/dashboard/carpool"><el-icon><Bicycle /></el-icon>拼车大厅</el-menu-item>
          <el-menu-item index="/dashboard/group"><el-icon><ChatLineRound /></el-icon>约团广场</el-menu-item>
          <el-menu-item index="/dashboard/orders"><el-icon><Tickets /></el-icon>我的订单</el-menu-item>
          <el-menu-item index="/dashboard/profile"><el-icon><User /></el-icon>个人中心</el-menu-item>
        </el-menu>
      </el-aside>
      <el-main class="main-content">
        <header class="top-nav">
          <div class="breadcrumb">首页 / {{ route.path === '/dashboard' ? '控制面板' : '业务模块' }}</div>
          <div class="user-profile">
            <el-avatar :size="32" :src="userInfo.avatarUrl" />
            <span class="username">{{ userInfo.realName || userInfo.username || '普通用户' }}</span>
          </div>
        </header>

        <router-view v-if="route.path !== '/dashboard'" />

        <div v-else>
          <div class="stat-cards">
            <el-row :gutter="20">
              <el-col :span="6" v-for="stat in stats" :key="stat.label">        
                <el-card shadow="hover" class="stat-card">
                  <div class="stat-val">{{ stat.value }}</div>
                  <div class="stat-label">{{ stat.label }}</div>
                </el-card>
              </el-col>
            </el-row>
          </div>

          <div class="content-body">
            <el-row :gutter="20">
              <el-col :span="16">
                <el-card header="活跃拼车行程">
                  <el-table :data="recentTrips" stripe>
                    <el-table-column prop="departureTime" label="时间" width="160" />
                    <el-table-column prop="startLocation" label="出发地" />   
                    <el-table-column prop="endLocation" label="目的地" />      
                    <el-table-column prop="seatAvailable" label="剩余座位" width="100" />
                    <el-table-column label="操作" width="120">
                      <template #default="scope">
                        <el-button type="primary" size="small" @click="$router.push('/dashboard/carpool')">立即加入</el-button>
                      </template>
                    </el-table-column>
                  </el-table>
                </el-card>
              </el-col>
              <el-col :span="8">
                <el-card header="热门约团推荐">
                  <div v-for="group in hotGroups" :key="group.id" class="group-item" @click="$router.push('/dashboard/group')">
                    <div class="group-title">{{ group.title }}</div>
                    <div class="group-meta">
                      <el-tag size="small">{{ group.category }}</el-tag>        
                      <span>{{ group.memberCount }}/{{ group.maxCount }}人</span>
                    </div>
                  </div>
                </el-card>
              </el-col>
            </el-row>
          </div>
        </div>
      </el-main>
    </el-container>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const userInfo = ref(JSON.parse(localStorage.getItem('user') || '{}'))
const stats = ref([
  { label: '活跃拼车', value: '12' },
  { label: '热门约团', value: '8' },
  { label: '我的足迹', value: '25' },
  { label: '信誉积分', value: '100' }
])
const recentTrips = ref([
  { departureTime: '2024-04-01 09:00', startLocation: '东校区侧门', endLocation: '高铁南站', seatAvailable: 3 },
  { departureTime: '2024-04-01 14:30', startLocation: '西区宿舍楼', endLocation: '万达广场', seatAvailable: 2 }
])
const hotGroups = ref([
  { id: 1, title: '周末清远漂流主题团', category: '户外', memberCount: 15, maxCount: 20 },
  { id: 2, title: '顺德美食探店半日游', category: '美食', memberCount: 6, maxCount: 8 }
])
</script>

<style scoped lang="scss">
.dashboard {
  height: 100vh;
  background-color: #f0f2f5;
  .sidebar { background: #001529; color: white; .logo { height: 60px; line-height: 60px; text-align: center; font-size: 20px; font-weight: bold; color: #409EFF; } }
  .top-nav { height: 60px; background: white; padding: 0 20px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 4px rgba(0,21,41,0.08); }
  .user-profile { display: flex; align-items: center; .username { margin-left: 10px; font-weight: 500; } }
  .stat-cards { margin: 20px; .stat-card { text-align: center; .stat-val { font-size: 24px; font-weight: bold; color: #303133; } .stat-label { color: #909399; margin-top: 8px; } } }
  .content-body { margin: 20px; .group-item { padding: 12px 0; border-bottom: 1px solid #ebeef5; &:last-child { border-bottom: none; } .group-title { font-weight: bold; margin-bottom: 8px; } .group-meta { display: flex; justify-content: space-between; align-items: center; font-size: 13px; color: #909399; } } }
}
</style>
