packer {
  required_plugins {
    vagrant = {
      version = "~> 1"
      source = "github.com/hashicorp/vagrant"
    }
  }
}

source "vagrant" "box" {
  source_path       = "ssplatt/rocky9"
  output_dir        = "./virtualbox/"
  communicator      = "ssh"
  provider          = "virtualbox"
  template          = "Vagrantfile.template"
}

build {
  sources = ["source.vagrant.box"]
  provisioner "shell" {
    script            = "provision.sh"
  }
}
