#we need to allow TUN to our lxc container
#here you need to put your lxc container ID, in this case mine is 120
echo 'lxc.cgroup.devices.allow: c 10:200 rwm' >> /etc/pve/lxc/120.conf
echo 'lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file' >> /etc/pve/lxc/120.conf