#!/bin/sh

MQTTSERVER=192.168.1.100
MQTTUSER=mqttuser
MQTTPASS=mqttuser
PORT=1883
INTERVAL=10
DBG=false

[ -x /usr/bin/rrdtool ] || exit 0

name=$(cat /proc/cpuinfo | grep machine | awk -F ": " '{print $2}')

if $DBG; then
    echo $name
fi

send_config_data() {
#discover inbound traffic sensor
mosquitto_pub -h $MQTTSERVER -p $PORT -u $MQTTUSER -P $MQTTPASS -t "homeassistant/sensor/router/rxspeed/config" -m "{\
\"name\":\"rx_$name\"\
,\"state_topic\":\"router/status\"\
,\"icon\":\"mdi:download-network\",\"unit_of_measurement\":\"MB/s\",\"value_template\":\"{{ value_json.wan_rx }}\"\
,\"unique_id\":\"rx_$name\"\
}" -i "OpenWRT" -r
#discover outbound traffic sensor
mosquitto_pub -h $MQTTSERVER -p $PORT -u $MQTTUSER -P $MQTTPASS -t "homeassistant/sensor/router/txspeed/config" -m "{\
\"name\":\"tx_$name\"\
,\"state_topic\":\"router/status\"\
,\"icon\":\"mdi:upload-network\",\"unit_of_measurement\":\"MB/s\",\"value_template\":\"{{ value_json.wan_tx }}\"\
,\"unique_id\":\"tx_$name\"\
}" -i "OpenWRT" -r
#discover cpu sensor
mosquitto_pub -h $MQTTSERVER -p $PORT -u $MQTTUSER -P $MQTTPASS -t "homeassistant/sensor/router/cpu/config" -m "{\
\"name\":\"cpu_$name\"\
,\"state_topic\":\"router/status\"\
,\"icon\":\"mdi:cpu-32-bit\",\"unit_of_measurement\":\"%\",\"value_template\":\"{{ value_json.cpu }}\"\
,\"unique_id\":\"cpu_$name\"\
}" -i "OpenWRT" -r
#discover lan clients sensor
mosquitto_pub -h $MQTTSERVER -p $PORT -u $MQTTUSER -P $MQTTPASS -t "homeassistant/sensor/router/lanclients/config" -m "{\
\"name\":\"lan_clients_$name\"\
,\"state_topic\":\"router/status\"\
,\"icon\":\"mdi:account-network\",\"unit_of_measurement\":\"db\",\"value_template\":\"{{ value_json.lan_clients }}\"\
,\"unique_id\":\"lan_clients_$name\"\
}" -i "OpenWRT" -r
#discover wifi clients sensor
mosquitto_pub -h $MQTTSERVER -p $PORT -u $MQTTUSER -P $MQTTPASS -t "homeassistant/sensor/router/wificlients/config" -m "{\
\"name\":\"wifi_clients_$name\"\
,\"state_topic\":\"router/status\"\
,\"icon\":\"mdi:account-voice\",\"unit_of_measurement\":\"db\",\"value_template\":\"{{ value_json.wifi_clients }}\"\
,\"unique_id\":\"wifi_clients_$name\"\
}" -i "OpenWRT" -r
#discover wifi quality sensor
mosquitto_pub -h $MQTTSERVER -p $PORT -u $MQTTUSER -P $MQTTPASS -t "homeassistant/sensor/router/wifiquality/config" -m "{\
\"name\":\"wifi_quality_$name\"\
,\"state_topic\":\"router/status\"\
,\"icon\":\"mdi:wifi\",\"unit_of_measurement\":\"%\",\"value_template\":\"{{ value_json.wifi_quality }}\"\
,\"unique_id\":\"wifi_quality_$name\"\
}" -i "OpenWRT" -r
#discover memory free sensor
mosquitto_pub -h $MQTTSERVER -p $PORT -u $MQTTUSER -P $MQTTPASS -t "homeassistant/sensor/router/memoryfree/config" -m "{\
\"name\":\"memory_free_$name\"\
,\"state_topic\":\"router/status\"\
,\"icon\":\"mdi:memory\",\"unit_of_measurement\":\"MB\",\"value_template\":\"{{ value_json.memory_free }}\"\
,\"unique_id\":\"memory_free_$name\"\
}" -i "OpenWRT" -r
#discover memory buffered sensor
mosquitto_pub -h $MQTTSERVER -p $PORT -u $MQTTUSER -P $MQTTPASS -t "homeassistant/sensor/router/memorybuffered/config" -m "{\
\"name\":\"memory_buffered_$name\"\
,\"state_topic\":\"router/status\"\
,\"icon\":\"mdi:memory\",\"unit_of_measurement\":\"MB\",\"value_template\":\"{{ value_json.memory_buffered }}\"\
,\"unique_id\":\"memory_buffered_$name\"\
}" -i "OpenWRT" -r
#discover memory cached sensor
mosquitto_pub -h $MQTTSERVER -p $PORT -u $MQTTUSER -P $MQTTPASS -t "homeassistant/sensor/router/memorycached/config" -m "{\
\"name\":\"memory_cached_$name\"\
,\"state_topic\":\"router/status\"\
,\"icon\":\"mdi:memory\",\"unit_of_measurement\":\"MB\",\"value_template\":\"{{ value_json.memory_cached }}\"\
,\"unique_id\":\"memory_cached_$name\"\
}" -i "OpenWRT" -r
#discover memory used sensor
mosquitto_pub -h $MQTTSERVER -p $PORT -u $MQTTUSER -P $MQTTPASS -t "homeassistant/sensor/router/memoryused/config" -m "{\
\"name\":\"memory_used_$name\"\
,\"state_topic\":\"router/status\"\
,\"icon\":\"mdi:memory\",\"unit_of_measurement\":\"MB\",\"value_template\":\"{{ value_json.memory_used }}\"\
,\"unique_id\":\"memory_used_$name\"\
}" -i "OpenWRT" -r
}

make_mqtt_message() {
#WAN Speed
WAN_INFO=$(rrdtool fetch /tmp/rrd/OpenWrt/interface-wan/if_octets.rrd AVERAGE -s -30s | grep -v nan | tail -1)
WAN_RX=$(echo $WAN_INFO | awk '{printf("%.1f\n", $2/1048576)}')
WAN_TX=$(echo $WAN_INFO | awk '{printf("%.1f\n", $3/1048576)}')

#Time
TIME=$(echo $WAN_INFO | awk '{print strftime("%H:%M:%S", substr($1, 1, length($1)-1))}')

#Memory
MEMORY_FREE=$(rrdtool fetch /tmp/rrd/OpenWrt/memory/memory-free.rrd AVERAGE -s -30s | grep -v nan | tail -1 | awk '{printf("%.1f\n", $2/1048576)}')
MEMORY_BUFFERED=$(rrdtool fetch /tmp/rrd/OpenWrt/memory/memory-buffered.rrd AVERAGE -s -30s | grep -v nan | tail -1 | awk '{printf("%.1f\n", $2/1048576)}')
MEMORY_CACHED=$(rrdtool fetch /tmp/rrd/OpenWrt/memory/memory-cached.rrd AVERAGE -s -30s | grep -v nan | tail -1 | awk '{printf("%.1f\n", $2/1048576)}')
MEMORY_USED=$(rrdtool fetch /tmp/rrd/OpenWrt/memory/memory-used.rrd AVERAGE -s -30s | grep -v nan | tail -1 | awk '{printf("%.1f\n", $2/1048576)}')

#CPU
CPU=$(rrdtool fetch /tmp/rrd/OpenWrt/cpu/percent-active.rrd AVERAGE -s -30s | grep -v nan | tail -1 | awk '{printf("%.1f\n", $2)}')

#WIFI
WLAN_CLIENTS=0
WLAN_QUALITY=0
COUNTER=0
for interface in `iwinfo | grep ESSID | cut -f 1 -s -d" "`
do
  WLAN_CLIENTS=$(($(rrdtool fetch /tmp/rrd/OpenWrt/iwinfo-$interface/stations.rrd AVERAGE -s -30s | grep -v nan | tail -1 | awk '{printf("%.0f\n", $2)}') + $WLAN_CLIENTS))
  WLAN_QUALITY=$(echo $(rrdtool fetch /tmp/rrd/OpenWrt/iwinfo-wlan1/signal_quality.rrd AVERAGE -s -30s | grep -v nan | tail -1 | awk '{printf("%.1f \n", $2)}') | sed "s/$/ + $WLAN_QUALITY/" | bc -l)
  COUNTER=$(($COUNTER +1))
done
WLAN_QUALITY=$(echo "$WLAN_QUALITY / $COUNTER" | bc -l | xargs printf '%.1f')

#LAN
LAN_CLIENTS=$(($(cat /tmp/dhcp.leases | wc -l) - $WLAN_CLIENTS))

if $DBG; then
    echo "$TIME $WAN_RX $WAN_TX $CPU $LAN_CLIENTS $WLAN_CLIENTS $WLAN_QUALITY $MEMORY_FREE $MEMORY_BUFFERED $MEMORY_CACHED $MEMORY_USED"
fi

mosquitto_pub -h $MQTTSERVER -u $MQTTUSER -P $MQTTPASS -t router/status -m "{\
\"name\":\"$name\"\
,\"wan_rx\":\"$WAN_RX\"\
,\"wan_tx\":\"$WAN_TX\"\
,\"cpu\":\"$CPU\"\
,\"lan_clients\":\"$LAN_CLIENTS\"\
,\"wifi_clients\":\"$WLAN_CLIENTS\"\
,\"wifi_quality\":\"$WLAN_QUALITY\"\
,\"memory_free\":\"$MEMORY_FREE\"\
,\"memory_buffered\":\"$MEMORY_BUFFERED\"\
,\"memory_cached\":\"$MEMORY_CACHED\"\
,\"memory_used\":\"$MEMORY_USED\"\
}" -i "OpenWRT"
}

#sending config data to Home Assistant for autodiscovery
[ -n "${name}" ] && send_config_data

while true;do
    [ -n "${name}" ] && make_mqtt_message
    resendconf=$((resendconf+1))
    #resend config message every 15 minutes for in case that mqtt server has been down
    if [[ $resendconf == 100 ]]; then
        [ -n "${name}" ] && send_config_data
        resendconf=0
    fi
    sleep $INTERVAL
done