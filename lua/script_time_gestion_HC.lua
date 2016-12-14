local script_label = "Gestion HP/HC"

local HP = "EDF Heures Pleines"
local HC = "EDF Heures Creuses"

time = os.date()
s = time
year = string.sub(s, 1, 4)
month = string.sub(s, 6, 7)
day = string.sub(s, 9, 10)
hour = string.sub(s, 12, 13)
minutes = string.sub(s, 15, 16)
seconds = string.sub(s, 18, 19)

commandArray = {}

if (( hour == "02" and minutes == "00")  or ( hour == "14" and minutes == "30")) then
  commandArray[HC]='On'
  commandArray[HP]='Off'
  print (script_label .. ': Passage en heure creuse')
end
if (( hour == "08" and minutes == "00")  or ( hour == "16" and minutes == "30")) then
  commandArray[HC]='Off'
  commandArray[HP]='On'
  print (script_label .. ': Passage en heure pleine')
end

return commandArray
