-- ============================================================
-- 登基仪式：玄武门之变
-- 简介.txt定版流程：
--   1. 玄武门修建完成 → 地块直接刷新李建成（特殊敌对单位）
--   2. 李建成：0移动力，超高防御，普通单位攻击强制0伤害
--   3. 操控天策上将用秦王弓完成绝杀 → 天策上将移除 → 切换唐太宗
-- 同步更新自 简介.txt（定版）
-- ============================================================

-- 记录已刷新的李建成（防止重复刷新）
local liJianchengSpawned = {}  -- playerID -> { spawned=true, x=X, y=Y }

-- ===== 玄武门建成 → 触发李建成刷新 =====

function Coronation_OnBuildingConstructed(playerID, city, buildingHash)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    local row = GameInfo.Buildings[buildingHash]
    if not row or row.BuildingType ~= BUILDING_XUANWU_GATE then
        return
    end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then
        return
    end
    if d.LeaderState ~= LEADER_STATE.CORONATION and d.LeaderState ~= LEADER_STATE.PRINCE_LINE then
        return
    end
    d.XuanwuGateBuilt = true
    LiShiminSavePlayerFieldsToProperties(playerID, d)

    -- 触发剧情通知
    LiShiminNotifyStoryMoment(
        playerID,
        "LOC_LISHIMIN_NOTIFY_TITLE",
        "LOC_LISHIMIN_XUANWU_BUILT",
        "xuanwu_gate",
        COLORS.SUCCESS
    )

    -- 立即刷新李建成（简介.txt定版：玄武门修建完成瞬间）
    SafeCall(Coronation_SpawnLiJiancheng, playerID, city)

    EventBus:FireEvent(EVENTS.ON_XUANWU_GATE_BUILT, playerID, city)
    PrinceLine_TryComplete(playerID)
end

-- 刷新李建成单位
function Coronation_SpawnLiJiancheng(playerID, gateCity)
    if not gateCity then
        -- 如果没有传入城市对象，尝试从首都找玄武门
        local player = Players[playerID]
        if player then
            local capital = GetCapitalCity(player)
            if capital then
                gateCity = capital
            end
        end
    end
    if not gateCity then return false end

    -- 已在该玩家刷新过李建成
    if liJianchengSpawned[playerID] and liJianchengSpawned[playerID].spawned then
        return false
    end

    -- 找到玄武门所在地块
    local gatePlot = nil
    for _, city in player:GetCities():Members() do
        if city == gateCity then
            gatePlot = city:GetPlot()
            break
        end
    end
    -- 备选：在首都附近找玄武门
    if not gatePlot then
        local player = Players[playerID]
        for _, city in (player and player:GetCities() or {}):Members() do
            if city:IsCapital() then
                gatePlot = city:GetPlot()
                break
            end
        end
    end

    -- 查找玄武门改良设施所在地块
    local xuanwuPlot = nil
    local player = Players[playerID]
    if player then
        for _, city in player:GetCities():Members() do
            local plot = city:GetPlot()
            if plot then
                -- 检查是否有玄武门改良设施
                local impType = plot:GetImprovementType()
                if impType ~= -1 then
                    local impRow = GameInfo.Improvements[impType]
                    if impRow and impRow.ImprovementType == BUILDING_XUANWU_GATE then
                        xuanwuPlot = plot
                        break
                    end
                end
            end
        end
    end

    -- 在首都地块找玄武门
    if not xuanwuPlot and player then
        local capital = GetCapitalCity(player)
        if capital then
            local capPlot = capital:GetPlot()
            -- 玄武门是建筑，直接在首都
            xuanwuPlot = capPlot
        end
    end

    if not xuanwuPlot then
        LogError("Coronation_SpawnLiJiancheng: Cannot find Xuanwu Gate plot")
        return false
    end

    -- 生成李建成（作为敌对中立单位，属于Barbarian玩家）
    local liJianchengInfo = GameInfo.Units[UNIT_LI_JIANCHENG]
    if not liJianchengInfo then
        LogError("Coronation_SpawnLiJiancheng: UNIT_LI_JIANCHENG not found")
        return false
    end

    -- 李建成归属于一个特殊的中立/敌对玩家（避免与其他逻辑冲突）
    -- 使用 Barbarian slot (playerID = GameDefines.MAX_CIVS)
    local barbPlayerID = GameDefines.MAX_CIVS
    local barbPlayer = Players[barbPlayerID]

    -- 创建李建成单位
    local unit = UnitManager.InitUnit(barbPlayerID, liJianchengInfo.Hash, xuanwuPlot:GetX(), xuanwuPlot:GetY())
    if not unit then
        -- 备选位置：玄武门周围
        for dx = -1, 1 do
            for dy = -1, 1 do
                local adjPlot = Map.GetPlot(xuanwuPlot:GetX() + dx, xuanwuPlot:GetY() + dy)
                if adjPlot and not adjPlot:IsWater() and not adjPlot:IsMountain() then
                    unit = UnitManager.InitUnit(barbPlayerID, liJianchengInfo.Hash, adjPlot:GetX(), adjPlot:GetY())
                    if unit then
                        xuanwuPlot = adjPlot
                        break
                    end
                end
            end
            if unit then break end
        end
    end

    if unit then
        -- 设置李建成的特殊属性
        -- 0移动力（禁止移动）
        unit:SetMoves(0)
        unit:ChangeMoves(-unit:GetMoves())

        -- 超高防御（通过设置生命值/防御力，在XML中已定义）

        -- 记录刷新位置
        liJianchengSpawned[playerID] = {
            spawned = true,
            x = xuanwuPlot:GetX(),
            y = xuanwuPlot:GetY(),
            unitID = unit:GetID(),
        }

        -- 通知玩家
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_NOTIFY_TITLE",
            "LOC_LISHIMIN_LI_JIANCHENG_SPAWNED",
            nil,
            COLORS.DANGER
        )

        Log("Coronation: Li Jiancheng spawned at (" .. xuanwuPlot:GetX() .. "," .. xuanwuPlot:GetY() .. ")")
        return true
    end

    return false
end

-- ===== 回合开始：超时检查 =====

function Coronation_OnTurnBegin(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.CORONATION then
        return
    end
    if d.XuanwuGateBuilt then
        d.CoronationTurnsSinceGate = (d.CoronationTurnsSinceGate or 0) + 1
        LiShiminSavePlayerFieldsToProperties(playerID, d)
    end
    Coronation_TryComplete(playerID)
end

-- 尝试完成登基仪式（李建成被击杀时调用）
function Coronation_TryComplete(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.CORONATION then
        return
    end
    -- 检查李建成是否仍然存在
    if liJianchengSpawned[playerID] and liJianchengSpawned[playerID].spawned then
        -- 李建成还存在，不能完成
        return
    end
    -- 李建成已被击杀 → 完成登基
    d.LeaderState = LEADER_STATE.EMPEROR_TAIZONG
    LiShiminSavePlayerFieldsToProperties(playerID, d)

    -- 移除天策上将
    SafeCall(Coronation_RemoveTianceGeneral, playerID)

    LiShiminNotifyStoryMoment(
        playerID,
        "LOC_LISHIMIN_NOTIFY_TITLE",
        "LOC_LISHIMIN_CORONATION_SUCCESS",
        "coronation_complete",
        COLORS.SUCCESS
    )

    EventBus:FireEvent(EVENTS.ON_CORONATION_COMPLETED, playerID)
end

-- 移除天策上将（完成登基后）
function Coronation_RemoveTianceGeneral(playerID)
    local player = Players[playerID]
    if not player then return end

    for _, unit in player:GetUnits():Members() do
        if IsTianceGeneral(unit) then
            -- 将天策上将从地图上移除（功成身退）
            UnitManager.Kill(unit, false)
            Log("Coronation: Tiance General removed (coronation complete)")
            break
        end
    end
end

-- ===== 战斗修正：李建成只受天策上将攻击 =====

-- 在战斗伤害计算时，检查是否为李建成
function Coronation_OnCombatDamage(context, attackingUnit, defender, damage)
    if not attackingUnit or not defender then
        return damage
    end

    -- 检查防守方是否是李建成
    if IsLiJiancheng(defender) then
        -- 检查进攻方是否是李世民的天策上将
        local attOwner = attackingUnit:GetOwner()
        if IsLiShiminLeaderPlayer(attOwner) and IsTianceGeneral(attackingUnit) then
            -- 天策上将攻击李建成 → 造成致命一击
            return defender:GetDamage() + defender:GetMaxDamage()  -- 秒杀
        else
            -- 普通单位攻击李建成 → 强制0伤害
            return 0
        end
    end

    -- 检查进攻方是否是李建成
    if IsLiJiancheng(attackingUnit) then
        -- 李建成不能主动攻击
        return 0
    end

    return damage
end

-- ===== 李建成被击杀时：触发登基完成 =====

function Coronation_OnUnitKilled(victimPlayerID, victimUnit, killers)
    if not victimUnit then return end
    if not IsLiJiancheng(victimUnit) then return end

    -- 找到击杀者
    local killerUnit = nil
    if killers and #killers > 0 then
        killerUnit = killers[1]
    end

    -- 找到李世民玩家（通过击杀者）
    local liShiminPlayerID = nil
    if killerUnit then
        local killerOwner = killerUnit:GetOwner()
        if IsLiShiminLeaderPlayer(killerOwner) then
            liShiminPlayerID = killerOwner
        end
    end

    -- 如果没有击杀者，通过李建成位置反推
    if not liShiminPlayerID then
        for pid = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
            if liJianchengSpawned[pid] and liJianchengSpawned[pid].spawned then
                if victimUnit:GetX() == liJianchengSpawned[pid].x and
                   victimUnit:GetY() == liJianchengSpawned[pid].y then
                    liShiminPlayerID = pid
                    break
                end
            end
        end
    end

    if not liShiminPlayerID then return end

    -- 标记李建成为已击杀
    if liJianchengSpawned[liShiminPlayerID] then
        liJianchengSpawned[liShiminPlayerID].spawned = false
    end

    -- 触发登基完成
    SafeCall(Coronation_OnLiJianchengKilled, liShiminPlayerID, killerUnit)
end

function Coronation_OnLiJianchengKilled(playerID, killerUnit)
    -- 必须是天策上将击杀
    if killerUnit and IsTianceGeneral(killerUnit) then
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_NOTIFY_TITLE",
            "LOC_LISHIMIN_LI_JIANCHENG_KILLED",
            nil,
            COLORS.DANGER
        )
        -- 触发登基完成流程
        local d = LiShiminMod_GetOrInitPlayer(playerID)
        if d then
            if d.LeaderState == LEADER_STATE.CORONATION then
                Coronation_TryComplete(playerID)
            elseif d.LeaderState == LEADER_STATE.PRINCE_LINE then
                -- 藩王线也可以击杀李建成
                PrinceLine_TryComplete(playerID)
            end
        end
    end
end

-- ===== 初始化 =====

function Coronation_Initialize()
    EventBus:RegisterListener(EVENTS.ON_BUILDING_CONSTRUCTED, Coronation_OnBuildingConstructed, 70)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN,   Coronation_OnTurnBegin,        85)
    EventBus:RegisterListener(EVENTS.ON_UNIT_KILLED,         Coronation_OnUnitKilled,        90)
    Log("Coronation module initialized — 玄武门之变已加载（简介.txt定版，含李建成刷新）")
end

Coronation_Initialize()

return {
    Coronation_SpawnLiJiancheng  = Coronation_SpawnLiJiancheng,
    Coronation_TryComplete      = Coronation_TryComplete,
    Coronation_OnLiJianchengKilled = Coronation_OnLiJianchengKilled,
}
