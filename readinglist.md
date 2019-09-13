# Windows Malware

## Training/Workshops

### Intro
* https://malwaretips.com/threads/malware-analysis-1-introduction.61972/
* https://malwaretips.com/tags/malware-analysis/

### Triage
* https://www.openanalysis.net/training/Crowdsourced_Malware_Triage_-_Workshop.pdf
* https://www.openanalysis.net/training/Malware_Triage_Workshop-Malscripts_Are_The_New_EK.pdf
* https://www.openanalysis.net/training/Malware_Triage_IOCs.pdf
* https://countuponsecurity.com/2015/02/16/static-malware-analysis-find-malicious-intent/

### Analysis
* https://samsclass.info/126/126_S17.shtml
* https://github.com/RPISEC/Malware
* https://maxkersten.nl/binary-analysis-course/
* https://malwareunicorn.org/#/workshops
* https://oalabs.openanalysis.net/tag/tutorials/

# Windows DFIR

## Info
* https://windowsir.blogspot.com/

## Tools
* https://ericzimmerman.github.io/#!index.md
* http://blog.didierstevens.com/didier-stevens-suite/
* https://github.com/marcurdy/dfir-toolset/blob/master/ToolsOfTheGame.md

## Powershell
* https://www.dionach.com/blog/powershell-in-forensic-investigations
* https://github.com/mgreen27/Invoke-LiveResponse
* https://www.ldap389.info/en/2013/06/17/powershell-forensic-onliners-regex-get-eventlog/
* https://www.sans.org/reading-room/whitepapers/forensics/live-response-powershell-34302
* https://github.com/davehull/Kansa
* https://blogs.technet.microsoft.com/heyscriptingguy/2012/07/28/weekend-scripter-using-powershell-to-aid-in-security-forensics/
* https://devblogs.microsoft.com/scripting/use-powershell-to-aid-in-security-forensics/

## ADS:
* https://blogs.technet.microsoft.com/askcore/2013/03/24/alternate-data-streams-in-ntfs/

## Event Logs
* https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/

## LogFile
* https://github.com/jschicht/LogFileParser

## MFT
* https://docs.microsoft.com/en-us/windows/win32/devnotes/master-file-table
* https://github.com/dkovar/analyzeMFT

## Reg
* http://www.hexacorn.com/blog/2017/01/28/beyond-good-ol-run-key-all-parts/

## Shellbags
* https://countuponsecurity.com/tag/shellbags/

## Timeline
* https://binaryforay.blogspot.com/2018/05/introducing-wxtcmd.html
* https://cclgroupltd.com/2018/05/03/windows-10-timeline-forensic-artefacts/
* https://salt4n6.com/2018/05/03/windows-10-timeline-forensic-artefacts/amp/

# Linux

## Forensics
* https://articles.forensicfocus.com/2015/08/25/linux-timestamps-oh-boy/
* https://www.hackers-arise.com/single-post/2016/06/20/Covering-your-BASH-Shell-Tracks-AntiForensics
* https://dfirdave.blogspot.com/2014/09/bash-history-forensics.html
* http://www.deer-run.com/~hal/DontKnowJack-bash_history.pdf
* https://www.linux.com/news/bring-back-deleted-files-lsof/

# MacOS DFIR

### Files/Filesystem
* https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/AccessingFilesandDirectories/AccessingFilesandDirectories.html#//apple_ref/doc/uid/TP40010672-CH3-SW1

#### .PKG
* http://bomutils.dyndns.org/tutorial.html
* http://s.sudre.free.fr/Stuff/Ivanhoe/FLAT.html
* https://ilostmynotes.blogspot.com/2012/06/mac-os-x-pkg-bom-files-package.html

#### MachO
* https://www.codeproject.com/Articles/187181/Dynamic-Linking-of-Imported-Functions-in-Mach-O
* http://www.m4b.io/reverse/engineering/mach/binaries/2015/03/29/mach-binaries.html
* https://www.objc.io/issues/6-build-tools/mach-o-executables/
* https://lowlevelbits.org/parsing-mach-o-files/

#### Code Signing:
* https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40005929
* https://developer.apple.com/library/archive/technotes/tn2206/_index.html#//apple_ref/doc/uid/DTS40007919
* https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/AboutCS/AboutCS.html#//apple_ref/doc/uid/TP40005929-CH3-SW1

### Malware Analysis

#### Lab Setup:
* http://osxdaily.com/2015/06/05/copy-iso-to-usb-drive-mac-os-x-command/
* https://tobiwashere.de/2017/10/virtualbox-how-to-create-a-macos-high-sierra-vm-to-run-on-a-mac-host-system/
* http://anadoxin.org/blog/disabling-system-integrity-protection-from-guest-el-capitan-under-virtualbox-5.html
* https://github.com/phdphuc/mac-a-mal-cuckoo
* https://www.sqlite.org/draft/cli.html
* https://www.fireeye.com/services/freeware/monitor.html

#### Analysis:
* https://www.sans.org/reading-room/whitepapers/forensics/mac-os-malware-analysis-33178
* https://www.apriorit.com/dev-blog/363-how-to-reverse-engineer-os-x-and-ios-software
* https://web.archive.org/web/20190606075247/https://blogs.dropbox.com/tech/2018/04/4696/
* https://objective-see.com/malware.html
* https://medium.com/@adam.toscher/creating-signed-and-customized-backdoored-macos-applications-by-abusing-apple-developer-tools-b4cbf1a98187
* http://amanda.secured.org/wp-content/uploads/2017/02/MIRcon_2014_RD_Track_Plists_Shell_Scripts_Object-C.pdf
* https://github.com/jbradley89/osx_incident_response_scripting_and_analysis/blob/master/chapter10/collect.sh

### Forensics
* https://www.mac4n6.com/resources/
* https://github.com/mac4n6/Presentations
* https://apple.stackexchange.com/questions/220729/what-type-of-hash-are-a-macs-password-stored-in
* https://apple.stackexchange.com/questions/186893/os-x-10-9-where-are-password-hashes-stored
* https://forensic4cast.com/2016/10/macos-timestamps-from-extended-attributes-and-spotlight/
* https://eclecticlight.co/2017/10/10/inside-the-macos-log-logd-and-the-files-that-it-manages/
* https://forensicswiki.org/wiki/Mac_OS_X_10.9_-_Artifacts_Location
* https://digital-forensics.sans.org/media/FOR518-Reference-Sheet.pdf
* https://gist.github.com/n8felton/e45e5eb585b0a9df4d93
* https://developer.apple.com/library/archive/documentation/CoreServices/Reference/MetadataAttributesRef/Reference/CommonAttrs.html#//apple_ref/doc/uid/TP40001694-SW1
* https://sud0man.blogspot.com/2015/05/artefacts-for-mac-os-x.html?m=1
* https://www.macobserver.com/tips/how-to/your-mac-remembers-everything-you-download-heres-how-to-clear-download-history/
* https://www.commandlinefu.com/commands/view/24201/get-hardware-uuid-in-mac-os-x
* http://osxdaily.com/2018/05/03/view-remove-extended-attributes-file-mac/

# Red Team
* https://highon.coffee/blog/penetration-testing-tools-cheat-sheet/#passive-information-gathering
* 
# N4n6
* https://www.sans.org/reading-room/whitepapers/protocols/analyzing-network-traffic-basic-linux-tools-34037
