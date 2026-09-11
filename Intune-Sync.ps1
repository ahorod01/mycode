#sync Itune
	
Install-Module Microsoft.Graph
Install-Module -Name Microsoft.Graph.Intune
Connect-MgGraph
Connect-MgGraph -scope DeviceManagementManagedDevices.PrivilegedOperations.All, DeviceManagementManagedDevices.ReadWrite.All,DeviceManagementManagedDevices.Read.All
Get-MgDeviceManagementManagedDevice -Filter "contains(deviceName,'AST')" |  ft ID, AzureAdDeviceId,DeviceEnrollmentType, DeviceName,lastsyncdatetime
#Single Host
#Sync-MgDeviceManagementManagedDevice -ManagedDeviceId deviceID
#All Hosts
$Windowsdevices = get-MgDeviceManagementManagedDevice | Where-Object {$_.OperatingSystem -eq "Windows"}

Foreach ($device in $Windowsdevices) {
    Sync-MgDeviceManagementManagedDevice -ManagedDeviceId $device.id
	if ($device.DeviceName -eq "AST6055" ){
		write-host "Sending device sync request to" $device.DeviceName -ForegroundColor yellow
	} else {
		write-host "Sending device sync request to" $device.DeviceName -ForegroundColor red
	}
}
