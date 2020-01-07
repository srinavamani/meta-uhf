#! /bin/sh

echo "Starting UHF Receiver Init Process"
cp -rf /etc/.aws ~/
ifup wlan0

sleep 5

#if [ -f "/usr/sbin/ntpdate" ]
#then
#	ntpdate -b -s -u pool.ntp.org
#fi

sh /etc/uhf-download.sh 

echo "##################################"
echo "          Completed               "
echo "##################################"
