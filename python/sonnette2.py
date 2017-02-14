#!/usr/bin/env python
# -*- coding: utf-8 -*-
#   File : sonnette.py
#   Author: manu512
#   Date: 14-Februar-2017
#   Description : Gestion SMS sonnette
#   URL : https://github.com/jmleglise/mylittle-domoticz/edit/master/Presence%20detection%20%28beacon%29/test_beacon.py
#   Version : 1.0
#

import os
import sys
import requests
import json
from datetime import datetime
from freesms import FreeClient
from free import ABONNEMENTFREE, CLEEABONNEMENTFREE

TPS = datetime.now().strftime('%H:%M')

def include(filename):
    if os.path.exists(filename): 
        execfile(filename)

IDX = 97 
MSG = "On vient de sonner !!"

# Domoticz server
DOMO_IP = "127.0.0.1"
DOMO_PORT = "8080"

# Gestion de la boucle en fonction de l'argument.
if len(sys.argv) > 1:
   try:
      if int(sys.argv[1]) == 30:
         MSG = "On vient de sonner devant !"
         #IDX = sys.argv[1]
      else:
         MSG = "On vient de sonner a la terrasse !"
         #IDX = sys.argv[1]
   except:
      MSG = "On vient de sonner" # Message par defaut quand un appui sur la sonnette a ete detecte.
      IDX = 97
	 
url = 'http://'+DOMO_IP+':'+DOMO_PORT+'/json.htm'
arguments = {'type': 'command', 'param': 'switchlight', 'idx': IDX, 'switchcmd': 'On' }
r = requests.get(url, params=arguments)

for i in range(2):
   f = FreeClient(user=ABONNEMENTFREE[i], passwd=CLEEABONNEMENTFREE[i])
   resp = f.send_sms(MSG)

#sys.exit(0)

# -------- Allumage de la lumière quand il fait nuit --------------
sunrise = {'type': 'command', 'param': 'getSunRiseSet'} 
r = requests.get(url, params=sunrise)
info = r.json()
couche = info['Sunset']
levee = info['Sunrise']

DAY, NIGHT = 1, 2
def check_time(time_to_check, on_time, off_time):
    if on_time > off_time:
        if time_to_check > on_time or time_to_check < off_time:
            return NIGHT, True
    elif on_time < off_time:
        if time_to_check > on_time and time_to_check < off_time:
            return DAY, True
    elif time_to_check == on_time:
        return None, True
    return None, False

when, matching = check_time(TPS, couche, levee)

if matching:
    if when == NIGHT:
        #print("Night Time detected.")
        arguments = {'type': 'command', 'param': 'switchlight', 'idx': '27', 'switchcmd': 'On' }
        r = requests.get(url, params=arguments)
    #elif when == DAY:
	    #print("Day Time detected.")
		
# ------- Fin allumage de la lumiere quand il fait nuit ---------------