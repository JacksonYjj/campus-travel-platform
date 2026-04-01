<template>
  <div class="admin-dashboard">
    <el-row :gutter="20">
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-title">总用户数</div>
          <div class="stat-value text-blue">1,254</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-title">今日活跃拼车</div>
          <div class="stat-value text-green">142</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-title">今日活跃约团</div>
          <div class="stat-value text-orange">38</div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="stat-card">
          <div class="stat-title">待处理申诉</div>
          <div class="stat-value text-red">5</div>
        </el-card>
      </el-col>
    </el-row>

    <br />
    <el-card header="最新系统通知">
      <p>系统运行正常，各项指标均在阈值范围内。</p>
      <p>建议及时处理积压的用户申诉信息。</p>
    </el-card>
  </div>
</template>

<script setup>
</script>

<style scoped>
.stat-card {
  text-align: center;
  padding: 10px 0;
}
.stat-title {
  font-size: 14px;
  color: #909399;
  margin-bottom: 10px;
}
.stat-value {
  font-size: 28px;
  font-weight: bold;
}
.text-blue { color: #409EFF; }
.text-green { color: #67C23A; }
.text-orange { color: #E6A23C; }
.text-red { color: #F56C6C; }
</style>