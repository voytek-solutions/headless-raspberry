include .make

ID ?=
IMG_URL = https://downloads.raspberrypi.org/raspbian_lite_latest
PWD = $(shell pwd)
ROLE ?=

PATH := $(PWD)/.venv/bin:$(PWD)/bin:$(shell printenv PATH)
SHELL := env PATH=$(PATH) /bin/bash

export ANSIBLE_CONFIG=$(PWD)/ansible/ansible.cfg
export RPI_ID=$(ID)

## Install local dependencies
#
# make deps
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

## Clean temporary and build files
clean:
	rm img/raspbian.img

.make:
	echo '' > .make
