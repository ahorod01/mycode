
clear

$userLst = Get-ADUser -Filter 'enabled -eq $true'  -SearchBase "OU=SantaAna,DC=Astech-EP,DC=local" | select -expand samaccountname

$users = $userLst | Sort-Object sourceDSAcn 

foreach ($user in $users) {
    $LastLogin = Get-ADUser -Identity $user -Properties LastLogonTimeStamp,Manager,whenCreated,UserPrincipalName | Select-Object Name,Manager,UserPrincipalName,whenCreated,@{Name="pwdLastSet"; Expression={[DateTime]::FromFileTime($_.pwdLastSet).ToString('yyyy-MM-dd hh:mm:ss')};},@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd hh:mm:ss')};} 
    write-host "=================================================="
    write-host "User ID $($user) - $($LastLogin.Name)"
    write-host "Manager $($LastLogin.Manager)"
    write-host "Created: $($LastLogin.whenCreated)"
    write-host "Last Login: $($LastLogin.Stamp)"
    write-host "--------------------------------------------------"
    
    $groups = Get-ADPrincipalGroupMembership  $user | select-object  -expand samaccountname
  
    for ($i = 0; $i -le ($groups.length - 1); $i += 1) {
      if ($groups.length -eq 1) {
        write-host $groups
      }else{
        write-host $($groups[$i])
      }
    }

    

    If ($members -contains $user) {
        #Write-Host "$user is member of $group"
    } Else {
        #Write-Host "$user is not a member of $group"
    }
    write-host ""
    
}

write-host "=================================================="
write-host "User Last Login Date"
write-host "=================================================="
$Path = 'LastLogon.csv'
Get-ADUser -Filter {enabled -eq $true} -Properties LastLogonTimeStamp | 
  
Select-Object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh:mm:ss')}} # | Export-Csv -Path $Path 




write-host "=================================================="
write-host "Group Membership"
write-host "=================================================="
$groups = Get-ADGroup  -SearchBase "OU=SantaAna,DC=Astech-EP,DC=local" | select name, SID

foreach ($group in $groups) {
    write-host "=================================================="
    write-host "Group Name: $($group.name)"    
    write-host "--------------------------------------------------"
    
    $grpMem = Get-ADGroupMember -identity $group.sid | select name    
    for ($i = 0; $i -le ($grpMem.length - 1); $i += 1) {
      if ($grpMem.length -eq 1) {
        write-host $grpMem
        #write-host $($grpMem[$i])
      }
    }
}