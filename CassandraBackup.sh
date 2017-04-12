#!/bin/bash
# Created by Sreeraju.V

DATE=`date +%Y-%m-%d`
Backup_Location=/mnt/cassandra/backup
DataDir__Location=/mnt/cassandra/data/*/*/snapshots
IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`

echo " For taking snapshot of specified keyspace,Enter Keyspace name: "
read KEYSPACE
options=("Table" "Keyspace" "CompleteKeyspace" "Quit")
select opt in "${options[@]}"
do
    case $opt in

        "Table")
#Take a snapshot of Specified Table on the node
echo " Enter Table Name: "
read TABLE
echo " Taking Backup of Table $table in Keyspace $KEYSPACE "
nodetool snapshot -t $DATE-$KEYSPACE --table $TABLE $KEYSPACE
echo "Snaphot tar archives stored in Location : $Backup_Location"
tar czf $Backup_Location/$DATE-$KEYSPACE.tgz $DataDir__Location/$DATE-$KEYSPACE.tgz
            ;;

        "Keyspace")
#Take a snapshot of Specified keyspaces on the node
echo " Taking Backup of Keyspace $KEYSPACE "
nodetool snapshot -t $DATE-$KEYSPACE $KEYSPACE
echo "Snaphot tar archives stored in Location : $Backup_Location"
tar czf $Backup_Location/$DATE-$KEYSPACE.tgz $DataDir__Location/$DATE-$KEYSPACE.tgz
            ;;

        "CompleteKeyspace")
#Take a snapshot of all keyspaces on the node
echo " For taking snapshot of all Keyspace,Press Enter: "
cqlsh `hostname -I` -e 'DESCRIBE KEYSPACES' > /tmp/mykeyspace.cql
for Keyspace in `grep -v 'OpsCenter' /tmp/mykeyspace.cql`; do
    nodetool snapshot -t $DATE-$Keyspace $Keyspace
    echo "Snaphot tar archives stored in Location : $Backup_Location"
    tar -cvzf $Backup_Location/$DATE-$Keyspace.tgz $DataDir__Location/$DATE-$Keyspace    
            ;;
            
        "Quit")
            break
            ;;            
