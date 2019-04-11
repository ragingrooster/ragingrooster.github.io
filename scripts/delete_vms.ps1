<# 
	delete_vms.ps1
	Author: Jordan Zeveney
	Version: 1.0
	Purpose: This script is used to delete virtual machines.
	Version History: 
	1.0 - 12 Jun 17 - Initial Write of Script. 
#> 

#Set PowerCLI Options
Set-PowerCLIConfiguration -Scope Session -WebOperationTimeoutSeconds 3600 -InvalidCertificateAction Ignore -Confirm:$false

Clear

#Check for PowerCLI
if ( !(Get-Module VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
    Import-Module VMware.VimAutomation.Core -ErrorAction Inquire
}

#Connect to vCenter
Connect-VIServer vsphere.local.lan -WarningAction 0

#Shutdown VM's that are powered on in the Practice folder.
Get-Folder $(somefolder) | Get-VM | Where-Object {$_.powerstate -eq 'PoweredOn'} | Shutdown-VMGuest -Confirm:$false

#Write
echo "Waiting for Virtual Machines to Shutdown..."

#Wait for 30 seconds
Start-Sleep -s 30

Start-transcript -Path "%USERPROFILE%\Desktop\delete_vms.txt" -force -noClobber -append

#Delete VM's that are in the $(somefolder) folder.
Get-Folder $(somefolder) | Get-VM | Remove-VM -DeletePermanently -Confirm:$true

#Determine if any VMs were left beind
$var= Get-Folder $(somefolder) | Get-VM #Array of VM names in folder
$ct = $var.length #Count of VMs based on length of VM name array

#Write
echo "Deleted $ct VMs"

Stop-transcript

#Disconnect vcenter server
Disconnect-VIServer vsphere.local.lan -Confirm:$false

exit
