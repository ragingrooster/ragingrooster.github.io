---
layout: default
---

Quick Notes on Memory Forensics - 2021/04/07
==================================

# Parse Memory with Volatility3:
## How to run:
```
python .\vol.py -f "S:\SomeNetworkPath\Case\Memory.mem" windows.info.Info > "S:\SomeNetworkPath\Case\Memory\Analysis\info.txt"
```
The rest of the Windows modules:

```
windows.bigpools.BigPools
windows.cmdline.CmdLine
windows.dlllist.DllList
windows.driverirp.DriverIrp
windows.driverscan.DriverScan
windows.envars.Envars
windows.filescan.FileScan
windows.getservicesids.GetServiceSIDs
windows.getsids.GetSIDs
windows.handles.Handles
windows.info.Info
windows.malfind.Malfind
windows.memmap.Memmap
windows.modscan.ModScan
windows.modules.Modules
windows.mutantscan.MutantScan
windows.netscan.NetScan
windows.poolscanner.PoolScanner
windows.privileges.Privs
windows.pslist.PsList
windows.psscan.PsScan
windows.pstree.PsTree
windows.registry.certificates.Certificates
windows.registry.hivelist.HiveList
windows.registry.hivescan.HiveScan
windows.registry.printkey.PrintKey
windows.registry.userassist.UserAssist
windows.ssdt.SSDT
windows.statistics.Statistics
windows.strings.Strings
windows.symlinkscan.SymlinkScan
windows.vadinfo.VadInfo
windows.verinfo.VerInfo
windows.virtmap.VirtMap
```
## Scan with Yara:
```
python .\vol.py -f "S:\SomeNetworkPath\Case\Memory.mem" yarascan.YaraScan --yara-file C:\Path\To\Yara\rule.yar
```

## Use Yara to look for a pattern:
```
python .\vol.py -f "S:\SomeNetworkPath\Case\Memory.mem" yarascan.YaraScan --yara-rules "https:"
```
## Parse out IPv4 addresses from netscan results
```
Get-Content "S:\SomeNetworkPath\Case\Memory\Analysis\netscan.txt" | Select-String -Pattern TCPv4 > ipv4_out.txt
```
Then parse out LISTENING, ESTABLISHED, and CLOSED connections.

# Bulk Extractor
```
.\bulk_extractor -o outfile "S:\SomeNetworkPath\Cases\Memory.mem"
```

# Carving Network Packets with Caploader

## Setup:
1. Download Free trial from [NETRSEC](https://www.netresec.com/?page=CapLoader#trial)
2. Unzip archive

## Analysis:
1. Launch Caploader
2. `File` > `Open Files` > `MEMORY.dmp`
3. Click `Yes` when prompted
4. Leave default check boxes, click `Start`
5. Once completed use the Caploader interface or..
6. Save pcap and open in Wireshark: `CTRL+A` > `CTRL+S` > Save As `flows.pcap`

# WinDbg Crash Dumps:
## Installation:
See [Debugging Tools for Windows 10 ](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/debugger-download-tools)

## Setup:
1. Search Menu > WinDbg
2. Set the Symbol Path (requires Internet): 
    - Hit ```CTRL+S```
    - Paste ```srv*c:\symbols*http://msdl.microsoft.com/download/symbols``` into box
    - Check ```Reload```
    - Click ```Okay```
3. File > Save Workspace

## [SwishDbgExt](https://github.com/comaeio/SwishDbgExt) Setup:
1. Download latest [release](https://github.com/comaeio/SwishDbgExt/releases)
2. Unzip Archive & Copy ```Release\x86\SwishDbgExt.dll```to your WinDbg directory
    - ex:```C:\Program Files (x86)\Windows Kits\10\Debuggers\x86```
3. Unzip Archive & Copy ```Release\x64\SwishDbgExt.dll```to your WinDbgx64 directory
    - ex:```C:\Program Files\Windows Kits\10\Debuggers\x64```

## Enumerating Crash Dump Settings:
1. Extract System Hive from `%SYSTEMDRIVE%\Windows\System32\Config\SYSTEM`
2. In Registry Viewer go to `HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\CrashControl`
- Q. What type of crash dump will the system generate?:
    - CrashDumpEnabled [[ref]](https://support.microsoft.com/en-us/help/254649/overview-of-memory-dump-file-options-for-windows):
        ```
        REG_DWORD 0x0 = None
        REG_DWORD 0x1 = Complete memory dump
        REG_DWORD 0x2 = Kernel memory dump
        REG_DWORD 0x3 = Small memory dump (64KB)
        REG_DWORD 0x7 = Automatic memory dump
        ```
- Q. Where will the Crash be saved?
    - DumpFile:`REG_EXPAND_SZ %SystemRoot%\MEMORY.DMP`
     - On a dead system located at:`%SYSTEMDRIVE%\Windows\MEMORY.DMP`

## Analysis with WinDbg and SwishDbgExt:
1. Open Crash Dump with `CTRL+D`
2. Out of the box DFIR applicable commands [[ref]](https://cedb60df-a-62cb3a1a-s-sites.googlegroups.com/site/tietjenk/ForensicCrashDumpAnalysis.pdf?attachauth=ANoY7cqKFs6cs0v-xa-Rlf2ux0qGRK41JVv00q2FWdKWkGa_881hhQUQwM_OV1_Fi3E5TEUHEHmepT--J10_9_YDDW7vVRS8xyRBxXYAxOVi5XgJFyo2mhkwHb9hfwaEU9Nqm7tBxN8jlrwSI5yH2U17zhEv3qgf5mtt2PcSwgVklWWlaksZXvKpqg_7cnDeya4BRkpYFD0A3u-G_mUg9S8qM-ojI3zwkArfYLNuJ6QEmA689NL8ynA%3D&attredirects=2):
    - Data about the crash:`!analyze –v `
        - For more info see [here](https://docs.microsoft.com/en-us/windows-hardware/drivers/debugger/using-the--analyze-extension)
    - Running processes during the crash:`!process 0 0`
    - List of driver s on system:`lmkv`
    - For more info on bug & stop codes see [here](http://www.thewindowsclub.com/windows-bug-check-or-stop-error-codes)
3. Load SwishDbgEx: 
    - (x86):`!load C:\Program Files (x86)\Windows Kits\10\Debuggers\x86\SwishDbgExt.dll`
    - (x64):`!load C:\Program Files\Windows Kits\10\Debuggers\x64\SwishDbgExt.dll`
4. Run the !Help command to display avaible commands:`!SwishDbgExt.help`
```
kd> !SwishDbgExt.help
Commands for C:\Program Files\Windows Kits\10\Debuggers\x64\SwishDbgExt.dll:
  !help             - Displays information on available extension commands
  !ms_callbacks     - Display callback functions
  !ms_checkcodecave - Look for used code cave
  !ms_consoles      - Display console command's history 
  !ms_credentials   - Display user's credentials (based on gentilwiki's
                      mimikatz) 
  !ms_drivers       - Display list of drivers
  !ms_dump          - Dump memory space on disk
  !ms_exqueue       - Display Ex queued workers
  !ms_fixit         - Reset segmentation in WinDbg (Fix "16.kd>")
  !ms_gdt           - Display GDT
  !ms_hivelist      - Display list of registry hives
  !ms_idt           - Display IDT
  !ms_lxss          - Display lsxx entries
  !ms_malscore      - Analyze a memory space and returns a Malware Score Index
                      (MSI) - (based on Frank Boldewin's work)
  !ms_mbr           - Scan Master Boot Record (MBR)
  !ms_netstat       - Display network information (sockets, connections, ...)
  !ms_object        - Display list of object
  !ms_process       - Display list of processes
  !ms_readkcb       - Read key control block
  !ms_readknode     - Read key node
  !ms_readkvalue    - Read key value
  !ms_regcheck      - Scan for suspicious registry entries
  !ms_scanndishook  - Scan and display suspicious NDIS hooks
  !ms_services      - Display list of services
  !ms_ssdt          - Display service descriptor table (SDT) functions
  !ms_store         - Display information related to the Store Manager
                      (ReadyBoost)
  !ms_timers        - Display list of KTIMER
  !ms_vacbs         - Display list of cached VACBs
  !ms_verbose       - Turn verbose mode on/off
  !ms_yarascan      - Scan process memory using yara rules
!help <cmd> will give more information for a particular command
```
[back](./)
