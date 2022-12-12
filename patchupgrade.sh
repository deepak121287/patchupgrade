#! /bin/bash
releasefrom=$(rpm -qa | grep ameyo-server | awk -F "[-.]" '{print $3"."$4}')

submenu () {
HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
local BACKTITLE="Backup menu"
local TITLE="Backup Menu"
local MENU="Choose one of the following options:"

local OPTIONS=(1 "Create Backup folders"
         2 "Database Backup"
         3 "Config files Backup"
         4 "Exit")

local CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo "create Backup folders"
            sleep 2
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/release;
            sleep 2 
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/appDbBk;
            sleep 2
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/crmBk;
            sleep 2
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/voicePromptBk;
            sleep 2
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/acpBk;
            sleep 2
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/nodeFlowBk;
            sleep 2
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/otherBk;
            sleep 2
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/otherBk/moh;
            sleep 2
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/artBk;
            Sleep 2
            ;;
        2)  
            directory=$(ls /dacx/ | grep R)
            dbname=$(cat /dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/web_server_ameyoconfig.props | grep ameyoDatabaseName | awk -F"=" '{print $2}')
            dbIP=$(cat /dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/hibernate.properties | grep 'url' | grep 'postgresql' | awk -F"/" '{print $3}')

            read -p "Do you want to take a 1.Normal Backup 2.Full DB backup ? (Enter 1 or 2)" backup
            sleep 2
            if [ $backup == 1 ]; then

            echo "The Application DB name is $dbname, executing backup script now.."
            sleep 5
            echo "Running DB backup..."
            sleep 5
            pg_dump -v -h $dbIP -U postgres $dbname -f /dacx/"$directory"/appDbBk/$dbname_`date +%F`.sql 
            echo -e "\nDatabase backed up to /dacx/"$directory"/appDbBk/"
            sleep 5

            elif [ $backup == 2 ]; then
            echo "Executing Full backup now.."
            sleep 5
            echo "Running Full backup..."
            sleep 5
            pg_dumpall -v -h $dbIP -U postgres -f /dacx/"$directory"/appDbBk/full_databse_bk_`date +%F`.sql
            echo -e "\nFull DB backed up to /dacx/"$directory"/appDbBk/"
            sleep 5
            else 
            echo "Wrong option!!"
            fi        
            ;;
        3)  directory=$(ls /dacx/ | grep R)
            acpIP=$(cat web_server_ameyoconfig.props | grep acpServerIP | awk -F "=" '{ print $2 }')
            crmIP=$(cat web_server_ameyoconfig.props | grep acpServerIP | awk -F "=" '{ print $2 }')
            appIP=$(cat web_server_ameyoconfig.props | grep ameyoServerIP | awk -F "=" '{ print $2 }')

            echo "Taking ameyo voicelogs conversion configuration file backup"
            sleep 2
            cp -vr /dacx/var/ameyo/dacxdata/etc/djinn/scripts/ameyoVoicelogsConversion.ini /dacx/$directory/appDbBk/
            sleep 2
            echo "Taking CRM bakup under /dacx/$directory/crmBk"
            sleep 2
            cp -va /dacx/ameyo/crm/html /dacx/$directory/crmBk
            sleep 2
            echo "Taking VoicePromt backup under /dacx/$directory/voicePromptBk"
            cp -va /dacx/var/ameyo/dacxdata/voiceprompts /dacx/$directory/voicePromptBk
            sleep 2
            echo "Taking ACP conf backup under /dacx/$directory/acpBk"
            sleep 2
            cp -va /dacx/ameyo/acp/plugins/reportika /dacx/$directory/acpBk
            sleep 2
            cp -va /dacx/ameyo/acp/apps/system/modules /dacx/$directory/acpBk
            sleep 2
            echo "Taking tomcat & drishti-chat.keystore files backup"  
            sleep 2
            cp -va /ameyo_mnt/dacx/ameyo/com.drishti.dacx.server.product/drishti-chat.keystore /dacx/$directory/otherBk
            sleep 2
            cp -va /ameyo_mnt/dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/tomcat.conf /dacx/$directory/otherBk
            sleep 2            
            echo "Taking other backups"
            sleep 2
            echo "Cron for root User" > /dacx/$directory/otherBk/cron
            sleep 2
            crontab -l >> /dacx/$directory/otherBk/cron
            sleep 2
            echo "Cron for dacx User" >> /dacx/$directory/otherBk/cron
            sleep 2
            crontab -l -u dacx >> /dacx/$directory/otherBk/cron
            sleep 2
            echo "chkconfig backup"
            sleep 2
            chkconfig --list | grep "3:on" > /dacx/$directory/otherBk/chkconfig
            sleep 2
            echo "moh file backup"
            sleep 2
            cp -a /dacx/var/ameyo/dacxdata/asterisks/1.6/var/lib/asterisk/sounds/en/moh.* /dacx/$directory/otherBk/moh
            sleep 2           
            ;;
        4) 
            main_menu
esac
}

main_menu(){
HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
local BACKTITLE="Patch upgrade 4.81"
local TITLE="Upgrade Menu"
local MENU="Choose one of the following options:"

local OPTIONS=(1 "Current release"
         2 "Pre-Patching Checklist"
         3 "Upgrade"
         4 "Exit")

while [ "$CHOICE -ne 4" ]; do

local CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            echo "Current release is $releasefrom"
            sleep 5
            ;;
        2)
            submenu
            ;;
        3)
            ;;

        4) 
            break
            ;;
esac
done
}

main_menu
