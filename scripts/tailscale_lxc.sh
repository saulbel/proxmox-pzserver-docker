#install curl and tailscale
apt update
apt install curl -y
curl -fsSL https://tailscale.com/install.sh | sh

#enable forwarding in lxc container
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
reboot