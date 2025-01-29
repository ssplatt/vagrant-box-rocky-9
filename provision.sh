#!/usr/bin/env bash
set -e

VIRTUALBOX=${VIRTUALBOX:-"false"}

echo ":::: Running as user $(whoami) ... "
id
echo ":::: Home dir: $HOME ..."

sestatus=$(sudo getenforce)
echo "$sestatus"
if [[ "$sestatus" != "Disabled" ]]; then
    sudo setenforce 0
    sudo sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
fi

sudo systemctl stop firewalld
sudo systemctl disable firewalld

sudo systemctl enable tmp.mount
sudo dnf install -y \
    epel-release \
    elrepo-release
sudo dnf upgrade -y
sudo dnf groupinstall -y GNOME
sudo dnf install -y \
    bzip2 \
    tar \
    firefox \
    cloud-utils-growpart \
    vim \
    wget \
    htop \
    telnet \
    gcc \
    make \
    perl \
    kernel-devel \
    kernel-headers \
    autoconf \
    unzip \
    socat \
    net-tools \
    python3 \
    python3-devel \
    git \
    zlib \
    bzip2-devel \
    ncurses-devel \
    libffi-devel \
    readline-devel \
    openssl-devel \
    sqlite-devel \
    xz-devel \
    zlib-devel \
    nfs-utils \
    cifs-utils\
    dnf-automatic

sudo sed -i 's/apply_updates = no/apply_updates = yes/' /etc/dnf/automatic.conf
sudo systemctl enable --now dnf-automatic.timer

if [[ ! -s /etc/sudoers.d/vagrant ]]; then
    sudo bash -c "cat > /etc/sudoers.d/vagrant" <<EOL
Defaults:vagrant !requiretty
%vagrant ALL=(ALL) NOPASSWD: ALL
EOL
fi

sudo sed -E -i 's/^#UseDNS no/UseDNS yes/' /etc/ssh/sshd_config
sudo sed -E -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

arch=$(uname -m)
if [[ "$arch" == "x86_64" ]]; then
    wget "https://dl.google.com/linux/direct/google-chrome-stable_current_${arch}.rpm"
    sudo dnf install -y "google-chrome-stable_current_${arch}.rpm"
    sudo rm -f "google-chrome-stable_current_${arch}.rpm"
else
    sudo dnf install -y chromium
fi

if [[ ! -s /home/vagrant/.ssh/authorized_keys ]]; then
    mkdir -p /home/vagrant/.ssh
    wget https://raw.githubusercontent.com/hashicorp/vagrant/refs/heads/main/keys/vagrant.pub -O /home/vagrant/.ssh/authorized_keys
    chmod 700 /home/vagrant/.ssh
    chmod 600 /home/vagrant/.ssh/authorized_keys
    chown -R vagrant:vagrant /home/vagrant/.ssh
fi
if [[ "$VIRTUALBOX" == "true" ]]; then
    sudo dnf install -y virtualbox-guest-additions || true
    sudo systemctl enable vboxservice || true
    sudo /sbin/rcvboxadd quicksetup all || true
else
    ## assume vmware
    sudo dnf install -y open-vm-tools-desktop
fi

sudo systemctl set-default graphical

sudo dnf remove -y \
    kernel-devel \
    kernel-headers
sudo dnf clean all
sudo dnf remove -y --oldinstallonly || true

sudo depmod -a
