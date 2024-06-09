#!/bin/bash

# Get OS and Kernel information
OS=$(lsb_release -d | awk -F"\t" '{print $2}')
KERNEL=$(uname -r)

# Get hostname and network information
HOSTNAME=$(hostname)
MACHINE_IP=$(hostname -I | awk '{print $1}')
CLIENT_IP=$(hostname -I | awk '{print $1}')  # Adjust according to your needs
DNS_IP=$(cat /etc/resolv.conf | grep 'nameserver' | awk '{print $2}')
USER=$(whoami)

# Get CPU information
CPU=$(lscpu | grep "Model name" | awk -F: '{print $2}' | xargs)
CORES=$(nproc)
CPU_FREQ=$(lscpu | grep "CPU MHz" | awk -F: '{print $2}' | xargs)

# Get CPU Load
LOAD1=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
LOAD5=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f2 | xargs)
LOAD15=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f3 | xargs)

# Get Memory information
MEM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
MEM_USED=$(free -h | grep Mem | awk '{print $3}')

# Get Disk usage
DISK_TOTAL=$(df -h / | grep / | awk '{print $2}')
DISK_USED=$(df -h / | grep / | awk '{print $3}')
DISK_USAGE=$(df -h / | grep / | awk '{print $5}')

# Get ZFS health (adjust if not using ZFS)
ZFS_HEALTH="HEALTH O.K."  # Placeholder

# Get last login and uptime
LAST_LOGIN=$(last -n 1 -a | head -n 1)
UPTIME=$(uptime -p)

# Display the report
echo "----------------------------------------"
echo " UNITED STATES GRAPHICS COMPANY"
echo "          MACHINE REPORT"
echo "----------------------------------------"
echo ""
echo "OS             : $OS"
echo "KERNEL         : Linux $KERNEL"
echo ""
echo "HOSTNAME       : $HOSTNAME"
echo "MACHINE IP     : $MACHINE_IP"
echo "CLIENT IP      : $CLIENT_IP"
echo "DNS IP         : $DNS_IP"
echo "USER           : $USER"
echo ""
echo "PROCESSOR      : $CPU"
echo "CORES          : $CORES vCPU(s)"
echo "CPU FREQ       : $CPU_FREQ MHz"
echo "LOAD 1m        : $LOAD1"
echo "LOAD 5m        : $LOAD5"
echo "LOAD 15m       : $LOAD15"
echo ""
echo "MEMORY USAGE   : $MEM_USED/$MEM_TOTAL"
echo ""
echo "VOLUME         : $DISK_USED/$DISK_TOTAL [$DISK_USAGE]"
echo "ZFS HEALTH     : $ZFS_HEALTH"
echo ""
echo "LAST LOGIN     : $LAST_LOGIN"
echo "UPTIME         : $UPTIME"
echo "----------------------------------------"
