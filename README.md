Ext2-Ext4SpeedTest
==================

###This shell can be use to test the speed betwen ext2, ext3 and etx4.  
###You can mount with differen options to decide yourself mount option.

  
测试环境： Ubuntu 12.04 x64

##########################################################################################
#### 1. 直接按照默认的方式挂载 ext2 格式的磁盘 mount ext2 without any flag
##########################################################################################
read   31448390 Bytes(30711.000000 KB) using  33.000000 seconds SPEED=905.000000 KB/s   
write   31448390 Bytes(30711.000000 KB) using  39.000000 seconds SPEED=779.000000 KB/s


##########################################################################################
#### 2. 直接按照默认方式挂载 ext4 格式的磁盘 mount ext4 without any flag
##########################################################################################
read   26013420 Bytes(25403.000000 KB) using  30.000000 seconds SPEED=819.000000 KB/s  
write   26013420 Bytes(25403.000000 KB) using  35.000000 seconds SPEED=708.000000 KB/s

#### 3. 有优化选项的挂载 ext4 格式磁盘
#### 3.1
##########################################################################################
#### mount ext4 with flag:(rw,noatime,errors=remount-ro,commit=8)
##########################################################################################
read   29472330 Bytes(28781.000000 KB) using  32.000000 seconds SPEED=874.000000 KB/s  
write   29472330 Bytes(28781.000000 KB) using  38.000000 seconds SPEED=751.000000 KB/s

####3.2
##########################################################################################
#### mount ext4 with flag:(rw,noatime,errors=remount-ro,commit=5)
##########################################################################################
read   29507100 Bytes(28815.000000 KB) using  33.000000 seconds SPEED=864.000000 KB/s  
write   29507100 Bytes(28815.000000 KB) using  38.000000 seconds SPEED=750.000000 KB/s

#### 3.3
##########################################################################################
#### mount ext4 with flag:(rw,noatime,errors=remount-ro,data=writeback,commit=5)
##########################################################################################
read   34157500 Bytes(33356.000000 KB) using  34.000000 seconds SPEED=954.000000 KB/s  
write   34157500 Bytes(33356.000000 KB) using  40.000000 seconds SPEED=813.000000 KB/s

#### 4. 关闭日志功能且有优化选项的挂载 ext4 格式磁盘
#### 4.1
##########################################################################################
#### mount ext4 without journal with flag:(rw,noatime,barrier=0,data=writeback,errors=remount-ro,commit=5)
##########################################################################################
read   36812960 Bytes(35950.000000 KB) using  37.000000 seconds SPEED=965.000000 KB/s  
write   36812960 Bytes(35950.000000 KB) using  43.000000 seconds SPEED=821.000000 KB/s

#### 4.2
##########################################################################################
#### mount ext4 without journal with flag:(rw,noatime,barrier=0,data=order,errors=remount-ro,commit=5)
##########################################################################################
read   27964560 Bytes(27309.000000 KB) using  31.000000 seconds SPEED=862.000000 KB/s  
write   27964560 Bytes(27309.000000 KB) using  36.000000 seconds SPEED=744.000000 KB/s


#### 根据测试结果得出的结论是：
* 默认状态下 ext4 读速度 要比 ext2 慢 100KB/S 左右； 写速度 要比 ext2 慢 70KB/S 左右
* 有挂载优化选项的 ext4  读速度 要比 ext2 慢 50KB/S 左右； 写速度 要比 ext2 慢 30KB/S 左右，其中data=writeback可以明显提升读写速度
* 有挂载优化选项且关闭日志功能的 ext4  读速度 要比 ext2 快 50KB/S 左右； 写速度 要比 ext2 快 40KB/S 左右，其中data=writeback可以明显提升读写速度
