# campus-travel-platform

校园拼车与组队出行平台，前后端分离架构。

## 项目结构

- `backend/`: Spring Boot + MyBatis 后端服务
- `frontend/`: Vue 3 + Vite 前端应用
- `carpool_group_platform_schema.sql`: 数据库建表脚本
- `启动文档_详细版.md`: 详细版启动说明

## 技术栈

- 后端：Spring Boot 3.2, Spring Security, MyBatis, MySQL, JWT
- 前端：Vue 3, Vite, Pinia, Vue Router, Element Plus, Axios

## 环境要求

- JDK 17
- Maven 3.8+
- Node.js 18+
- MySQL 8+

## 本地启动

### 1. 初始化数据库

先执行 `carpool_group_platform_schema.sql`，创建所需表结构。

### 2. 启动后端

进入 `backend/` 目录后执行：

```bash
mvn spring-boot:run
```

### 3. 启动前端

进入 `frontend/` 目录后执行：

```bash
npm install
npm run dev
```

## 常用脚本

前端：

- `npm run dev`
- `npm run build`
- `npm run preview`

## 版本管理

提交规范见 [CONTRIBUTING.md](CONTRIBUTING.md)。
