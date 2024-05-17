# Synology CPU temperature

<a href="https://github.com/007revad/Synology_CPU_temperature/releases"><img src="https://img.shields.io/github/release/007revad/Synology_CPU_temperature.svg"></a>
<a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2F007revad%2FSynology_CPU_temperature&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=views&edge_flat=false"/></a>
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/paypalme/007revad)
[![](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/007revad)
[![committers.top badge](https://user-badge.committers.top/australia/007revad.svg)](https://user-badge.committers.top/australia/007revad)

### Description

Get Synology NAS CPU temperature via SSH

Works for Intel and AMD CPUs in DSM 7 and DSM 6. Also works for Synology models with more than 1 CPU.

For other CPUS [create an issue](https://github.com/007revad/Synology_CPU_temperature/issues) and I'll see if I can add support for it. 

If you schedule the script in Task Scheduler you should enable logging and set the log_directory in included syno_cpu_temp.config

### Download the script

1. Download the latest version _Source code (zip)_ from https://github.com/007revad/Synology_CPU_temperature/releases
2. Save the download zip file to a folder on the Synology.
3. Unzip the zip file.

### To run the script via SSH

[How to enable SSH and login to DSM via SSH](https://kb.synology.com/en-global/DSM/tutorial/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet)

```YAML
/volume1/scripts/syno_cpu_temp.sh
```

**Note:** Replace /volume1/scripts/ with the path to where the script is located.

### Troubleshooting

If the script won't run check the following:

1. If the path to the script contains any spaces you need to enclose the path/scriptname in double quotes:
   ```YAML
   sudo -s "/volume1/my scripts/syno_cpu_temp.sh"
   ```
2. Make sure you unpacked the zip or rar file that you downloaded and are trying to run the syno_cpu_temp.sh file.
3. Set the syno_cpu_temp.sh file as executable:
   ```YAML
   sudo chmod +x "/volume1/scripts/syno_cpu_temp.sh"
   ```

-----
### Screenshots

<p align="left">AMD Ryzen CPU</p>
<p align="left"><img src="/images/amd.png"></p>

<p align="left">Intel 4 core CPU</p>
<p align="left"><img src="/images/intel_4core.png"></p>

<p align="left">Intel 2 core CPU</p>
<p align="left"><img src="/images/intel_2core.png"></p>

<p align="left">AMD Ryzen CPU log</p>
<p align="left"><img src="/images/log.png"></p>

