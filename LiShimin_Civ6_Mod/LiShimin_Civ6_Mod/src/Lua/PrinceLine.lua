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
        end
    end

    d.XuanwuGateBuilt = PlayerHasBuildingType(playerID, BUILDING_XUANWU_GATE)
    LiShiminSavePlayerFieldsToProperties(playerID, d)

    ShowNotification(
        playerID,
        "LOC_LISHIMIN_PRINCE_TITLE",
        "LOC_LISHIMIN_PRINCE_START",
        nil,
        COLORS.WARNING
    )

    EventBus:FireEvent(EVENTS.ON_PRINCE_LINE_ACTIVATED, playerID)
end

-- ===== 回合开始 =====

function PrinceLine_OnTurnBegin(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.PRINCE_LINE then
        return
    end

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
        return
    end

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
        return
    end
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
    local gateOk = d.XuanwuGateBuilt or PlayerHasBuildingType(playerID, BUILDING_XUANWU_GATE)
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

    return true
end

function TianceGeneralIsAlive(playerID)
    local player = Players[playerID]
    if not player then return false end
    for _, unit in player:GetUnits():Members() do
        if IsTianceGeneral(unit) then
            return true
        end
    end
    return false
end

-- ===== 尝试完成藩王线 =====

function PrinceLine_TryComplete(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.PRINCE_LINE then
        return
    end

    if not PrinceLine_IsWinSatisfied(playerID, d) then
        return
    end

    -- 满足全部条件：复辟成功
    d.LeaderState = LEADER_STATE.EMPEROR_TAIZONG
    d.RestorationTurnsRemaining = -1
    LiShiminSavePlayerFieldsToProperties(playerID, d)

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
        return
    end
    if PrinceLine_IsWinSatisfied(playerID, d) then
        return
    end

    -- 简介.txt定版：超时后不再直接结束游戏，触发全图围剿
    ShowNotification(
        playerID,
        "LOC_LISHIMIN_PRINCE_TITLE",
        "LOC_LISHIMIN_RESTORATION_FAILED",
        nil,
        COLORS.DANGER
    )

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

return {
    PrinceLine_Activate       = PrinceLine_Activate,
    PrinceLine_TryComplete    = PrinceLine_TryComplete,
    PrinceLine_CheckFailure   = PrinceLine_CheckFailure,
    PrinceLine_IsWinSatisfied = PrinceLine_IsWinSatisfied,
    TianceGeneralIsAlive      = TianceGeneralIsAlive,
}
