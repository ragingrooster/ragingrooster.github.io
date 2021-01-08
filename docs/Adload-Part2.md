---
layout: default
---

Importing ClamAV Hashset into X-ways Forensics - 2019/01/17
==================================

Part 2 of my Adload analysis, demonstrating Triage Analysis to extract some quick IOCs.


TLDR:

#### Malware Triage
Triaging malware is the quick and dirty approach to analysis, much like applying a tourniquet to stop someone from bleeding. Sometimes analysts just need results quickly, so they collect enough relevant information from the sample to identify and remove it from the affected system(s). Reverse Engineering a binary is the best way to figure out exactly what the malware does, but sometimes time is of the essence.

##### Essential Information:
```
Filename
Hashes
File Properties
Code Signature
AV Detection
Strings
Processes
Filesystem Changes
Network Communications
```
#### Triaging the Adload sample.

I showed a few of these steps in my previous post, so I'll just fill in the info I already presented and pick up from there.

##### Filename:
```
CAC4DD3330C6
```

##### Hashes
```
MD5 aa07958f8a08b275c799a8975171ad76
SHA-1 ed26d23f8fa527e036de118b6c4d182b6159f878
SHA-256 a23c9488d26bf65b1b5209c042b8340304d295cdfc55f2f31cb89d3511f9634d
SSDeep 12288:hHdJmX8Z0J0cBzKKjXgQBGmEvvwN56K/dXUA0ZVG21bLNKGm:pmu0JbzjXsXwv6adXUAQXdbm
```

##### File Properties:
```
$ file
Mach-O 64-bit executable x86_64

$ otool -h CAC4DD3330C6
Mach header
	magic cputype cpusubtype caps	filetype ncmds sizeofcmds	flags
 0xfeedfacf 16777223	    3 0x80		   2     27       3984 0x00218085
```
_Using otool I confirmed that the Mach-O file is indeed a 64-bit executable based on the magic number, 0xfeedfacf._

##### Code Signature
```
$ codesign -dvvv CAC4DD3330C6
Executable=/REDACTED-FILE-PATH/CAC4DD3330C6
Identifier=com.CAC4DD3330C6
Format=Mach-O thin (x86_64)
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
Info.plist entries=not bound
TeamIdentifier=34C3U9CXLW
Sealed Resources=none
Internal requirements count=1 size=176
```

##### AV Detection
Here is where I want to show you a cool trick that I learned from Chapter 3 of the Malware Analyst's Cookbook [2].

###### First, I updated my ClamAV signatures (important step). Then, I unpacked them using sigtool.
```
$ sigtool -u main.cvd

$ sigtool -u daily.cvd
```

###### Next, I scanned the suspicious file again with clamscan to get the signature name...
```Get-Content
$ clamscan ~/Desktop/CAC4DD3330C6
CAC4DD3330C6: Osx.Trojan.Generic-6776032-0 FOUND

----------- SCAN SUMMARY -----------
Known viruses: 6772866
Engine version: 0.100.0
Scanned directories: 0
Scanned files: 1
Infected files: 1
Data scanned: 0.73 MB
Data read: 0.73 MB (ratio 1.01:1)
Time: 17.293 sec (0 m 17 s)
```
###### And then searched the directory of unpacked signatures:
```
$ grep 'Osx.Trojan.Generic-6776032-0' *
daily.ldb:Osx.Trojan.Generic-6776032-0;Engine:51-255,Target:9;0&1&2&3&4;4e5374335f5f3131305f5f66756e6374696f6e365f5f66756e63495a36352d5b4170705f64656c656761746520776562566965773a6469644661696c50726f766973696f6e616c4c6f6164576974684572726f723a666f724672616d653a5d4533245f324e535f39616c6c6f6361746f724953325f4545467676454545;405f5f5a4e5374335f5f3131375f5f6173736f635f7375625f737461746531305f5f7375625f7761697445524e535f3131756e697175655f6c6f636b494e535f356d75746578454545;4e5374335f5f3132305f5f7368617265645f7074725f656d706c616365494e346173696f313962617369635f73747265616d5f736f636b6574494e53315f32697033746370454e53315f323173747265616d5f736f636b65745f736572766963654953345f454545454e535f39616c6c6f6361746f724953375f45454545;4e5374335f5f3132305f5f7368617265645f7074725f656d706c616365494e346173696f326970313462617369635f7265736f6c766572494e53325f33746370454e53325f31367265736f6c7665725f736572766963654953345f454545454e535f39616c6c6f6361746f724953375f45454545;4e346173696f3664657461696c3132706f7369785f7468726561643466756e63494e53305f32317265736f6c7665725f736572766963655f626173653232776f726b5f696f5f736572766963655f72756e6e6572454545
```
_Now I can see why the sample was detected by ClamAV._

###### Next, I broke up the hex where there is a semicolon and converted the Hex to ASCII.
```
$ echo '4e5374335f5f3131305f5f66756e6374696f6e365f5f66756e63495a36352d5b4170705f64656c656761746520776562566965773a6469644661696c50726f766973696f6e616c4c6f6164576974684572726f723a666f724672616d653a5d4533245f324e535f39616c6c6f6361746f724953325f4545467676454545' | xxd -r -p
NSt3__110__function6__funcIZ65-[App_delegate webView:didFailProvisionalLoadWithError:forFrame:]E3$_2NS_9allocatorIS2_EEFvvEEE

$ echo '405f5f5a4e5374335f5f3131375f5f6173736f635f7375625f737461746531305f5f7375625f7761697445524e535f3131756e697175655f6c6f636b494e535f356d75746578454545' | xxd -r -p
@__ZNSt3__117__assoc_sub_state10__sub_waitERNS_11unique_lockINS_5mutexEEE

$ echo '4e5374335f5f3132305f5f7368617265645f7074725f656d706c616365494e346173696f313962617369635f73747265616d5f736f636b6574494e53315f32697033746370454e53315f323173747265616d5f736f636b65745f736572766963654953345f454545454e535f39616c6c6f6361746f724953375f45454545' | xxd -r -p
NSt3__120__shared_ptr_emplaceIN4asio19basic_stream_socketINS1_2ip3tcpENS1_21stream_socket_serviceIS4_EEEENS_9allocatorIS7_EEEE

$echo '4e5374335f5f3132305f5f7368617265645f7074725f656d706c616365494e346173696f326970313462617369635f7265736f6c766572494e53325f33746370454e53325f31367265736f6c7665725f736572766963654953345f454545454e535f39616c6c6f6361746f724953375f45454545' | xxd -r -p
NSt3__120__shared_ptr_emplaceIN4asio2ip14basic_resolverINS2_3tcpENS2_16resolver_serviceIS4_EEEENS_9allocatorIS7_EEEE

$echo '4e346173696f3664657461696c3132706f7369785f7468726561643466756e63494e53305f32317265736f6c7665725f736572766963655f626173653232776f726b5f696f5f736572766963655f72756e6e6572454545' | xxd -r -p
N4asio6detail12posix_thread4funcINS0_21resolver_service_base22work_io_service_runnerEEE
```
##### So, the signature is checking for the presence of these strings:
```
1. NSt3__110__function6__funcIZ65-[App_delegate webView:didFailProvisionalLoadWithError:forFrame:]E3$_2NS_9allocatorIS2_EEFvvEEE
2. @__ZNSt3__117__assoc_sub_state10__sub_waitERNS_11unique_lockINS_5mutexEEE
3. NSt3__120__shared_ptr_emplaceIN4asio19basic_stream_socketINS1_2ip3tcpENS1_21stream_socket_serviceIS4_EEEENS_9allocatorIS7_EEEE
4. NSt3__120__shared_ptr_emplaceIN4asio2ip14basic_resolverINS2_3tcpENS2_16resolver_serviceIS4_EEEENS_9allocatorIS7_EEEE
5. N4asio6detail12posix_thread4funcINS0_21resolver_service_base22work_io_service_runnerEEE
```
_Googling some of the functions brings you to Total Hash and a related Adload sample from May, 2018_ <https://totalhash.cymru.com/analysis/?ac7ccfd1dd2701c38fda39d89ae53e1d71c8b7b8>

##### Strings

"Strings are ASCII and Unicode-printable sequences of characters embedded within a file. Extracting strings can give clues about the program functionality and indicators associated with a suspect binary." [1]

This little tool is really handy when examining binaries and can reveal IOCs such as functions, commands, filenames, network data, etc.

I redirected the output of the program to a text file for analysis and was able to locate the functions from the ClamAV signature in the output of strings:
```
$ strings CAC4DD3330C6 > strings

$ grep 'NSt3__110__function6__funcIZ65-' strings 
NSt3__110__function6__funcIZ65-[App_delegate webView:didFailProvisionalLoadWithError:forFrame:]E3$_2NS_9allocatorIS2_EEFvvEEE

$ grep 'ZNSt3__117__assoc_sub_state10' strings 
@__ZNSt3__117__assoc_sub_state10__sub_waitERNS_11unique_lockINS_5mutexEEE

$ grep 'NSt3__120__shared_ptr_emplaceIN4asio' strings 
NSt3__120__shared_ptr_emplaceIN4asio19basic_stream_socketINS1_2ip3tcpENS1_21stream_socket_serviceIS4_EEEENS_9allocatorIS7_EEEE
NSt3__120__shared_ptr_emplaceIN4asio2ip14basic_resolverINS2_3tcpENS2_16resolver_serviceIS4_EEEENS_9allocatorIS7_EEEE

$ grep 'N4asio6detail12posix_thread4funcINS0_21resolver_service_base22work_io_service_runnerEEE' strings 
N4asio6detail12posix_thread4funcINS0_21resolver_service_base22work_io_service_runnerEEE

```
_At this point I have confirmed that all of the strings the signature was looking for are present in the binary and I've converted them to a human readable format._

Some other interesting data I found in strings were directory locations (we'll see these again later):
```
$ grep -E '/[a-z0-9]{0,10}/' strings 
/usr/bin/hdiutil
/usr/bin/open
```

For the next few steps the quickest and easiest way to get answers was to sumbit the sample to VirusTotal and analyze the results (Automated Behavioral Analysis):

#### Processes Created
```
/System/Library/Frameworks/CoreServices.framework/Frameworks/Metadata.framework/Versions/A/Support/mdwrite
/Users/user1/client/tmp/a23c9488d26bf65b1b5209c042b8340304d295cdfc55f2f31cb89d3511f9634d/sample.bin
/usr/bin/hdiutil info -plist
/System/Library/Frameworks/QuickLook.framework/Resources/quicklookd.app/Contents/MacOS/quicklookd
```

#### Filesystem Changes
<details>
<summary>Files Opened</summary>
<br>
/System/Library/Frameworks/CoreServices.framework/Frameworks/Metadata.framework/Versions/A/Support
/System/Library/Frameworks/CoreServices.framework/Frameworks/Metadata.framework/Versions/A/Support/mdwrite
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/Metadata.framework/Versions
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/Metadata.framework/Versions/Resources/Info.plist
/System/Library/PrivateFrameworks/Heimdal.framework/Heimdal
/System/Library/PrivateFrameworks/Heimdal.framework/Versions/Current
/Users/user1/.CFUserTextEncoding
/System/Library/Frameworks/GSS.framework/GSS
/System/Library/Frameworks/GSS.framework/Versions/Current
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/com.apple.QuickLook.thumbnailcache/dirty
/etc/master.passwd
/tmp
/private/tmp/CommCenter.KeepAlive.Enabled
/private/tmp
/Library/Keychains/crls/update-current
/Library/Keychains/crls/valid.sqlite3-journal
/Library/Keychains/crls
/Users/user1/client/tmp/a23c9488d26bf65b1b5209c042b8340304d295cdfc55f2f31cb89d3511f9634d
/Users/user1/client/tmp/a23c9488d26bf65b1b5209c042b8340304d295cdfc55f2f31cb89d3511f9634d/sample.bin
/var/db/timezone/icutz/icutz44l.dat
/var/db/timezone/zoneinfo/posixrules
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/com.apple.trustd/mds/mds.lock
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/com.apple.trustd/mds/mdsObject.db_
/private/var/db/mds/system/mdsObject.db
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/com.apple.trustd/mds/mdsDirectory.db_
/private/var/db/mds/system/mdsDirectory.db
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/com.apple.trustd/mds/mdsObject.db
/System/Library/Security
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/com.apple.trustd/mds/mdsDirectory.db
/Users/user1/Library/Security
/Users/user1/Library/Keychains/login.keychain-db
/System/Library/Keychains/SystemRootCertificates.keychain
/Library/Keychains/System.keychain
/System/Library/Input Methods/PressAndHold.app/Contents/PlugIns/PAH_Extension.appex
/System/Library/CoreServices/FolderActionsDispatcher.app
/System/Library/CoreServices/FolderActionsDispatcher.app/Contents
/System/Library/CoreServices/FolderActionsDispatcher.app/Contents/Info.plist
/System/Library/CoreServices/FolderActionsDispatcher.app/Contents/MacOS/FolderActionsDispatcher
/System/Library/CoreServices/FolderActionsDispatcher.app/Contents/_CodeSignature/CodeRequirements-1
/System/Library/CoreServices/System Events.app
/System/Library/CoreServices/System Events.app/Contents
/System/Library/CoreServices/System Events.app/Contents/Info.plist
/System/Library/CoreServices/System Events.app/Contents/MacOS/System Events
/System/Library/CoreServices/System Events.app/Contents/_CodeSignature/CodeRequirements-1
/private/var/db/uuidtext/B3
/private/var/db/uuidtext/BE
/private/var/db/uuidtext/88
/private/var/db/uuidtext/D0
/private/var/db/uuidtext/1B
/private/var/db/uuidtext/D2
/private/var/db/uuidtext/38
/private/var/db/uuidtext/F3
/private/var/db/uuidtext/1E
/private/var/db/uuidtext/D8
/System/Library/PrivateFrameworks/CoreServicesInternal.framework/CoreServicesInternal
/System/Library/PrivateFrameworks/CoreServicesInternal.framework/Versions/Current
/System/Library/Frameworks/CoreServices.framework/Frameworks
/System/Library/Frameworks/CoreServices.framework/Versions/Current
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/LaunchServices
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/Current
/System/Library/Frameworks/ApplicationServices.framework/Frameworks
/System/Library/Fonts/SFNSText.ttf
/System/Library/Frameworks/ApplicationServices.framework/Frameworks/ATS.framework
/System/Library/Frameworks/ApplicationServices.framework/Frameworks/ATS.framework/Resources
/System/Library/Frameworks/ApplicationServices.framework/Frameworks/ATS.framework/Resources/Info.plist
/System/Library/Frameworks/ApplicationServices.framework/Frameworks/ATS.framework/Resources/English.lproj
/System/Library/Frameworks/ApplicationServices.framework/Frameworks/ATS.framework/Resources/Base.lproj
/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ATS.framework/Resources
/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/ATS.framework/Versions/Current
/Library/Application Support/CrashReporter/SubmitDiagInfo.domains
/usr/share/icu/icudt59l.dat
/System/Library/Frameworks/ColorSync.framework/ColorSync
/System/Library/Frameworks/ColorSync.framework/Versions/Current
/System/Library/CoreServices/SystemAppearance.bundle/Contents/Resources/VibrantLightAppearance.car
/System/Library/Frameworks/CoreText.framework/CoreText
/System/Library/Frameworks/CoreText.framework/Versions/Current
/Users/user1/client/tmp/a23c9488d26bf65b1b5209c042b8340304d295cdfc55f2f31cb89d3511f9634d/en.lproj
/Users/user1/client/tmp/a23c9488d26bf65b1b5209c042b8340304d295cdfc55f2f31cb89d3511f9634d/Base.lproj
/System/Library/CoreServices/SystemAppearance.bundle
/System/Library/CoreServices/SystemAppearance.bundle/Contents
/System/Library/CoreServices/SystemAppearance.bundle/Contents/Info.plist
/System/Library/CoreServices/SystemAppearance.bundle/Contents/Resources
/System/Library/CoreServices/SystemAppearance.bundle/Contents/Resources/en.lproj
/System/Library/CoreServices/SystemAppearance.bundle/Contents/Resources/Base.lproj
/System/Library/CoreServices/SystemAppearance.bundle/Contents/Resources/English.lproj
/System/Library/CoreServices/SystemAppearance.bundle/Contents/Resources/SystemAppearance.car
/Users/user1/Library/Preferences/com.apple.LaunchServices/com.apple.LaunchServices.plist
/Users/user1/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure.plist
/System/Library/Frameworks/OpenCL.framework/Libraries
/System/Library/Frameworks/OpenCL.framework/Versions/Current
/Users/user1/client/tmp/a23c9488d26bf65b1b5209c042b8340304d295cdfc55f2f31cb89d3511f9634d/sample.bin/..namedfork/rsrc
/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics
/System/Library/Frameworks/CoreGraphics.framework/Versions/Current
/System/Library/Frameworks/Accelerate.framework/Frameworks
/System/Library/Frameworks/Accelerate.framework/Versions/Current
/System/Library/Frameworks/AppKit.framework/Versions/Current
/System/Library/Frameworks/AppKit.framework
/System/Library/Frameworks/AppKit.framework/Resources
/System/Library/Frameworks/AppKit.framework/Resources/Info.plist
/System/Library/Frameworks/AppKit.framework/AppKit
/System/Library/Frameworks/AppKit.framework/Resources/English.lproj
/System/Library/Frameworks/AppKit.framework/Resources/Base.lproj
/System/Library/Frameworks/AppKit.framework/English.lproj
/System/Library/Frameworks/AppKit.framework/Base.lproj
/System/Library/Frameworks/Carbon.framework/Versions/A/Frameworks/HIToolbox.framework/Resources/Extras2.rsrc
/System/Library/CoreServices/SystemAppearance.bundle/Contents/Resources/Assets.car
/System/Library/PrivateFrameworks/CoreUI.framework
/System/Library/PrivateFrameworks/CoreUI.framework/Resources
/System/Library/PrivateFrameworks/CoreUI.framework/Resources/Info.plist
/System/Library/PrivateFrameworks/CoreUI.framework/CoreUI
/System/Library/PrivateFrameworks/CoreUI.framework/Versions/Current
/System/Library/PrivateFrameworks/CoreUI.framework/Resources/English.lproj
/System/Library/PrivateFrameworks/CoreUI.framework/Resources/Base.lproj
/System/Library/PrivateFrameworks/CoreUI.framework/Resources/DuplicateImageNames.plist
/System/Library/Frameworks/AVFoundation.framework/AVFoundation
/System/Library/Frameworks/AVFoundation.framework/Versions/Current
/System/Library/Frameworks/CoreMedia.framework/CoreMedia
/System/Library/Frameworks/CoreMedia.framework/Versions/Current
/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/HIServices
/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/Current
/System/Library/Frameworks/CFNetwork.framework/Resources/CFNETWORK_DIAGNOSTICS
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/mds/mds.lock
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/mds/mdsObject.db_
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/mds/mdsDirectory.db_
/var
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/mds/mdsObject.db
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/mds/mdsDirectory.db
/System/Library/Security/Certificates.bundle
/System/Library/Security/Certificates.bundle/Contents
/System/Library/Security/Certificates.bundle/Contents/Info.plist
/System/Library/Security/Certificates.bundle/Contents/Resources
/System/Library/Security/Certificates.bundle/Contents/Resources/en.lproj
/System/Library/Security/Certificates.bundle/Contents/Resources/Base.lproj
/var/db/DetachedSignatures
/Library/Preferences/com.apple.security.plist
/System/Library/Keychains/SystemTrustSettings.plist
/System/Library/Frameworks/Security.framework
/System/Library/Frameworks/Security.framework/Resources
/System/Library/Frameworks/Security.framework/Resources/Info.plist
/System/Library/Frameworks/Security.framework/Security
/System/Library/Frameworks/Security.framework/Versions/Current
/System/Library/Frameworks/Security.framework/PlugIns/csparser.bundle
/System/Library/Frameworks/Security.framework/PlugIns/csparser.bundle/Contents
/System/Library/Frameworks/Security.framework/PlugIns/csparser.bundle/Contents/Info.plist
/System/Library/Frameworks/Security.framework/PlugIns
/System/Library/Frameworks/Security.framework/PlugIns/csparser.bundle/Contents/MacOS/csparser
/System/Library/Frameworks/Security.framework/Resources/en.lproj
</details>

<details>
<summary>Files Written</summary>
<br>
/Library/Keychains/crls/update-current
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/com.apple.trustd/mds/mdsDirectory.db_
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/com.apple.trustd/mds/mdsObject.db_
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/mds/mdsDirectory.db_
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/mds/mdsObject.db_
/var/folders/zz/zyxvpxvq6csfxvn_n00000y800007k/0/com.apple.nsurlsessiond/E9212A19021CA201C088F817871E6655AAA579B9/4B3DCC907D170D9B88EEE5CFB9F619791CDF0FA4/.dat.nosync0098.89YA60
/var/folders/zz/zyxvpxvq6csfxvn_n00000y800007k/0/com.apple.nsurlsessiond/E9212A19021CA201C088F817871E6655AAA579B9/4B3DCC907D170D9B88EEE5CFB9F619791CDF0FA4/.dat.nosync0098.3Cmnr9
/var/folders/zz/zyxvpxvq6csfxvn_n00000y800007k/0/com.apple.nsurlsessiond/E9212A19021CA201C088F817871E6655AAA579B9/4B3DCC907D170D9B88EEE5CFB9F619791CDF0FA4/.dat.nosync0098.DStapC
/System/Library/PrivateFrameworks/CoreServicesInternal.framework/Versions/Current
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/T/TemporaryItems/(A Document Being Saved By Quick Look Helper)/thumbnails.fraghandler
</details>

<details>
<summary>Files Copied</summary>
<br>
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/com.apple.trustd//mds/mdsObject.db_
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C/com.apple.trustd//mds/mdsDirectory.db_
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C//mds/mdsObject.db_
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/C//mds/mdsDirectory.db_
/var/folders/zz/zyxvpxvq6csfxvn_n00000y800007k/0/com.apple.nsurlsessiond/E9212A19021CA201C088F817871E6655AAA579B9/4B3DCC907D170D9B88EEE5CFB9F619791CDF0FA4/.dat.nosync0098.DStapC
/var/folders/zz/zyxvpxvq6csfxvn_n00000y800007k/0/com.apple.nsurlsessiond/E9212A19021CA201C088F817871E6655AAA579B9/4B3DCC907D170D9B88EEE5CFB9F619791CDF0FA4/.dat.nosync0098.3Cmnr9
/var/folders/zz/zyxvpxvq6csfxvn_n00000y800007k/0/com.apple.nsurlsessiond/E9212A19021CA201C088F817871E6655AAA579B9/4B3DCC907D170D9B88EEE5CFB9F619791CDF0FA4/.dat.nosync0098.89YA60
/var/folders/4c/2j7t8wj96cngjk55x3sm1t2c0000gn/T/TemporaryItems/(A Document Being Saved By Quick Look Helper)/thumbnails.fraghandler
</details>

<details>
<summary>Files Dropped</summary>
<br>
 /System/Library/PrivateFrameworks/CoreUI.framework/CoreUI
/System/Library/Frameworks/MediaToolbox.framework/MediaToolbox
/System/Library/PrivateFrameworks/Heimdal.framework/Heimdal
/System/Library/Frameworks/NetworkExtension.framework/NetworkExtension
/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/HIServices
/System/Library/PrivateFrameworks/WirelessDiagnostics.framework/WirelessDiagnostics
/System/Library/PrivateFrameworks/CoreServicesInternal.framework/CoreServicesInternal
/System/Library/Frameworks/GSS.framework/GSS
/System/Library/Frameworks/AVFoundation.framework/AVFoundation
/System/Library/Frameworks/AppKit.framework/AppKit
/System/Library/Frameworks/CoreMedia.framework/CoreMedia
/System/Library/Frameworks/Security.framework/Security
/System/Library/Frameworks/VideoToolbox.framework/VideoToolbox
/System/Library/Frameworks/QuickLook.framework/Versions/A/Resources/quicklookd.app/Contents/MacOS/quicklookd
/System/Library/Frameworks/CoreText.framework/CoreText
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/LaunchServices
/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics
/System/Library/Frameworks/ColorSync.framework/ColorSync
</details>

#### Network Communications
<details>
<summary>HTTP Requests</summary>
<br>
http://init-p01st[.]push[.]apple[.]com/bag
http://cdn[.]masteranalyser[.]com/screens/precheck/_pl_2JybQ==
http://cdn[.]masteranalyser[.]com/styles/scss/3
http://cdn[.]masteranalyser[.]com/product/logo/SGFybQ%3D%3D
http://cdn[.]masteranalyser[.]com/images/2c6626d2-7204-4aec-a2b7-efdf7ddf98e7
http://cdn[.]masteranalyser[.]com/scripts/jq
http://cdn[.]masteranalyser[.]com/scripts/mjs
http://cdn[.]masteranalyser[.]com/scripts/sjs/3
http://cdn[.]masteranalyser[.]com/favicon.ico
</details>

### Summary
So, what did I learn about this sample through Triage Analysis?

1. It's detected by ClamAV as Osx.Trojan.Generic-6776032-0 and numerous AV vendors as Adload.
2. The ClamAV Signature is looking for 5 specific functions seen across different variants of Adload (see above).
3. Adload is a Trojan Downloader (see VT results).
4. This sample tries to access System Trust Settings (see Filesystem section above).
5. The sample makes HTTP requests to cdn[.]masteranalyser[.]com.

A more indepth analysis could uncover more details, but by conducting a quick triage of the sample I can already tell this isn't something I would want on my system.. would you?

#### References
1. Learning Malware Analysis by Monnappa K A. Publisher: Packt Publishing. Release Date: June 2018. ISBN: 9781788392501
2. Malware Analyst's Cookbook and DVD: Tools and Techniques for Fighting Malicious Code by Matthew Richard, Blake Hartstein, Steven Adair, Michael Hale Ligh. Publisher: John Wiley & Sons. Release Date: November 2010. ISBN: 9780470613030.
3. <https://www.virustotal.com/#/file/a23c9488d26bf65b1b5209c042b8340304d295cdfc55f2f31cb89d3511f9634d/details>

[back](./)
