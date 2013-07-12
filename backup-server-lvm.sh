#!/bin/bash

NOOUT=`&>/dev/null`

# For Debug uncomment this
#NOOUT="&>/dev/null" && DEBUG="echo -e \t$time "

usage() {
  echo -e "usage: ${0} VM_NAME [TARGET]\n"
  echo -e "\tVM_NAME:\tName der zu sichernden VirtualBox VM"
  echo -e "\t[TARGET]:\tZiel in dem die Datensicherung gespeichert wird.\n\t\t\tDefault: /cygdrive/e/\$VM_NAME"
}

# Helper function
error() {
  echo -e "\n$1\n"
  usage
  exit 1
}

# Helper function
# if DEBUG is true, echo all comands
echoer() {
  [ -z $DEBUG ] && (
    echo -e $1
  )
}

# Parameter pr√ºfungen
[ -z $1 ] && error "VM_NAME fehlt (z.B. server-0)!\n" || VM_NAME=$1


# parameter2 ist das Ziel in dem die Datensicherung gespeichert wird
[ -z $2 ] && TARGET=/cygdrive/e || TARGET=$2

cat <<EOL

  Backup Skript
  =================
  F¸r die t‰gliche Datensicherung der Virtuellen Maschinen,

  Dieses Skript ist zur Verwendung in cron Tasks auf den Linux
  Systemen gedach.

EOL


# create 16GB Snapshot from VM store
echo -e "\nCreate LVM Snapshot ..."
$DEBUG "lvcreate -s /dev/vg00/vms -L16GB -n vms-snap"


echo -e "\nMount LVM Snapshot ..."
if [ ! -d /mnt/snapshot ]; then mkdir /mnt/snapshot; fi
$DEBUG "mount /dev/vg00/vms-snap /mnt/snapshot/"

echo -e "\nMove old backups ..."
$DEBUG rm -rf $TARGET/$VM_NAME.3         $NOOUT
$DEBUG mv $TARGET/$VM_NAME.2 $TARGET/$VM_NAME.3   $NOOUT
$DEBUG mv $TARGET/$VM_NAME.1 $TARGET/$VM_NAME.2   $NOOUT
$DEBUG cp -al $TARGET/$VM_NAME $TARGET/$VM_NAME.1 $NOOUT
$DEBUG rsync -av --progress /mnt/snapshot/$VM_NAME $TARGET

echo -e "\nUmount LVM Snapshot ..."
$DEBUG "umount /mnt/backups/"

echo -e "\nRemove LVM Snapshot ..."
$DEBUG "lvremove -f /dev/vg00/vms-snap"



