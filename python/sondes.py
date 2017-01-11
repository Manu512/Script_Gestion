#!/usr/bin/env python
import sys
import glob
import time
import requests

# Domoticz server
DOMO_IP = "127.0.0.1"
DOMO_PORT = "8080"

# Gestion sonde de temperatures
TTRDEFAUT = "60" # Délai d'attente entre 2 iterations de mesure des sondes.
TEMP_EXTERIEUR = "48"
TEMP_SORTIE_VMC = "49"
TEMP_SALON = "50"
TEMP_BUREAU = "51"
TEMP_CHAMBRE = "52"
TEMP_SDB = "53"
TEMP_EAU_CHAUDE = "54"
TEMP_EAU_FROIDE = "55"
TEMP_A_DEFINIR = "56"

def maj_temp(IDX,t):
   if t < 80:
      url = 'http://'+DOMO_IP+':'+DOMO_PORT+'/json.htm'
      payload = {'type': 'command', 'param': 'udevice','nvalue': '0', 'idx': IDX, 'svalue': t }
      r = requests.get(url, params=payload)
      #print(r.url)
   return

# Gestion de la boucle en fonction de l'argument.
if len(sys.argv) > 1:
   try:
      TTR = str(int(sys.argv[1]))
   except:
      TTR = TTRDEFAUT # Délai d'attente entre 2 iterations de mesure des sondes.
else:
    TTR = TTRDEFAUT # Délai d'attente entre 2 iterations de mesure des sondes.

# DS18B20.py
# 2016-04-25
# Public Domain

# Typical reading
# 73 01 4b 46 7f ff 0d 10 41 : crc=41 YES
# 73 01 4b 46 7f ff 0d 10 41 t=23187

while True:

   for sensor in glob.glob("/sys/bus/w1/devices/28-00*/w1_slave"):
      id = sensor.split("/")[5]

      try:
         f = open(sensor, "r")
         data = f.read()
         f.close()
         if "YES" in data:
            (discard, sep, reading) = data.partition(' t=')
            t = float(reading) / 1000.0
            t = round(t,1)
            #print("{} {:.2f}".format(id, round(t,2)))
            if "28-0004785507ff" in id:
               IDX = TEMP_EXTERIEUR
               url = maj_temp(IDX,t)
            if "28-0004774bb7ff" in id:
               IDX = TEMP_SORTIE_VMC
               url = maj_temp(IDX,t)
            if "28-0004735082ff" in id:
               IDX = TEMP_SALON
               url = maj_temp(IDX,t)
            if "28-0004734c51ff" in id:
               IDX = TEMP_EAU_CHAUDE
               url = maj_temp(IDX,t)
            if "28-00044ef0e7ff" in id:
               IDX = TEMP_CHAMBRE
               url = maj_temp(IDX,t)
            if "28-00044cf1adff" in id:
               IDX = TEMP_SDB
               url = maj_temp(IDX,t)
            if "28-0004734ceaff" in id:
               IDX = TEMP_BUREAU
               url = maj_temp(IDX,t)
            if "28-0004774c20ff" in id:
               IDX = TEMP_EAU_FROIDE
               url = maj_temp(IDX,t)
            if "28-00044ceea2ff" in id:
               IDX = TEMP_A_DEFINIR
               url = maj_temp(IDX,t)
      except:
         pass
   #break
   time.sleep(TTR)
