#!/bin/bash
#Requisites
echo Installing Requisites
sudo apt-get install -y \
	libtool-bin flex gawk libexpat-dev python sed python-serial srecord bc git help2man \
	build-essential zip gdb git vim make unrar autoconf automake \
	bison texinfo libtool gcc g++ gperf libc-dbg ncurses-dev expat \
	lua5.1 lua5.1-doc luarocks
for m in lua-bitlib luafilesystem md5 luaposix luasocket; do sudo luarocks install $m; done 

#Build esp-open-sdk
echo Installing esp-open-sdk
NMCU_HOME=$PWD
cd $NMCU_HOME
git clone --recursive https://github.com/pfalcon/esp-open-sdk.git
cd esp-open-sdk
make STANDALONE=y

#Set  env variables
echo Creating $NMCU_HOME/sourceThis which needs to be sourced before using node-mcu tools

export ESP_HOME=$NMCU_HOME/esp-open-sdk
echo export ESP_HOME=$ESP_HOME > $NMCU_HOME/sourceThis

export SMING_HOME=$NMCU_HOME/Sming/Sming
echo export SMING_HOME=$SMING_HOME >> $NMCU_HOME/sourceThis

export PATH=$PATH:$NMCU_HOME/esp-open-sdk/xtensa-lx106-elf/bin
# PATH is put in sourceThis later in this file

alias xgcc="xtensa-lx106-elf-gcc"
echo alias xgcc="xtensa-lx106-elf-gcc" >> $NMCU_HOME/sourceThis

#Get and build Sming Core
echo Installing  Sming Core
cd $NMCU_HOME
git clone https://github.com/SmingHub/Sming.git
cd Sming/Sming
git checkout origin/master
make

#Get and build esptool2
echo Installing esptool2
#cd $NMCU_HOME
cd $ESP_HOME
git clone https://github.com/raburton/esptool2.git
cd esptool2
make
export PATH=$PATH:$ESP_HOME/esptool2/

#Build Spiffy (if required)
echo Building Spiffy
cd $NMCU_HOME/Sming/Sming
make spiffy

#install esptool.py
echo Installing esptool.py
cd $NMCU_HOME
sudo apt-get install python-serial unzip
wget https://github.com/themadinventor/esptool/archive/master.zip
unzip master.zip
mv esptool-master $NMCU_HOME/esp-open-sdk/esptool
rm master.zip

#git clone original Arduino codebase as reference
echo Cloning original Arduino codebase as reference
cd $NMCU_HOME
git clone https://github.com/esp8266/Arduino.git

#git clone nodemcu firmware for reference
echo Cloning nodemcu firmware for reference
cd $NMCU_HOME
git clone https://github.com/nodemcu/nodemcu-firmware.git
cd nodemcu-firmware
cp  -R ../esp-open-sdk/lx106-hal/include/xtensa sdk-overrides/include
# catch22, the sdk/iesp_iot... dir isnt there (yet) and compilation fails
# till the 2 .a files are copied over. The dir tree is present only after the
# 1st compilation attempt
wget -O sdk/esp_iot_sdk_v2.0.0/lib/libhal.a https://github.com/esp8266/esp8266-wiki/raw/master/libs/libhal.a
wget -O sdk/esp_iot_sdk_v2.0.0/lib/libc.a https://github.com/esp8266/esp8266-wiki/raw/master/libs/libc.a
# make
echo NodeMCU firmware built. It can be flashed by doing
echo "../tools/esptool.py --port /dev/ttyUSB0 write_flash 0x00000 ../bin/0x00000.bin 0x10000 ../bin/0x10000.bin"

# This is done at the end as $PATH changes more than once
echo export PATH=$PATH >> $NMCU_HOME/sourceThis
