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
Connect-VIServer "severname" -WarningAction 0

#Count the number of VMs in the "somefolder"
$ct_b4 = Get-Folder "somefolder" | Get-VM | Measure-Object | %{$_.Count}

#Shutdown VM's that are powered on in the Practice folder.
Get-Folder "somefolder" | Get-VM | Where-Object {$_.powerstate -eq 'PoweredOn'} | Shutdown-VMGuest -Confirm:$false

#Write
echo "Waiting for Virtual Machines to Shutdown..."

#Wait for 30 seconds
Start-Sleep -s 30

Start-transcript -Path "%USERPROFILE%\Desktop\delete_vms.txt" -force -noClobber -append

#Delete VM's that are in the "somefolder" folder.
Get-Folder "somefolder" | Get-VM | Remove-VM -DeletePermanently -Confirm:$true

#Determine if VMs were left behind.
$ct_af = Get-Folder "somefolder" | Get-VM | Measure-Object | %{$_.Count}
echo "Removed $ct_b4 VMs"
echo "$ct_af VMs still in the "somefolder"."

#Write
echo "Deleted $ct VMs"

Stop-transcript

#Disconnect vcenter server
Disconnect-VIServer vsphere.local.lan -Confirm:$false

exit
