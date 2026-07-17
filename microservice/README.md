# Go-Admin 微服务改造方案

## 一、概述

本方案将 go-admin 单体应用改造为微服务架构，实现服务注册与发现、配置中心、API 网关、负载均衡、熔断降级等核心功能，解决高并发场景下的性能瓶颈问题。

## 二、架构设计

### 2.1 整体架构

```
┌─────────────────────────────────────────────────────────┐
│                     客户端 / Web 前端                     │
└──────────────────────────────┬──────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────┐
│                      API 网关层                           │
│  (路由转发 / 鉴权 / 限流 / 熔断 / 日志 / 监控)             │
└───┬───────────┬───────────┬───────────┬───────────────┘
    │           │           │           │
┌───▼───┐ ┌────▼────┐ ┌────▼────┐ ┌────▼────┐
│ 用户  │ │  系统   │ │ 定时任务│ │  开发  │
│ 服务  │ │  管理   │ │  服务   │ │  工具  │
│       │ │  服务   │ │         │ │  服务  │
└───┬───┘ └────┬────┘ └────┬────┘ └────┬────┘
    │           │           │           │
┌───▼───────────▼───────────▼───────────▼───────┐
│             服务注册与发现 (etcd)               │
│         (服务注册 / 发现 / 健康检查)            │
└──────────────────────┬────────────────────────┘
                       │
┌──────────────────────▼────────────────────────┐
│              配置中心 (etcd)                   │
│       (动态配置 / 热更新 / 环境隔离)            │
└──────────────────────┬────────────────────────┘
                       │
┌──────────────────────▼────────────────────────┐
│       数据库 / 缓存 / 消息队列                 │
│  (MySQL / Redis / 可扩展支持 MQ)               │
└───────────────────────────────────────────────┘
```

### 2.2 服务拆分方案

按照业务领域拆分为以下微服务：

| 服务名称 | 服务ID | 端口 | 职责说明 |
|---------|--------|------|---------|
| API网关 | gateway | 8080 | 统一入口、路由转发、鉴权、限流 |
| 用户服务 | user-service | 8001 | 用户管理、部门管理、岗位管理 |
| 权限服务 | auth-service | 8002 | 角色管理、菜单管理、权限控制、登录认证 |
| 系统服务 | system-service | 8003 | 字典管理、参数配置、操作日志、登录日志 |
| 定时任务服务 | job-service | 8004 | 定时任务调度、任务日志 |
| 工具服务 | tool-service | 8005 | 代码生成、服务监控、文件上传 |

### 2.3 核心技术栈

| 组件 | 技术选型 | 说明 |
|------|---------|------|
| 服务注册与发现 | etcd | 轻量级、高可用、支持健康检查 |
| 配置中心 | etcd | 与服务发现共用，减少组件依赖 |
| API网关 | Gin 自研 | 基于 Gin 框架实现，轻量高效 |
| 负载均衡 | 轮询 / 加权轮询 / 随机 | 客户端负载均衡 |
| 熔断降级 | Sentinel | 项目已集成，直接复用 |
| 服务间调用 | HTTP + JSON | 简单通用，便于调试 |
| 监控告警 | Prometheus + Grafana | 指标采集与可视化 |
| 链路追踪 | OpenTracing + Jaeger | 可扩展支持 |

## 三、核心模块说明

### 3.1 服务注册与发现

**文件位置**: [microservice/registry/etcd.go](file:///Users/zxwy/Downloads/workspace/Go/go-admin/microservice/registry/etcd.go)

核心功能：
- 服务注册：服务启动时注册到 etcd，带 TTL 租约
- 服务发现：根据服务名获取可用实例列表
- 健康检查：通过 etcd 租约机制自动摘除故障节点
- 服务监听：监听服务实例变化，实时更新本地缓存

使用示例：
```go
// 创建注册中心
reg, err := registry.NewEtcdRegistry([]string{"127.0.0.1:2379"}, 10)

// 注册服务
info := &registry.ServiceInfo{
    Name:    "user-service",
    Address: "127.0.0.1",
    Port:    8001,
    Weight:  100,
    Version: "v1.0.0",
}
reg.Register(ctx, info)

// 发现服务
services, err := reg.Discover(ctx, "user-service")
```

### 3.2 负载均衡

**文件位置**: [microservice/loadbalancer/balancer.go](file:///Users/zxwy/Downloads/workspace/Go/go-admin/microservice/loadbalancer/balancer.go)

支持的负载均衡策略：
- **轮询 (RoundRobin)**: 按顺序依次选择实例
- **加权轮询 (WeightedRoundRobin)**: 根据权重分配流量
- **随机 (Random)**: 随机选择实例
- **IP哈希 (IPHash)**: 根据客户端IP哈希，保证同一客户端访问同一实例

### 3.3 服务间调用客户端

**文件位置**: [microservice/client/client.go](file:///Users/zxwy/Downloads/workspace/Go/go-admin/microservice/client/client.go)

核心功能：
- 自动服务发现与负载均衡
- 支持 GET/POST/PUT/DELETE 等 HTTP 方法
- 自动 JSON 序列化/反序列化
- 连接池管理
- 可扩展熔断降级（可集成 Sentinel）

使用示例：
```go
// 创建服务客户端
client := client.NewServiceClient(reg)

// 调用用户服务
var result User
err := client.Get(ctx, "user-service", "/api/v1/users/1", &result)
```

### 3.4 API 网关

**文件位置**: [microservice/gateway/gateway.go](file:///Users/zxwy/Downloads/workspace/Go/go-admin/microservice/gateway/gateway.go)

核心功能：
- 动态路由配置
- 基于路径的服务转发
- 自动服务发现与负载均衡
- 支持路径前缀剥离
- 统一错误处理

可扩展功能：
- JWT 鉴权
- 请求限流
- 熔断降级
- 访问日志
- 请求追踪

### 3.5 配置中心

**文件位置**: [microservice/config/etcd.go](file:///Users/zxwy/Downloads/workspace/Go/go-admin/microservice/config/etcd.go)

核心功能：
- 配置读取与设置
- 支持 JSON 格式配置
- 配置变更监听
- 本地缓存

## 四、快速开始

### 4.1 启动基础设施

```bash
cd microservice/deploy
docker-compose up -d
```

这会启动以下组件：
- etcd: 服务注册与配置中心 (端口 2379)
- MySQL: 数据库 (端口 3306)
- Redis: 缓存 (端口 6379)
- Prometheus: 监控 (端口 9090)
- Grafana: 可视化 (端口 3000)

### 4.2 启动示例服务

```bash
# 启动用户服务示例
cd microservice/examples/user-service
go run main.go

# 启动网关
cd microservice/examples/gateway
go run main.go
```

### 4.3 测试服务

```bash
# 通过网关访问用户服务
curl http://localhost:8080/api/v1/user/users
```

## 五、迁移步骤

### 阶段一：基础设施搭建（1-2天）

1. 部署 etcd 集群（3节点）
2. 部署 API 网关
3. 部署监控系统（Prometheus + Grafana）
4. 部署日志系统（可选 ELK / Loki）

### 阶段二：核心服务拆分（1-2周）

1. 拆出用户服务（用户、部门、岗位）
2. 拆出权限服务（角色、菜单、登录认证）
3. 拆出系统服务（字典、参数、日志）
4. 验证核心流程正常

### 阶段三：业务服务拆分（1周）

1. 拆出定时任务服务
2. 拆出工具服务（代码生成、文件上传）
3. 完善服务间调用
4. 性能测试与优化

### 阶段四：稳定性建设（1周）

1. 接入熔断降级（Sentinel）
2. 接入链路追踪（Jaeger）
3. 完善监控告警
4. 全链路压测

## 六、高并发解决方案

### 6.1 服务层扩容

- **水平扩展**: 无状态服务可任意水平扩容
- **动态扩缩容**: 根据负载自动调整实例数
- **负载均衡**: 多种负载均衡策略，均匀分配流量

### 6.2 缓存策略

- **多级缓存**: 本地缓存 + Redis 分布式缓存
- **热点数据**: 热点 Key 本地缓存，减少 Redis 压力
- **缓存预热**: 服务启动时预加载热点数据

### 6.3 数据库优化

- **读写分离**: 主库写，从库读
- **分库分表**: 数据量超过单表瓶颈时考虑
- **连接池**: 合理配置数据库连接池

### 6.4 异步处理

- **消息队列**: 引入 MQ 解耦非核心流程
- **异步通知**: 日志、短信、邮件等异步处理
- **批量处理**: 批量操作减少 IO 次数

## 七、项目已有基础

### 7.1 已集成组件

1. **Sentinel**: 熔断限流，直接可用
   - 位置: [common/middleware/sentinel.go](file:///Users/zxwy/Downloads/workspace/Go/go-admin/common/middleware/sentinel.go)

2. **Gin**: Web 框架，性能优秀
   - 各服务直接复用

3. **GORM**: ORM 框架，支持多种数据库
   - 各服务独立数据库连接

4. **Casbin**: 权限控制
   - 权限服务集中管理

### 7.2 代码结构优势

项目已按业务模块划分目录，便于拆分：

```
app/
├── admin/      # 系统管理模块 → 拆分为用户/权限/系统服务
├── jobs/       # 定时任务模块 → 拆分为任务服务
└── other/      # 工具模块 → 拆分为工具服务

common/         # 公共组件 → 各服务共享
config/         # 配置 → 迁移到配置中心
```

## 八、注意事项

### 8.1 分布式事务

跨服务操作需要考虑分布式事务，建议方案：
- 尽量避免跨服务事务
- 必须跨服务时，使用最终一致性方案（本地消息表 / 可靠消息）
- 不建议使用强一致性方案（性能损耗大）

### 8.2 数据一致性

- 用户、权限等基础数据由基础服务维护
- 其他服务通过接口调用获取，不直接访问数据库
- 可通过缓存 + 事件通知机制同步数据

### 8.3 接口版本管理

- URL 中包含版本号：`/api/v1/...`
- 向后兼容，不破坏性变更
- 多版本并行，逐步迁移

### 8.4 服务治理

- 统一错误码规范
- 统一日志格式
- 统一接口响应格式
- 接口文档（Swagger）

## 九、示例代码

### 9.1 服务启动示例

[user-service/main.go](file:///Users/zxwy/Downloads/workspace/Go/go-admin/microservice/examples/user-service/main.go)

### 9.2 网关示例

[gateway/main.go](file:///Users/zxwy/Downloads/workspace/Go/go-admin/microservice/examples/gateway/main.go)

### 9.3 Docker 部署

[docker-compose.yml](file:///Users/zxwy/Downloads/workspace/Go/go-admin/microservice/deploy/docker-compose.yml)

## 十、总结

本微服务改造方案具有以下优势：

1. **渐进式改造**: 可逐步拆分，不影响现有业务
2. **轻量级架构**: 基于 etcd，组件少，运维成本低
3. **高性能**: 客户端负载均衡，无网关性能瓶颈
4. **高可用**: 服务自动发现与健康检查，故障自动摘除
5. **可扩展**: 模块化设计，方便扩展新功能
6. **复用性**: 充分利用项目已有组件（Gin、Sentinel、GORM）

建议从非核心业务开始拆分，逐步验证方案，再推广到核心业务。
