#=======================================================
# Filename:   Menu.PS1
# Author:     Alex Horodenski (AWH)
# Date:       2022/12/15
# Purpose:    PowerShell menu to execute common system
#             tasks via Command line or PowerShell
#-------------------------------------------------------
# Version History
#-------------------------------------------------------
# 2022/12/15:AWH - Initial Design
# 2023/05/10:AWH - Added more fucntionallity
# 2024/02/1 :AWH - Added more fucntionallity
# 2025/11/11:AWH - Added more fucntionallity 
#            (TPM, AutoPilot, Intune)
# 2026/06/11:AWH - Added Sub-Menu for cleaner look
# 2026/06/26:AWH - Added more fucntionallity 
#            (Service Submenu and controls, Azure AD Join)
#=======================================================
try{
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
    Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned
    throw "Sum Ting Wong"
}
catch{
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red -BackgroundColor white
}


#Get-ExecutionPolicy -List

# Define Menus
function Show-MainMenu  {
    Clear-Host
    Write-Host "===================================== Menu =====================================" -ForegroundColor Cyan -BackgroundColor Yellow
    Write-Host " 1. Show System Hostname          IA. Get AssetInventory for SnipeIT to import"
    Write-Host " 2. Show System IP Addresses      S.  Get Service List"
    Write-Host " 3. List Running Processes        SS. System Summary"
    Write-Host " 4. Last 10 Event Logs            SD. System Detail" 
    Write-Host " 5. Reboot                        U.  Up Time / Boot Time"
    Write-Host " 6. Shutdown                      V.  Windows Version/Memory"
	Write-Host " 7. Boot into BIOS                W.  Wifi Mac Address"	
    Write-Host " 8. BIOS                          LU. List all Local User Accounts"	
	Write-Host " 9. Product Key                   MS. Connect to MS365 PowerShell"
    Write-Host "10. God Mode                      NS. Network Tools Menu"
	Write-Host ""
    Write-Host " The Following require Admin Rights "       -ForegroundColor Yellow -BackgroundColor Green	
    Write-Host "AU. Update All Software Applications       DS. Check Driver Signature"	
	Write-Host "BL. Get BitLocker Status                   H.  Edit HOSTS file"
    Write-Host "BA. Activate BitLocker                     IT. Install AD Remote Tools"    
    Write-Host "GA. Get AutoPilot data, Save to CSV        T.  Get TPM Status"	    
    Write-Host "AJ. Check Azure AD Join                    SC. System Clean Up Menu"
    Write-Host "I.  Enroll in Intune MDM                   VS. Volume Shadow Menu"
    Write-Host "US. Disable Uneccessary Services           SM. Windows Services Menu"
    Write-Host "WU. Windows Update no Reboot               EF. Enable Fingerprint Reader"
    Write-Host "WR. Windows Update with Reboot             "	
    Write-Host "WS. Windows Selective Updates              50. User Profiles"	
    Write-Host ""
    Write-Host "===============================================================================" -ForegroundColor Cyan    
    Write-Host "Q.  Quit    RF. Run Forrest   RP. Dancing Parrot    AS. # of People in Space   " -ForegroundColor Yellow
    Write-Host "===============================================================================" -ForegroundColor Cyan    
}
function Show-SubMenu01 {
    Clear-Host
    Write-Host "========================== System Clean up - Sub Menu =========================" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host " 1. Clean Temp Folders" 
    Write-Host " 2. Clean Windows Update"
    Write-Host " 3. Disk Cleaner"
    Write-Host " 4. System Online Clean up"
    Write-Host " 5. System Scan (SFC /SCANNOW)"	
    Write-Host " 6. System Scan Log"
    Write-Host "===============================================================================" -ForegroundColor Cyan    
    Write-Host "Q.  Return to Main Menu                                                        " -ForegroundColor Yellow
    Write-Host "===============================================================================" -ForegroundColor Cyan 	
}
function Show-SubMenu02 {
    Clear-Host
    Write-Host "========================== Volume Shadow - Sub Menu =========================" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host " 1. List Shadows" 
    Write-Host " 2. Delete All Shadows"
    Write-Host " 3. Delete Oldest Shadows"
    Write-Host " 4. List Writers"
    Write-Host " 5. List Providers"	
    Write-Host "==============================================================================" -ForegroundColor Cyan    
    Write-Host "Q.  Return to Main Menu                                                       " -ForegroundColor Yellow
    Write-Host "==============================================================================" -ForegroundColor Cyan 	
}
function Show-SubMenu03 {
    Clear-Host
    Write-Host "========================== Network Tools - Sub Menu =========================" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host " 1. Address Resolution Protocol (ARP)" 
    Write-Host " 2. Network Status (NETSTAT)"
    Write-Host " 3. Interface Statistics"
    Write-Host " 4. Get IP Configuration"
    Write-Host " 5. Get Network Adapters"
    Write-Host " 6. Test Connection"	
    Write-Host " 7. Connection Test Firewall and Internet"
    Write-Host " 8. DNS Lookup"
    Write-Host " 9. View DNS Cache"
    Write-Host "10. Clear DNS Cache"
    Write-Host "11. Show DNS Servers"
    Write-Host "12. Show default Gateway"    
    Write-Host "=============================================================================" -ForegroundColor Cyan    
    Write-Host "Q.  Return to Main Menu                                                      " -ForegroundColor Yellow
    Write-Host "=============================================================================" -ForegroundColor Cyan 	
    get-service dnscache,dhcp,TermService,WlanSvc |ft Displayname,Status
}
function Show-SubMenu04 {
    Clear-Host
    Write-Host "========================== Services - Sub Menu =========================" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host " 1. List Windows Services" 
    Write-Host " 2. Service Control"
    Write-Host " 3. "
    Write-Host " 4. "
    Write-Host " 5. Delete Service, cannot undo!!!"	
    Write-Host "=========================================================================" -ForegroundColor Cyan    
    Write-Host "Q.  Return to Main Menu                                                  " -ForegroundColor Yellow
    Write-Host "=========================================================================" -ForegroundColor Cyan 	
}

# Process Menus
function Get-Menu      {
	
    $loop = $true
    while ($loop) {
        Show-MainMenu
		$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
		$principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
		$isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
		#
		if ($isAdmin) {
			#Write-Host "PowerShell is running with administrator rights."
		} else {
			Write-Host "PowerShell is NOT running with administrator rights."
			Write-Host "Some menu items will not work. Have a Nice Day!"
			

		}			
		
        $selection = Read-Host "Enter your choice"

        switch ($selection.ToUpper()) {
            '1' { SystemHostname }
            '2' { SystemIPAddresses }
            '3' { RunningProcesses }
            '4' { EvntLog }
            '5' { Restart-Computer -Force }
            '6' { Stop-Computer -ComputerName localhost }
			'7' { echo "This will reboot the system and automatically load the BIOS"
				  pause
				  shutdown /r /fw /t0 
				}				
            '8' { BIOS }
            '9' { Write-Host ""
                  (Get-CimInstance -ClassName SoftwareLicensingService).SubscriptionEdition
                  (Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey
                  Write-Host ""
                  pause
                }
            '10'{ explorer "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}"}            
            '50'{ cmd.exe /c "userpwlz"}
            'AJ'{ Check-Admin
                  cmd.exe /c "dsregcmd /status |more"  
                  pause
                }
			'AU'{ Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
                  cmd.exe /c "winget upgrade --all" 
				  Pause 
				}
			'AS'{ Astronauts }	
            
			'BA'{ Check-Admin
				  Add-BitLockerKeyProtector -MountPoint "C:" -TpmProtector
				  pause
				}
            'BL'{ Check-Admin
                  Get-BitLockerVolume
                  pause
                }
			'GA'{ AutoPilot }	
			'EF'{ EnableFinger }	
            'H' { Check-Admin
                  invoke-item "C:\windows\system32\drivers\etc\HOSTS"
				  pause 
				}
            'I' { Intune-Enroll }			
            'IA'{ powershell -ExecutionPolicy Bypass "\\ast-aws-fs00\Hardware$\get-assetinfo.ps1"
				  pause
				}
			'IT'{ ADTools }
			'LU'{ #Invoke-Command  -ScriptBlock {Get-LocalUser}
				  Get-LocalUser |ft Name,Enabled,LastLogon
				  write-host "Local Groups..."
				  get-LocalGroup |ft Name
				  pause
				}
			'DS'{ sigverif }			
			'MS'{
				echo "This will connect PowerShell to MS365/Azure and then exit this app"
				pause
				Install-Module ExchangeOnlineManagement
				Install-Module Microsoft.Graph				
				Install-Module MSOnline
				connect-MgGraph
				Connect-Graph -scopes "User.Read.All", "Group.ReadWrite.All", "Device.Read.All", "DeviceManagementManagedDevices.PrivilegedOperations.All","DeviceManagementManagedDevices.ReadWrite.All", "DeviceManagementApps.ReadWrite.All", "DeviceManagementConfiguration.ReadWrite.All"
				pause				
				exit
			    }
			'NS'{ Get-SubMenu03 } #Network Tools Sub-menu 
            'RA'{ Run-Admin }  # restart w/ Admin Rights
            'RF'{ write-host "Crtl + C to quit, you will need to restart MENU"
				  pause
				  cmd /c "curl ascii.live/forrest"
				}
			'RP'{ write-host "Crtl + C to quit, you will need to restart MENU"
				  pause
				  cmd /c "curl ascii.live/parrot"				  
				}
            'RR'{ write-host "Crtl + C to quit, you will need to restart MENU"
				  pause
				  cmd /c "curl ascii.live/rick"
                }				  
            'S' { get-service |out-gridview } 
            'SC'{ Get-SubMenu01 } #System Clean Sub-menu 
            'SD'{ System }            
            'SM'{ #Check-Admin
                  Get-SubMenu04 
                } #Services Sub-menu }
            'SS'{ WhyNot }
            'T' { Get-TPM
                  Pause
                }
            'U' { Uptime }
            'US'{ ServicesDisabled }
            'V' { SystemVersion }
            'VS'{ Check-Admin
                  Get-SubMenu02 
                } #Volume Shadow Sub-menu
            'W' { SystemWeeFeeMac }
			'WR'{ WinUpdate
				  Restart-Computer -Force
                  Write-Host "Reboot initiated..."
                  exit	
                }
            'WS'{ WinUpdateSelect }
			'WU'{ WinUpdate }      

            'SM'{ Check-Admin
                  Get-SubMenu01 
                } #System Clean up Sub-Menu        
            'Q' { 
                $loop = $false 
                Write-Host "Exiting script. Goodbye!" -ForegroundColor Yellow
                exit
            }
            Default { 
                Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                Pause
            }
        }
    }
}
function Get-SubMenu01 {
    $loop = $true
    while ($loop) {
        Show-SubMenu01
        $selection = Read-Host "Enter your choice"
        switch ($selection.ToUpper()) {
			'1'{ ClnTemp }
			'2'{ WinUpdateReset }
			'3'{ DiskClean }
            '4'{ Check-Admin
                 DISM /Online /Cleanup-Image /RestoreHealth 
                 pause
                 Get-SubMenu01
                }
            '5'{ Check-Admin
                  sfc /scannow 
                  pause
                  Get-SubMenu01
                }
            '6'{ notepad C:\Windows\Logs\CBS\CBS.log }
            'Q'{ Get-Menu } #return to main menu
        }
    }
}
function Get-SubMenu02 {
    $loop = $true
    while ($loop) {
        Show-SubMenu02
        $selection = Read-Host "Enter your choice"
        switch ($selection.ToUpper()) {
			'1'{ vssadmin list shadows
                 pause
               }
			'2'{ vssadmin delete shadows /for=c: /all /quiet
                 pause
               }
			'3'{ vssadmin delete shadows /for=c: /oldest /quiet
                 pause
               }
            '4'{ vssadmin list writers               
                 pause                
               }
            '5'{ vssadmin list providers              
                 pause                
               }
            
            'Q'{ Get-Menu } #return to main menu
        }
    }
}
function Get-SubMenu03 {
    $loop = $true
    while ($loop) {
        Show-SubMenu03        
        $selection = Read-Host "Enter your choice"
        switch ($selection.ToUpper()) {
			'1'{ cmd.exe /c 'arp -a'
                 pause
               }
			'2'{ Get-NetTCPConnection |more
                 pause
               }
			'3'{ cmd.exe /c 'netstat -e'
                 pause
               }
            '4'{ Get-NetIPConfiguration
                 pause                
               }
            '5'{ Get-NetAdapter
                 pause                
               }
            '6'{ $lookupHost = Read-Host "Enter host DNS Name or IP to test"                 
                 $remoteHost = Read-Host "Enter Remote Source address"
                 if ($lookupHost -ne "" ){                    
                    if ($remoteHost -eq "" ){
                        Test-Connection -ComputerName $lookupHost }
                    else{
                        Test-Connection -ComputerName $lookupHost -Source $remoteHost }                    
                    pause
                 }               
               }
            '7'{ TestNetwork }
            '8'{ $lookupHost = Read-Host "Enter host to lookup"
                 if ($lookupHost -ne "" ){
                    Clear-Host
                    $job=Start-Job -ScriptBlock {
                        param ($lookupHost)
                        Resolve-DnsName -Name $lookupHost -Type All
                    } -ArgumentList $lookupHost
                    receive-job -Id $job.Id -Wait                                       
                    remove-job -Id $job.Id
                 }
                 #pause
               }   
            '9'{ Get-DnsClientCache | ft data, Entry,Name,TTL |more
                 pause
               } 
           '10'{ clear-DnsClientCache }            
           '11'{ Get-DnsClientServerAddress |ft InterfaceAlias,InterfaceIndex,AddressFamily,ServerAddresses
                 pause
               }
           '12'{ DefaultGW }
            'Q'{ Clear-Host
                 Get-Menu 
               } #return to main menu
        }
    }
}
function Get-SubMenu04 {
    $loop = $true
    while ($loop) {
        Show-SubMenu04        
        $selection = Read-Host "Enter your choice"
        switch ($selection.ToUpper()) {
			'1'{ Get-Service |ft
                 Pause
               }
			'2'{ ServiceState }
            '5'{ ServiceDelete }
            'Q'{ Get-Menu } #return to main menu
        }
    }
}
# Check if admin rights are present
function Check-Admin {    
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    $isAdmin = $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if ($isAdmin) {
        #Write-Host "PowerShell is running with administrator rights."
    } else {
        Write-Output "The current user is NOT a part of the Administrators group."
        pause
        Get-Menu
    }
}
function Run-Admin {
    # Prompt for credentials
	$cred = Get-Credential -Message "Please enter admin credentials"
		
	# Relaunch script with elevated privileges using Start-Process
	Start-Process powershell -Verb RunAs -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$PSCommandPath`"",
        "-Credential", "`"$cred`"",
        $argList -join ' '
    )

	# Exit current non-admin session
	#exit	
}

# Define Menu items
function ADTools{
	# List all RSAT Active Directory related features
	Write-Host "Checking if Tools already installed"
	Get-WindowsCapability -Name RSAT:ActiveDirectory* -Online
	Write-Host "INSTALLING WILL TAKE A VERY LLLLOOONNNGGGG TIME, so only start when computer will be running for a bit."
	pause
	# Install the RSAT Active Directory module
	Add-WindowsCapability –online –Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
	# Load the AD module into your session
	Import-Module ActiveDirectory
	# Install every RSAT tool available
	Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
	Add-WindowsCapability -Name Rsat.DHCP.Tools~~~~0.0.1.0 -Online
	Add-WindowsCapability -Name Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0 -Online
	Add-WindowsCapability -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0 -Online	
	# Test by getting the current domain
	Get-ADDomain
	pause
}
function AutoPilot {
    Check-Admin
    $folderPath = "C:\Temp"
    if (Test-Path -Path $folderPath) {
        	Write-Host "The folder '$folderPath' exists."
    } else {
        Write-Host "The folder '$folderPath' does not exist."
		New-Item -Path "C:\Temp\" -ItemType Directory
    }	
	Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
	Install-Script -Name Get-WindowsAutoPilotInfo -RequiredVersion 3.8
	Get-WindowsAutoPilotInfo -OutputFile "$($folderPath)\AutopilotDevices.csv" 
	Write-Host "File $($folderPath)\AutopilotDevices.csv created..."
	#Get-WindowsAutoPilotInfo -Online -GroupTag "Astech" -AssignedComputerName $(hostname)
	Pause	
}
function Astronauts {
	Write-Host "Processing, counting people 1,2,3..."
	$uri = "http://api.open-notify.org/astros.json" # Example public API
	$response = Invoke-RestMethod -Uri $uri -Method Get
	# The response is a PSCustomObject and can be accessed using dot notation
	Write-Host "Message: $($response.message)"
	Write-Host "Number of people in space: $($response.number) (According to NASA anyways)"
	Pause
}
function BIOS {
    Get-CimInstance -ClassName Win32_BIOS
    Pause
}
function ClnTemp {
	Check-Admin
	# PowerShell Script: Clean Temp Folders Safely
	# This script deletes files and folders from temp directories
	# Run as Administrator for full cleanup

	# Define temp paths
	$tempPaths = @(
		"$env:TEMP",                      # Current user's temp folder
		"$env:TMP",                       # Current user's TMP folder
		"C:\Windows\Temp",                # System temp folder
		"C:\Temp",                 		  # Custom temp folder
		"C:\Users\*\AppData\Local\Temp\"
	)

	# Create a log file
	#$logFile = "$env:USERPROFILE\temp_cleanup_log.txt"
	$logFile = "temp_cleanup_log.txt"
	"Temp Cleanup Log - $(Get-Date)" | Out-File -FilePath $logFile -Encoding UTF8

	foreach ($path in $tempPaths) {
		if (Test-Path $path) {
			Write-Host "Cleaning: $path" -ForegroundColor Cyan
			#Add-Content -Path $logFile -Value "`nCleaning: $path"

			try {
				# Remove files
				Get-ChildItem -Path $path -File -Recurse -Force -ErrorAction SilentlyContinue |
					ForEach-Object {
						try {
							Remove-Item $_.FullName -Force -ErrorAction Stop
							#Add-Content -Path $logFile -Value "Deleted file: $($_.FullName)"
						} catch {
							#Add-Content -Path $logFile -Value "Failed to delete file: $($_.FullName) - $($_.Exception.Message)"
						}
					}

				# Remove empty folders
				Get-ChildItem -Path $path -Directory -Recurse -Force -ErrorAction SilentlyContinue |
					Sort-Object FullName -Descending | # Delete deepest folders first
					ForEach-Object {
						try {
							Remove-Item $_.FullName -Force -Recurse -ErrorAction Stop
							#Add-Content -Path $logFile -Value "Deleted folder: $($_.FullName)"
						} catch {
							#Add-Content -Path $logFile -Value "Failed to delete folder: $($_.FullName) - $($_.Exception.Message)"
						}
					}

			} catch {
				#Write-Warning "Error cleaning $path: $_"
				Write-Warning "Error cleaning"
				#Add-Content -Path $logFile -Value "Error cleaning $path: $($_.Exception.Message)"
			}
		} else {
			Write-Host "Path not found: $path" -ForegroundColor Yellow
			#Add-Content -Path $logFile -Value "Path not found: $path"
		}
	}

	Write-Host "Cleanup complete. Log saved to: $logFile" -ForegroundColor Green
    pause
    Get-SubMenu01	
}
function DiskClean {
	
	# Run Disk Cleanup silently
	Check-Admin
	cleanmgr /sagerun:1
	Write-Host "Check App Popup for completion!" -ForegroundColor Green
	pause
    Get-SubMenu01
}
function EnableFinger{
	# Set Registry
	Write-Host "Adding Registry..."    
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{BEC09223-B018-416D-A0AC-523971B639F5}\" 
    #Begin: set Registry values
	New-ItemProperty -LiteralPath $path -Name "@"        -value "WinBio Credential Provider" -PropertyType String -Force -ea SilentlyContinue;    
    New-ItemProperty -LiteralPath $path -Name 'Disabled' -Value "-" -PropertyType String -Force -ea SilentlyContinue;    
    #End: set Registry values
	Write-Host "Registry settings added!!!"
	pause
}
function EvntLog {	
    Clear-Host
    Write-Host "APPLICTION LOGS"  -ForegroundColor Green
    Get-WinEvent -LogName Application -MaxEvents 10 -FilterXPath "*[System[(Level=2)]]"
    pause
    Clear-Host
    Write-Host "SYSTEM LOGS"  -ForegroundColor Green
    Get-WinEvent -LogName System -MaxEvents 10 -FilterXPath "*[System[(Level=2)]]"
    pause
    Clear-Host
    Write-Host "SECURITY LOGS"  -ForegroundColor Green
    Get-WinEvent -LogName Security -MaxEvents 10 -FilterXPath "*[System[(Level=2)]]"
    pause    
}
function DefaultGW {
    try {
        # Get the default IPv4 route (DestinationPrefix 0.0.0.0/0)
        $defaultRoute = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction Stop |
                        Sort-Object RouteMetric |
                        Select-Object -First 1

        # Validate that a default route was found
        if (-not $defaultRoute) {
            throw "Default route not found."
        }

        # Store key values in variables
        $gateway     = $defaultRoute.NextHop
        $interface   = $defaultRoute.InterfaceAlias
        $metric      = $defaultRoute.RouteMetric

        # Output values for confirmation
        Write-Host "Default Route Found:"
        Write-Host " Gateway:        $gateway"
        Write-Host " Interface:      $interface"
        Write-Host " Route Metric:   $metric"
    }
    catch {
        Write-Error "Error retrieving default route: $_"
    }
    pause
}
function Intune-Enroll{
    # Set MDM Enrollment URL's
    $path = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\"
    $key = 'SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\*'
    $default = '6cf57820-9122-4269-b579-57f7dd5c0330'

    if ( !(Test-Path $path )) {
        Write-Host "Sum Ting Whealing Wong!"        
        Write-Host "Please Enter your MS365 Tenant ID (########-####-####-####-############)"
        $selection = Read-Host "Enter ID: [$default]"
        #Create branch (Still need to code)
        #New-ItemProperty -LiteralPath $path -Name 'AccessTokenUrl'   -Value "https://login.microsoftonline.com/$selection/oauth2/token" -PropertyType String -Force -ea SilentlyContinue;
        #New-ItemProperty -LiteralPath $path -Name 'AuthCodeUrl'      -Value "https://login.microsoftonline.com/$selection/oauth2/authorize" -PropertyType String -Force -ea SilentlyContinue;
        #New-ItemProperty -LiteralPath $path -Name 'DeviceManagementEndpoint' -Value "https://enterpriseregistration.windows.net/manage/$selection/" -PropertyType String -Force -ea SilentlyContinue;
        #New-ItemProperty -LiteralPath $path -Name 'KerbEndpoint'     -Value "https://login.microsoftonline.com/$selection/kerberos" -PropertyType String -Force -ea SilentlyContinue;
        #New-ItemProperty -LiteralPath $path -Name 'WebAuthnEndpoint' -Value "https://enterpriseregistration.windows.net/webauthn/$selection/" -PropertyType String -Force -ea SilentlyContinue;
        
        #New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' -PropertyType String -Force -ea SilentlyContinue;
        #New-ItemProperty -LiteralPath $path -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String -Force -ea SilentlyContinue;
        #New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType String -Force -ea SilentlyContinue;        
        pause
        Intune-Enroll        
    } else { Write-Host "Found registry key, continuing..." }
    

    try{ $keyinfo = Get-Item "HKLM:\$key" -ErrorAction Stop }      
    catch [System.IO.FileNotFoundException] {
        Write-Host "Tenant ID is not found!"        
        pause
        Get-Menu
    }    
    #finally { exit 1001 }
    exit 
    $url = $keyinfo.name
    $url = $url.Split("\")[-1]
    write $keyinfo.name
    $path = "$path$url"

    #Begin: set Registry values
    New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath $path -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String -Force -ea SilentlyContinue;
    New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType String -Force -ea SilentlyContinue;
    #End: set Registry values

    if(!(Test-Path $path)){
        Write-Host "KEY $path not found!"
        exit 1001
    }else{
        try{
            Get-ItemProperty $path -Name MdmEnrollmentUrl
        }
        catch{
            Write_Host "MDM Enrollment registry keys not found. Registering now..."
            #Begin: set Registry values
            New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath $path -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String -Force -ea SilentlyContinue;
            New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType String -Force -ea SilentlyContinue;
            #End: set Registry values
        }
        finally{
        # Trigger AutoEnroll with the deviceenroller
            try{
                C:\Windows\system32\deviceenroller.exe /c /AutoEnrollMDM
                Write-Host "Device is performing the MDM enrollment!"
               exit 0
            }
            catch{
                Write-Host "Something went wrong (C:\Windows\system32\deviceenroller.exe)"
               exit 1001          
            }

        }
    }

    $triggers = @()

    $triggers += New-ScheduledTaskTrigger -At (get-date) -Once -RepetitionInterval (New-TimeSpan -Minutes 1)

    $User = "SYSTEM"

    $Action = New-ScheduledTaskAction -Execute "%windir%\system32\deviceenroller.exe" -Argument "/c /AutoEnrollMDM"

    $Null = Register-ScheduledTask -TaskName "TriggerEnrollment" -Trigger $triggers -User $User -Action $Action -Force
    Start-ScheduledTask -TaskName "TriggerEnrollment"
	
	pause
}
function RunningProcesses {
    Write-Host "Running Processes:" -ForegroundColor Green
    Get-Process | Select-Object ProcessName, Id, CPU, WorkingSet | Sort-Object ProcessName | Format-Table -AutoSize | more
    Pause
}
function ServiceDelete{
    Check-Admin    
    $SrvcName = Read-Host "Enter service name to delete"
    if ($SrvcName -eq ""){ Get-SubMenu04 }
    try {        
        if (-not (get-service -Name $SrvcName )){
            throw "Invalid Service, please check the service name"                      
        }
    }
    catch {
        Write-Host "Invalid input: $($_.Exception.Message)" -ForegroundColor Red        
        ServiceState  
    }
    $param="-ForegroundColor Yellow -BackgroundColor Red"
    Write-Host " THIS WILL DELETE THE WINODWS SERVICE $($SrvcName) " -ArgumentList @("`"$param`"",$argList -join ' ')
    Write-Host " ONCE EXECUTED, IT CANNOT BE UNDONE   " -ArgumentList @("`"$param`"")
    # Ask the user for confirmation
    $response = Read-Host "Are you sure you want to proceed? (Y/N)"

    # Check the response
    if ($response -match '^[Yy]$') {
        Write-Host "Proceeding..."
        # Place your code here
        cmd.exe /c "sc delete $($SrvcName)"
    } else {5
        Write-Host "Operation cancelled."
    }
    
    pause
        
}
function ServiceState{
    $loop = $true    
    $SrvcName = Read-Host "Enter service name"
    if ($SrvcName -eq ""){ Get-SubMenu04 }
    try {        
        if (-not (get-service -Name $SrvcName )){
            throw "Invalid Service, please check the service name"                      
        }
    }
    catch {
        Write-Host "Invalid input: $($_.Exception.Message)" -ForegroundColor Red        
        ServiceState  
    }
    while ($loop) {            
        Write-Host " Required Services " -ForegroundColor Black -BackgroundColor Yellow
        get-service -Name $SrvcName -RequiredServices | select -property name,status,displayname,starttype
        Start-Sleep -Seconds 2
        Write-Host " Dependent Services " -ForegroundColor Black -BackgroundColor Yellow
        get-service -Name $SrvcName -DependentServices | select -property name,status,displayname,starttype
        Start-Sleep -Seconds 2
        Write-Host " Service Status " -ForegroundColor Black -BackgroundColor Yellow
        get-service -Name $SrvcName | select -property name,status,displayname,starttype
        Start-Sleep -Seconds 2
        Write-Host ""
        ServiceState2 ($SrvcName)        
    }
}
function ServiceState2 {
    Check-Admin
    Write-Host "*********************" -ForegroundColor White -BackgroundColor red
    Write-Host "1. Stop Service"
    Write-Host "2. Start Service"
    Write-Host "3. Restart Service"
    Write-Host "4. Disable Service"
    Write-Host "5. Autostart Service"
    Write-Host "6. Manual Service"
    Write-Host "*********************" -ForegroundColor White -BackgroundColor red
    Write-Host "Q. Cancel            " -ForegroundColor White -BackgroundColor red
    Write-Host "*********************" -ForegroundColor White -BackgroundColor red
    $SrvcAct = Read-Host "Enter service action"
    #if ($SrvcAct -eq ""){ Get-SubMenu04 }
    switch ($SrvcAct.ToUpper()) {
        '1'{ Stop-Service -Name $SrvcName }
        '2'{ Start-Service -Name $SrvcName }
        '3'{ ReStart-Service -Name $SrvcName }
        '4'{ Set-Service -Name $SrvcName -StartupType Disabled }
        '5'{ Set-Service -Name $SrvcName -StartupType Automatic }
		'6'{ Set-Service -Name $SrvcName -StartupType Manual }
		'7'{ ServiceState }
        'Q'{ Get-SubMenu04 } #return to sub menu
    }
    clear-host
    Write-Host "----------------------------------------------------------"
    get-service -Name $SrvcName | select -property name,status,displayname,starttype    
    Write-Host "----------------------------------------------------------"
    ServiceState2 ($SrvcName)
}
function ServicesDisabled {
    Check-Admin  
    $servicesToDisable = @(
        "XboxGipSvc",    
        "XblAuthManager",
        "XblGameSave",
        "XboxNetApiSvc",
        "GameInputSvcv",
        "BcastDVRUserService_ecc9e5",
        "RetailDemo",
        "shpamsvc",
        "workfolderssvc",
        "p2psvc",
        "CscService",
        "fax",
        "PcaSvc",
        "lfsvc",
        "WerSvc",
        "icssvc"
    )
    foreach ($serviceName in $servicesToDisable) {
        try {
            # Get the service object
            $service = Get-Service -Name $serviceName -ErrorAction Stop

            # Stop the service if it's running
            if ($service.Status -ne 'Stopped') {
                Write-Host "Stopping service: $serviceName..."
                Stop-Service -Name $serviceName -Force -ErrorAction Stop
            }

            # Set startup type to Disabled
            Set-Service -Name $serviceName -StartupType Disabled -ErrorAction Stop
            Write-Host "Service '$serviceName' has been disabled successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "Error processing service '$serviceName': $_" -ForegroundColor Red
        }
    }
    Pause
}
Function System {
    Get-CimInstance -ClassName Win32_BIOS
    Get-CimInstance -ClassName Win32_ComputerSystem
    
    $CIMMemory = Get-CIMINStance CIM_PhysicalMemory
    $OSTotalVirtualMemory = [math]::round($OSInfo.TotalVirtualMemorySize / 1MB, 2)
    $OSTotalVisibleMemory = [math]::round(($OSInfo.TotalVisibleMemorySize / 1MB), 2)
    $PhysicalMemory = [Math]::Round((($CIMMemory | Measure-Object -Property capacity -sum).sum / 1GB), 2)
    Write-Host "Memory              : $( $PhysicalMemory) GB"
    Write-Host ""

    Get-CimInstance -ClassName Win32_ComputerSystem -Property UserName
    Get-CimInstance -ClassName Win32_Processor | Select-Object -ExcludeProperty "CIM*"
    
    Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property SystemType    
    Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
       
    Write-Host "OPERATING SYSTEM..." -ForegroundColor Green
    Get-ComputerInfo -Property "OsName", "OsVersion"
    Get-CimInstance -ClassName Win32_OperatingSystem |
    Select-Object -Property BuildNumber,BuildType,OSType,ServicePackMajorVersion,ServicePackMinorVersion
    Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property *user*
    Pause

}
function SystemHostname {
    Write-Host "System Hostname: $(hostname)" -ForegroundColor Green
    systeminfo | findstr "Domain"
    Pause
}
function SystemIPAddresses {
    Write-Host "System IP Addresses:" -ForegroundColor Green
    Get-NetIPAddress | Where-Object {$_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -notmatch 'Loopback|vEthernet'} | Select-Object InterfaceAlias, IPAddress | Format-Table
    Pause
}
function SystemVersion {
    Get-ComputerInfo -Property "OsName", "OsVersion"
    Pause
}
function SystemWeeFeeMac {
    $CIMNetwork = Get-CimInstance Win32_NetworkAdapter
    $WifiMac = $CIMNetwork | Where-Object { $_.Name -match ("Wireless|wifi|wi\-fi") -and ($_.name -notlike "*virtual*") } | 
    Select-object -ExpandProperty MacAddress
    Write-Host "WiFi Mac  : $($WifiMac)"
    Pause
}
function TestNetwork {
    Write-Host "Testing Firewall (GATEWAY)"
    $ActiveNet =  Get-NetAdapter –Physical  |Where-Object {$_.status -eq "Up"} |  select name 
    $Network = Get-NetIPAddress |Where-Object EnabledDefault -EQ 2 | Where-Object InterfaceAlias  -EQ $ActiveNet.name  | Where-Object IPv4Address -NE $null | select * 
    $DefautGateway = Get-NetRoute -InterfaceIndex $Network.InterfaceIndex -DestinationPrefix "0.0.0.0/0" | select NextHop                 
    Test-Connection $DefautGateway.NextHop | ft PSComputerName,Address, IPV4Address,IPV6Address, ReplySize,ResponseTime
    Write-Host "Testing Internet Connection"
    Test-Connection 1.1.1.1 | ft PSComputerName,Address, IPV4Address,IPV6Address, ReplySize,ResponseTime
    pause
}
function Uptime {
    (Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime
	systeminfo | find "Boot Time"
    Pause
}
function WinUpdate{
	Check-Admin
	Write-Output "Running Windows update, this may take sometime!!!"
	Write-Output "We will check, download and install any updates found..."
    
    if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
        Write-Host "Module exists, Continue with update..."             
    } else {
        Write-Host "Module does not exist"        
        # Import the Windows Update module 
	    Import-Module PSWindowsUpdate 
        # Install the Windows Update module 
        Install-Module -Name PSWindowsUpdate -Force -AllowClobber 
    }
	
	# Check for updates 
	Get-WindowsUpdate -AcceptAll -Install -Verbose 

	pause
}
function WinUpdateReset{
	Check-Admin
	Stop-Service -Name "wuauserv"
	Stop-Service -Name "bits"
	#del /s /q c:\windows\SoftwareDistribution\*
	# Define the target folder path
	$folderPath = "c:\windows\SoftwareDistribution"
	try {
		if (Test-Path $folderPath) {
			# Remove all contents inside the folder, but not the folder itself
			Remove-Item -Path (Join-Path $folderPath '*') -Recurse 	-Force 	-ErrorAction Stop
			Write-Host "Contents of '$folderPath' deleted successfully."
		}
		else {
			Write-Host "Folder '$folderPath' does not exist."
		}
	}
	catch {
		Write-Host "Error deleting contents: $($_.Exception.Message)"
	}	
	Start-Service -Name "bits"
	Start-Service -Name "wuauserv"
	pause
    Get-SubMenu01	
}
function WinUpdateSelect{
    Check-Admin
    Write-Host "Collecting Updates..."
    Install-Module -Name PSWindowsUpdate -Force
    Import-Module PSWindowsUpdate
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
    Write-Host "Available Updates..."
    Get-WindowsUpdate 
    Write-Host "Step through Updates and prompt to install"
    Get-WindowsUpdate -install
    pause
}
function WhyNot {
    #Get Sytem information, why?  Why Not.
    $LastUser = Get-CimInstance Win32_UserProfile -Filter 'Special=FALSE' | Sort-Object LastUseTime -Descending |
    Select-Object -First 1 | ForEach-Object {
        ([System.Security.Principal.SecurityIdentifier]$_.SID).Translate([System.Security.Principal.NTAccount]).Value
    }

    $CIMCS = Get-Ciminstance -class win32_ComputerSystem
    $CPUInfo = $CIMcs.name
    $MN = $CIMcs.Model

    $OSInfo = Get-CIMinstance Win32_OperatingSystem
    $OSInstallDate = $OSInfo.InstallDate

    $CIMMemory = Get-CIMINStance CIM_PhysicalMemory
    $OSTotalVirtualMemory = [math]::round($OSInfo.TotalVirtualMemorySize / 1MB, 2)
    $OSTotalVisibleMemory = [math]::round(($OSInfo.TotalVisibleMemorySize / 1MB), 2)
    $PhysicalMemory = [Math]::Round((($CIMMemory | Measure-Object -Property capacity -sum).sum / 1GB), 2)

    $CIMBios = Get-Ciminstance Win32_BIOS
    $SN = $CIMBios.serialnumber
    $MF = $CIMBios.manufacturer

    $CIMDisk = Get-Ciminstance Win32_logicalDisk
    $DISKTOTAL = $CIMDisk | Where-Object caption -eq "C:" | foreach-object { Write-Output "$('{0:N2}' -f ($_.Size/1gb)) GB " }
    $DISKFREE = $CIMDisk | Where-Object caption -eq "C:" | foreach-object { Write-Output "$('{0:N2}' -f ($_.FreeSpace/1gb)) GB " }
    
    $CIMNetwork = Get-CimInstance Win32_NetworkAdapter
    $WifiMac = $CIMNetwork | Where-Object { $_.Name -match ("Wireless|wifi|wi\-fi") -and ($_.name -notlike "*virtual*") } | 
    Select-object -ExpandProperty MacAddress
    
    $CIMNetCfg = Get-Ciminstance Win32_NetworkAdapterConfiguration    
    $MAC = $CIMNetCfg | Where-Object { $_.ipenabled -EQ $true } | select-object -first 1 -ExpandProperty MacAddress

    $CIMMonitors = Get-WMIObject WmiMonitorID -Namespace root\wmi

    $CIMChassis = Get-CimInstance Win32_SystemEnclosure | Select-object -ExpandProperty ChassisTypes
    $CIMCS = Get-Ciminstance -class win32_ComputerSystem
    $CPUInfo = $CIMcs.name
    $IP = (Test-Connection $CPUInfo -count 1).IPv4Address.IPAddressToString

    Foreach ($CPU in $CPUInfo) {		
        $infoObject = [PSCustomObject][ordered]@{
		#The following add data to the infoObjects.	
		"Asset: Name"                   = $CPUInfo
		"Asset: Tag"                    = $AT
		"Asset: Model Number"           = $MN
		"Asset: Manufacturer"           = $MF
		"Asset: Serial Number"          = $SN
		"Inventory: Status"             = $status
		"Inventory: Timestamp"          = $(Get-Date)
		"Inventory: Chassis"            = $Chassis
		"OS: Name"                      = $OSInfo.Caption
		"OS: Install Date"              = $OSInstallDate
		"OS: Last User"                 = $lastuser
		"Sub-Assets: Monitors"          = $MonitorFriendly
		"Specs: Physical RAM"           = $PhysicalMemory
		"Specs: Virtual Memory"         = $OSTotalVirtualMemory
		"Specs: Visable Memory"         = $OSTotalVisibleMemory
		"Specs: Total Disk Space"       = $DISKTOTAL
		"Specs: Free Disk Space"        = $DISKFREE
		"Network: IP Address"           = $IP
		"Network: Wireless MAC Address" = $WifiMAC
		"Network: Ethernet MAC Address" = $MAC
    	}
    	write $infoObject
    }
    Pause
}




##BEGIN HERE ##
#display menu
Get-Menu