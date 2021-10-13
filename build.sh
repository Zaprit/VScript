#!/bin/bash
# This script builds all VScript libraries and puts them in the "build folder"
# might be handy idk

# Clean Directory
if [ "$1" == "clean" ]
then
rm -rf build
exit
fi

if [ "$1" == "install" ]
then
echo "Installing Libraries"
mkdir -p ~/.VScript/libs
cp build/*.vsl ~/.VScript/libs
echo "Done"
exit
fi

if [ ! -d build ]
then
mkdir build
fi

for i in $(ls src)
do
cd src/$i
if [ ! -f "build.conf" ]
then
echo "Not A VSC Library $i"
cd ../../
continue
fi

vsc
source build.conf
echo Copying Build Output To Build Folder
cp $VSC_PROG_NAME.vsl ../../build
echo "Removing Build Output From src Directory"
rm $VSC_PROG_NAME.vsl
cd ../../
done
