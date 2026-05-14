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
-- 天策府十八学士：每招募1名伟人，原始首都全产出+6，最多3层（+18）
-- ============================================================

-- 伟人招募回调
function TalentReserve_OnGreatPersonRecruited(playerID, greatPersonID, greatPersonType)
    Log("TalentReserve: OnGreatPersonRecruited fired for pid=" .. tostring(playerID))
    if not IsLiShiminLeaderPlayer(playerID) then
        Log("TalentReserve: not LiShimin player, skipping")
        return
    end

    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then
        Log("TalentReserve: player data nil, skipping")
        return
    end

    if d.LeaderState == LEADER_STATE.EMPEROR_TAIZONG then
        Log("TalentReserve: already EMPEROR_TAIZONG, skipping")
        return
    end

    local prevStacks = d.TalentStacks or 0
    local newStacks = math.min(prevStacks + 1, TALENT_RESERVE_MAX_STACKS)
    if newStacks == prevStacks then
        Log("TalentReserve: stacks at max (" .. newStacks .. "), skipping")
        return
    end

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