---
title: 字段说明
toc_max_heading_level: 4
---

# global

用于放置全局参数，可被当前 chart 和子 chart 读取

| 字段路径                | 类型   | 默认值          | 描述                                                         |
| ----------------------- | ------ | --------------- | ------------------------------------------------------------ |
| global.ingress.disabled | bool   | false           | 当为 true 时，chart 自身的 ingress.enabled 无效，用于关闭应用时删除 ingress 资源 |
| global.ingress.host     | string | -               | 设置当前 chart 与 子 chart 的公有域名                        |
| global.repodomain       | string | hub.qucheng.com | 拼接容器 image 字段，方便在私有化部署时切换到用户的镜像仓库  |
