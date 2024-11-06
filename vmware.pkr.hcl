packer {
  required_plugins {
    vmware = {
      version = "~> 1"
      source = "github.com/hashicorp/vmware"
    }
  }
}

variable "vmx_path" { 
  type = string
  default = "/home/runner/.vagrant.d/boxes/bento-VAGRANTSLASH-centos-stream-9/202407.23.0/vmware_desktop/centos-stream-9-amd64.vmx"
}

source "vmware-vmx" "box" {
  source_path       = "${var.vmx_path}"
  output_directory  = "./vmware_desktop/"
  communicator      = "ssh"
  ssh_username      = "vagrant"
  ssh_password      = "vagrant"
  ssh_timeout       = "20m"
  shutdown_command  = "sudo shutdown -h now"
  format            = "vmx"
  headless          = "true"
  vmx_data = {
    "ethernet0.addresstype" = "generated"
    "ethernet0.connectiontype" = "nat"
    "ethernet0.linkstatepropagation.enable" = "TRUE"
    "ethernet0.pcislotnumber" = "160"
    "ethernet0.present" = "TRUE"
    "ethernet0.virtualdev" = "vmxnet3"
  }
}

build {
  sources = ["source.vmware-vmx.box"]
  provisioner "shell" {
    script            = "provision.sh"
  }
}
