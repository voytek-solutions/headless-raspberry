include .make

ID ?= $(PROJECT)
IMG_URL = https://downloads.raspberrypi.org/raspbian_lite_latest
PROJECT ?=
PWD = $(shell pwd)
ROLE ?=

PATH := $(PWD)/.venv/bin:$(PWD)/bin:$(shell printenv PATH)
SHELL := env PATH=$(PATH) /bin/bash

export ANSIBLE_CONFIG=$(PWD)/ansible/ansible.cfg
export RPI_ID=$(ID)
export PROJECT

## Prints this help
help:
	@awk -v skip=1 \
		'/^##/ { sub(/^[#[:blank:]]*/, "", $$0); doc_h=$$0; doc=""; skip=0; next } \
		 skip  { next } \
		 /^#/  { doc=doc "\n" substr($$0, 2); next } \
		 /:/   { sub(/:.*/, "", $$0); printf "\033[34m%-30s\033[0m\033[1m%s\033[0m %s\n\n", $$0, doc_h, doc; skip=1 }' \
		$(MAKEFILE_LIST)

## Initialise project
# Installs required dependencies
#
# Usage:    make init
init: .venv deps_git

## Download rasbian image
# Usage:    make img/raspbian.img
#           make img/raspbian.img IMG_URL=https://downloads.raspberrypi.org/raspbian_latest
img/raspbian.img:
	mkdir -p img
	download_image $(IMG_URL)

img/rpi-$(ID)-raspbian.img: img/raspbian.img
	cp img/raspbian.img img/rpi-$(ID)-raspbian.img

## Build your Raspberry Pi
# Usage:    make build PROJECT=blink
#        or build two images, each with different hostname
#           make build PROJECT=blink ID=blink01
#           make build PROJECT=blink ID=blink02
build: .venv img/rpi-$(ID)-raspbian.img
	vagrant up --no-provision
	vagrant provision
	vagrant halt

## Clean temporary and build files
clean:
	rm -rf img
	rm -rf .venv

# Installs a virtual environment and all python dependencies
.venv:
	virtualenv .venv
	.venv/bin/pip install -U "pip<9.0"
	.venv/bin/pip install pyopenssl urllib3[secure] requests[security]
	.venv/bin/pip install -r requirements.txt --ignore-installed
	virtualenv --relocatable .venv

# Setup local git configuration
deps_git:
	git config --local include.path ../.git-local/config
	ln -sf $(PWD)/.git-local/hooks/commit-msg $(PWD)/.git/hooks/commit-msg
	chmod +x .git/hooks/commit-msg
	ln -sf $(PWD)/.git-local/hooks/prepare-commit-msg $(PWD)/.git/hooks/prepare-commit-msg
	chmod +x .git/hooks/prepare-commit-msg

# creates empty .make file
.make:
	touch .make
