# Headless Raspberry π

A way to build and configure your π0




## How It Works?

The process is very simple.

* Default Raspbian image is mounted inside Vagrant box, and configured for initial
  headless run which includes wifi and hostname setup.
* Insert SD card, and burn new image.
* Start π0 and continue with configuration - each image has unique hostname.

The plan is to simply run `make build ID=a8af184 ROLE=mpd`.




## Random Commands

```
# Get random PI hostname
make new_hostname
```

```
# Get IP of given pi
dig +short rpi-0w-c04202e @192.168.1.1
```
