# Project Configuration

In order to setup WiFi(s) add the following section

```
raspbian_headless:
  authorized_keys:
    - wojtek
  networks:
    - ssid: '"my-wifi-sid"'
      scan_ssid: 1
      key_mgmt: WPA-PSK
      psk: '"my-wifi-secret-password"'
      proto: RSN
      pairwise: CCMP TKIP
      group: CCMP TKIP
```
