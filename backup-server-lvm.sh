#!/bin/bash

NOOUT=`&>/dev/null`

# For Debug uncomment this
#NOOUT="&>/dev/null" && DEBUG="echo -e \t$time "

usage() {
  echo -e "usage: ${0} SSH_HOSTNAME VM_NAME [TARGET]\n"
  echo -e "\tSSH_HOSTNAME:\tName des zu sichernden Linux Servers"
  echo -e "\tVM_NAME:\tName der zu sichernden VirtualBox VM"
  echo -e "\t[TARGET]:\tZiel in dem die Datensicherung gespeichert wird.\n\t\t\tDefault: /cygdrive/e/\$VM_NAME"
}

error() {
  echo -e "\n$1\n"
  usage
  exit 1
}

echoer() {
  [ -z $DEBUG ] && (
    echo -e $1
  )
}

# Parameter prÃ¼fungen
[ -z $1 ] && error "SSH_HOSTNAME fehlt (z.B. linux01)!\n" || SSH_HOSTNAME=$1

[ -z $2 ] && error "VM_NAME fehlt (z.B. server-0)!\n" || VM_NAME=$2

# Benutzername@Hostname zusammensetzen
USER_HOSTNAME="root@$SSH_HOSTNAME"
# SSH Befehl zusammenbauen
SSH="ssh $USER_HOSTNAME"


# parameter2 ist das Ziel in dem die Datensicherung gespeichert wird
[ -z $3 ] && TARGET=/cygdrive/e || TARGET=$3

# Test LVM Snapshot
echo -e "\nSystemprüfungen:"
$DEBUG $SSH lvs|grep vms-snap
[ $? -eq 0 ] && error "LVM Snapshot existiert bereits! Bitte Admin bescheid geben."


cat <<EOL

  Backup Skript
  =================
  Für die tägliche Datensicherung der Virtuellen Maschinen,
  von einem laufenden Windows 7 aus.

  Dieses Skript erstellt einen LVM Snapshot auf dem als erster Parameter 
  übergebenen Rechner. Anschließend wird auf diesem Rechner die 
  VM Partition gemountet und die als zweiter Parameter übergebene VM 
  mit RSYNC gesichert.

EOL



echo -e "\nCreate LVM Snapshot ..."
$DEBUG $SSH "lvcreate -s /dev/vg00/vms -L16GB -n vms-snap"

echo -e "\nMount LVM Snapshot ..."
$DEBUG $SSH "mount /dev/vg00/vms-snap /mnt/backups/"

echo -e "\nMove old backups ..."
$DEBUG rm -rf $TARGET/$VM_NAME.3         $NOOUT
$DEBUG mv $TARGET/$VM_NAME.2 $TARGET/$VM_NAME.3   $NOOUT
$DEBUG mv $TARGET/$VM_NAME.1 $TARGET/$VM_NAME.2   $NOOUT
$DEBUG cp -al $TARGET/$VM_NAME $TARGET/$VM_NAME.1 $NOOUT
$DEBUG rsync -av --progress  $USER_HOSTNAME:/mnt/backups/$VM_NAME $TARGET

echo -e "\nUmount LVM Snapshot ..."
$DEBUG $SSH "umount /mnt/backups/"

echo -e "\nRemove LVM Snapshot ..."
$DEBUG $SSH "lvremove -f /dev/vg00/vms-snap"



