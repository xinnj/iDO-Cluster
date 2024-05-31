# 禅道开源版

## 2024.3.1501  by ysicing

- 更新到 20.0.beta2

## 2024.4.1201  by ysicing

- 更新到 18.12

## 2024.2.2801  by ysicing

- 更新到 18.11

## 2024.1.3101  by ysicing

- 更新到 20.0.beta1

## 2023.12.2801  by ysicing

- 更新到 18.10

## 2023.10.1201  by ysicing

- 更新到 18.8

## 2023.9.2201  by ysicing

- 更新到 18.7

## 2023.8.3101  by ysicing

- 修改环境变量问题

## 2023.8.2401  by ysicing

- 更新到 18.6

## 2023.7.1301  by ysicing

- 更新到 18.5

## 2023.6.2501  by ysicing

- 更新到 18.4

## 2023.3.2201 2023-03-22 16:01:50 by zhouyq

- 更新到 18.3

## 2023.3.701 2023-03-09 10:08:27 by zhouyq

- 更新到 18.2

## 2023.2.1601 2023-02-17 09:55:13 by zhouyq

- 更新到  18.1

## 2023.1.1001 2023-01-10 20:42:33 by zhouyq

- 更新到  18.0

## 2023.1.401 2023-01-04 10:42:12 by zhouyq

- 更新到 18.0.beta3

## 2022.11.701 2022-11-10 10:12:10 by zhouyq

- 更新到 17.8

## 2022.10.2701 2022-10-27 17:40:24 by zhouyq

- 更新到 17.7

## 2022.9.2901 2022-09-29 15:36:45 by zhouyq

- 更新到 17.6.2

## 2022.9.1901 2022-09-19 10:24:45 by zhouyq

- 更新到 17.6.1

## 2022.8.3101 2022-08-31 13:45:50 by zhouyq

- 升级到 17.6

## 2022.8.3001 2022-08-30 12:38:48 by zhouyq

- 增加源码地址
- 增加截图

## 17.5.0 2022-08-18 20:20:07 by zhouyq

- update zentao-open to 17.5

## 17.4.1 2022-08-18 13:38:33 by zhouyq

- 新增旗舰版3.3 Kubernetes镜像构建命令,解决kubernetes环境下授权失效问题.
- 新增旗舰版3.3 Kubernetes arm64架构 镜像构建命令.
- 新增版本升级[说明文档](https://github.com/quicklyon/zentao-docker/blob/master/README.md)
- 新增[update.sh](https://github.com/quicklyon/zentao-docker/blob/master/update.sh)方便自动化检查新版本.
- 解决设置Redis保存Session时无法进行初始化安装的问题 [#1](https://github.com/quicklyon/zentao-docker/issues/1)
- 调整安装向导检查脚本,保证安装完成后再删除 install.php 和 upgrade.php文件
- 替换MySQL服务检查命令,提升检查效率
- 更新MySQL-Client包,支持MySQL 8.0
- Dockerfile设置默认bash,提升极端情况下的兼容性.
- 设置make命令的默认指令,当未加参数时,显示make help指令.
- 提升make help命令的兼容性,支持指令中包含数字的情况.

## 17.4.0 2022-08-03 15:36:28 by zhouyq

- 升级到  17.4

## 0.1.11 2022-07-23 by qisy

- 升级 lib-common 包, 引入公共数据库模版
- db.config 增加配置, 公共数据库创建用户时授予 super 权限

## 0.1.10 2022-07-19 14:44:18 by zhouyq

- 禅道开源版升级到 17.3

## 0.1.9 2022.7.15 by qisy

- 更新 mysql 版本，禁止mysql数据卷的备份还原
- 增加 db.yaml 模版, 支持连接其它数据库

## 0.1.8 2022.7.6 by zhouyq

- 版本升级到 17.2

## 0.1.6 2022.7.6 by zhouyq

- 规范版本号，平台1.1发版前整理

## 0.1.3 2022.06.30 by qisy

- 切换到 mysql.auth

## 0.1.2 2022.06.23 by zhouyq

- 升级到开源版 17.1

## 0.1.1 2022.06.09 by zhouyq

- 升级到开源版 17.0
- 指定最低可升级版本

## 0.1.0 2022.06.07 by qisy

- 解决在某些情况下生成 MYSQL_HOST 地址不正确的问题

## 0.0.9 2022.6.6 by zhouyq

- 修复检查并删除install.php和upgrade.php的脚本bug

## 0.0.8 2022.5.31 by zhouyq

- 修改values.yaml 取消启动时健康检查

## 0.0.7 2022.5.31 by zhouyq

- 修改custom.yaml中的mysql数据库名词为 `%s-mysql`

## 0.0.6 2022.5.31 by zhouyq

- 修改custom.yaml中的mysql数据库名词为 `mysql-%s`
- 修改custom.yaml中的chart名词为 `zentao-open`

## 0.0.5 2022.5.27 by zhouyq

- 更新禅道应用描述信息，去掉 “最”

## 0.0.4 2022.5.25 by ysicing

- 更新依赖

## 0.0.3 2022.5.25 by zhouyq

**Docker镜像变更**:

- check_files.sh 脚本的执行从 entrypoint.sh 移到 /etc/s6/s6-init/envs  修正查不到文件的错误
- 修正了检测install.php和upgrade.php 的脚本，支持自定义数据库表prefix的检测
- /etc/s6/s6-init/envs 文件中添加DOCUMENT_ROOT变量，方便修改apache虚拟主机的文档目录

## 0.0.2 2022.5.24 by zhouyq

**charts文件变更**:

- 新建禅道开源版 16.5
- 申请内存调整为128M
- 申请CPU调整为100m
- 最大内存调整为256M
- 最大CPU调整为200m
- 去掉 `DEBUG=1` 环境变量
