#!/bin/bash

# HOSTNAME
pcName=$(hostname | sed "s/-/_/")

# MEMORY INFOS
memoryTotal=$(free -m | awk 'NR==2{printf "%s", $2 }')
memoryUsed=$(free -m | awk 'NR==2{printf "%s", $3 }')
memoryFree=$(expr $memoryTotal - $memoryUsed)
usedMemoryPercentage=$(expr $memoryUsed \* 100 / $memoryTotal | sed "s/,/./")
freeMemoryPercentage=$(expr 100 - $usedMemoryPercentage | sed "s/,/./")

# DISK INFOS
totalDiskSpace=$(df -h | awk '$NF=="/"{printf "%d", $2}')
usedDiskSpace=$(df -h | awk '$NF=="/"{printf "%d", $3}')
usedDiskSpacePercentage=$(expr $usedDiskSpace \* 100 / $totalDiskSpace | sed "s/,/./")
freeDiskSpace=$(expr $totalDiskSpace - $usedDiskSpace)
freeDiskSpacePercentage=$(expr $freeDiskSpace \* 100 / $totalDiskSpace | sed "s/,/./")

# CPU INFOS
cpuLoad=$(top -bn1 | grep load | awk '{printf "%.2f", $(NF-2)}' | sed "s/,/./")
numberOfCPUCores=$(lscpu | egrep 'CPU\(s\):' | awk '{printf "%s", $2}')
cpuLoad2=$(top -bn1 | grep load | awk '{printf "%d", $(NF-2) * 100}')
cpuUsage=$(expr $cpuLoad2 / $numberOfCPUCores | sed "s/,/./")

# PING INFOS
pingWithGoogle=$(ping -q -c2 google.com | awk 'NR==4{printf  "%.2f", $11/2}' | sed "s/,/./")

pcStatus=0
if [ $usedMemoryPercentage -gt 50 ]; then
	pcStatus=1
fi

if [ $usedMemoryPercentage -gt 75 ]; then
	pcStatus=2
fi

if [ $usedDiskSpacePercentage -gt 90 ]; then
	pcStatus=2
fi

if [ $cpuUsage -gt 60 ]; then
	pcStatus=1
fi

if [ $cpuUsage -gt 80 ]; then
	pcStatus=2
fi


echo
echo "=================================="
echo "HOST NAME: $pcName"
echo "STATUS: $pcStatus"
echo "----------------------------------"
echo "MEMORY:"
echo "----------------------------------"
echo " |-- TOTAL: $memoryTotal MB"
echo " |-- USED: $memoryUsed MB ($usedMemoryPercentage%)"
echo " |-- FREE: $memoryFree MB ($freeMemoryPercentage%)"
echo "----------------------------------"
echo "CPU:"
echo "----------------------------------"
echo " |-- NUMBER OF CORES: $numberOfCPUCores"
echo " |-- CPU LOAD: $cpuLoad"
echo " |-- CPU USAGE: $cpuUsage%"
echo "----------------------------------"
echo "DISK:"
echo "----------------------------------"
echo " |-- TOTAL SPACE: $totalDiskSpace GB"
echo " |-- USED SPACE: $usedDiskSpace GB ($usedDiskSpacePercentage%)"
echo " |-- FREE SPACE: $freeDiskSpace GB ($freeDiskSpacePercentage%)"
echo "----------------------------------"
echo "PING:"
echo "----------------------------------"
echo " |-- google.com: $pingWithGoogle"
echo "=================================="

curl -i -XPOST http://192.168.1.4:8086/write?db=teste2 --data-binary "cpu,server=$pcName numberOfCores=$numberOfCPUCores,cpuLoad=$cpuLoad,cpuUsage=$cpuUsage"
curl -i -XPOST http://192.168.1.4:8086/write?db=teste2 --data-binary "memory,server=$pcName total=$memoryTotal,used=$memoryUsed,free=$memoryFree"
curl -i -XPOST http://192.168.1.4:8086/write?db=teste2 --data-binary "diskstorage,server=$pcName total=$totalDiskSpace,used=$usedDiskSpace,free=$freeDiskSpace"
curl -i -XPOST http://192.168.1.4:8086/write?db=teste2 --data-binary "ping,server=$pcName google=$pingWithGoogle"
curl -i -XPOST http://192.168.1.4:8086/write?db=teste2 --data-binary "pcstatus,server=$pcName status=$pcStatus"