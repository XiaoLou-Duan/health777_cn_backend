-- 用户认证模块相关表

-- 用户基本信息表
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `phone` VARCHAR(20) NOT NULL COMMENT '手机号',
  `password_hash` VARCHAR(128) COMMENT '密码哈希',
  `salt` VARCHAR(64) COMMENT '密码盐',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '用户状态: 0-禁用, 1-正常',
  `last_login_time` DATETIME COMMENT '最后登录时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户基本信息表';

-- 用户详细信息表1
CREATE TABLE IF NOT EXISTS `user_profiles` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `name` VARCHAR(50) COMMENT '用户姓名',
  `gender` TINYINT COMMENT '性别: 0-未知, 1-男, 2-女',
  `birth_date` DATE COMMENT '出生日期',
  `height` DECIMAL(5,2) COMMENT '身高(cm)',
  `weight` DECIMAL(5,2) COMMENT '体重(kg)',
  `avatar_url` VARCHAR(255) COMMENT '头像URL',
  `health_condition` TEXT COMMENT '健康状况描述',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_id` (`user_id`),
  KEY `idx_gender` (`gender`),
  KEY `idx_birth_date` (`birth_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户详细信息表';

-- 用户设备表
CREATE TABLE IF NOT EXISTS `user_devices` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `device_token` VARCHAR(128) NOT NULL COMMENT '设备令牌',
  `device_type` VARCHAR(20) NOT NULL COMMENT '设备类型: ios, android',
  `device_model` VARCHAR(50) COMMENT '设备型号',
  `last_active_time` DATETIME COMMENT '最后活跃时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_device_token` (`device_token`),
  KEY `idx_device_type` (`device_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户设备表';

-- 验证码表
CREATE TABLE IF NOT EXISTS `verification_codes` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `phone` VARCHAR(20) NOT NULL COMMENT '手机号',
  `code` VARCHAR(10) NOT NULL COMMENT '验证码',
  `type` TINYINT NOT NULL COMMENT '类型: 1-注册, 2-登录, 3-修改密码, 4-修改手机号',
  `expire_time` DATETIME NOT NULL COMMENT '过期时间',
  `is_used` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已使用: 0-未使用, 1-已使用',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_phone_type` (`phone`, `type`),
  KEY `idx_expire_time` (`expire_time`),
  KEY `idx_is_used` (`is_used`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='验证码表';


-- 清空原有数据
TRUNCATE TABLE `users`;
TRUNCATE TABLE `user_profiles`;
TRUNCATE TABLE `user_devices`;
TRUNCATE TABLE `verification_codes`;

-- 用户基本信息表示例数据
INSERT INTO `users` (`phone`, `password_hash`, `salt`, `status`, `last_login_time`) VALUES
('13800138000', 'e10adc3949ba59abbe56e057f20f883e', 'abc123', 1, '2023-05-15 10:30:00'),
('13900139000', '25f9e794323b453885f5181f1b624d0b', 'def456', 1, '2023-05-16 11:45:00'),
('13700137000', '5f4dcc3b5aa765d61d8327deb882cf99', 'ghi789', 0, '2023-04-20 09:15:00');

-- 用户详细信息表示例数据(使用真实图片URL)
INSERT INTO `user_profiles` (`user_id`, `name`, `gender`, `birth_date`, `height`, `weight`, `avatar_url`, `health_condition`) VALUES
(1, '张三', 1, '1990-05-15', 175.50, 70.20, 'https://randomuser.me/api/portraits/men/32.jpg', '无特殊健康状况'),
(2, '李四', 2, '1988-08-20', 165.30, 55.80, 'https://randomuser.me/api/portraits/women/44.jpg', '轻度高血压'),
(3, '王五', 1, '1995-03-10', 180.00, 80.00, 'https://randomuser.me/api/portraits/men/75.jpg', '糖尿病');

-- 用户设备表示例数据
INSERT INTO `user_devices` (`user_id`, `device_token`, `device_type`, `device_model`, `last_active_time`) VALUES
(1, 'ios_token_123456', 'ios', 'iPhone 13', '2023-05-15 10:35:00'),
(1, 'android_token_654321', 'android', 'Xiaomi 12', '2023-05-14 18:20:00'),
(2, 'ios_token_789012', 'ios', 'iPhone 12', '2023-05-16 11:50:00');

-- 验证码表示例数据
INSERT INTO `verification_codes` (`phone`, `code`, `type`, `expire_time`, `is_used`) VALUES
('13800138000', '123456', 1, '2023-05-15 10:45:00', 1),
('13900139000', '654321', 2, '2023-05-16 12:00:00', 0),
('13700137000', '987654', 3, '2023-04-20 09:30:00', 1);