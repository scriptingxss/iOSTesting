#Upload the following script to your IOS device, and chmod +x to run.
#Most Basic Usage: Set a filter ('f' option), and then create a download bundle ('d' option) all of the applicable files.
#!/bin/sh
FILTER=""
while :
do
clear
echo -e "\n--[ IOS Automation Script ]--\n"
if [ "$FILTER" != "" ]; then
echo " f : Set Filters ( Current Filter: $FILTER - $BUNDLE )"
echo " d : Download All Files"
echo " k : Keychain Data"
echo " b : Binary Info"
else
echo " f : Set Filters"
fi
echo
echo " 1 : List Application Locations"
echo " 2 : List Application Bundle IDs"
echo " 3 : List Application Bundle Names"
echo " 4 : List Application data Plist files"
echo " 5 : List Application folder Plist files"
echo " 6 : List all SQL databases"
echo " 7 : List iWatch bundles"
echo " 8 : List Snapshots"
echo " 9 : List Cookies"
echo
echo -e " q : Quit \n"
read -sn 1 opt
case $opt in
"1") echo -e "\n--[ Application List ]--\n"
if [ "$FILTER" != "" ]; then
ls /private/var/mobile/Containers/Bundle/Application/*/* | grep $FILTER
else
ls /private/var/mobile/Containers/Bundle/Application/*/* | grep \.app
fi
echo -e "\nPress any key to continue..."
read -n1 a
;;
"2") echo -e "\n--[ Application Bundle IDs ]--\n"
if [ "$FILTER" != "" ]; then
find /var/mobile/Containers/Bundle/Application -name $FILTER | cut -f7,8 -d/ | sort -u | sed 's/\// : /'
else
find /var/mobile/Containers/Bundle/Application -name *.app | cut -f7,8 -d/ | sort -u | sed 's/\// : /'
fi
echo -e "\nPress any key to continue..."
read -n1 a
;;
"3") echo -e "\n--[ Application Bundle Names ]--\n"
if [ "$FILTER" != "" ]; then
plutil /private/var/mobile/Containers/Bundle/Application/*/$FILTER/Info.plist | grep CFBundleIdentifier | cut -f2 -d"\""
else
plutil /private/var/mobile/Containers/Bundle/Application/*/*/Info.plist | grep CFBundleIdentifier | cut -f2 -d"\""
fi
echo -e "\nPress any key to continue..."
read -n1 a
;;
"4") echo -e "\n--[ Application Plist Files ]--\n"
if [ "$FILTER" != "" ]; then
ls /private/var/mobile/Containers/Data/Application/$DATAFOLDER/Library/Preferences/*.plist
else
ls /private/var/mobile/Containers/Data/Application/*/Library/Preferences/*.plist
fi
echo -e "\nPress any key to continue..."
read -n1 a
;;
"5") echo -e "\n--[ Application Data Plist Files ]--\n"
if [ "$FILTER" != "" ]; then
find /private/var/mobile/Containers/Bundle/Application/$APPUUID/ -name *.plist
else
find /private/var/mobile/Containers/Bundle/Application/ -name *.plist
fi
echo -e "\nPress any key to continue..."
read -n1 a
;;
"6") echo -e "\n--[ SQL Databases ]--\n"
if [ "$FILTER" != "" ]; then
find /var/mobile/Containers/*/Application/$DATAFOLDER/ -regextype posix-egrep -regex ".*\.(sqlite|sqlitedb|sqlite3|db|storedata|store|kcr|sql|realm)$" -type f
else
find /var/mobile/Containers/*/Application/ -regextype posix-egrep -regex ".*\.(sqlite|sqlitedb|sqlite3|db|storedata|store|kcr|sql|realm)$" -type f
fi
echo -e "\nPress any key to continue..."
read -n1 a
;;
"7") echo -e "\n--[ iWatch Bundle Locations ]--\n"
if [ "$FILTER" != "" ]; then
for i in $(ls /private/var/mobile/Containers/Shared/AppGroup/*/.com.apple.mobile_container_manager.metadata.plist); do grep $BUNDLE $i | cut -f 2-8 -d"/"; done
else
ls -ld /private/var/mobile/Containers/Shared/AppGroup/* | cut -f10 -d" "
fi
echo -e "\nPress any key to continue..."
read -n1 a
;;
"8") echo -e "\n --[ Screenshot Listing ]--\n"
if [ "$FILTER" != "" ]; then
find /var/mobile/Containers/Data/Application/*/Library/Caches/Snapshots/ -type f -name *.png | grep $BUNDLE
else
find /var/mobile/Containers/Data/Application/*/Library/Caches/Snapshots/ -type f -name *.png
fi
echo -e "\nPress any key to continue..."
read -n1 a
;;
"9") echo -e "\n --[ Cookie Listing ]--\n"
if [ "$FILTER" != "" ]; then
find /private/var/mobile/Containers/Data/Application/$BUNDLE/Library/Cookies -name Cookies.binarycookies
else
find /private/var/mobile/Containers/Data/Application/*/Library/Cookies -name Cookies.binarycookies
fi
echo -e "\nPress any key to continue..."
read -n1 a
;;
"f") echo -e "\n --[ Filter Settings ]--\n"
for a in $(find /var/mobile/Containers/Bundle/Application -name *.app | cut -f8 -d/ | sort -u); do
echo " $a"
done
echo
read -p "Enter an application name listed above: " FILTER
APPFOLDER=`ls /private/var/mobile/Containers/Bundle/Application/*/* | grep $FILTER | sed 's/://'`
BUNDLE=`plutil /private/var/mobile/Containers/Bundle/Application/*/$FILTER/Info.plist | grep CFBundleIdentifier | cut -f2 -d"\""`
DATAFOLDER=`ls /private/var/mobile/Containers/Data/Application/*/Library/Preferences/*.plist | grep $BUNDLE | cut -f8 -d"/"`
LOCATION=`ls /private/var/mobile/Containers/Bundle/Application/*/* | grep $FILTER | sed 's/://'`
APPUUID=`ls /private/var/mobile/Containers/Bundle/Application/*/* | grep $FILTER | cut -f 8 -d"/"`
BINARY=`plutil $LOCATION/Info.plist | grep CFBundleExecutable | cut -f7 -d" " | sed 's/;//'`
;;
"k") echo -e "\n--[ Keychain Data ]--\n"
keychain_dumper | grep -B 4 -A 3 $BUNDLE
read -n1 a
;;
"d") analysis_archive
echo -e "\nDone! Results can be found in $OUTPUTFILE.zip - Press any key to continue.\n"
read -n1 a
;;
"q") exit 0;;
"b") binary_analysis
echo -e "\nCheck folder ./$BINARY.bin for output results\n"
read -n1 a
;;
*) echo -e "\nInvalid Option"
read -n1 a
;;
esac
analysis_archive(){
echo -e "\n--[ Creating Analysis Archive ]--"
if [ "$FILTER" != "" ]; then
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
OUTPUTFILE=`echo "$FILTER" | cut -f1 -d"."`
mkdir $OUTPUTFILE.tmp
cd $OUTPUTFILE.tmp
echo -e "Application: $FILTER" > README.txt
echo -e "Location: $LOCATION" >> README.txt
echo -e "Bundle ID: $BUNDLE" >> README.txt
echo -e "\nApplication Binary:"
zip $OUTPUTFILE.zip $LOCATION/$BINARY
echo -e "\nApplication Folder Plist Files:"
echo -e "\nApplication Folder Plist Files:" >> README.txt
for f in $(ls /private/var/mobile/Containers/Data/Application/$DATAFOLDER/Library/Preferences/*.plist); do
zip $OUTPUTFILE.zip $f
echo $f >> README.txt
done
echo -e "\nData Folder Plist Files:"
echo -e "\nData Folder Plist Files:" >> README.txt
for f in $(find /private/var/mobile/Containers/Bundle/Application/$APPUUID/ -name *.plist); do
zip $OUTPUTFILE.zip $f
echo $f >> README.txt
done
echo -e "\nSQL Database Files:"
echo -e "\nSQL Database Files:" >> README.txt
for f in $(find /var/mobile/Containers/*/Application/$DATAFOLDER/ -regextype posix-egrep -regex ".*\.(sqlite|sqlitedb|sqlite3|db|storedata|store|kcr|sql|realm)$" -type f); do
zip $OUTPUTFILE.zip "$f"
echo $f >> README.txt
done
echo -e "\nDumping Screenshots:"
echo -e "\nDumping Screenshots:" >> README.txt
for f in $(find /var/mobile/Containers/Data/Application/*/Library/Caches/Snapshots/ -type f -name *.png | grep $BUNDLE); do
zip $OUTPUTFILE.zip $f
echo $f >> README.txt
done
echo -e "\nDumping Cookies:"
echo -e "\nDumping Cookies:" >> README.txt
for f in $(find /private/var/mobile/Containers/Data/Application/$BUNDLE/Library/Cookies -name Cookies.binarycookies); do
zip $OUTPUTFILE.zip $f
echo $f >> README.txt
done
echo -e "\nDumping Keychain Data:"
echo -e "\nDumping Keychain Data: (See keychain.txt)" >> README.txt
keychain_dumper | grep -B 4 -A 3 $BUNDLE >> keychain.txt
zip $OUTPUTFILE.zip keychain.txt
binary_analysis
echo -e "\nAdding Binary Files:"
zip -r $OUTPUTFILE.zip $BINARY.bin/
rm -rf $BINARY.bin/
zip $OUTPUTFILE.zip README.txt
echo -e "\nCleaning up..."
mv $OUTPUTFILE.zip ..
cd ..
rm -rf $OUTPUTFILE.tmp
IFS=$SAVEIFS
else
echo -e "\n ** Error: Must declare a filter to continue ** \n"
fi
}
binary_analysis() {
echo -e "\n--[ Binary Informaton ]--\n"
BINARYINFO=`otool -hv $APPFOLDER/$BINARY`
ARMV7=`echo $BINARYINFO | grep V7`
ARM64=`echo $BINARYINFO | grep ARM64`
ARMV7PIE=`echo $ARMV7 | grep PIE`
ARM64PIE=`echo $ARM64 | grep PIE`
if [ ! -d "$BINARY.bin" ]; then 
mkdir $BINARY.bin
fi
cd $BINARY.bin
echo -e "\n--[ Binary Informaton ]--\n" >> ../README.txt
if [ "$ARMV7" != "" ]; then
echo "ARMV7 Binary found"
echo "ARMV7 Binary found" >> ../README.txt
echo -e "\tThinning binary: $BINARY.armv7"
echo -e "\tThinning binary: $BINARY.armv7" >> ../README.txt
lipo -thin armv7 $APPFOLDER/$BINARY -output $BINARY.armv7
if [ "$ARMV7PIE" != "" ]; then
echo -e "\tPIE enabled"
echo -e "\tPIE enabled" >> ../README.txt
else
echo "**WARNING: PIE IS NOT ENABLED**"
echo "**WARNING: PIE IS NOT ENABLED**" >> ../README.txt
fi
if [ "`otool -Iv $BINARY.armv7 | grep stack_chk_guard`" != "" ]; then
echo -e "\tStack Protections enabled"
echo -e "\tStack Protections enabled" >> ../README.txt
else
echo -e "\t**WARNING: STACK PROTECTIONS NOT ENABLED**"
echo -e "\t**WARNING: STACK PROTECTIONS NOT ENABLED**" >> ../README.txt
fi
if [ "`otool -Iv $BINARY.armv7 | grep Autorelease`" != "" ]; then
echo -e "\tARC enabled"
echo -e "\tARC enabled" >> ../README.txt
else
echo -e "\t**WARNING: ARC NOT ENABLED**"
echo -e "\t**WARNING: ARC NOT ENABLED**" >> ../README.txt
fi
if [ "`otool -L $BINARY.armv7|grep libswift`" != "" ]; then
echo -e "\tSWIFT Binary"
echo -e "\tSWIFT Binary" >> ../README.txt
else
echo -e "\tObjective C Binary"
echo -e "\tObjective C Binary" >> ../README.txt
echo -e "\tOutputting Class Information: $BINARY.armv7.class"
echo -e "\tOutputting Class Information: $BINARY.armv7.class" >> ../README.txt
echo -e "\t\t**Note: If this step fails, there may be a memory issue. Restart and try again."
echo -e "\t\t**Note: If this step fails, there may be a memory issue. Restart and try again." >> ../README.txt
class-dump $BINARY.armv7 > $BINARY.armv7.class 2>&1
fi
echo -e "\tOutputting Library information: $BINARY.armv7.lib"
echo -e "\tOutputting Library information: $BINARY.armv7.lib" >> ../README.txt
otool -L $BINARY.armv7 > $BINARY.armv7.lib
echo -e "\tOutputting Symbols: $BINARY.armv7.symbols"
echo -e "\tOutputting Symbols: $BINARY.armv7.symbols" >> ../README.txt
nm $BINARY.armv7 > $BINARY.armv7.symbols
else
echo "No ARMV7 Binary found"
echo "No ARMV7 Binary found" >> ../README.txt
fi
if [ "$ARM64" != "" ]; then
echo -e "\nARM64 Binary found"
echo -e "\nARM64 Binary found" >> ../README.txt
echo -e "\tThinning binary: $BINARY.arm64"
echo -e "\tThinning binary: $BINARY.arm64" >> ../README.txt
lipo -thin arm64 $APPFOLDER/$BINARY -output $BINARY.arm64
if [ "$ARM64PIE" != "" ]; then
echo -e "\tPIE enabled"
echo -e "\tPIE enabled" >> ../README.txt
else
echo "**WARNING: PIE IS NOT ENABLED**"
echo "**WARNING: PIE IS NOT ENABLED**" >> ../README.txt
fi
if [ "`otool -Iv $BINARY.arm64 | grep stack_chk_guard`" != "" ]; then
echo -e "\tStack Protections enabled"
echo -e "\tStack Protections enabled" >> ../README.txt
else
echo -e "\t**WARNING: STACK PROTECTIONS NOT ENABLED**"
echo -e "\t**WARNING: STACK PROTECTIONS NOT ENABLED**" >> ../README.txt
fi
if [ "`otool -Iv $BINARY.arm64 | grep Autorelease`" != "" ]; then
echo -e "\tARC enabled"
echo -e "\tARC enabled" >> ../README.txt
else
echo -e "\t**WARNING: ARC NOT ENABLED**"
echo -e "\t**WARNING: ARC NOT ENABLED**" >> ../README.txt
fi
if [ "`otool -L $BINARY.arm64|grep libswift`" != "" ]; then
echo -e "\tSWIFT Binary"
echo -e "\tSWIFT Binary" >> ../README.txt
else
echo -e "\tObjective C Binary"
echo -e "\tObjective C Binary" >> ../README.txt
fi
echo -e "\tOutputting Library information: $BINARY.arm64.lib"
echo -e "\tOutputting Library information: $BINARY.arm64.lib" >> ../README.txt
otool -L $BINARY.arm64 > $BINARY.arm64.lib
echo -e "\tOutputting Symbols: $BINARY.arm64.symbols"
echo -e "\tOutputting Symbols: $BINARY.arm64.symbols" >> ../README.txt
nm $BINARY.arm64 > $BINARY.arm64.symbols
else
echo "No ARM64 Binary found"
echo "No ARM64 Binary found" >> ../README.txt
fi
cd ..
}
done
