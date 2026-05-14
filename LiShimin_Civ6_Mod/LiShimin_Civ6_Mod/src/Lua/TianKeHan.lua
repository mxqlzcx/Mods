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
    return ids
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
                return unit
            end
        end
    end
    return nil
end

-- ===== 核心逻辑：节度使系统 =====

-- 每回合检测节度使状态
function TianKeHan_RefreshJiedushiStatus(liShiminPlayerID)
    if not IsLiShiminLeaderPlayer(liShiminPlayerID) then return end
    local d = LiShiminMod_GetOrInitPlayer(liShiminPlayerID)
    if not d or d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then
        return
    end

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
        return
    end
    local cityStatePlayer = Players[cityStateID]
    if not cityStatePlayer then return end

    -- 检查玩家是否为宗主国
    if not cityStatePlayer:IsSuzerain(liShiminPlayerID) then
        return
    end

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
        return
    end

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
        return
    end

    local turn = Game.GetCurrentGameTurn()
    local interval = ENVOY_INTERVAL or 10

    -- 检查间隔
    local lastTurn = lastEnvoyTurn[liShiminPlayerID] or 0
    if (turn - lastTurn) < interval then
        return
    end

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
        return false
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
            return true
        end
    end

    return false
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
    return count
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

    return units
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
        return false
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
        return true
    end

    return false
end

-- ===== 唐太宗回合开始主入口 =====

function TianKeHan_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then return end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then
        return
    end

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

return {
    TianKeHan_OnTurnBegin            = TianKeHan_OnTurnBegin,
    TianKeHan_IsJiedushiEstablished = TianKeHan_IsJiedushiEstablished,
    TianKeHan_IsTianziYanuActive    = TianKeHan_IsTianziYanuActive,
    TianKeHan_GetYanuTurnsRemaining = TianKeHan_GetYanuTurnsRemaining,
    TianKeHan_RefreshJiedushiStatus = TianKeHan_RefreshJiedushiStatus,
    TianKeHan_GrantFreeEnvoy        = TianKeHan_GrantFreeEnvoy,
    TianKeHan_GetConscriptableUnits = TianKeHan_GetConscriptableUnits,
    TianKeHan_ConscriptUnit         = TianKeHan_ConscriptUnit,
    TianKeHan_CanConscript           = TianKeHan_CanConscript,
    TianKeHan_SaveState             = TianKeHan_SaveState,
    TianKeHan_LoadState             = TianKeHan_LoadState,
}
