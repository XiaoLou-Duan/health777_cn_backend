-- 智能提醒系统相关表

-- 提醒设置表
CREATE TABLE IF NOT EXISTS `reminder_settings` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '设置ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `reminder_type` VARCHAR(50) NOT NULL COMMENT '提醒类型: meal, exercise, protein, appointment',
  `is_enabled` TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用: 0-禁用, 1-启用',
  `reminder_time` TIME COMMENT '提醒时间',
  `repeat_days` VARCHAR(20) COMMENT '重复日期(1-7表示周一到周日，逗号分隔)',
  `reminder_sound` VARCHAR(50) COMMENT '提醒声音',
  `vibration` TINYINT NOT NULL DEFAULT 1 COMMENT '是否震动: 0-否, 1-是',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_type` (`user_id`, `reminder_type`),
  KEY `idx_is_enabled` (`is_enabled`),
  KEY `idx_reminder_time` (`reminder_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='提醒设置表';

-- 免打扰时段表
CREATE TABLE IF NOT EXISTS `do_not_disturb` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `start_time` TIME NOT NULL COMMENT '开始时间',
  `end_time` TIME NOT NULL COMMENT '结束时间',
  `is_enabled` TINYINT NOT NULL DEFAULT 1 COMMENT '是否启用: 0-禁用, 1-启用',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_is_enabled` (`is_enabled`),
  KEY `idx_time_range` (`start_time`, `end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='免打扰时段表';

-- 任务表
CREATE TABLE IF NOT EXISTS `tasks` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '任务ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `task_type` VARCHAR(50) NOT NULL COMMENT '任务类型: meal_record, exercise, protein_intake, social',
  `task_name` VARCHAR(100) NOT NULL COMMENT '任务名称',
  `description` TEXT COMMENT '任务描述',
  `points` INT NOT NULL DEFAULT 0 COMMENT '完成奖励积分',
  `start_date` DATE NOT NULL COMMENT '开始日期',
  `end_date` DATE COMMENT '结束日期',
  `is_recurring` TINYINT NOT NULL DEFAULT 0 COMMENT '是否循环: 0-否, 1-是',
  `recurrence_pattern` VARCHAR(50) COMMENT '循环模式: daily, weekly, monthly',
  `status` TINYINT NOT NULL DEFAULT 0 COMMENT '状态: 0-未完成, 1-已完成, 2-已过期',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_task_type` (`task_type`),
  KEY `idx_status` (`status`),
  KEY `idx_date_range` (`start_date`, `end_date`),
  KEY `idx_is_recurring` (`is_recurring`),
  KEY `idx_points` (`points`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务表';

-- 任务完成记录表
CREATE TABLE IF NOT EXISTS `task_completions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `task_id` INT UNSIGNED NOT NULL COMMENT '任务ID',
  `completion_date` DATE NOT NULL COMMENT '完成日期',
  `completion_time` TIME NOT NULL COMMENT '完成时间',
  `points_earned` INT NOT NULL DEFAULT 0 COMMENT '获得积分',
  `notes` TEXT COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_task_id` (`task_id`),
  KEY `idx_completion_date` (`completion_date`),
  KEY `idx_points_earned` (`points_earned`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务完成记录表';

-- 通知表
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '通知ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `title` VARCHAR(100) NOT NULL COMMENT '通知标题',
  `content` TEXT NOT NULL COMMENT '通知内容',
  `notification_type` VARCHAR(50) NOT NULL COMMENT '通知类型: reminder, achievement, task, system',
  `reference_id` INT UNSIGNED COMMENT '关联ID',
  `reference_type` VARCHAR(50) COMMENT '关联类型',
  `is_read` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已读: 0-未读, 1-已读',
  `read_time` DATETIME COMMENT '阅读时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_type` (`notification_type`),
  KEY `idx_is_read` (`is_read`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_reference` (`reference_id`, `reference_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='通知表';

-- 推送记录表
CREATE TABLE IF NOT EXISTS `push_records` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `notification_id` INT UNSIGNED COMMENT '通知ID',
  `device_token` VARCHAR(128) NOT NULL COMMENT '设备令牌',
  `push_type` VARCHAR(50) NOT NULL COMMENT '推送类型',
  `push_time` DATETIME NOT NULL COMMENT '推送时间',
  `status` TINYINT NOT NULL COMMENT '状态: 0-失败, 1-成功',
  `error_message` TEXT COMMENT '错误信息',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_notification_id` (`notification_id`),
  KEY `idx_push_time` (`push_time`),
  KEY `idx_status` (`status`),
  KEY `idx_device_token` (`device_token`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='推送记录表';
