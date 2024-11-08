.PHONY: build build-vmware clean upload cilocal setup-vmware

build:
	./scripts/build_box_virtualbox.sh

build-vmware:
	./scripts/build_box_vmware.sh

setup-vmware:
	./scripts/setup_vmware.sh

clean:
	rm -rf ./vmware_desktop ./virtualbox

upload:
	./scripts/upload_artifact.sh

cilocal: clean build upload
