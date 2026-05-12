# 技术文档

## 开发环境

### 必需工具

| 工具 | 版本 | 用途 |
|------|------|------|
| 《文明6》 | 最新版本 | 游戏本体 |
| ModBuddy | 与游戏版本匹配 | 模组项目编辑器 |
| Python | 3.8+ | XML验证脚本 |

### 目录结构

```
LiShimin_Civ6_Mod/
├── docs/           # 文档
├── config/         # Lua配置文件
├── src/
│   ├── XML/        # XML定义文件
│   ├── Lua/        # Lua脚本
│   └── ArtDefs/    # 美术资源定义
├── art/            # 美术资源文件
├── tools/          # 开发工具脚本
├── modbuddy/       # ModBuddy项目文件
└── release/        # 编译输出目录
```

## 文件格式规范

### Lua 文件

- 统一使用4空格缩进
- 变量命名：`camelCase`
- 常量命名：`UPPER_SNAKE_CASE`
- 文件编码：`UTF-8 without BOM`

### XML 文件

- 统一使用4空格缩进
- 标签属性使用双引号
- 根节点需包含 `<?xml version="1.0" encoding="utf-8"?>`
- 文件编码：`UTF-8 without BOM`

### 美术资源

- 图标格式：DDS（带mipmap）
- 肖像格式：1024x1024 PNG 导出为 DDS
- 加载画面：512x256 PNG 导出为 DDS

## 模块架构

### 事件总线（EventBus.lua）

中央事件调度中心，所有模块通过事件总线通信。

```lua
-- 注册事件监听器
EventBus:RegisterListener("ON_GAME_START", callback, priority)

-- 触发事件
EventBus:FireEvent("ON_PLAYER_TURN_BEGIN", playerID)
```

### 主控制器（Main.lua）

模组入口，负责初始化和协调。

```lua
LiShiminMod:Initialize()      -- 初始化模组
LiShiminMod:RegisterEvents()   -- 注册事件监听器
```

### 状态管理

全局状态存储在 `LiShiminMod.Players[playerID]` 中：

```lua
{
    LeaderState = "TIANCE_GENERAL",   -- 当前形态
    CitiesConquered = 0,              -- 已征服城市数
    GreatPeopleRecruited = 0,         -- 已招募伟人数
    XuanwuGateBuilt = false,          -- 玄武门是否建成
    CoronationCompleted = false,      -- 登基仪式是否完成
    RestorationTurnsRemaining = -1,   -- 复辟剩余回合
}
```

## API 参考

### 游戏事件

| 事件 | 参数 | 说明 |
|------|------|------|
| `Events.GameStart` | - | 游戏开始 |
| `Events.PlayerTurnBegin` | playerID | 玩家回合开始 |
| `Events.PlayerTurnEnd` | playerID | 玩家回合结束 |
| `Events.UnitCreated` | playerID, unitID, unitType | 单位创建 |
| `Events.UnitKilledInCombat` | unitsKilled[] | 单位死亡 |
| `Events.PlayerEraChanged` | playerID, newEra, oldEra | 时代变更 |

### 模组自定义事件

| 事件 | 参数 | 说明 |
|------|------|------|
| `ON_XUANWU_GATE_BUILT` | playerID, city | 玄武门建成 |
| `ON_SHOOT_LI_JIANCHENG` | playerID | 射杀李建成 |
| `ON_CORONATION_COMPLETED` | playerID | 登基完成 |
| `ON_PRINCE_LINE_ACTIVATED` | playerID | 藩王线激活 |
| `ON_RESTORATION_COMPLETED` | playerID | 复辟成功 |
| `ON_RESTORATION_FAILED` | playerID | 复辟失败 |

### 关键API

```lua
-- 获取玩家对象
local player = Players[playerID]

-- 获取城市
local city = CityManager.GetCity(playerID, cityID)
local capital = player:GetCities():FindCapital()

-- 获取单位
local unit = UnitManager.GetUnit(playerID, unitID)

-- 显示通知
NotificationManager:CreateNotification(playerID)
```

## 调试指南

### 启用调试模式

编辑 `src/Lua/Utils.lua`：

```lua
DEBUG_MODE = true  -- 改为true启用
```

### 控制台日志

调试模式下，所有日志会输出到控制台：

```
[LiShiminMod] [DEBUG] Event fired: ON_GAME_START
[LiShiminMod] [INFO] Player 0 initialized as Tiance General
```

### 常见问题

| 问题 | 可能原因 | 解决方案 |
|------|----------|----------|
| 模组无法加载 | XML格式错误 | 运行 `tools/validate_xml.py` |
| 事件不触发 | 监听器注册失败 | 检查 `EventBus:RegisterListener` 调用 |
| 单位不生成 | 前置条件未满足 | 检查科技/市政要求 |

## 编译与发布

### 编译步骤

1. 用 ModBuddy 打开 `modbuddy/LiShimin.civ6proj`
2. 点击 `Build → Make Mod Winterface`
3. 生成 `.mod` 文件在 `release/` 目录

### 版本命名

格式：`LiShimin_MAJOR.MINOR.mod`

示例：`LiShimin_2.0.mod`

### 发布检查清单

- [ ] 所有XML文件通过验证
- [ ] 所有Lua文件无语法错误
- [ ] 美术资源正确加载
- [ ] 更新 `docs/changelog.md`
- [ ] 更新 `config/version.lua` 中的版本号
- [ ] 编写 `release/notes/X.Y.md` 发布说明
