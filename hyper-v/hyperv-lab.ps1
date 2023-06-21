[CmdletBinding()]
param (
	[parameter()][string]$ConfigFile = "C:\Git\_non_sync\hyperv-lab-config.json",
	[parameter()][switch]$AutoStart,
	[parameter()][string]$rootpath = "D:\Hyper-V"
)

$machines = Get-Content $ConfigFile | ConvertFrom-Json

foreach ($machine in $machines) {
	$vmname = $machine.name
	$vmpath = "$rootpath\$vmname"
	$diskpath = "$($vmpath)$($vmname)-disk1.vhdx"

	if (!(Test-Path $vmpath)) {	$null = mkdir $vmpath -Force }

	Write-Host "Creating machine: $vmname"
	$null = New-VM -Name $vmname -Generation $machine.generation -Path $vmpath
	$null = Set-VM -Name $vmname -ProcessorCount $machine.cpu -MemoryStartupBytes $machine.ram
	$null = New-VHD -Path $diskpath -SizeBytes $machine.disksize
	$null = Add-VMHardDiskDrive -VMName $vmname -Path $diskpath
	$null = Set-VMDvdDrive -VMName $vmname -Path $machine.image
	$null = Remove-VMNetworkAdapter -VMName $vmname
	$null = Add-VMNetworkAdapter -VMName $vmname -Name $machine.port
	$null = Set-VMNetworkAdapterVlan -VMName $vmname -VMNetworkAdapterName $machine.port -Access -AccessVlanId $machine.vlan
	$null = Connect-VMNetworkAdapter -VMName $vmname -Name $machine.port -SwitchName $machine.vmswitch
	$null = Set-VMFirmware -VMName $vmname -EnableSecureBoot $machine.secureboot
	$vmx = Get-VM -Name $vmname
	if ($AutoStart) {
		Write-Host "starting machine: $vmname"
		Start-VM $vmname
	}
	$vmx
}
