#! /bin/bash

dir="/dacx/psqlrelease"
pg_dumpall -U postgres -f /dacx/psqlrelease/full_database_backup.sql
sleep 2
cp -rp /var/lib/pgsql/data/*.conf /dacx/backup/
sleep 5
read -p " enter the new postgres mainversion (10/9/8) of the file in the psqlrelease folder?" mainversion
sleep 5
read -p " enter the new postgres fullversion (10.17/9.3) of the file in the psqlrelease folder ?" version
sleep 5
echo "stopping Djinn service..."
systemctl stop djinn.service
sleep 2
echo "stopping postgres service"
systemctl disable postgres*.service
systemctl stop postgres*.service
sleep 2
rpm -qa | grep postgres > "$dir"/postgres-packages-installed.txt
echo "removing postgres packages.."
while read line; do
    if grep $line "$dir"/postgres-packages-installed.txt > /dev/null
    then
    rpm -e $line   
    else
    echo "Did not find $line"
    fi
done <
sleep 5
mv /var/lib/pgsql /var/lib/pgsql.BAK
sleep 5 
rpm -ivh "$dir"/postgresql$mainversion-$version-1PGDG.rhel7.x86_64.rpm
sleep 5
rpm -ivh "$dir"/postgresql$mainversion-contrib-$version-1PGDG.rhel7.x86_64.rpm
sleep 5
rpm -ivh "$dir"/postgresql$mainversion-devel-$version-1PGDG.rhel7.x86_64.rpm
sleep 5
rpm -ivh "$dir"/postgresql$mainversion-docs-$version-1PGDG.rhel7.x86_64.rpm
sleep 5
rpm -ivh "$dir"/postgresql$mainversion-libs-$version-1PGDG.rhel7.x86_64.rpm
sleep 5
rpm -ivh "$dir"/postgresql$mainversion-plpython-$version-1PGDG.rhel7.x86_64.rpm
sleep 5
rpm -ivh "$dir"/postgresql$mainversion-server-$version-1PGDG.rhel7.x86_64.rpm
sleep 5
/usr/pgsql-$mainversion/bin/postgresql-$mainversion-setup initdb
sleep 5
echo "starting Djinn service..."
systemctl start djinn.service
sleep 2
echo "starting postgres service"
systemctl enable postgres*.service
systemctl start postgres*.service
sleep 5
psql -U postgres < /dacx/psqlrelease/full_database_backup.sql
sleep 10
