#! /bin/sh

##-------------------------------------------------------------------------
## Script : backup.sh
##
## Objectif : Script qui permet d'automatiser la sauvegarde des éleménts
## importants d'une installation DOmoticz'
##
## Auteur : Bastien DUMAS 
## Date : 01/11/2015
## Version : 1.0
##-------------------------------------------------------------------------
. /home/pi/domoticz/scripts/shell/include_passwd # comprend les identifiants pour acceder à la freebox et transmission des SMS via FreeMobile


################### CONFIGURATION DU SCRIPT ###################
## Information abonné FreeMobile pour l'envoie de SMS
FREE_USERNAME="18280298" #Nom d'utilisateur freemobile
FREE_PASSWORD="olI6IHKMZsY9V2" #Password freemobile

#Informations relative à domoticz
DOMOTICZ_IP="127.0.0.1"  # Domoticz IP 
DOMOTICZ_PORT="8080"        # Domoticz port 
DOMOTICZ_DIRECTORY="/home/pi/domoticz" #Répertoire Domoticz
FILESYSTEM="/dev/mmcblk0" #Chemin du device filesystem

# Montage de la Freebox
echo "Montage de la Freebox"
/sbin/mount.cifs //mafreebox.freebox.fr/Disque\ dur/ /mnt/freebox/ -o user=$user_box,pass=$pass_box

#Informations relative à la sauvegarde
BACKUP_DIRECTORY="/mnt/freebox/Backup_img" #Répertoire de destination des fichiers issus de la sauvegarde
TIMESTAMP=`/bin/date +%Y%m%d%H%M%S` #Timestamp utilisé pour différencier les sauvegardes
DB_BACKUPFILE="domoticz_$TIMESTAMP.db" #Nom du fichier issu de la sauvegarde de la base de donnée domoticz
DOMOTICZ_DIRECTORY_BACKUPFILE="domoticz_directory_$TIMESTAMP.tar.gz" #Nom du fichier issu de la sauvegarde du répertoire domoticz 
FILESYSTEM_BACKUPFILE="domoBox_$TIMESTAMP.gzip" #Nom du fichier issu de la sauvegarde du filesystem complet

#Chemin du fichier de log
LOG_FILE="/mnt/freebox/Backup_img/backup.log"

#Temps de conservation des fichiers de sauvegarde
TTL_DB="7" #Base de donnée
TTL_DOMOTICZ="31" #Répertoire domoticz
TTL_FILESYSTEM="62" #Sauvegarde complete du FILESYSTEM
###############################################################




####################### DEBUT DU SCRIPT #######################
echo "===============> Sauvegarde du $TIMESTAMP" >> $LOG_FILE
echo "==== ELEMENTS DE CONFIGURATION ====" >> $LOG_FILE
echo "BACKUP_DIRECTORY : $BACKUP_DIRECTORY" >> $LOG_FILE
echo "TIMESTAMP : $TIMESTAMP" >> $LOG_FILE
echo "DB_BACKUPFILE : $DB_BACKUPFILE" >> $LOG_FILE
echo "DOMOTICZ_DIRECTORY_BACKUPFILE : $DOMOTICZ_DIRECTORY_BACKUPFILE" >> $LOG_FILE
echo "FILESYSTEM_BACKUPFILE : $FILESYSTEM_BACKUPFILE" >> $LOG_FILE
echo "myBackupFile = ${BACKUP_DIRECTORY}/${DB_BACKUPFILE}" >> $LOG_FILE
echo "LOG_FILE = $LOG_FILE" >> $LOG_FILE
echo "===================================" >> $LOG_FILE
echo "" 
echo ""


        #### PARTIE 1 : SAUVEGARDE #####

case "$1" in
	DB) ## Sauvegarde de la base de donnée de domoticz
		echo "$TIMESTAMP : Vous avez demande la sauvegarde de la base de donnée de Domoticz " >> $LOG_FILE
		myBackupFile="${BACKUP_DIRECTORY}/${DB_BACKUPFILE}"

		#Initialisation du timer
		BEFORE=$(/bin/date +'%s')

		#Sauvegarde
		sav_db=$(curl -s http://$DOMOTICZ_IP:$DOMOTICZ_PORT/backupdatabase.php > $myBackupFile)

		#Calcul du temps d'éxécution
		AFTER=$(/bin/date +'%s')
		ELAPSED=$(($AFTER - $BEFORE))
		ELAPSED=`/bin/date -u -d @${ELAPSED} +"%T"`

		#LOG du résultat
		if [ -e $myBackupFile ]
		then
			msg="$TIMESTAMP : Sauvegarde OK dans le fichier : $myBackupFile en $ELAPSED"
			echo $msg >> $LOG_FILE
			##Envoie du SMS de succes
			curl -s -i -k "https://smsapi.free-mobile.fr/sendmsg?user=$FREE_USERNAME&pass=$FREE_PASSWORD&msg=$msg"
		else
			msg="$TIMESTAMP : ERREUR LORS DE LA SAUVEGARDE DE LA BASE DE DONNEE DOMOTICZ" 
			echo $msg >> $LOG_FILE
			##Envoie du SMS d'erreur
			curl -s -i -k "https://smsapi.free-mobile.fr/sendmsg?user=$FREE_USERNAME&pass=$FREE_PASSWORD&msg=$msg"
			exit 3;
		fi
	;;
	DOMOTICZ) ## Sauvegarde du répertoire domoticz complet
		echo "$TIMESTAMP : Vous avez demande la sauvegarde du répertoire DOMOTICZ" >> $LOG_FILE

		#Construction du nom de fichier
		myBackupFile="${BACKUP_DIRECTORY}/${DOMOTICZ_DIRECTORY_BACKUPFILE}"

		#Initialisation du timer
		BEFORE=$(/bin/date +'%s')

		#Sauvegarde
		sav_directory=$(sudo tar czf $myBackupFile $DOMOTICZ_DIRECTORY)

		#Calcul du temps d'éxécution
		AFTER=$(/bin/date +'%s')
		ELAPSED=$(($AFTER - $BEFORE))
		ELAPSED=`/bin/date -u -d @${ELAPSED} +"%T"`

		#LOG du résultat
		if [ -e $myBackupFile ]
		then
			msg="$TIMESTAMP : Sauvegarde OK dans le fichier : $myBackupFile en $ELAPSED" 
			echo $msg >> $LOG_FILE
			##Envoie du SMS de succes
			curl -s -i -k "https://smsapi.free-mobile.fr/sendmsg?user=$FREE_USERNAME&pass=$FREE_PASSWORD&msg=$msg"
		else
			msg="$TIMESTAMP : ERREUR LORS DE LA SAUVEGARDE DU REPERTOIRE DOMOTICZ" 
			echo $msg >> $LOG_FILE
			##Envoie du SMS d'erreur
			curl -s -i -k "https://smsapi.free-mobile.fr/sendmsg?user=$FREE_USERNAME&pass=$FREE_PASSWORD&msg=$msg"
			exit 3;
		fi
	;;
	FILESYSTEM) ## Sauvegarde du FILESYSTEM complet
		echo "$TIMESTAMP : Vous avez demande la sauvegarde du FILESYSTEM" >> $LOG_FILE
		
		#Construction du nom de fichier
		myBackupFile="${BACKUP_DIRECTORY}/${FILESYSTEM_BACKUPFILE}"
		
		#Initialisation du timer
		BEFORE=$(/bin/date +'%s')
		
		#Sauvegarde
		sav_filesystem=$(sudo dd bs=4M if=$FILESYSTEM | gzip > $myBackupFile)
		
		#Calcul du temps d'éxécution
		AFTER=$(/bin/date +'%s')
		ELAPSED=$(($AFTER - $BEFORE))	
		ELAPSED=`/bin/date -u -d @${ELAPSED} +"%T"`
		
		#LOG du résultat
		if [ -e $myBackupFile ]
		then
			msg="$TIMESTAMP : Sauvegarde OK dans le fichier : $myBackupFile en $ELAPSED"
			echo $msg >> $LOG_FILE
			##Envoie du SMS de succes
			curl -s -i -k "https://smsapi.free-mobile.fr/sendmsg?user=$FREE_USERNAME&pass=$FREE_PASSWORD&msg=$msg"
		else
			msg="$TIMESTAMP : ERREUR LORS DE LA SAUVEGARDE DU FILESYSTEM"
			echo $msg >> $LOG_FILE
			##Envoie du SMS d'erreur
			curl -s -i -k "https://smsapi.free-mobile.fr/sendmsg?user=$FREE_USERNAME&pass=$FREE_PASSWORD&msg=$msg"
			exit 3;
		fi
	;;
	*) ## ERREUR DE PARAMETRE
		
		echo "USAGE $0 :" >&2
		echo "$0 type_sauvegarde" >&2
		echo "$0 (DB|DOMOTICZ|FILESYSTEM)" >&2
		echo "Paramètres incorrectes" >> $LOG_FILE
		exit 3;
esac

        #### PARTIE 2 : NETTOYAGE #####

#Nettoyage des sauvegarde de DB
myDBFile="${BACKUP_DIRECTORY}/*.db"
DB_to_be_deleted=`find $myDBFile -type f -mtime +$TTL_DB`
echo "DB_to_be_deleted : $DB_to_be_deleted" >> $LOG_FILE
find $myDBFile -type f -mtime +$TTL_DB -exec rm {} \; 

#Nettoyage des sauvegardes de répertoire domoticz
myDIRECTORYFile="${BACKUP_DIRECTORY}/*.tar.gz"
DIRECTORY_to_be_deleted=`find $myDIRECTORYFile -type f -mtime +$TTL_DOMOTICZ`
echo "DIRECTORY_to_be_deleted : $DIRECTORY_to_be_deleted" >> $LOG_FILE
find $myDIRECTORYFile -type f -mtime +$TTL_DOMOTICZ -exec rm {} \;

#Nettoyage des sauvegardes du filesystem
myFSFile="${BACKUP_DIRECTORY}/*.gzip"
FS_to_be_deleted=`find $myFSFile -type f -mtime +$TTL_FILESYSTEM`
echo "FS_to_be_deleted : $FS_to_be_deleted" >> $LOG_FILE
find $myFSFile -type f -mtime +$TTL_FILESYSTEM -exec rm {} \;

# Démontage de la Freebox
echo "Démontage de la Freebox"
/bin/umount /mnt/freebox

	
######################## FIN DU SCRIPT #######################
