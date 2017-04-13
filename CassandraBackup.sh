#!/bin/bash
# Created by Sreeraju.V

DATE=`date +%Y-%m-%d`
Backup_Location=/mnt/cassandra/backup
DataDir_Location=/mnt/cassandra/data/*/*/snapshots
IP=`ip addr | grep 'state UP' -A2 | tail -n1 | awk '{print $2}' | cut -f1  -d'/'`

echo " For taking snapshot of specified keyspace,Enter Keyspace name: "
read KEYSPACE
options=("Table" "Keyspace" "CompleteKeyspace" "S3 Upload" "Clear Snapshot" "Quit")
select opt in "${options[@]}"
do
    case $opt in

        "Table")
#Take a snapshot of Specified Table on the node
echo " Enter Table Name: "
read TABLE
echo " Taking Backup of Table $table in Keyspace $KEYSPACE "
nodetool flush
nodetool snapshot -t $KEYSPACE-$TABLE-$DATE --table $TABLE $KEYSPACE
echo "Snaphot tar archives stored in Location : $Backup_Location"
tar czf $Backup_Location/$KEYSPACE-$DATE.tgz $DataDir_Location/$KEYSPACE-$TABLE-$DATE.tgz
            ;;

        "Keyspace")
#Take a snapshot of Specified keyspaces on the node
echo " Taking Backup of Keyspace $KEYSPACE "
nodetool flush
nodetool snapshot -t $KEYSPACE-$DATE $KEYSPACE
echo "Snaphot tar archives stored in Location : $Backup_Location"
tar czf $Backup_Location/$KEYSPACE-$DATE.tgz $DataDir_Location/$KEYSPACE-$DATE.tgz
            ;;

        "CompleteKeyspace")
#Take a snapshot of all keyspaces on the node
echo " For taking snapshot of all Keyspace,Press Enter: "
cqlsh `hostname -I` -e 'DESCRIBE KEYSPACES' > /tmp/mykeyspace.cql
for Keyspace in `grep -v 'OpsCenter' /tmp/mykeyspace.cql`; do
    nodetool flush
    nodetool snapshot -t $KEYSPACE-$DATE $Keyspace
    echo "Snaphot tar archives stored in Location : $Backup_Location"
    tar -cvzf $Backup_Location/$KEYSPACE-$DATE.tgz $DataDir_Location/$KEYSPACE-$DATE
            ;;

        "S3 Upload")
#Upload Archived to S3 Bucket
echo "Enter S3 Bucket Name :"
read S3Bucket
echo "Uploading Snaphshot Archive file to S3 Bucket : $S3Bucket"
aws s3 cp $Backup_Location/$KEYSPACE-$DATE.tgz  s3://$S3Bucket/
             ;;

        "Clear Snapshot")
#Clear all snapshot from Disk
echo "Clearing all Snapshot taken in Disk"
nodetool clearsnapshot
             ;;

        "Quit")
            break
            ;;
