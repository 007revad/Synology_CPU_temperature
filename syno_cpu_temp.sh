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
# Realtek
# ???
#
# https://chainsawonatireswing.com/2012/01/07/find-out-which-cpu-your-synology-diskstation-uses/
# Marvell
# ???
#
# Annapurna
# ???
#
# STM
# ???
#
# Mindspeed
# ???
#
# Freescale
# ???
#----------------------------------------------------------

scriptver="v2.0.3"
script=Synology_CPU_temp
repo="007revad/Synology_CPU_temp"
scriptname=syno_cpu_temp

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
echo -e "${model} DSM $productversion-$buildnumber$smallfix $buildphase"

# Get DSM major version
dsm=$(get_key_value /etc.defaults/VERSION majorversion)

# Read variables from syno_cpu_temp.config
if [[ -f $(dirname -- "$0";)/${scriptname}.config ]];then
    Log_Directory=$(synogetkeyvalue "$(dirname -- "$0";)/${scriptname}.config" Log_Directory)
    Log=$(synogetkeyvalue "$(dirname -- "$0";)/${scriptname}.config" Log)
else
    echo "${scriptname}.config file missing!"
    exit 1
fi

# Check if backup directory exists
if [[ ${Log,,} == "yes" && ! -d $Log_Directory ]]; then
    echo "Log directory not found:"
    echo "$Log_Directory"
    echo "Check your setting in syno_cpu_temp.config"
    exit 1
fi

if [[ ${Log,,} == "yes" ]]; then
    echo "Logging to $Log_Directory"
    now="$(date +"%Y-%m-%d %H:%M:%S") - "
    Log_File="${Log_Directory}/${scriptname}.log"

    # Add header to log if log file does not already exist
    if [[ ! -f "$Log_File" ]]; then
        echo "$script $scriptver" > "$Log_File"
        echo -e "${model} DSM $productversion-$buildnumber$smallfix $buildphase" >> "$Log_File"
    fi
fi

# Get CPU vendor
if grep Intel /proc/cpuinfo >/dev/null; then
    vendor="Intel"
elif grep AMD /proc/cpuinfo >/dev/null; then
    vendor="AMD"
elif grep Realtek /proc/cpuinfo >/dev/null; then
    vendor="Realtek"
elif grep Marvell /proc/cpuinfo >/dev/null; then
    vendor="Marvell"
elif grep Annapurna /proc/cpuinfo >/dev/null; then
    vendor="Annapurna"
elif grep STM /proc/cpuinfo >/dev/null; then
    vendor="STM"
elif grep Mindspeed /proc/cpuinfo >/dev/null; then
    vendor="Mindspeed"
elif grep Freescale /proc/cpuinfo >/dev/null; then
    vendor="Freescale"
else
    vendor="$(grep 'vendor_id' /proc/cpuinfo | uniq | cut -d":" -f2 | xargs)"
fi

if [[ ${vendor,,} != "intel" ]] && [[ ${vendor,,} != "amd" ]]; then
    echo "$vendor not supported yet." |& tee -a "$Log_File"
    echo "Create a Github issue to get $vendor CPUs added." |& tee -a "$Log_File"
    exit
fi

# Show CPU model
grep 'model name' /proc/cpuinfo | uniq | cut -d":" -f2 | xargs |& tee -a "$Log_File"

# Get number of CPUs
cpu_qty=$(grep 'physical id' /proc/cpuinfo | uniq | awk '{printf $4}')
#cpu_qty=$((cpu_qty +1))  # test multiple CPUs

# Get Intel CPU and core temps
if [[ ${vendor,,} == "intel" ]]; then
    if [ "$dsm" = "7" ]; then
        c=0
        while [[ ! $c -gt $cpu_qty ]]; do
            if [[ $cpu_qty -gt "0" ]]; then
                # Show CPU number
                echo -en "\n${now}" |& tee -a "$Log_File"
                echo -e "[ CPU $c ]" |& tee -a "$Log_File"
            else
                echo "" |& tee -a "$Log_File"
            fi

            x=1
            while [ "$x" -lt $(($(nproc) +2)) ]; do
                # Show max temp for CPU $c
                if [[ $x == "1" ]]; then
                    if [[ -f "/sys/class/hwmon/hwmon$c/temp1_max" ]]; then
                        echo -n "${now}" |& tee -a "$Log_File"
                        printf %s "Max temp: " |& tee -a "$Log_File"
                        awk '{printf $1/1000}' "/sys/class/hwmon/hwmon$c/temp1_max" |& tee -a "$Log_File"
                        echo " °C" |& tee -a "$Log_File"
                    fi
                fi
                # Show core $x temp for CPU $c
                if [ -f "/sys/class/hwmon/hwmon$c/temp${x}_label" ]; then
                    echo -n "${now}" |& tee -a "$Log_File"
                    printf %s "$(cat "/sys/class/hwmon/hwmon$c/temp${x}_label"): " |& tee -a "$Log_File"
                    awk '{printf $1/1000}' "/sys/class/hwmon/hwmon$c/temp${x}_input" |& tee -a "$Log_File"
                    echo " °C" |& tee -a "$Log_File"
                fi
                x=$((x +1))
            done
            c=$((c +1))
        done
    elif [ "$dsm" = "6" ]; then
        c=0
        while [[ ! $c -gt $cpu_qty ]]; do
            if [[ $cpu_qty -gt "0" ]]; then
                # Show CPU number
                echo -en "\n${now}" |& tee -a "$Log_File"
                echo -e "[ CPU $c ]" |& tee -a "$Log_File"
            else
                echo "" |& tee -a "$Log_File"
            fi

            x=2
            while [ "$x" -lt $(($(nproc) +2)) ]; do
                # Show core $x temp for CPU $c
                if [ -f "/sys/bus/platform/devices/coretemp.$c/temp${x}_label" ]; then
                    echo -n "${now}" |& tee -a "$Log_File"
                    printf %s "$(cat "/sys/bus/platform/devices/coretemp.$c/temp${x}_label"): " |& tee -a "$Log_File"
                    awk '{printf $1/1000}' "/sys/bus/platform/devices/coretemp.$c/temp${x}_input" |& tee -a "$Log_File"
                    echo " °C" |& tee -a "$Log_File"
                fi
                x=$((x +1))
            done
            c=$((c +1))
        done
    else
        echo "Unknown DSM version!" |& tee -a "$Log_File"
    fi
fi


# Get AMD CPU temp
if [[ ${vendor,,} == "amd" ]]; then
    if [ "$dsm" = "7" ]; then
        c=0
        while [[ ! $c -gt $cpu_qty ]]; do
            if [[ $cpu_qty -gt "0" ]]; then
                # Show CPU number
                echo -en "\n${now}" |& tee -a "$Log_File"
                echo -e "[ CPU $c ]" |& tee -a "$Log_File"
            else
                echo "" |& tee -a "$Log_File"
            fi
            # Show CPU max temp
            if [[ -f "/sys/class/hwmon/hwmon$c/temp1_max" ]]; then
                echo -n "${now}" |& tee -a "$Log_File"
                printf %s "Max temp: " |& tee -a "$Log_File"
                awk '{printf $1/1000}' "/sys/class/hwmon/hwmon$c/temp1_max" |& tee -a "$Log_File"
                echo " °C" |& tee -a "$Log_File"
            fi
            # Show core $x temp
            if [[ -f "/sys/class/hwmon/hwmon$c/temp1_max" ]]; then
                echo -n "${now}" |& tee -a "$Log_File"
                printf %s "$(cat "/sys/class/hwmon/hwmon$c/name"):  " |& tee -a "$Log_File"
                awk '{printf $1/1000}' "/sys/class/hwmon/hwmon$c/temp1_input" |& tee -a "$Log_File"
                echo " °C" |& tee -a "$Log_File"
            fi
            c=$((c +1))
        done
    elif [ "$dsm" = "6" ]; then
        c=0
        while [[ ! $c -gt $cpu_qty ]]; do
            if [[ $cpu_qty -gt "0" ]]; then
                # Show CPU number
                echo -en "\n${now}" |& tee -a "$Log_File"
                echo -e "[ CPU $c ]" |& tee -a "$Log_File"
            else
                echo "" |& tee -a "$Log_File"
            fi
            # Show core $x temp
            if [[ -f "/sys/bus/platform/devices/coretemp.$c/name" ]]; then
                echo -n "${now}" |& tee -a "$Log_File"
                printf %s "$(cat "/sys/bus/platform/devices/coretemp.$c/name"): " |& tee -a "$Log_File"
                awk '{printf $1/1000}' "/sys/bus/platform/devices/coretemp.$c/temp1_input" |& tee -a "$Log_File"
                echo " °C" |& tee -a "$Log_File"
            fi
            c=$((c +1))
        done
    else
        echo "Unknown DSM version!" |& tee -a "$Log_File"
    fi
fi

echo ""

