-- ============================================================
-- 天策军威（TianceAura）
-- 简介.txt定版效果：
--   天策上将周围2格范围内，每存在1个友军单位，自身防御力+5，无叠加上限。
--   摒弃无脑无敌设定，以亲兵护卫换取生存能力，贴合历史人设。
-- 实现方式：
--   在战斗开始时计算光环加成，通过临时改变单位战斗力（Combat/LockedCombat）实现。
--   注意：Civ6 英雄单位不能直接修改战斗力，这里通过 UI 层显示加成数值。
-- ============================================================

local auraCache = {}  -- playerID -> unitID -> auraBonus（缓存避免每帧重算）

-- 获取天策上将周围的友军数量
function TianceAura_CountFriendlyUnits(tianceUnit)
    if not tianceUnit or not IsTianceGeneral(tianceUnit) then
        return 0
    end
    local playerID = tianceUnit:GetOwner()
    local player = Players[playerID]
    if not player then return 0 end

    local tiancePlot = tianceUnit:GetPlot()
    if not tiancePlot then return 0 end

    local tianceX = tianceUnit:GetX()
    local tianceY = tianceUnit:GetY()
    local range = TIANCE_AURA_RANGE or 2
    local count = 0

    for _, unit in player:GetUnits():Members() do
        if not IsTianceGeneral(unit) then
            -- 只统计友军单位（排除天策上将自身）
            local unitPlot = unit:GetPlot()
            if unitPlot then
                local dist = Map.GetPlotDistance(tianceX, tianceY, unit:GetX(), unit:GetY())
                if dist <= range and dist > 0 then
                    -- 排除非战斗单位（移民、工人、商队等）
                    local row = GameInfo.Units[unit:GetUnitType()]
                    if row and row.Combat > 0 then
                        count = count + 1
                    end
                end
            end
        end
    end

    return count
end

-- 获取天策上将当前光环防御加成
function TianceAura_GetBonus(tianceUnit)
    local playerID = tianceUnit:GetOwner()
    local unitID = tianceUnit:GetID()
    if auraCache[playerID] and auraCache[playerID][unitID] then
        return auraCache[playerID][unitID]
    end
    local count = TianceAura_CountFriendlyUnits(tianceUnit)
    local bonus = count * (TIANCE_AURA_COMBAT_BONUS or 5)
    if not auraCache[playerID] then auraCache[playerID] = {} end
    auraCache[playerID][unitID] = bonus
    return bonus
end

-- 清除缓存（单位移动或被移除时调用）
function TianceAura_InvalidateCache(playerID, unitID)
    if auraCache[playerID] then
        auraCache[playerID][unitID] = nil
    end
end

-- 清除指定玩家的所有缓存
function TianceAura_InvalidatePlayerCache(playerID)
    auraCache[playerID] = nil
end

-- 获取光环状态描述（用于UI显示）
function TianceAura_GetStatusText(playerID)
    local player = Players[playerID]
    if not player then return nil end

    for _, unit in player:GetUnits():Members() do
        if IsTianceGeneral(unit) then
            local bonus = TianceAura_GetBonus(unit)
            if bonus > 0 then
                local count = TianceAura_CountFriendlyUnits(unit)
                return {
                    title   = Locale.Lookup("LOC_LISHIMIN_AURA_TITLE"),
                    body    = Locale.Lookup("LOC_LISHIMIN_AURA_STATUS", count, bonus),
                    bonus   = bonus,
                    count   = count,
                }
            else
                return {
                    title   = Locale.Lookup("LOC_LISHIMIN_AURA_TITLE"),
                    body    = Locale.Lookup("LOC_LISHIMIN_AURA_NO_BONUS"),
                    bonus   = 0,
                    count   = 0,
                }
            end
        end
    end
    return nil
end

-- ============================================================
-- 战斗修正：在天策上将发起攻击或受到攻击时，动态计算战斗值
-- ============================================================

-- 天策上将攻击时：在原有攻击力基础上叠加防御加成（反击用）
function TianceAura_ModifyCounterAttack(combatResult, tianceUnit, attackingUnit, defender)
    if not tianceUnit or not IsTianceGeneral(tianceUnit) then
        return combatResult
    end
    -- 如果天策上将是防守方，应用光环防御加成
    if defender and defender == tianceUnit then
        local bonus = TianceAura_GetBonus(tianceUnit)
        if bonus > 0 then
            combatResult.TianceAuraBonus = bonus
        end
    end
    return combatResult
end

-- ============================================================
-- 回合开始时：刷新光环状态通知
-- ============================================================

function TianceAura_OnTurnBegin(playerID)
    if not IsLiShiminLeaderPlayer(playerID) then return end
    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end
    -- 仅在天策上将和登基阶段显示光环状态
    if d.LeaderState ~= LEADER_STATE.TIANCE_GENERAL and
       d.LeaderState ~= LEADER_STATE.CORONATION then
        return
    end

    local status = TianceAura_GetStatusText(playerID)
    if status and status.bonus > 0 then
        -- 有光环加成时每10回合通知一次
        local turn = Game.GetCurrentGameTurn()
        if turn % 10 == 0 then
            ShowNotification(
                playerID,
                status.title,
                status.body,
                nil,
                COLORS.PRIMARY
            )
        end
    end
end

-- ============================================================
-- 单位移动/创建/死亡时：清除缓存
-- ============================================================

function TianceAura_OnUnitMoved(playerID, unit)
    if unit and IsTianceGeneral(unit) then
        TianceAura_InvalidateCache(playerID, unit:GetID())
        -- 同时清除所有玩家的缓存（友军单位可能属于其他玩家，但这里只关心李世民）
        TianceAura_InvalidatePlayerCache(playerID)
    end
end

function TianceAura_OnUnitCreated(playerID, unit)
    -- 新单位出现时，天策上将的光环范围可能变化
    if IsLiShiminLeaderPlayer(playerID) then
        TianceAura_InvalidatePlayerCache(playerID)
    end
end

function TianceAura_OnUnitKilled(playerID, unit)
    -- 单位死亡时，天策上将的光环范围可能变化
    if IsLiShiminLeaderPlayer(playerID) then
        TianceAura_InvalidatePlayerCache(playerID)
    end
end

-- ============================================================
-- 初始化
-- ============================================================

function TianceAura_Initialize()
    EventBus:RegisterListener(EVENTS.ON_PLAYER_TURN_BEGIN, TianceAura_OnTurnBegin, 55)
    Log("TianceAura module initialized — 天策军威光环系统已加载（简介.txt定版）")
end

TianceAura_Initialize()

return {
    TianceAura_GetBonus       = TianceAura_GetBonus,
    TianceAura_CountFriendlyUnits = TianceAura_CountFriendlyUnits,
    TianceAura_GetStatusText  = TianceAura_GetStatusText,
    TianceAura_InvalidateCache = TianceAura_InvalidateCache,
    TianceAura_ModifyCounterAttack = TianceAura_ModifyCounterAttack,
}
