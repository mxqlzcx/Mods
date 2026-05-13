-- ============================================================
-- 天策府十八学士：每招募1名伟人，原始首都全产出+6，最多3层（+18）
-- 定版实现：
--   Dummy Buildings: BUILDING_TALENT_SCHOLAR_1/2/3
--   各自在 XML Building_YieldChanges 中配置 +6/+12/+18 全产出
--   Lua 负责：招募伟人时在首都创建对应建筑，切换唐太宗时清空
--   仅在「天策上将」和「登基仪式」期间生效
-- ============================================================

-- 伟人招募回调
function TalentReserve_OnGreatPersonRecruited(playerID, greatPersonID, greatPersonType)
    if not IsLiShiminLeaderPlayer(playerID) then return end

    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end

    -- 唐太宗阶段不叠加
    if d.LeaderState == LEADER_STATE.EMPEROR_TAIZONG then return end

    local prevStacks = d.TalentStacks or 0
    local newStacks = math.min(prevStacks + 1, TALENT_RESERVE_MAX_STACKS)
    if newStacks == prevStacks then return end  -- 已达上限

    d.TalentStacks = newStacks
    LiShiminSavePlayerFieldsToProperties(playerID, d)

    -- 创建对应等级的 Dummy Building
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

-- ===== 在首都创建 Dummy Building =====
function TalentReserve_ApplyCapitalBuilding(playerID, stacks)
    local player = Players[playerID]
    if not player then return end
    local capital = GetCapitalCity(player)
    if not capital then return end

    -- 先清除旧建筑
    TalentReserve_RemoveAllScholarBuildings(capital)

    -- 无层数则不创建任何建筑
    if stacks <= 0 then return end

    -- 确定建筑类型
    local buildingType
    if stacks == 1 then
        buildingType = GameInfo.Buildings["BUILDING_TALENT_SCHOLAR_1"]
    elseif stacks == 2 then
        buildingType = GameInfo.Buildings["BUILDING_TALENT_SCHOLAR_2"]
    elseif stacks >= 3 then
        buildingType = GameInfo.Buildings["BUILDING_TALENT_SCHOLAR_3"]
    end

    if not buildingType then return end

    -- 检查建筑是否已存在
    if capital:GetBuildings():HasBuilding(buildingType.Index) then return end

    -- 在首都创建建筑（直接授予，不计入建造队列）
    capital:GetBuildQueue():CreateBuilding(buildingType.Index, 100)
end

-- ===== 移除所有十八学士建筑 =====
function TalentReserve_RemoveAllScholarBuildings(city)
    if not city then return end
    local buildings = city:GetBuildings()
    if not buildings then return end

    for _, idx in ipairs({
        GameInfo.Buildings["BUILDING_TALENT_SCHOLAR_1"] and GameInfo.Buildings["BUILDING_TALENT_SCHOLAR_1"].Index,
        GameInfo.Buildings["BUILDING_TALENT_SCHOLAR_2"] and GameInfo.Buildings["BUILDING_TALENT_SCHOLAR_2"].Index,
        GameInfo.Buildings["BUILDING_TALENT_SCHOLAR_3"] and GameInfo.Buildings["BUILDING_TALENT_SCHOLAR_3"].Index,
    }) do
        if idx and buildings:HasBuilding(idx) then
            buildings:RemoveBuilding(idx)
        end
    end
end

-- ===== 切换唐太宗时清空 =====
function TalentReserve_OnCoronationComplete(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then return end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end

    d.TalentStacks = 0
    LiShiminSavePlayerFieldsToProperties(playerID, d)

    local player = Players[playerID]
    if player then
        local capital = GetCapitalCity(player)
        TalentReserve_RemoveAllScholarBuildings(capital)
    end
end

-- ===== 藩王线激活时保留 ≠ 不再叠加 =====
function TalentReserve_OnPrinceLineActivated(playerID)
    -- 保留已有建筑，但不再通过伟人招募叠加
    -- 通知由 Main.lua 统一分发，此处无需重复创建
end

-- ===== 每回合补建（防建筑被意外移除）=====
function TalentReserve_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then return end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end
    if d.LeaderState == LEADER_STATE.EMPEROR_TAIZONG then return end

    local stacks = d.TalentStacks or 0
    if stacks <= 0 then return end

    local player = Players[playerID]
    if not player then return end
    local capital = GetCapitalCity(player)
    if not capital then return end

    TalentReserve_ApplyCapitalBuilding(playerID, stacks)
end

-- ===== 初始化 =====
function TalentReserve_Initialize()
    EventBus:RegisterListener(EVENTS.ON_GREAT_PERSON_RECRUITED, TalentReserve_OnGreatPersonRecruited, 50)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, TalentReserve_OnTurnBegin, 45)
    EventBus:RegisterListener(EVENTS.ON_CORONATION_COMPLETED, TalentReserve_OnCoronationComplete, 40)
    EventBus:RegisterListener(EVENTS.ON_PRINCE_LINE_ACTIVATED, TalentReserve_OnPrinceLineActivated, 40)
    Log("TalentReserve module initialized — 天策府十八学士已加载（DummyBuilding 定版）")
end

TalentReserve_Initialize()

return {
    TalentReserve_OnGreatPersonRecruited = TalentReserve_OnGreatPersonRecruited,
    TalentReserve_OnTurnBegin = TalentReserve_OnTurnBegin,
    TalentReserve_ApplyCapitalBuilding = TalentReserve_ApplyCapitalBuilding,
    TalentReserve_RemoveAllScholarBuildings = TalentReserve_RemoveAllScholarBuildings,
}
