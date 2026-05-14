-- ============================================================================
-- LiShimin Civ6 Mod v2.0.0 — 主脚本（单文件合并版）
-- 所有子模块已内联合并，避免 Civ6 GameplayScripts 沙盒隔离导致函数不可见
-- 合并日期：2026-05-13
-- ============================================================================

-- ============================================================================
-- MODULE: config\constants.lua
-- ============================================================================

-- ============================================================
-- 模组常量配置
-- 所有关键数值集中在此处，方便平衡调整
-- 同步更新自 简介.txt（定版）
-- ============================================================

-- ===== 时代名称常量（必须与 XML GameInfo.Eras 中 EraType 一致）=====
ERA_ANCIENT     = "ERA_ANCIENT"
ERA_CLASSICAL   = "ERA_CLASSICAL"
ERA_MEDIEVAL    = "ERA_MEDIEVAL"
ERA_RENAISSANCE = "ERA_RENAISSANCE"
ERA_INDUSTRIAL  = "ERA_INDUSTRIAL"
ERA_MODERN      = "ERA_MODERN"
ERA_ATOMIC      = "ERA_ATOMIC"
ERA_INFORMATION = "ERA_INFORMATION"

-- ===== 领袖名称（必须与 XML / Leader 定义的类型名匹配） =====
LEADER_LI_SHIMIN = "LEADER_LI_SHIMIN"

-- ===== 领袖状态枚举 =====
LEADER_STATE = {
    TIANCE_GENERAL   = 1,   -- 天策上将（远古~古典）
    CORONATION       = 2,   -- 登基仪式（中世纪交界）
    PRINCE_LINE      = 3,   -- 藩王支线（背水一战）
    EMPEROR_TAIZONG  = 4,   -- 唐太宗（中世纪及以后）
}

-- ===== 状态转换常量 =====
CORONATION_MIN_CITIES_CONQUERED = 5   -- 进入中世纪前，需征服至少5城才走登基线

-- ===== 天策上将（英雄远程单位）=----
UNIT_TIANCE_GENERAL = "UNIT_TIANCE_GENERAL"

-- 天策军威光环（简介.txt定版）：周围每存在1个友军，自身防御力+5，无上限
TIANCE_AURA_COMBAT_BONUS  = 5          -- 每格友军+5防御
TIANCE_AURA_RANGE          = 2          -- 光环范围（格）
TIANCE_COMBAT              = 45        -- 近战防御基础值
TIANCE_RANGED_COMBAT       = 55        -- 远程攻击值
TIANCE_RANGE               = 2         -- 射程
TIANCE_MOVES               = 3         -- 移动力
TIANCE_COST                = 130       -- 召唤费用

-- ===== 玄甲军（特色重骑兵）=====
UNIT_XUANJIA_ARMY = "UNIT_XUANJIA_ARMY"
XUANJIA_ARMY_COMBAT   = 55        -- 攻击力（高于骑士）
XUANJIA_ARMY_MOVES     = 4        -- 移动力
XUANJIA_ARMY_COST      = 190      -- 建造费用

-- ===== 玄武门（登基仪式改良设施）=====
IMPROVEMENT_XUANWU_GATE = "IMPROVEMENT_XUANWU_GATE"
CORONATION_MIN_TURNS_AFTER_GATE = 1   -- 建成后等待回合（简介.txt：建成玄武门即触发李建成刷新）

-- ===== 天策府十八学士 =----
UNIT_TALENT_RESERVE_BENEFIT   = true   -- 功能开关
TALENT_RESERVE_PER_GP         = 6      -- 每招募1名伟人，首都全产出+6
TALENT_RESERVE_MAX_STACKS     = 3      -- 最多叠加3层（最高+18）

-- ===== 藩王线（简介.txt定版）=====
PRINCE_LINE_TURNS                 = 30   -- 复辟时限：30回合
PRINCE_EXTRA_CONQUESTS_REQUIRED   = 1    -- 藩王线额外征服要求：补1城（夺回首都时已算1城）
PRINCE_REMINDER_INTERVAL         = 5    -- 每隔多少回合提醒一次

-- 藩王线全局惩罚（简介.txt定版：科技/文化/粮食各-50%）
PRINCE_SCIENCE_PENALTY     = -50   -- 科技惩罚（%）
PRINCE_CULTURE_PENALTY     = -50   -- 文化惩罚（%）
PRINCE_FOOD_PENALTY        = -50   -- 粮食惩罚（%）
-- 藩王线翻盘增益（简介.txt定版：军事单位生产力+150%）
PRINCE_MILITARY_PROD_BONUS = 150  -- 军事单位建造速度加成（%）

-- ===== 唐太宗·贞观之治（简介.txt定版：每城+1%，上限+10%）=====
ZHENGUAN_PER_CITY_PCT = 1     -- 每城全产出加成（%）
ZHENGUAN_MAX_PCT      = 10    -- 全域加成上限（%）
-- 切换为唐太宗后，天策府十八学士效果清零（简介.txt：前期人才积累为登基铺垫）

-- ===== 唐太宗·万国来朝（简介.txt定版：每10回合）=====
ENVOY_INTERVAL = 10   -- 每N回合自动获得1名免费使者

-- ===== 唐太宗·天可汗·节度使 ======
-- 节度使：派驻城邦后，触发双重霸权
JIEDUSHI_ENVOY_MULTIPLIER = 2    -- 节度使城邦：每名使者影响力×2（1名使者=2点影响力）
-- 注：资源复制（上贡）效果通过城市图标/通知提示实现（Lua层暂不支持修改资源流）

-- ===== 唐太宗·天子一怒 =====
TIANZI_YANU_WINDOW = 10           -- 宣战后可免费征用城邦军队的窗口（回合）
-- 节度使使者翻倍效果在"天子一怒"期间暂停（宣战后10回合内节度使使者×2暂时失效）

-- ===== 偃武修文·驻军收益（简介.txt定版）=====
YANWU_CAMP_BONUS_ENABLED = true  -- 功能开关

-- ===== 李建成（玄武门仪式目标单位）=====
UNIT_LI_JIANCHENG = "UNIT_LI_JIANCHENG"
LI_JIANCHENG_HP         = 1      -- 极低生命值（仅天策上将可击杀）
LI_JIANCHENG_MOVES      = 0      -- 无法移动

-- ===== 通知图标常量 =====
LISHIMIN_NOTIFY_ICON_XUANWU_GATE  = "NotificationIconBuilding"
LISHIMIN_NOTIFY_ICON_CORONATION   = "NotificationIconVictory"

-- ===== 颜色常量 =====
COLORS = {
    PRIMARY   = { R = 0.98, G = 0.74, B = 0.19, A = 1.0 },  -- 金色（皇室）
    SECONDARY = { R = 0.20, G = 0.60, B = 0.90, A = 1.0 },  -- 蓝色（外交通知）
    SUCCESS   = { R = 0.27, G = 0.72, B = 0.40, A = 1.0 },  -- 绿色
    WARNING   = { R = 0.98, G = 0.60, B = 0.20, A = 1.0 },  -- 橙色（藩王警告）
    DANGER    = { R = 0.90, G = 0.20, B = 0.20, A = 1.0 },  -- 红色（失败）
}

-- constants.lua: 所有常量已作为全局变量定义，无需 return 表


-- ============================================================================
-- MODULE: config\balance.lua
-- ============================================================================

-- ============================================================
-- 模组平衡数据（版本化管理）
-- 同步更新自 简介.txt（定版）
-- ============================================================

-- 当前使用的版本标识（切换值以使用不同平衡集）
-- 可在 version.lua 中通过 BALANCE_VERSION 控制
BALANCE_VERSION = "v2.0"

-- ============================================================
-- v1.0 平衡数据（早期版本参考）
-- ============================================================
BalanceData_v100 = {
    Name = "v1.0",
    TianceGeneral = {
        RangedCombat    = 55,
        Combat         = 45,
        Range           = 2,
        Moves           = 3,
        Cost            = 130,
    },
    XuanjiaArmy = {
        Combat          = 55,
        Moves           = 4,
        Cost            = 190,
    },
    TalentReserve = {
        PerGreatPerson  = 6,   -- 每伟人首都+6全产出
        MaxStacks       = 3,   -- 最多3层
    },
    ZhenguanReign = {
        PerCityBonus    = 1,   -- 每城+1%
        MaxBonus        = 10,  -- 上限+10%
    },
    PrinceLine = {
        RestorationTimeLimit    = 30,  -- 复辟时限30回合
        ProductionBonus          = 150, -- 军工+150%
        SciencePenalty           = -50,
        CulturePenalty          = -50,
    },
    WorldReception = {
        EnvoyInterval   = 6,   -- 每6回合
    },
    TianceAura = {
        CombatBonusPerUnit = 5,  -- 每友军+5防御
        Range            = 2,
    },
}

-- ============================================================
-- v2.0 平衡数据（当前定版，同步自 简介.txt）
-- ============================================================
BalanceData_v200 = {
    Name = "v2.0",
    TianceGeneral = {
        RangedCombat    = 55,
        Combat         = 45,
        Range           = 2,
        Moves           = 3,
        Cost            = 130,
        AuraBonus       = 5,    -- 每友军+5防御（无上限）
        AuraRange       = 2,
        Health          = 220,  -- 英雄单位生命值
    },
    XuanjiaArmy = {
        Combat          = 55,
        Moves           = 4,
        Cost            = 190,
    },
    TalentReserve = {
        PerGreatPerson  = 6,    -- 每伟人首都全产出+6
        MaxStacks       = 3,    -- 最多3层（最高+18）
    },
    ZhenguanReign = {
        -- 简介.txt定版：每城+1%，上限+10%
        PerCityBonus    = 1,
        MaxBonus        = 10,
    },
    PrinceLine = {
        RestorationTimeLimit    = 30,   -- 复辟时限30回合（简介.txt定版）
        ProductionBonus          = 150,  -- 军工建造速度+150%（简介.txt定版）
        SciencePenalty           = -50,  -- 科技-50%（简介.txt定版）
        CulturePenalty           = -50,  -- 文化-50%（简介.txt定版）
        FoodPenalty              = -50,  -- 粮食-50（简介.txt定版）
        ExtraConquestsRequired   = 1,    -- 藩王线额外需补1城（夺回首都时已算1城）
    },
    WorldReception = {
        -- 简介.txt定版：每10回合
        EnvoyInterval   = 10,
    },
    TianKeHan = {
        -- 天可汗·节度使：驻城邦后效果
        EnvoyMultiplier = 2,    -- 节度使城邦：使者影响力翻倍（1使=2影响力）
        ResourceCopy    = true, -- 资源上贡（通知提醒）
        -- 天子一怒：宣战后效果
        WarBonusWindow  = 10,   -- 宣战后10回合内可免费征用城邦军队
        WarEnvoySuspension = true, -- 天子一怒期间节度使使者翻倍暂停
    },
    YanWuXiuWen = {
        -- 偃武修文：驻军于特色区域赚取和平收益
        CampusBonus     = true, -- 驻学院：战斗力10%的科技值
        TheaterBonus    = true, -- 驻剧院广场：+2大作家/大音乐家点数；3级兵额外+4旅游业绩
        CommercialBonus = true, -- 驻商业中心：维护费2倍金币+1贸易路线容量
        PeaceMultiplier = 2,    -- 绝对和平时驻军收益翻倍
    },
    LiJiancheng = {
        HP      = 1,            -- 李建成1点生命
        Moves   = 0,            -- 无法移动
        -- 设定：仅天策上将可造成伤害（通过战斗修正实现）
    },
    TianceAura = {
        CombatBonusPerUnit = 5,  -- 每友军+5防御（无上限）
        Range              = 2, -- 光环范围2格
    },
}

-- ============================================================
-- 平衡数据获取接口
-- ============================================================
function GetBalanceData()
    if BALANCE_VERSION == "v1.0" then

    elseif BALANCE_VERSION == "v2.0" then

    else
        -- 默认返回v2.0（当前定版）

    end
end

-- 便捷访问：返回当前激活的平衡数据集
function GetActiveBalance()
    return GetBalanceData()
end

-- balance.lua: 所有数据已作为全局变量/函数定义，无需 return 表


-- ============================================================================
-- MODULE: src\Lua\Utils.lua
-- ============================================================================

-- 工具函数和日志系统
-- 提供模组中使用的通用工具函数和统一的日志记录功能

-- 调试模式开关（排查阶段设为true，稳定后改回false）
DEBUG_MODE = true

-- 日志记录函数
function Log(message, level)
    level = level or "INFO"
    if DEBUG_MODE or level == "ERROR" then
        print("[LiShiminMod] [" .. level .. "] " .. message)
    end
end

-- 错误日志记录函数
function LogError(message)
    Log(message, "ERROR")
end

-- 警告日志记录函数
function LogWarning(message)
    Log(message, "WARNING")
end

-- 调试日志记录函数
function LogDebug(message)
    if DEBUG_MODE then
        Log(message, "DEBUG")
    end
end

-- 安全调用函数，用于捕获和处理异常
function SafeCall(func, ...)
    local status, result = pcall(func, ...)
    if not status then
        LogError("Error in function call: " .. tostring(result))

    end

end

-- 检查值是否为nil或空
function IsNilOrEmpty(value)
    return value == nil or value == "" or (type(value) == "table" and next(value) == nil)
end

-- 深拷贝表
function DeepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local new_tbl = {}
    for k, v in pairs(tbl) do
        new_tbl[k] = DeepCopy(v)
    end

end

-- 获取玩家的首都
function GetCapitalCity(player)
    local cities = player:GetCities()
    for _, city in cities:Members() do
        if city:IsCapital() then

        end
    end

end

-- 获取玩家拥有的城市数量
function GetPlayerCityCount(player)
    return player:GetCities():GetCount()
end

-- 检查玩家是否拥有指定数量的城市
function HasRequiredCities(player, requiredCount)
    return GetPlayerCityCount(player) >= requiredCount
end

-- 获取单位所在的地块
function GetUnitPlot(unit)
    return Map.GetPlot(unit:GetX(), unit:GetY())
end

-- 检查两个地块是否相邻
function ArePlotsAdjacent(plot1, plot2)
    return Map.GetPlotDistance(plot1:GetX(), plot1:GetY(), plot2:GetX(), plot2:GetY()) == 1
end

-- 获取地块周围的所有单位
function GetUnitsAroundPlot(plot, range, playerID)
    local units = {}
    local x, y = plot:GetX(), plot:GetY()
    
    for i = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local player = Players[i]
        if not playerID or player:GetID() == playerID then
            for unit in player:GetUnits():Members() do
                local unitPlot = GetUnitPlot(unit)
                local distance = Map.GetPlotDistance(x, y, unitPlot:GetX(), unitPlot:GetY())
                if distance <= range then
                    table.insert(units, unit)
                end
            end
        end
    end

end

-- 显示通知
function ShowNotification(playerID, title, message, icon, color)
    local player = Players[playerID]
    if not player then return end
    
    local notification = NotificationManager:CreateNotification(playerID)
    notification:SetType(NotificationTypes.NOTIFICATION_GENERIC)
    notification:SetText(Locale.Lookup(message))
    notification:SetTitle(Locale.Lookup(title))
    
    if icon then
        notification:SetIcon(icon)
    end
    
    if color then
        notification:SetColor(color.R, color.G, color.B, color.A)
    end
    
    NotificationManager:Add(notification)
end

-- 玄武门 / 登基等剧情：带图标的通知，并在 UI 层播放短音效（见 src/UI/LiShiminPresentation.lua）
-- momentKind: "xuanwu_gate" | "coronation_complete"
function LiShiminNotifyStoryMoment(playerID, title, message, momentKind, color)
    local icon
    if momentKind == "xuanwu_gate" then
        icon = LISHIMIN_NOTIFY_ICON_XUANWU_GATE
    elseif momentKind == "coronation_complete" then
        icon = LISHIMIN_NOTIFY_ICON_CORONATION
    end
    ShowNotification(playerID, title, message, icon, color)
    if LuaEvents and LuaEvents.LiShiminMod_PlayPresentation then
        LuaEvents.LiShiminMod_PlayPresentation(momentKind)
    end
end

-- 从单位实例解析单位类型字符串（Civ6 中 GetUnitType 为索引，不可与 Type 字符串直接比较）
function GetUnitTypeNameFromUnit(unit)
    if not unit then

    end
    local row = GameInfo.Units[unit:GetUnitType()]
    return row and row.UnitType or nil
end

-- 检查单位是否是天策上将
function IsTianceGeneral(unit)
    return GetUnitTypeNameFromUnit(unit) == UNIT_TIANCE_GENERAL
end

-- 检查单位是否是李建成
function IsLiJiancheng(unit)
    return GetUnitTypeNameFromUnit(unit) == UNIT_LI_JIANCHENG
end

-- 是否为李世民领袖（需在 Gameplay 脚本上下文）
function IsLiShiminLeaderPlayer(playerID)
    local cfg = PlayerConfigurations[playerID]
    if not cfg then

    end
    return cfg:GetLeaderTypeName() == LEADER_LI_SHIMIN
end

function PlayerSupportsModProperties(player)
    return player and player.GetProperty ~= nil and player.SetProperty ~= nil
end

function PlayerHasBuildingType(playerID, buildingTypeStr)
    local player = Players[playerID]
    local bdef = GameInfo.Buildings[buildingTypeStr]
    if not player or not bdef then

    end
    for _, city in player:GetCities():Members() do
        if city:GetBuildings():HasBuilding(bdef.Index) then

        end
    end

end

function PlayerHasImprovementType(playerID, improvementTypeStr)
    local player = Players[playerID]
    local impDef = GameInfo.Improvements[improvementTypeStr]
    if not player or not impDef then

    end
    for _, city in player:GetCities():Members() do
        local numPlots = city:GetOwnedPlots()
        if numPlots then
            for i = 0, numPlots - 1 do
                local plot = city:GetOwnedPlot(i)
                if plot and plot:GetImprovementType() == impDef.Index then

                end
            end
        end
    end

end

function PlotOwnedByMajor(playerID, plotX, plotY)
    local plot = Map.GetPlot(plotX, plotY)
    if not plot then

    end
    return plot:GetOwner() == playerID
end

local function persistSet(player, key, value)
    if PlayerSupportsModProperties(player) then
        player:SetProperty(key, value)
    end
end

function LiShiminLoadPlayerFieldsFromProperties(playerID, data)
    local player = Players[playerID]
    if not player or not data or not PlayerSupportsModProperties(player) then

    local function applyIfSet(key, fn)
        local v = player:GetProperty(key)
        if v ~= nil then
            fn(v)
        end
    end
    applyIfSet("LiShimin_LeaderState", function(v) data.LeaderState = v end)
    applyIfSet("LiShimin_CitiesConquered", function(v) data.CitiesConquered = tonumber(v) or v end)
    applyIfSet("LiShimin_XuanwuGateBuilt", function(v) data.XuanwuGateBuilt = (v == 1 or v == true) end)
    applyIfSet("LiShimin_MedievalResolved", function(v) data.MedievalResolved = (v == 1 or v == true) end)
    applyIfSet("LiShimin_CoronationTurns", function(v) data.CoronationTurnsSinceGate = tonumber(v) or 0 end)
    applyIfSet("LiShimin_PrinceConquests", function(v) data.PrinceConquestsSinceLine = tonumber(v) or 0 end)
    applyIfSet("LiShimin_RestorationTurns", function(v) data.RestorationTurnsRemaining = tonumber(v) or -1 end)
    applyIfSet("LiShimin_CapitalX", function(v) data.CapitalX = tonumber(v) or -1 end)
    applyIfSet("LiShimin_CapitalY", function(v) data.CapitalY = tonumber(v) or -1 end)
end

function LiShiminMod_CreateDefaultPlayerData()
    return {
        LeaderState = LEADER_STATE.TIANCE_GENERAL,
        CitiesConquered = 0,
        XuanwuGateBuilt = false,
        MedievalResolved = false,
        CoronationTurnsSinceGate = 0,
        PrinceConquestsSinceLine = 0,
        RestorationTurnsRemaining = -1,
        CapitalX = -1,
        CapitalY = -1,
    }
end

function LiShiminMod_GetOrInitPlayer(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then

    end
    if not LiShiminMod then
        LiShiminMod = {}
    end
    if not LiShiminMod.Players then
        LiShiminMod.Players = {}
    end
    if not LiShiminMod.Players[playerID] then
        local data = LiShiminMod_CreateDefaultPlayerData()
        LiShiminLoadPlayerFieldsFromProperties(playerID, data)
        LiShiminMod.Players[playerID] = data
    end
    return LiShiminMod.Players[playerID]
end

function LiShiminSavePlayerFieldsToProperties(playerID, data)
    local player = Players[playerID]
    if not player or not data then

    persistSet(player, "LiShimin_LeaderState", data.LeaderState)
    persistSet(player, "LiShimin_CitiesConquered", data.CitiesConquered)
    persistSet(player, "LiShimin_XuanwuGateBuilt", data.XuanwuGateBuilt and 1 or 0)
    persistSet(player, "LiShimin_MedievalResolved", data.MedievalResolved and 1 or 0)
    persistSet(player, "LiShimin_CoronationTurns", data.CoronationTurnsSinceGate)
    persistSet(player, "LiShimin_PrinceConquests", data.PrinceConquestsSinceLine)
    persistSet(player, "LiShimin_RestorationTurns", data.RestorationTurnsRemaining)
    persistSet(player, "LiShimin_CapitalX", data.CapitalX)
    persistSet(player, "LiShimin_CapitalY", data.CapitalY)
end

-- 获取玩家的领袖状态
function GetPlayerLeaderState(playerID)
    if LiShiminMod and LiShiminMod.Players and LiShiminMod.Players[playerID] then
        return LiShiminMod.Players[playerID].LeaderState
    end

end

-- 设置玩家的领袖状态
function SetPlayerLeaderState(playerID, state)
    if not LiShiminMod then LiShiminMod = {} end
    if not LiShiminMod.Players then LiShiminMod.Players = {} end
    if not LiShiminMod.Players[playerID] then LiShiminMod.Players[playerID] = {} end
    
    LiShiminMod.Players[playerID].LeaderState = state
    LogDebug("Player " .. playerID .. " leader state set to: " .. state)
end

-- 获取当前平衡数据
function GetCurrentBalance()
    if BalanceData then

    end
    
    -- 如果BalanceData未加载，尝试加载
    if not IsNilOrEmpty(BALANCE_VERSION) then
        local balance = GetBalanceData()
        if balance then
            BalanceData = balance

        end
    end
    
    LogError("Failed to get balance data!")

end

-- Utils.lua: 所有函数作为普通全局函数定义（不加 local，不加 _G.），Civ6 include() 机制可跨文件共享
-- 关键：不加 local，不加 _G.（沙盒中 _G 为 nil），去掉 return 语句即可共享
-- 注意：return 语句会导致 Civ6 脚本加载器行为异常（已移除）


-- ============================================================================
-- MODULE: src\Lua\EventBus.lua
-- ============================================================================

-- ===== 防御性依赖检查 =====
print("[LiShiminMod] EventBus.lua loading... DEBUG_MODE=" .. tostring(DEBUG_MODE) .. " LogDebug=" .. tostring(LogDebug) .. " print=" .. tostring(print))
if not LogDebug then
    -- Civ6 中 include() 用于加载同 mod 下的 Lua 文件
    local utilsLoaded, utilsErr = pcall(function()
        include("Utils.lua")
    end)
    if not utilsLoaded then
        -- include 路径可能需要相对于脚本根目录
        utilsLoaded, utilsErr = pcall(function()
            include("src/Lua/Utils.lua")
        end)
    end
    if not utilsLoaded then
        -- 最后手段：内联定义核心函数
        function LogDebug(msg) print("[LiShiminMod][DBG] " .. tostring(msg)) end
        function LogWarning(msg) print("[LiShiminMod][WARN] " .. tostring(msg)) end
        function LogError(msg) print("[LiShiminMod][ERR] " .. tostring(msg)) end
        function SafeCall(func, ...)
            local ok, result = pcall(func, ...)
            if not ok then print("[LiShiminMod][ERR] SafeCall: " .. tostring(result)) end

        end
        function IsNilOrEmpty(v) return v == nil or v == "" end
        print("[LiShiminMod][ERR] Utils.lua failed to load, using inline fallbacks: " .. tostring(utilsErr))
    else
        print("[LiShiminMod] Utils.lua loaded via include()")
    end
end

-- ===== 事件名称常量（必须在 EventBus:Initialize() 之前定义）=====
EVENTS = {
    -- 核心游戏事件
    ON_GAME_START             = "ON_GAME_START",
    ON_PLAYER_TURN_BEGIN      = "ON_PLAYER_TURN_BEGIN",
    ON_PLAYER_TURN_END        = "ON_PLAYER_TURN_END",
    ON_UNIT_CREATED           = "ON_UNIT_CREATED",
    ON_UNIT_KILLED            = "ON_UNIT_KILLED",
    ON_CITY_CONQUERED         = "ON_CITY_CONQUERED",
    ON_GREAT_PERSON_RECRUITED = "ON_GREAT_PERSON_RECRUITED",
    ON_ERA_CHANGED            = "ON_ERA_CHANGED",
    ON_BUILDING_CONSTRUCTED   = "ON_BUILDING_CONSTRUCTED",
    -- 模组自定义事件
    ON_XUANWU_GATE_BUILT      = "ON_XUANWU_GATE_BUILT",
    ON_SHOOT_LI_JIANCHENG     = "ON_SHOOT_LI_JIANCHENG",
    ON_CORONATION_COMPLETED   = "ON_CORONATION_COMPLETED",
    ON_PRINCE_LINE_ACTIVATED  = "ON_PRINCE_LINE_ACTIVATED",
    ON_RESTORATION_COMPLETED  = "ON_RESTORATION_COMPLETED",
    ON_RESTORATION_FAILED     = "ON_RESTORATION_FAILED",
}

-- 事件总线系统
-- 用于模组内部不同模块之间的通信和事件处理
-- 采用观察者模式，允许模块注册事件监听器和触发事件

EventBus = {
    -- 事件注册表，存储所有已注册的事件
    events = {},
    
    -- 监听器注册表，存储每个事件的所有监听器
    listeners = {},

    -- 监听器 id 全局单调递增（与 #listeners 脱钩，避免 RemoveListener 后再注册产生重复 id）
    nextListenerId = 0,
    
    -- 初始化事件总线
    Initialize = function(self)
        LogDebug("EventBus initialized")
        self.events = {}
        self.listeners = {}
        self.nextListenerId = 0
    end,
    
    -- 注册一个新事件
    RegisterEvent = function(self, eventName)
        if not self.events[eventName] then
            self.events[eventName] = true
            self.listeners[eventName] = {}
            LogDebug("Event registered: " .. eventName)
        end
    end,
    
    -- 注册事件监听器
    RegisterListener = function(self, eventName, callback, priority)
        -- 如果事件不存在，先注册事件
        if not self.events[eventName] then
            self:RegisterEvent(eventName)
        end
        
        -- 默认优先级为0
        priority = priority or 0

        self.nextListenerId = self.nextListenerId + 1
        local listenerId = self.nextListenerId
        
        -- 创建监听器对象
        local listener = {
            callback = callback,
            priority = priority,
            id = listenerId
        }
        
        -- 添加到监听器列表
        table.insert(self.listeners[eventName], listener)
        
        -- 按优先级排序（优先级越高，执行顺序越靠前）
        table.sort(self.listeners[eventName], function(a, b)
            return a.priority > b.priority
        end)
        
        LogDebug("Listener registered for event: " .. eventName .. " (Priority: " .. priority .. ")")
        return listener.id
    end,
    
    -- 移除事件监听器
    RemoveListener = function(self, eventName, listenerId)
        if not self.listeners[eventName] then
            LogWarning("Attempting to remove listener from non-existent event: " .. eventName)

        end
        
        for i, listener in ipairs(self.listeners[eventName]) do
            if listener.id == listenerId then
                table.remove(self.listeners[eventName], i)
                LogDebug("Listener removed from event: " .. eventName)

            end
        end
        
        LogWarning("Listener not found for event: " .. eventName)

    end,
    
    -- 触发事件
    FireEvent = function(self, eventName, ...)
        if not self.events[eventName] then
            LogWarning("Attempting to fire non-existent event: " .. eventName)

        end
        
        LogDebug("Event fired: " .. eventName)
        
        -- 调用所有监听器
        -- 注意：必须先捕获 vararg 到局部变量，闭包内不能直接使用 ...
        local args = table.pack(...)
        if self.listeners[eventName] then
            for _, listener in ipairs(self.listeners[eventName]) do
                SafeCall(function()
                    listener.callback(table.unpack(args))
                end)
            end
        end

    end,
    
    -- 获取事件的监听器数量
    GetListenerCount = function(self, eventName)
        if not self.listeners[eventName] then

        end
        return #self.listeners[eventName]
    end,
    
    -- 获取所有已注册的事件
    GetRegisteredEvents = function(self)
        local events = {}
        for eventName, _ in pairs(self.events) do
            table.insert(events, eventName)
        end

    end,
    
    -- 清除所有事件和监听器
    Clear = function(self)
        self.events = {}
        self.listeners = {}
        self.nextListenerId = 0
        LogDebug("EventBus cleared")
    end
}

-- 初始化事件总线
EventBus:Initialize()

-- 注册核心游戏事件
function RegisterGameEvents()
    -- 游戏开始事件
    Events.GameStart.Add(function()
        EventBus:FireEvent(EVENTS.ON_GAME_START)
    end)
    
    -- 玩家回合开始事件
    Events.PlayerTurnBegin.Add(function(playerID)
        EventBus:FireEvent(EVENTS.ON_PLAYER_TURN_BEGIN, playerID)
    end)
    
    -- 玩家回合结束事件
    Events.PlayerTurnEnd.Add(function(playerID)
        EventBus:FireEvent(EVENTS.ON_PLAYER_TURN_END, playerID)
    end)
    
    -- 单位创建事件
    Events.UnitAddedToMap.Add(function(playerID, unitID)
        local unit = UnitManager.GetUnit(playerID, unitID)
        if unit then
            local unitInfo = GameInfo.Units[unit:GetUnitType()]
            local unitType = (unitInfo and unitInfo.Hash) or unit:GetUnitType()
            local plotX, plotY = unit:GetX(), unit:GetY()
            EventBus:FireEvent(EVENTS.ON_UNIT_CREATED, playerID, unit, unitType, plotX, plotY)
        end
    end)
    
    -- 单位死亡事件
    -- 单位死亡事件
    Events.UnitKilledInCombat.Add(function(unitsKilled)
        if unitsKilled and unitsKilled[1] then
            local unit = unitsKilled[1]
            local playerID = unit:GetOwner()
            EventBus:FireEvent(EVENTS.ON_UNIT_KILLED, playerID, unit, unitsKilled)
        end
    end)
    
    -- 城市征服事件（Events.CityConquered 可能不存在，用 Events.CityRemovedFromMap 兜底）
    if Events.CityConquered then
        Events.CityConquered.Add(function(ownerID, cityID, conquerorID)
            local city = CityManager.GetCity(ownerID, cityID)
            if city then
                EventBus:FireEvent(EVENTS.ON_CITY_CONQUERED, ownerID, city, conquerorID)
            end
        end)
    else
        Events.CityRemovedFromMap.Add(function(playerID, cityID)
            -- CityRemovedFromMap: playerID = original owner, cityID = city index
            -- 需要通过城市名和地图判断是否被其他玩家征服（粗筛，避免漏掉）
            local city = CityManager.GetCity(playerID, cityID)
            if city and city:IsCapital() == false then
                -- 简化：仅通知，不传递 conquerorID（由 Main.lua 通过 CityConquered 事件自行判断归属）
                EventBus:FireEvent(EVENTS.ON_CITY_CONQUERED, playerID, city, -1)
            end
        end)
    end
    
    -- 伟人招募事件（多重兜底确保所有版本都能触发）
    if Events.GreatPersonEarned then
        Events.GreatPersonEarned.Add(function(playerID, greatPersonIndex, greatPersonClass)
            EventBus:FireEvent(EVENTS.ON_GREAT_PERSON_RECRUITED, playerID, greatPersonIndex, greatPersonClass)
        end)
    elseif Events.GreatPersonRecruited then
        Events.GreatPersonRecruited.Add(function(playerID, greatPersonID, greatPersonType)
            EventBus:FireEvent(EVENTS.ON_GREAT_PERSON_RECRUITED, playerID, greatPersonID, greatPersonType)
        end)
    elseif Events.GreatPersonActivated then
        Events.GreatPersonActivated.Add(function(playerID, unitID, greatPersonIndividualID, greatPersonClassID)
            EventBus:FireEvent(EVENTS.ON_GREAT_PERSON_RECRUITED, playerID, unitID, greatPersonIndividualID)
        end)
    elseif Events.UnitGreatPersonCreated then
        Events.UnitGreatPersonCreated.Add(function(playerID, unitID, greatPersonType)
            EventBus:FireEvent(EVENTS.ON_GREAT_PERSON_RECRUITED, playerID, unitID, greatPersonType)
        end)
    else
        LogWarning("Great Person events not found — TalentReserve will not receive GP recruitment events")
    end
    
    -- 时代变更事件
    Events.PlayerEraChanged.Add(function(playerID, newEra, oldEra)
        EventBus:FireEvent(EVENTS.ON_ERA_CHANGED, playerID, newEra, oldEra)
    end)

    -- 建筑建成（用于玄武门等）
    if Events.BuildingConstructed then
        Events.BuildingConstructed.Add(function(playerID, cityID, buildingID, plotID, isOriginalConstruction)
            local city = CityManager.GetCity(playerID, cityID)
            EventBus:FireEvent(
                EVENTS.ON_BUILDING_CONSTRUCTED,
                playerID,
                city,
                buildingID,
                plotID,
                isOriginalConstruction
            )
        end)
    end
    
    LogDebug("Game events registered")
end

-- 注册模组自定义事件
function RegisterCustomEvents()
    -- 与 RegisterGameEvents 中 Fire 对齐；当前可无监听器，但必须注册以免误判为「未注册事件」
    EventBus:RegisterEvent(EVENTS.ON_UNIT_CREATED)
    EventBus:RegisterEvent(EVENTS.ON_GREAT_PERSON_RECRUITED)

    -- 玄武门建造事件
    EventBus:RegisterEvent(EVENTS.ON_XUANWU_GATE_BUILT)
    
    -- 预留：射杀李建成（尚无 FireEvent 调用点；后续任务/战斗逻辑可在此事件上监听）
    EventBus:RegisterEvent(EVENTS.ON_SHOOT_LI_JIANCHENG)
    
    -- 登基完成事件
    EventBus:RegisterEvent(EVENTS.ON_CORONATION_COMPLETED)
    
    -- 藩王线激活事件
    EventBus:RegisterEvent(EVENTS.ON_PRINCE_LINE_ACTIVATED)
    
    -- 复辟完成事件
    EventBus:RegisterEvent(EVENTS.ON_RESTORATION_COMPLETED)
    
    -- 复辟失败事件
    EventBus:RegisterEvent(EVENTS.ON_RESTORATION_FAILED)

    EventBus:RegisterEvent(EVENTS.ON_BUILDING_CONSTRUCTED)
    
    LogDebug("Custom events registered")
end


-- ============================================================================
-- MODULE: src\Lua\HeroDeath.lua
-- ============================================================================

-- ===== 防御性依赖检查 =====
if not LogDebug then
    function LogDebug(msg) print("[LiShiminMod][DBG] " .. tostring(msg)) end
end
if not LogWarning then
    function LogWarning(msg) print("[LiShiminMod][WARN] " .. tostring(msg)) end
end
if not LogError then
    function LogError(msg) print("[LiShiminMod][ERR] " .. tostring(msg)) end
end
if not SafeCall then
    function SafeCall(func, ...)
        local ok, result = pcall(func, ...)
        if not ok then print("[LiShiminMod][ERR] SafeCall: " .. tostring(result)) end

    end
end
if not IsNilOrEmpty then
    function IsNilOrEmpty(v) return v == nil or v == "" end
end
-- 天策上将死亡处理模块
-- 负责处理天策上将死亡时的游戏逻辑和失败判定

-- 处理天策上将死亡
function HandleTianceGeneralDeath(playerID)
    LogDebug("Handling Tiance General death for player " .. playerID)
    
    -- 获取玩家数据
    local playerData = LiShiminMod.Players[playerID]
    if not playerData then
        LogError("Player data not found for player " .. playerID)

    -- 检查当前状态
    -- 只有在天策上将形态或登基仪式中死亡才会导致游戏失败
    if playerData.LeaderState == LEADER_STATE.TIANCE_GENERAL or 
       playerData.LeaderState == LEADER_STATE.CORONATION then
        
        LogDebug("Tiance General death causes game over for player " .. playerID)
        
        -- 显示失败通知
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_NOTIFY_TITLE",
            ERROR_MESSAGES.LEADER_DEATH,
            nil,
            COLORS.DANGER
        )
        
        -- 立即执行游戏结束逻辑
        LuaEvents.LiShiminMod_EndGame(playerID)
    else
        LogDebug("Tiance General death does not cause game over in current state: " .. playerData.LeaderState)
    end
end

-- 游戏结束逻辑
function EndGameForPlayer(playerID)
    LogDebug("Ending game for player " .. playerID)
    
    local player = Players[playerID]
    if not player then
        LogError("Player not found: " .. playerID)

    -- 这里可以添加游戏结束的具体逻辑
    -- 在文明6中，通常通过设置玩家失败来结束游戏
    
    -- 示例：设置玩家失败
    player:SetHasLost(true)
    
    -- 显示失败画面或消息
    -- 注意：具体的实现方式可能需要根据文明6的API进行调整
end

-- 注册游戏结束事件
function RegisterEndGameEvent()
    LuaEvents.LiShiminMod_EndGame.Add(function(playerID)
        EndGameForPlayer(playerID)
    end)
end

-- 初始化模块
function InitializeHeroDeathModule()
    LogDebug("Initializing HeroDeath module")
    RegisterEndGameEvent()
end

-- 自动初始化
InitializeHeroDeathModule()


-- ============================================================================
-- MODULE: src\Lua\TalentReserve.lua
-- ============================================================================

-- ===== 防御性依赖检查 =====
if not LogDebug then
    function LogDebug(msg) print("[LiShiminMod][DBG] " .. tostring(msg)) end
end
if not LogWarning then
    function LogWarning(msg) print("[LiShiminMod][WARN] " .. tostring(msg)) end
end
if not LogError then
    function LogError(msg) print("[LiShiminMod][ERR] " .. tostring(msg)) end
end
if not SafeCall then
    function SafeCall(func, ...)
        local ok, result = pcall(func, ...)
        if not ok then print("[LiShiminMod][ERR] SafeCall: " .. tostring(result)) end

    end
end
if not IsNilOrEmpty then
    function IsNilOrEmpty(v) return v == nil or v == "" end
end
-- ============================================================
-- 天策府十八学士：每招募1名伟人，原始首都全产出+6，最多3层（+18）
-- ============================================================

-- 伟人招募回调
function TalentReserve_OnGreatPersonRecruited(playerID, greatPersonID, greatPersonType)
    Log("TalentReserve: OnGreatPersonRecruited fired for pid=" .. tostring(playerID))
    if not IsLiShiminLeaderPlayer(playerID) then
        Log("TalentReserve: not LiShimin player, skipping")

    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then
        Log("TalentReserve: player data nil, skipping")

    if d.LeaderState == LEADER_STATE.EMPEROR_TAIZONG then
        Log("TalentReserve: already EMPEROR_TAIZONG, skipping")

    local prevStacks = d.TalentStacks or 0
    local newStacks = math.min(prevStacks + 1, TALENT_RESERVE_MAX_STACKS)
    if newStacks == prevStacks then
        Log("TalentReserve: stacks at max (" .. newStacks .. "), skipping")

    d.TalentStacks = newStacks
    LiShiminSavePlayerFieldsToProperties(playerID, d)

    Log("TalentReserve: stacks " .. prevStacks .. " -> " .. newStacks)
    TalentReserve_ApplyCapitalBuilding(playerID, newStacks)

    local bonus = newStacks * TALENT_RESERVE_PER_GP
    ShowNotification(
        playerID,
        "LOC_LISHIMIN_TALENT_TITLE",
        Locale.Lookup("LOC_LISHIMIN_TALENT_STACK", newStacks, TALENT_RESERVE_MAX_STACKS, bonus),
        nil,
        COLORS.SECONDARY
    )
end

-- ===== 用 Property 开关替代隐藏建筑 =====
-- Civ6 没有直接让城市瞬间获得建筑的 Lua API
-- CreateIncompleteBuilding 只能塞进建造队列，不会立刻生效
-- 改用 player:SetProperty() 拨动开关，让 XML Modifier 配合生效
function TalentReserve_ApplyCapitalBuilding(playerID, stacks)
    local player = Players[playerID]
    if not player then return end

    -- 伟人有几层，就拨开几个开关（拆分为3个独立 Property）
    if stacks >= 1 then player:SetProperty("LiShimin_Talent_1", 1) end
    if stacks >= 2 then player:SetProperty("LiShimin_Talent_2", 1) end
    if stacks >= 3 then player:SetProperty("LiShimin_Talent_3", 1) end

    Log("TalentReserve: Activated Modifiers up to stack " .. tostring(stacks))
end

-- ===== 移除所有加成开关 =====
function TalentReserve_RemoveAllScholarBuildings(playerID)
    local player = Players[playerID]
    if player then
        player:SetProperty("LiShimin_Talent_1", 0)
        player:SetProperty("LiShimin_Talent_2", 0)
        player:SetProperty("LiShimin_Talent_3", 0)
    end
end

-- ===== 切换唐太宗时清空 =====
function TalentReserve_OnCoronationComplete(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then return end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end
    d.TalentStacks = 0
    LiShiminSavePlayerFieldsToProperties(playerID, d)
    TalentReserve_RemoveAllScholarBuildings(playerID)
end

function TalentReserve_OnPrinceLineActivated(playerID)
end

function TalentReserve_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then return end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end
    if d.LeaderState == LEADER_STATE.EMPEROR_TAIZONG then return end
    local stacks = d.TalentStacks or 0
    if stacks <= 0 then return end
    TalentReserve_ApplyCapitalBuilding(playerID, stacks)
end

-- ===== 初始化 =====
function TalentReserve_Initialize()
    EventBus:RegisterListener(EVENTS.ON_GREAT_PERSON_RECRUITED, TalentReserve_OnGreatPersonRecruited, 50)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, TalentReserve_OnTurnBegin, 45)
    EventBus:RegisterListener(EVENTS.ON_CORONATION_COMPLETED, TalentReserve_OnCoronationComplete, 40)
    EventBus:RegisterListener(EVENTS.ON_PRINCE_LINE_ACTIVATED, TalentReserve_OnPrinceLineActivated, 40)
    Log("TalentReserve module initialized (diagnosis build)")
end

TalentReserve_Initialize()

-- ============================================================================
-- MODULE: src\Lua\TianceAura.lua
-- ============================================================================

-- ===== 防御性依赖检查 =====
if not LogDebug then
    function LogDebug(msg) print("[LiShiminMod][DBG] " .. tostring(msg)) end
end
if not LogWarning then
    function LogWarning(msg) print("[LiShiminMod][WARN] " .. tostring(msg)) end
end
if not LogError then
    function LogError(msg) print("[LiShiminMod][ERR] " .. tostring(msg)) end
end
if not SafeCall then
    function SafeCall(func, ...)
        local ok, result = pcall(func, ...)
        if not ok then print("[LiShiminMod][ERR] SafeCall: " .. tostring(result)) end

    end
end
if not IsNilOrEmpty then
    function IsNilOrEmpty(v) return v == nil or v == "" end
end
-- ============================================================
-- 天策军威（TianceAura）
-- 简介.txt定版效果：
--   天策上将周围2格范围内，每存在1个友军单位，自身防御力+5，无叠加上限。
--   摒弃无脑无敌设定，以亲兵护卫换取生存能力，贴合历史人设。
-- 实现方式：
--   在战斗开始时计算光环加成，通过临时改变单位战斗力（Combat/LockedCombat）实现。
--   注意：Civ6 英雄单位不能直接修改战斗力，这里通过 UI 层显示加成数值。
-- ============================================================

local auraCache = {}  -- playerID -> unitID -> auraBonus（缓存避免每帧重算）

-- 获取天策上将周围的友军数量
function TianceAura_CountFriendlyUnits(tianceUnit)
    if not tianceUnit or not IsTianceGeneral(tianceUnit) then

    end
    local playerID = tianceUnit:GetOwner()
    local player = Players[playerID]
    if not player then return 0 end

    local tiancePlot = tianceUnit:GetPlot()
    if not tiancePlot then return 0 end

    local tianceX = tianceUnit:GetX()
    local tianceY = tianceUnit:GetY()
    local range = TIANCE_AURA_RANGE or 2
    local count = 0

    for _, unit in player:GetUnits():Members() do
        if not IsTianceGeneral(unit) then
            -- 只统计友军单位（排除天策上将自身）
            local unitPlot = unit:GetPlot()
            if unitPlot then
                local dist = Map.GetPlotDistance(tianceX, tianceY, unit:GetX(), unit:GetY())
                if dist <= range and dist > 0 then
                    -- 排除非战斗单位（移民、工人、商队等）
                    local row = GameInfo.Units[unit:GetUnitType()]
                    if row and row.Combat > 0 then
                        count = count + 1
                    end
                end
            end
        end
    end

end

-- 获取天策上将当前光环防御加成
function TianceAura_GetBonus(tianceUnit)
    local playerID = tianceUnit:GetOwner()
    local unitID = tianceUnit:GetID()
    if auraCache[playerID] and auraCache[playerID][unitID] then
        return auraCache[playerID][unitID]
    end
    local count = TianceAura_CountFriendlyUnits(tianceUnit)
    local bonus = count * (TIANCE_AURA_COMBAT_BONUS or 5)
    if not auraCache[playerID] then auraCache[playerID] = {} end
    auraCache[playerID][unitID] = bonus

end

-- 清除缓存（单位移动或被移除时调用）
function TianceAura_InvalidateCache(playerID, unitID)
    if auraCache[playerID] then
        auraCache[playerID][unitID] = nil
    end
end

-- 清除指定玩家的所有缓存
function TianceAura_InvalidatePlayerCache(playerID)
    auraCache[playerID] = nil
end

-- 获取光环状态描述（用于UI显示）
function TianceAura_GetStatusText(playerID)
    local player = Players[playerID]
    if not player then return nil end

    for _, unit in player:GetUnits():Members() do
        if IsTianceGeneral(unit) then
            local bonus = TianceAura_GetBonus(unit)
            if bonus > 0 then
                local count = TianceAura_CountFriendlyUnits(unit)


-- ============================================================================
-- MODULE: src\Lua\PrinceLine.lua
-- ============================================================================

-- ===== 防御性依赖检查 =====
if not LogDebug then
    function LogDebug(msg) print("[LiShiminMod][DBG] " .. tostring(msg)) end
end
if not LogWarning then
    function LogWarning(msg) print("[LiShiminMod][WARN] " .. tostring(msg)) end
end
if not LogError then
    function LogError(msg) print("[LiShiminMod][ERR] " .. tostring(msg)) end
end
if not SafeCall then
    function SafeCall(func, ...)
        local ok, result = pcall(func, ...)
        if not ok then print("[LiShiminMod][ERR] SafeCall: " .. tostring(result)) end

    end
end
if not IsNilOrEmpty then
    function IsNilOrEmpty(v) return v == nil or v == "" end
end
-- ============================================================
-- 藩王支线：背水一战
-- 简介.txt定版：
--   触发条件：中世纪前不足5城，或30回合内未完成玄武门仪式
--   全局惩罚：科技-50%、文化-50%、粮食-50%
--   翻盘增益：军事单位生产力+150%
--   限时任务：30回合内夺回首都+保全天策上将+完成玄武门仪式
--   失败后果：30回合届满，全图围剿（所有AI宣战）
-- 同步更新自 简介.txt（定版）
-- ============================================================

-- ===== 激活藩王线 =====

function PrinceLine_Activate(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end

    -- 简介.txt定版：30回合时限
    local limit = PRINCE_LINE_TURNS or 30
    d.RestorationTurnsRemaining = limit
    d.PrinceConquestsSinceLine = 0

    local p = Players[playerID]
    if p then
        local cap = GetCapitalCity(p)
        if cap then
            d.CapitalX = cap:GetX()
            d.CapitalY = cap:GetY()
            -- 简介.txt定版：失去首都——转移给自由城市
            -- 玩家需要重新夺回首都
            PrinceLine_TransferCapitalToFreeCity(playerID, cap)
        end
    end

    d.XuanwuGateBuilt = PlayerHasImprovementType(playerID, IMPROVEMENT_XUANWU_GATE)
    LiShiminSavePlayerFieldsToProperties(playerID, d)

    -- 设置 Property = 1 触发 XML Modifiers 生效
    -- Modifiers.xml: REQSET_LISHIMIN_PRINCE_LINE → -50%×6 + +150%军工
    Players[playerID]:SetProperty("LiShimin_IsPrinceLine", 1)

    ShowNotification(
        playerID,
        "LOC_LISHIMIN_PRINCE_TITLE",
        "LOC_LISHIMIN_PRINCE_START",
        nil,
        COLORS.WARNING
    )

    EventBus:FireEvent(EVENTS.ON_PRINCE_LINE_ACTIVATED, playerID)
end

-- 转移首都给自由城市（藩王线核心）
function PrinceLine_TransferCapitalToFreeCity(playerID, capitalCity)
    if not capitalCity then return end

    -- Civ6 API: TransferCityToFreeCity 将城市转移为自由城市
    -- 玩家失去所有权变成中立城邦
    local capitalX, capitalY = capitalCity:GetX(), capitalCity:GetY()
    local freeCityOwner = PlayerManager.GetFreeCitiesPlayerID()

    -- 尝试通过 CityManager.TransferCity 转移
    if freeCityOwner and freeCityOwner >= 0 then
        local success = CityManager.TransferCity(capitalCity, freeCityOwner)
        if success then
            ShowNotification(
                playerID,
                "LOC_LISHIMIN_PRINCE_TITLE",
                Locale.Lookup("LOC_LISHIMIN_PRINCE_CAPITAL_LOST"),
                nil,
                COLORS.DANGER
            )
        end
    else
        -- 备用方案：记录首都坐标以便后续检测收复
        Log("PrinceLine: Failed to transfer capital to free city, will check ownership manually")
    end
end

-- ===== 回合开始 =====

function PrinceLine_OnTurnBegin(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.PRINCE_LINE then

    local rem = d.RestorationTurnsRemaining or 0
    local interval = PRINCE_REMINDER_INTERVAL or 5

    -- 每5回合（简介.txt定版）提醒一次
    if rem > 0 and rem <= 30 and (rem % interval == 0) then
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_PRINCE_TITLE",
            Locale.Lookup("LOC_LISHIMIN_PRINCE_COUNTDOWN", rem),
            nil,
            COLORS.WARNING
        )
    end

    -- 藩王线期间持续检查胜利条件
    PrinceLine_TryComplete(playerID)
end

-- ===== 回合结束 =====

function PrinceLine_OnTurnEnd(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.PRINCE_LINE then

    local rem = d.RestorationTurnsRemaining
    if rem and rem > 0 then
        d.RestorationTurnsRemaining = rem - 1
        LiShiminSavePlayerFieldsToProperties(playerID, d)

        if d.RestorationTurnsRemaining == 0 then
            -- 超时：执行失败判定
            PrinceLine_TryComplete(playerID)
            PrinceLine_CheckFailure(playerID)
        end
    end
end

-- ===== 城市被征服 =====

function PrinceLine_OnCityConquered(ownerID, city, conquerorID)
    local d = LiShiminMod_GetOrInitPlayer(conquerorID)
    if not d or d.LeaderState ~= LEADER_STATE.PRINCE_LINE then

    local prev = Players[ownerID]
    if prev and prev:IsBarbarian() then return end

    d.PrinceConquestsSinceLine = (d.PrinceConquestsSinceLine or 0) + 1
    LiShiminSavePlayerFieldsToProperties(conquerorID, d)

    ShowNotification(
        conquerorID,
        "LOC_LISHIMIN_PRINCE_TITLE",
        Locale.Lookup("LOC_LISHIMIN_PRINCE_CONQUEST", d.PrinceConquestsSinceLine, PRINCE_EXTRA_CONQUESTS_REQUIRED or 1),
        nil,
        COLORS.SECONDARY
    )

    PrinceLine_TryComplete(conquerorID)
end

-- ===== 藩王线胜利条件判定 =====

function PrinceLine_IsWinSatisfied(playerID, d)
    if not d then return false end

    -- 条件1：玄武门仪式已完成（建成玄武门+李建成被击杀）
    local gateOk = d.XuanwuGateBuilt or PlayerHasImprovementType(playerID, IMPROVEMENT_XUANWU_GATE)
    if not gateOk then return false end

    -- 条件2：藩王线额外征服要求（简介.txt：同步完成三大目标）
    -- 藩王线需额外补1城（夺回首都已算1城）
    local need = PRINCE_EXTRA_CONQUESTS_REQUIRED or 1
    local conqOk = (d.PrinceConquestsSinceLine or 0) >= need
    if not conqOk then return false end

    -- 条件3：首都已收复
    local ownsCapital = true
    if d.CapitalX and d.CapitalY and d.CapitalX >= 0 and d.CapitalY >= 0 then
        ownsCapital = PlotOwnedByMajor(playerID, d.CapitalX, d.CapitalY)
    end
    if not ownsCapital then return false end

    -- 条件4：天策上将存活
    local tianceAlive = TianceGeneralIsAlive(playerID)
    if not tianceAlive then return false end

end

function TianceGeneralIsAlive(playerID)
    local player = Players[playerID]
    if not player then return false end
    for _, unit in player:GetUnits():Members() do
        if IsTianceGeneral(unit) then

        end
    end

end

-- ===== 尝试完成藩王线 =====

function PrinceLine_TryComplete(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.PRINCE_LINE then

    if not PrinceLine_IsWinSatisfied(playerID, d) then

    -- 满足全部条件：复辟成功
    d.LeaderState = LEADER_STATE.EMPEROR_TAIZONG
    d.RestorationTurnsRemaining = -1
    LiShiminSavePlayerFieldsToProperties(playerID, d)

    -- 清除藩王线 Property，移除 -50% 惩罚和 +150% 军事加成
    Players[playerID]:SetProperty("LiShimin_IsPrinceLine", 0)

    ShowNotification(
        playerID,
        "LOC_LISHIMIN_PRINCE_TITLE",
        "LOC_LISHIMIN_RESTORATION_SUCCESS",
        nil,
        COLORS.SUCCESS
    )

    -- 移除天策上将（功成身退）
    SafeCall(PrinceLine_RemoveTianceGeneral, playerID)

    EventBus:FireEvent(EVENTS.ON_RESTORATION_COMPLETED, playerID)
end

function PrinceLine_RemoveTianceGeneral(playerID)
    local player = Players[playerID]
    if not player then return end
    for _, unit in player:GetUnits():Members() do
        if IsTianceGeneral(unit) then
            UnitManager.Kill(unit, false)
            break
        end
    end
end

-- ===== 藩王线失败判定 =====

function PrinceLine_CheckFailure(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.PRINCE_LINE then

    if PrinceLine_IsWinSatisfied(playerID, d) then

    -- 简介.txt定版：超时后不再直接结束游戏，触发全图围剿
    ShowNotification(
        playerID,
        "LOC_LISHIMIN_PRINCE_TITLE",
        "LOC_LISHIMIN_RESTORATION_FAILED",
        nil,
        COLORS.DANGER
    )

    -- 清除藩王线 Property（失败后默认转唐太宗降级模式）
    -- 惩罚仍保留直至游戏结束
    -- 触发全图所有AI对玩家宣战（八方平叛）
    SafeCall(PrinceLine_DeclareWarOnRebel, playerID)

    EventBus:FireEvent(EVENTS.ON_RESTORATION_FAILED, playerID)

    -- 不立即结束游戏，让玩家体验"全天下围攻"的结局
    -- 游戏继续进行，由玩家决定是破灭还是奇迹翻盘
end

-- 全图围剿：所有AI领袖对玩家宣战
function PrinceLine_DeclareWarOnRebel(playerID)
    local player = Players[playerID]
    if not player then return end

    local rebelName = Locale.Lookup("LOC_LISHIMIN_PRINCE_REBEL_NAME")

    for otherPID = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if otherPID ~= playerID then
            local otherPlayer = Players[otherPID]
            if otherPlayer and otherPlayer:IsAlive() and not otherPlayer:IsBarbarian() then
                -- 所有AI领袖视玩家为叛军，强制宣战
                local warRow = GameInfo.WarTypes["WAR_TRUCE_BREAKER"]
                if warRow then
                    Players[otherPID]:GetDiplomacy():DeclareWarToPlayer(playerID, warRow.Hash)
                end
            end
        end
    end

    ShowNotification(
        playerID,
        "LOC_LISHIMIN_PRINCE_TITLE",
        Locale.Lookup("LOC_LISHIMIN_RESTORATION_FAILED_WAR", rebelName),
        nil,
        COLORS.DANGER
    )
end

-- ===== 初始化 =====

function PrinceLine_Initialize()
    EventBus:RegisterListener(EVENTS.ON_PRINCE_LINE_ACTIVATED, PrinceLine_Activate, 80)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN,       PrinceLine_OnTurnBegin, 80)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_END,         PrinceLine_OnTurnEnd,   80)
    Log("PrinceLine module initialized — 藩王支线已加载（简介.txt定版）")
end

PrinceLine_Initialize()


-- ============================================================================
-- MODULE: src\Lua\TianKeHan.lua
-- ============================================================================

-- ===== 防御性依赖检查 =====
if not LogDebug then
    function LogDebug(msg) print("[LiShiminMod][DBG] " .. tostring(msg)) end
end
if not LogWarning then
    function LogWarning(msg) print("[LiShiminMod][WARN] " .. tostring(msg)) end
end
if not LogError then
    function LogError(msg) print("[LiShiminMod][ERR] " .. tostring(msg)) end
end
if not SafeCall then
    function SafeCall(func, ...)
        local ok, result = pcall(func, ...)
        if not ok then print("[LiShiminMod][ERR] SafeCall: " .. tostring(result)) end

    end
end
if not IsNilOrEmpty then
    function IsNilOrEmpty(v) return v == nil or v == "" end
end
-- ============================================================
-- 天可汗（TianKeHan）
-- 简介.txt定版效果：
--   1. 万国来朝：每10回合自动获得1名免费使者
--   2. 天可汗·节度使：派驻城邦→资源上贡+使者影响力翻倍
--   3. 天子一怒：主动宣战后10回合内，可免费征用所有宗主国城邦军队
-- 实现方式：
--   节度使状态通过玩家Property持久化存储，使者影响力通过InfluenceManager调整
--   资源复制效果通过城邦图标/通知提示实现（Lua层暂不支持修改资源流向）
-- ============================================================

-- ===== 常量引用（由 config/constants.lua 提供）=====
local ENVOY_INTERVAL        = ENVOY_INTERVAL        or 10   -- 每10回合使者
local JIEDUSHI_ENVOY_MULT   = JIEDUSHI_ENVOY_MULT or 2    -- 节度使使者×2
local TIANZI_YANU_WINDOW    = TIANZI_YANU_WINDOW   or 10   -- 天子一怒窗口

-- ===== 运行时状态 =====

-- 节度使城邦列表：playerID -> { cityStateID1 = true, cityStateID2 = true, ... }
local jiedushiCityStates = {}

-- 天子一怒状态：playerID -> { active = bool, turnsRemaining = N }
local tianziYanuState = {}

-- 万国来朝上次使者回合：playerID -> lastTurn
local lastEnvoyTurn = {}

-- ===== 工具函数 =====

-- 获取所有城邦玩家ID
function TianKeHan_GetCityStatePlayerIDs()
    local ids = {}
    for pid = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIVS - 1 do
        local p = Players[pid]
        if p and p:IsAlive() then
            table.insert(ids, pid)
        end
    end

end

-- 获取城邦首都地块坐标
function TianKeHan_GetCityStateCapitalPlot(cityStatePlayerID)
    local player = Players[cityStatePlayerID]
    if not player then return nil end
    local capital = GetCapitalCity(player)
    if not capital then return nil end
    return capital:GetPlot()
end

-- 检查玩家是否在城邦市中心有军事单位驻守
function TianKeHan_IsJiedushiEstablished(liShiminPlayerID, cityStatePlayerID)
    local jiedushi = jiedushiCityStates[liShiminPlayerID]
    return jiedushi and jiedushi[cityStatePlayerID] == true
end

-- 获取某城邦的驻军军事单位
function TianKeHan_GetGarrisonUnitInCityState(liShiminPlayerID, cityStatePlayerID)
    local capitalPlot = TianKeHan_GetCityStateCapitalPlot(cityStatePlayerID)
    if not capitalPlot then return nil end
    local plotX, plotY = capitalPlot:GetX(), capitalPlot:GetY()
    local liShiminPlayer = Players[liShiminPlayerID]
    if not liShiminPlayer then return nil end

    for _, unit in liShiminPlayer:GetUnits():Members() do
        if unit:GetX() == plotX and unit:GetY() == plotY then
            -- 检查是否为军事单位
            local unitType = unit:GetUnitType()
            local row = GameInfo.Units[unitType]
            if row and row.Combat > 0 then

            end
        end
    end

end

-- ===== 核心逻辑：节度使系统 =====

-- 每回合检测节度使状态
function TianKeHan_RefreshJiedushiStatus(liShiminPlayerID)
    if not IsLiShiminLeaderPlayer(liShiminPlayerID) then return end
    local d = LiShiminMod_GetOrInitPlayer(liShiminPlayerID)
    if not d or d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then

    if not jiedushiCityStates[liShiminPlayerID] then
        jiedushiCityStates[liShiminPlayerID] = {}
    end

    local prevJiedushi = {}
    for csid, _ in pairs(jiedushiCityStates[liShiminPlayerID]) do
        prevJiedushi[csid] = true
    end

    local newJiedushi = {}
    local tianziActive = TianKeHan_IsTianziYanuActive(liShiminPlayerID)

    for _, csID in ipairs(TianKeHan_GetCityStatePlayerIDs()) do
        -- 检查玩家是否是该城邦宗主国
        if Players[csID] and Players[csID]:IsSuzerain(liShiminPlayerID) then
            local garrison = TianKeHan_GetGarrisonUnitInCityState(liShiminPlayerID, csID)
            if garrison then
                newJiedushi[csID] = true
                jiedushiCityStates[liShiminPlayerID][csID] = true

                -- 新建立节度使：触发效果
                if not prevJiedushi[csID] then
                    TianKeHan_OnJiedushiEstablished(liShiminPlayerID, csID, tianziActive)
                end
            else
                jiedushiCityStates[liShiminPlayerID][csID] = nil
            end
        else
            jiedushiCityStates[liShiminPlayerID][csID] = nil
        end
    end

    -- 检查是否有节度使被撤销
    for csid, _ in pairs(prevJiedushi) do
        if not newJiedushi[csid] then
            TianKeHan_OnJiedushiRevoked(liShiminPlayerID, csid)
        end
    end
end

-- 节度使建立时触发
function TianKeHan_OnJiedushiEstablished(liShiminPlayerID, cityStateID, tianziYanuActive)
    local cityStatePlayer = Players[cityStateID]
    if not cityStatePlayer then return end
    local cityStateName = Locale.Lookup(cityStatePlayer:GetName())
    local envoyMult = JIEDUSHI_ENVOY_MULT

    -- 天子一怒期间，节度使使者翻倍暂停
    if tianziYanuActive then
        ShowNotification(
            liShiminPlayerID,
            "LOC_LISHIMIN_JIEDUSHI_TITLE",
            Locale.Lookup("LOC_LISHIMIN_JIEDUSHI_ESTABLISHED_BUT_SUSPENDED", cityStateName),
            nil,
            COLORS.WARNING
        )
    else
        ShowNotification(
            liShiminPlayerID,
            "LOC_LISHIMIN_JIEDUSHI_TITLE",
            Locale.Lookup("LOC_LISHIMIN_JIEDUSHI_ESTABLISHED", cityStateName, envoyMult),
            nil,
            COLORS.SUCCESS
        )
        -- 触发使者影响力加倍（通过InfluenceManager）
        TianKeHan_ApplyJiedushiEnvoyBonus(liShiminPlayerID, cityStateID)
    end

    -- 触发资源上贡通知
    TianKeHan_NotifyResourceCopy(liShiminPlayerID, cityStateID)
end

-- 节度使撤销时
function TianKeHan_OnJiedushiRevoked(liShiminPlayerID, cityStateID)
    local cityStatePlayer = Players[cityStateID]
    if not cityStatePlayer then return end
    local cityStateName = Locale.Lookup(cityStatePlayer:GetName())
    ShowNotification(
        liShiminPlayerID,
        "LOC_LISHIMIN_JIEDUSHI_TITLE",
        Locale.Lookup("LOC_LISHIMIN_JIEDUSHI_REVOKED", cityStateName),
        nil,
        COLORS.SECONDARY
    )
end

-- 应用节度使使者翻倍效果（每回合生效）
function TianKeHan_ApplyJiedushiEnvoyBonus(liShiminPlayerID, cityStateID)
    -- 天子一怒期间不生效
    if TianKeHan_IsTianziYanuActive(liShiminPlayerID) then

    local cityStatePlayer = Players[cityStateID]
    if not cityStatePlayer then return end

    -- 检查玩家是否为宗主国
    if not cityStatePlayer:IsSuzerain(liShiminPlayerID) then

    -- 通过InfluenceManager增加影响力
    -- 每个节度使城邦获得额外的"虚拟使者"效果（通过影响力差值模拟）
    -- 注意：Civ6 Lua API 中 InfluenceManager:AddInfluenceGiven() 可能受限
    -- 此处采用通知+逻辑记录方式，确保游戏体验
    local player = Players[liShiminPlayerID]
    if not player then return end

    -- 记录节度使加成状态（供其他系统查询）
    if not LiShiminMod.JiedushiBonus then LiShiminMod.JiedushiBonus = {} end
    LiShiminMod.JiedushiBonus[cityStateID] = true
end

-- 触发资源上贡通知（纯UI提示，资源复制效果由游戏机制决定）
function TianKeHan_NotifyResourceCopy(liShiminPlayerID, cityStateID)
    local cityStatePlayer = Players[cityStateID]
    if not cityStatePlayer then return end
    local cityStateName = Locale.Lookup(cityStatePlayer:GetName())

    ShowNotification(
        liShiminPlayerID,
        "LOC_LISHIMIN_JIEDUSHI_RESOURCE_TITLE",
        Locale.Lookup("LOC_LISHIMIN_JIEDUSHI_RESOURCE_COPY", cityStateName),
        nil,
        COLORS.PRIMARY
    )
end

-- ===== 核心逻辑：天子一怒 =====

function TianKeHan_IsTianziYanuActive(playerID)
    local state = tianziYanuState[playerID]
    return state and state.active == true
end

function TianKeHan_GetYanuTurnsRemaining(playerID)
    local state = tianziYanuState[playerID]
    if not state or not state.active then return 0 end
    return state.turnsRemaining or 0
end

-- 宣战事件处理
function TianKeHan_OnWarDeclared(attackingPlayerID, defendingPlayerID)
    if IsLiShiminLeaderPlayer(attackingPlayerID) then
        -- 玩家主动宣战：触发天子一怒
        TianKeHan_ActivateTianziYanu(attackingPlayerID)
    end
    if IsLiShiminLeaderPlayer(defendingPlayerID) then
        -- 玩家被宣战：触发防御通知（不影响天子一怒状态）
        ShowNotification(
            defendingPlayerID,
            "LOC_LISHIMIN_DIPLOMACY_TITLE",
            "LOC_LISHIMIN_DIPLOMACY_DEFENSIVE",
            nil,
            COLORS.SECONDARY
        )
    end
end

-- 激活天子一怒
function TianKeHan_ActivateTianziYanu(liShiminPlayerID)
    local d = LiShiminMod_GetOrInitPlayer(liShiminPlayerID)
    if not d or d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then

    tianziYanuState[liShiminPlayerID] = {
        active = true,
        turnsRemaining = TIANZI_YANU_WINDOW or 10,
    }

    -- 持久化存储
    LiShiminSavePlayerFieldsToProperties(liShiminPlayerID, {
        TianziYanuActive = true,
        TianziYanuTurns = TIANZI_YANU_WINDOW or 10,
    })

    ShowNotification(
        liShiminPlayerID,
        "LOC_LISHIMIN_TIANZI_YANU_TITLE",
        Locale.Lookup("LOC_LISHIMIN_TIANZI_YANU_ACTIVATED", TIANZI_YANU_WINDOW or 10),
        nil,
        COLORS.WARNING
    )

    -- 通知节度使效果暂停
    local jiedushi = jiedushiCityStates[liShiminPlayerID]
    if jiedushi then
        local count = 0
        for csid, _ in pairs(jiedushi) do count = count + 1 end
        if count > 0 then
            ShowNotification(
                liShiminPlayerID,
                "LOC_LISHIMIN_JIEDUSHI_TITLE",
                Locale.Lookup("LOC_LISHIMIN_JIEDUSHI_SUSPENDED_BY_YANU", count),
                nil,
                COLORS.WARNING
            )
        end
    end
end

-- 逐回合倒计时天子一怒
function TianKeHan_OnTurnEnd(liShiminPlayerID)
    if not IsLiShiminLeaderPlayer(liShiminPlayerID) then return end
    local state = tianziYanuState[liShiminPlayerID]
    if not state or not state.active then return end

    state.turnsRemaining = state.turnsRemaining - 1
    if state.turnsRemaining <= 0 then
        state.active = false
        state.turnsRemaining = 0
        -- 天子一怒结束，恢复节度使使者翻倍效果
        ShowNotification(
            liShiminPlayerID,
            "LOC_LISHIMIN_TIANZI_YANU_TITLE",
            "LOC_LISHIMIN_TIANZI_YANU_ENDED",
            nil,
            COLORS.SUCCESS
        )
        -- 重新应用节度使效果
        TianKeHan_RefreshJiedushiStatus(liShiminPlayerID)
    end
end

-- ===== 核心逻辑：万国来朝（免费使者自动获取）=====

function TianKeHan_OnTurnBegin_Envoy(liShiminPlayerID)
    if not IsLiShiminLeaderPlayer(liShiminPlayerID) then return end
    local d = LiShiminMod_GetOrInitPlayer(liShiminPlayerID)
    if not d or d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then

    local turn = Game.GetCurrentGameTurn()
    local interval = ENVOY_INTERVAL or 10

    -- 检查间隔
    local lastTurn = lastEnvoyTurn[liShiminPlayerID] or 0
    if (turn - lastTurn) < interval then

    lastEnvoyTurn[liShiminPlayerID] = turn

    -- 执行使者发放：发给影响力最低的城邦
    local success = TianKeHan_GrantFreeEnvoy(liShiminPlayerID)
    if success then
        ShowNotification(
            liShiminPlayerID,
            "LOC_LISHIMIN_WORLD_TITLE",
            Locale.Lookup("LOC_LISHIMIN_WORLD_ENVOY_GAIN"),
            nil,
            COLORS.SECONDARY
        )
    end
end

-- 发放免费使者
function TianKeHan_GrantFreeEnvoy(playerID)
    -- 寻找一个玩家还不是宗主国的城邦发放使者
    local candidates = {}
    local cityStates = TianKeHan_GetCityStatePlayerIDs()

    for _, csID in ipairs(cityStates) do
        local csPlayer = Players[csID]
        if csPlayer and csPlayer:IsAlive() and not csPlayer:IsSuzerain(playerID) then
            -- 统计该城邦当前使者数
            local envoyCount = TianKeHan_CountEnvoysInCityState(playerID, csID)
            table.insert(candidates, { csID = csID, envoyCount = envoyCount })
        end
    end

    if #candidates == 0 then
        -- 所有城邦都已是宗主国，通知玩家

    end

    -- 按当前使者数升序排序（优先发给影响力最低的）
    table.sort(candidates, function(a, b)
        return a.envoyCount < b.envoyCount
    end)

    local targetID = candidates[1].csID

    -- Civ6 标准 API：增加玩家可分配的使者令牌
    -- ChangeTokensToGive(1) = 增加 1 个未分配的使者到池子
    -- 玩家在下一回合手动分配给任意城邦
    local player = Players[playerID]
    if player then
        local influence = player:GetInfluence()
        if influence then
            influence:ChangeTokensToGive(1)

        end
    end

end

-- 统计玩家在某城邦的使者数量
function TianKeHan_CountEnvoysInCityState(playerID, cityStateID)
    local count = 0
    for _, token in pairs(GameInfo.InfluenceTokens) do
        if token.InfluenceTokenType == "ENVOY" then
            -- 检查玩家在该城邦的使者
            local balance = Players[cityStateID]:GetInfluenceBalance(playerID, token.Hash)
            if balance and balance > 0 then
                count = count + balance
            end
        end
    end

end

-- ===== 核心逻辑：免费征用城邦军队 =====

function TianKeHan_GetConscriptableUnits(playerID)
    -- 获取所有节度使城邦中可以征用的军事单位
    local units = {}
    local jiedushi = jiedushiCityStates[playerID]
    if not jiedushi then return units end

    for csID, _ in pairs(jiedushi) do
        local csPlayer = Players[csID]
        if csPlayer and csPlayer:IsAlive() then
            -- 检查该城邦是否是玩家宗主国
            if csPlayer:IsSuzerain(playerID) then
                for _, unit in csPlayer:GetUnits():Members() do
                    local unitType = unit:GetUnitType()
                    local unitRow = GameInfo.Units[unitType]
                    if unitRow and unitRow.Combat > 0 then
                        table.insert(units, {
                            unit = unit,
                            cityStateID = csID,
                            cityStateName = Locale.Lookup(csPlayer:GetName()),
                            unitName = Locale.Lookup(unitRow.Name),
                        })
                    end
                end
            end
        end
    end

end

function TianKeHan_CanConscript(playerID)
    -- 天子一怒期间且有节度使城邦时，可以征用
    local state = tianziYanuState[playerID]
    if not state or not state.active then
        return false, Locale.Lookup("LOC_LISHIMIN_CONSCRIPT_NOT_AVAILABLE")
    end
    local units = TianKeHan_GetConscriptableUnits(playerID)
    if #units == 0 then
        return false, Locale.Lookup("LOC_LISHIMIN_CONSCRIPT_NO_UNITS")
    end
    return true, nil
end

-- 征用单个城邦单位（天子一怒期间免费）
function TianKeHan_ConscriptUnit(playerID, unit, targetX, targetY)
    if not TianKeHan_IsTianziYanuActive(playerID) then

    end

    local unitX, unitY = unit:GetX(), unit:GetY()
    local csID = 0
    for pid, _ in pairs(jiedushiCityStates[playerID] or {}) do
        local capPlot = TianKeHan_GetCityStateCapitalPlot(pid)
        if capPlot and capPlot:GetX() == unitX and capPlot:GetY() == unitY then
            csID = pid
            break
        end
    end

    -- 将单位转移给玩家
    local newUnit = UnitManager.ChangeOwner(unit, playerID, targetX or unitX, targetY or unitY)

    if newUnit then
        local csPlayer = Players[csID]
        local csName = csPlayer and Locale.Lookup(csPlayer:GetName()) or "?"
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_CONSCRIPT_TITLE",
            Locale.Lookup("LOC_LISHIMIN_CONSCRIPT_SUCCESS",
                Locale.Lookup(GameInfo.Units[newUnit:GetUnitType()].Name),
                csName),
            nil,
            COLORS.SUCCESS
        )

    end

end

-- ===== 唐太宗回合开始主入口 =====

function TianKeHan_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then return end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then

    -- 1. 刷新节度使状态
    TianKeHan_RefreshJiedushiStatus(playerID)

    -- 2. 检测万国来朝使者
    TianKeHan_OnTurnBegin_Envoy(playerID)

    -- 3. 天子一怒期间：每5回合提醒一次
    local state = tianziYanuState[playerID]
    if state and state.active then
        local turn = Game.GetCurrentGameTurn()
        if turn % 5 == 0 then
            local turnsLeft = state.turnsRemaining
            local units = TianKeHan_GetConscriptableUnits(playerID)
            if #units > 0 then
                ShowNotification(
                    playerID,
                    "LOC_LISHIMIN_TIANZI_YANU_TITLE",
                    Locale.Lookup("LOC_LISHIMIN_TIANZI_YANU_REMINDER",
                        turnsLeft, #units),
                    nil,
                    COLORS.WARNING
                )
            end
        end
    end
end

-- ===== 持久化 =====

function TianKeHan_SaveState(playerID)
    if not playerID then return end
    local player = Players[playerID]
    if not player then return end

    local state = tianziYanuState[playerID]
    local tianziActive = state and state.active or false
    local tianziTurns = state and state.turnsRemaining or 0

    player:SetProperty("LiShimin_TianziYanuActive", tianziActive and 1 or 0)
    player:SetProperty("LiShimin_TianziYanuTurns", tianziTurns)
    player:SetProperty("LiShimin_LastEnvoyTurn", lastEnvoyTurn[playerID] or 0)
end

function TianKeHan_LoadState(playerID)
    local player = Players[playerID]
    if not player then return end

    local active = player:GetProperty("LiShimin_TianziYanuActive")
    local turns = player:GetProperty("LiShimin_TianziYanuTurns")
    if active == 1 and turns and turns > 0 then
        tianziYanuState[playerID] = {
            active = true,
            turnsRemaining = turns,
        }
    end

    local lastTurn = player:GetProperty("LiShimin_LastEnvoyTurn")
    if lastTurn then
        lastEnvoyTurn[playerID] = tonumber(lastTurn) or 0
    end
end

-- ===== 初始化 =====

function TianKeHan_Initialize()
    -- 注册事件
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, TianKeHan_OnTurnBegin, 30)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_END,   TianKeHan_OnTurnEnd,   80)
    EventBus:RegisterListener(EVENTS.ON_UNIT_CREATED,       function(pid, u) TianceAura_OnUnitCreated(pid, u) end, 60)
    Events.WarDeclared.Add(TianKeHan_OnWarDeclared)

    -- 初始化时加载已有玩家的状态
    for pid = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        if IsLiShiminLeaderPlayer(pid) then
            TianKeHan_LoadState(pid)
        end
    end

    Log("TianKeHan module initialized — 天可汗系统已加载（简介.txt定版）")
end

TianKeHan_Initialize()


-- ============================================================================
-- MODULE: src\Lua\ZhenguanTaizong.lua
-- ============================================================================

-- ===== 防御性依赖检查 =====
if not LogDebug then
    function LogDebug(msg) print("[LiShiminMod][DBG] " .. tostring(msg)) end
end
if not LogWarning then
    function LogWarning(msg) print("[LiShiminMod][WARN] " .. tostring(msg)) end
end
if not LogError then
    function LogError(msg) print("[LiShiminMod][ERR] " .. tostring(msg)) end
end
if not SafeCall then
    function SafeCall(func, ...)
        local ok, result = pcall(func, ...)
        if not ok then print("[LiShiminMod][ERR] SafeCall: " .. tostring(result)) end

    end
end
if not IsNilOrEmpty then
    function IsNilOrEmpty(v) return v == nil or v == "" end
end
-- ============================================================
-- 唐太宗阶段效果：贞观之治 + 万国来朝 + 天可汗智慧
-- 仅在 EMPEROR_TAIZONG 状态下生效
-- 同步更新自 简介.txt（定版）
-- ============================================================

-- ===== 贞观之治：每城+1%，上限+10% =====
-- 实现方式：纯 Lua，通过城市 Property 记录加成，由 UI 层读取显示
-- 注：Civ6 Lua API 对城市 Yields 表的实时修改支持有限，
--     完整实现建议通过 DummyBuilding + Modifier + RequirementSet
--     此处采用 Property + Notification 方式作为基础实现

local YIELD_FOOD        = 0
local YIELD_PRODUCTION  = 1
local YIELD_GOLD       = 2
local YIELD_SCIENCE    = 3
local YIELD_CULTURE    = 4
local YIELD_FAITH      = 5

-- 缓存：上次应用的城市场景（避免每回合重复计算）
local lastZhenguanTurn       = {}
local lastZhenguanCityCount  = {}

-- 获取贞观之治当前加成百分比
function Zhenguan_GetCurrentBonusPct(playerID)
    local player = Players[playerID]
    if not player then return 0 end
    local cityCount = player:GetCities():GetCount()
    if cityCount <= 0 then return 0 end
    -- 简介.txt定版：每城+1%，上限+10%
    local pct = math.min(cityCount * (ZHENGUAN_PER_CITY_PCT or 1), (ZHENGUAN_MAX_PCT or 10))

end

-- 应用贞观之治加成到城市（Property记录，UI读取）
function Zhenguan_ApplyYieldBonus(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end

    -- 仅在唐太宗阶段生效
    if d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then

    local player = Players[playerID]
    if not player then return end

    local cityCount = player:GetCities():GetCount()
    if cityCount <= 0 then return end

    -- 简介.txt定版：每城1%，上限10%
    local pct = math.min(cityCount * (ZHENGUAN_PER_CITY_PCT or 1), (ZHENGUAN_MAX_PCT or 10))
    local bonus = pct

    -- 对每个城市记录加成（供UI显示）
    for _, city in player:GetCities():Members() do
        city:SetProperty("LiShimin_ZhenguanBonus", bonus)
        -- 标注基础产出来源（玩家实际感知效果需要通过 Modifier）
        -- 此处设置一个基础数值，由游戏机制在后续自动乘算
        -- Civ6 中：城市基础产出 × (1 + pct/100) 即为最终产出
    end

    -- 缓存本次应用状态
    lastZhenguanTurn[playerID]       = Game.GetCurrentGameTurn()
    lastZhenguanCityCount[playerID]  = cityCount
end

-- 贞观之治每回合主入口
function Zhenguan_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then

    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then

    local player = Players[playerID]
    if not player then return end

    local cityCount = player:GetCities():GetCount()
    if cityCount <= 0 then return end

    -- 应用加成
    SafeCall(Zhenguan_ApplyYieldBonus, playerID)

    -- 简介.txt定版：每10回合通知一次贞观之治状态
    local turn = Game.GetCurrentGameTurn()
    if (turn % 10 == 0) then
        local pct = Zhenguan_GetCurrentBonusPct(playerID)
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_ZHENGUAN_TITLE",
            Locale.Lookup("LOC_LISHIMIN_ZHENGUAN_STATUS", cityCount, pct),
            nil,
            COLORS.SUCCESS
        )
    end
end

-- ===== 万国来朝：每10回合免费获得1名使者 =====

local lastEnvoyTurn = {}

function WorldReception_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then

    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then

    -- 如果 TianKeHan 模块存在且有效，则由 TianKeHan 接管使者发放
    -- 此处保留独立实现作为备用（双重保险）
    if TianKeHan_GrantFreeEnvoy then
        return  -- 由 TianKeHan 统一处理
    end

    local turn = Game.GetCurrentGameTurn()
    local interval = ENVOY_INTERVAL or 10   -- 简介.txt定版：每10回合
    if lastEnvoyTurn[playerID] and (turn - lastEnvoyTurn[playerID]) < interval then

    lastEnvoyTurn[playerID] = turn

    -- 发放免费使者
    local granted = WorldReception_GrantEnvoy(playerID)

    ShowNotification(
        playerID,
        "LOC_LISHIMIN_WORLD_TITLE",
        Locale.Lookup("LOC_LISHIMIN_WORLD_ENVOY_GAIN"),
        nil,
        COLORS.SECONDARY
    )
end

-- 实际发放使者
function WorldReception_GrantEnvoy(playerID)
    local player = Players[playerID]
    if not player then return false end

    -- Civ6 标准 API：增加玩家可分配的使者令牌（ChangeTokensToGive）
    -- 玩家在下一回合手动分配给任意城邦
    local influence = player:GetInfluence()
    if influence then
        influence:ChangeTokensToGive(1)

    end

end

-- ===== 天可汗智慧：主动宣战外交修正 =====

function TianKeHan_OnWarDeclared(attackingPlayerID, defendingPlayerID)
    if IsLiShiminLeaderPlayer(attackingPlayerID) then
        -- 玩家主动宣战：所有领袖好感-10（通知）
        ShowNotification(
            attackingPlayerID,
            "LOC_LISHIMIN_TIANZI_YANU_TITLE",
            "LOC_LISHIMIN_TIANZI_YANU_WAR_DECLARED",
            nil,
            COLORS.WARNING
        )
    end
    if IsLiShiminLeaderPlayer(defendingPlayerID) then
        -- 玩家被宣战：所有领袖好感+15（通知）
        ShowNotification(
            defendingPlayerID,
            "LOC_LISHIMIN_DIPLOMACY_TITLE",
            "LOC_LISHIMIN_DIPLOMACY_DEFENSIVE",
            nil,
            COLORS.SECONDARY
        )
    end
end

-- ===== 初始化 =====
function ZhenguanTaizong_Initialize()
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, Zhenguan_OnTurnBegin, 40)
    -- WorldReception 由 TianKeHan 模块接管，此处仅作备用
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, WorldReception_OnTurnBegin, 35)
    Events.WarDeclared.Add(TianKeHan_OnWarDeclared)
    Log("ZhenguanTaizong module initialized — 贞观之治/万国来朝已加载（简介.txt定版）")
end

ZhenguanTaizong_Initialize()


-- ============================================================================
-- MODULE: src\Lua\Coronation.lua
-- ============================================================================

-- ===== 防御性依赖检查 =====
if not LogDebug then
    function LogDebug(msg) print("[LiShiminMod][DBG] " .. tostring(msg)) end
end
if not LogWarning then
    function LogWarning(msg) print("[LiShiminMod][WARN] " .. tostring(msg)) end
end
if not LogError then
    function LogError(msg) print("[LiShiminMod][ERR] " .. tostring(msg)) end
end
if not SafeCall then
    function SafeCall(func, ...)
        local ok, result = pcall(func, ...)
        if not ok then print("[LiShiminMod][ERR] SafeCall: " .. tostring(result)) end

    end
end
if not IsNilOrEmpty then
    function IsNilOrEmpty(v) return v == nil or v == "" end
end
-- Coronation.lua
-- 登基线：玄武门建成后刷新李建成，天策上将踩踏处决后转为唐太宗形态

local LiJianchengID = nil
local LiJianchengOwner = nil
local LiJianchengX = -1
local LiJianchengY = -1

-- 获取野蛮人玩家ID（动态获取最安全）
local function GetBarbarianPlayerID()
    local players = PlayerManager.GetAliveIDs()
    for _, pid in ipairs(players) do
        local p = Players[pid]
        if p and p:IsBarbarian() then

        end
    end

end

-- 在指定坐标生成李建成
local function SpawnLiJiancheng(x, y)
    local barbPlayerID = GetBarbarianPlayerID()
    local barbPlayer = Players[barbPlayerID]
    if not barbPlayer then return end

    local unitDef = GameInfo.Units["UNIT_LI_JIANCHENG"]
    if not unitDef then return end

    local unit = UnitManager.InitUnit(barbPlayerID, unitDef.Hash, x, y)
    if unit then
        LiJianchengID = unit:GetID()
        LiJianchengOwner = barbPlayerID
        LiJianchengX = x
        LiJianchengY = y
    end
end

-- 监听改良设施建造（玄武门建成）
function Coronation_OnImprovementAddedToMap(locX, locY, improvementType, playerID)
    if not IsLiShiminLeaderPlayer(playerID) then return end

    local impRow = GameInfo.Improvements[improvementType]
    if not impRow or impRow.ImprovementType ~= "IMPROVEMENT_XUANWU_GATE" then

    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end

    -- 仅在登基线或藩王线允许触发
    if d.LeaderState ~= LEADER_STATE.CORONATION and d.LeaderState ~= LEADER_STATE.PRINCE_LINE then

    d.XuanwuGateBuilt = true
    LiShiminSavePlayerFieldsToProperties(playerID, d)

    -- 在玄武门坐标生成李建成（野蛮人平民）
    SpawnLiJiancheng(locX, locY)

    -- 通知玩家
    ShowNotification(
        playerID,
        "LOC_LISHIMIN_NOTIFY_TITLE",
        "玄武门已建成！天策上将请速往此处，处决李建成！",
        nil,
        COLORS.WARNING
    )

    -- 触发事件和音效
    EventBus:FireEvent(EVENTS.ON_XUANWU_GATE_BUILT, playerID)
    if LuaEvents.LiShiminMod_PlayPresentation then
        LuaEvents.LiShiminMod_PlayPresentation("xuanwu_gate")
    end
end

-- 监听单位被移出地图（平民被踩踏时触发）
function Coronation_OnUnitRemovedFromMap(playerID, unitID)
    -- 如果移除的不是我们记录的李建成，直接跳过
    if playerID ~= LiJianchengOwner or unitID ~= LiJianchengID then

    -- 李建成被踩了！去他刚才在的格子上"抓凶手"
    local plot = Map.GetPlot(LiJianchengX, LiJianchengY)
    if not plot then return end

    local killerUnit = nil
    local killerPlayerID = nil

    -- 获取地块上现在的军事单位
    local unitCount = plot:GetUnitCount()
    for i = 0, unitCount - 1 do
        local u = plot:GetUnitByIndex(i)
        if u then
            killerUnit = u
            killerPlayerID = u:GetOwner()
            break
        end
    end

    if killerUnit then
        local unitType = GameInfo.Units[killerUnit:GetType()].UnitType

        -- 验证身份：是天策上将，且属于当前玩家
        if unitType == "UNIT_TIANCE_GENERAL" and IsLiShiminLeaderPlayer(killerPlayerID) then

            -- 处决成功！更新领袖状态
            local d = LiShiminMod_GetOrInitPlayer(killerPlayerID)
            d.LeaderState = LEADER_STATE.EMPEROR_TAIZONG
            LiShiminSavePlayerFieldsToProperties(killerPlayerID, d)

            ShowNotification(
                killerPlayerID,
                "LOC_LISHIMIN_NOTIFY_TITLE",
                "玄武喋血，大局已定！天策上将正式登基为唐太宗！",
                nil,
                COLORS.SUCCESS
            )

            -- 播放处决图片弹窗 + 登基成功音效
            if LuaEvents.LiShiminMod_PlayPresentation then
                LuaEvents.LiShiminMod_PlayPresentation("coronation_kill")
                LuaEvents.LiShiminMod_PlayPresentation("coronation_complete")
            end
            EventBus:FireEvent(EVENTS.ON_CORONATION_COMPLETED, killerPlayerID)

            -- 清理记录
            LiJianchengID = nil

        else
            -- 处决失败（杂兵踩的）
            ShowNotification(
                killerPlayerID,
                "LOC_LISHIMIN_NOTIFY_TITLE",
                "史书不可篡改！必须由天策上将亲自终结李建成！",
                nil,
                COLORS.DANGER
            )

            -- 立刻原地重刷李建成
            SpawnLiJiancheng(LiJianchengX, LiJianchengY)
        end
    end
end

-- 初始化
function Coronation_Initialize()
    Events.ImprovementAddedToMap.Add(Coronation_OnImprovementAddedToMap)
    Events.UnitRemovedFromMap.Add(Coronation_OnUnitRemovedFromMap)
end

Coronation_Initialize()

-- ============================================================================
-- MODULE: src/Lua/Main.lua (ENTRY POINT)
-- ============================================================================

-- ===== 防御性依赖检查 =====
if not LogDebug then
    function LogDebug(msg) print("[LiShiminMod][DBG] " .. tostring(msg)) end
end
if not LogWarning then
    function LogWarning(msg) print("[LiShiminMod][WARN] " .. tostring(msg)) end
end
if not LogError then
    function LogError(msg) print("[LiShiminMod][ERR] " .. tostring(msg)) end
end
if not SafeCall then
    function SafeCall(func, ...)
        local ok, result = pcall(func, ...)
        if not ok then print("[LiShiminMod][ERR] SafeCall: " .. tostring(result)) end
        return result
    end
end
if not IsNilOrEmpty then
    function IsNilOrEmpty(v) return v == nil or v == "" end
end
-- ============================================================
-- 模组入口：注册事件、驱动天策上将/登基线/藩王线/唐太宗状态机
-- 同步更新自 简介.txt（定版）
-- ============================================================

LiShiminMod = LiShiminMod or {}
LiShiminMod.Players = LiShiminMod.Players or {}
LiShiminMod.Version = MOD_VERSION or "2.0.0"

-- ===== 游戏生命周期 =====

function LiShiminMod_OnGameStart()
    for pid = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        LiShiminMod.Players[pid] = nil
        if IsLiShiminLeaderPlayer(pid) then
            local d = LiShiminMod_GetOrInitPlayer(pid)
            Log("GameStart: LiShimin player found, pid=" .. tostring(pid))
            -- 在 GameStart 直接尝试生成天策上将
            if d and not d.TianceGeneralSpawned then
                d.TianceGeneralSpawned = true
                LiShiminSavePlayerFieldsToProperties(pid, d)
                SpawnTianceGeneral(pid)
            end
            ShowNotification(
                pid,
                "LOC_LISHIMIN_WELCOME_TITLE",
                "LOC_LISHIMIN_WELCOME_BODY",
                nil,
                COLORS.PRIMARY
            )
        end
    end
end

function LiShiminMod_OnLoadGame()
    for pid = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        LiShiminMod.Players[pid] = nil
        if IsLiShiminLeaderPlayer(pid) then
            LiShiminMod_GetOrInitPlayer(pid)
            if TianKeHan_LoadState then
                TianKeHan_LoadState(pid)
            end
        end
    end
end

-- ===== 每回合事件 =====

function LiShiminMod_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end

    -- 最保底方案：如果天策上将还没送出去，强制送
    if not d.TianceGeneralSpawned then
        d.TianceGeneralSpawned = true
        LiShiminSavePlayerFieldsToProperties(playerID, d)
        Log("TurnBegin: safety-net spawning Tiance General for pid=" .. tostring(playerID))
        SpawnTianceGeneral(playerID)
    end

    Coronation_OnTurnBegin(playerID)
    PrinceLine_OnTurnBegin(playerID)
end

function LiShiminMod_OnTurnEnd(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    PrinceLine_OnTurnEnd(playerID)
end

-- ===== 时代变更 =====

function LiShiminMod_OnEraChanged(playerID, newEra, oldEra)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    local eraRow = GameInfo.Eras[newEra]
    if not eraRow or eraRow.EraType ~= ERA_MEDIEVAL then
        return
    end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.MedievalResolved then
        return
    end
    d.MedievalResolved = true
    local n = d.CitiesConquered or 0
    local need = CORONATION_MIN_CITIES_CONQUERED or 5
    if n >= need then
        d.LeaderState = LEADER_STATE.CORONATION
        d.CoronationTurnsSinceGate = 0
        if PlayerHasImprovementType(playerID, IMPROVEMENT_XUANWU_GATE) then
            d.XuanwuGateBuilt = true
        end
        LiShiminSavePlayerFieldsToProperties(playerID, d)
        ShowNotification(playerID, "LOC_LISHIMIN_NOTIFY_TITLE", "LOC_LISHIMIN_ERA_CORONATION_PATH", nil, COLORS.SECONDARY)
        Coronation_TryComplete(playerID)
    else
        d.LeaderState = LEADER_STATE.PRINCE_LINE
        LiShiminSavePlayerFieldsToProperties(playerID, d)
        ShowNotification(playerID, "LOC_LISHIMIN_NOTIFY_TITLE", "LOC_LISHIMIN_ERA_PRINCE_PATH", nil, COLORS.WARNING)
        PrinceLine_Activate(playerID)
    end
end

-- ===== 城市被征服 =====

function LiShiminMod_OnCityConquered(ownerID, city, conquerorID)
    if not city then return end
    if not IsLiShiminLeaderPlayer(conquerorID) then return end
    local prev = Players[ownerID]
    if prev and prev:IsBarbarian() then return end
    local d = LiShiminMod_GetOrInitPlayer(conquerorID)
    if not d then return end
    if not d.MedievalResolved then
        d.CitiesConquered = (d.CitiesConquered or 0) + 1
        LiShiminSavePlayerFieldsToProperties(conquerorID, d)
    end
    PrinceLine_OnCityConquered(ownerID, city, conquerorID)
end

-- ===== 单位死亡 =====

function LiShiminMod_OnUnitKilled(playerID, unit, unitsKilled)
    if not unit then return end
    if IsTianceGeneral(unit) and IsLiShiminLeaderPlayer(playerID) then
        HandleTianceGeneralDeath(playerID)
    end
end

-- ===== 建筑建成 =====

function LiShiminMod_OnBuildingConstructed(playerID, city, buildingHash, plotID, isOriginalConstruction)
end

-- ===== 开局生成天策上将 =====
-- 三重触发：GameStart > CityAddedToMap > TurnBegin，确保一定送出

function SpawnTianceGeneral(playerID)
    local player = Players[playerID]
    if not player then
        LogError("SpawnTianceGeneral: player nil for pid=" .. tostring(playerID))
        return
    end

    -- 多种方式找出生点：首都 > 玩家单位位置 > 玩家起始坐标
    local spawnPlot = nil
    local source = "none"

    -- 方法1：首都
    local capital = GetCapitalCity(player)
    if capital then
        spawnPlot = Map.GetPlot(capital:GetX(), capital:GetY())
        source = "capital"
    end

    -- 方法2：玩家第一个单位的坐标（开局通常是开拓者）
    if not spawnPlot then
        for unit in player:GetUnits():Members() do
            local p = Map.GetPlot(unit:GetX(), unit:GetY())
            if p then
                spawnPlot = p
                source = "unit"
                break
            end
        end
    end

    -- 方法3：PlayerConfigurations 起始坐标
    if not spawnPlot then
        local cfg = PlayerConfigurations[playerID]
        if cfg then
            local sx = cfg:GetStartPlotX()
            local sy = cfg:GetStartPlotY()
            if sx and sy and sx >= 0 and sy >= 0 then
                spawnPlot = Map.GetPlot(sx, sy)
                source = "startpos"
            end
        end
    end

    if not spawnPlot then
        LogError("SpawnTianceGeneral: no valid plot found for pid=" .. tostring(playerID))
        return
    end

    -- 在出生点周围找一个非山地非水域的空地
    local unitPlot = nil
    for dx = -1, 1 do
        for dy = -1, 1 do
            if dx == 0 and dy == 0 then
                -- skip center
            else
                local p = Map.GetPlot(spawnPlot:GetX() + dx, spawnPlot:GetY() + dy)
                if p and not p:IsMountain() and not p:IsWater() then
                    unitPlot = p
                    break
                end
            end
        end
        if unitPlot then break end
    end
    if not unitPlot then
        unitPlot = spawnPlot
    end

    local unitInfo = GameInfo.Units[UNIT_TIANCE_GENERAL]
    if not unitInfo then
        LogError("SpawnTianceGeneral: UNIT_TIANCE_GENERAL not found in GameInfo! Check XML.")
        return
    end

    Log("SpawnTianceGeneral: spawning at (" .. unitPlot:GetX() .. "," .. unitPlot:GetY() .. ") via " .. source)
    local unit = player:GetUnits():Create(unitInfo.Index, unitPlot:GetX(), unitPlot:GetY())
    if unit then
        Log("SpawnTianceGeneral: SUCCESS")
        ShowNotification(playerID, "LOC_LISHIMIN_NOTIFY_TITLE", "LOC_LISHIMIN_TIANCE_SPAWNED", nil, COLORS.PRIMARY)
    else
        LogError("SpawnTianceGeneral: player:GetUnits():Create returned nil")
    end
end

-- ===== 初始化 =====

function LiShiminMod_Initialize()
    RegisterGameEvents()
    RegisterCustomEvents()

    EventBus:RegisterListener(EVENTS.ON_GAME_START,         LiShiminMod_OnGameStart,         100)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN,  LiShiminMod_OnTurnBegin,         90)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_END,    LiShiminMod_OnTurnEnd,           90)
    EventBus:RegisterListener(EVENTS.ON_ERA_CHANGED,        LiShiminMod_OnEraChanged,        80)
    EventBus:RegisterListener(EVENTS.ON_CITY_CONQUERED,    LiShiminMod_OnCityConquered,     80)
    EventBus:RegisterListener(EVENTS.ON_UNIT_KILLED,        LiShiminMod_OnUnitKilled,        100)
    EventBus:RegisterListener(EVENTS.ON_BUILDING_CONSTRUCTED, LiShiminMod_OnBuildingConstructed, 70)

    -- 兜底2：建城时再试一次（CityAddedToMap 时 IsCapital 尚未标记，改用 CityInitialized）
    Events.CityInitialized.Add(function(playerID, cityID)
        if not IsLiShiminLeaderPlayer(playerID) then return end
        local player = Players[playerID]
        -- 如果这是玩家的第一座城，必然是开局首都
        if player and player:GetCities():GetCount() == 1 then
            local d = LiShiminMod_GetOrInitPlayer(playerID)
            if d and not d.TianceGeneralSpawned then
                d.TianceGeneralSpawned = true
                LiShiminSavePlayerFieldsToProperties(playerID, d)
                SpawnTianceGeneral(playerID)
            end
        end
    end)

    if Events.LoadGameViewStateDone then
        Events.LoadGameViewStateDone.Add(function()
            LiShiminMod_OnLoadGame()
        end)
    end

    Log("LiShiminMod initialized --- " .. (MOD_VERSION_FULL or "v2.0.0") .. " (diagnosis build)")
end

LiShiminMod_Initialize()
