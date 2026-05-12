-- ============================================================
-- 模组版本信息
-- 同步更新自 简介.txt（定版）
-- ============================================================

MOD_VERSION       = "2.0.0"
MOD_VERSION_NAME  = "正式版"
MOD_BALANCE_VERSION = "v2.0"   -- 同步自 简介.txt 定版数值
MOD_RELEASE_DATE  = "XX-XX"     -- TODO: 正式发布时填入日期

-- 平衡版本切换（仅影响 config/balance.lua 的 GetBalanceData() 返回值）
-- "v1.0" → 使用旧版平衡数据
-- "v2.0" → 使用简介.txt定版平衡数据（当前默认）
BALANCE_VERSION = "v2.0"

-- 模组版本标识（用于日志和调试）
MOD_VERSION_FULL = MOD_VERSION .. " (" .. MOD_BALANCE_VERSION .. ")"

return {
    MOD_VERSION         = MOD_VERSION,
    MOD_VERSION_NAME    = MOD_VERSION_NAME,
    MOD_BALANCE_VERSION = MOD_BALANCE_VERSION,
    MOD_RELEASE_DATE    = MOD_RELEASE_DATE,
    MOD_VERSION_FULL    = MOD_VERSION_FULL,
    BALANCE_VERSION     = BALANCE_VERSION,
}
