# Changelog

# 1.1.14 2024.3.28 by qisy

- 支持通过 global.switchLimit=off 全局关闭资源限制
- 支持通过 resources.switchLimit=off 关闭单个实例的资源限制

# 1.1.13 2023.11.18 by qisy

- 支持设置全局环境变量TZ

# 1.1.12 2023.09.18 by qisy

- sidecard 容器支持超卖 (oversold)

# 1.1.11 2023.08.28 by qisy

- 增加了 lib-common.image.autotag 函数, 能在一个chart里选择不同的tag

# 1.1.10 2023.08.11 by qisy

- 将 crd db 的配置迁移到 mysql.db / postgresql.db / mongodb.db
- 兼容旧应用放在 .Values.db 下的配置，但只支持外部数据库，需逐步修改

## 1.1.9 2023.06.01 by qisy

- container securityContext 支持

## 1.1.8 2023.06.01 by ysicing

- 添加通用命令执行probe

## 1.1.7 2023.04.26 by qisy

- 增加 empty 数据卷类型

## 1.1.6 2023.04.11 by qisy

- 增加 service 端口映射
- secret 空 data 不会覆盖目标 secret data

## 1.1.5 2023.04.06 by qisy

- 增加 lib-common.utils.genHost 函数来生成带协议的主机地址

## 1.1.3 2023.02.14 by ysicing

- 修复已设置existingClaim仍然创建pvc问题

## 1.1.2 2023.02.08 by qisy

- 修复 ingress 默认 class 问题
- secret 支持标签和注解

## 1.1.1 2023.02.07 by qisy

- 支持了 initContainers 以及 sidecars

## 1.1.0 2023.02.03 by qisy

- 支持了 Job 工作流
- 支持为组件创建 serviceAccount
- 简化 Role 的创建，自动生成 rolebinding
- 支持创建多个 secret

## 1.0.9 2023.01.05 by qisy

- values 里定义了默认挂载，即集群内自签名的 ca 证书
- volumes 和 volumeMounts 只会挂载已存在的外部 secret 或 configmap

## 1.0.8 2022.12.29 by qisy

- ingress 支持配置子域名

## 1.0.7 2022.12.22 by qisy

- service 模版模块化，支持云服务商 LoadBalancer 类型
- 支持添加 tke 负载均衡的 service 注解

## 1.0.6 2022.12.5 by qisy

- $ref 允许倒数第二个路径为空字典

## 1.0.5 2022.10.26 by qisy

- 支持关闭时删除工作流，通过 cleanPolicy.workflow 或 global.cleanPolicy.workflow
- 修复 db crd 的一些错误定义
- 修复存储卷在组件中名称生成不正确的问题

## 1.0.4 2022.10.26 by qisy

- serviceAccount 完善 v2 版本 

## 1.0.3 2022.10.20 by qisy

- 支持secret挂载
- 支持statefulset

## 1.0.2 2022.10.09 by qisy

- 支持根据条件判断是否注入环境变量，在secret和configmap类型的定义中生效

## 1.0.1 2022.09.27 by qisy

- 增加了 daemonset 类型 workflow
- hostPath 支持定义 tpl

## 1.0.0 2022.09.08 by qisy

- 函数库升级到v2版本，支持多组件

## 0.2.19 2022.09.01 by ysicing

- 添加默认provider:quickon Label支持筛选应用

## 0.2.18 2022.08.31 by qisy

- 已创建的 pvc, 其 accessModes 不被values内容覆盖

## 0.2.17 2022.08.26 by qisy

- 包装 annotations 生成函数, 支持value使用引用以及模版，ingress接入该函数

## 0.2.16 2022.08.16 by qisy

- 允许将 global 中的节点选择器、污点容忍、亲和性作为缺省配置，使子 chart 能同时生效

## 0.2.15 2022.07.28 by qisy

- 增加 postgresql & mongodb 的扩展数据库模版

## 0.2.14 2022.07.22 by qisy

- 拆分 db 和 dbservice 模版文件, 增加一个扩展数据库模版，供应用使用
- 支持 db 新增字段 config

## 0.2.13 2022.07.21 by qisy

- 修复 db 模版 default 函数参数顺序错误问题

## 0.2.12 2022.07.20 by ysicing

- 添加dbservice注解

## 0.2.11 2022.07.14 by qisy

- support command args list

## 0.2.10 2022.07.04 by qisy

- support nfs volumes for applayer

## 0.2.9 2022.07.01 by qisy

- bugfix: env 字段切换为 valueFrom 的同时，设置 value 为 null

## 0.2.8 2022.06.29 by qisy
- 判断 pvc 是否存在, 取当前的 storageClassName 渲染模版
- 增加两个新函数, utils.getValueByPath 读取 path, utils.readRef 识别引用
- env、secret 的渲染，能识别引用、tpl
- env 能够识别数字、bool并转义

## 0.2.6 2022.06.20 by ysicing

- 回滚到0.2.4
## 0.2.5 2022.06.20 by ysicing

- 修改storageClass错误
## 0.2.4 2022.06.20 by qisy

- 增加了 ingressHost 字段以及相应指针的处理

## 0.2.3 2022.06.15 by qisy

- 增加调试用的 json schemas

## 0.2.2

- 修正不正确的单词拼写
- 应用关闭时移除service

## 0.2.1

- 优化envFrom
- 修复bug

## 0.2.0

- empty高级参数支持
- 添加命名空间
- 默认环境变量POD_NAME
- 支持envFrom

## 0.1.8

- 支持tls证书配置

## 0.1.4

- 新增`pullPolicy`属性
