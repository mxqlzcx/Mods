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
-- Coronation.lua
-- 登基线：玄武门建成后刷新李建成，天策上将踩踏处决后转为唐太宗形态

local LiJianchengID = nil
local LiJianchengOwner = nil
local LiJianchengX = -1
local LiJianchengY = -1

-- 获取野蛮人玩家ID（动态获取最安全）
local function GetBarbarianPlayerID()
    local players = PlayerManager.GetAliveIDs()
    for _, pid in ipairs(players) do
        local p = Players[pid]
        if p and p:IsBarbarian() then
            return pid
        end
    end
    return 63
end

-- 在指定坐标生成李建成
local function SpawnLiJiancheng(x, y)
    local barbPlayerID = GetBarbarianPlayerID()
    local barbPlayer = Players[barbPlayerID]
    if not barbPlayer then return end

    local unitDef = GameInfo.Units["UNIT_LI_JIANCHENG"]
    if not unitDef then return end

    local unit = UnitManager.InitUnit(barbPlayerID, unitDef.Hash, x, y)
    if unit then
        LiJianchengID = unit:GetID()
        LiJianchengOwner = barbPlayerID
        LiJianchengX = x
        LiJianchengY = y
    end
end

-- 监听改良设施建造（玄武门建成）
function Coronation_OnImprovementAddedToMap(locX, locY, improvementType, playerID)
    if not IsLiShiminLeaderPlayer(playerID) then return end

    local impRow = GameInfo.Improvements[improvementType]
    if not impRow or impRow.ImprovementType ~= "IMPROVEMENT_XUANWU_GATE" then
        return
    end

    local d = LiShiminMod_GetOrInitPlayer(playerID)
    if not d then return end

    -- 仅在登基线或藩王线允许触发
    if d.LeaderState ~= LEADER_STATE.CORONATION and d.LeaderState ~= LEADER_STATE.PRINCE_LINE then
        return
    end

    d.XuanwuGateBuilt = true
    LiShiminSavePlayerFieldsToProperties(playerID, d)

    -- 在玄武门坐标生成李建成（野蛮人平民）
    SpawnLiJiancheng(locX, locY)

    -- 通知玩家
    ShowNotification(
        playerID,
        "LOC_LISHIMIN_NOTIFY_TITLE",
        "玄武门已建成！天策上将请速往此处，处决李建成！",
        nil,
        COLORS.WARNING
    )

    -- 触发事件和音效
    EventBus:FireEvent(EVENTS.ON_XUANWU_GATE_BUILT, playerID)
    if LuaEvents.LiShiminMod_PlayPresentation then
        LuaEvents.LiShiminMod_PlayPresentation("xuanwu_gate")
    end
end

-- 监听单位被移出地图（平民被踩踏时触发）
function Coronation_OnUnitRemovedFromMap(playerID, unitID)
    -- 如果移除的不是我们记录的李建成，直接跳过
    if playerID ~= LiJianchengOwner or unitID ~= LiJianchengID then
        return
    end

    -- 李建成被踩了！去他刚才在的格子上"抓凶手"
    local plot = Map.GetPlot(LiJianchengX, LiJianchengY)
    if not plot then return end

    local killerUnit = nil
    local killerPlayerID = nil

    -- 获取地块上现在的军事单位
    local unitCount = plot:GetUnitCount()
    for i = 0, unitCount - 1 do
        local u = plot:GetUnitByIndex(i)
        if u then
            killerUnit = u
            killerPlayerID = u:GetOwner()
            break
        end
    end

    if killerUnit then
        local unitType = GameInfo.Units[killerUnit:GetType()].UnitType

        -- 验证身份：是天策上将，且属于当前玩家
        if unitType == "UNIT_TIANCE_GENERAL" and IsLiShiminLeaderPlayer(killerPlayerID) then

            -- 处决成功！更新领袖状态
            local d = LiShiminMod_GetOrInitPlayer(killerPlayerID)
            d.LeaderState = LEADER_STATE.EMPEROR_TAIZONG
            LiShiminSavePlayerFieldsToProperties(killerPlayerID, d)

            ShowNotification(
                killerPlayerID,
                "LOC_LISHIMIN_NOTIFY_TITLE",
                "玄武喋血，大局已定！天策上将正式登基为唐太宗！",
                nil,
                COLORS.SUCCESS
            )

            -- 播放处决图片弹窗 + 登基成功音效
            if LuaEvents.LiShiminMod_PlayPresentation then
                LuaEvents.LiShiminMod_PlayPresentation("coronation_kill")
                LuaEvents.LiShiminMod_PlayPresentation("coronation_complete")
            end
            EventBus:FireEvent(EVENTS.ON_CORONATION_COMPLETED, killerPlayerID)

            -- 清理记录
            LiJianchengID = nil

        else
            -- 处决失败（杂兵踩的）
            ShowNotification(
                killerPlayerID,
                "LOC_LISHIMIN_NOTIFY_TITLE",
                "史书不可篡改！必须由天策上将亲自终结李建成！",
                nil,
                COLORS.DANGER
            )

            -- 立刻原地重刷李建成
            SpawnLiJiancheng(LiJianchengX, LiJianchengY)
        end
    end
end

-- 初始化
function Coronation_Initialize()
    Events.ImprovementAddedToMap.Add(Coronation_OnImprovementAddedToMap)
    Events.UnitRemovedFromMap.Add(Coronation_OnUnitRemovedFromMap)
end

Coronation_Initialize()