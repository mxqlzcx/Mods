-- InGame UI 上下文：供 UI.PlaySound / ContextPtr 使用（GameplayScripts 中无 UI 全局表）
-- 由 Gameplay 通过 LuaEvents.LiShiminMod_PlayPresentation(kind) 触发

-- ===== 玄武门之变剧情图片配置 =====
-- 图片文件丢入 src/UI/ 目录，修改 CORONATION_KILL_IMAGE 变量即可替换
-- 要求：DDS 格式，512x512 或 1024x1024，带 Alpha 通道
local CORONATION_KILL_IMAGE = "Coronation_Kill.dds"  -- ← 替换为你的图片文件名

local function playMomentSound(momentKind)
	if not UI or not UI.PlaySound then
		return
	end
	-- 使用原版 Wwise 事件名；若某版本无声，可在本文件内替换为其它已知事件名
	if momentKind == "xuanwu_gate" then
		UI.PlaySound("Research_Complete_Culture")
	elseif momentKind == "coronation_complete" then
		UI.PlaySound("Research_Complete")
	elseif momentKind == "coronation_kill" then
		-- 李建成被俘获瞬间：更戏剧化的音效
		UI.PlaySound("Notification_Declare_War")
		-- TODO: 如有自定义音效，替换为 UI.PlaySound("LiShimin_XuanwuGate_Kill")
	end
end

-- ===== 玄武门之变全屏图片演出 =====
-- 当 coronation_kill 触发时，在屏幕中央弹出剧情图片
-- 图片由 CORONATION_KILL_IMAGE 变量控制
local CORONATION_DISPLAY_MS = 4000   -- 图片显示时长（毫秒）
local CORONATION_FADE_MS    = 800    -- 淡出动画时长（毫秒）

local function showCoronationKillImage(momentKind)
	if momentKind ~= "coronation_kill" then return end

	local container = Controls.CoronationKillContainer
	if not container then
		print("[LiShimin] Warning: CoronationKillContainer not found in XML")
		return
	end

	-- 设置图片纹理（如果文件名被更改）
	local img = Controls.CoronationKillImage
	if img and CORONATION_KILL_IMAGE ~= "Coronation_Kill.dds" then
		img:SetTexture(CORONATION_KILL_IMAGE)
	end

	-- 显示容器
	container:SetHide(false)
	container:SetToBeginning()
	container:Play()

	print("[LiShimin] Coronation kill image shown: " .. CORONATION_KILL_IMAGE)

	-- 延迟淡出
	local context = ContextPtr
	if context then
		context:SetTimer(function()
			-- 淡出后隐藏
			container:Play("FadeOut")
			context:SetTimer(function()
				container:SetHide(true)
				-- 重置透明度以便下次显示
				container:SetToBeginning()
				print("[LiShimin] Coronation kill image hidden")
			end, CORONATION_FADE_MS)
		end, CORONATION_DISPLAY_MS)
	end
end

LuaEvents.LiShiminMod_PlayPresentation.Add(playMomentSound)
LuaEvents.LiShiminMod_PlayPresentation.Add(showCoronationKillImage)
