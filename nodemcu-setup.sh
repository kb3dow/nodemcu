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
git clone https://github.com/pfalcon/esp-open-sdk.git
cd esp-open-sdk
make STANDALONE=y

#Set  env variables
export ESP_HOME=$NMCU_HOME/esp-open-sdk
export SMING_HOME=$NMCU_HOME/Sming/Sming
export PATH=$NMCU_HOME/esp-open-sdk/xtensa-lx106-elf/bin:$PATH
alias xgcc="xtensa-lx106-elf-gcc"


echo Creating $NMCU_HOME/sourceThis which needs to be source before using node-mcu tools
echo export ESP_HOME=$NMCU_HOME/esp-open-sdk > $NMCU_HOME/sourceThis
echo export SMING_HOME=$NMCU_HOME/Sming/Sming >> $NMCU_HOME/sourceThis
echo export PATH=$NMCU_HOME/esp-open-sdk/xtensa-lx106-elf/bin:$PATH >> $NMCU_HOME/sourceThis
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
#echo Finding and change the $NMCU_HOME/Sming/Sming/Makefile-project.mk to point to correct esptool2
#sed --regexp-extended --in-place=.bak "s:^ESPTOOL2 \?\= .*:ESPTOOL2 \?\= $NMCU_HOME/esptool2/esptool2:" $NMCU_HOME/Sming/Sming/Makefile-project.mk
export PATH=$PATH:$ESP_HOME/esptool2/
echo export PATH=$PATH:$ESP_HOME/esptool2 >> $NMCU_HOME/sourceThis

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
