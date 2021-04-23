---
layout: default
---

Importing ClamAV Hashset into X-ways Forensics
==================================

## Intro:
The Xways manual states that you can import _"a very simple and universal hash set text file, where the first line is simply the hash type (e.g. "MD5") and all the following lines are  simply  the  hash  values  as  ASCII  hex  or  (for  SHA-1)  in  Base32  notation,  one  per  line.  Line  break is 0x0D 0x0A"_ [1]. This allows you to check a suspect file against a hashset without exporting it and preforming a lookup.

## Getting the hashes:
It's easiest to do this in Linux, we only need to install ClamAV to get sigtool. You could use freshclam to get the AV sigs, but I found this process cleaner:
```
sudo apt install clamav
mkdir sigs && cd
wget http://database.clamav.net/main.cvd
wget http://database.clamav.net/daily.cvd
sigtool --unpack main.cvd
sigtool --unpack daily.cvd
grep -Eo '[a-fA-F0-9]{32}' main.hdb >> ClamAVHashes.txt
grep -Eo '[a-fA-F0-9]{32}' daily.hdb >> ClamAVHashes.txt
```
OPTIONAL:
```
cp ClamAVHashes.txt /media/$USER/$USB/ClamAVHashes.txt
```
But, you could also use PowerShell:
```
sigtool.exe --unpack .\daily.cld
sigtool.exe --unpack .\main.cld
Select-String -Path .\daily.hdb -Pattern '^[a-f0-9]{32}' | ForEach-Object { $_.Matches } | % { $_.Values } | Out-File 'ClamAVHashes.txt'
Select-String -Path .\main.hdb -Pattern '^[a-f0-9]{32}' | ForEach-Object { $_.Matches } | % { $_.Values } | Out-File -Append 'ClamAVHashes.txt'
```

## Formatting:
- Edit ClamAVHashes.txt in Notepad++
- Add "MD5" (no quotes) to Line 1
- "CTRL+A", Right Click, convert to UPPERCASE
- Set encoding to "UTF-8 BOM"
- Make sure there's an empty line at the end of the file
- Save AS ".hsh"

Here's an example of my ClamAVHashes.hsh:
```
MD5
B10A8DB164E0754105B7A99BE72E3FE5
C76F0F3840E9EF0CC2C896B16EE81FC0
 
```
## Adding to Xways:
- In the Menu go to Tools > Hash Database (or CTRL+F2)
- Select "Import", then select ClamAVHashes.hsh
- Wait for the file to import than hit close, that's it!

## Running against drive:
See [Hashing in X-Ways Forensics on SALT4N6's site](salt4n6.com/2018/05/07/hashing-in-x-ways-forensics/

## Refs:
1. [Xways User Guide 5.18 Hash Database ](http://www.x-ways.net/winhex/manual.pdf#%5B%7B%22num%22%3A521%2C%22gen%22%3A0%7D%2C%7B%22name%22%3A%22XYZ%22%7D%2C0%2C792%2Cnull%5D)

[back](./)
