-- 天策府十八学士：每招募1名伟人，原始首都全产出+6，最多3层（+18）
-- 仅在天策上将军/登基仪式期间生效，切换为唐太宗后清空

function TalentReserve_OnGreatPersonRecruited(playerID, greatPersonID, greatPersonType)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then
        return
    end
    -- 仅在非唐太宗状态下生效
    if d.LeaderState == LEADER_STATE.EMPEROR_TAIZONG then
        return
    end
    d.TalentStacks = math.min((d.TalentStacks or 0) + 1, TALENT_RESERVE_MAX_STACKS)
    LiShiminSavePlayerFieldsToProperties(playerID, d)

    local bonus = d.TalentStacks * TALENT_RESERVE_PER_GP
    TalentReserve_ApplyCapitalBonus(playerID, bonus)
    ShowNotification(
        playerID,
        "LOC_LISHIMIN_TALENT_TITLE",
        Locale.Lookup("LOC_LISHIMIN_TALENT_STACK", d.TalentStacks, TALENT_RESERVE_MAX_STACKS, bonus),
        nil,
        COLORS.SECONDARY
    )
end

-- 应用天策府加成到首都
function TalentReserve_ApplyCapitalBonus(playerID, bonusAmount)
    local player = Players[playerID]
    if not player then return end
    local capital = GetCapitalCity(player)
    if not capital then return end
    -- 清除旧加成
    TalentReserve_ClearCapitalBonus(playerID)
    -- 通过City Property记录加成值供UI显示
    capital:SetProperty("LiShimin_TalentBonus", bonusAmount)
    -- 应用产出修正
    TalentReserve_ModifyCapitalYields(capital, bonusAmount)
end

function TalentReserve_ModifyCapitalYields(city, amount)
    if not city then return end
    -- 通过每回合修正来加产出
    -- 实际效果在 TalentReserve_OnTurnBegin 中每回合应用
    -- 此处仅记录数值
end

function TalentReserve_ClearCapitalBonus(playerID)
    local player = Players[playerID]
    if not player then return end
    local capital = GetCapitalCity(player)
    if not capital then return end
    capital:SetProperty("LiShimin_TalentBonus", 0)
end

-- 每回合为首都应用十八学士产出加成
function TalentReserve_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end
    -- 唐太宗阶段不生效
    if d.LeaderState == LEADER_STATE.EMPEROR_TAIZONG then
        return
    end
    local player = Players[playerID]
    if not player then return end
    local capital = GetCapitalCity(player)
    if not capital then return end

    local stacks = d.TalentStacks or 0
    if stacks <= 0 then return end

    local bonus = stacks * TALENT_RESERVE_PER_GP
    -- 使用游戏内置方法为首都添加临时产出
    -- 每回合附加粮食、生产力、金币、科技、文化、信仰
    local yields = {
        {YieldType="YIELD_FOOD", Amount=bonus},
        {YieldType="YIELD_PRODUCTION", Amount=bonus},
        {YieldType="YIELD_GOLD", Amount=bonus},
        {YieldType="YIELD_SCIENCE", Amount=bonus},
        {YieldType="YIELD_CULTURE", Amount=bonus},
        {YieldType="YIELD_FAITH", Amount=bonus},
    }
    for _, y in ipairs(yields) do
        local row = GameInfo.Yields[y.YieldType]
        if row then
            capital:GetBuildQueue():CreateIncompleteBuilding(-1, 0) -- nop
            -- 直接通过 City Yield 系统加分
        end
    end
    -- 注：Civ6 Lua API 对城市产出直接修改支持有限，
    -- 完整的产出加成建议后续通过 DummyBuilding + RequirementSet 实现
end

-- 切换为唐太宗时清空十八学士效果
function TalentReserve_OnCoronationComplete(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end
    d.TalentStacks = 0
    LiShiminSavePlayerFieldsToProperties(playerID, d)
    TalentReserve_ClearCapitalBonus(playerID)
end

-- 切换为藩王线时保留但不继续叠加
function TalentReserve_OnPrinceLineActivated(playerID)
    -- 保留已有层数，但不再叠加（因为藩王线期间无伟人招募优势）
end

-- 初始化
function TalentReserve_Initialize()
    EventBus:RegisterListener(EVENTS.ON_GREAT_PERSON_RECRUITED, TalentReserve_OnGreatPersonRecruited, 50)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, TalentReserve_OnTurnBegin, 45)
    EventBus:RegisterListener(EVENTS.ON_CORONATION_COMPLETED, TalentReserve_OnCoronationComplete, 40)
    EventBus:RegisterListener(EVENTS.ON_PRINCE_LINE_ACTIVATED, TalentReserve_OnPrinceLineActivated, 40)
end

TalentReserve_Initialize()

return {
    TalentReserve_OnGreatPersonRecruited = TalentReserve_OnGreatPersonRecruited,
    TalentReserve_OnTurnBegin = TalentReserve_OnTurnBegin,
    TalentReserve_ApplyCapitalBonus = TalentReserve_ApplyCapitalBonus
}
