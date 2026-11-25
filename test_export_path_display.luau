--!nocheck
-- 测试：导出完成后，saveinstance 是否在控制台显示文件的绝对路径
-- 运行方法：在 Roblox 执行器中执行本脚本，等待测试完成，然后看控制台输出。
-- 本测试只保存一个临时 Folder + Part，完成后会尝试删除导出文件。

local REPO_URL = "https://raw.githubusercontent.com/Yar1991-Translation/UniversalSynSaveInstance/main/"
local TEST_FOLDER = "export_path_test"
-- 可选：执行器没有 getworkspace() 时手动填写其工作目录
-- Solara 当前工作区: D:/solara/workspace
local MANUAL_WORKSPACE = "D:/solara/workspace"

local ENV = (getgenv and getgenv()) or _G

local function getFunction(name)
	local fn = rawget(ENV, name)
	if type(fn) ~= "function" then
		fn = rawget(_G, name)
	end
	return type(fn) == "function" and fn or nil
end

local writefile = getFunction("writefile")
local isfile = getFunction("isfile")
local delfile = getFunction("delfile") or getFunction("deletefile") or getFunction("removefile")
local getworkspace = getFunction("getworkspace")
	or getFunction("getexecutionfolder")
	or getFunction("getworkspacepath")
	or getFunction("getexecutorpath")

local function isAbsolute(path)
	return path:sub(1, 1) == "/"
		or path:match("^%a:[/\\]") ~= nil
		or path:sub(1, 2) == "\\\\"
end

local function getWorkspacePath()
	if MANUAL_WORKSPACE and MANUAL_WORKSPACE ~= "" then
		return MANUAL_WORKSPACE
	end
	if not getworkspace then
		return nil
	end

	local ok, path = pcall(getworkspace)
	if ok and type(path) == "string" and path ~= "" then
		return path
	end
end

local function resolveAbsolute(path)
	if not path or path == "" then
		return nil
	end
	if isAbsolute(path) then
		return path
	end

	local workspace = getWorkspacePath()
	if workspace then
		workspace = workspace:gsub("\\", "/"):gsub("/+$", "")
		if workspace ~= "" then
			return workspace .. "/" .. path
		end
	end

	return path
end

print("==============================================")
print("[TEST] 导出路径显示测试")
print("[TEST] 工作目录函数:", getworkspace and "可用" or "不可用")
print("[TEST] 手动工作目录:", MANUAL_WORKSPACE ~= "" and MANUAL_WORKSPACE or "未设置")

if not writefile then
	warn("[TEST FAIL] 当前执行器没有 writefile，无法导出。")
	return
end

local loadOk, synsaveinstance = pcall(function()
	local source = game:HttpGet(REPO_URL .. "saveinstance.luau", true)
	return loadstring(source, "saveinstance")()
end)

if not loadOk or type(synsaveinstance) ~= "function" then
	warn("[TEST FAIL] 加载 saveinstance 失败: " .. tostring(synsaveinstance))
	return
end

local USSI = ENV.USSI
if USSI then
	USSI.LastOutputPath = nil
	USSI.LastOutputPathPrinted = nil
end

local folder = Instance.new("Folder")
folder.Name = "USSI_PathTest_" .. tostring(math.random(100000, 999999))

local part = Instance.new("Part")
part.Name = "TestPart"
part.Parent = folder

local options = {
	mode = "invalid", -- 只保存 ExtraInstances
	ExtraInstances = { folder },
	IsModel = true,
	ExportFolder = TEST_FOLDER,
	WorkspacePath = MANUAL_WORKSPACE ~= "" and MANUAL_WORKSPACE or nil,
	Decompile = false,
	SaveBytecode = false,
	ReadMe = false,
	ShowStatus = false,
	TestOnlyNotice = false,
	SafeMode = false,
	KillAllScripts = false,
	BoostFPS = false,
	AntiIdle = false,
	NilInstances = false,
	AlternativeWritefile = true,
}

print("[TEST] 开始导出临时模型...")
local ok, result = pcall(synsaveinstance, options)

folder:Destroy()

if not ok then
	warn("[TEST FAIL] 导出失败: " .. tostring(result))
	return
end

print("[TEST] synsaveinstance 返回:", tostring(result))

local libPath = USSI and USSI.LastOutputPath
local libPrinted = USSI and USSI.LastOutputPathPrinted
local fallbackPath = resolveAbsolute(type(result) == "string" and result or nil)

if libPrinted and libPath then
	print("[TEST PASS] 库已记录并打印导出路径: " .. tostring(libPath))
	if isAbsolute(libPath) then
		print("[TEST PASS] 该路径是绝对路径。")
	else
		print("[TEST WARN] 库打印的是相对路径：执行器没有提供可用的工作目录函数，无法得到绝对路径。")
	end
else
	print("[TEST FAIL] 库没有记录导出路径。请确认 GitHub main 已更新到包含该功能的版本。")
end

if fallbackPath then
	print("[TEST] 测试脚本计算的路径:", fallbackPath)
	if isAbsolute(fallbackPath) then
		print("[TEST PASS] 测试脚本可以计算出绝对路径。")
	else
		print("[TEST WARN] 测试脚本也只能得到相对路径；请检查执行器的 getworkspace() 是否可用。")
	end
end

if isfile and type(result) == "string" then
	local okFile, exists = pcall(isfile, result)
	print("[TEST] 导出文件存在:", okFile and tostring(exists) or tostring(exists))
end

if delfile and type(result) == "string" then
	local okDel, err = pcall(delfile, result)
	print("[TEST] 删除临时导出文件:", okDel and "成功" or ("失败: " .. tostring(err)))
elseif type(result) == "string" then
	warn("[TEST] 没有 delfile，请手动删除临时导出文件: " .. tostring(fallbackPath or result))
end

print("==============================================")
print("[TEST] 如果上面的路径是绝对路径，说明导出完成后控制台显示绝对路径功能正常。")
print("==============================================")
