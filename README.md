# Synology CPU temperature
Get Synology NAS CPU temperature via SSH

Works for Intel and AMD CPUs in DSM 7 and DSM 6

### Download the script

1. Download the latest version _Source code (zip)_ from https://github.com/007revad/Synology_CPU_temperature/releases
2. Save the download zip file to a folder on the Synology.
3. Unzip the zip file.

### To run the script via SSH

[How to enable SSH and login to DSM via SSH](https://kb.synology.com/en-global/DSM/tutorial/How_to_login_to_DSM_with_root_permission_via_SSH_Telnet)

```YAML
sudo -s /volume1/scripts/syno_cpu_temp.sh
```

-----
### Screenshots

<p align="left">AMD Ryzen CPU</p>
<p align="left"><img src="/images/amd.png"></p>

<p align="left">Intel 4 core CPU</p>
<p align="left"><img src="/images/intel_4core.png"></p>

<p align="left">Intel 2 core CPU</p>
<p align="left"><img src="/images/intel_2core.png"></p>

