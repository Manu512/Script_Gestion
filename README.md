# Script_Gestion

Attention, les fichiers doivent rester dans leurs repertoires et garder les meme noms.
Il faut placer les 2 repertoires dans /domoticz/scripts/ pour que cela fonctionne.

Script de gestion de mon serveur domotique basé sur Domoticz

# Repertoire LUA

Contient les scripts en LUA suivant:
+ script_device_compteurHC-HP.lua
Gere le compteur heure creuse / heure pleine et tous ce qui en decoulle
+ script_time_gestion_HC.lua
Gere les heures creuses et pleines
+ script_device_eclairage_ext.lua
Gere l'eclairage exterieur si il fait jour, eteins immediatement l'eclairage.
+ script_time_eclairage_ext.lua
Eteins l'eclairage exterieur au bout de 10 min.
+ script_device_temperature_exterieur.lua
Futur Script qui va notifier par sms les temperatures de la nuit (Max, Min et moyenne) et alerter si il y a eu du gel.

# Repertoire Python
Contient les scripts en Pÿthon suivant :
+ sondes.py
Script Python de recuperation de mes 9 sondes DS18B20
+ sonnettes2.py
Script Python gestions des sonnettes/SMS et de l'eclairage exterieur.
