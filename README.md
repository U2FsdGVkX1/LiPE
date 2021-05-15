# LiPE
Boot the temporary Linux OS based Tiny Core Linux to a VPS for easy maintenance, backup and reinstallation!

How To
------

Just run the command with root privileges.

```
curl https://raw.githubusercontent.com/U2FsdGVkX1/LiPE/main/LiPE.sh | bash
```

Then sit and relax, connect to your server after about 3 minutes.

```
# The default password is 12345678
ssh tc@your-server-ip

# You can directly use cfdisk to modify your partition
lsblk
sudo cfdisk /dev/vda
```

Since it booted only once, you can just restart your VPS to rollback it when the server is not reachable.

Kernel Parameters
-----------------

If you want to know more parameters, open the /boot/grub/custom.cfg file (it would be "grub2" instead of "grub" in some Linux distro)

```
menuentry 'LiPE' {
  search --no-floppy --fs-uuid --set=root xxxxxxx
  linux /boot/vmlinuz-lipe password=12345678
  initrd /boot/initrd-lipe.gz
}
```

You can change the LiPE default password

If your VPS is not reachable, you can also use hostip, netmask, gateway, nameserver parameters, like this…

```
menuentry 'LiPE' {
  search --no-floppy --fs-uuid --set=root xxxxxxx
  linux /boot/vmlinuz-lipe password=123456abc hostip=156.251.130.42 netmask=255.255.255.128 gateway=156.251.130.1 nameserver=8.8.8.8
  initrd /boot/initrd-lipe.gz
}
```

Uninstall
---------

Delete the following files

```
rm -rf /boot/vmlinuz-lipe /boot/initrd-lipe.gz /boot/grub/custom.cfg
```
