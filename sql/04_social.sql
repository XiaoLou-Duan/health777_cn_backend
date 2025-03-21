-- 激励与社交功能相关表

-- 用户积分表
CREATE TABLE IF NOT EXISTS `user_points` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `total_points` INT NOT NULL DEFAULT 0 COMMENT '总积分',
  `available_points` INT NOT NULL DEFAULT 0 COMMENT '可用积分',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户积分表';

-- 积分记录表
CREATE TABLE IF NOT EXISTS `point_records` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `points` INT NOT NULL COMMENT '积分变动',
  `record_type` TINYINT NOT NULL COMMENT '记录类型: 1-饮食记录, 2-运动完成, 3-乳清蛋白摄入, 4-社区活动, 5-其他',
  `description` VARCHAR(255) NOT NULL COMMENT '描述',
  `reference_id` INT UNSIGNED COMMENT '关联ID',
  `reference_type` VARCHAR(50) COMMENT '关联类型',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_record_type` (`record_type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='积分记录表';

-- 成就定义表
CREATE TABLE IF NOT EXISTS `achievements` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '成就ID',
  `name` VARCHAR(100) NOT NULL COMMENT '成就名称',
  `description` TEXT NOT NULL COMMENT '成就描述',
  `category` VARCHAR(50) NOT NULL COMMENT '成就类别',
  `level` TINYINT NOT NULL COMMENT '成就等级',
  `points` INT NOT NULL DEFAULT 0 COMMENT '奖励积分',
  `icon_url` VARCHAR(255) COMMENT '图标URL',
  `requirements` TEXT NOT NULL COMMENT '达成条件',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_category_level` (`category`, `level`),
  KEY `idx_points` (`points`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='成就定义表';

-- 用户成就记录表
CREATE TABLE IF NOT EXISTS `user_achievements` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `achievement_id` INT UNSIGNED NOT NULL COMMENT '成就ID',
  `achieved_at` DATETIME NOT NULL COMMENT '达成时间',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_achievement` (`user_id`, `achievement_id`),
  KEY `idx_achieved_at` (`achieved_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户成就记录表';

-- 社区话题表
CREATE TABLE IF NOT EXISTS `topics` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '话题ID',
  `name` VARCHAR(50) NOT NULL COMMENT '话题名称',
  `description` TEXT COMMENT '话题描述',
  `icon_url` VARCHAR(255) COMMENT '图标URL',
  `post_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '帖子数量',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-禁用, 1-正常',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`),
  KEY `idx_status` (`status`),
  KEY `idx_post_count` (`post_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社区话题表';

-- 社区帖子表
CREATE TABLE IF NOT EXISTS `posts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '帖子ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `topic_id` INT UNSIGNED COMMENT '话题ID',
  `title` VARCHAR(100) NOT NULL COMMENT '标题',
  `content` TEXT NOT NULL COMMENT '内容',
  `view_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '浏览次数',
  `like_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '点赞次数',
  `comment_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '评论次数',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-删除, 1-正常, 2-置顶',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_topic_id` (`topic_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`),
  KEY `idx_view_count` (`view_count`),
  KEY `idx_like_count` (`like_count`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='社区帖子表';

-- 帖子图片表
CREATE TABLE IF NOT EXISTS `post_images` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '图片ID',
  `post_id` INT UNSIGNED NOT NULL COMMENT '帖子ID',
  `image_url` VARCHAR(255) NOT NULL COMMENT '图片URL',
  `sort_order` INT NOT NULL DEFAULT 0 COMMENT '排序顺序',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_sort_order` (`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='帖子图片表';

-- 评论表
CREATE TABLE IF NOT EXISTS `comments` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '评论ID',
  `post_id` INT UNSIGNED NOT NULL COMMENT '帖子ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `parent_id` INT UNSIGNED COMMENT '父评论ID',
  `content` TEXT NOT NULL COMMENT '评论内容',
  `like_count` INT UNSIGNED NOT NULL DEFAULT 0 COMMENT '点赞次数',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态: 0-删除, 1-正常',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_post_id` (`post_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_parent_id` (`parent_id`),
  KEY `idx_status` (`status`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='评论表';

-- 点赞表
CREATE TABLE IF NOT EXISTS `likes` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '点赞ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `target_id` INT UNSIGNED NOT NULL COMMENT '目标ID',
  `target_type` VARCHAR(20) NOT NULL COMMENT '目标类型: post, comment',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_target` (`user_id`, `target_id`, `target_type`),
  KEY `idx_target_id_type` (`target_id`, `target_type`),
  KEY `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='点赞表';
