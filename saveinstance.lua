local Params = {
	RepoURL = "https://gitee.com/lofblogac/UniversalSynSaveInstance/raw/main/",
	SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
return function(Options)
	synsaveinstance(Options)
end
