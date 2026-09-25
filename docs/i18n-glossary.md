# 术语表（EN → 简体中文）

Stage 1 P0 范围的中文用词依据。新增 key 时必须先在本表登记，避免同一概念两种译法
（例如「会话」不要有时写成「对话」）。

## 1. 按用户可见度排序的核心术语

| EN | 简体中文 | 说明 |
|---|---|---|
| Settings | 设置 | 屏幕标题 |
| Appearance | 外观 | Settings 分区标题 |
| Home | 首页 | 底部导航 `HermesDestination.home` |
| Chats | 会话 | 底部导航。选「会话」而非「对话」：与 Gateway 侧 session 概念对齐 |
| Projects | 项目 | 底部导航 |
| Activity | 动态 | 底部导航 |
| More | 更多 | 底部导航 |
| Cancel | 取消 | 通用 |
| Save | 保存 | 通用 |
| Save Changes | 保存修改 | 编辑已有项 |
| Delete | 删除 | 通用 |
| Edit Connection | 编辑连接 | 连接行菜单 |
| Connect | 连接 | 连接表单提交 |
| Add Connection | 添加连接 | FAB tooltip |
| Restore configuration | 恢复配置 | 顶栏 tooltip |
| Retry | 重试 | 加载失败 |
| No connections | 暂无连接 | Home 空状态标题 |
| Label | 名称 | 连接表单「连接名称」。不用「标签」：此字段是给人看的连接名 |
| Host | 主机 | 连接表单 |
| Port | 端口 | 连接表单 |
| API Key | API 密钥 | 连接表单。`API` 保留英文，「Key」译「密钥」 |
| Text size | 文字大小 | 设置卡片 |
| Preview | 预览 | 文字大小卡片内 |
| System | 跟随系统 | 主题档位。译「跟随系统」而非「系统」：单独一个「系统」语义不清 |
| Dark | 深色 | 主题档位 |
| Light | 浅色 | 主题档位 |
| Language | 语言 | 语言卡片标题 |
| Follow the system language | 跟随系统语言 | 语言卡 system 档副标题 |
| Interface language. Changes apply immediately. | 界面语言，更改立即生效。 | 语言卡弹窗说明 |

## 2. 暂不翻译（技术标识/品牌）

`Hermes`、`Gateway`、`API Server`、`Android`、`Bearer`、`token`、`URL`、`SSE`、`Cron`、
`Dashboard`、`Provider`、`Model`、`Cinzel`（字体名）、`HERMES`（brand wordmark）。

理由：它们是协议/平台/品牌名，翻译会让用户无法在文档、日志、Gateway 侧配置里对上号。
品牌 wordmark（`lib/main.dart` 的 `'HERMES'` + Cinzel 字体）是图形标识，**永不本地化**。

## 3. 排版约定

- 全角/半角：括号统一半角 `(` `)`（与仓库现有风格一致），破折号统一 ` — `（空格 + em dash），
  **不要**用中文全角破折号 `——`，保持与英文同一模板。
- 数字与单位：`8642`、`100%` 保持半角。
- 大小写：中文不用首字母大写概念；英文保持句首大写（`Connect` 而非 `connect`）。
