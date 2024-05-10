#!/usr/bin/env bash
#----------------------------------------------------------
# Display CPU temperature and each core's temperature
#----------------------------------------------------------
# https://www.tecmint.com/check-linux-cpu-information/
#----------------------------------------------------------
#
# Intel(R) Celeron(R) J4125 CPU @ 2.00GHz
# Physical id 0: 32 °C
# Core 0: 32 °C
# Core 1: 32 °C
# Core 2: 31 °C
# Core 3: 31 °C
#
# AMD Ryzen Embedded V1500B
# k10temp: 42.75 °C
#
#----------------------------------------------------------

scriptver="v1.0.1"
script=Synology_CPU_temp
repo="007revad/Synology_CPU_temp"

# Show script version
#echo -e "$script $scriptver\ngithub.com/$repo\n"
echo "$script $scriptver"

# Get NAS model
model=$(cat /proc/sys/kernel/syno_hw_version)

# Get DSM full version
productversion=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION productversion)
buildphase=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION buildphase)
buildnumber=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION buildnumber)
smallfixnumber=$(/usr/syno/bin/synogetkeyvalue /etc.defaults/VERSION smallfixnumber)

# Show DSM full version and model
if [[ $buildphase == GM ]]; then buildphase=""; fi
if [[ $smallfixnumber -gt "0" ]]; then smallfix="-$smallfixnumber"; fi
echo -e "${model} DSM $productversion-$buildnumber$smallfix $buildphase\n"

# Get DSM major version
dsm=$(get_key_value /etc.defaults/VERSION majorversion)

# Get CPU model
cat /proc/cpuinfo | grep 'model name' | uniq | cut -d":" -f2 | xargs

# Get Intel CPU and core temps
if cat /proc/cpuinfo | grep Intel >/dev/null; then
    if [ "$dsm" = "7" ]; then
        #echo "$(cat /sys/class/hwmon/hwmon0/name):"
        x=1
        while [ "$x" -lt $(($(nproc) +2)) ]; do
            printf %s "$(cat /sys/class/hwmon/hwmon0/temp${x}_label): "
            cat /sys/class/hwmon/hwmon0/temp"${x}"_input | awk '{printf $1/1000}'; echo " °C"
            x=$((x +1))
        done
    elif [ "$dsm" = "6" ]; then
        #echo "$(cat /sys/bus/platform/devices/coretemp.0/name):"
        x=2
        while [ "$x" -lt $(($(nproc) +2)) ]; do
            if [ -f /sys/bus/platform/devices/coretemp.0/temp"${x}"_label ]; then
                printf %s "$(cat /sys/bus/platform/devices/coretemp.0/temp${x}_label): "
                cat /sys/bus/platform/devices/coretemp.0/temp"${x}"_input | awk '{printf $1/1000}'; echo " °C"
            fi
            x=$((x +1))
        done
    else
        echo "Unknown DSM version!"
    fi
fi

# Get AMD CPU temp
if cat /proc/cpuinfo | grep AMD >/dev/null; then
    if [ "$dsm" = "7" ]; then
        printf %s "$(cat /sys/class/hwmon/hwmon0/name): "
        cat /sys/class/hwmon/hwmon0/temp1_input | awk '{printf $1/1000}'; echo " °C"
    elif [ "$dsm" = "6" ]; then
        printf %s "$(cat /sys/bus/platform/devices/coretemp.0/name): "
        cat /sys/bus/platform/devices/coretemp.0/temp1_input | awk '{printf $1/1000}'; echo " °C"
    else
        echo "Unknown DSM version!"
    fi
fi

echo ""

