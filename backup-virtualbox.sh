#!/bin/bash

cat <<EOF >>/dev/null

Backupscript für Virtualbox getreibene Systeme im SOHO Bereich.

EOF

echo -e "Start backup at: `date +%F`"

BACKUPDIR=/media/Elements
BACKUPNAME="GLT-Server-Hauser-Paulinenstr"


# Test des Backup Laufwerks und Alternative
mountpoint "${BACKUPDIR}"
if [ $? -ne 0 ]; then
	mount /dev/sdb1 /mnt/backup
	BACKUPDIR=/mnt/backup
fi

echo -e "Sicherung der alten Datensicherungen ...\n"
[ -d "${BACKUPDIR}/${BACKUPNAME}.3" ] && rm -rf "${BACKUPDIR}/${BACKUPNAME}.3"
[ -d "${BACKUPDIR}/${BACKUPNAME}.2" ] && mv -v  "${BACKUPDIR}/${BACKUPNAME}.2/" "${BACKUPDIR}/${BACKUPNAME}.3"
[ -d "${BACKUPDIR}/${BACKUPNAME}.1" ] && mv -v  "${BACKUPDIR}/${BACKUPNAME}.1/" "${BACKUPDIR}/${BACKUPNAME}.2"
[ -d "${BACKUPDIR}/${BACKUPNAME}" ] && rsync -av "${BACKUPDIR}/${BACKUPNAME}/"   "${BACKUPDIR}/${BACKUPNAME}.1"

echo -e "Create Snapshot ...\n"
lvcreate -s /dev/vgsystem/vms -L20GB -n vms-snapshot

echo -e "Mount Snapshot ...\n"
mount /dev/vgsystem/vms-snapshot /mnt/vms-snapshot

echo -e "Sichere Virtualbox Verzeichnis ...\n"
rsync -av /mnt/vms-snapshot ${BACKUPDIR}/${BACKUPNAME}

echo -e "Snapshot unmounten ...\n"
sleep 10
umount /dev/vgsystem/vms-snapshot

echo -e "Remove Snapshot ...\n"
while true; do
  lvremove -f /dev/vgsystem/vms-snapshot
  if [ $? -ne 0 ]; then
    echo -e "Snapshot not removed, try again!"
    umount /dev/vgsystem/vms-snapshot
    lvremove -f /dev/vgsystem/vms-snapshot
    if [ $? -eq 0]; then break; fi
    sleep 2
  else
    break
  fi
done


echo -e "Berechtigung korregieren."
chmod 777 "${BACKUPDIR}" -R


