#! /bin/bash
appreleasefrom=$(rpm -qa | grep ameyo-server | awk -F "[-.]" '{print $3"."$4}')
artreleasefrom=$(rpm -qa | grep ameyo-art | awk -F "[-.]" '{print $3"."$4}')
phpreleasefrom=$(php --version | awk -F "[v,]" 'NR==4 {print $2}')
postgresreleasefrom=$(psql -V -h $dbIP)

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
            sleep 1
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/release;
            sleep 1 
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/appDbBk;
            sleep 1
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/crmBk;
            sleep 1
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/voicePromptBk;
            sleep 1
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/acpBk;
            sleep 1
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/nodeFlowBk;
            sleep 1
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/otherBk;
            sleep 1
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/otherBk/moh;
            sleep 1
            mkdir -vp /dacx/R"$releasefrom"_`date +%F`/artBk;
            Sleep 1
            ;;
        2)  
            directory=$(ls /dacx/ | grep R)
            dbname=$(cat /dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/web_server_ameyoconfig.props | grep ameyoDatabaseName | awk -F"=" '{print $2}')
            reportdbname=$(cat /dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/web_server_ameyoconfig.props | grep ameyoReportDBName | awk -F"=" '{print $2}')
            dbIP=$(cat /dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/hibernate.properties | grep 'url' | grep 'postgresql' | awk -F"/" '{print $3}')

            read -p "Do you want to take a 1.Normal Backup 2.Full DB backup ? (Enter 1 or 2)" backup
            sleep 2
            if [ $backup == 1 ]; then

            echo "The Application DB name is $dbname, executing backup script now.."
            sleep 5
            echo "Running DB backup..."
            sleep 5
            pg_dump -v -h $dbIP -U postgres $dbname -f /dacx/"$directory"/appDbBk/"$dbname"_`date +%F`.sql 
            echo -e "\nDatabase backed up to /dacx/"$directory"/appDbBk/"
            sleep 5

            echo "The reports DB name is $reportdbname, executing backup script now.."
            sleep 5
            echo "Running reports DB backup..."
            sleep 5
            pg_dump -v -h $dbIP -U postgres $reportdbname -f /dacx/"$directory"/appDbBk/"$reportdbname"_`date +%F`.sql 
            echo -e "\nReportsDatabase backed up to /dacx/"$directory"/appDbBk/"
            sleep 5

            echo "executing art configuration DB backup script now.."
            sleep 5
            pg_dump -v -h $dbIP -U postgres art_configuration_db -f /dacx/"$directory"/appDbBk/art_configuration_db_`date +%F`.sql 
            echo -e "\nartconfigurationDatabase backed up to /dacx/"$directory"/appDbBk/"
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
            read -p "enter your asterisk server IP:" asteriskIP
            read -p "enter your crmIP:" crmIP
            sleep 2
            acpIP=$(cat /ameyo_mnt/dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/web_server_ameyoconfig.props | grep acpServerIP | awk -F "=" '{ print $2 }')
            appIP=$(cat /ameyo_mnt/dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/web_server_ameyoconfig.props | grep ameyoServerIP | awk -F "=" '{ print $2 }')
            artIP=$(cat /ameyo_mnt/dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/web_server_ameyoconfig.props | grep reportsServerIP | awk -F "=" '{ print $2 }')

            echo "Taking application file backup"
            sleep 2
            cp -r /ameyo_mnt/dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf /dacx/$directory/appDbBk/
            sleep 5
            cp -r /ameyo_mnt/dacx/ameyo/com.drishti.dacx.server.product/plugins /dacx/$directory/appDbBk/
            sleep 5
            cp -r /ameyo_mnt/dacx/SI /dacx/$directory/appDbBk/
            sleep 5
            echo "Taking ART file backup"
            sleep 2
            scp -vr root@$artIP:/ameyo_mnt/dacx/var/ameyo/dacxdata/ameyo.art.product/conf /dacx/$directory/artBk/
            sleep 5
            scp -vr root@$artIP:/ameyo_mnt/dacx/ameyo/ameyo.art.product/plugins /dacx/$directory/artBk/
            sleep 5
            echo "Taking ameyo voicelogs conversion configuration file backup"
            sleep 2
            cp -vr /dacx/var/ameyo/dacxdata/etc/djinn/scripts/ameyoVoicelogsConversion.ini /dacx/$directory/appDbBk/
            sleep 2
            echo "Taking CRM bakup under /dacx/$directory/crmBk"
            sleep 2
            scp -vr root@$crmIP:/dacx/ameyo/crm/html /dacx/$directory/crmBk
            sleep 2
            echo "Taking VoicePromt backup under /dacx/$directory/voicePromptBk"
            cp -va /dacx/var/ameyo/dacxdata/voiceprompts /dacx/$directory/voicePromptBk
            sleep 2
            echo "Taking ACP conf backup under /dacx/$directory/acpBk"
            sleep 2
            scp -vr root@$acpIP:/dacx/ameyo/acp/plugins/reportika /dacx/$directory/acpBk
            sleep 2
            scp -vr root@$acpIP:/dacx/ameyo/acp/apps/system/modules /dacx/$directory/acpBk
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
            scp -vr root@$asteriskIP/dacx/var/ameyo/dacxdata/asterisks/1.6/var/lib/asterisk/sounds/en/moh.* /dacx/$directory/otherBk/moh
            sleep 2           
            ;;
        4) 
            main_menu
esac
}

submenu2 () {
HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
local BACKTITLE="Backup menu"
local TITLE="Backup Menu"
local MENU="Choose one of the following options:"

local OPTIONS=(1 "PHP upgrade"
         2 "Postgres Upgrade"
         3 "APP upgrade"
         4 "ART upgrade"
         5 "Exit")

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
        php --version > php.txt
        majrel=$(awk -F"[v,.]" 'NR==4 {print $2}' php.txt)
        minrel=$(awk -F"[v,.]" 'NR==4 {print $3}' php.txt) 
        if (($majrel >= 6)); then
        echo "no requirement to upgrade"
        elif (($minrel>=3)); then
        echo "no requirement to upgrade"
        else
        echo "we must upgrade to PHP v5.3 atleast"
        read -p "Continue (y/n)?" CONT
        if [ "$CONT" = "y" ]; then
        rpm -uvh /dacx/$directory/release/php*
        sleep 2
        else
        echo "exiting.."
        fi
        fi
        sleep 20
        ;;
        2)
        directory=$(ls /dacx/ | grep R)
        dbserverIP=$(cat /dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/hibernate.properties | grep 'url' | grep 'postgresql' | awk -F"/" '{print $3}')
        majrelp=$(psql -V -h $dbIP | awk -F[" ".] '{print $3}')
        if (($majrelp > 8)); then
        echo "no requirement to upgrade POSTGRES"
        else
        read -p "we need to upgrade postgres, have you taken backup?" CONT1
        if [ "$CONT1" = "y" ]; then
            read -p "Continue with upgrade(y/n)?" CONT2
            if [ "$CONT2" = "y" ]; then
            ssh -v root@$dbserverIP "mkdir /dacx/psqlrelease"
            scp -vr /dacx/"$directory"/release/postgres* root@$dbserverIP:/dacx/psqlrelease/
            sleep 2
            ssh -v root@$dbserverIP "bash -s" < ./postgres.sh
            else
            "exiting.."
            fi
        else
        echo "exiting.."
        fi
        fi
        sleep 20        
        ;; 
        3)
        directory=$(ls /dacx/ | grep R)
        dbserverIP=$(cat /dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/hibernate.properties | grep 'url' | grep 'postgresql' | awk -F"/" '{print $3}')
        echo "please take backup of ameyodb from the pre checklist menu before proceeding"
        read -p "do you still wish to continue with app upgrade:(y/n)?" u1
        ameyodbname=$(cat /dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/web_server_ameyoconfig.props | grep ameyoDatabaseName | awk -F"=" '{print $2}')
        if [ "$u1"="y" ]; then
        echo "stopping app server" 
        ameyoctl service appserver faststop
        rpm -Uvh /dacx/"$directory"/release/ameyo-server*.rpm
        sleep 5
        psql -U postgres -d $ameyodbname -h $dbserverIP -c "delete from schema_version;"
        psql -U postgres -d $ameyodbname -h $dbserverIP -c "delete from schema_version_history;"
        psql -U postgres -d $ameyodbname -h $dbserverIP -c "delete from data_version;"
        psql -U postgres -d $ameyodbname -h $dbserverIP -c "delete from data_version_history;"
        psql -U postgres -d $ameyodbname -h $dbserverIP -c "delete from persist_policy_instance ;"
        psql -U postgres -d $ameyodbname -h $dbserverIP -c "select id,name,value from system_configuration_parameter where name ilike '%patch%';"
        psql -U postgres -d $ameyodbname -h $dbserverIP -c "update system_configuration_parameter set value = 'true' where name ilike '%patch%';"
        sleep 5
        echo "starting app server"
        ameyoctl service appserver start
        else
        "exiting.."
        fi
        ;;
        4)
        directory=$(ls /dacx/ | grep R)
        artserverIP=$(cat /ameyo_mnt/dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/web_server_ameyoconfig.props | grep reportsServerIP | awk -F "=" '{ print $2 }')
        dbserverIP=$(cat /dacx/var/ameyo/dacxdata/com.drishti.dacx.server.product/conf/hibernate.properties | grep 'url' | grep 'postgresql' | awk -F"/" '{print $3}')
        echo "please take backup of reportsdb and art_configuration_db from the pre checklist menu before proceeding"
        read -p "do you still wish to continue with the art upgrade:(y/n)?" u2
        if [ "$u2"="y" ]; then
        ssh root@$artserverIP "mkdir /dacx/artrelease"
        sleep 2
        scp -vr /dacx/"$directory"/release/ameyo-art* root@$artserverIP:/dacx/artrelease/
        sleep 2
        echo "stopping art server"
        ssh root@$artserverIP "ameyoctl service ameyoart stop"
        sleep 5
        ssh root@$artserverIP "rpm -Uvh /dacx/artrelease/ameyo-art*.rpm"
        sleep 5
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "delete from schema_version;"
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "delete from schema_version_history;"
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "delete from data_version;"
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "delete from data_version_history;"
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "delete from last_usersync_date;"
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "delete from last_persisterusersync_date;"
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "delete from last_acpusersync_date;"
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "delete from users;"
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "delete from user_password;"
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "delete from user_password_history;"
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "select id,name,value from application_launching_configuration_parameter where name ilike '%patch%' and name not ilike '%SSOPatch%';"
        psql -U postgres -d art_configuration_db -h $dbserverIP -c "update application_launching_configuration_parameter set value = 'true' where name ilike '%patch%' and name not ilike '%SSOPatch%';"
        sleep 5
        echo "starting art server"
        ssh root@$artserverIP "ameyoctl service ameyoart start"
        else
        "exiting.."
        fi       
        ;;
        5) 
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

local OPTIONS=(1 "Current Releases"
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
            echo "Current app release is $appreleasefrom"
            echo "Current art release is $artreleasefrom"
            echo "Current php release is $phpreleasefrom"
            echo "Current postgres release is $postgresreleasefrom"
            sleep 5
            ;;
        2)
            submenu
            ;;
        3)
            submenu2
            ;;

        4) 
            break
            ;;
esac
done
}

main_menu
