#!/usr/bin/env bash
set -e

VMWARE_VERSION=${VMWARE_VERSION:="17.6.1"}
VMWARE_BUILD=${VMWARE_BUILD:-"24319023"}
VAGRANT_VMWARE_UTILITY_VERSION=${VAGRANT_VMWARE_UTILITY_VERSION:-"1.0.23"}
USE_VAGRANT=${USE_VAGRANT:-"false"}

sudo apt-get update
sudo apt-get install -y software-properties-common wget build-essential libxcb-render0 libpcsclite1 libxcb-shm0 libaio1 libxi6 libxinerama1 libxcursor1 libxtst6
wget -q "https://softwareupdate.vmware.com/cds/vmw-desktop/ws/${VMWARE_VERSION}/${VMWARE_BUILD}/linux/core/VMware-Workstation-${VMWARE_VERSION}-${VMWARE_BUILD}.x86_64.bundle.tar"
tar xf "VMware-Workstation-${VMWARE_VERSION}-${VMWARE_BUILD}.x86_64.bundle.tar"
sudo bash "VMware-Workstation-${VMWARE_VERSION}-${VMWARE_BUILD}.x86_64.bundle" --console --eulas-agreed --required
if [[ "$USE_VAGRANT" == "true" ]]; then
    wget -q "https://releases.hashicorp.com/vagrant-vmware-utility/${VAGRANT_VMWARE_UTILITY_VERSION}/vagrant-vmware-utility_${VAGRANT_VMWARE_UTILITY_VERSION}-1_amd64.deb"
    sudo dpkg -i "vagrant-vmware-utility_${VAGRANT_VMWARE_UTILITY_VERSION}-1_amd64.deb"
    sudo systemctl restart vagrant-vmware-utility
fi
sudo vmware-modconfig --console --install-all
sudo touch /etc/vmware/license-ws-foo
mkdir -p "$HOME/.vmware"
echo "pref.wspro.firstRunDismissedVersion = \"${VMWARE_VERSION}\"" > "$HOME/.vmware/preferences"
chmod 600 "$HOME/.vmware/preferences"
cat "$HOME/.vmware/preferences"
vagrant --version
packer --version
vmware --version
