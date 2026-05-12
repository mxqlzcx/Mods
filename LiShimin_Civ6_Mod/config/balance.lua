-- 平衡配置文件
-- 包含所有版本的游戏平衡数据，按版本号组织

local Balance = {
    ["1.0"] = {
        -- 天策上将属性
        TianceGeneral = {
            Attack = 40,
            Range = 2,
            Health = 200,
            Movement = 3,
            Cost = 120,
            -- 秦王弓特性
            BowAttackBonus = 25,
            -- 护卫机制
            GuardRange = 2,
        },
        -- 玄甲军属性
        XuanJiaArmy = {
            Attack = 35,
            Defense = 25,
            Health = 150,
            Movement = 4,
            Cost = 180,
            -- 特殊能力
            ChargeBonus = 50,
        },
        -- 天策府十八学士效果
        TalentReserve = {
            PerGreatPersonBonus = 6,
            MaxStacks = 3,
            MaxTotalBonus = 18,
        },
        -- 唐太宗贞观之治效果
        ZhenguanReign = {
            PerCityBonus = 3,
            MaxBonus = 24,
        },
        -- 外交效果
        WorldReception = {
            EnvoyGainInterval = 6, -- 每6回合获得使者
            WarDeclarationPenalty = -5, -- 主动宣战扣除外交好感
            DefensiveWarBonus = 10, -- 被宣战增加外交好感
        },
        -- 藩王线效果
        PrinceLine = {
            ProductionPenalty = -50, -- 科技、文化、粮食产出惩罚
            MilitaryProductionBonus = 150, -- 军事单位生产力加成
            RestorationTimeLimit = 30, -- 复辟任务时限
        }
    },
    ["2.0"] = {
        -- 天策上将属性（增强）
        TianceGeneral = {
            Attack = 45,
            Range = 2,
            Health = 220,
            Movement = 3,
            Cost = 130,
            -- 秦王弓特性
            BowAttackBonus = 30,
            -- 护卫机制
            GuardRange = 2,
        },
        -- 玄甲军属性（增强）
        XuanJiaArmy = {
            Attack = 38,
            Defense = 28,
            Health = 160,
            Movement = 4,
            Cost = 190,
            -- 特殊能力
            ChargeBonus = 55,
        },
        -- 天策府十八学士效果（增强）
        TalentReserve = {
            PerGreatPersonBonus = 7,
            MaxStacks = 3,
            MaxTotalBonus = 21,
        },
        -- 唐太宗贞观之治效果（调整）
        ZhenguanReign = {
            PerCityBonus = 3.5,
            MaxBonus = 28,
        },
        -- 外交效果（调整）
        WorldReception = {
            EnvoyGainInterval = 5, -- 每5回合获得使者
            WarDeclarationPenalty = -4, -- 主动宣战扣除外交好感
            DefensiveWarBonus = 12, -- 被宣战增加外交好感
        },
        -- 藩王线效果（平衡）
        PrinceLine = {
            ProductionPenalty = -45, -- 科技、文化、粮食产出惩罚（减轻）
            MilitaryProductionBonus = 160, -- 军事单位生产力加成（增强）
            RestorationTimeLimit = 35, -- 复辟任务时限（延长）
        }
    }
}

-- 获取当前版本的平衡数据
function GetBalanceData()
    return Balance[BALANCE_VERSION] or Balance["2.0"]
end

-- 获取指定版本的平衡数据
function GetBalanceDataByVersion(version)
    return Balance[version] or Balance["2.0"]
end

-- 导出平衡数据供其他模块使用
BalanceData = GetBalanceData()

return Balance
