-- 工具函数和日志系统
-- 提供模组中使用的通用工具函数和统一的日志记录功能

-- 调试模式开关（生产环境设为false）
DEBUG_MODE = false

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
        return nil
    end
    return result
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
    return new_tbl
end

-- 获取玩家的首都
function GetCapitalCity(player)
    local cities = player:GetCities()
    for _, city in cities:Members() do
        if city:IsCapital() then
            return city
        end
    end
    return nil
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
    
    return units
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
        return nil
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
        return false
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
        return false
    end
    for _, city in player:GetCities():Members() do
        if city:GetBuildings():HasBuilding(bdef.Index) then
            return true
        end
    end
    return false
end

function PlotOwnedByMajor(playerID, plotX, plotY)
    local plot = Map.GetPlot(plotX, plotY)
    if not plot then
        return false
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
        return
    end
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
        return nil
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
        return
    end
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
    return nil
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
        return BalanceData
    end
    
    -- 如果BalanceData未加载，尝试加载
    if not IsNilOrEmpty(BALANCE_VERSION) then
        local balance = GetBalanceData()
        if balance then
            BalanceData = balance
            return balance
        end
    end
    
    LogError("Failed to get balance data!")
    return nil
end

return {
    DEBUG_MODE = DEBUG_MODE,
    Log = Log,
    LogError = LogError,
    LogWarning = LogWarning,
    LogDebug = LogDebug,
    SafeCall = SafeCall,
    IsNilOrEmpty = IsNilOrEmpty,
    DeepCopy = DeepCopy,
    GetCapitalCity = GetCapitalCity,
    GetPlayerCityCount = GetPlayerCityCount,
    HasRequiredCities = HasRequiredCities,
    GetUnitPlot = GetUnitPlot,
    ArePlotsAdjacent = ArePlotsAdjacent,
    GetUnitsAroundPlot = GetUnitsAroundPlot,
    ShowNotification = ShowNotification,
    LiShiminNotifyStoryMoment = LiShiminNotifyStoryMoment,
    IsTianceGeneral = IsTianceGeneral,
    IsLiJiancheng = IsLiJiancheng,
    GetPlayerLeaderState = GetPlayerLeaderState,
    SetPlayerLeaderState = SetPlayerLeaderState,
    GetCurrentBalance = GetCurrentBalance,
    GetUnitTypeNameFromUnit = GetUnitTypeNameFromUnit,
    IsLiShiminLeaderPlayer = IsLiShiminLeaderPlayer,
    PlayerSupportsModProperties = PlayerSupportsModProperties,
    PlayerHasBuildingType = PlayerHasBuildingType,
    PlotOwnedByMajor = PlotOwnedByMajor,
    LiShiminLoadPlayerFieldsFromProperties = LiShiminLoadPlayerFieldsFromProperties,
    LiShiminSavePlayerFieldsToProperties = LiShiminSavePlayerFieldsToProperties,
    LiShiminMod_CreateDefaultPlayerData = LiShiminMod_CreateDefaultPlayerData,
    LiShiminMod_GetOrInitPlayer = LiShiminMod_GetOrInitPlayer
}
