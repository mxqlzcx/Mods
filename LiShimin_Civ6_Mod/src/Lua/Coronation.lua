-- 登基线：建成玄武门后经过若干回合仪式，转为唐太宗形态

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
    LiShiminNotifyStoryMoment(
        playerID,
        "LOC_LISHIMIN_NOTIFY_TITLE",
        "LOC_LISHIMIN_XUANWU_BUILT",
        "xuanwu_gate",
        COLORS.SUCCESS
    )
    EventBus:FireEvent(EVENTS.ON_XUANWU_GATE_BUILT, playerID, city)
    Coronation_TryComplete(playerID)
    PrinceLine_TryComplete(playerID)
end

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

function Coronation_TryComplete(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.CORONATION then
        return
    end
    local need = CORONATION_MIN_TURNS_AFTER_GATE or 3
    if d.XuanwuGateBuilt and (d.CoronationTurnsSinceGate or 0) >= need then
        d.LeaderState = LEADER_STATE.EMPEROR_TAIZONG
        LiShiminSavePlayerFieldsToProperties(playerID, d)
        LiShiminNotifyStoryMoment(
            playerID,
            "LOC_LISHIMIN_NOTIFY_TITLE",
            "LOC_LISHIMIN_CORONATION_SUCCESS",
            "coronation_complete",
            COLORS.SUCCESS
        )
        EventBus:FireEvent(EVENTS.ON_CORONATION_COMPLETED, playerID)
    end
end
