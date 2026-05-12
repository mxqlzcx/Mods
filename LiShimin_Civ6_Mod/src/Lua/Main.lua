-- 模组入口：注册事件、驱动天策上将 / 登基线 / 藩王线 / 唐太宗状态机

LiShiminMod = LiShiminMod or {}
LiShiminMod.Players = LiShiminMod.Players or {}
LiShiminMod.Version = MOD_VERSION or "2.0.0"

-- ===== 游戏生命周期 =====

function LiShiminMod_OnGameStart()
    for pid = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        LiShiminMod.Players[pid] = nil
        if IsLiShiminLeaderPlayer(pid) then
            local d = LiShiminMod_GetOrInitPlayer(pid)
            -- 开局赠送天策上将
            SpawnTianceGeneral(pid)
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
        end
    end
end

-- ===== 每回合事件 =====

function LiShiminMod_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    LiShiminMod_GetOrInitPlayer(playerID)
    Coronation_OnTurnBegin(playerID)
    PrinceLine_OnTurnBegin(playerID)
end

function LiShiminMod_OnTurnEnd(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    PrinceLine_OnTurnEnd(playerID)
end

-- ===== 时代变更 → 走登基线还是藩王线 =====

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
        -- 登基线
        d.LeaderState = LEADER_STATE.CORONATION
        d.CoronationTurnsSinceGate = 0
        if PlayerHasBuildingType(playerID, BUILDING_XUANWU_GATE) then
            d.XuanwuGateBuilt = true
        end
        LiShiminSavePlayerFieldsToProperties(playerID, d)
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_NOTIFY_TITLE",
            "LOC_LISHIMIN_ERA_CORONATION_PATH",
            nil,
            COLORS.SECONDARY
        )
        Coronation_TryComplete(playerID)
    else
        -- 藩王线
        d.LeaderState = LEADER_STATE.PRINCE_LINE
        LiShiminSavePlayerFieldsToProperties(playerID, d)
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_NOTIFY_TITLE",
            "LOC_LISHIMIN_ERA_PRINCE_PATH",
            nil,
            COLORS.WARNING
        )
        PrinceLine_Activate(playerID)
    end
end

-- ===== 城市征服 =====

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

-- ===== 天策上将死亡 =====

function LiShiminMod_OnUnitKilled(playerID, unit, unitsKilled)
    if not unit then return end
    if not IsTianceGeneral(unit) then return end
    if not IsLiShiminLeaderPlayer(playerID) then return end
    HandleTianceGeneralDeath(playerID)
end

-- ===== 建筑建成（玄武门） =====

function LiShiminMod_OnBuildingConstructed(playerID, city, buildingHash, plotID, isOriginalConstruction)
    Coronation_OnBuildingConstructed(playerID, city, buildingHash)
end

-- ===== 开局生成天策上将 =====

function SpawnTianceGeneral(playerID)
    local player = Players[playerID]
    if not player then return end
    local capital = GetCapitalCity(player)
    if not capital then return end
    local plot = Map.GetPlot(capital:GetX(), capital:GetY())
    if not plot then return end

    -- 在首都周围找一个空地
    local unitPlot = nil
    for dx = -1, 1 do
        for dy = -1, 1 do
            local p = Map.GetPlot(capital:GetX() + dx, capital:GetY() + dy)
            if p and p:GetImprovementType() == -1 and not p:IsMountain() and not p:IsWater() then
                unitPlot = p
                break
            end
        end
        if unitPlot then break end
    end
    if not unitPlot then
        unitPlot = plot
    end

    local unitInfo = GameInfo.Units[UNIT_TIANCE_GENERAL]
    if unitInfo then
        local unit = UnitManager.InitUnit(player, unitInfo.Hash, unitPlot:GetX(), unitPlot:GetY())
        if unit then
            ShowNotification(
                playerID,
                "LOC_LISHIMIN_NOTIFY_TITLE",
                "LOC_LISHIMIN_TIANCE_SPAWNED",
                nil,
                COLORS.PRIMARY
            )
        end
    end
end

-- ===== 初始化 =====

function LiShiminMod_Initialize()
    RegisterGameEvents()
    RegisterCustomEvents()
    EventBus:RegisterListener(EVENTS.ON_GAME_START, LiShiminMod_OnGameStart, 100)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, LiShiminMod_OnTurnBegin, 90)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_END, LiShiminMod_OnTurnEnd, 90)
    EventBus:RegisterListener(EVENTS.ON_ERA_CHANGED, LiShiminMod_OnEraChanged, 80)
    EventBus:RegisterListener(EVENTS.ON_CITY_CONQUERED, LiShiminMod_OnCityConquered, 80)
    EventBus:RegisterListener(EVENTS.ON_UNIT_KILLED, LiShiminMod_OnUnitKilled, 100)
    EventBus:RegisterListener(EVENTS.ON_BUILDING_CONSTRUCTED, LiShiminMod_OnBuildingConstructed, 70)
    if Events.LoadGameViewStateDone then
        Events.LoadGameViewStateDone.Add(function()
            LiShiminMod_OnLoadGame()
        end)
    end
    LogDebug("LiShiminMod initialized")
end

LiShiminMod_Initialize()
