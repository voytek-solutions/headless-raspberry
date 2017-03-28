include .make

ID ?=
IMG_URL = https://downloads.raspberrypi.org/raspbian_lite_latest
PI_MODEL = 0w
PWD = $(shell pwd)
ROLE ?=

PATH := $(PWD)/.venv/bin:$(PWD)/bin:$(shell printenv PATH)
SHELL := env PATH=$(PATH) /bin/bash

export ANSIBLE_CONFIG=$(PWD)/ansible/ansible.cfg
export RPI_ID=$(ID)

.DEFAULT_GOAL := help

## Install local python and git dependencies
deps: .venv deps_git

## Installs a virtual environment and all python dependencies
.venv:
	virtualenv .venv
	.venv/bin/pip install -U "pip<9.0"
	.venv/bin/pip install pyopenssl urllib3[secure] requests[security]
	.venv/bin/pip install -r requirements.txt --ignore-installed
	virtualenv --relocatable .venv

## Setup git
deps_git:
	git config --local include.path ../.git-local/config
	ln -sf $(PWD)/.git-local/hooks/commit-msg $(PWD)/.git/hooks/commit-msg
	chmod +x .git/hooks/commit-msg
	ln -sf $(PWD)/.git-local/hooks/prepare-commit-msg $(PWD)/.git/hooks/prepare-commit-msg
	chmod +x .git/hooks/prepare-commit-msg

## Download rasbian image
img/raspbian.img:
	download_image $(IMG_URL)

## Build your Raspberry Pi
build:
	vagrant up --no-provision
	vagrant provision

## Runs playbooks
playbook:
	ansible-playbook \
		--inventory ansible/inventory/pis \
		-e hosts=all \
		ansible/playbooks/mpd.yml

## Generates random hostname for your pi
# Usage:
#   make new_hostname
#   make new_hostname PI_MODEL=3b
new_hostname:
	@echo "rpi-$(PI_MODEL)-"$$(head -c24 /dev/urandom | md5 | head -c7)

## Deletes temporary and build files
clean:
	rm img/raspbian.img
	find . -name "*.retry" | xargs rm
	rm -rf .venv

## Print this help
help:
	@awk -v skip=1 \
		'/^##/ { sub(/^[#[:blank:]]*/, "", $$0); doc_h=$$0; doc=""; skip=0; next } \
		 skip  { next } \
		 /^# /  { doc=doc "\n" substr($$0, 3); next } \
		 /:/   { sub(/:.*/, "", $$0); printf "\033[34m%-30s\033[0m\033[1m%s\033[0m %s\n\n", $$0, doc_h, doc; skip=1 }' \
		$(MAKEFILE_LIST)

.make:
	echo '' > .make
