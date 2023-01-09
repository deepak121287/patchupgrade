#! /bin/bash
mkdir /dacx/psqlrelease
dir="/dacx/psqlrelease"
rpm -qa | grep postgres > "$dir"/postgres-packages-installed.txt
count = $(rpm -qa | grep postgres | wc -l)
echo "removing postgres packages.."
while [ i==$count ]
do
rpm -e $(awk 'FNR==1' "$dir"/postgres-packages-installed.txt).rpm
done
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
