-- 运动管理模块相关表

-- 运动视频资源表
CREATE TABLE IF NOT EXISTS `exercise_videos` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '视频ID',
  `title` VARCHAR(100) NOT NULL COMMENT '视频标题',
  `description` TEXT COMMENT '视频描述',
  `difficulty_level` TINYINT NOT NULL COMMENT '难度级别: 1-初级, 2-中级, 3-高级',
  `duration` INT NOT NULL COMMENT '视频时长(秒)',
  `video_url` VARCHAR(255) NOT NULL COMMENT '视频URL',
  `thumbnail_url` VARCHAR(255) COMMENT '缩略图URL',
  `category` VARCHAR(50) NOT NULL COMMENT '分类',
  `tags` VARCHAR(255) COMMENT '标签',
  `view_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '观看次数',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_difficulty` (`difficulty_level`),
  KEY `idx_category` (`category`),
  KEY `idx_view_count` (`view_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='运动视频资源表';

-- 用户运动记录表
CREATE TABLE IF NOT EXISTS `exercise_records` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `exercise_date` DATE NOT NULL COMMENT '运动日期',
  `exercise_type` VARCHAR(50) NOT NULL COMMENT '运动类型',
  `start_time` DATETIME NOT NULL COMMENT '开始时间',
  `end_time` DATETIME NOT NULL COMMENT '结束时间',
  `duration` INT NOT NULL COMMENT '运动时长(秒)',
  `video_id` INT UNSIGNED COMMENT '关联视频ID',
  `completion_rate` DECIMAL(5,2) COMMENT '完成率(%)',
  `notes` TEXT COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id_date` (`user_id`, `exercise_date`),
  KEY `idx_video_id` (`video_id`),
  KEY `idx_exercise_type` (`exercise_type`),
  KEY `idx_completion_rate` (`completion_rate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户运动记录表';

-- 运动统计表
CREATE TABLE IF NOT EXISTS `exercise_statistics` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '统计ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `statistic_date` DATE NOT NULL COMMENT '统计日期',
  `statistic_type` VARCHAR(20) NOT NULL COMMENT '统计类型: daily, weekly, monthly',
  `total_duration` INT NOT NULL DEFAULT 0 COMMENT '总运动时长(秒)',
  `exercise_days` INT NOT NULL DEFAULT 0 COMMENT '运动天数',
  `target_duration` INT NOT NULL COMMENT '目标时长(秒)',
  `achievement_rate` DECIMAL(5,2) NOT NULL DEFAULT 0 COMMENT '达标率(%)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_date_type` (`user_id`, `statistic_date`, `statistic_type`),
  KEY `idx_achievement_rate` (`achievement_rate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='运动统计表';

-- 用户视频观看记录表
CREATE TABLE IF NOT EXISTS `video_watch_records` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `video_id` INT UNSIGNED NOT NULL COMMENT '视频ID',
  `watch_date` DATE NOT NULL COMMENT '观看日期',
  `watch_duration` INT NOT NULL COMMENT '观看时长(秒)',
  `completion_rate` DECIMAL(5,2) NOT NULL COMMENT '完成率(%)',
  `last_position` INT NOT NULL DEFAULT 0 COMMENT '上次观看位置(秒)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_video` (`user_id`, `video_id`),
  KEY `idx_watch_date` (`watch_date`),
  KEY `idx_completion_rate` (`completion_rate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户视频观看记录表';
