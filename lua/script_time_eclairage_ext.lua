-- script domoticz/scripts/lua/script_time_eclairage_ext.lua
local script_label = "Eclairage exterieur"

local lum = "Eclairage exterieur"

t1 = os.time()
s = otherdevices_lastupdate[lum]
-- returns a date time like 2013-07-11 17:23:12
 
year = string.sub(s, 1, 4)
month = string.sub(s, 6, 7)
day = string.sub(s, 9, 10)
hour = string.sub(s, 12, 13)
minutes = string.sub(s, 15, 16)
seconds = string.sub(s, 18, 19)
 
commandArray = {}
t2 = os.time{year=year, month=month, day=day, hour=hour, min=minutes, sec=seconds}
difference = (os.difftime (t1, t2))

if (otherdevices[lum] == 'On') then
  print ('Je surveille la lampe exterieur depuis ' .. difference .. ' secondes.')
end

if (otherdevices[lum] == 'On' and difference > 600) then
  commandArray[lum] = 'Off'
  print (script_label .. ' lumiere exterieur allumé plus de 10 min, EXTINCTION')
end

return commandArray 
