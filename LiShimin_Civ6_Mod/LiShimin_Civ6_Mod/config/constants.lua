-- ============================================================
-- 模组常量配置
-- 所有关键数值集中在此处，方便平衡调整
-- 同步更新自 简介.txt（定版）
-- ============================================================

-- ===== 时代名称常量（必须与 XML GameInfo.Eras 中 EraType 一致）=====
ERA_ANCIENT     = "ERA_ANCIENT"
ERA_CLASSICAL   = "ERA_CLASSICAL"
ERA_MEDIEVAL    = "ERA_MEDIEVAL"
ERA_RENAISSANCE = "ERA_RENAISSANCE"
ERA_INDUSTRIAL  = "ERA_INDUSTRIAL"
ERA_MODERN      = "ERA_MODERN"
ERA_ATOMIC      = "ERA_ATOMIC"
ERA_INFORMATION = "ERA_INFORMATION"

-- ===== 领袖名称（必须与 XML / Leader 定义的类型名匹配） =====
LEADER_LI_SHIMIN = "LEADER_LI_SHIMIN"

-- ===== 领袖状态枚举 =====
LEADER_STATE = {
    TIANCE_GENERAL   = 1,   -- 天策上将（远古~古典）
    CORONATION       = 2,   -- 登基仪式（中世纪交界）
    PRINCE_LINE      = 3,   -- 藩王支线（背水一战）
    EMPEROR_TAIZONG  = 4,   -- 唐太宗（中世纪及以后）
}

-- ===== 状态转换常量 =====
CORONATION_MIN_CITIES_CONQUERED = 5   -- 进入中世纪前，需征服至少5城才走登基线

-- ===== 天策上将（英雄远程单位）=----
UNIT_TIANCE_GENERAL = "UNIT_TIANCE_GENERAL"

-- 天策军威光环（简介.txt定版）：周围每存在1个友军，自身防御力+5，无上限
TIANCE_AURA_COMBAT_BONUS  = 5          -- 每格友军+5防御
TIANCE_AURA_RANGE          = 2          -- 光环范围（格）
TIANCE_COMBAT              = 45        -- 近战防御基础值
TIANCE_RANGED_COMBAT       = 55        -- 远程攻击值
TIANCE_RANGE               = 2         -- 射程
TIANCE_MOVES               = 3         -- 移动力
TIANCE_COST                = 130       -- 召唤费用

-- ===== 玄甲军（特色重骑兵）=====
UNIT_XUANJIA_ARMY = "UNIT_XUANJIA_ARMY"
XUANJIA_ARMY_COMBAT   = 55        -- 攻击力（高于骑士）
XUANJIA_ARMY_MOVES     = 4        -- 移动力
XUANJIA_ARMY_COST      = 190      -- 建造费用

-- ===== 玄武门（登基仪式改良设施）=====
IMPROVEMENT_XUANWU_GATE = "IMPROVEMENT_XUANWU_GATE"
CORONATION_MIN_TURNS_AFTER_GATE = 1   -- 建成后等待回合（简介.txt：建成玄武门即触发李建成刷新）

-- ===== 天策府十八学士 =----
UNIT_TALENT_RESERVE_BENEFIT   = true   -- 功能开关
TALENT_RESERVE_PER_GP         = 6      -- 每招募1名伟人，首都全产出+6
TALENT_RESERVE_MAX_STACKS     = 3      -- 最多叠加3层（最高+18）

-- ===== 藩王线（简介.txt定版）=====
PRINCE_LINE_TURNS                 = 30   -- 复辟时限：30回合
PRINCE_EXTRA_CONQUESTS_REQUIRED   = 1    -- 藩王线额外征服要求：补1城（夺回首都时已算1城）
PRINCE_REMINDER_INTERVAL         = 5    -- 每隔多少回合提醒一次

-- 藩王线全局惩罚（简介.txt定版：科技/文化/粮食各-50%）
PRINCE_SCIENCE_PENALTY     = -50   -- 科技惩罚（%）
PRINCE_CULTURE_PENALTY     = -50   -- 文化惩罚（%）
PRINCE_FOOD_PENALTY        = -50   -- 粮食惩罚（%）
-- 藩王线翻盘增益（简介.txt定版：军事单位生产力+150%）
PRINCE_MILITARY_PROD_BONUS = 150  -- 军事单位建造速度加成（%）

-- ===== 唐太宗·贞观之治（简介.txt定版：每城+1%，上限+10%）=====
ZHENGUAN_PER_CITY_PCT = 1     -- 每城全产出加成（%）
ZHENGUAN_MAX_PCT      = 10    -- 全域加成上限（%）
-- 切换为唐太宗后，天策府十八学士效果清零（简介.txt：前期人才积累为登基铺垫）

-- ===== 唐太宗·万国来朝（简介.txt定版：每10回合）=====
ENVOY_INTERVAL = 10   -- 每N回合自动获得1名免费使者

-- ===== 唐太宗·天可汗·节度使 ======
-- 节度使：派驻城邦后，触发双重霸权
JIEDUSHI_ENVOY_MULTIPLIER = 2    -- 节度使城邦：每名使者影响力×2（1名使者=2点影响力）
-- 注：资源复制（上贡）效果通过城市图标/通知提示实现（Lua层暂不支持修改资源流）

-- ===== 唐太宗·天子一怒 =====
TIANZI_YANU_WINDOW = 10           -- 宣战后可免费征用城邦军队的窗口（回合）
-- 节度使使者翻倍效果在"天子一怒"期间暂停（宣战后10回合内节度使使者×2暂时失效）

-- ===== 偃武修文·驻军收益（简介.txt定版）=====
YANWU_CAMP_BONUS_ENABLED = true  -- 功能开关

-- ===== 李建成（玄武门仪式目标单位）=====
UNIT_LI_JIANCHENG = "UNIT_LI_JIANCHENG"
LI_JIANCHENG_HP         = 1      -- 极低生命值（仅天策上将可击杀）
LI_JIANCHENG_MOVES      = 0      -- 无法移动

-- ===== 通知图标常量 =====
LISHIMIN_NOTIFY_ICON_XUANWU_GATE  = "NotificationIconBuilding"
LISHIMIN_NOTIFY_ICON_CORONATION   = "NotificationIconVictory"

-- ===== 颜色常量 =====
COLORS = {
    PRIMARY   = { R = 0.98, G = 0.74, B = 0.19, A = 1.0 },  -- 金色（皇室）
    SECONDARY = { R = 0.20, G = 0.60, B = 0.90, A = 1.0 },  -- 蓝色（外交通知）
    SUCCESS   = { R = 0.27, G = 0.72, B = 0.40, A = 1.0 },  -- 绿色
    WARNING   = { R = 0.98, G = 0.60, B = 0.20, A = 1.0 },  -- 橙色（藩王警告）
    DANGER    = { R = 0.90, G = 0.20, B = 0.20, A = 1.0 },  -- 红色（失败）
}

-- constants.lua: 所有常量已作为全局变量定义，无需 return 表
