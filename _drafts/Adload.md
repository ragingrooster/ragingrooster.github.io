---
layout: post
title: Adload Sample, Part 1: Static Analysis
---
Happy New Year! Excuse my absense, while I have been away taking FOR508: Advanced Digital Forensics, Incident Response, and Threat Hunting, GIAC Certified Forensic Analyst (GCFA), 
and of course enjoying the holidays. Now that's all over I'm back to show you some static analysis of a macOS trojan I found today while conducting some research. 
Hope you enjoy and as always shoot any questions, or comments to ragingroosterrem@gmail.com.

### Tools Used:
- macOS High Sierra virtualized with Virtualbox
- Bash Commands: bash, cat, cd, clamscan, codesign, file, find, hdiutil, ls, md5, openssl, plutil, shasum

### The Story, YAFFD
I was googling a security tool called moloch + threat hunting and clicked on a link to what I thought was a security blog containing some juciy information 
(It was the third link, on the first page of results mind you). Instead of being served up some shortcuts on a platter, I was redirected to Yet Another Fake Flash Downloader (YAFFD). 
Okay, I'd preffer to do some malware analysis today.

<img src="{{ site.baseurl }}/images/YAFFD.png">
