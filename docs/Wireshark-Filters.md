--- 
layout: default
---

Wireshark Filters
==================================

This was my Wireshark Filter Cheatsheet for GNFA when I certified in May of 2019.

| Filter | Description |
|:------|:--------|
| tcp.port == 80 | BPF like filter |
| (not tcp.port == 80 and not tcp.port == 8080) and http contains "stolen"'	| HTTP traffic on a nonstandard port that contains the word "stolen" |
| 'dns.flags.response == 1 and dns.count.answers > 5 and dns.qry.name contains "cz.cc"'	| DNS replies containing more than 5 responses for a query against a known hostile domain |
| 'http and http.cookie matches "(?i)username"' | Match traffic that contains the string 'username' in the cookie value (case-sensitive manner) |
| http and lower(http.cookie) contains "username"' | Case-insensitive. Convert a field value to lowercase before eval |
| http.request and not ip.addr == 70.32.97.206 | Rule out the IP and show just requests to other hosts |
| ftp.request.command == "RETR"	| FTP - Find all "RETR" FTP commands |
| ip.addr == 149.20.20.135 and tcp.port == 30893 | FTP - File Extraction |
| smb.cmd == 0x72 | SMB - Protocol Negotiation |
| smb.cmd == 0x73 | SMB - Session Establishment (Setup AndX Request/Response) |
| smb.cmd == 0x75 | SMB - Accessing Services (Tree Connect AndX Request/Response) |
| smb.cmd == 0x32 && smb.trans2.cmd == 0x0005 && smb.qpi_loi == 1004 | SMB - Obtain Directory/File Metadata (Trans2 Request/Response) |
| smb.cmd == 0xa2 | SMB - Opening a File (NT Create AndX Request/Response) |
| smb.cmd == 0x24 | SMB - Locking a File for Access (Locking AndX Request/Response) |
| smb.cmd == 0x2e | SMB - Reading from a File (Read AndX Request/Response) |
| smb.cmd == 0x24 | SMB - Unlocking a File (Locking AndX Request/Response) |
| smb.cmd == 0x04 | SMB - Closing a File (Close AndX Request/Response) |
| smb.cmd == 0x71 | SMB - Tree Disconnection |
| smb.cmd == 0x71 | SMB - Logoff (Logoff AndX Request) |
| smb2.boot_time | SMB - When system booted |
| smb.file | SMB - Maps the filename to fileID |
| (smb2.filename) && !(smb2.filename == "browser")) && !(smb2.filename contains "(31B2F340-016D-11D2-945F-00C04FB984F9)\\gpt.ini") | SMB - Filename |
| atsvc.opnum == 0, atsvc.atsvc_JobInfo.command | SMB - Remote Job Scheduler (At job) [common Lateral Movement method] |
| !(tcp.analysis.keep_alive || tcp.analysis.keep_alive_ack) | TCP keep alive - used on very long lived connections. To keep client open client will send a packed with one byte of data to the server and not increment the TCP sequence number. |
| !(wlan.fc.type_subtype == 0x0008) | SSID |

[back](./)
