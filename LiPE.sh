#!/bin/bash

set -e

BOOTLOCAL="https://raw.githubusercontent.com/U2FsdGVkX1/LiPE/main/bootlocal.sh"
COREPURE_VERSION="$(curl -sSL "http://www.tinycorelinux.net/13.x/x86_64/release/" | \
                        tr -d '\r\n\t' |  grep -Po '(?<=>CorePure64-)[0-9]+(\.[0-9]+)+(?=\.iso\.md5\.txt<\/a>)' | \
                        sort -Vr | head -n 1)"
COREPURE="http://www.tinycorelinux.net/13.x/x86_64/release/CorePure64-${COREPURE_VERSION}.iso"
FILENAME=`basename $COREPURE`

[ $EUID -ne 0 ] && echo "This script must be run as root" && exit 1

if [ -e "/usr/bin/pacman" ]; then
    pacman -Syy --noconfirm wget gzip cpio
fi

rm -rf $FILENAME $FILENAME.md5.txt bootlocal.sh
wget $COREPURE && wget $COREPURE.md5.txt && wget $BOOTLOCAL
md5sum -c $FILENAME.md5.txt && chmod +x bootlocal.sh
[ $? != 0 ] && echo "Download failed!" && exit 1

mkdir -p TinyCore
mount -o ro "$FILENAME" TinyCore
[ $? != 0 ] && echo "Mount failed!" && exit 1

cp TinyCore/boot/vmlinuz64 vmlinuz-lipe && cp TinyCore/boot/corepure64.gz initrd-lipe.gz
umount TinyCore
cd TinyCore
zcat ../initrd-lipe.gz | cpio -i -H newc
[ $? != 0 ] && echo "Extracting failed!" && exit 1

mv ../bootlocal.sh opt
find . | cpio -o -H newc | gzip > ../initrd-lipe.gz
[ $? != 0 ] && echo "Archiving failed!" && exit 1

cd ..
rm -rf TinyCore $FILENAME $FILENAME.md5.txt
mv vmlinuz-lipe initrd-lipe.gz /boot
if [ -d /boot/grub2 ]; then
    grubreboot=grub2-reboot
    cfg=/boot/grub2/custom.cfg
elif [ -d /boot/grub ]; then
    grubreboot=grub-reboot
    cfg=/boot/grub/custom.cfg
else
    echo "Unable to find the GRUB directory!"
    exit 1
fi

dev=`df /boot | tail -1 | awk '{print $1}'`
mountpoint=`df /boot | tail -1 | awk '{print $NF}'`
uuid=`blkid -s UUID -o value $dev`
[ -z "$uuid" ] && echo "Unable to find the boot partition!" && exit 1
echo "menuentry 'LiPE' {
  search --no-floppy --fs-uuid --set=root $uuid
  linux /$(realpath --relative-to=$mountpoint /boot/vmlinuz-lipe) password=12345678
  initrd /$(realpath --relative-to=$mountpoint /boot/initrd-lipe.gz)
}
" > $cfg
$grubreboot LiPE
reboot
