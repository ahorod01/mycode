# Set the AD target OU
$computers = Get-ADComputer -Filter * -SearchBase "OU=Workstations,OU=SantaAna,DC=Astech-EP,DC=local"
# Set the absolute path to the output CSV file
$csvPath = "bitlocker-list.csv"
# Declare an output array to store data
$output = @()
# Declare CSV headers
$output += "HostName, RecoveryPassword"

# Loop over computers, check if BitLocker is stored
foreach ($computer in $computers) {
 # Fetch the msFVE-RecoverInfo object and sort by creation date to make sure the latest key is fetched
 $fetch = $(Get-ADObject -Filter {objectclass -eq 'msFVE-RecoveryInformation'} -SearchBase $computer.DistinguishedName -Properties 'msFVE-RecoveryPassword',whencreated | Sort-Object WhenCreated -Descending).'msFVE-RecoveryPassword'
 # If blank, write "BitLocker not active" to the data object.
 if (-Not $fetch) {
  $output += ($computer.Name,"BitLocker not active OR not backed up AD") -join ","
 }
 # If more than one key, fetch the first (will be the newest). 
 elseif ($fetch.Count -gt 1) {
  $output += ($computer.Name, $fetch[0]) -join ","
 }
 # If single key, fetch it.
 else {
  $output += ($computer.Name, $fetch) -join ","
 }
}

# Export output to CSV
$output #| Out-File -FilePath $csvPath

