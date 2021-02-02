## Windows Logs:
Log Locations:
- %WinDir%\System32\winevt\Logs
- [root]\Windows\System32\LogFiles
- [root]\inetpub\logs\LogFiles

### Evidence of:

| Log         | Description             |
| :---        | :---                    |
| Application | Software installation, antivirus alerts, exploit attempts |
| Security    | user authentication & logons (failures/successes), user behavior and actions, file, folder, & share access, policy changes / modifications to security settings, AD/object access, process tracking (proccess start, exit, handles, object access, etc.), system events affecting security |
| System      | Windows services, system compontents, drivers, etc. Services stopped/started, System reboots |

### Logon Type codes:

| Code    | Description             | Notes                                                                                       |
| :---    | :---                    | :---                                                                                        |
| Type 2  | Interactive             | Logon via console (keyboard, server HKVM, virtual client)                                   |
| Type 3  | Network                 | SMB, shared folders, printers, etc.                                                         |
| Type 4  | Batch                   | Scheduled Task, tied to specified user account                                              |
| Type 5  | Service                 | Service started, tied to specified user account                                             |
| Type 7  | Unlock                  | Unlocking from password protected screen saver mode, but could also be generated from RDP   |
| Type 8  | NetworkCleartext        | Network logon where password was sent in cleartext, scripted or IIS Basic Auth              |
| Type 9  | NewCredentials          | RunAS cmd to start program under diff user account with /netonly switch                     |
| Type 10 | RemoteInteractive       | Terminal Services, RDP, Remote Assistance (prior to Win10 were type 2)                      |
| Type 11 | CachedInteractive       | Cached creds used when not in contact with DC (facilitates mobile users), bad on servers    |
| Type 12 | CachedRemoteInteractive | Cached creds used for remote interactive logon (RDP), MS live accts on stdalone wrkstations |
| Type 13 | Cached Unlock           | Cached creds used for unlock operations, like Type 7                                        |

### Account Usage:
- %SystemRoot%\System32\Winevt\Logs\Security.evtx
	- 4624 Successful Logon (if hacker users exploit this prob won't be present due to bypassing standard API)
	- 4625 Failed Logon (potential indicator of password guessing/dictionary attack from brute-force tools like hydra & medusa)
	- 4634/4647 Successful Logoff/User initiated logoff for interactive session (4634 not reliably recorded by Windows)
		- 4647 logon id assigned at time of logon value can help track user activities during session
	- 4672 Account logon w/ superuser rights (admin)
- events contain logon type, account, timestamp, event id, computer

### RDP Related Events:
Network Connection >> Authentication >> Logon >> Session Disconnect/Reconnect >> Logoff
- Network Connection:
	- %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx
		- 1149 User authentication succeded (only indicates a network connection, not authenticated such as when you are promoted for usrname/pw)
    - %SystemRoot%\System32\Winevt\Logs\Microsft-Windows-RemoteDesktopServices-RdpCoreTS%4Operational.evtx
		- 131 Server accepted a new TCP connection from client IP.ADDRESS(only indicates connection)
	-  %SystemRoot%\System32\Winevt\Logs\Microsft-Windows-TerminalServices-RemoteConnectionManager%4Admin
		- 1158 Remote Desktop Services accepted a connection from IP.ADDRESS(only if NLA is disabled (you can tell if you can see login screen before entering creds), allows attacker to see whos currently logged in)
	- %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-TerminalServices-RDPClient%4Operational.evtx
		- 1024 RDP ClientActiveX is trying to connect to the server (IP.ADDRESS OR HOSTNAME)
- Authentication:
	- %SystemRoot%\System32\Winevt\Logs\Security.evtx
		- 4624 Successful Logon with specified usrname (Type 3,10 or 7 from remote IP)
		- 4625 Failed Logon (ID brute force. NLA enabled Type 3, NLA disabled Type 10)
- Logon:
	- %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx
		- 21 Remote Desktop Services: Session Logon Succeeded (only when source network address is not local)
		- 22 Remote Desktop Services: Shell start notification recieved (only when source network address is not local)
- Session Disconnect/Reconnect:
	- %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx
		- 24 Remote Desktop Services: Session has been disconnected (only when source network address is not local)
		- 25 Remote Desktop Services: Session reconnection succeeded
		- 39 Session <X> has been disconnected by session <Y> (user formally disconnected  RDP session)
		- 40 Session <X> has been disconnected, reason code <Z> (user disconnect/reconnect)
			- reason code 0: no additional info (usually means that user has just closed RDP client window)
			- reason code 5: client's connection was replaced by another connection (means user has reconnected to previous RDP session)
			- reason code 11: user activity initiated the disconnect (means user clicked disconnect button in start menu)
	- %SystemRoot%\System32\Winevt\Logs\Security.evtx
		- 4778 Session was reconnected to a Window Station (user reconnected to exisiting RDP session. Use with 4624 Type 7 & Type 10. Sessions named console = "Fast User Switching")
		- 4779 A session was disconnected from a Window Station (user disconnected. paired with Event ID 24 and likely Event ID’s 39 and 40. ID SessionName, ClientAddress, and LogonID & associated activity.)
- Logoff:
	- %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx
		- 23   Remote Desktop Services: Session logoff succeeded (user initiated a formal system logoff vs simple disconnect)
		- 4634 An account was logged off (Type 10 (RemoteInteractive/TerminalServices/Remote Desktop) or Type 7 from remote IP (if reconnection from prev. RDP session) pair with 21)
		- 4647 User initiated logoff (user initiated loggoff.. requires reasoning and temporal context)
		- 9009 The Desktop Window Manager has exited with code (<X>) (user formally closes an RDP connection and indicates the RDP desktop GUI has been shutdown)

### Windows Processes:
- %SystemRoot%\System32\Winevt\Logs\Security.evtx
	- 4688 A new process has been created (contains SID, Account Name, Domain, LogonID)
	- 4689 A process has exited (date/time, exit status, process name/path)
  
### Windows Services:
- %SystemRoot%\System32\Winevt\Logs\System.evtx
	- 7034 Service crashed unexpectedly
	- 7035 Service sent a Start/Stop control
	- 7036 Service started or stopped
	- 7040 start type changed (Boot/On Request/Disabled)
	- 7045 service was installed on the system (Win2008R2+)
- %SystemRoot%\System32\Winevt\Logs\Security.evtx
	- 4697 service was installed on the system

### Scheduled Tasks:
- %SystemRoot%\System32\Winevt\Logs\Security.evtx
	- 4698 A scheduled task was created (SID, Acct name/domain, logon ID, task info)
	- 4700 A scheduled task was enabled
- %SystemRoot%\System32\Winevt\Logs\Microsoft-Windows-TaskScheduler%4Operational.evtx
	- See chart @ https://www.cyprich.com/2017/03/29/common-task-scheduler-event-ids/
