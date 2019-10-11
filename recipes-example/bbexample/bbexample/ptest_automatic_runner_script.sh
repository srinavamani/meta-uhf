#! /bin/sh

echo "Starting ptest_automatic_runner"

rm -rf /home/root/Ptest_Log_Files
mkdir -p /home/root/Ptest_Log_Files
ptest-runner -l | awk {'print $1'} | sed 1d > /home/root/ptest_pkg_list
while read line; do

if [ $line ]
then
	ptest-runner $line > /home/root/Ptest_Log_Files/$line.txt
fi

done < /home/root/ptest_pkg_list

echo "##################################"
echo "          Completed               "
echo "##################################"
    
