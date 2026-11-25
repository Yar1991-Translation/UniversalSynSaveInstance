-- 完整保存示例（Universal Syn SaveInstance - Yar1991-Translation Fork）
-- 功能：完整保存 + 反编译 + 字节码 + 安全模式 + Nil 实例 + 自定义导出目录 + 进度条 + 仅供测试提示

local Params = {
	RepoURL = "https://raw.githubusercontent.com/Yar1991-Translation/UniversalSynSaveInstance/main/",
	SSI = "saveinstance",
}

-- 加载 Universal Syn SaveInstance 库
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()

-- 设置完整保存的自定义选项
local CustomOptions = {
	mode = "full", -- 保存所有游戏 Instance（非仅脚本或部分优化）
	Decompile = true, -- 开启脚本反编译
	DecompileTimeout = 15, -- 单个脚本反编译超时时间（秒）
	SaveBytecode = true, -- 保存字节码以供日后重新反编译
	SafeMode = true, -- 推荐开启：保存前自动踢出玩家，防止游戏防作弊检测
	NilInstances = true, -- 保存未挂载到游戏树（Parent 为 nil）的实例

	-- 自定义导出目录
	-- 你的执行器不支持绝对路径，所以使用执行器工作目录下的相对目录 "export"
	-- 保存完成后控制台会打印实际文件的绝对路径
	ExportFolder = "export",

	-- 导出前“仅供测试，24 小时内删除”提示
	TestOnlyNotice = true,
	TestOnlyNoticeTimeout = 15, -- 15 秒后自动继续；设为 0 则必须手动点击确认

	-- 显示导出进度条
	ShowStatus = true,
}

-- 执行保存
local savedPath = synsaveinstance(CustomOptions)

-- 如果当前加载的库版本没有在控制台打印绝对路径，这里补充打印
if savedPath then
	local USSI = (getgenv and getgenv().USSI) or _G.USSI
	if not (USSI and USSI.LastOutputPathPrinted) then
		local function isAbsolute(path)
			return path:sub(1, 1) == "/"
				or path:match("^%a:[/\\]") ~= nil
				or path:sub(1, 2) == "\\\\"
		end

		local function getWorkspacePath()
			local env = (getgenv and getgenv()) or _G
			local candidates = {
				rawget(env, "getworkspace"),
				rawget(env, "getexecutionfolder"),
				rawget(env, "getworkspacepath"),
				rawget(_G, "getworkspace"),
				rawget(_G, "getexecutionfolder"),
				rawget(_G, "getworkspacepath"),
			}

			for _, fn in candidates do
				if type(fn) == "function" then
					local ok, path = pcall(fn)
					if ok and type(path) == "string" and path ~= "" then
						return path
					end
				end
			end
		end

		local absolutePath = savedPath
		if not isAbsolute(absolutePath) then
			local workspace = getWorkspacePath()
			if workspace then
				workspace = workspace:gsub("\\", "/"):gsub("/+$", "")
				if workspace ~= "" then
					absolutePath = workspace .. "/" .. savedPath
				end
			end
		end

		print("[export_full] 导出文件路径: " .. absolutePath)
		if absolutePath == savedPath and not isAbsolute(savedPath) then
			print("[export_full] 执行器未提供工作目录函数（如 getworkspace），以上为相对路径；文件位于执行器工作目录下。")
		end
	end
end
