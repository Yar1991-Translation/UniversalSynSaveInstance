--!nocheck
-- 测试执行器工作区是否能正常写入
-- 会在工作区根目录创建 workspace_write_test.txt，测试后不会删除
-- 运行后请到 D:\solara\workspace 查看该文件

local FILE_NAME = "workspace_write_test.txt"
local KNOWN_WORKSPACE = "D:/solara/workspace"

local function nowString()
	local ok, value = pcall(function()
		return os.date("%Y-%m-%d %H:%M:%S")
	end)
	return ok and tostring(value) or tostring(os.time())
end

local CONTENT = table.concat({
	"USSI workspace write test",
	"time: " .. nowString(),
	"如果你能在资源管理器中看到这个文件，说明工作区可以正常写入。",
}, "\n")

local ENV = (getgenv and getgenv()) or _G

local function getFunction(name)
	local fn = rawget(ENV, name)
	if type(fn) ~= "function" then
		fn = rawget(_G, name)
	end
	return type(fn) == "function" and fn or nil
end

local writefile = getFunction("writefile")
local readfile = getFunction("readfile")
local isfile = getFunction("isfile")
local appendfile = getFunction("appendfile")
local listfiles = getFunction("listfiles")
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
	if getworkspace then
		local ok, path = pcall(getworkspace)
		if ok and type(path) == "string" and path ~= "" then
			return path, "getworkspace()"
		end
	end
	return KNOWN_WORKSPACE, "已知 Solara 数据目录"
end

local function report(ok, label, detail)
	local line = string.format("[WORKTEST] %s %s%s", ok and "OK  " or "FAIL", label, detail ~= nil and (" | " .. tostring(detail)) or "")
	print(line)
	if not ok then
		warn(line)
	end
end

print("==============================================")
print("[WORKTEST] 工作区写入测试")
print("[WORKTEST] 目标文件:", FILE_NAME)
print("[WORKTEST] writefile:", writefile and "可用" or "不可用")
print("[WORKTEST] readfile:", readfile and "可用" or "不可用")
print("[WORKTEST] isfile:", isfile and "可用" or "不可用")
print("[WORKTEST] appendfile:", appendfile and "可用" or "不可用")
print("[WORKTEST] listfiles:", listfiles and "可用" or "不可用")

if not writefile then
	warn("[WORKTEST] 当前执行器没有 writefile，无法测试工作区。")
	return
end

-- 1. 直接在工作区根目录写入 txt
local okWrite, writeErr = pcall(writefile, FILE_NAME, CONTENT)
report(okWrite, "writefile 写入工作区根目录", writeErr)

if not okWrite then
	print("[WORKTEST] 写入失败，后面的读回测试跳过。")
	return
end

-- 2. isfile
if isfile then
	local okFile, exists = pcall(isfile, FILE_NAME)
	report(okFile and exists == true, "isfile 文件存在", okFile and tostring(exists) or exists)
end

-- 3. readfile 读回校验
if readfile then
	local okRead, content = pcall(readfile, FILE_NAME)
	local same = okRead and content == CONTENT
	report(same, "readfile 内容一致", okRead and ("长度=" .. tostring(type(content) == "string" and #content or "nil")) or content)
else
	print("[WORKTEST] 没有 readfile，跳过读回校验")
end

-- 4. appendfile（可选）
if appendfile then
	local suffix = "\nAPPENDED " .. nowString()
	local okAppend, appendErr = pcall(appendfile, FILE_NAME, suffix)
	report(okAppend, "appendfile 追加内容", appendErr)
	if okAppend and readfile then
		local okRead, content = pcall(readfile, FILE_NAME)
		local expected = CONTENT .. suffix
		report(okRead and content == expected, "appendfile 后内容一致", okRead and ("长度=" .. tostring(type(content) == "string" and #content or "nil")) or content)
	end
end

-- 5. listfiles（可选）
if listfiles then
	local okList, list = pcall(listfiles, "")
	if not okList then
		okList, list = pcall(listfiles, ".")
	end
	if okList and type(list) == "table" then
		local found = false
		local sample = {}
		for _, item in list do
			local text = tostring(item)
			if string.find(text, FILE_NAME, 1, true) then
				found = true
			end
			if #sample < 10 then
				sample[#sample + 1] = text
			end
		end
		report(found, "listfiles 能找到测试文件", found and "找到" or ("条目: " .. table.concat(sample, ", ")))
	else
		report(false, "listfiles 工作区", list)
	end
end

-- 6. 显示绝对路径（不删除文件）
local workspace, source = getWorkspacePath()
if workspace then
	workspace = workspace:gsub("\\", "/"):gsub("/+$", "")
	if workspace ~= "" then
		local absolute = isAbsolute(workspace) and (workspace .. "/" .. FILE_NAME) or FILE_NAME
		print("[WORKTEST] 工作目录来源:", source)
		print("[WORKTEST] 文件相对路径:", FILE_NAME)
		print("[WORKTEST] 文件绝对路径:", absolute)
		if not isAbsolute(workspace) then
			print("[WORKTEST] 提示: 工作目录不是绝对路径，可能是执行器虚拟路径。")
		end
	end
end

print("==============================================")
print("[WORKTEST] 测试完成，文件未删除。")
print("[WORKTEST] 请打开下面的目录确认是否有", FILE_NAME)
print("[WORKTEST]", KNOWN_WORKSPACE)
print("==============================================")
