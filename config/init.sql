-- =============================================
-- go-admin 系统数据库初始化脚本
-- MySQL 版本
-- =============================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =============================================
-- 1. sys_user 用户表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_user` (
  `user_id` int NOT NULL AUTO_INCREMENT COMMENT '编码',
  `username` varchar(64) DEFAULT NULL COMMENT '用户名',
  `password` varchar(128) DEFAULT NULL COMMENT '密码',
  `nick_name` varchar(128) DEFAULT NULL COMMENT '昵称',
  `phone` varchar(11) DEFAULT NULL COMMENT '手机号',
  `role_id` bigint DEFAULT NULL COMMENT '角色ID',
  `salt` varchar(255) DEFAULT NULL COMMENT '加盐',
  `avatar` varchar(255) DEFAULT NULL COMMENT '头像',
  `sex` varchar(255) DEFAULT NULL COMMENT '性别',
  `email` varchar(128) DEFAULT NULL COMMENT '邮箱',
  `dept_id` bigint DEFAULT NULL COMMENT '部门',
  `post_id` bigint DEFAULT NULL COMMENT '岗位',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `status` varchar(4) DEFAULT NULL COMMENT '状态',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';

-- =============================================
-- 2. sys_role 角色表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_role` (
  `role_id` int NOT NULL AUTO_INCREMENT COMMENT '角色编码',
  `role_name` varchar(128) DEFAULT NULL COMMENT '角色名称',
  `status` varchar(4) DEFAULT NULL,
  `role_key` varchar(128) DEFAULT NULL COMMENT '角色代码',
  `role_sort` int DEFAULT NULL COMMENT '角色排序',
  `flag` varchar(128) DEFAULT NULL,
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `admin` varchar(4) DEFAULT NULL,
  `data_scope` varchar(128) DEFAULT NULL,
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色表';

-- =============================================
-- 3. sys_menu 菜单表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_menu` (
  `menu_id` int NOT NULL AUTO_INCREMENT COMMENT '菜单编码',
  `menu_name` varchar(128) DEFAULT NULL COMMENT '菜单名称',
  `title` varchar(128) DEFAULT NULL COMMENT '标题',
  `icon` varchar(128) DEFAULT NULL COMMENT '图标',
  `path` varchar(128) DEFAULT NULL COMMENT '路径',
  `paths` varchar(128) DEFAULT NULL COMMENT '路径全路径',
  `menu_type` varchar(1) DEFAULT NULL COMMENT '菜单类型',
  `action` varchar(16) DEFAULT NULL COMMENT '动作',
  `permission` varchar(255) DEFAULT NULL COMMENT '权限标识',
  `parent_id` int DEFAULT NULL COMMENT '上级菜单',
  `no_cache` varchar(8) DEFAULT NULL COMMENT '是否缓存',
  `breadcrumb` varchar(255) DEFAULT NULL COMMENT '面包屑',
  `component` varchar(255) DEFAULT NULL COMMENT '组件路径',
  `sort` int DEFAULT NULL COMMENT '排序',
  `visible` varchar(1) DEFAULT NULL COMMENT '是否可见',
  `is_frame` varchar(1) DEFAULT '0' COMMENT '是否外部链接',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单表';

-- =============================================
-- 4. sys_dept 部门表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_dept` (
  `dept_id` int NOT NULL AUTO_INCREMENT COMMENT '部门编码',
  `parent_id` int DEFAULT NULL COMMENT '上级部门',
  `dept_path` varchar(255) DEFAULT NULL COMMENT '部门路径',
  `dept_name` varchar(128) DEFAULT NULL COMMENT '部门名称',
  `sort` int DEFAULT NULL COMMENT '排序',
  `leader` varchar(128) DEFAULT NULL COMMENT '负责人',
  `phone` varchar(11) DEFAULT NULL COMMENT '手机',
  `email` varchar(64) DEFAULT NULL COMMENT '邮箱',
  `status` int DEFAULT NULL COMMENT '状态',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='部门表';

-- =============================================
-- 5. sys_api 接口表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_api` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键编码',
  `handle` varchar(128) DEFAULT NULL COMMENT 'handle',
  `title` varchar(128) DEFAULT NULL COMMENT '标题',
  `path` varchar(128) DEFAULT NULL COMMENT '地址',
  `type` varchar(16) DEFAULT NULL COMMENT '接口类型',
  `action` varchar(16) DEFAULT NULL COMMENT '请求类型',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='接口表';

-- =============================================
-- 6. sys_config 参数配置表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_config` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `config_name` varchar(128) DEFAULT NULL COMMENT '配置名称',
  `config_key` varchar(128) DEFAULT NULL COMMENT '配置键',
  `config_value` varchar(255) DEFAULT NULL COMMENT '配置值',
  `config_type` varchar(64) DEFAULT NULL COMMENT '配置类型',
  `is_frontend` varchar(64) DEFAULT NULL COMMENT '是否前台',
  `remark` varchar(128) DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='参数配置表';

-- =============================================
-- 7. sys_dict_type 字典类型表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_dict_type` (
  `dict_id` int NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_name` varchar(128) DEFAULT NULL COMMENT '字典名称',
  `dict_type` varchar(128) DEFAULT NULL COMMENT '字典类型',
  `status` int DEFAULT NULL COMMENT '状态',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`dict_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典类型表';

-- =============================================
-- 8. sys_dict_data 字典数据表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_dict_data` (
  `dict_code` int NOT NULL AUTO_INCREMENT COMMENT '字典编码',
  `dict_sort` int DEFAULT NULL COMMENT '排序',
  `dict_label` varchar(128) DEFAULT NULL COMMENT '字典标签',
  `dict_value` varchar(128) DEFAULT NULL COMMENT '字典值',
  `dict_type` varchar(128) DEFAULT NULL COMMENT '字典类型',
  `css_class` varchar(128) DEFAULT NULL COMMENT '样式类',
  `list_class` varchar(128) DEFAULT NULL COMMENT '列表类',
  `is_default` varchar(4) DEFAULT NULL COMMENT '是否默认',
  `status` int DEFAULT NULL COMMENT '状态',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`dict_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='字典数据表';

-- =============================================
-- 9. sys_post 岗位表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_post` (
  `post_id` int NOT NULL AUTO_INCREMENT COMMENT '岗位编码',
  `post_code` varchar(128) DEFAULT NULL COMMENT '岗位代码',
  `post_name` varchar(128) DEFAULT NULL COMMENT '岗位名称',
  `post_sort` int DEFAULT NULL COMMENT '排序',
  `status` int DEFAULT NULL COMMENT '状态',
  `remark` varchar(255) DEFAULT NULL COMMENT '备注',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='岗位表';

-- =============================================
-- 10. sys_login_log 登录日志表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_login_log` (
  `info_id` int NOT NULL AUTO_INCREMENT COMMENT '日志编码',
  `user_name` varchar(128) DEFAULT NULL COMMENT '用户名',
  `status` varchar(4) DEFAULT NULL COMMENT '登录状态',
  `ipaddr` varchar(128) DEFAULT NULL COMMENT '登录IP',
  `login_location` varchar(255) DEFAULT NULL COMMENT '登录地点',
  `browser` varchar(128) DEFAULT NULL COMMENT '浏览器',
  `os` varchar(128) DEFAULT NULL COMMENT '操作系统',
  `msg` varchar(255) DEFAULT NULL COMMENT '提示信息',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`info_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='登录日志表';

-- =============================================
-- 11. sys_opera_log 操作日志表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_opera_log` (
  `opera_id` int NOT NULL AUTO_INCREMENT COMMENT '日志编码',
  `title` varchar(128) DEFAULT NULL COMMENT '操作标题',
  `business_type` int DEFAULT NULL COMMENT '业务类型',
  `method` varchar(255) DEFAULT NULL COMMENT '方法名称',
  `request_method` varchar(16) DEFAULT NULL COMMENT '请求方式',
  `operator_type` int DEFAULT NULL COMMENT '操作人类型',
  `operator_name` varchar(128) DEFAULT NULL COMMENT '操作人',
  `dept_name` varchar(128) DEFAULT NULL COMMENT '部门名称',
  `oper_url` varchar(255) DEFAULT NULL COMMENT '请求URL',
  `oper_ip` varchar(128) DEFAULT NULL COMMENT '操作IP',
  `oper_location` varchar(255) DEFAULT NULL COMMENT '操作地点',
  `oper_param` text COMMENT '操作参数',
  `json_result` text COMMENT '返回结果',
  `status` int DEFAULT NULL COMMENT '状态',
  `error_msg` varchar(255) DEFAULT NULL COMMENT '错误信息',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`opera_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';

-- =============================================
-- 12. sys_job 定时任务表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_job` (
  `job_id` int NOT NULL AUTO_INCREMENT COMMENT '任务编码',
  `job_name` varchar(128) DEFAULT NULL COMMENT '任务名称',
  `job_group` varchar(128) DEFAULT NULL COMMENT '任务分组',
  `job_type` int DEFAULT NULL COMMENT '任务类型',
  `cron_expression` varchar(128) DEFAULT NULL COMMENT 'Cron表达式',
  `invoke_target` varchar(255) DEFAULT NULL COMMENT '调用目标',
  `job_args` varchar(255) DEFAULT NULL COMMENT '参数',
  `status` int DEFAULT NULL COMMENT '状态',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  `is_sync` int DEFAULT NULL COMMENT '是否同步',
  `sort` int DEFAULT NULL COMMENT '排序',
  PRIMARY KEY (`job_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='定时任务表';

-- =============================================
-- 13. sys_role_menu 角色菜单关联表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_role_menu` (
  `role_id` int NOT NULL COMMENT '角色编码',
  `menu_id` int NOT NULL COMMENT '菜单编码',
  PRIMARY KEY (`role_id`,`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色菜单关联表';

-- =============================================
-- 14. sys_menu_api_rule 菜单接口关联表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_menu_api_rule` (
  `menu_id` int NOT NULL COMMENT '菜单编码',
  `api_id` int NOT NULL COMMENT '接口编码',
  PRIMARY KEY (`menu_id`,`api_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='菜单接口关联表';

-- =============================================
-- 15. sys_role_dept 角色部门关联表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_role_dept` (
  `role_id` int NOT NULL COMMENT '角色编码',
  `dept_id` int NOT NULL COMMENT '部门编码',
  PRIMARY KEY (`role_id`,`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色部门关联表';

-- =============================================
-- 16. sys_casbin_rule CASBIN规则表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_casbin_rule` (
  `id` int NOT NULL AUTO_INCREMENT COMMENT '主键',
  `ptype` varchar(512) DEFAULT NULL COMMENT '策略类型',
  `v0` varchar(512) DEFAULT NULL COMMENT '参数0',
  `v1` varchar(512) DEFAULT NULL COMMENT '参数1',
  `v2` varchar(512) DEFAULT NULL COMMENT '参数2',
  `v3` varchar(512) DEFAULT NULL COMMENT '参数3',
  `v4` varchar(512) DEFAULT NULL COMMENT '参数4',
  `v5` varchar(512) DEFAULT NULL COMMENT '参数5',
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_index` (`ptype`,`v0`,`v1`,`v2`,`v3`,`v4`,`v5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='CASBIN规则表';

-- =============================================
-- 17. sys_tables 代码生成表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_tables` (
  `table_id` int NOT NULL AUTO_INCREMENT COMMENT '编码',
  `table_name` varchar(128) DEFAULT NULL COMMENT '表名',
  `table_comment` varchar(255) DEFAULT NULL COMMENT '表注释',
  `sub_table_name` varchar(128) DEFAULT NULL COMMENT '子表名',
  `sub_table_fk_name` varchar(128) DEFAULT NULL COMMENT '子表外键',
  `is_logic_delete` int DEFAULT NULL COMMENT '是否逻辑删除',
  `is_autofill` int DEFAULT NULL COMMENT '是否自动填充',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`table_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代码生成表';

-- =============================================
-- 18. sys_columns 代码生成列信息表
-- =============================================
CREATE TABLE IF NOT EXISTS `sys_columns` (
  `column_id` int NOT NULL AUTO_INCREMENT COMMENT '编码',
  `table_id` int DEFAULT NULL COMMENT '表编码',
  `column_name` varchar(128) DEFAULT NULL COMMENT '列名',
  `column_comment` varchar(255) DEFAULT NULL COMMENT '列注释',
  `column_type` varchar(128) DEFAULT NULL COMMENT '列类型',
  `java_type` varchar(128) DEFAULT NULL COMMENT 'Java类型',
  `java_field` varchar(128) DEFAULT NULL COMMENT 'Java字段名',
  `is_pk` int DEFAULT NULL COMMENT '是否主键',
  `is_increment` int DEFAULT NULL COMMENT '是否自增',
  `is_required` int DEFAULT NULL COMMENT '是否必填',
  `is_insert` int DEFAULT NULL COMMENT '是否插入',
  `is_edit` int DEFAULT NULL COMMENT '是否编辑',
  `is_list` int DEFAULT NULL COMMENT '是否列表',
  `is_query` int DEFAULT NULL COMMENT '是否查询',
  `query_type` varchar(128) DEFAULT NULL COMMENT '查询类型',
  `html_type` varchar(128) DEFAULT NULL COMMENT 'HTML类型',
  `dict_type` varchar(128) DEFAULT NULL COMMENT '字典类型',
  `sort` int DEFAULT NULL COMMENT '排序',
  `create_by` varchar(64) DEFAULT NULL COMMENT '创建人',
  `update_by` varchar(64) DEFAULT NULL COMMENT '更新人',
  `created_at` datetime DEFAULT NULL COMMENT '创建时间',
  `updated_at` datetime DEFAULT NULL COMMENT '更新时间',
  `deleted_at` datetime DEFAULT NULL COMMENT '删除时间',
  PRIMARY KEY (`column_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='代码生成列信息表';

SET FOREIGN_KEY_CHECKS = 1;

-- =============================================
-- 初始化数据
-- =============================================

-- 初始化用户数据（密码为123456经过bcrypt加密）
INSERT INTO sys_user VALUES (1, 'admin', '$2a$10$N9qo8uLOickgx2ZMRZoMye.IjzqAKL9xL5jvMFVdNJHvGCgTq/VEq', '超级管理员', '13800138000', 1, '', '', '0', 'admin@go-admin.com', 1, 1, '超级管理员', '2', 'admin', 'admin', '2021-05-13 19:56:37', '2021-06-17 20:31:14', NULL);

-- 初始化角色数据
INSERT INTO sys_role VALUES (1, '超级管理员', '2', 'admin', 1, '', '', 1, '1', NULL, 'admin', 'admin', '2021-05-13 19:56:37', '2021-06-17 11:48:40', NULL);

-- 初始化部门数据
INSERT INTO sys_dept VALUES (1, 0, '/0/1/', '爱拓科技', 0, 'aituo', '13782218188', 'atuo@aituo.com', 2, 'admin', 'admin', '2021-05-13 19:56:37', '2021-06-05 17:06:44', NULL);

-- 初始化配置数据
INSERT INTO sys_config VALUES (1, '皮肤样式', 'sys_index_skinName', 'skin-green', 'Y', 0, '主框架页-默认皮肤样式名称', 1, 'admin', 'admin', '2021-05-13 19:56:37', '2021-06-05 13:50:13', NULL);
INSERT INTO sys_config VALUES (2, '初始密码', 'sys_user_initPassword', '123456', 'Y', 0, '用户管理-账号初始密码', 1, 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_config VALUES (3, '侧栏主题', 'sys_index_sideTheme', 'theme-dark', 'Y', 0, '主框架页-侧边栏主题', 1, 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_config VALUES (4, '系统名称', 'sys_app_name', 'go-admin管理系统', 'Y', 1, '', 1, 'admin', 'admin', '2021-03-17 08:52:06', '2021-05-28 10:08:25', NULL);
INSERT INTO sys_config VALUES (5, '系统logo', 'sys_app_logo', 'https://doc-image.zhangwj.com/img/go-admin.png', 'Y', 1, '', 1, 'admin', 'admin', '2021-03-17 08:53:19', '2021-03-17 08:53:19', NULL);

-- 初始化字典类型数据
INSERT INTO sys_dict_type VALUES (1, '系统开关', 'sys_normal_disable', 2, '系统开关列表', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_type VALUES (2, '用户性别', 'sys_user_sex', 2, '用户性别列表', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_type VALUES (3, '菜单状态', 'sys_show_hide', 2, '菜单状态列表', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_type VALUES (4, '系统是否', 'sys_yes_no', 2, '系统是否列表', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_type VALUES (5, '任务状态', 'sys_job_status', 2, '任务状态列表', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_type VALUES (6, '任务分组', 'sys_job_group', 2, '任务分组列表', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);

-- 初始化字典数据
INSERT INTO sys_dict_data VALUES (1, 0, '正常', '2', 'sys_normal_disable', '', '', '2', 2, '系统正常', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:40', NULL);
INSERT INTO sys_dict_data VALUES (2, 0, '停用', '1', 'sys_normal_disable', '', '', '2', 2, '系统停用', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_data VALUES (3, 0, '男', '0', 'sys_user_sex', '', '', '2', 2, '性别男', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_data VALUES (4, 0, '女', '1', 'sys_user_sex', '', '', '2', 2, '性别女', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_data VALUES (5, 0, '未知', '2', 'sys_user_sex', '', '', '2', 2, '性别未知', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_data VALUES (6, 0, '显示', '0', 'sys_show_hide', '', '', '2', 2, '显示菜单', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_data VALUES (7, 0, '隐藏', '1', 'sys_show_hide', '', '', '2', 2, '隐藏菜单', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_data VALUES (8, 0, '是', 'Y', 'sys_yes_no', '', '', '2', 2, '系统默认是', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);
INSERT INTO sys_dict_data VALUES (9, 0, '否', 'N', 'sys_yes_no', '', '', '2', 2, '系统默认否', 'admin', 'admin', '2021-05-13 19:56:37', '2021-05-13 19:56:37', NULL);

-- 初始化菜单数据
INSERT INTO sys_menu VALUES (1, 'Dashboard', '首页', 'dashboard', '/', '/0/1', 'C', '', '', 0, false, '', '/dashboard/index', 0, '0', '1', 0, 1, '2021-05-13 19:56:37', '2021-06-17 11:48:40', NULL);
INSERT INTO sys_menu VALUES (2, 'Admin', '系统管理', 'api-server', '/admin', '/0/2', 'M', '', '', 0, true, '', 'Layout', 10, '0', '1', 0, 1, '2021-05-20 21:58:45', '2021-06-17 11:48:40', NULL);
INSERT INTO sys_menu VALUES (3, 'SysUserManage', '用户管理', 'user', '/admin/sys-user', '/0/2/3', 'C', '', 'admin:sysUser:list', 2, false, '', '/admin/sys-user/index', 10, '0', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 20:31:14', NULL);
INSERT INTO sys_menu VALUES (43, '', '新增管理员', 'app-group-fill', '', '/0/2/3/43', 'F', 'POST', 'admin:sysUser:add', 3, false, '', '', 10, '0', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 20:31:14', NULL);
INSERT INTO sys_menu VALUES (44, '', '查询管理员', 'app-group-fill', '', '/0/2/3/44', 'F', 'GET', 'admin:sysUser:query', 3, false, '', '', 40, '0', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 20:31:14', NULL);
INSERT INTO sys_menu VALUES (45, '', '修改管理员', 'app-group-fill', '', '/0/2/3/45', 'F', 'PUT', 'admin:sysUser:edit', 3, false, '', '', 30, '0', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 20:31:14', NULL);
INSERT INTO sys_menu VALUES (46, '', '删除管理员', 'app-group-fill', '', '/0/2/3/46', 'F', 'DELETE', 'admin:sysUser:remove', 3, false, '', '', 20, '0', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 20:31:14', NULL);
INSERT INTO sys_menu VALUES (51, 'SysMenuManage', '菜单管理', 'tree-table', '/admin/sys-menu', '/0/2/51', 'C', '', 'admin:sysMenu:list', 2, true, '', '/admin/sys-menu/index', 30, '0', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 11:48:40', NULL);
INSERT INTO sys_menu VALUES (52, 'SysRoleManage', '角色管理', 'peoples', '/admin/sys-role', '/0/2/52', 'C', '', 'admin:sysRole:list', 2, true, '', '/admin/sys-role/index', 20, '0', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 11:48:40', NULL);
INSERT INTO sys_menu VALUES (56, 'SysDeptManage', '部门管理', 'tree', '/admin/sys-dept', '/0/2/56', 'C', '', 'admin:sysDept:list', 2, false, '', '/admin/sys-dept/index', 40, '0', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 11:48:40', NULL);
INSERT INTO sys_menu VALUES (57, 'SysPostManage', '岗位管理', 'pass', '/admin/sys-post', '/0/2/57', 'C', '', 'admin:sysPost:list', 2, false, '', '/admin/sys-post/index', 50, '0', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 11:48:40', NULL);
INSERT INTO sys_menu VALUES (58, 'Dict', '字典管理', 'education', '/admin/dict', '/0/2/58', 'C', '', 'admin:sysDictType:list', 2, false, '', '/admin/dict/index', 60, '0', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 11:48:40', NULL);
INSERT INTO sys_menu VALUES (59, 'SysDictDataManage', '字典数据', 'education', '/admin/dict/data/:dictId', '/0/2/59', 'C', '', 'admin:sysDictData:list', 2, false, '', '/admin/dict/data', 100, '1', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 11:48:40', NULL);
INSERT INTO sys_menu VALUES (62, 'SysConfigManage', '参数管理', 'swagger', '/admin/sys-config', '/0/2/62', 'C', '', 'admin:sysConfig:list', 2, false, '', '/admin/sys-config/index', 70, '0', '1', 0, 1, '2021-05-20 22:08:44', '2021-06-17 11:48:40', NULL);

-- 初始化角色菜单关联
INSERT INTO sys_role_menu VALUES (1, 1);
INSERT INTO sys_role_menu VALUES (1, 2);
INSERT INTO sys_role_menu VALUES (1, 3);
INSERT INTO sys_role_menu VALUES (1, 43);
INSERT INTO sys_role_menu VALUES (1, 44);
INSERT INTO sys_role_menu VALUES (1, 45);
INSERT INTO sys_role_menu VALUES (1, 46);
INSERT INTO sys_role_menu VALUES (1, 51);
INSERT INTO sys_role_menu VALUES (1, 52);
INSERT INTO sys_role_menu VALUES (1, 56);
INSERT INTO sys_role_menu VALUES (1, 57);
INSERT INTO sys_role_menu VALUES (1, 58);
INSERT INTO sys_role_menu VALUES (1, 59);
INSERT INTO sys_role_menu VALUES (1, 62);

-- 初始化CASBIN规则（admin角色拥有所有权限）
INSERT INTO sys_casbin_rule VALUES (1, 'p', 'admin', '/api/v1/sys-user', 'POST', '', '', '', '', NULL);
INSERT INTO sys_casbin_rule VALUES (2, 'p', 'admin', '/api/v1/sys-user', 'GET', '', '', '', '', NULL);
INSERT INTO sys_casbin_rule VALUES (3, 'p', 'admin', '/api/v1/sys-user', 'PUT', '', '', '', '', NULL);
INSERT INTO sys_casbin_rule VALUES (4, 'p', 'admin', '/api/v1/sys-user', 'DELETE', '', '', '', '', NULL);
INSERT INTO sys_casbin_rule VALUES (5, 'g', 'admin', 'admin', '', '', '', '', '', NULL);

-- =============================================
-- 创建索引优化查询
-- =============================================
CREATE INDEX idx_sys_user_username ON sys_user(username);
CREATE INDEX idx_sys_user_dept_id ON sys_user(dept_id);
CREATE INDEX idx_sys_menu_parent_id ON sys_menu(parent_id);
CREATE INDEX idx_sys_menu_path ON sys_menu(path);
CREATE INDEX idx_sys_dept_parent_id ON sys_dept(parent_id);
CREATE INDEX idx_sys_dict_type_dict_type ON sys_dict_type(dict_type);
CREATE INDEX idx_sys_dict_data_dict_type ON sys_dict_data(dict_type);

-- =============================================
-- 初始化完成
-- =============================================
-- 默认管理员账号: admin
-- 默认密码: 123456
-- =============================================
