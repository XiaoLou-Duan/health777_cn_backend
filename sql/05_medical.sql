-- 医患互动功能相关表

-- 医生信息表
CREATE TABLE IF NOT EXISTS `doctors` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '医生ID',
  `name` VARCHAR(50) NOT NULL COMMENT '医生姓名',
  `title` VARCHAR(50) NOT NULL COMMENT '职称',
  `department` VARCHAR(50) NOT NULL COMMENT '科室',
  `hospital` VARCHAR(100) NOT NULL COMMENT '医院',
  `introduction` TEXT COMMENT '简介',
  `avatar_url` VARCHAR(255) COMMENT '头像URL',
  `phone` VARCHAR(20) COMMENT '联系电话',
  `email` VARCHAR(100) COMMENT '邮箱',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用, 1-正常',
  `online_status` TINYINT NOT NULL DEFAULT 0 COMMENT '在线状态: 0-离线, 1-在线',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_department` (`department`),
  KEY `idx_hospital` (`hospital`),
  KEY `idx_status` (`status`),
  KEY `idx_online_status` (`online_status`),
  KEY `idx_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='医生信息表';

-- 医生账号表
CREATE TABLE IF NOT EXISTS `doctor_accounts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '账号ID',
  `doctor_id` INT UNSIGNED NOT NULL COMMENT '医生ID',
  `username` VARCHAR(50) NOT NULL COMMENT '用户名',
  `password_hash` VARCHAR(128) NOT NULL COMMENT '密码哈希',
  `salt` VARCHAR(64) NOT NULL COMMENT '密码盐',
  `last_login_time` DATETIME COMMENT '最后登录时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_username` (`username`),
  UNIQUE KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_last_login_time` (`last_login_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='医生账号表';

-- 用户-医生关系表
CREATE TABLE IF NOT EXISTS `user_doctor_relations` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '关系ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `doctor_id` INT UNSIGNED NOT NULL COMMENT '医生ID',
  `relation_type` TINYINT NOT NULL COMMENT '关系类型: 1-主治医生, 2-咨询医生',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-解除, 1-正常',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_doctor` (`user_id`, `doctor_id`),
  KEY `idx_relation_type` (`relation_type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户-医生关系表';

-- 消息表
CREATE TABLE IF NOT EXISTS `messages` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '消息ID',
  `sender_id` INT UNSIGNED NOT NULL COMMENT '发送者ID',
  `sender_type` VARCHAR(10) NOT NULL COMMENT '发送者类型: user, doctor',
  `receiver_id` INT UNSIGNED NOT NULL COMMENT '接收者ID',
  `receiver_type` VARCHAR(10) NOT NULL COMMENT '接收者类型: user, doctor',
  `content` TEXT NOT NULL COMMENT '消息内容',
  `message_type` TINYINT NOT NULL COMMENT '消息类型: 1-文本, 2-图片, 3-语音, 4-视频',
  `media_url` VARCHAR(255) COMMENT '媒体URL',
  `media_duration` INT COMMENT '媒体时长(秒)',
  `is_read` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已读: 0-未读, 1-已读',
  `read_time` DATETIME COMMENT '阅读时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_sender` (`sender_id`, `sender_type`),
  KEY `idx_receiver` (`receiver_id`, `receiver_type`),
  KEY `idx_conversation` (`sender_id`, `sender_type`, `receiver_id`, `receiver_type`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_message_type` (`message_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息表';

-- 会话表
CREATE TABLE IF NOT EXISTS `conversations` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '会话ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `doctor_id` INT UNSIGNED NOT NULL COMMENT '医生ID',
  `last_message_id` INT UNSIGNED COMMENT '最后消息ID',
  `unread_count_user` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '用户未读数',
  `unread_count_doctor` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '医生未读数',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-关闭, 1-正常',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_doctor` (`user_id`, `doctor_id`),
  KEY `idx_last_message` (`last_message_id`),
  KEY `idx_status` (`status`),
  KEY `idx_updated_at` (`updated_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='会话表';

-- 医生排班表
CREATE TABLE IF NOT EXISTS `doctor_schedules` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '排班ID',
  `doctor_id` INT UNSIGNED NOT NULL COMMENT '医生ID',
  `schedule_date` DATE NOT NULL COMMENT '排班日期',
  `start_time` TIME NOT NULL COMMENT '开始时间',
  `end_time` TIME NOT NULL COMMENT '结束时间',
  `max_appointments` INT NOT NULL DEFAULT 10 COMMENT '最大预约数',
  `current_appointments` INT NOT NULL DEFAULT 0 COMMENT '当前预约数',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-取消, 1-正常',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_doctor_date` (`doctor_id`, `schedule_date`),
  KEY `idx_status` (`status`),
  KEY `idx_availability` (`current_appointments`, `max_appointments`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='医生排班表';

-- 预约表
CREATE TABLE IF NOT EXISTS `appointments` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '预约ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `doctor_id` INT UNSIGNED NOT NULL COMMENT '医生ID',
  `schedule_id` INT UNSIGNED NOT NULL COMMENT '排班ID',
  `appointment_date` DATE NOT NULL COMMENT '预约日期',
  `start_time` TIME NOT NULL COMMENT '开始时间',
  `end_time` TIME NOT NULL COMMENT '结束时间',
  `appointment_type` TINYINT NOT NULL COMMENT '预约类型: 1-线上咨询, 2-线下门诊',
  `description` TEXT COMMENT '预约描述',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态: 0-待确认, 1-已确认, 2-已完成, 3-已取消',
  `cancel_reason` VARCHAR(255) COMMENT '取消原因',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_doctor_id` (`doctor_id`),
  KEY `idx_schedule_id` (`schedule_id`),
  KEY `idx_date_status` (`appointment_date`, `status`),
  KEY `idx_appointment_type` (`appointment_type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='预约表';
