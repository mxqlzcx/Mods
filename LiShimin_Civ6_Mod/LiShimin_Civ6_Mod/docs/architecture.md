# 架构文档

## 1. 整体架构

本模组采用**模块化 + 事件驱动**架构，核心设计原则：

- **高内聚低耦合**：每个模块职责单一，通过事件总线通信
- **可扩展**：易于添加新事件、新能力、新单位
- **可维护**：版本化配置，集中管理常量与数值

### 1.1 架构图

```
┌─────────────────────────────────────────────────────────────┐
│                      Main.lua (入口)                        │
│  - 初始化 LiShiminMod 全局对象                             │
│  - 注册游戏事件 → EventBus                                  │
│  - 管理玩家状态数据                                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      EventBus.lua (事件总线)                │
│  - 事件注册/监听/触发                                       │
│  - 模块间通信桥梁                                            │
└─────────────────────────────────────────────────────────────┘
          │           │           │           │
          ▼           ▼           ▼           ▼
┌─────────────┐ ┌─────────┐ ┌──────────┐ ┌──────────┐
│Coronation.lua│ │HeroDeath│ │PrinceLine│ │TianceAura│
│  (登基仪式) │ │.lua     │ │.lua      │ │.lua      │
│+李建成实体 │ │(英雄死亡)│ │(藩王线)  │ │(军威光环)│
└─────────────┘ └─────────┘ └──────────┘ └──────────┘
          │                                         │
          ▼                                         ▼
┌────────────────────┐                    ┌──────────────────────┐
│ZhenguanTaizong.lua│                    │  TianKeHan.lua       │
│ 贞观之治+万国来朝 │                    │ 天可汗节度使+        │
│  (纯Lua实现)       │                    │ 天子一怒+万国来朝    │
└────────────────────┘                    └──────────────────────┘
```

### 1.2 数据流

```
游戏事件触发
    │
    ▼
EventBus:FireEvent(eventName, ...)
    │
    ▼
Main.lua 中的监听器被调用
    │
    ├── 更新 LiShiminMod.Players[playerID] 状态
    │
    └── 调用对应模块的处理函数
            │
            ├── Coronation.lua  → 登基仪式逻辑 + 李建成刷新
            ├── HeroDeath.lua   → 天策上将死亡=游戏结束
            ├── PrinceLine.lua  → 藩王线剧情
            ├── TianceAura.lua  → 天策军威光环
            ├── TianKeHan.lua   → 天可汗节度使/天子一怒
            │
            ▼
        UI 通知 / 游戏状态变更
```

## 2. 核心模块

### 2.1 EventBus.lua

事件总线是模组的中央通信枢纽，实现观察者模式。

```lua
EventBus = {
    events = {},       -- 已注册事件表
    listeners = {},    -- 事件监听器表
    
    -- 注册事件
    RegisterEvent(eventName),
    
    -- 注册监听器（callback: 回调函数, priority: 优先级）
    RegisterListener(eventName, callback, priority),
    
    -- 触发事件（传递参数给所有监听器）
    FireEvent(eventName, ...),
}
```

**优势：**
- 解耦事件源与事件处理逻辑
- 支持优先级，确保执行顺序
- 易于添加新功能，无需修改已有代码

### 2.2 Main.lua

主控制器，管理模组生命周期和全局状态。

```lua
LiShiminMod = {
    Players = {},      -- 所有玩家数据
    Version = "2.0",  -- 模组版本
    
    Initialize(),           -- 初始化
    RegisterGameEventListeners(),    -- 注册游戏事件
    RegisterCustomEventListeners(),  -- 注册自定义事件
    
    -- 事件处理回调
    OnGameStart(),
    OnPlayerTurnBegin(playerID),
    OnEraChanged(playerID, newEra, oldEra),
    ...
}
```

### 2.3 状态机

玩家状态流转图：

```
                    ┌─────────────────┐
                    │ TIANCE_GENERAL  │
                    │  (天策上将形态) │
                    └────────┬────────┘
                             │
              [进入中世纪时代]
                             │
              ┌───────────────┴───────────────┐
              │                               │
     [征服≥5城]                        [征服<5城]
              │                               │
              ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │   CORONATION    │             │   PRINCE_LINE   │
    │  (登基仪式中)   │             │    (藩王线)     │
    └────────┬────────┘             └────────┬────────┘
             │                               │
    [完成仪式]                        [复辟成功]
             │                               │
             ▼                               ▼
    ┌─────────────────┐             ┌─────────────────┐
    │  EMPEROR_TAIZONG │            │  EMPEROR_TAIZONG │
    │   (唐太宗形态)   │◄───────────│   (唐太宗形态)   │
    └─────────────────┘  [藩王线]   └─────────────────┘
                                    ▲
                                    │
                          [复辟失败 → 游戏结束]
```

## 3. 文件对应关系

| 目录 | 文件 | 说明 |
|------|------|------|
| `config/` | `balance.lua` | 数值平衡配置（版本化）|
| `config/` | `constants.lua` | 常量定义、枚举值（同步定版）|
| `config/` | `version.lua` | 版本控制变量（v2.0.0）|
| `src/Lua/` | `Main.lua` | 入口控制、状态协调 |
| `src/Lua/` | `EventBus.lua` | 事件调度中心 |
| `src/Lua/` | `Coronation.lua` | 登基仪式逻辑 + 李建成实体刷新 |
| `src/Lua/` | `HeroDeath.lua` | 天策上将死亡处理 |
| `src/Lua/` | `PrinceLine.lua` | 藩王线剧情 |
| `src/Lua/` | `ZhenguanTaizong.lua` | 贞观之治 + 万国来朝（纯Lua）|
| `src/Lua/` | `TianceAura.lua` | 天策军威光环（🆕 v2.0）|
| `src/Lua/` | `TianKeHan.lua` | 天可汗节度使 + 天子一怒（🆕 v2.0）|
| `src/Lua/` | `Utils.lua` | 工具函数、日志 |
| `src/Lua/UI/` | `CoronationUI.lua` | 登基仪式界面 |
| `src/XML/` | `Civilizations.xml` | 文明定义 |
| `src/XML/` | `Leaders.xml` | 领袖定义 |
| `src/XML/` | `Traits.xml` | 特性定义 |
| `src/XML/` | `Modifiers.xml` | 修饰符定义 |
| `src/XML/` | `RequirementSets.xml` | 需求集合 |
| `src/XML/` | `Units.xml` | 单位定义 |
| `src/XML/` | `Buildings.xml` | 建筑定义 |
| `src/XML/` | `Text.xml` | 文本本地化 |
| `src/ArtDefs/` | `*.artdef` | 美术资源定义 |

## 4. 版本控制机制

### 4.1 平衡版本

通过 `BALANCE_VERSION` 选择加载哪套数值：

```lua
-- config/version.lua
BALANCE_VERSION = "2.0"

-- config/balance.lua
local Balance = {
    ["1.0"] = { ... },  -- 1.0版本数值
    ["2.0"] = { ... },  -- 2.0版本数值
}
```

### 4.2 版本差异示例

| 参数 | 1.0 | 2.0 | 变化 |
|------|-----|-----|------|
| 天策上将攻击 | 40 | 45 | +5 |
| 天策上将生命 | 200 | 220 | +20 |
| 使者获取间隔 | 6回合 | 5回合 | -1 |
| 藩王惩罚 | -50% | -45% | +5% |

## 5. 错误处理

### 5.1 SafeCall 包装器

所有事件回调使用 SafeCall 包装，防止异常中断游戏：

```lua
function SafeCall(func, ...)
    local status, result = pcall(func, ...)
    if not status then
        LogError("Error: " .. tostring(result))
        return nil
    end
    return result
end
```

### 5.2 日志分级

```lua
Log(message, level)
LogError(message)   -- 错误（始终输出）
LogWarning(message) -- 警告
LogDebug(message)   -- 调试（DEBUG_MODE=true时输出）
```

## 6. 性能优化

### 6.1 事件过滤

在事件回调入口快速过滤，减少无效处理：

```lua
function OnUnitKilled(unitsKilled)
    if not unitsKilled[1] then return end
    local unit = unitsKilled[1]
    if unit:GetOwner() ~= LiShiminPlayerID then return end
    -- 继续处理...
end
```

### 6.2 延迟初始化

非关键资源采用延迟加载：

```lua
function LazyLoadArtAssets()
    if not ArtAssetsLoaded then
        -- 加载美术资源
        ArtAssetsLoaded = true
    end
end
```

## 7. 扩展性设计

### 7.1 添加新能力

1. 在 `config/constants.lua` 中定义新常量
2. 在 `config/balance.lua` 中添加数值
3. 在 `src/XML/Traits.xml` 中添加特性
4. 在 `src/Lua/` 中实现逻辑
5. 在 `Main.lua` 中注册事件监听

### 7.2 添加新单位

1. 在 `src/XML/Units.xml` 中定义单位
2. 在 `src/Lua/` 中实现特殊行为（如有）
3. 更新 `config/constants.lua` 中的单位类型常量
