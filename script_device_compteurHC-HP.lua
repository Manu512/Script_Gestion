-- script domoticz/scripts/lua/script_device_compteurHC-HP.lua
local script_label = "EDF"

-- Initialisation des variables locales
local capteurGlobal = "Compteur ES"
local capteurCptHP = "Compteur Electrique HP"
local capteurCptHC = "Compteur Electrique HC"
local HistoHCHP = "Compteur_Histo"
local euro = "EURO_EDF"

local es = "ES"

local idxEs = otherdevices_idx[es]



local idxCptHP = otherdevices_idx[capteurCptHP]
local idxCptHC = otherdevices_idx[capteurCptHC]
local idxCptHisto = otherdevices_idx[HistoHCHP]
local idxEuro = otherdevices_idx[euro]
local flagHC = "EDF Heures Creuses"

local euro_HC = uservariables['Cout_KW_HC']
local euro_HP = uservariables['Cout_KW_HP']

-- Mode debug Oui / Non
local debug = uservariables['DEBUG']

-- Fonction de mise à jour
function update(device, id, power, energy, index)
--     print(script_label .. ' Update ' .. device .. ' ID : ' .. id .. ' => power : ' .. power .. ' energy :' .. energy)
    commandArray[index] = {['UpdateDevice'] = id .. "|0|" .. power .. ";" .. energy}
    return
end

commandArray = {} 

if otherdevices["Standbye_Signal"] == "On" then 
    print (script_label .. " : Standbye_Signal configuré, aucun pilotage")
    return commandArray    
end

if debug == True then
	print(script_label .. ' Start')
	print(script_label .. ' Debug : ' .. debug)   
	print(script_label .. ' capteurGlobal : ' .. capteurGlobal)
end

Conso_Cumul, Conso_Instant = otherdevices_svalues[capteurGlobal]:match("([^;]+);0;0;0;([^;]+)")

Conso_Instant = tonumber (Conso_Instant)
--     print (script_label .. ' Conso Instant = ' .. Conso_Instant .. "/Watts")
--     print (script_label .. ' Conso Cumul = ' .. Conso_Cumul .. "/Watts")
--     print (script_label .. ' Conso Cumul/1000 = ' .. Conso_Cumul/1000 .. "/kWh")

-- update(HistoHCHP, idxCptHisto,  0, 0, 1)
-- update(capteurCptHP, 726,  0, 0, 5)
-- update(capteurCptHC, idxCptHC,  0, 0, 5)
-- update(euro, idxEuro, 0, 0, 1)
-- update(euro, 728, 0,0, 5)

if (devicechanged[capteurGlobal]) then
--     print (script_label .. ' Il y a eu augmentation de la consommation')
    -- Mise à jour du compteur
    Histo_Instant, Histo_Cumul = otherdevices_svalues[HistoHCHP]:match("([^;]+);([^;]+)")
--     print (script_label .. ' Conso Histo Instant = ' .. Histo_Instant .. "/kWh")
--     print (script_label .. ' Conso Histo Cumul = ' .. Histo_Cumul .. "/kWh")
--     print (script_label .. ' Conso Histo Cumul/1000 = ' .. Histo_Cumul/1000 .. "/kWh")
    

    -- commandArray[capteurCptHP]= tostring(Delta_Conso)
--     print (script_label .. ' flagHC = ' .. otherdevices[flagHC])
    
    if (otherdevices[flagHC]=='On') then
--         print (script_label .. ' On est en heures creuses')
        Delta_Conso = (Conso_Cumul-Histo_Cumul)
--         print (script_label .. ' Delta Conso = ' .. Delta_Conso .. "/Wh")
--         print (script_label .. ' Delta Conso = ' .. Delta_Conso/1000 .. "/kWh")
--         print (script_label .. ' La conso du kWh HC est de : ' .. euro_HC)
        -- Seul le cumule du compteur nous interesse pour calculer la nouvelle valeur
        conso_Cumul = tonumber(conso_Cumul)
        euro_HCHP = euro_HC
--         print(script_label .. ' Compteur cible = HC')
--         print(script_label .. ' Valeur capteurCptHC = '..tostring(capteurCptHC))
--         print(script_label .. ' Valeur idxCptHC = '..tostring(idxCptHC))
--         print(script_label .. ' Valeur consoInstant = '..tostring(Conso_Instant))

        -- Mise à jour du compteur
        consoInstantHC, consoCumuleHC = otherdevices_svalues[capteurCptHC]:match("([^;]+);([^;]+)")
--         print(script_label .. ' Valeur consoInstantHC = '..tostring(capteurCptHC))
--         print(script_label .. ' Valeur consoCumuleHC = '..tostring(capteurCptHC))
        update(capteurCptHC, idxCptHC, tonumber(Conso_Instant), consoCumuleHC+Delta_Conso, 1)
        
        -- Mise à 0 de la conso intantanee du compteur HP
        consoInstantHP, consoCumuleHP = otherdevices_svalues[capteurCptHP]:match("([^;]+);([^;]+)")
        consoInstantHP = 0
        update(capteurCptHP, idxCptHP, consoInstantHP, consoCumuleHP, 2)

        -- Sauvegarde de la valeur du compteur global pour prochain calcul
        update(HistoHCHP, idxCptHisto,  Conso_Instant, Conso_Cumul, 3)    
        euro_HCHP = euro_HC
    else
        -- Periode heures pleines
        -- Recuperation des valeurs du compteur global
--         print (script_label .. ' On est en heures pleines')
        Delta_Conso = (Conso_Cumul-Histo_Cumul)
--         print (script_label .. ' Delta Conso = ' .. Delta_Conso .. "/Wh")
--         print (script_label .. ' Delta Conso = ' .. Delta_Conso/1000 .. "/kWh")
--         print (script_label .. ' La conso du kWh HP est de : ' .. euro_HP)
        -- Seul le cumule du compteur nous interesse pour calculer la nouvelle valeur
        conso_Cumul = tonumber(conso_Cumul)
        euro_HCHP = euro_HP
--         print(script_label .. ' Compteur cible = HP')
--         print(script_label .. ' Valeur capteurCptHP = '..tostring(capteurCptHP))
--         print(script_label .. ' Valeur idxCptHP = '..tostring(idxCptHP))
--         print(script_label .. ' Valeur consoInstant = '..tostring(Conso_Instant))

        -- Mise à jour du compteur
        consoInstantHP, consoCumuleHP = otherdevices_svalues[capteurCptHP]:match("([^;]+);([^;]+)")
        update(capteurCptHP, idxCptHP, tonumber(Conso_Instant), consoCumuleHP+Delta_Conso, 1)
        
        -- Mise à 0 de la conso intantanee du compteur HC
        consoInstantHC, consoCumuleHC = otherdevices_svalues[capteurCptHC]:match("([^;]+);([^;]+)")
        consoInstantHC = 0
        update(capteurCptHC, idxCptHC, consoInstantHC, consoCumuleHC, 2)

        -- Sauvegarde de la valeur du compteur global pour prochain calcul
        update(HistoHCHP, idxCptHisto, Conso_Instant, Conso_Cumul, 3)
        euro_HCHP = euro_HP
    end
--     print(script_label .. ' Calcul Tarifaire')
--     print(script_label .. ' Calcul Tarifaire => Delta_Conso /Wh: ' .. Delta_Conso)
--     print(script_label .. ' Calcul Tarifaire => Delta_Conso /kWh: ' .. Delta_Conso/1000)
--     print(script_label .. ' Calcul Tarifaire => Tarif kWh : ' .. euro_HCHP)
--     print(script_label .. ' Calcul Tarifaire => Cout : ' .. Delta_Conso/1000*euro_HCHP)

    Cout_Instant, Cout_Cumul = otherdevices_svalues[euro]:match("([^;]+);([^;]+)")
--     print(script_label .. ' Calcul Tarifaire => Cout_Cumul actuel : ' .. Cout_Cumul)    
--     print(script_label .. ' Calcul Tarifaire => Cout_Cumul+Delta_Conso*euro_HCHP : ' .. Cout_Cumul+Delta_Conso/1000*euro_HCHP)    
    update(euro, idxEuro,  Cout_Cumul+ Delta_Conso/1000*euro_HCHP, Cout_Cumul+ Delta_Conso/1000*euro_HCHP, 4)
    commandArray[idxEs] = { ['UpdateDevice'] = idxEs ..'|0|'.. consoCumuleHP ..';'.. consoCumuleHC ..';0;0;'.. Conso_Instant ..';0' }
else
--     print (script_label .. " Il n'y a PAS eu augmentation de la consommation")
end


return commandArray 
