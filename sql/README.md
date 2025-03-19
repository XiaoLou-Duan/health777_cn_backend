# 数据库设计说明

本目录包含肌少症（肌护达）老年患者健康管理系统的数据库设计文件。

## 文件说明

- `00_init.sql` - 初始化数据库脚本
- `01_users.sql` - 用户认证模块相关表
- `02_nutrition.sql` - 营养管理模块相关表
- `03_exercise.sql` - 运动管理模块相关表
- `04_social.sql` - 激励与社交功能相关表
- `05_medical.sql` - 医患互动功能相关表
- `06_reminders.sql` - 智能提醒系统相关表

## 数据库结构概览

系统数据库设计遵循关系型数据库范式设计原则，主要包含以下核心模块：

### 1. 用户认证模块
- 用户基本信息表 (users)
- 用户详细信息表 (user_profiles)
- 用户设备表 (user_devices)
- 验证码表 (verification_codes)

### 2. 营养管理模块
- 食物项目表 (food_items)
- 用户餐食记录表 (meals)
- 餐食食物明细表 (meal_food_items)
- 营养摄入记录表 (nutrition_records)
- 乳清蛋白摄入记录表 (protein_supplements)
- 饮食建议表 (diet_recommendations)

### 3. 运动管理模块
- 运动视频资源表 (exercise_videos)
- 用户运动记录表 (exercise_records)
- 运动统计表 (exercise_statistics)
- 用户视频观看记录表 (video_watch_records)

### 4. 激励与社交功能
- 用户积分表 (user_points)
- 积分记录表 (point_records)
- 成就定义表 (achievements)
- 用户成就记录表 (user_achievements)
- 社区话题表 (topics)
- 社区帖子表 (posts)
- 帖子图片表 (post_images)
- 评论表 (comments)
- 点赞表 (likes)

### 5. 医患互动功能
- 医生信息表 (doctors)
- 医生账号表 (doctor_accounts)
- 用户-医生关系表 (user_doctor_relations)
- 消息表 (messages)
- 会话表 (conversations)
- 医生排班表 (doctor_schedules)
- 预约表 (appointments)

### 6. 智能提醒系统
- 提醒设置表 (reminder_settings)
- 免打扰时段表 (do_not_disturb)
- 任务表 (tasks)
- 任务完成记录表 (task_completions)
- 通知表 (notifications)
- 推送记录表 (push_records)

## 数据库初始化

要初始化数据库，请按照以下步骤操作：

1. 确保已安装MySQL数据库服务器
2. 使用MySQL客户端连接到数据库服务器
3. 执行以下命令：

```sql
SOURCE 00_init.sql;
```

或者依次执行以下命令：

```sql
CREATE DATABASE IF NOT EXISTS `health_goods` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `health_goods`;
SOURCE 01_users.sql;
SOURCE 02_nutrition.sql;
SOURCE 03_exercise.sql;
SOURCE 04_social.sql;
SOURCE 05_medical.sql;
SOURCE 06_reminders.sql;
```

## 表关系图

数据库表关系图请参考项目文档中的ER图部分。
