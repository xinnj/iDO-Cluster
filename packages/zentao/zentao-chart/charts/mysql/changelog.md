# Changelog

## 0.2.9 2022.08.16 by qisy

- 更新 lib-common, 读取 global 调度参数

## 0.2.8 2022.07.26 by qisy

- 更新 lib-common, 调整 dbservice & db 的参数传入

## 0.2.7 2022.07.21 by ysicing

- 升级 lib-common, 支持dbservice注解

## 0.2.6 2022.07.15 by qisy
- pvc 卷增加注解, 不会被备份还原

## 0.2.5 2022.07.14 by qisy
- 升级 lib-common, 支持 command args

## 0.2.4 2022.07.04 by qisy
- 升级 lib-common 库, 兼容 env 中 value 和 valueFrom 共存冲突问题

## 0.2.3 20220629 by qisy
- 切换到 auth 定义认证信息，env 和 secret 处理该认证信息
- 如果集群安装了qucheng crd，自动创建 dbservice 和 db

## 0.2.2 20220615 by qisy 
- 增加调试用的 json schemas
