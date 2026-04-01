<template>
  <div class="carpool-hall">
    <el-card class="filter-card">
      <el-form :inline="true" :model="filters" class="demo-form-inline">
        <el-form-item label="出发地">
          <el-input v-model="filters.start" placeholder="从哪儿出发" />
        </el-form-item>
        <el-form-item label="目的地">
          <el-input v-model="filters.end" placeholder="去哪儿" />
        </el-form-item>
        <el-form-item label="日期">
          <el-date-picker v-model="filters.date" type="date" placeholder="出发日期" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="fetchTrips">搜索行程</el-button>
          <el-button type="success" @click="publishDialog = true">发布行程</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <div class="trip-list" v-loading="loading">
      <el-row :gutter="20">
        <el-col :span="8" v-for="trip in trips" :key="trip.id">
          <el-card shadow="hover" class="trip-card">
            <div class="trip-header">
              <span class="trip-time">{{ formatTime(trip.departureTime) }}</span>
              <el-tag :type="trip.seatAvailable > 0 ? 'success' : 'info'">
                余{{ trip.seatAvailable }}座
              </el-tag>
            </div>
            <div class="trip-route">
              <div class="point-item start">{{ trip.startLocation }}</div>
              <div class="route-line"></div>
              <div class="point-item end">{{ trip.endLocation }}</div>
            </div>
            <div class="trip-footer">
              <div class="driver-info">
                <el-avatar :size="24" icon="User" />
                <span class="driver-name">{{ trip.driverName || '车主' }}</span>
              </div>
              <div class="price">￥{{ trip.pricePerPerson }}</div>
            </div>
            <div class="actions">
              <el-button type="primary" plain @click="joinTrip(trip)" :disabled="trip.seatAvailable <= 0">加入拼车</el-button>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>

    <el-dialog v-model="publishDialog" title="发布拼车行程" width="500px">
      <el-form :model="publishForm" label-width="80px">
        <el-form-item label="出发地">
          <el-input v-model="publishForm.startLocation" />
        </el-form-item>
        <el-form-item label="目的地">
          <el-input v-model="publishForm.endLocation" />
        </el-form-item>
        <el-form-item label="出发时间">
          <el-date-picker v-model="publishForm.departureTime" type="datetime" placeholder="选择时间" />
        </el-form-item>
        <el-row>
          <el-col :span="12">
            <el-form-item label="座位数">
              <el-input-number v-model="publishForm.seatTotal" :min="1" :max="6" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="单价">
              <el-input-number v-model="publishForm.pricePerPerson" :min="0" />
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <el-button @click="publishDialog = false">取消</el-button>
        <el-button type="primary" @click="handlePublish">立即发布</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import axios from 'axios'
import dayjs from 'dayjs'

const trips = ref([])
const loading = ref(false)
const publishDialog = ref(false)
const filters = reactive({ start: '', end: '', date: '' })
const publishForm = reactive({
  startLocation: '',
  endLocation: '',
  departureTime: '',
  seatTotal: 3,
  pricePerPerson: 15,
  pricingMode: 'fixed_per_person'
})

const fetchTrips = async () => {
  loading.value = true
  try {
    const res = await axios.get('/api/trips/carpool/list', { params: filters })
    trips.value = res.data
  } catch (err) {
    ElMessage.error('获取行程失败')
  } finally {
    loading.value = false
  }
}

const handlePublish = async () => {
  try {
    await axios.post('/api/trips/carpool/publish', {
      ...publishForm,
      seatAvailable: publishForm.seatTotal,
      departureTime: dayjs(publishForm.departureTime).format('YYYY-MM-DD HH:mm:ss')
    })
    ElMessage.success('发布成功')
    publishDialog.value = false
    fetchTrips()
  } catch (err) {
    ElMessage.error('发布失败')
  }
}

const joinTrip = (trip) => {
  ElMessageBox.confirm(`确认预约从 ${trip.startLocation} 到 ${trip.endLocation} 的拼车吗？费用约为 ￥${trip.pricePerPerson}`, '预约确认')
    .then(() => {
      ElMessage.success('预约申请已发送给车主')
    })
    .catch(() => {})
}

const formatTime = (time) => dayjs(time).format('MM-DD HH:mm')

onMounted(fetchTrips)
</script>

<style scoped>
.carpool-hall {
  padding: 20px;
}
.filter-card {
  margin-bottom: 20px;
}
.trip-card {
  margin-bottom: 20px;
  border-radius: 8px;
}
.trip-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
  border-bottom: 1px solid #ebeef5;
  padding-bottom: 15px;
}
.trip-time {
  font-size: 18px;
  font-weight: bold;
  color: #303133;
}
.trip-route {
  margin-bottom: 15px;
}
.point-item {
  position: relative;
  padding-left: 20px;
  line-height: 24px;
}
.point-item::before {
  content: '';
  position: absolute;
  left: 0;
  top: 8px;
  width: 8px;
  height: 8px;
  border-radius: 50%;
}
.point-item.start::before { background-color: #67C23A; }
.point-item.end::before { background-color: #F56C6C; }
.route-line {
  margin-left: 3px;
  height: 15px;
  border-left: 2px dashed #DCDFE6;
  margin-top: -2px;
  margin-bottom: -2px;
}
.trip-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 15px;
}
.driver-info {
  display: flex;
  align-items: center;
}
.driver-name {
  margin-left: 8px;
  color: #606266;
  font-size: 14px;
}
.price {
  font-size: 20px;
  color: #FF9900;
  font-weight: bold;
}
.actions {
  text-align: right;
  border-top: 1px solid #ebeef5;
  padding-top: 15px;
}
</style>
