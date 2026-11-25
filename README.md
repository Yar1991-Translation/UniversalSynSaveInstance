# UniversalSynSaveInstance（Fork）

上游项目：https://github.com/luau/UniversalSynSaveInstance
本 Fork 新增了自定义导出目录、导出进度条和仅供测试提示，详见下方。

# ⚠️ 仅供测试 / FOR TESTING ONLY

本项目及导出的文件仅供个人学习、研究与技术测试使用。
导出的文件可能包含受版权保护的内容，请在导出后 **24 小时内删除全部导出文件**，
不得用于商业用途、公开传播或任何侵犯他人权利的行为。
使用者应自行承担因使用本工具产生的一切法律责任；使用前请自行确认是否符合当地法律及 Roblox 服务条款。

Exported files may contain copyrighted material. Delete all exported files within 24 hours.
Do not use them commercially or redistribute them. Use at your own risk.

# 本 Fork 新增功能

- `ExportFolder`：自定义导出目录（自动尝试创建）。相对路径基于执行器工作目录；`C:/...` 或 `/...` 等绝对路径在支持它的执行器中会直接使用。
- `WorkspacePath`：当执行器没有 `getworkspace()` 时，手动填写执行器工作目录，用于控制台显示绝对路径（不影响文件实际写入位置）。Solara 当前工作区是 `D:/solara/workspace`。
- 导出进度条：`ShowStatus = true`（默认）时，屏幕右上角会显示导出百分比进度条。
- 导出完成后会在控制台打印文件的绝对路径（执行器提供 `getworkspace()` 等函数时）；如果执行器只支持相对路径，会打印相对路径并给出提示。
- `TestOnlyNotice` / `TestOnlyNoticeTimeout`：导出前显示“仅供测试，24 小时内删除”提示。默认 15 秒后自动继续；设为 `0` 或负数则必须手动点击确认。`ReadMe = true`（默认）时，导出文件内的 README 脚本也会包含该提示。

# Loadstring

```lua
local Params = {
 RepoURL = "https://raw.githubusercontent.com/Yar1991-Translation/UniversalSynSaveInstance/main/",
 SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
local Options = { -- Documentation here https://luau.github.io/UniversalSynSaveInstance/api/SynSaveInstance
    ExportFolder = "USSI_Exports", -- 自定义导出目录（自动创建）
    TestOnlyNotice = true,         -- 导出前显示仅供测试提示
    TestOnlyNoticeTimeout = 15,    -- 15 秒后自动继续；0 = 必须手动确认
    ShowStatus = true,             -- 显示导出进度条
}
synsaveinstance(Options)
```

# 测试脚本

- `test_export_path_display.luau`：导出一个临时模型，验证导出完成后控制台是否显示文件的绝对路径。

# 💖 Support Us & Our Work

<a href='https://ko-fi.com/M4M1JNH5G' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi2.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' title='KO-FI' /></a>
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/M4M1JNH5G "KO-FI")
<br />
[![ko-fi](https://user-images.githubusercontent.com/95628489/231759262-25661006-b7ca-4967-a79d-2b465cd9575a.png)](https://ko-fi.com/M4M1JNH5G "KO-FI QR-CODE")

# DISCORD SERVER:<br />

<https://discord.com/invite/wx4ThpAsmw> **/** <https://discord.gg/wx4ThpAsmw><br />
[<img src="https://discordapp.com/api/guilds/1022465460517740654/widget.png?style=banner2" alt="Our Official Discord Server!"></img>](https://discord.com/invite/wx4ThpAsmw)<br />

