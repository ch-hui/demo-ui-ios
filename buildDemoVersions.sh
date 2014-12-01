#!/bin/sh
 
#  build_Script.sh
#  iOS_IMKit_Demo
#
#  Created by Heq.Shinoda on 14-07-11.
#  Copyright (c) 2014年 Heq.Shinoda All rights reserved.


LASTVersion=$(cat versionsConfig)

TempVer=${LASTVersion%.*.*}
OlderVer=${TempVer#*.*.}
echo OlderVer=${OlderVer}
echo ${TempVer}

CurrentVer=$[OlderVer+1]

NEWVersion=${LASTVersion%.*.*.*}.$[OlderVer+1].${LASTVersion#*.*.*.}

sed -i '' "s;${OlderVer};${CurrentVer};" versionsConfig


DestDir="./bin"
ReleaseDir="./build"
version="$NEWVersion"
rm -rdf "$DestDir"
mkdir "$DestDir"
rm -rdf "$ReleaseDir"

ipafilename="iOS-IMKit-demo"                 
sourceid="RongCloud_iOSDevTeam"                     
xcodebuild clean -configuration "Release"      
targetName="iOS-IMKit-demo"
 
 
ipapath="${PWD}/${DestDir}/${targetName}_v${version}_by_${sourceid}.ipa"
 
xcodebuild -project iOS-IMKit-demo.xcodeproj -target "$targetName" -configuration "Release"  -sdk iphoneos build
appfile="${ReleaseDir}/Release-iphoneos/${targetName}.app"

echo "***开始打ipa包****"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "$appfile" -o "$ipapath" --sign "iPhone Distribution: Feinno Communication Tech Co. Ltd."

