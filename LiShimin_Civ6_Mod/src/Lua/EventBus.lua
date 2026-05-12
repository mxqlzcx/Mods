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
        if self.listeners[eventName] then
            for _, listener in ipairs(self.listeners[eventName]) do
                SafeCall(function()
                    listener.callback(...)
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
    Events.UnitCreated.Add(function(playerID, unitID, unitType, plotX, plotY)
        local unit = UnitManager.GetUnit(playerID, unitID)
        if unit then
            EventBus:FireEvent(EVENTS.ON_UNIT_CREATED, playerID, unit, unitType, plotX, plotY)
        end
    end)
    
    -- 单位死亡事件
    Events.UnitKilledInCombat.Add(function(unitsKilled)
        if unitsKilled and unitsKilled[1] then
            local unit = unitsKilled[1]
            local playerID = unit:GetOwner()
            EventBus:FireEvent(EVENTS.ON_UNIT_KILLED, playerID, unit, unitsKilled)
        end
    end)
    
    -- 城市征服事件
    Events.CityConquered.Add(function(ownerID, cityID, conquerorID)
        local city = CityManager.GetCity(ownerID, cityID)
        if city then
            EventBus:FireEvent(EVENTS.ON_CITY_CONQUERED, ownerID, city, conquerorID)
        end
    end)
    
    -- 伟人招募事件
    Events.GreatPersonRecruited.Add(function(playerID, greatPersonID, greatPersonType)
        EventBus:FireEvent(EVENTS.ON_GREAT_PERSON_RECRUITED, playerID, greatPersonID, greatPersonType)
    end)
    
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
