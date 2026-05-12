-- InGame UI 上下文：供 UI.PlaySound 使用（GameplayScripts 中无 UI 全局表）
-- 由 Gameplay 通过 LuaEvents.LiShiminMod_PlayPresentation(kind) 触发

local function playMomentSound(momentKind)
	if not UI or not UI.PlaySound then
		return
	end
	-- 使用原版 Wwise 事件名；若某版本无声，可在本文件内替换为其它已知事件名
	if momentKind == "xuanwu_gate" then
		UI.PlaySound("Research_Complete_Culture")
	elseif momentKind == "coronation_complete" then
		UI.PlaySound("Research_Complete")
	end
end

LuaEvents.LiShiminMod_PlayPresentation.Add(playMomentSound)
