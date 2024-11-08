#!/usr/bin/env bash
set -e

packer init ./vagrant.pkr.hcl
packer validate ./vagrant.pkr.hcl
packer build \
    -color=false \
    -on-error=abort \
    ./vagrant.pkr.hcl
