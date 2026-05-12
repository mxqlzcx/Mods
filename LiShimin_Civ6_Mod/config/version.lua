-- 版本控制文件
-- 用于追踪模组的平衡版本，便于后续更新和维护

-- 当前平衡版本（用于 GetBalanceData() 选择数值）
BALANCE_VERSION = "2.0"

-- 模组版本号
MOD_VERSION = "2.0.0"

-- 模组元数据
MOD_NAME = "天策上将·唐太宗（李世民）"
MOD_AUTHOR = "模组开发者"
MOD_DESCRIPTION = "双形态领袖李世民，体验从马上打天下到下马治天下的完整历程。"
MOD_TEASER = "千古一帝李世民，双形态领袖模组，体验大唐盛世的崛起！"

-- 兼容版本
COMPATIBLE_VERSIONS = "2.0"

-- 模组配置
MOD_CONFIG = {
    AffectsSavedGames = true,
    SupportsSinglePlayer = true,
    SupportsMultiplayer = false,
    ReloadUnitSystem = true,
    ReloadAudioSystem = false,
    ReloadLandmarkSystem = false,
    ReloadStrategicViewSystem = false
}

return {
    BALANCE_VERSION = BALANCE_VERSION,
    MOD_VERSION = MOD_VERSION,
    MOD_NAME = MOD_NAME,
    MOD_AUTHOR = MOD_AUTHOR,
    MOD_DESCRIPTION = MOD_DESCRIPTION,
    MOD_TEASER = MOD_TEASER,
    COMPATIBLE_VERSIONS = COMPATIBLE_VERSIONS,
    MOD_CONFIG = MOD_CONFIG
}
