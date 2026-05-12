-- 天策上将死亡处理模块
-- 负责处理天策上将死亡时的游戏逻辑和失败判定

-- 处理天策上将死亡
function HandleTianceGeneralDeath(playerID)
    LogDebug("Handling Tiance General death for player " .. playerID)
    
    -- 获取玩家数据
    local playerData = LiShiminMod.Players[playerID]
    if not playerData then
        LogError("Player data not found for player " .. playerID)
        return
    end
    
    -- 检查当前状态
    -- 只有在天策上将形态或登基仪式中死亡才会导致游戏失败
    if playerData.LeaderState == LEADER_STATE.TIANCE_GENERAL or 
       playerData.LeaderState == LEADER_STATE.CORONATION then
        
        LogDebug("Tiance General death causes game over for player " .. playerID)
        
        -- 显示失败通知
        ShowNotification(
            playerID,
            "LOC_LISHIMIN_NOTIFY_TITLE",
            ERROR_MESSAGES.LEADER_DEATH,
            nil,
            COLORS.DANGER
        )
        
        -- 立即执行游戏结束逻辑
        LuaEvents.LiShiminMod_EndGame(playerID)
    else
        LogDebug("Tiance General death does not cause game over in current state: " .. playerData.LeaderState)
    end
end

-- 游戏结束逻辑
function EndGameForPlayer(playerID)
    LogDebug("Ending game for player " .. playerID)
    
    local player = Players[playerID]
    if not player then
        LogError("Player not found: " .. playerID)
        return
    end
    
    -- 这里可以添加游戏结束的具体逻辑
    -- 在文明6中，通常通过设置玩家失败来结束游戏
    
    -- 示例：设置玩家失败
    player:SetHasLost(true)
    
    -- 显示失败画面或消息
    -- 注意：具体的实现方式可能需要根据文明6的API进行调整
end

-- 注册游戏结束事件
function RegisterEndGameEvent()
    LuaEvents.LiShiminMod_EndGame.Add(function(playerID)
        EndGameForPlayer(playerID)
    end)
end

-- 初始化模块
function InitializeHeroDeathModule()
    LogDebug("Initializing HeroDeath module")
    RegisterEndGameEvent()
end

-- 自动初始化
InitializeHeroDeathModule()

return {
    HandleTianceGeneralDeath = HandleTianceGeneralDeath,
    EndGameForPlayer = EndGameForPlayer,
    InitializeHeroDeathModule = InitializeHeroDeathModule
}
