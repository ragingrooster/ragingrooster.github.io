---
layout: post
title: Adload Sample, Part 2. Triage.
---
In previous posts I mentioned static and behavioral analysis and how they differ, but I haven't discussed triage yet. Thus, I decided to shift the focus on analysis of this sample to show you how to triage malware, because quite frankly it's a good sample to do just that.

TLDR:

#### Malware Triage
Triaging malware is the quick and dirty approach to analysis, much like applying a tourniquet to stop someone from bleeding. Sometimes analysts just need results quickly, so they collect enough relevant information from the sample to identify and remove it from the affected system(s). Reverse Engineering a binary is the best way to figure out exactly what the malware does, but sometimes time is of the essence.

##### Essential Information:
Hashes, File Properties, Code Signature, AV Detection, Strings, Processes Created, Files Opened/Read/Written/Moved, Network Communications

#### Triaging the Adload sample.

I showed a few of these steps in my previous post, so I'll just fill in the info I already presented and pick up from there.

##### Filename:
```
CAC4DD3330C6
```

##### Hashes
```
MD5	aa07958f8a08b275c799a8975171ad76
SHA-1 ed26d23f8fa527e036de118b6c4d182b6159f878
SHA-256 a23c9488d26bf65b1b5209c042b8340304d295cdfc55f2f31cb89d3511f9634d
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

###### Code Signature
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
Here is where I want to show you a cool trick that I learned from Chapter 3: Malware Classification of the Malware Analyst's Cookbook and DVD.

First, I updated my ClamAV signatures (important step). Then, I unpacked them using sigtool.
```
$ sigtool -u main.cvd

$ sigtool -u daily.cvd
```

Next, I scanned the suspicious file again with clamscan to get the signature name...
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
And then searched the unpacked signatures for it.
```
$ grep 'Osx.Trojan.Generic-6776032-0' *
daily.ldb:Osx.Trojan.Generic-6776032-0;Engine:51-255,Target:9;0&1&2&3&4;4e5374335f5f3131305f5f66756e6374696f6e365f5f66756e63495a36352d5b4170705f64656c656761746520776562566965773a6469644661696c50726f766973696f6e616c4c6f6164576974684572726f723a666f724672616d653a5d4533245f324e535f39616c6c6f6361746f724953325f4545467676454545;405f5f5a4e5374335f5f3131375f5f6173736f635f7375625f737461746531305f5f7375625f7761697445524e535f3131756e697175655f6c6f636b494e535f356d75746578454545;4e5374335f5f3132305f5f7368617265645f7074725f656d706c616365494e346173696f313962617369635f73747265616d5f736f636b6574494e53315f32697033746370454e53315f323173747265616d5f736f636b65745f736572766963654953345f454545454e535f39616c6c6f6361746f724953375f45454545;4e5374335f5f3132305f5f7368617265645f7074725f656d706c616365494e346173696f326970313462617369635f7265736f6c766572494e53325f33746370454e53325f31367265736f6c7665725f736572766963654953345f454545454e535f39616c6c6f6361746f724953375f45454545;4e346173696f3664657461696c3132706f7369785f7468726561643466756e63494e53305f32317265736f6c7665725f736572766963655f626173653232776f726b5f696f5f736572766963655f72756e6e6572454545
```
_Now I can see why the sample was detected by ClamAV._

Next, I Broke up the hex where there is a ";" and searched with a hex editor. Here's the results:
```
4e5374335f5f3131305f5f66756e6374696f6e365f5f66756e63495a36352d5b4170705f64656c656761746520776562566965773a6469644661696c50726f766973696f6e616c4c6f6164576974684572726f723a666f724672616d653a5d4533245f324e535f39616c6c6f6361746f724953325f4545467676454545

	found at offset 528544 in iHex

		NSt3__110__function6__funcIZ65-[App_delegate webView:didFailProvisionalLoadWithError:forFrame:]E3$_2NS_9allocatorIS2_EEFvvEEE

		https://developer.apple.com/documentation/webkit/webframeloaddelegate/1501459-webview


405f5f5a4e5374335f5f3131375f5f6173736f635f7375625f737461746531305f5f7375625f7761697445524e535f3131756e697175655f6c6f636b494e535f356d75746578454545

	found at offset 700130 in Hex Fiend

		@__ZNSt3__117__assoc_sub_state10__sub_waitERNS_11unique_lockINS_5mutexEEE

4e5374335f5f3132305f5f7368617265645f7074725f656d706c616365494e346173696f313962617369635f73747265616d5f736f636b6574494e53315f32697033746370454e53315f323173747265616d5f736f636b65745f736572766963654953345f454545454e535f39616c6c6f6361746f724953375f45454545

	found at offset 533792 in Hex Fiend

		NSt3__120__shared_ptr_emplaceIN4asio19basic_stream_socketINS1_2ip3tcpENS1_21stream_socket_serviceIS4_EEEENS_9allocatorIS7_EEEE

4e5374335f5f3132305f5f7368617265645f7074725f656d706c616365494e346173696f326970313462617369635f7265736f6c766572494e53325f33746370454e53325f31367265736f6c7665725f736572766963654953345f454545454e535f39616c6c6f6361746f724953375f45454545

	found at offset 534128 in Hex Fiend

		NSt3__120__shared_ptr_emplaceIN4asio2ip14basic_resolverINS2_3tcpENS2_16resolver_serviceIS4_EEEENS_9allocatorIS7_EEEE

4e346173696f3664657461696c3132706f7369785f7468726561643466756e63494e53305f32317265736f6c7665725f736572766963655f626173653232776f726b5f696f5f736572766963655f72756e6e6572454545

	found at offset 530976 in Hex Fiend

		N4asio6detail12posix_thread4funcINS0_21resolver_service_base22work_io_service_runnerEEE
```
_Tada, I have confirmed that all of the strings the signature was looking for are present in the binary and converted them to ASCII. A Google search for the strings should bring you to Cymru's Totalhash Malware Analysis Database. <https://totalhash.cymru.com/analysis/?ac7ccfd1dd2701c38fda39d89ae53e1d71c8b7b8>_

##### Strings
Speaking of strings:

"Strings are ASCII and Unicode-printable sequences of characters embedded within a file. Extracting strings can give clues about the program functionality and indicators associated with a suspect binary." [1]

This little tool is really handy when examining binaries and can reveal IOCs such as functions, commands, filenames, network data, etc.

I redirected the output of the program to a text file for analysis. The output for this sample was 1109 lines, so I uploaded it here <>.

I was able to locate the functions from the ClamAV signature in the output of strings:
```

```

Other interesting data points were:
```

```
#### Processes Created



#### Files Opened/Read/Written/Moved

#### Network Communications

```
http://init-p01st[.]push[.]apple[.]com/bag
http://cdn[.]masteranalyser[.]com/screens/precheck/_pl_2JybQ==
http://cdn[.]masteranalyser[.]com/styles/scss/3
http://cdn[.]masteranalyser[.]com/product/logo/SGFybQ%3D%3D
http://cdn[.]masteranalyser[.]com/images/2c6626d2-7204-4aec-a2b7-efdf7ddf98e7
http://cdn[.]masteranalyser[.]com/scripts/jq
http://cdn[.]masteranalyser[.]com/scripts/mjs
http://cdn[.]masteranalyser[.]com/scripts/sjs/3
http://cdn[.]masteranalyser[.]com/favicon.ico
```

#### References
[1] Learning  Malware Analysis
