import { createRouter, createWebHistory } from 'vue-router'

const routes = [
  { path: '/', redirect: '/login' },
  { path: '/login', component: () => import('./views/Login.vue') },
  { path: '/register', component: () => import('./views/Register.vue') },
  // 客户端路由
  { 
    path: '/dashboard', 
    component: () => import('./views/Dashboard.vue'), 
    meta: { requiresAuth: true },
    children: [
        { path: '', component: () => import('./views/Dashboard.vue'), meta: { requiresAuth: true } },
        { path: 'carpool', component: () => import('./views/CarpoolHall.vue'), meta: { requiresAuth: true } },
        { path: 'group', component: () => import('./views/GroupSquare.vue'), meta: { requiresAuth: true } },
        { path: 'orders', component: () => import('./views/Orders.vue'), meta: { requiresAuth: true } },
        { path: 'profile', component: () => import('./views/Profile.vue'), meta: { requiresAuth: true } }
    ]
  },
  // 管理员端路由
  {
    path: '/admin',
    component: () => import('./views/admin/AdminLayout.vue'),
    meta: { requiresAuth: true, role: 'ADMIN' },
    children: [
        { path: '', component: () => import('./views/admin/AdminDashboard.vue') },
        { path: 'users', component: () => import('./views/admin/AdminUsers.vue') },      
        { path: 'orders', component: () => import('./views/admin/AdminOrders.vue') },      
        { path: 'appeals', component: () => import('./views/admin/AdminAppeals.vue') }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

router.beforeEach((to, from, next) => {
  if (to.meta.requiresAuth && !localStorage.getItem('token')) {
    next('/login')
  } else {
    next()
  }
})

export default router
