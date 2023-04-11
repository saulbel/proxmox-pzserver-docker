# proxmox-pzserver-docker

## Prerequisites
Things you need before starting:
* `Proxmox server`
* `Terraform`
* `Ansible`
* `Tailscale`

## Project structure
```
proxmox-pzserver-docker
└── ansible-playbooks
     └── install-docker.yaml
     └── install-and-configure-ufw.yaml
└── scripts
     └── allow_tun_access.sh
     └── tailscale_lxc.sh
└── terraform
     └── main.tf
     └── secrets.auto.tfvars
```
## Tasks to accomplish
- The idea of this project is to use `terraform/ansible` to deploy and configure a `lxc` container, create a `project zomboid` on it using `docker` and share it with our friends easily using `tailscale`.

## How to setup this project locally
- First we should download it with either `git clone` or as `.zip`.
- Then you will have to modify `secrets.auto.tfvars` and `main.tf` with your `proxmox` data. 

## Step 1: create the lxc container using terraform
- Once you have everything ready, we just have to initialize `terraform`:
````
$ terraform init
````
- Then to check if our config is valid and what it will do:
````
$ terraform plan
````
- Finally we can create our `lxc` container:
````
$ terraform apply
````

## Step 2: configure our lxc container
- Here comes the tricky part. You may wonder why are we using a `lxc` container instead of a `vm`. As you might guess, it is all about optimizing resources of our `proxmox` server. 
- So in order to make it work, we need to give our `lxc` container access to `TUN` interface. Here we can either execute the script `allow_tun_access.sh` in our `proxmox` server or do it manually. You will have to modify it with your `lxc` container id.
````
root@pve1:~# echo 'lxc.cgroup.devices.allow: c 10:200 rwm' >> /etc/pve/lxc/120.conf
root@pve1:~# echo 'lxc.mount.entry: /dev/net/tun dev/net/tun none bind,create=file' >> /etc/pve/lxc/120.conf
````
- After that, you will have to log in inside the `lxc` container and execute the script `tailscale_lxc.sh`. It will install `tailscale` and it will enable ip forwarding.
````
root@pzserver-1:~# ./tailscale_lxc.sh
````
- Then you will have to start `tailscale` and you will have to open the link it will provide. You will open it on a web browser in order to add it to the `tailscale` mesh.
````
root@pzserver-1:~# tailscale up
To authenticate, visit:
        https://login.tailscale.com/x/xxxxxxx
````

## Step 3: install and configure docker/networking with ansible
- Now we are gonna install `docker` and `docker-compose` using `ansible`. Remember that we have included the `ansible` ssh key in our lxc container so we just have to execute `install-docker.yaml`.
- Then we will have to open some ports for our `project zomboid` server. This time we are gonna use `ufw` which is a wrapper for `iptables`. Again, we will just have to execute `install-and-configure-ufw.yaml`.
````
$ ansible-playbook install-docker.yaml -i root@192.168.1.20,
$ ansible-playbook install-and-configure-ufw.yaml -i root@192.168.1.20,
````

## Step 4: configure project zomboid server using docker-compose
- For this step we are gonna use the following github [repo](https://github.com/Danixu/project-zomboid-server-docker).
- We will log in into our `lxc` container and then create a `docker-compose.yaml` file like the one in that repo.
- We will also need to create a `.env` file using `.env.template`. The only mandatory variable is the `ADMINPASSWORD` so change it.
- Finally we are ready to create our `project zomboid` server. How do we do it? Well it will be as simple as this:
````
root@pzserver-1:~# docker-compose up -d
````

## Step 5: how to connect to our project zomboid server and play with our friends
- First of all, if we just wanna play alone we can enter to our server with just our `lxc` local ip, in this case is `192.168.1.20`.
- How do we share our server with friends? Remember that we installed `tailscale` on our `lxc` container? Well if we go to the [tailscale](https://login.tailscale.com/admin/machines) webpage and we log in with our account, we can click on the three dots and share our machine with our friends. Your friends will need to download `tailscale` in their machines and then connect to the vpn profile. They will use the `tailscale ip` in order to connect to your server.

## Step 6: tinkering with project zomboid server config
- Now you will just have to configure your server as you please and install as many mods as you and your friends want.
- And finally the most important thing, hope you have fun building your own servers and of course, playing!