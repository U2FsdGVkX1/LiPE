#!/bin/sh

network="eth0"
hostip=
netmask=

install() {
    su tc -c "tce-load -wi $@"
}

parse_parameter() {
    for x in $(cat /proc/cmdline); do
        key=`echo $x | cut -d'=' -f1`
        value=`echo $x | cut -d'=' -f2`
        case "$key" in
            password)
            echo "tc:$value" | chpasswd
            ;;
            hostip)
            hostip=$value
            ;;
            netmask)
            netmask=$value
            ;;
            gateway)
            route add default gw $value $network
            ;;
            nameserver)
            echo "nameserver $value" > /etc/resolv.conf
            ;;
        esac
    done
}

configure_network() {
    if [ -n "$hostip" ]; then
        ifconfig $network $hostip netmask $netmask
        ifconfig $network up
    fi
    ping -c 8 1.1.1.1
}

install_openssh() {
    install openssh
    cp /usr/local/etc/ssh/sshd_config.orig /usr/local/etc/ssh/sshd_config
}

install_tools() {
    install e2fsprogs
    install dosfstools
    install grub2-multi
    install util-linux
}

parse_parameter
configure_network
install_tools
install_openssh
/usr/local/etc/init.d/openssh start