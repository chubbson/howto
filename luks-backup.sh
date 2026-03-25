#!/bin/bash
# P14s G5 System Backup Script
# Run as root: sudo bash ~/luks-backup.sh
# To find USB PARTUUID: sudo blkid /dev/sda1

DATE=$(date +%Y%m%d_%H%M%S)
BASE_DIR="/mnt/backup/p14sg5"
BACKUP_DIR="$BASE_DIR/$DATE"

echo "Starting backup..."

# Mount backup USB if not mounted
mkdir -p /mnt/backup
mount /dev/disk/by-partuuid/bd09407f-01 /mnt/backup

# Create timestamped folder
mkdir -p $BACKUP_DIR

# LUKS header
echo "Backing up LUKS header..."
cryptsetup luksHeaderBackup /dev/nvme0n1p3 \
    --header-backup-file $BACKUP_DIR/luks-header-backup.img

# Partition table
echo "Backing up partition table..."
sfdisk -d /dev/nvme0n1 | tee $BACKUP_DIR/partition-table-backup.sfdisk

# LVM config
echo "Backing up LVM config..."
vgcfgbackup -f $BACKUP_DIR/lvm-backup.cfg vg0

# System configs
echo "Backing up system configs..."
cp /etc/crypttab $BACKUP_DIR/crypttab-backup
cp /etc/fstab $BACKUP_DIR/fstab-backup
cp /etc/mkinitcpio.conf $BACKUP_DIR/mkinitcpio-backup
cp /etc/default/grub $BACKUP_DIR/grub-backup
cp /etc/modprobe.d/nvidia.conf $BACKUP_DIR/modprobe-nvidia-backup

# Secure Boot keys
echo "Backing up Secure Boot keys..."                                                                                                                                                       
cp -r /var/lib/sbctl/keys $BACKUP_DIR/secureboot-keys                                                                                                                                
                                                                                                                                                                                              
# GRUB generated config                                                                                                                                                                     
echo "Backing up GRUB generated config..."
cp /boot/grub/grub.cfg $BACKUP_DIR/grub-cfg-backup                                                                                                                                          
                                                                                                                                                                                              
# Snapper configs                                                                                                                                                                           
echo "Backing up Snapper configs..."                                                                                                                                                        
cp -r /etc/snapper/configs $BACKUP_DIR/snapper-configs

# This script
cp /home/me/luks-backup.sh $BACKUP_DIR/luks-backup.sh

echo "Done! Backup saved to $BACKUP_DIR"
ls -lh $BACKUP_DIR/

# Unmount
umount /mnt/backup
echo "USB unmounted safely."
