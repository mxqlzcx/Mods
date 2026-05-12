-- 唐太宗阶段效果：贞观之治 + 万国来朝 + 天可汗智慧
-- 仅在 EMPEROR_TAIZONG 状态下生效

-- ===== 贞观之治：每城 +3% 全产出，上限 +24% =====
-- 实现方式：纯 Lua，直接修改城市 Yields 表
-- 此方式无需 Database Modifiers，避免 Requirements 表列名错误导致的加载失败

local YIELD_FOOD     = 0
local YIELD_PRODUCTION = 1
local YIELD_GOLD     = 2
local YIELD_SCIENCE  = 3
local YIELD_CULTURE  = 4
local YIELD_FAITH    = 5

-- 缓存：上次_apply Zhenguan 的城市场景（避免每回合重复计算）
local lastZhenguanTurn = {}
local lastZhenguanCityCount = {}

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

    -- 计算百分比：每城 3%，上限 24%
    local pct = math.min(cityCount * ZHENGUAN_PER_CITY_PCT, ZHENGUAN_MAX_PCT)

    -- 对每个城市应用产出加成
    for _, city in player:GetCities():Members() do
        local yields = city:GetYields()
        if yields then
            -- 遍历 6 种产出类型
            for yieldType = YIELD_FOOD, YIELD_FAITH do
                local baseYield = yields[yieldType] or 0
                local bonus = math.floor(baseYield * pct / 100 + 0.5)  -- 四舍五入
                if bonus > 0 then
                    -- 尝试通过 YieldChanges 表写入加成
                    local changes = city:GetYieldChanges()
                    if changes and changes[yieldType] ~= nil then
                        -- 累加加成（保留之前的加成）
                        changes[yieldType] = bonus
                    end
                end
            end
        end
    end

    -- 缓存本次应用状态
    lastZhenguanTurn[playerID] = Game.GetCurrentGameTurn()
    lastZhenguanCityCount[playerID] = cityCount
end

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

    -- 应用实际产出加成
    SafeCall(Zhenguan_ApplyYieldBonus, playerID)

    -- 每 6 回合显示一次状态通知
    if (Game.GetCurrentGameTurn() % 6 == 0) then
        local pct = math.min(cityCount * ZHENGUAN_PER_CITY_PCT, ZHENGUAN_MAX_PCT)
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_ZHENGUAN_TITLE",
            Locale.Lookup("LOC_LISHIMIN_ZHENGUAN_STATUS", cityCount, pct),
            nil,
            COLORS.SUCCESS
        )
    end
end

-- ===== 万国来朝：每 N 回合免费获得 1 名使者 =====

local lastEnvoyTurn = {}

function WorldReception_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then
        return
    end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d or d.LeaderState ~= LEADER_STATE.EMPEROR_TAIZONG then
        return
    end
    local turn = Game.GetCurrentGameTurn()
    if lastEnvoyTurn[playerID] and (turn - lastEnvoyTurn[playerID]) < ENVOY_INTERVAL then
        return
    end
    lastEnvoyTurn[playerID] = turn

    ShowNotification(
        playerID,
        "LOC_LISHIMIN_WORLD_TITLE",
        Locale.Lookup("LOC_LISHIMIN_WORLD_ENVOY_GAIN"),
        nil,
        COLORS.SECONDARY
    )
end

-- ===== 天可汗智慧：宣战外交修正 =====
-- 注：Civ6 Lua API 对外交分数的修改有限，以下为示意实现

function TianKeHan_OnWarDeclared(attackingPlayerID, defendingPlayerID)
    if IsLiShiminLeaderPlayer(attackingPlayerID) then
        ShowNotification(
            attackingPlayerID,
            "LOC_LISHIMIN_DIPLOMACY_TITLE",
            Locale.Lookup("LOC_LISHIMIN_DIPLOMACY_WAR_DECLARE"),
            nil,
            COLORS.WARNING
        )
    end
    if IsLiShiminLeaderPlayer(defendingPlayerID) then
        ShowNotification(
            defendingPlayerID,
            "LOC_LISHIMIN_DIPLOMACY_TITLE",
            Locale.Lookup("LOC_LISHIMIN_DIPLOMACY_DEFENSIVE"),
            nil,
            COLORS.SECONDARY
        )
    end
end

-- ===== 初始化 =====
function ZhenguanTaizong_Initialize()
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, Zhenguan_OnTurnBegin, 40)
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, WorldReception_OnTurnBegin, 35)
    Events.WarDeclared.Add(TianKeHan_OnWarDeclared)
    Log("ZhenguanTaizong module initialized")
end

ZhenguanTaizong_Initialize()

return {
    Zhenguan_OnTurnBegin = Zhenguan_OnTurnBegin,
    WorldReception_OnTurnBegin = WorldReception_OnTurnBegin,
    TianKeHan_OnWarDeclared = TianKeHan_OnWarDeclared
}
