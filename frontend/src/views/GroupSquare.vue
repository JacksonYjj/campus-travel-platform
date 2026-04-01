<template>
  <div class="group-square">
    <div class="header-banner">
      <h1>校园约团广场</h1>
      <el-button type="primary" size="large" @click="createDialog = true">发起我的主题团</el-button>
    </div>

    <el-tabs v-model="activeCategory" class="category-tabs">
      <el-tab-pane label="全部" name="all"></el-tab-pane>
      <el-tab-pane label="周边游" name="周边游"></el-tab-pane>
      <el-tab-pane label="跨城游" name="跨城游"></el-tab-pane>
      <el-tab-pane label="美食探店" name="美食探店"></el-tab-pane>
      <el-tab-pane label="户外露营" name="户外露营"></el-tab-pane>
    </el-tabs>

    <div class="group-list" v-loading="loading">
      <el-row :gutter="20">
        <el-col :span="6" v-for="group in filteredGroups" :key="group.id">
          <el-card shadow="hover" class="group-card" :body-style="{ padding: '0px' }">
            <img :src="group.coverImgUrl || 'https://shadow.elemecdn.com/app/element/hamburger.9cf7b091-55e9-11e9-a976-7f4d0b07eef6.png'" class="cover-image" />
            <div class="group-content">
              <div class="title">{{ group.title }}</div>
              <div class="tags">
                <el-tag size="small" type="success">{{ group.tripCategory }}</el-tag>
              </div>
              <div class="info-item">
                <el-icon><Location /></el-icon> {{ group.destination }}
              </div>
              <div class="info-item">
                <el-icon><Calendar /></el-icon> {{ formatDate(group.startTime) }}
              </div>
              <div class="progress-bar">
                <div class="progress-info">
                  <span>已报名 {{ group.memberCount }}/{{ group.maxCount }}</span>
                  <span class="price">￥{{ group.budgetEstimate || 0 }}/人</span>
                </div>
                <el-progress :percentage="(group.memberCount / group.maxCount) * 100" :show-text="false" />
              </div>
              <el-button type="primary" style="width: 100%" @click="joinGroup(group)">立即报名</el-button>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <el-dialog v-model="createDialog" title="发起主题团" width="600px">
      <el-form :model="createForm" label-width="100px">
        <el-form-item label="团名称">
          <el-input v-model="createForm.title" placeholder="例如：周末清远漂流" />
        </el-form-item>
        <el-row>
          <el-col :span="12">
            <el-form-item label="分类">
              <el-select v-model="createForm.tripCategory" style="width:100%">
                <el-option label="周边游" value="周边游" />
                <el-option label="跨城游" value="跨城游" />
                <el-option label="美食探店" value="美食探店" />
                <el-option label="户外露营" value="户外露营" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="目的地">
              <el-input v-model="createForm.destination" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="出发时间">
              <el-date-picker v-model="createForm.startTime" type="datetime" placeholder="出发时间" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="报名截止">
              <el-date-picker v-model="createForm.signupDeadline" type="datetime" placeholder="截止时间" style="width:100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row>
          <el-col :span="12">
            <el-form-item label="人数上限">
              <el-input-number v-model="createForm.maxCount" :min="2" :max="50" style="width:100%" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="预估预算">
              <el-input-number v-model="createForm.budgetEstimate" :min="0" style="width:100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="集会地点">
          <el-input v-model="createForm.gatheringLocation" />
        </el-form-item>
        <el-form-item label="活动详情">
          <el-input type="textarea" v-model="createForm.description" :rows="4" placeholder="描述一下行程安排和亮点..." />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="createDialog = false">取消</el-button>
        <el-button type="primary" @click="handleCreate">提交审核</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Location, Calendar } from '@element-plus/icons-vue'
import axios from 'axios'
import dayjs from 'dayjs'

const groups = ref([])
const loading = ref(false)
const createDialog = ref(false)
const activeCategory = ref('all')

const createForm = reactive({
  title: '',
  tripCategory: '周边游',
  destination: '',
  startTime: '',
  signupDeadline: '',
  maxCount: 10,
  budgetEstimate: 100,
  gatheringLocation: '',
  description: ''
})

const fetchGroups = async () => {
  loading.value = true
  try {
    const res = await axios.get('/api/trips/group/list')
    groups.value = res.data
  } catch (err) {
    ElMessage.error('获取列表失败')
  } finally {
    loading.value = false
  }
}

const filteredGroups = computed(() => {
  if (activeCategory.value === 'all') return groups.value
  return groups.value.filter(g => g.tripCategory === activeCategory.value)
})

const handleCreate = async () => {
  try {
    await axios.post('/api/trips/group/create', {
      title: createForm.title,
      tripCategory: createForm.tripCategory,
      destination: createForm.destination,
      gatheringLocation: createForm.gatheringLocation,
      description: createForm.description,
      memberCount: 1,
      maxCount: createForm.maxCount,
      budgetEstimate: createForm.budgetEstimate,
      startTime: dayjs(createForm.startTime).format('YYYY-MM-DD HH:mm:ss'),
      signupDeadline: dayjs(createForm.signupDeadline).format('YYYY-MM-DD HH:mm:ss')
    })
    ElMessage.success('发起成功，请等待审核')
    createDialog.value = false
    fetchGroups()
  } catch (err) {
    ElMessage.error('发起失败')
  }
}

const joinGroup = (group) => {
  ElMessageBox.confirm(`确认报名参加 ${group.title} 吗？需预支付 ￥${group.budgetEstimate}`, '报名确认')
    .then(() => {
      ElMessage.success('报名成功')
    })
    .catch(() => {})
}

const formatDate = (d) => dayjs(d).format('MM-DD HH:mm')

onMounted(fetchGroups)
</script>

<style scoped>
.group-square {
  padding: 20px;
}
.header-banner {
  background: linear-gradient(to right, #409EFF, #67C23A);
  color: white;
  padding: 40px;
  border-radius: 16px;
  margin-bottom: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.header-banner h1 {
  margin: 0;
}
.category-tabs {
  margin-bottom: 20px;
}
.group-card {
  margin-bottom: 20px;
  border-radius: 8px;
  overflow: hidden;
  transition: all 0.3s;
}
.group-card:hover {
  transform: translateY(-5px);
}
.cover-image {
  width: 100%;
  height: 160px;
  object-fit: cover;
}
.group-content {
  padding: 15px;
}
.title {
  font-size: 16px;
  font-weight: bold;
  margin-bottom: 10px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.tags {
  margin-bottom: 10px;
}
.info-item {
  color: #606266;
  font-size: 13px;
  margin-bottom: 8px;
  display: flex;
  align-items: center;
}
.progress-bar {
  margin-top: 15px;
  margin-bottom: 15px;
}
.progress-info {
  display: flex;
  justify-content: space-between;
  font-size: 12px;
  color: #909399;
  margin-bottom: 5px;
}
.price {
  color: #F56C6C;
  font-weight: bold;
}
</style>
