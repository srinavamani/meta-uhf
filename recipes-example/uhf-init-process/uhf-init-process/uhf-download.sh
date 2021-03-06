#!/bin/sh

auto_download_check_function()
{
val1=`cat "$Config_file_path/$default_conf_file" | grep "config_updated_timestamp"` && val2=${val1#*>} && config_updated_timestamp=${val2%<*}
echo $config_updated_timestamp

if [ -f $Config_file_path/config_timestamp ]
then
	current_config_timestamp=`cat $Config_file_path/config_timestamp`
	echo $current_config_timestamp

	if [ "$config_updated_timestamp" != "$current_config_timestamp" ]
	then
		echo "timestamp_not_match"
		rm -rf "$Config_file_path"
		reboot
	fi
fi
}

download_config()
{
val1=`cat "$Config_file_path/$default_conf_file" | grep "school_name"` && val2=${val1#*>} && school_conf_path=${val2%<*}

main_conf_file_name=`aws s3 ls $school_conf_path/Board-Configurations/ | grep $mac | awk '{print $4}'`
student_database_file_name="Student_Database"

aws s3 cp "$school_conf_path/Board-Configurations/$main_conf_file_name" $Config_file_path/
aws s3 cp "$school_conf_path/$student_database_file_name.csv" $Config_file_path/

if [ -f "$Config_file_path/$student_database_file_name.csv" ]; then

cp "$Config_file_path/$student_database_file_name.csv" "/home/root/ID.csv"
echo "Student database downloaded successfully"
else
echo "Student database missing"
fi

val1=`cat "$Config_file_path/$main_conf_file_name" | grep "wifi_ssid"` && val2=${val1#*>} && wifi_ssid=${val2%<*}
val1=`cat "$Config_file_path/$main_conf_file_name" | grep "wifi_password"` && val2=${val1#*>} && wifi_password=${val2%<*}

val1=`cat "$Config_file_path/$main_conf_file_name" | grep "IN"` && number_of_channels=${val1#*>} && number_of_channels=${val2%<*}

val1=`cat "$Config_file_path/$main_conf_file_name" | grep "IN"` && val2=${val1#*>} && IN=${val2%<*}
val1=`cat "$Config_file_path/$main_conf_file_name" | grep "OUT"` && val2=${val1#*>} && OUT=${val2%<*}

echo "Number of channels - $number_of_channels"
echo "IN - $IN"
echo "OUT - $OUT"

cp /etc/wpa_supplicant.conf-uhf /etc/wpa_supplicant.conf

wpa_passphrase $wifi_ssid $wifi_password >> /etc/wpa_supplicant.conf

##### Copy the respective project application as main application for this board - pending

}

file_conversion()
{
case $1 in
	csv2db)
		echo "Converting from CSV to SQLITE DB"
		(
		echo ".mode csv"
		echo ".import $2 sample"
		) | sqlite3 $3
	;;
esac
}

upload()
{

Upload "$1" "$number_of_channels" "$IN" "$OUT"

echo "uploading - $1 Report"
upload_date=`date +%Y-%m-%d`
file_name=`echo "$upload_date"_"$1".csv`
echo "$file_name"

sqlite3 -header -csv "/home/root/ID.db" "select * from Student_Details;" > "/home/root/$file_name"

aws s3 cp "/home/root/$file_name" "s3://peepal000primary000school/Reports/Campus/"

}


####################################################################
#		Code starts from here
####################################################################

Config_file_path="/home/root/RPI_CONFIGS"
auto_download_check=`date +%H`
hour=`date +%H`

if [ ! -d $Config_file_path ]
then
	echo "RPI_CONFIGS Not found"
	mkdir -p "$Config_file_path/upload"
	chmod 777 "$Config_file_path"
fi

if [ ! -f "/home/root/upload_state" ]
then
touch /home/root/upload_state
fi

#mac=`cat /sys/class/net/eth0/address`
mac="58:8a:5a:39:38:03"

# AWS encryotion and decryption pending

aws s3 ls s3://board-mapping-details/ | awk '{print $4}' > /tmp/list.txt

default_conf_file=`cat "/tmp/list.txt" | grep $mac`

echo "$default_conf_file"

if [ $default_conf_file ]
then
	echo "Registered Device"
	aws s3 cp s3://board-mapping-details/$default_conf_file $Config_file_path/
	break
else
	echo "Device not registered"
	exit 3
fi

#Last Updation Timestamp in config file
val1=`cat $Config_file_path/$default_conf_file | grep "config_updated_timestamp"` && val2=${val1#*>} && config_updated_timestamp=${val2%<*}
echo $config_updated_timestamp

if [ -f $Config_file_path/config_timestamp ]
then
	current_config_timestamp=`cat $Config_file_path/config_timestamp`
	echo $current_config_timestamp

	if [ "$config_updated_timestamp" != "$current_config_timestamp" ]
	then
		echo "timestamp_not_match"
		rm -rf "$Config_file_path/$Student_Database*"
		download_config
		echo "$config_updated_timestamp" > $Config_file_path/config_timestamp
	else
		echo "timestamp_matching"
		val1=`cat "$Config_file_path/$default_conf_file" | grep "school_name"` && val2=${val1#*>} && school_conf_path=${val2%<*}
		main_conf_file_name=`aws s3 ls $school_conf_path/Board-Configurations/ | grep $mac | awk '{print $4}'`

###### configuration file name with mac : not with _ (check and exit) - Pending

	fi
else
	echo "Confing file not found"
	download_config
	echo "$config_updated_timestamp" > $Config_file_path/config_timestamp
fi

# Remove the ID.db based on backup concept
rm -rf /home/root/ID.db

#BLE_Student_ID_Scanner &

val1=`cat "$Config_file_path/$main_conf_file_name" | grep "morning_section_start"` && val2=${val1#*>} && morning_start=${val2%<*}
val1=`cat "$Config_file_path/$main_conf_file_name" | grep "morning_section_end"` && val2=${val1#*>} && morning_end=${val2%<*}

val1=`cat "$Config_file_path/$main_conf_file_name" | grep "afternoon_section_start"` && val2=${val1#*>} && afternoon_start=${val2%<*}
val1=`cat "$Config_file_path/$main_conf_file_name" | grep "afternoon_section_end"` && val2=${val1#*>} && afternoon_end=${val2%<*}

morning_section_start=`echo ${morning_start//:}`
morning_section_end=`echo ${morning_end//:}`

afternoon_section_start=`echo ${afternoon_start//:}`
afternoon_section_end=`echo ${afternoon_end//:}`

echo "$morning_section_start - $morning_section_end"
echo "$afternoon_section_start - $afternoon_section_end"

morning_section_started="no"
afternoon_section_started="no"

morning_section="not_started"
afternoon_section="not_started"

date=`date +%d%m%Y`

###### upload need to proper even in power fluctuation case - pending

if [ ! -f "$Config_file_path/upload/$current_date" ]
then
	echo "Todays upload status missing..."
	rm -rf "$Config_file_path/upload/*"
	touch  "$Config_file_path/upload/$date"
	echo "morning_upload no" > "$Config_file_path/upload/$date"
	echo "afternoon_upload no" >> "$Config_file_path/upload/$date"
fi

morning_upload_state=`cat "$Config_file_path/upload/$date" | grep "morning" | awk {'print $2'}`
afternoon_upload_state=`cat "$Config_file_path/upload/$date" | grep "afternoon" | awk {'print $2'}`

while [ 1 ]
do

current_time=`date +%H%M%S`
#echo "current_time - $current_time"
current_date=`date +%d%m%Y`
#echo "$current_date"

quick_upload=`cat /home/root/upload_state`

# Quick upload - Morning report
if [ "$quick_upload" == "morning" ]
then
upload morning
morning_upload_state="yes"
echo "none" > /home/root/upload_state
# Quick upload - Afternoon report
elif [ "$quick_upload" == "afternoon" ]
then
upload afternoon
afternoon_upload_state="yes"
echo "none" > /home/root/upload_state
fi

###### Masked due to some error in increment
#if [ $hour -eq $auto_download_check ]
#then
#echo "Auto_Download_Check"
#auto_download_check_function
#auto_download_check=$((auto_download_check+1))
#fi

if [ "$current_time" -gt "$morning_section_start" -a "$current_time" -lt "$morning_section_end" ]
then
if [ "$morning_section" == "not_started" ]
then
echo "morning section in process"
#
# Call the binary with argument for morning or afternoon section
#
BLE_Student_ID_Scanner &
########
morning_section="started"
morning_section_started="yes"
fi
elif [ "$morning_upload_state" == "no" -a "$morning_section_started" == "yes" ]
then
echo "upload - morning"
#
# Kill the binary
#
killall BLE_Student_ID_Scanner
########
#upload morning
morning_upload_state="yes"
fi

if [ "$current_time" -gt "$afternoon_section_start" -a "$current_time" -lt "$afternoon_section_end" ]
then
if [ "$afternoon_section" == "not_started" ]
then
echo "afternoon section in process"
#
# Call the binary with argument for morning or afternoon section
#
BLE_Student_ID_Scanner &
########
afternoon_section="started"
afternoon_section_started="yes"
fi
elif [ "$afternoon_upload_state" == "no" -a "$afternoon_section_started" == "yes" ]
then
#
# Kill the binary
#
killall BLE_Student_ID_Scanner
########
#upload afternoon
afternoon_upload_state="yes"
fi

sleep 1

done
