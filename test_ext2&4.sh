#!/bin/bash
#
# Date: 2013-11-05
# Auther: Ipaloma.com
# Emial: liu.guangtao@ipaloma.com
#
# This shell can be use to test the speed betwen ext2, ext3 and etx4.
# You can mount with differen options to decide yourself mount option.
# 
# Test method:
# First create ext2/etx3/etx4 disk(partition) by dd, fdisk and mkfs commands;
# Then create 10 files for every file system, for a signal file 
# the shell write content with random lenght into the file;
# The length of content is between 10 and 1000010 maximize; 
# The writing times for a file will up to 10*1000000 maximize.
#
# After a routine of writing a file, the shell will read from the file up
# to 10*1000000 times maximize. For every read the content length is 
# between 10 and 1000010(maximize); 
#
# The all things just pursue the simulation more exactly.
# Please Refer: 
#  	https://www.kernel.org/doc/Documentation/filesystems/ext4.txt
# 


TMP_DIR="test_ext"
write_sum_b=0
w_time_sum=0
read_sum_b=0
r_time_sum=0

###################################
####### Function Defination #######
single_file_write() {
	local file="$1"
	local result_file="$2"
	local i=0
	local write_size=0
	local write_time=0
	for (( i = 0; i < 10; i++ )); do
		local input=""
		for (( j = 0; j < $(((RANDOM%1000000)+1)); j++ )); do
			input=$input"aaaaaaaaaa"
			write_size=$(($write_size + ${#input}))
			local START=$(date +%s%N)/1000000     #ms
			echo $input >> $file
			local END=$(date +%s%N)/1000000  	  #ms
			local DIFF=$(($END - $START))
			write_time=$(($write_time + $DIFF))
		done
	done
	printf "write %10s Bytes into file:%5s using %10s msec \n" "$write_size" "$file" "$write_time" \
					>> $result_file
	write_sum_b=$(($write_sum_b + $write_size))
	w_time_sum=$(($w_time_sum + $write_time))
}

single_file_read() {
	local file="$1"
	local result_file="$2"
	local i=0
	local read_size=0
	local read_time=0
	while read line; do
		local START=$(date +%s%N)/1000000     #ms
		read_size=$(($read_size + ${#line}))
		local END=$(date +%s%N)/1000000  	  #ms
		local DIFF=$(($END - $START))
		read_time=$(($read_time + $DIFF))
	done < $file

	printf "read %10s Bytes into file:%5s using %10s msec \n" "$read_size" "$file" "$read_time" \
					>> $result_file
	read_sum_b=$(($read_sum_b + $read_size))
	r_time_sum=$(($r_time_sum + $read_time))
}

start_fs_test() {
	cd "$1"
	local result_file="$2"

	echo "Staring write & read file testing ... "
	local i=0
	for (( i = 0; i < 10; i++ )); do
		printf "."
		single_file_write "$i" $result_file"_w.txt"
		single_file_read "$i" $result_file"_r.txt"
	done
	echo " "
	echo "****************************************" | tee -a $result_file"_w.txt"
	printf "write %10s Bytes(%10f KB) using %10f seconds SPEED=%10f KB/s\n" \
			 "$write_sum_b" $(($write_sum_b / 1024)) $(($w_time_sum / 1000)) $(($write_sum_b / $w_time_sum * 1000 / 1024)) \
			| tee -a $result_file"_w.txt"

	echo " "
	echo "****************************************" | tee -a $result_file"_r.txt"
	printf "read %10s Bytes(%10f KB) using %10f seconds SPEED=%10f KB/s\n" \
			 "$read_sum_b" $(($read_sum_b / 1024)) $(($r_time_sum / 1000)) $(($read_sum_b / $r_time_sum * 1000 / 1024)) \
			| tee -a $result_file"_r.txt"

	read_sum_b=0
	r_time_sum=0	
	write_sum_b=0
	w_time_sum=0

	cd ..
}

start_test_ext()(
	local fs_type="$1"
	echo "****************************************"
	echo "Starting test file system:$fs_type...."

	local testf=$fs_type".img"
	dd if=/dev/zero of=$testf bs=1M count=1024
	fdisk $testf -b 4096 -C 16 -H 255 -S 63 

	mountp=$fs_type"_mount"
	mkdir $mountp
	# you can try other flag:
	# commit=8
	# data=order
	# data=writeback
	case $fs_type in
		"ext2" | "ext4")
			mkfs -t $fs_type $testf
			mount -t $fs_type $testf $mountp
			;;
		"ext4-nojournal")
			mkfs.ext4 -O ^has_journal $testf
			mount -t ext4 -o noatime,barrier=0,errors=remount-ro $testf $mountp
			;;
		"ext4-optimize")
			mkfs -t ext4 $testf
			mount -t ext4 -o noatime,errors=remount-ro $testf $mountp
			;;
		*)
			echo "Unknown file system type:$fs_type" && exit 1
			;;
	esac

	local result_file="/tmp/fstest_result_"$fs_type

	start_fs_test "$mountp" "$result_file"

	sleep 1
	umount -f $mountp
)

###################################
####### Staring Executing  ########

# del the test directory
rm -rf $TMP_DIR 
if [ $? -ne 0 ]; then
	echo "Delete $TMP_DIR failed" && exit 1
fi
# del the last time test result file
rm -rf /tmp/fstest_result_ext*
if [ $? -ne 0 ]; then
	echo "Delete /tmp/fstest_result_ext* failed" && exit 1
fi

# this shell should be runned as root
if [ "`whoami`" != "root" ]; then
	echo "WARNING: You should be root!" && exit 1
fi

# create a 1GB vritual partation
mkdir $TMP_DIR && cd $TMP_DIR

start_test_ext "ext2"

start_test_ext "ext4"

start_test_ext "ext4-optimize"

start_test_ext "ext4-nojournal"


# del the test directory
rm -rf $TMP_DIR