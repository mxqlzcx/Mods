-- 藩王线：进入中世纪时征服不足5城则触发惩罚任务
-- 限30回合内：夺回首都 + 保全上将 + 完成玄武门仪式

function PrinceLine_Activate(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end
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

    -- 首都变为自由城市（如果未被占领）
    local capCity = GetCapitalCity(Players[playerID])
    if capCity then
        -- 注：Civ6 Lua API 直接设置城市所有权有限
        -- 完整实现可能需要通过 FreeCity 事件
    end

    ShowNotification(
        playerID,
        "LOC_LISHIMIN_PRINCE_TITLE",
        "LOC_LISHIMIN_PRINCE_START",
        nil,
        COLORS.WARNING
    )
    EventBus:FireEvent(EVENTS.ON_PRINCE_LINE_ACTIVATED, playerID)
end

function PrinceLine_OnCityConquered(ownerID, city, conquerorID)
    local d = LiShiminMod_GetOrInitPlayer(conquerorID)
    if not d or d.LeaderState ~= LEADER_STATE.PRINCE_LINE then
        return
    end
    local prev = Players[ownerID]
    if prev and prev:IsBarbarian() then return end
    d.PrinceConquestsSinceLine = (d.PrinceConquestsSinceLine or 0) + 1
    LiShiminSavePlayerFieldsToProperties(conquerorID, d)
    PrinceLine_TryComplete(conquerorID)
end

function PrinceLine_OnTurnBegin(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.PRINCE_LINE then
        return
    end
    local rem = d.RestorationTurnsRemaining or 0
    local interval = PRINCE_REMINDER_INTERVAL or 5
    if rem > 0 and interval > 0 and (rem % interval == 0) then
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_PRINCE_TITLE",
            Locale.Lookup("LOC_LISHIMIN_PRINCE_COUNTDOWN", rem),
            nil,
            COLORS.WARNING
        )
    end
    PrinceLine_TryComplete(playerID)
end

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
            PrinceLine_TryComplete(playerID)
            PrinceLine_CheckFailure(playerID)
        end
    end
end

function PrinceLine_IsWinSatisfied(playerID, d)
    if not d then return false end
    local gateOk = d.XuanwuGateBuilt or PlayerHasBuildingType(playerID, BUILDING_XUANWU_GATE)
    local need = PRINCE_EXTRA_CONQUESTS_REQUIRED or 1
    local conqOk = (d.PrinceConquestsSinceLine or 0) >= need
    local ownsCapital = true
    if d.CapitalX and d.CapitalY and d.CapitalX >= 0 and d.CapitalY >= 0 then
        ownsCapital = PlotOwnedByMajor(playerID, d.CapitalX, d.CapitalY)
    end
    -- 还需验证天策上将存活
    local tianceAlive = TianceGeneralIsAlive(playerID)
    return gateOk and conqOk and ownsCapital and tianceAlive
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

function PrinceLine_TryComplete(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.PRINCE_LINE then
        return
    end
    if not PrinceLine_IsWinSatisfied(playerID, d) then return end
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
    EventBus:FireEvent(EVENTS.ON_RESTORATION_COMPLETED, playerID)
end

function PrinceLine_CheckFailure(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.PRINCE_LINE then
        return
    end
    if PrinceLine_IsWinSatisfied(playerID, d) then return end
    ShowNotification(
        playerID,
        "LOC_LISHIMIN_PRINCE_TITLE",
        "LOC_LISHIMIN_RESTORATION_FAILED",
        nil,
        COLORS.DANGER
    )
    EventBus:FireEvent(EVENTS.ON_RESTORATION_FAILED, playerID)
    LuaEvents.LiShiminMod_EndGame(playerID)
end
