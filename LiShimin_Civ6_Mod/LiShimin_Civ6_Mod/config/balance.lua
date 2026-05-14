-- ============================================================
-- 模组平衡数据（版本化管理）
-- 同步更新自 简介.txt（定版）
-- ============================================================

-- 当前使用的版本标识（切换值以使用不同平衡集）
-- 可在 version.lua 中通过 BALANCE_VERSION 控制
BALANCE_VERSION = "v2.0"

-- ============================================================
-- v1.0 平衡数据（早期版本参考）
-- ============================================================
BalanceData_v100 = {
    Name = "v1.0",
    TianceGeneral = {
        RangedCombat    = 55,
        Combat         = 45,
        Range           = 2,
        Moves           = 3,
        Cost            = 130,
    },
    XuanjiaArmy = {
        Combat          = 55,
        Moves           = 4,
        Cost            = 190,
    },
    TalentReserve = {
        PerGreatPerson  = 6,   -- 每伟人首都+6全产出
        MaxStacks       = 3,   -- 最多3层
    },
    ZhenguanReign = {
        PerCityBonus    = 1,   -- 每城+1%
        MaxBonus        = 10,  -- 上限+10%
    },
    PrinceLine = {
        RestorationTimeLimit    = 30,  -- 复辟时限30回合
        ProductionBonus          = 150, -- 军工+150%
        SciencePenalty           = -50,
        CulturePenalty          = -50,
    },
    WorldReception = {
        EnvoyInterval   = 6,   -- 每6回合
    },
    TianceAura = {
        CombatBonusPerUnit = 5,  -- 每友军+5防御
        Range            = 2,
    },
}

-- ============================================================
-- v2.0 平衡数据（当前定版，同步自 简介.txt）
-- ============================================================
BalanceData_v200 = {
    Name = "v2.0",
    TianceGeneral = {
        RangedCombat    = 55,
        Combat         = 45,
        Range           = 2,
        Moves           = 3,
        Cost            = 130,
        AuraBonus       = 5,    -- 每友军+5防御（无上限）
        AuraRange       = 2,
        Health          = 220,  -- 英雄单位生命值
    },
    XuanjiaArmy = {
        Combat          = 55,
        Moves           = 4,
        Cost            = 190,
    },
    TalentReserve = {
        PerGreatPerson  = 6,    -- 每伟人首都全产出+6
        MaxStacks       = 3,    -- 最多3层（最高+18）
    },
    ZhenguanReign = {
        -- 简介.txt定版：每城+1%，上限+10%
        PerCityBonus    = 1,
        MaxBonus        = 10,
    },
    PrinceLine = {
        RestorationTimeLimit    = 30,   -- 复辟时限30回合（简介.txt定版）
        ProductionBonus          = 150,  -- 军工建造速度+150%（简介.txt定版）
        SciencePenalty           = -50,  -- 科技-50%（简介.txt定版）
        CulturePenalty           = -50,  -- 文化-50%（简介.txt定版）
        FoodPenalty              = -50,  -- 粮食-50（简介.txt定版）
        ExtraConquestsRequired   = 1,    -- 藩王线额外需补1城（夺回首都时已算1城）
    },
    WorldReception = {
        -- 简介.txt定版：每10回合
        EnvoyInterval   = 10,
    },
    TianKeHan = {
        -- 天可汗·节度使：驻城邦后效果
        EnvoyMultiplier = 2,    -- 节度使城邦：使者影响力翻倍（1使=2影响力）
        ResourceCopy    = true, -- 资源上贡（通知提醒）
        -- 天子一怒：宣战后效果
        WarBonusWindow  = 10,   -- 宣战后10回合内可免费征用城邦军队
        WarEnvoySuspension = true, -- 天子一怒期间节度使使者翻倍暂停
    },
    YanWuXiuWen = {
        -- 偃武修文：驻军于特色区域赚取和平收益
        CampusBonus     = true, -- 驻学院：战斗力10%的科技值
        TheaterBonus    = true, -- 驻剧院广场：+2大作家/大音乐家点数；3级兵额外+4旅游业绩
        CommercialBonus = true, -- 驻商业中心：维护费2倍金币+1贸易路线容量
        PeaceMultiplier = 2,    -- 绝对和平时驻军收益翻倍
    },
    LiJiancheng = {
        HP      = 1,            -- 李建成1点生命
        Moves   = 0,            -- 无法移动
        -- 设定：仅天策上将可造成伤害（通过战斗修正实现）
    },
    TianceAura = {
        CombatBonusPerUnit = 5,  -- 每友军+5防御（无上限）
        Range              = 2, -- 光环范围2格
    },
}

-- ============================================================
-- 平衡数据获取接口
-- ============================================================
function GetBalanceData()
    if BALANCE_VERSION == "v1.0" then
        return BalanceData_v100
    elseif BALANCE_VERSION == "v2.0" then
        return BalanceData_v200
    else
        -- 默认返回v2.0（当前定版）
        return BalanceData_v200
    end
end

-- 便捷访问：返回当前激活的平衡数据集
function GetActiveBalance()
    return GetBalanceData()
end

-- balance.lua: 所有数据已作为全局变量/函数定义，无需 return 表
