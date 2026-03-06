_G.STD = _G.STD or {}
STD._path = ModPath

Hooks:Add("LocalizationManagerPostInit", "STD_Localization", function(loc)
	local lang = SystemInfo:language()
	if lang and lang:key() == Idstring("french"):key() then
		loc:load_localization_file(STD._path .. "loc/french.txt")
	end
	loc:load_localization_file(STD._path .. "loc/english.txt", false)
end)
