#!/bin/bash

# Get OS and Kernel information
OS=$(lsb_release -d | awk -F"\t" '{print $2}')
KERNEL=$(uname -r)

# Get hostname and network information
HOSTNAME=$(hostname)
MACHINE_IP=$(hostname -I | awk '{print $1}')
CLIENT_IP=$(hostname -I | awk '{print $1}')  # Adjust according to your needs
DNS_IP=$(grep 'nameserver' /etc/resolv.conf | awk '{print $2}' | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n 1)
USER=$(whoami)

# Get CPU information
CPU=$(lscpu | grep "Model name" | awk -F: '{print $2}' | xargs)
CORES=$(nproc)
NUM_CORES=$(echo $CORES | awk '{print $1}')
CPU_FREQ=$(vcgencmd measure_clock arm | awk -F "=" '{print $2/1000000}')


# Get CPU Load
LOAD1=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | xargs)
LOAD5=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f2 | xargs)
LOAD15=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f3 | xargs)

# Function to round to the nearest 0.20
round_to_nearest_five() {
  number=$1
  remainder=$((number % 5))
  
  if [ $remainder -ge 3 ]; then
    rounded=$((number + (5 - remainder)))
  else
    rounded=$((number - remainder))
  fi

  # Divide by 100 to get back to the original scale
  echo $(echo "scale=2; $rounded / 5" | bc)
}

# Convert to a percentage
percentage() {
  dividend=$1
  divisor=$2
  new_val=$(echo "scale=2; $dividend / $divisor" | bc)
  result=$(echo "scale=0; $new_val * 100 / 1" | bc)
  echo $result
}

# Calc LOAD percentage
PERCENTAGE_LOAD1=$(percentage $LOAD1 $NUM_CORES)
PERCENTAGE_LOAD5=$(percentage $LOAD5 $NUM_CORES)
PERCENTAGE_LOAD15=$(percentage $LOAD15 $NUM_CORES)

# Rounded CPU LOAD
ROUNDED_LOAD1=$(round_to_nearest_five $PERCENTAGE_LOAD1)
ROUNDED_LOAD5=$(round_to_nearest_five $PERCENTAGE_LOAD5)
ROUNDED_LOAD15=$(round_to_nearest_five $PERCENTAGE_LOAD15)

# Available CPU LOAD
DIFF_LOAD1=$(echo "20 - $ROUNDED_LOAD1" | bc)
DIFF_LOAD5=$(echo "20 - $ROUNDED_LOAD5" | bc)
DIFF_LOAD15=$(echo "20 - $ROUNDED_LOAD15" | bc)

# Get Memory information
MEM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
MEM_USED=$(free -h | grep Mem | awk '{print $3}')
MEM_USAGE=$(echo "$(free | awk '/Mem:/ {print $3}') / $(free | awk '/Mem:/ {print $2}') * 100" | bc -l | awk '{print int($1+0.5)}')
ROUNDED_MEM=$(round_to_nearest_five $MEM_USAGE)
DIFF_MEM=$(echo "20 - $ROUNDED_MEM" | bc)

# Get Disk usage
DISK_TOTAL=$(df -h / | grep / | awk '{print $2}')
DISK_USED=$(df -h / | grep / | awk '{print $3}')
DISK_USAGE=$(df -h / | grep / | awk '{print $5}' | tr -d '%')
ROUNDED_DISK=$(round_to_nearest_five $DISK_USAGE)
DIFF_DISK=$(echo "20 - $ROUNDED_DISK" | bc)

# Get last login and uptime
LAST_LOGIN=$(last -n 1 -a | head -n 1 | awk '{print $4, $5, $6}')
UPTIME=$(uptime -p)
FORMATTED_UPTIME=$(echo $UPTIME | sed 's/up //; s/ days*/d,/; s/ hours*/h,/; s/ minutes*/m/; s/, *$//')

UTF_SOLID_SQUARE="\u2588"
UTF_OPAQUE_SQUARE="\u2592"

# Display the report
echo "-----------------------------------------------"
echo "-----------------------------------------------"
echo "                 ARASKA CORP."
echo "                MACHINE REPORT"
echo "-----------------------------------------------"
echo "OS             | $OS"
echo "KERNEL         | Linux $KERNEL"
echo ""
echo "HOSTNAME       | $HOSTNAME"
echo "MACHINE IP     | $MACHINE_IP"
echo "CLIENT IP      | $CLIENT_IP"
echo "DNS IP         | $DNS_IP"
echo "USER           | $USER"
echo "-----------------------------------------------"
echo "PROCESSOR      | $CPU"
echo "CORES          | $CORES vCPU(s)"
echo "CPU FREQ       | $CPU_FREQ MHz"
echo -ne "LOAD 1m        | "
for i in $(seq 1 $ROUNDED_LOAD1); do
    printf "$UTF_SOLID_SQUARE"
done
for i in $(seq 1 $DIFF_LOAD1); do
    printf "$UTF_OPAQUE_SQUARE"
done
printf " $PERCENTAGE_LOAD1%%"
echo

echo -ne "LOAD 5m        | "
for i in $(seq 1 $ROUNDED_LOAD5); do
    printf "$UTF_SOLID_SQUARE"
done
for i in $(seq 1 $DIFF_LOAD5); do
    printf "$UTF_OPAQUE_SQUARE"
done
printf " $PERCENTAGE_LOAD5%%"
echo

echo -ne "LOAD 15m       | "
for i in $(seq 1 $ROUNDED_LOAD15); do
    printf "$UTF_SOLID_SQUARE"
done
for i in $(seq 1 $DIFF_LOAD15); do
    printf "$UTF_OPAQUE_SQUARE"
done
printf " $PERCENTAGE_LOAD15%%"
echo

echo "-----------------------------------------------"
echo "MEMORY         | $MEM_USED/$MEM_TOTAL"
echo -ne "USAGE          | "
for i in $(seq 1 $ROUNDED_MEM); do
    printf "$UTF_SOLID_SQUARE"
done
for i in $(seq 1 $DIFF_MEM); do
    printf "$UTF_OPAQUE_SQUARE"
done
printf " $MEM_USAGE%%"
echo

echo "-----------------------------------------------"
echo "VOLUME         | $DISK_USED/$DISK_TOTAL"
echo -ne "               | "
for i in $(seq 1 $ROUNDED_DISK); do
    printf "$UTF_SOLID_SQUARE"
done
for i in $(seq 1 $DIFF_DISK); do
    printf "$UTF_OPAQUE_SQUARE"
done
printf " $DISK_USAGE%%"
echo

echo "-----------------------------------------------"
echo "LAST LOGIN     | $LAST_LOGIN"
echo "UPTIME         | $FORMATTED_UPTIME"
echo "-----------------------------------------------"
