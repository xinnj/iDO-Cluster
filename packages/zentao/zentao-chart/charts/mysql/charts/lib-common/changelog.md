# Changelog

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
