-- ============================================================
-- 唐太宗阶段效果：贞观之治 + 万国来朝 + 天可汗智慧
-- 仅在 EMPEROR_TAIZONG 状态下生效
-- 同步更新自 简介.txt（定版）
-- ============================================================

-- ===== 贞观之治：每城+1%，上限+10% =====
-- 实现方式：纯 Lua，通过城市 Property 记录加成，由 UI 层读取显示
-- 注：Civ6 Lua API 对城市 Yields 表的实时修改支持有限，
--     完整实现建议通过 DummyBuilding + Modifier + RequirementSet
--     此处采用 Property + Notification 方式作为基础实现

local YIELD_FOOD        = 0
local YIELD_PRODUCTION  = 1
local YIELD_GOLD       = 2
local YIELD_SCIENCE    = 3
local YIELD_CULTURE    = 4
local YIELD_FAITH      = 5

-- 缓存：上次应用的城市场景（避免每回合重复计算）
local lastZhenguanTurn       = {}
local lastZhenguanCityCount  = {}

-- 获取贞观之治当前加成百分比
function Zhenguan_GetCurrentBonusPct(playerID)
    local player = Players[playerID]
    if not player then return 0 end
    local cityCount = player:GetCities():GetCount()
    if cityCount <= 0 then return 0 end
    -- 简介.txt定版：每城+1%，上限+10%
    local pct = math.min(cityCount * (ZHENGUAN_PER_CITY_PCT or 1), (ZHENGUAN_MAX_PCT or 10))
    return pct
end

-- 应用贞观之治加成到城市（Property记录，UI读取）
function Zhenguan_ApplyYieldBonus(playerID)
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end

    -- 仅在唐太宗阶段生效
    if d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then
        return
    end

    local player = Players[playerID]
    if not player then return end

    local cityCount = player:GetCities():GetCount()
    if cityCount <= 0 then return end

    -- 简介.txt定版：每城1%，上限10%
    local pct = math.min(cityCount * (ZHENGUAN_PER_CITY_PCT or 1), (ZHENGUAN_MAX_PCT or 10))
    local bonus = pct

    -- 对每个城市记录加成（供UI显示）
    for _, city in player:GetCities():Members() do
        city:SetProperty("LiShimin_ZhenguanBonus", bonus)
        -- 标注基础产出来源（玩家实际感知效果需要通过 Modifier）
        -- 此处设置一个基础数值，由游戏机制在后续自动乘算
        -- Civ6 中：城市基础产出 × (1 + pct/100) 即为最终产出
    end

    -- 缓存本次应用状态
    lastZhenguanTurn[playerID]       = Game.GetCurrentGameTurn()
    lastZhenguanCityCount[playerID]  = cityCount
end

-- 贞观之治每回合主入口
function Zhenguan_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then
        return
    end
    local player = Players[playerID]
    if not player then return end

    local cityCount = player:GetCities():GetCount()
    if cityCount <= 0 then return end

    -- 应用加成
    SafeCall(Zhenguan_ApplyYieldBonus, playerID)

    -- 简介.txt定版：每10回合通知一次贞观之治状态
    local turn = Game.GetCurrentGameTurn()
    if (turn % 10 == 0) then
        local pct = Zhenguan_GetCurrentBonusPct(playerID)
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_ZHENGUAN_TITLE",
            Locale.Lookup("LOC_LISHIMIN_ZHENGUAN_STATUS", cityCount, pct),
            nil,
            COLORS.SUCCESS
        )
    end
end

-- ===== 万国来朝：每10回合免费获得1名使者 =====

local lastEnvoyTurn = {}

function WorldReception_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then
        return
    end

    -- 如果 TianKeHan 模块存在且有效，则由 TianKeHan 接管使者发放
    -- 此处保留独立实现作为备用（双重保险）
    if TianKeHan_GrantFreeEnvoy then
        return  -- 由 TianKeHan 统一处理
    end

    local turn = Game.GetCurrentGameTurn()
    local interval = ENVOY_INTERVAL or 10   -- 简介.txt定版：每10回合
    if lastEnvoyTurn[playerID] and (turn - lastEnvoyTurn[playerID]) < interval then
        return
    end
    lastEnvoyTurn[playerID] = turn

    -- 发放免费使者
    local granted = WorldReception_GrantEnvoy(playerID)

    ShowNotification(
        playerID,
        "LOC_LISHIMIN_WORLD_TITLE",
        Locale.Lookup("LOC_LISHIMIN_WORLD_ENVOY_GAIN"),
        nil,
        COLORS.SECONDARY
    )
end

-- 实际发放使者
function WorldReception_GrantEnvoy(playerID)
    -- 寻找玩家还不是宗主国的城邦
    local candidates = {}
    for csID = GameDefines.MAX_MAJOR_CIVS, GameDefines.MAX_CIVS - 1 do
        local csPlayer = Players[csID]
        if csPlayer and csPlayer:IsAlive() then
            if not csPlayer:IsSuzerain(playerID) then
                table.insert(candidates, csID)
            end
        end
    end

    if #candidates == 0 then
        return false
    end

    -- 随机选一个发放
    local targetID = candidates[math.random(#candidates)]

    local tokenInfo = GameInfo.InfluenceTokens["INFLUENCE_TOKEN_TYPE_ENVOY"]
    if tokenInfo then
        InfluenceManager.ChangeStat(
            playerID,
            targetID,
            tokenInfo.Hash,
            1,
            "LiShimin_WorldReception"
        )
        return true
    end

    return false
end

-- ===== 天可汗智慧：主动宣战外交修正 =====

function TianKeHan_OnWarDeclared(attackingPlayerID, defendingPlayerID)
    if IsLiShiminLeaderPlayer(attackingPlayerID) then
        -- 玩家主动宣战：所有领袖好感-10（通知）
        ShowNotification(
            attackingPlayerID,
            "LOC_LISHIMIN_TIANZI_YANU_TITLE",
            "LOC_LISHIMIN_TIANZI_YANU_WAR_DECLARED",
            nil,
            COLORS.WARNING
        )
    end
    if IsLiShiminLeaderPlayer(defendingPlayerID) then
        -- 玩家被宣战：所有领袖好感+15（通知）
        ShowNotification(
            defendingPlayerID,
            "LOC_LISHIMIN_DIPLOMACY_TITLE",
            "LOC_LISHIMIN_DIPLOMACY_DEFENSIVE",
            nil,
            COLORS.SECONDARY
        )
    end
end

-- ===== 初始化 =====
function ZhenguanTaizong_Initialize()
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, Zhenguan_OnTurnBegin, 40)
    -- WorldReception 由 TianKeHan 模块接管，此处仅作备用
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, WorldReception_OnTurnBegin, 35)
    Events.WarDeclared.Add(TianKeHan_OnWarDeclared)
    Log("ZhenguanTaizong module initialized — 贞观之治/万国来朝已加载（简介.txt定版）")
end

ZhenguanTaizong_Initialize()

return {
    Zhenguan_OnTurnBegin       = Zhenguan_OnTurnBegin,
    WorldReception_OnTurnBegin = WorldReception_OnTurnBegin,
    TianKeHan_OnWarDeclared    = TianKeHan_OnWarDeclared,
    Zhenguan_GetCurrentBonusPct = Zhenguan_GetCurrentBonusPct,
}
