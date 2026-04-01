-- 校园拼车 + 约团双模式平台数据库脚本
-- MySQL 8.0+
-- 字符集: utf8mb4

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS campus_travel_platform
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE campus_travel_platform;

-- 1) 用户与权限
CREATE TABLE IF NOT EXISTS user_account (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  real_name VARCHAR(50) NOT NULL,
  gender ENUM('male','female','other','unknown') NOT NULL DEFAULT 'unknown',
  phone VARCHAR(20) NOT NULL,
  email VARCHAR(100) NULL,
  school_name VARCHAR(100) NOT NULL,
  campus_name VARCHAR(100) NULL,
  student_no VARCHAR(50) NULL,
  avatar_url VARCHAR(255) NULL,
  auth_status ENUM('pending','verified','rejected') NOT NULL DEFAULT 'pending',
  account_status ENUM('active','disabled','frozen') NOT NULL DEFAULT 'active',
  credit_score INT NOT NULL DEFAULT 100,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_username (username),
  UNIQUE KEY uk_user_phone (phone),
  UNIQUE KEY uk_user_email (email),
  UNIQUE KEY uk_user_school_student (school_name, student_no),
  KEY idx_user_auth_status (auth_status),
  KEY idx_user_account_status (account_status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS role (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  role_code VARCHAR(30) NOT NULL,
  role_name VARCHAR(50) NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_role_code (role_code)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_role (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_role (user_id, role_id),
  KEY idx_user_role_user (user_id),
  KEY idx_user_role_role (role_id),
  CONSTRAINT fk_user_role_user FOREIGN KEY (user_id) REFERENCES user_account(id),
  CONSTRAINT fk_user_role_role FOREIGN KEY (role_id) REFERENCES role(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_emergency_contact (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  contact_name VARCHAR(50) NOT NULL,
  contact_phone VARCHAR(20) NOT NULL,
  relation_type VARCHAR(30) NOT NULL,
  is_default TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_emergency_user (user_id),
  CONSTRAINT fk_emergency_user FOREIGN KEY (user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_verification_doc (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  doc_type ENUM('student_card','campus_card','id_card') NOT NULL,
  doc_no VARCHAR(100) NULL,
  front_image_url VARCHAR(255) NULL,
  back_image_url VARCHAR(255) NULL,
  verify_status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  reviewer_id BIGINT UNSIGNED NULL,
  review_comment VARCHAR(255) NULL,
  reviewed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_verify_user (user_id),
  KEY idx_verify_status (verify_status),
  CONSTRAINT fk_verify_user FOREIGN KEY (user_id) REFERENCES user_account(id),
  CONSTRAINT fk_verify_reviewer FOREIGN KEY (reviewer_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

-- 2) 车主与车辆
CREATE TABLE IF NOT EXISTS vehicle_profile (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  owner_user_id BIGINT UNSIGNED NOT NULL,
  plate_no VARCHAR(20) NOT NULL,
  brand VARCHAR(50) NOT NULL,
  model VARCHAR(50) NOT NULL,
  car_type ENUM('sedan','suv','mpv','other') NOT NULL DEFAULT 'sedan',
  seat_count TINYINT UNSIGNED NOT NULL,
  color VARCHAR(20) NULL,
  verify_status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_vehicle_plate (plate_no),
  KEY idx_vehicle_owner (owner_user_id),
  KEY idx_vehicle_verify_status (verify_status),
  CONSTRAINT fk_vehicle_owner FOREIGN KEY (owner_user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS driver_profile (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  vehicle_id BIGINT UNSIGNED NOT NULL,
  license_no VARCHAR(50) NOT NULL,
  years_of_driving TINYINT UNSIGNED NOT NULL DEFAULT 0,
  verify_status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  reviewer_id BIGINT UNSIGNED NULL,
  review_comment VARCHAR(255) NULL,
  reviewed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_driver_user (user_id),
  UNIQUE KEY uk_driver_license_no (license_no),
  KEY idx_driver_vehicle (vehicle_id),
  KEY idx_driver_verify_status (verify_status),
  CONSTRAINT fk_driver_user FOREIGN KEY (user_id) REFERENCES user_account(id),
  CONSTRAINT fk_driver_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicle_profile(id),
  CONSTRAINT fk_driver_reviewer FOREIGN KEY (reviewer_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

-- 3) 拼车模块
CREATE TABLE IF NOT EXISTS carpool_trip (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  trip_no VARCHAR(32) NOT NULL,
  driver_user_id BIGINT UNSIGNED NOT NULL,
  vehicle_id BIGINT UNSIGNED NOT NULL,
  start_location VARCHAR(120) NOT NULL,
  start_lng DECIMAL(10,6) NULL,
  start_lat DECIMAL(10,6) NULL,
  end_location VARCHAR(120) NOT NULL,
  end_lng DECIMAL(10,6) NULL,
  end_lat DECIMAL(10,6) NULL,
  route_polyline TEXT NULL,
  departure_time DATETIME NOT NULL,
  arrival_time_est DATETIME NULL,
  seat_total TINYINT UNSIGNED NOT NULL,
  seat_available TINYINT UNSIGNED NOT NULL,
  pricing_mode ENUM('fixed_per_person','aa_split') NOT NULL DEFAULT 'fixed_per_person',
  price_per_person DECIMAL(10,2) NULL,
  deposit_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  remark VARCHAR(255) NULL,
  trip_status ENUM('draft','open','matched','in_progress','completed','cancelled') NOT NULL DEFAULT 'open',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_carpool_trip_no (trip_no),
  KEY idx_carpool_driver (driver_user_id),
  KEY idx_carpool_vehicle (vehicle_id),
  KEY idx_carpool_route_time (start_location, end_location, departure_time),
  KEY idx_carpool_status (trip_status),
  CONSTRAINT fk_carpool_driver FOREIGN KEY (driver_user_id) REFERENCES user_account(id),
  CONSTRAINT fk_carpool_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicle_profile(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS carpool_demand (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  demand_no VARCHAR(32) NOT NULL,
  passenger_user_id BIGINT UNSIGNED NOT NULL,
  from_location VARCHAR(120) NOT NULL,
  to_location VARCHAR(120) NOT NULL,
  expected_departure_start DATETIME NOT NULL,
  expected_departure_end DATETIME NOT NULL,
  passenger_count TINYINT UNSIGNED NOT NULL DEFAULT 1,
  car_type_preference ENUM('any','sedan','suv','mpv') NOT NULL DEFAULT 'any',
  budget_min DECIMAL(10,2) NULL,
  budget_max DECIMAL(10,2) NULL,
  gender_preference ENUM('none','male_driver','female_driver') NOT NULL DEFAULT 'none',
  demand_status ENUM('open','matched','cancelled','expired') NOT NULL DEFAULT 'open',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_carpool_demand_no (demand_no),
  KEY idx_demand_user (passenger_user_id),
  KEY idx_demand_route_time (from_location, to_location, expected_departure_start),
  KEY idx_demand_status (demand_status),
  CONSTRAINT fk_demand_user FOREIGN KEY (passenger_user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS carpool_order (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  order_no VARCHAR(32) NOT NULL,
  trip_id BIGINT UNSIGNED NOT NULL,
  passenger_user_id BIGINT UNSIGNED NOT NULL,
  demand_id BIGINT UNSIGNED NULL,
  passenger_count TINYINT UNSIGNED NOT NULL DEFAULT 1,
  unit_price DECIMAL(10,2) NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  deposit_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  pay_status ENUM('unpaid','deposit_paid','paid','refunding','refunded','failed') NOT NULL DEFAULT 'unpaid',
  order_status ENUM('pending_confirm','matched','in_progress','completed','cancelled') NOT NULL DEFAULT 'pending_confirm',
  cancel_reason VARCHAR(255) NULL,
  confirmed_at DATETIME NULL,
  canceled_at DATETIME NULL,
  completed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_carpool_order_no (order_no),
  UNIQUE KEY uk_trip_passenger_once (trip_id, passenger_user_id),
  KEY idx_carpool_order_trip (trip_id),
  KEY idx_carpool_order_passenger (passenger_user_id),
  KEY idx_carpool_order_status (order_status),
  KEY idx_carpool_pay_status (pay_status),
  CONSTRAINT fk_carpool_order_trip FOREIGN KEY (trip_id) REFERENCES carpool_trip(id),
  CONSTRAINT fk_carpool_order_passenger FOREIGN KEY (passenger_user_id) REFERENCES user_account(id),
  CONSTRAINT fk_carpool_order_demand FOREIGN KEY (demand_id) REFERENCES carpool_demand(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS carpool_location_share (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  trip_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  lng DECIMAL(10,6) NOT NULL,
  lat DECIMAL(10,6) NOT NULL,
  speed_kmh DECIMAL(6,2) NULL,
  recorded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_location_trip_time (trip_id, recorded_at),
  KEY idx_location_user_time (user_id, recorded_at),
  CONSTRAINT fk_location_trip FOREIGN KEY (trip_id) REFERENCES carpool_trip(id),
  CONSTRAINT fk_location_user FOREIGN KEY (user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

-- 4) 约团模块
CREATE TABLE IF NOT EXISTS group_trip (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  group_no VARCHAR(32) NOT NULL,
  creator_user_id BIGINT UNSIGNED NOT NULL,
  organizer_type ENUM('personal','club') NOT NULL DEFAULT 'personal',
  title VARCHAR(120) NOT NULL,
  trip_category VARCHAR(50) NOT NULL,
  cover_image_url VARCHAR(255) NULL,
  highlights_richtext LONGTEXT NULL,
  highlights_video_url VARCHAR(255) NULL,
  gather_location VARCHAR(120) NOT NULL,
  destination VARCHAR(120) NOT NULL,
  start_time DATETIME NOT NULL,
  end_time DATETIME NULL,
  signup_deadline DATETIME NOT NULL,
  min_member_count INT UNSIGNED NOT NULL DEFAULT 1,
  max_member_count INT UNSIGNED NOT NULL,
  current_member_count INT UNSIGNED NOT NULL DEFAULT 0,
  budget_per_person DECIMAL(10,2) NULL,
  deposit_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  group_status ENUM('recruiting','formed','in_progress','ended','cancelled') NOT NULL DEFAULT 'recruiting',
  auto_close_when_full TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_group_no (group_no),
  KEY idx_group_creator (creator_user_id),
  KEY idx_group_destination_time (destination, start_time),
  KEY idx_group_status (group_status),
  KEY idx_group_deadline (signup_deadline),
  CONSTRAINT fk_group_creator FOREIGN KEY (creator_user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS group_tag (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  tag_name VARCHAR(40) NOT NULL,
  tag_type VARCHAR(30) NOT NULL DEFAULT 'theme',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_tag_name_type (tag_name, tag_type)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS group_trip_tag_rel (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  group_trip_id BIGINT UNSIGNED NOT NULL,
  tag_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_group_tag_rel (group_trip_id, tag_id),
  KEY idx_group_tag_rel_group (group_trip_id),
  KEY idx_group_tag_rel_tag (tag_id),
  CONSTRAINT fk_group_tag_rel_group FOREIGN KEY (group_trip_id) REFERENCES group_trip(id),
  CONSTRAINT fk_group_tag_rel_tag FOREIGN KEY (tag_id) REFERENCES group_tag(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS group_signup (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  signup_no VARCHAR(32) NOT NULL,
  group_trip_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  member_count TINYINT UNSIGNED NOT NULL DEFAULT 1,
  contact_phone VARCHAR(20) NOT NULL,
  signup_status ENUM('pending_pay','locked','confirmed','cancelled','refunded') NOT NULL DEFAULT 'pending_pay',
  pay_status ENUM('unpaid','deposit_paid','paid','refunding','refunded','failed') NOT NULL DEFAULT 'unpaid',
  pay_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  lock_expire_at DATETIME NULL,
  canceled_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_signup_no (signup_no),
  UNIQUE KEY uk_group_user_once (group_trip_id, user_id),
  KEY idx_signup_group (group_trip_id),
  KEY idx_signup_user (user_id),
  KEY idx_signup_status (signup_status),
  CONSTRAINT fk_signup_group FOREIGN KEY (group_trip_id) REFERENCES group_trip(id),
  CONSTRAINT fk_signup_user FOREIGN KEY (user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS group_member_role (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  group_trip_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  role_in_group ENUM('leader','finance','member','photo') NOT NULL DEFAULT 'member',
  assigned_by BIGINT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_group_member_role (group_trip_id, user_id, role_in_group),
  KEY idx_group_member_role_group (group_trip_id),
  KEY idx_group_member_role_user (user_id),
  CONSTRAINT fk_group_member_role_group FOREIGN KEY (group_trip_id) REFERENCES group_trip(id),
  CONSTRAINT fk_group_member_role_user FOREIGN KEY (user_id) REFERENCES user_account(id),
  CONSTRAINT fk_group_member_role_assigner FOREIGN KEY (assigned_by) REFERENCES user_account(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS group_notice (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  group_trip_id BIGINT UNSIGNED NOT NULL,
  publisher_user_id BIGINT UNSIGNED NOT NULL,
  notice_type ENUM('schedule','meeting','warning','general') NOT NULL DEFAULT 'general',
  title VARCHAR(120) NOT NULL,
  content TEXT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_group_notice_group_time (group_trip_id, created_at),
  CONSTRAINT fk_group_notice_group FOREIGN KEY (group_trip_id) REFERENCES group_trip(id),
  CONSTRAINT fk_group_notice_publisher FOREIGN KEY (publisher_user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS group_media (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  group_trip_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  media_type ENUM('image','video') NOT NULL,
  media_url VARCHAR(255) NOT NULL,
  description VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_group_media_group_time (group_trip_id, created_at),
  KEY idx_group_media_user (user_id),
  CONSTRAINT fk_group_media_group FOREIGN KEY (group_trip_id) REFERENCES group_trip(id),
  CONSTRAINT fk_group_media_user FOREIGN KEY (user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

-- 5) 双模式联动
CREATE TABLE IF NOT EXISTS group_carpool_link (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  group_trip_id BIGINT UNSIGNED NOT NULL,
  carpool_trip_id BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_group_carpool_link (group_trip_id, carpool_trip_id),
  KEY idx_group_carpool_group (group_trip_id),
  KEY idx_group_carpool_trip (carpool_trip_id),
  CONSTRAINT fk_group_carpool_group FOREIGN KEY (group_trip_id) REFERENCES group_trip(id),
  CONSTRAINT fk_group_carpool_trip FOREIGN KEY (carpool_trip_id) REFERENCES carpool_trip(id),
  CONSTRAINT fk_group_carpool_creator FOREIGN KEY (created_by) REFERENCES user_account(id)
) ENGINE=InnoDB;

-- 6) 旅游资源与商家
CREATE TABLE IF NOT EXISTS merchant (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  merchant_name VARCHAR(120) NOT NULL,
  merchant_type ENUM('scenic_spot','homestay','local_shop','travel_agency','other') NOT NULL DEFAULT 'other',
  contact_name VARCHAR(50) NOT NULL,
  contact_phone VARCHAR(20) NOT NULL,
  license_no VARCHAR(100) NULL,
  verify_status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  account_status ENUM('active','disabled') NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_merchant_license (license_no),
  KEY idx_merchant_status (verify_status, account_status)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS travel_resource (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  merchant_id BIGINT UNSIGNED NOT NULL,
  resource_name VARCHAR(120) NOT NULL,
  resource_type ENUM('ticket','hotel','experience','food') NOT NULL,
  destination VARCHAR(120) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  discount_price DECIMAL(10,2) NULL,
  stock INT UNSIGNED NOT NULL DEFAULT 0,
  sale_start_at DATETIME NULL,
  sale_end_at DATETIME NULL,
  status ENUM('online','offline') NOT NULL DEFAULT 'online',
  description TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_resource_merchant (merchant_id),
  KEY idx_resource_destination_type (destination, resource_type),
  KEY idx_resource_status (status),
  CONSTRAINT fk_resource_merchant FOREIGN KEY (merchant_id) REFERENCES merchant(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS resource_booking (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  booking_no VARCHAR(32) NOT NULL,
  resource_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  group_trip_id BIGINT UNSIGNED NULL,
  quantity INT UNSIGNED NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  booking_status ENUM('pending_pay','paid','used','cancelled','refunded') NOT NULL DEFAULT 'pending_pay',
  pay_status ENUM('unpaid','paid','refunding','refunded','failed') NOT NULL DEFAULT 'unpaid',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_booking_no (booking_no),
  KEY idx_booking_resource (resource_id),
  KEY idx_booking_user (user_id),
  KEY idx_booking_group (group_trip_id),
  KEY idx_booking_status (booking_status),
  CONSTRAINT fk_booking_resource FOREIGN KEY (resource_id) REFERENCES travel_resource(id),
  CONSTRAINT fk_booking_user FOREIGN KEY (user_id) REFERENCES user_account(id),
  CONSTRAINT fk_booking_group FOREIGN KEY (group_trip_id) REFERENCES group_trip(id)
) ENGINE=InnoDB;

-- 7) 支付、评价、纠纷、通知
CREATE TABLE IF NOT EXISTS payment_order (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  payment_no VARCHAR(32) NOT NULL,
  biz_type ENUM('carpool_order','group_signup','resource_booking') NOT NULL,
  biz_id BIGINT UNSIGNED NOT NULL,
  payer_user_id BIGINT UNSIGNED NOT NULL,
  pay_channel ENUM('wechat','alipay','campus_card','balance') NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  pay_status ENUM('created','paid','failed','closed','refunding','refunded') NOT NULL DEFAULT 'created',
  paid_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_payment_no (payment_no),
  KEY idx_payment_biz (biz_type, biz_id),
  KEY idx_payment_payer (payer_user_id),
  KEY idx_payment_status (pay_status),
  CONSTRAINT fk_payment_payer FOREIGN KEY (payer_user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_review (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  review_type ENUM('carpool','group_trip','resource') NOT NULL,
  biz_id BIGINT UNSIGNED NOT NULL,
  reviewer_user_id BIGINT UNSIGNED NOT NULL,
  target_user_id BIGINT UNSIGNED NULL,
  rating TINYINT UNSIGNED NOT NULL,
  punctuality_score TINYINT UNSIGNED NULL,
  communication_score TINYINT UNSIGNED NULL,
  safety_score TINYINT UNSIGNED NULL,
  content VARCHAR(500) NULL,
  is_anonymous TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  KEY idx_review_biz (review_type, biz_id),
  KEY idx_review_reviewer (reviewer_user_id),
  KEY idx_review_target (target_user_id),
  CONSTRAINT fk_review_reviewer FOREIGN KEY (reviewer_user_id) REFERENCES user_account(id),
  CONSTRAINT fk_review_target FOREIGN KEY (target_user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS dispute_ticket (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  ticket_no VARCHAR(32) NOT NULL,
  dispute_type ENUM('carpool_order','group_signup','resource_booking','other') NOT NULL,
  biz_id BIGINT UNSIGNED NULL,
  reporter_user_id BIGINT UNSIGNED NOT NULL,
  respondent_user_id BIGINT UNSIGNED NULL,
  title VARCHAR(120) NOT NULL,
  description TEXT NOT NULL,
  status ENUM('open','processing','resolved','closed') NOT NULL DEFAULT 'open',
  handler_user_id BIGINT UNSIGNED NULL,
  result_summary VARCHAR(500) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_dispute_ticket_no (ticket_no),
  KEY idx_dispute_type_biz (dispute_type, biz_id),
  KEY idx_dispute_reporter (reporter_user_id),
  KEY idx_dispute_status (status),
  CONSTRAINT fk_dispute_reporter FOREIGN KEY (reporter_user_id) REFERENCES user_account(id),
  CONSTRAINT fk_dispute_respondent FOREIGN KEY (respondent_user_id) REFERENCES user_account(id),
  CONSTRAINT fk_dispute_handler FOREIGN KEY (handler_user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_notification (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  notice_channel ENUM('in_app','sms','email','push') NOT NULL DEFAULT 'in_app',
  notice_type VARCHAR(40) NOT NULL,
  title VARCHAR(120) NOT NULL,
  content VARCHAR(1000) NOT NULL,
  related_type VARCHAR(40) NULL,
  related_id BIGINT UNSIGNED NULL,
  is_read TINYINT(1) NOT NULL DEFAULT 0,
  read_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_notice_user_read (user_id, is_read),
  KEY idx_notice_related (related_type, related_id),
  CONSTRAINT fk_notice_user FOREIGN KEY (user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

-- 8) 推荐与行为反馈
CREATE TABLE IF NOT EXISTS user_interest_tag (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  tag_name VARCHAR(40) NOT NULL,
  weight DECIMAL(6,3) NOT NULL DEFAULT 1.000,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_interest_tag (user_id, tag_name),
  KEY idx_interest_user (user_id),
  CONSTRAINT fk_interest_user FOREIGN KEY (user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS recommendation_feedback (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  scene_type ENUM('carpool','group_trip','resource') NOT NULL,
  target_id BIGINT UNSIGNED NOT NULL,
  action_type ENUM('impression','click','collect','join','hide','dislike') NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_reco_feedback_user_scene (user_id, scene_type),
  KEY idx_reco_feedback_target (scene_type, target_id),
  CONSTRAINT fk_reco_feedback_user FOREIGN KEY (user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

-- 9) 会话消息（拼车/约团）
CREATE TABLE IF NOT EXISTS chat_message (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  biz_type ENUM('carpool_order','group_trip') NOT NULL,
  biz_id BIGINT UNSIGNED NOT NULL,
  sender_user_id BIGINT UNSIGNED NOT NULL,
  message_type ENUM('text','image','location','system') NOT NULL DEFAULT 'text',
  message_body TEXT NULL,
  media_url VARCHAR(255) NULL,
  location_lng DECIMAL(10,6) NULL,
  location_lat DECIMAL(10,6) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  KEY idx_chat_biz_time (biz_type, biz_id, created_at),
  KEY idx_chat_sender_time (sender_user_id, created_at),
  CONSTRAINT fk_chat_sender FOREIGN KEY (sender_user_id) REFERENCES user_account(id)
) ENGINE=InnoDB;

-- 基础角色初始化
INSERT INTO role (role_code, role_name)
VALUES
('STUDENT', '学生用户'),
('DRIVER', '车主用户'),
('ORGANIZER', '约团组织者'),
('MERCHANT', '旅游服务商'),
('ADMIN', '平台管理员')
ON DUPLICATE KEY UPDATE role_name = VALUES(role_name);

-- 测试账号初始化（密码统一为: 123456）
INSERT INTO user_account (
  username, password_hash, real_name, gender, phone, email,
  school_name, campus_name, student_no, avatar_url,
  auth_status, account_status, credit_score
)
VALUES
('student01', '123456', '测试学生', 'unknown', '13900000001', 'student01@test.local', '示例大学', '主校区', '20260001', NULL, 'verified', 'active', 100),
('driver01', '123456', '测试车主', 'unknown', '13900000002', 'driver01@test.local', '示例大学', '东校区', '20260002', NULL, 'verified', 'active', 100),
('organizer01', '123456', '测试团长', 'unknown', '13900000003', 'organizer01@test.local', '示例大学', '西校区', '20260003', NULL, 'verified', 'active', 100),
('admin01', '123456', '系统管理员', 'unknown', '13900000004', 'admin01@test.local', '示例大学', '主校区', '20260004', NULL, 'verified', 'active', 100)
ON DUPLICATE KEY UPDATE
  password_hash = VALUES(password_hash),
  real_name = VALUES(real_name),
  auth_status = VALUES(auth_status),
  account_status = VALUES(account_status),
  updated_at = CURRENT_TIMESTAMP;

-- 测试账号角色绑定
INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
FROM user_account u
JOIN role r ON r.role_code = 'STUDENT'
WHERE u.username = 'student01'
ON DUPLICATE KEY UPDATE user_id = user_id;

INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
FROM user_account u
JOIN role r ON r.role_code = 'DRIVER'
WHERE u.username = 'driver01'
ON DUPLICATE KEY UPDATE user_id = user_id;

INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
FROM user_account u
JOIN role r ON r.role_code = 'ORGANIZER'
WHERE u.username = 'organizer01'
ON DUPLICATE KEY UPDATE user_id = user_id;

INSERT INTO user_role (user_id, role_id)
SELECT u.id, r.id
FROM user_account u
JOIN role r ON r.role_code = 'ADMIN'
WHERE u.username = 'admin01'
ON DUPLICATE KEY UPDATE user_id = user_id;

SET FOREIGN_KEY_CHECKS = 1;
