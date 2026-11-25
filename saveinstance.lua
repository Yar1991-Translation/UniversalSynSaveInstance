local Params = {
	RepoURL = "https://raw.githubusercontent.com/Yar1991-Translation/UniversalSynSaveInstance/main/",
	SSI = "saveinstance",
}
local synsaveinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
return function(Options)
	synsaveinstance(Options)
end
