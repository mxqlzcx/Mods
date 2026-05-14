-- ===== 防御性依赖检查 =====
print("[LiShiminMod] EventBus.lua loading... DEBUG_MODE=" .. tostring(DEBUG_MODE) .. " LogDebug=" .. tostring(LogDebug) .. " print=" .. tostring(print))
if not LogDebug then
    -- Civ6 中 include() 用于加载同 mod 下的 Lua 文件
    local utilsLoaded, utilsErr = pcall(function()
        include("Utils.lua")
    end)
    if not utilsLoaded then
        -- include 路径可能需要相对于脚本根目录
        utilsLoaded, utilsErr = pcall(function()
            include("src/Lua/Utils.lua")
        end)
    end
    if not utilsLoaded then
        -- 最后手段：内联定义核心函数
        function LogDebug(msg) print("[LiShiminMod][DBG] " .. tostring(msg)) end
        function LogWarning(msg) print("[LiShiminMod][WARN] " .. tostring(msg)) end
        function LogError(msg) print("[LiShiminMod][ERR] " .. tostring(msg)) end
        function SafeCall(func, ...)
            local ok, result = pcall(func, ...)
            if not ok then print("[LiShiminMod][ERR] SafeCall: " .. tostring(result)) end
            return result
        end
        function IsNilOrEmpty(v) return v == nil or v == "" end
        print("[LiShiminMod][ERR] Utils.lua failed to load, using inline fallbacks: " .. tostring(utilsErr))
    else
        print("[LiShiminMod] Utils.lua loaded via include()")
    end
end

-- ===== 事件名称常量（必须在 EventBus:Initialize() 之前定义）=====
EVENTS = {
    -- 核心游戏事件
    ON_GAME_START             = "ON_GAME_START",
    ON_PLAYER_TURN_BEGIN      = "ON_PLAYER_TURN_BEGIN",
    ON_PLAYER_TURN_END        = "ON_PLAYER_TURN_END",
    ON_UNIT_CREATED           = "ON_UNIT_CREATED",
    ON_UNIT_KILLED            = "ON_UNIT_KILLED",
    ON_CITY_CONQUERED         = "ON_CITY_CONQUERED",
    ON_GREAT_PERSON_RECRUITED = "ON_GREAT_PERSON_RECRUITED",
    ON_ERA_CHANGED            = "ON_ERA_CHANGED",
    ON_BUILDING_CONSTRUCTED   = "ON_BUILDING_CONSTRUCTED",
    -- 模组自定义事件
    ON_XUANWU_GATE_BUILT      = "ON_XUANWU_GATE_BUILT",
    ON_SHOOT_LI_JIANCHENG     = "ON_SHOOT_LI_JIANCHENG",
    ON_CORONATION_COMPLETED   = "ON_CORONATION_COMPLETED",
    ON_PRINCE_LINE_ACTIVATED  = "ON_PRINCE_LINE_ACTIVATED",
    ON_RESTORATION_COMPLETED  = "ON_RESTORATION_COMPLETED",
    ON_RESTORATION_FAILED     = "ON_RESTORATION_FAILED",
}

-- 事件总线系统
-- 用于模组内部不同模块之间的通信和事件处理
-- 采用观察者模式，允许模块注册事件监听器和触发事件

EventBus = {
    -- 事件注册表，存储所有已注册的事件
    events = {},
    
    -- 监听器注册表，存储每个事件的所有监听器
    listeners = {},

    -- 监听器 id 全局单调递增（与 #listeners 脱钩，避免 RemoveListener 后再注册产生重复 id）
    nextListenerId = 0,
    
    -- 初始化事件总线
    Initialize = function(self)
        LogDebug("EventBus initialized")
        self.events = {}
        self.listeners = {}
        self.nextListenerId = 0
    end,
    
    -- 注册一个新事件
    RegisterEvent = function(self, eventName)
        if not self.events[eventName] then
            self.events[eventName] = true
            self.listeners[eventName] = {}
            LogDebug("Event registered: " .. eventName)
        end
    end,
    
    -- 注册事件监听器
    RegisterListener = function(self, eventName, callback, priority)
        -- 如果事件不存在，先注册事件
        if not self.events[eventName] then
            self:RegisterEvent(eventName)
        end
        
        -- 默认优先级为0
        priority = priority or 0

        self.nextListenerId = self.nextListenerId + 1
        local listenerId = self.nextListenerId
        
        -- 创建监听器对象
        local listener = {
            callback = callback,
            priority = priority,
            id = listenerId
        }
        
        -- 添加到监听器列表
        table.insert(self.listeners[eventName], listener)
        
        -- 按优先级排序（优先级越高，执行顺序越靠前）
        table.sort(self.listeners[eventName], function(a, b)
            return a.priority > b.priority
        end)
        
        LogDebug("Listener registered for event: " .. eventName .. " (Priority: " .. priority .. ")")
        return listener.id
    end,
    
    -- 移除事件监听器
    RemoveListener = function(self, eventName, listenerId)
        if not self.listeners[eventName] then
            LogWarning("Attempting to remove listener from non-existent event: " .. eventName)
            return false
        end
        
        for i, listener in ipairs(self.listeners[eventName]) do
            if listener.id == listenerId then
                table.remove(self.listeners[eventName], i)
                LogDebug("Listener removed from event: " .. eventName)
                return true
            end
        end
        
        LogWarning("Listener not found for event: " .. eventName)
        return false
    end,
    
    -- 触发事件
    FireEvent = function(self, eventName, ...)
        if not self.events[eventName] then
            LogWarning("Attempting to fire non-existent event: " .. eventName)
            return false
        end
        
        LogDebug("Event fired: " .. eventName)
        
        -- 调用所有监听器
        -- 注意：必须先捕获 vararg 到局部变量，闭包内不能直接使用 ...
        local args = table.pack(...)
        if self.listeners[eventName] then
            for _, listener in ipairs(self.listeners[eventName]) do
                SafeCall(function()
                    listener.callback(table.unpack(args))
                end)
            end
        end
        
        return true
    end,
    
    -- 获取事件的监听器数量
    GetListenerCount = function(self, eventName)
        if not self.listeners[eventName] then
            return 0
        end
        return #self.listeners[eventName]
    end,
    
    -- 获取所有已注册的事件
    GetRegisteredEvents = function(self)
        local events = {}
        for eventName, _ in pairs(self.events) do
            table.insert(events, eventName)
        end
        return events
    end,
    
    -- 清除所有事件和监听器
    Clear = function(self)
        self.events = {}
        self.listeners = {}
        self.nextListenerId = 0
        LogDebug("EventBus cleared")
    end
}

-- 初始化事件总线
EventBus:Initialize()

-- 注册核心游戏事件
function RegisterGameEvents()
    -- 游戏开始事件
    Events.GameStart.Add(function()
        EventBus:FireEvent(EVENTS.ON_GAME_START)
    end)
    
    -- 玩家回合开始事件
    Events.PlayerTurnBegin.Add(function(playerID)
        EventBus:FireEvent(EVENTS.ON_PLAYER_TURN_BEGIN, playerID)
    end)
    
    -- 玩家回合结束事件
    Events.PlayerTurnEnd.Add(function(playerID)
        EventBus:FireEvent(EVENTS.ON_PLAYER_TURN_END, playerID)
    end)
    
    -- 单位创建事件
    Events.UnitAddedToMap.Add(function(playerID, unitID)
        local unit = UnitManager.GetUnit(playerID, unitID)
        if unit then
            local unitInfo = GameInfo.Units[unit:GetUnitType()]
            local unitType = (unitInfo and unitInfo.Hash) or unit:GetUnitType()
            local plotX, plotY = unit:GetX(), unit:GetY()
            EventBus:FireEvent(EVENTS.ON_UNIT_CREATED, playerID, unit, unitType, plotX, plotY)
        end
    end)
    
    -- 单位死亡事件
    -- 单位死亡事件
    Events.UnitKilledInCombat.Add(function(unitsKilled)
        if unitsKilled and unitsKilled[1] then
            local unit = unitsKilled[1]
            local playerID = unit:GetOwner()
            EventBus:FireEvent(EVENTS.ON_UNIT_KILLED, playerID, unit, unitsKilled)
        end
    end)
    
    -- 城市征服事件（Events.CityConquered 可能不存在，用 Events.CityRemovedFromMap 兜底）
    if Events.CityConquered then
        Events.CityConquered.Add(function(ownerID, cityID, conquerorID)
            local city = CityManager.GetCity(ownerID, cityID)
            if city then
                EventBus:FireEvent(EVENTS.ON_CITY_CONQUERED, ownerID, city, conquerorID)
            end
        end)
    else
        Events.CityRemovedFromMap.Add(function(playerID, cityID)
            -- CityRemovedFromMap: playerID = original owner, cityID = city index
            -- 需要通过城市名和地图判断是否被其他玩家征服（粗筛，避免漏掉）
            local city = CityManager.GetCity(playerID, cityID)
            if city and city:IsCapital() == false then
                -- 简化：仅通知，不传递 conquerorID（由 Main.lua 通过 CityConquered 事件自行判断归属）
                EventBus:FireEvent(EVENTS.ON_CITY_CONQUERED, playerID, city, -1)
            end
        end)
    end
    
    -- 伟人招募事件（多重兜底确保所有版本都能触发）
    if Events.GreatPersonEarned then
        Events.GreatPersonEarned.Add(function(playerID, greatPersonIndex, greatPersonClass)
            EventBus:FireEvent(EVENTS.ON_GREAT_PERSON_RECRUITED, playerID, greatPersonIndex, greatPersonClass)
        end)
    elseif Events.GreatPersonRecruited then
        Events.GreatPersonRecruited.Add(function(playerID, greatPersonID, greatPersonType)
            EventBus:FireEvent(EVENTS.ON_GREAT_PERSON_RECRUITED, playerID, greatPersonID, greatPersonType)
        end)
    elseif Events.GreatPersonActivated then
        Events.GreatPersonActivated.Add(function(playerID, unitID, greatPersonIndividualID, greatPersonClassID)
            EventBus:FireEvent(EVENTS.ON_GREAT_PERSON_RECRUITED, playerID, unitID, greatPersonIndividualID)
        end)
    elseif Events.UnitGreatPersonCreated then
        Events.UnitGreatPersonCreated.Add(function(playerID, unitID, greatPersonType)
            EventBus:FireEvent(EVENTS.ON_GREAT_PERSON_RECRUITED, playerID, unitID, greatPersonType)
        end)
    else
        LogWarning("Great Person events not found — TalentReserve will not receive GP recruitment events")
    end
    
    -- 时代变更事件
    Events.PlayerEraChanged.Add(function(playerID, newEra, oldEra)
        EventBus:FireEvent(EVENTS.ON_ERA_CHANGED, playerID, newEra, oldEra)
    end)

    -- 建筑建成（用于玄武门等）
    if Events.BuildingConstructed then
        Events.BuildingConstructed.Add(function(playerID, cityID, buildingID, plotID, isOriginalConstruction)
            local city = CityManager.GetCity(playerID, cityID)
            EventBus:FireEvent(
                EVENTS.ON_BUILDING_CONSTRUCTED,
                playerID,
                city,
                buildingID,
                plotID,
                isOriginalConstruction
            )
        end)
    end
    
    LogDebug("Game events registered")
end

-- 注册模组自定义事件
function RegisterCustomEvents()
    -- 与 RegisterGameEvents 中 Fire 对齐；当前可无监听器，但必须注册以免误判为「未注册事件」
    EventBus:RegisterEvent(EVENTS.ON_UNIT_CREATED)
    EventBus:RegisterEvent(EVENTS.ON_GREAT_PERSON_RECRUITED)

    -- 玄武门建造事件
    EventBus:RegisterEvent(EVENTS.ON_XUANWU_GATE_BUILT)
    
    -- 预留：射杀李建成（尚无 FireEvent 调用点；后续任务/战斗逻辑可在此事件上监听）
    EventBus:RegisterEvent(EVENTS.ON_SHOOT_LI_JIANCHENG)
    
    -- 登基完成事件
    EventBus:RegisterEvent(EVENTS.ON_CORONATION_COMPLETED)
    
    -- 藩王线激活事件
    EventBus:RegisterEvent(EVENTS.ON_PRINCE_LINE_ACTIVATED)
    
    -- 复辟完成事件
    EventBus:RegisterEvent(EVENTS.ON_RESTORATION_COMPLETED)
    
    -- 复辟失败事件
    EventBus:RegisterEvent(EVENTS.ON_RESTORATION_FAILED)

    EventBus:RegisterEvent(EVENTS.ON_BUILDING_CONSTRUCTED)
    
    LogDebug("Custom events registered")
end

return EventBus
