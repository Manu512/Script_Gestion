-- script domoticz/scripts/lua/script_device_eclairage_ext.lua
local script_label = "Eclairage exterieur"

local lum = "Eclairage exterieur"

commandArray = {} 

if devicechanged[lum] then
	if (timeofday['Daytime'] and otherdevices[lum] == 'On') then
    commandArray[lum] = 'Off'
	print (script_label .. ' tentative d\' allumage des lampes exterieur alors qu\'il fait jour, EXTINCTION')
	end
	
end
	
return commandArray 