#!/usr/bin/env bash
set -e

USE_VAGRANT=${USE_VAGRANT:-"false"}
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )/"
PROJECT_ROOT="$(dirname "$DIR")"

vagrant plugin install vagrant-vmware-desktop

if [[ "$USE_VAGRANT" == "true" ]]; then
    packer init ./vagrant-vmware.pkr.hcl
    packer validate ./vagrant-vmware.pkr.hcl
    packer build \
        -color=false \
        -on-error=abort \
        ./vagrant-vmware.pkr.hcl
else
    if [[ ! -d "$HOME/.vagrant.d/boxes/ssplatt-VAGRANTSLASH-centos-stream-9" ]]; then
        vagrant box add ssplatt/centos-stream-9 --no-tty --provider vmware_desktop
    else
        vagrant box update --box ssplatt/centos-stream-9 --provider vmware_desktop
    fi
    vmx_file=$(find "$HOME/.vagrant.d/boxes/" -type f -name "*.vmx")
    packer init -var "vmx_path=$vmx_file" ./vmware.pkr.hcl
    packer validate -var "vmx_path=$vmx_file" ./vmware.pkr.hcl
    packer build \
        -color=false \
        -on-error=abort \
        -var "vmx_path=$vmx_file" \
        ./vmware.pkr.hcl

    cd ./vmware_desktop
    ls -lah

    rm -rf ./*.lck
    rm -rf ./*.scoreboard
    rm -rf ./*.log
    rm -rf ./*.box
    if [[ "$(uname -o)" == "Darwin" ]]; then
        vmwarevdiskmanager="/Applications/VMware Fusion.app/Contents/Library/vmware-vdiskmanager"
    else
        vmwarevdiskmanager=$(which vmware-vdiskmanager)
    fi
    $vmwarevdiskmanager -d ./*.vmdk
    $vmwarevdiskmanager -k ./*.vmdk

    bash "$PROJECT_ROOT"/scripts/add_metadata.sh

    tar cvzf ../centos9stream.box ./*
fi
