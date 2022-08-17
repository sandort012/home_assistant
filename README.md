# home_assistant

Start MQTT process
```
./mqtt.sh &>/dev/null &
```
Check if process started
```
ps | grep mqtt
```
Example of a started service:
```
root@OpenWrt:/# ps | grep mqtt
16660 root      1276 S    /bin/sh ./mqtt.sh

```