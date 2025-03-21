-- 营养管理模块相关表

-- 食物项目表
CREATE TABLE IF NOT EXISTS `food_items` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '食物ID',
  `name` VARCHAR(100) NOT NULL COMMENT '食物名称',
  `category` VARCHAR(50) NOT NULL COMMENT '食物类别',
  `protein_per_100g` DECIMAL(6,2) NOT NULL COMMENT '每100g蛋白质含量(g)',
  `calories_per_100g` DECIMAL(6,2) NOT NULL COMMENT '每100g热量(kcal)',
  `fat_per_100g` DECIMAL(6,2) COMMENT '每100g脂肪含量(g)',
  `carbs_per_100g` DECIMAL(6,2) COMMENT '每100g碳水化合物含量(g)',
  `fiber_per_100g` DECIMAL(6,2) COMMENT '每100g纤维含量(g)',
  `image_url` VARCHAR(255) COMMENT '食物图片URL',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`),
  KEY `idx_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='食物项目表';

-- 用户餐食记录表
CREATE TABLE IF NOT EXISTS `meals` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '餐食ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `meal_type` TINYINT NOT NULL COMMENT '餐食类型: 1-早餐, 2-午餐, 3-晚餐, 4-加餐',
  `meal_time` DATETIME NOT NULL COMMENT '用餐时间',
  `image_url` VARCHAR(255) COMMENT '餐食图片URL',
  `ai_recognized` TINYINT NOT NULL DEFAULT 0 COMMENT '是否AI识别: 0-否, 1-是',
  `total_protein` DECIMAL(6,2) COMMENT '总蛋白质含量(g)',
  `total_calories` DECIMAL(6,2) COMMENT '总热量(kcal)',
  `notes` TEXT COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id_meal_time` (`user_id`, `meal_time`),
  KEY `idx_meal_type` (`meal_type`),
  KEY `idx_ai_recognized` (`ai_recognized`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户餐食记录表';

-- 餐食食物明细表
CREATE TABLE IF NOT EXISTS `meal_food_items` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `meal_id` INT UNSIGNED NOT NULL COMMENT '餐食ID',
  `food_item_id` INT UNSIGNED COMMENT '食物ID',
  `food_name` VARCHAR(100) NOT NULL COMMENT '食物名称',
  `quantity` DECIMAL(6,2) NOT NULL COMMENT '食用量(g)',
  `protein` DECIMAL(6,2) NOT NULL COMMENT '蛋白质含量(g)',
  `calories` DECIMAL(6,2) NOT NULL COMMENT '热量(kcal)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_meal_id` (`meal_id`),
  KEY `idx_food_item_id` (`food_item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='餐食食物明细表';

-- 营养摄入记录表
CREATE TABLE IF NOT EXISTS `nutrition_records` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `record_date` DATE NOT NULL COMMENT '记录日期',
  `total_protein` DECIMAL(6,2) NOT NULL DEFAULT 0 COMMENT '总蛋白质摄入量(g)',
  `total_calories` DECIMAL(6,2) NOT NULL DEFAULT 0 COMMENT '总热量摄入量(kcal)',
  `protein_target` DECIMAL(6,2) NOT NULL COMMENT '蛋白质目标摄入量(g)',
  `calories_target` DECIMAL(6,2) NOT NULL COMMENT '热量目标摄入量(kcal)',
  `achievement_rate` DECIMAL(5,2) NOT NULL DEFAULT 0 COMMENT '达标率(%)',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_user_date` (`user_id`, `record_date`),
  KEY `idx_achievement_rate` (`achievement_rate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='营养摄入记录表';

-- 乳清蛋白摄入记录表
CREATE TABLE IF NOT EXISTS `protein_supplements` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '记录ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `supplement_time` DATETIME NOT NULL COMMENT '摄入时间',
  `supplement_type` VARCHAR(50) NOT NULL COMMENT '补充剂类型',
  `protein_amount` DECIMAL(6,2) NOT NULL COMMENT '蛋白质含量(g)',
  `image_url` VARCHAR(255) COMMENT '图片URL',
  `notes` TEXT COMMENT '备注',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id_time` (`user_id`, `supplement_time`),
  KEY `idx_supplement_type` (`supplement_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='乳清蛋白摄入记录表';

-- 饮食建议表
CREATE TABLE IF NOT EXISTS `diet_recommendations` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '建议ID',
  `user_id` INT UNSIGNED NOT NULL COMMENT '用户ID',
  `recommendation_date` DATE NOT NULL COMMENT '建议日期',
  `protein_gap` DECIMAL(6,2) NOT NULL COMMENT '蛋白质缺口(g)',
  `recommendation_content` TEXT NOT NULL COMMENT '建议内容',
  `is_read` TINYINT NOT NULL DEFAULT 0 COMMENT '是否已读: 0-未读, 1-已读',
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id_date` (`user_id`, `recommendation_date`),
  KEY `idx_is_read` (`is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='饮食建议表';
