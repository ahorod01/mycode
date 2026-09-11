#=====================================================================================
# Filename: AD-Inventory.ps1
# Author  : Alex Horodenski
# Purpose : Gather AD environment  settings and security and output to a report file
#           Lists Security groups/membership and user membership
# Created : 2024/07/04
# Modified:
#=====================================================================================

#define functions (Code Smarter, standardize)
#________________________________________________________
## Output Section Header for both screen and file output
function get-header  {

    param ( 
        [Parameter(Mandatory=$true,  Position=0)]
        [string] $Title,
        [Parameter(Mandatory=$false, Position=1)]
        [string] $Type,
        [Parameter(Mandatory=$false, Position=2)]
        [string] $FilePath
    )
    
    # check if Type is blank, if so use defaults below
    if ($Type -eq "") {
        $chrType="*"
        $fColor="Black"
        $bColor="Yellow"
        $colorBar=@{ForegroundColor=$fColor;BackgroundColor=$bColor}        
    } else {
        # reset to specified if TYPE is not blank
        $chrType=$Type
        $colorBar=""
    }
    
    $bar=""
    $length=$Title.length+2
    if ($length -gt 100){$length=100}

    For ($i=0; $i -le $length; $i++)  { $bar = $bar+$chrType } 
    
    Write-Output ""
    #output header to the file
    if ($FilePath -ne ""){
        Write-Output $bar         | out-file -FilePath $FilePath -Append  
        Write-Output " $Title  "  | Out-String -Stream | out-file -FilePath $FilePath -Append
        Write-Output $bar         | out-file -FilePath $FilePath -Append

    }     
    #output header to the screen
    Write-Host $bar         @colorBar
    Write-Host " $Title  "  @colorBar | Out-String -Stream
    Write-Host $bar         @colorBar
}

#__________________
#Setup output file
function ToOutput ($filePath){    
    if($filePath -ne ""){
        $outPath=$filePath
        write-output ""  | out-file -FilePath $($filePath) -NoNewline   ## Create new blank file
        return "| out-file -FilePath '$($filePath)' -Append" ## Return Output parameter       
    } else {
        return ""
    }
}
#****************
#** Begin here **
#****************
param (
    [Parameter(Mandatory=$false, Position=0)]
    [string] $output
)
clear

#---------------------------------------
#start with overview, then take the 
#time to get detailed
#---------------------------------------
$filePath="AD_Overview.txt"
$outPath=ToOutput($filePath)

get-header "Active Directory Overview" "" $filePath
Get-ADForest | out-file -FilePath $FilePath -Append
Get-ADDomain | out-file -FilePath $FilePath -Append

get-header "Domain Password Policy" "=" $filePath
Get-ADDefaultDomainPasswordPolicy | out-file -FilePath $filePath -Append
 
get-header "List All Domain Controllers" "=" $filePath
Get-ADDomainController -filter * | ft name, IPv4Address, IsGlobalCatalog,IsReadOnly, Forest, Site, OperatingSystem | out-file -FilePath $filePath -Append

get-header "Organizational Units" "=" $filePath
Get-ADOrganizationalUnit -Filter * |ft Name, DistinguishedName | out-file -FilePath $filePath -Append
#END Overview, time to get detailed
#---------------------------------------


#---------------------------------------
#Get administrators
#---------------------------------------
$filePath="AD_Administrators.txt"
$outPath=ToOutput($filePath)

get-header "List members of the Adinistrators security group" "" $filePath
Get-ADGroupMember -Identity Administrators `
    | Select-Object name, objectClass,distinguishedName | Sort-Object -Property Name | out-file -FilePath $filePath -Append
Start-Sleep 2

# List Enterprise Admins
get-header "List members of the Enterprise Admins security group" "" $filePath
Get-ADGroupMember -Identity "Enterprise Admins" -Recursive `
    | ft SamAccountName,Name, DistinguishedName | out-string|Sort-Object -Property Name | out-file -FilePath $filePath -Append
$groupMembers = Get-ADGroupMember -Identity "Enterprise Admins"
Foreach($member in $groupMembers){
    Get-ADUser $member -Properties * | select SamAccountName, UserPrincipalName, LastLogonDate, Enabled `
        | Sort-Object -Property Name | out-file -FilePath $filePath -Append
}

#List Domain Admins
get-header "List members of the Domain Admins security group   " "" $filePath
Get-ADGroupMember -Identity "Domain Admins" -Recursive | ft SamAccountName, Name, distinguishedName | out-file -FilePath $filePath -Append
#-list Last Login Date / Status
$groupMembers = Get-ADGroupMember -Identity "Domain Admins"
Foreach($member in $groupMembers){ 
    Get-ADUser $member -Properties * | select SamAccountName, LastLogonDate, Enabled | Sort-Object -Property Name | out-file -FilePath $filePath -Append
}
#---------------------------------------
Start-Sleep 5

#---------------------------------------
#User Last Login
#---------------------------------------
$filePath="AD_LastLogin.txt"
$outPath=ToOutput($filePath)

get-header "User Last Login Date" "=" $filePath
Get-ADUser -Filter {enabled -eq $true} -Properties LastLogonTimeStamp `
    | Select-Object Name,@{Name="LastLogin"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh:mm:ss')}} `
    | sort-object  Name | Out-String -Stream | out-file -FilePath $filePath -Append
Start-Sleep 5


#---------------------------------------
#List all security group/memberships
#---------------------------------------
$filePath="AD_GroupMembership.txt"
$outPath=ToOutput($filePath)

get-header "List all security groups and members" "" $filePath
$groups = Get-ADGroup -filter "GroupCategory -eq 'Security'" -Properties Members, Description,whenCreated,whenChanged,info `
    |select Name, Description,whenCreated,whenChanged,info | Sort-Object -Property Name 
Foreach($member in $groups){        
    get-header "Security Group:   $($member.Name) `r`n (Created: $($member.whenCreated) Changed: $($member.whenChanged))`r`n -> $($member.Description) `r`n Note: `r`n $($member.info)" "-" $filePath
    #Write-Output "User ID  `tName  `tLast Login  `tEnabled"  | out-file -FilePath $filePath -Append
    $groupMembers = Get-ADGroupMember -Identity $($member.Name)
    
    Foreach($member in $groupMembers){        
        if ($member.objectclass -eq "user"){
            Get-ADUser $member -Properties * | sort-object Name | select  SamAccountName , Name , LastLogonDate, Enabled | out-file -FilePath $filePath -Append
        } else {
            if ($member.objectclass -eq "group"){
                Write-Output "See Security Group $($member.Name) for member list"  | out-file -FilePath $filePath -Append
            }
        }
    }
}
Start-Sleep 5



#---------------------------------------
#list users
#---------------------------------------
$filePath="AD_ActiveUsers-MembersOf.txt"
$outPath=ToOutput($filePath)

get-header "List all Active AD User Accounts" "" $filePath
$users = Get-ADUser -Filter 'enabled -eq $true'   | select -expand samaccountname | sort-object samaccountname
foreach ($user in $users) {
    $userDetail = Get-ADUser -Identity $user -Properties LastLogonTimeStamp,pwdLastSet,pwdLastSet,Manager,whenCreated,UserPrincipalName `
        | Select-Object Name,Manager,UserPrincipalName,whenCreated, `
        @{Name="pwdLastSet"; Expression={[DateTime]::FromFileTime($_.pwdLastSet).ToString('yyyy-MM-dd hh:mm:ss')};}, `
        @{Name="LastLogin";  Expression={[DateTime]::FromFileTime($_.LastLogonTimeStamp).ToString('yyyy-MM-dd hh:mm:ss')};} 
    $mgr=$($LastLogin.Manager)
    Write-Output "==================================================================" | out-file -FilePath $filePath -Append
    Write-Output "User ID   : $($user) - $($userDetail.Name)"                         | out-file -FilePath $filePath -Append
    Write-Output "Manager   : $($userDetail.Manager)"                                 | out-file -FilePath $filePath -Append
    Write-Output "Created   : $($userDetail.whenCreated)"                             | out-file -FilePath $filePath -Append
    Write-Output "Last Login: $($userDetail.LastLogin)"                               | out-file -FilePath $filePath -Append
    Write-Output "Pwd Set   : $($userDetail.pwdLastSet)"                              | out-file -FilePath $filePath -Append
    Write-Output "------------------------------------------------------------------" | out-file -FilePath $filePath -Append
    Write-Output "Member of the following Security/Distribution Lists:"               | out-file -FilePath $filePath -Append

    Get-ADUser $user -Properties MemberOf | Select-Object -ExpandProperty MemberOf | sort-object Name `
        | Get-ADGroup -Properties Description | ft -HideTableHeaders Name, Description      | out-file -FilePath $filePath -Append

    write-output ""  | out-file -FilePath $filePath -Append
}
write-output "-------------------------------------------------------------------"  | out-file -FilePath $filePath -Append
write-output ""  | out-file -FilePath $filePath -Append



#---------------------------------------
#list Group Policy Objects
#---------------------------------------
$filePath="AD_GPOlist.txt"
$currentDir=Get-Location
$outPath=ToOutput($filePath)

get-header "List all AD GPOs" "" $filePath

#list GPOs
Get-GPO -all -domain astech-ep.local | ft displayname, Gpostatus,CreationTime,ModificationTime | out-file -FilePath $filePath 

#backup GPOs, cause we can and should
$Folder = 'GroupPolicy'
"Test to see if folder [$Folder]  exists"
if (Test-Path -Path $Folder) {
    "Path exists,using it!"
} else {
    New-Item -Path 'GroupPolicy' -ItemType Directory
}
Get-GPO -all -domain astech-ep.local | Backup-GPO -Path "$currentDir\GroupPolicy"

#-------------------------------------------------
#list latest BitLocker Recover key in AD,
#Recovery-keys stored in Azure AD not included
#-------------------------------------------------
$filePath="AD_BitLockerRecoverKey.csv"
$outPath=ToOutput($filePath)

get-header "List latest BitLocker Recover key in AD" "" $filePath

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
$output | out-file -FilePath $filePath 