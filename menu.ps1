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
# 2023/05/10:AWH - Added more functionality
# 2024/02/1 :AWH - Added more functionality
# 2025/11/11:AWH - Added more functionality
#            (TPM, AutoPilot, Intune)
# 2026/06/11:AWH - Added Sub-Menu for cleaner look
# 2026/06/26:AWH - Added more functionality
#            (Service Submenu and controls, Azure AD Join)
# 2026/09/15:AWH - Added Backup Drivers
# 2026/09/18:AWH - Bug-fix pass: removed forced startup
#            error, fixed console resize crash, fixed
#            recursive menu navigation (stack growth),
#            fixed broken string concatenation/typos,
#            fixed duplicate menu keys, added a safety
#            net around menu actions so one bad command
#            no longer kills the whole session.
#=======================================================

# Try to relax the execution policy for this process/user so the script
# and the modules it calls (PSWindowsUpdate, etc.) can actually run.
# Only warn if it fails - don't blow up on every launch.
try {
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force -ErrorAction Stop
}
catch {
    Write-Host "WARNING: Could not set Process execution policy: $($_.Exception.Message)" -ForegroundColor Yellow
}
try {
    Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force -ErrorAction Stop
}
catch {
    Write-Host "WARNING: Could not set CurrentUser execution policy: $($_.Exception.Message)" -ForegroundColor Yellow
}
# NOTE: LocalMachine scope requires admin rights and will fail for standard
# users on every single launch - only attempt it if we're actually elevated.
$startupIdentity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$startupPrincipal = New-Object System.Security.Principal.WindowsPrincipal($startupIdentity)
if ($startupPrincipal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        Set-ExecutionPolicy -Scope LocalMachine -ExecutionPolicy RemoteSigned -Force -ErrorAction Stop
    }
    catch {
        Write-Host "WARNING: Could not set LocalMachine execution policy: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

#Get-ExecutionPolicy -List

# Define Menus
function Show-MainMenu  {
    Clear-Host
    Write-Host "===================================== Menu =====================================" -ForegroundColor Cyan -BackgroundColor Yellow
    Write-Host " 1. Show System Hostname          IA. Get AssetInventory for SnipeIT to import  "
    Write-Host " 2. Show System IP Addresses      S.  Get Service List                          "
    Write-Host " 3. List Running Processes        SS. System Summary                            "
    Write-Host " 4. Last 10 Event Logs            SD. System Detail                             "
    Write-Host " 5. Reboot                        PM. Performance Monitor                       "
    Write-Host " 6. Shutdown                      RM. Reliability Monitor                       "
    Write-Host " 7. Boot into BIOS                U.  Up Time / Boot Time                       "
    Write-Host " 8. BIOS                          V.  Windows Version/Memory                    "
    Write-Host " 9. Product Key                   W.  Wifi Mac Address                          "
    Write-Host "10. Activate Windows              LU. List all Local User Accounts              "
    Write-Host "11. UI Tweaks                     MS. Connect to MS365 PowerShell               "
    Write-Host "AT. Admin Tools                   NS. Network Tools Menu                        "
    Write-Host "--------------------------------------------------------------------------------"
    Write-Host " The Following require Admin Rights "       -ForegroundColor Yellow -BackgroundColor Green
    Write-Host "WU. Windows/App Update                     DS. Check Driver Signature"
    Write-Host "BL. Get BitLocker Status                   H.  Edit HOSTS file"
    Write-Host "BA. Activate BitLocker                     IT. Install AD Remote Tools"
    Write-Host "GA. Get AutoPilot data, Save to CSV        T.  Get TPM Status"
    Write-Host "AJ. Check Azure AD Join                    SC. System Clean Up Menu"
    Write-Host "I.  Enroll in Intune MDM                   VS. Volume Shadow Menu"
    Write-Host "US. Disable Unnecessary Services           SM. Windows Services Menu"
    Write-Host "EF. Enable Fingerprint Reader               "
    Write-Host "BD. Backup System Drivers"
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "Q.  Quit    RF. Run Forrest   RP. Dancing Parrot    AS. # of People in Space   " -ForegroundColor Yellow
    Write-Host "===============================================================================" -ForegroundColor Cyan

    if (-not $script:IsAdmin) {
        Write-Host "PowerShell is NOT running with administrator rights. Some menu items will not work." -ForegroundColor Red
    }
}
function Show-SubMenu01 {
    Clear-Host
    Write-Host "========================== System Clean up - Sub Menu =========================" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host " 1. Clean Temp Folders                                                         "
    Write-Host " 2. Clean Windows Update                                                       "
    Write-Host " 3. Disk Cleaner                                                               "
    Write-Host " 4. System Online Clean up                                                     "
    Write-Host " 5. System Scan (SFC /SCANNOW)                                                 "
    Write-Host " 6. System Scan Log                                                            "
    Write-Host " 7. System Repair                                                              "
    Write-Host "===============================================================================" -ForegroundColor Cyan
    Write-Host "Q.  Return to Main Menu                                                        " -ForegroundColor Yellow
    Write-Host "===============================================================================" -ForegroundColor Cyan
} #System Clean Up
function Show-SubMenu02 {
    Clear-Host
    Write-Host "========================== Volume Shadow - Sub Menu =========================" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host " 1. List Shadows"
    Write-Host " 2. Delete All Shadows"
    Write-Host " 3. Delete Oldest Shadows"
    Write-Host " 4. List Writers"
    Write-Host " 5. List Providers"
    Write-Host " 6. Enable Volume Shadow"
    Write-Host " 7. Create Restore Point"
    Write-Host "==============================================================================" -ForegroundColor Cyan
    Write-Host "Q.  Return to Main Menu                                                       " -ForegroundColor Yellow
    Write-Host "==============================================================================" -ForegroundColor Cyan
} #Volume Shadow
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
    Write-Host "13. Get Hostname"
    Write-Host "14. Set NTP"
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Write-Host "Q.  Return to Main Menu                                                      " -ForegroundColor Yellow
    Write-Host "=============================================================================" -ForegroundColor Cyan
    Get-Service dnscache, dhcp, TermService, WlanSvc -ErrorAction SilentlyContinue | Format-Table Displayname, Status
} #Network Tools
function Show-SubMenu04 {
    Clear-Host
    Write-Host "========================== Services - Sub Menu =========================" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host " 1. List Windows Services                                               "
    Write-Host " 2. Service Control                                                     "
    Write-Host " 5. Delete Service, cannot undo!!!                                      "
    Write-Host "========================================================================" -ForegroundColor Cyan
    Write-Host "Q.  Return to Main Menu                                                 " -ForegroundColor Yellow
    Write-Host "========================================================================" -ForegroundColor Cyan
} #Services
function Show-SubMenu05 {
    Clear-Host
    Write-Host "======================= Windows Updates - Sub Menu ======================" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host "1. Update All Software Applications                                      "
    Write-Host "2. Windows Update no Reboot                                              "
    Write-Host "3. Windows Update with Reboot                                            "
    Write-Host "4. Windows Selective Updates                                             "
    Write-Host "5. Reset Windows Updates                                                 "
    Write-Host "6. Install Windows Subsystem for Linux  (Ubuntu, Default)                "
    Write-Host "7. Install Windows Subsystem for Linux  (Kali)                           "
    Write-Host "8. List of Available Linux Distibutions                                  "    
    Write-Host "9. Aggresive Fix Windows Update                                          "
    Write-Host "=========================================================================" -ForegroundColor Cyan
    Write-Host "Q.  Return to Main Menu                                                  " -ForegroundColor Yellow
    Write-Host "=========================================================================" -ForegroundColor Cyan
} #Windows Update
function Show-SubMenu06 {
    Clear-Host
    Write-Host "========================== UI Tweaks - Sub Menu =========================" -ForegroundColor Black -BackgroundColor Yellow
    Write-Host " 1. Restore old Right-click Context menu in Windows 11                   "
    Write-Host " 2. Verbose Boot Enabled/Disabled                                        "
    Write-Host " 3. Disable the Weather/News icon in the Taskbar                         "
    Write-Host " 4. Start Menu on the left of the Taskbar                                "
    Write-Host " 5. Disable Network Throttling                                           "
    Write-Host " 6. Disable Search Box                                                   "
    Write-Host " 7. Open Explorer to This PC                                             " 
    Write-Host " 9. God Mode                                                             "    
    Write-Host "10. Performance Config                                                   "
    Write-Host "=========================================================================" -ForegroundColor Cyan
    Write-Host " Q. Return to Main Menu                                                  " -ForegroundColor Yellow
    Write-Host "=========================================================================" -ForegroundColor Cyan
} #UI Tweaks

# Check if admin rights are present. Returns $true/$false and does NOT
# navigate anywhere - callers decide what to do with the result.
function Test-IsAdmin {
    $identity  = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Custom exception type used to unwind out of a menu action when admin
# rights are required but missing, without recursively spawning new menus.
class AdminRequiredException : System.Exception {
    AdminRequiredException([string]$message) : base($message) {}
}

# Call this at the top of any action that needs admin rights. Throws if
# not elevated; the enclosing menu loop's try/catch will catch it, show
# the message, and simply redraw the current menu.
function Check-Admin {
    if (-not (Test-IsAdmin)) {
        Write-Host "This action requires Administrator rights. Please restart the menu as Administrator (RA)." -ForegroundColor Red
        Pause
        throw [AdminRequiredException]::new("Administrator rights required.")
    }
}

function Run-Admin {
    # Relaunch this script elevated. Note: PowerShell's -Verb RunAs does not
    # accept a -Credential argument passed through to the child process the
    # way the original code assumed, so we simply relaunch elevated and let
    # the UAC prompt handle credentials.
    try {
        Start-Process powershell -Verb RunAs -ArgumentList @(
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", "`"$PSCommandPath`""
        )
    }
    catch {
        Write-Host "Could not relaunch elevated: $($_.Exception.Message)" -ForegroundColor Red
        Pause
    }
}

# Process Menus
function Get-Menu {
    $loop = $true
    while ($loop) {
        $script:IsAdmin = Test-IsAdmin
        Show-MainMenu
        $selection = Read-Host "Enter your choice"

        try {
            switch ($selection.ToUpper()) {
                '1' { SystemHostname; Pause }
                '2' { SystemIPAddresses }
                '3' { RunningProcesses }
                '4' { EvntLog }
                '5' { Restart-Computer -Force }
                '6' { Stop-Computer -Force }
                '7' {
                    Write-Host "This will reboot the system and automatically load the BIOS"
                    Pause
                    shutdown /r /fw /t0
                }
                '8' { BIOS }
                '9' {
                    Write-Host ""
                    (Get-CimInstance -ClassName SoftwareLicensingService).SubscriptionEdition
                    $key = (Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey
                    Write-Host $key
                    cmd.exe /c "slmgr.vbs /dlv"
                    cmd.exe /c "slmgr.vbs /xpr"
                    Pause
                }
                '10' {
                    Check-Admin
                    $LicKey = (Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey
                    $key = Read-Host ("Enter Product Key (Default is {0})" -f $LicKey)
                    if ([string]::IsNullOrWhiteSpace($key)) { $key = $LicKey }
                    if (-not [string]::IsNullOrWhiteSpace($key)) {
                        cmd.exe /c "slmgr.vbs /ipk $key"
                        cmd.exe /c "slmgr.vbs /ato"
                        cmd.exe /c "slmgr.vbs /dli"
                    }
                    Pause
                }
                '11' { Get-SubMenu06 }
                '50' { cmd.exe /c "netplwiz" }
                'AJ' {
                    Check-Admin
                    cmd.exe /c "dsregcmd /status | more"
                    Pause
                }
                'AS' { Astronauts }
                'AT' { cmd.exe /c "%windir%\system32\control.exe /name Microsoft.AdministrativeTools" }
                'BA' {
                    Check-Admin
                    Add-BitLockerKeyProtector -MountPoint "C:" -TpmProtector
                    Pause
                }
                'BD' { BackupDrivers }
                'BL' {
                    Check-Admin
                    Get-BitLockerVolume
                    Pause
                }
                'GA' { AutoPilot }
                'EF' { EnableFinger }
                'H' {
                    Check-Admin
                    Invoke-Item "C:\windows\system32\drivers\etc\HOSTS"
                    Pause
                }
                'I'  { Intune-Enroll }
                'IA' {
                    powershell -ExecutionPolicy Bypass "\\ast-aws-fs00\Hardware$\get-assetinfo.ps1"
                    Pause
                }
                'IT' { ADTools }
                'LU' {
                    Get-LocalUser | Format-Table Name, Enabled, LastLogon
                    Write-Host "Local Groups..."
                    Get-LocalGroup | Format-Table Name
                    Pause
                }
                'DS' { sigverif }
                'MS' {
                    Write-Host "This will connect PowerShell to MS365/Azure and then exit this app"
                    Pause
                    Install-Module ExchangeOnlineManagement -Scope CurrentUser -Force
                    Install-Module Microsoft.Graph -Scope CurrentUser -Force
                    Install-Module MSOnline -Scope CurrentUser -Force
                    Connect-MgGraph -Scopes "User.Read.All", "Group.ReadWrite.All", "Device.Read.All", "DeviceManagementManagedDevices.PrivilegedOperations.All", "DeviceManagementManagedDevices.ReadWrite.All", "DeviceManagementApps.ReadWrite.All", "DeviceManagementConfiguration.ReadWrite.All"
                    Pause
                    $loop = $false
                    exit
                }
                'NS' { Get-SubMenu03 }
                'PM' { cmd /c "perfmon" }
                'RA' { Run-Admin }
                'RF' {
                    Write-Host "Ctrl + C to quit, you will need to restart MENU"
                    Pause
                    cmd /c "curl ascii.live/forrest"
                }
                'RM' { cmd /c "perfmon /rel" }
                'RP' {
                    Write-Host "Ctrl + C to quit, you will need to restart MENU"
                    Pause
                    cmd /c "curl ascii.live/parrot"
                }
                'RR' {
                    Write-Host "Ctrl + C to quit, you will need to restart MENU"
                    Pause
                    cmd /c "curl ascii.live/rick"
                }
                'S'  { Get-Service | Out-GridView }
                'SA' { cmd /c "sysdm.cpl" }
                'SC' { Get-SubMenu01 }
                'SD' { System }
                'SM' { Get-SubMenu04 }
                'SS' { WhyNot }
                'T'  { Get-TPM; Pause }
                'U'  { Uptime }
                'US' { ServicesDisabled }
                'V'  { SystemVersion }
                'VS' { Get-SubMenu02 }
                'W'  { SystemWeeFeeMac }
                'WU' { Get-SubMenu05 }
                'Q'  {
                    $loop = $false
                    Write-Host "Exiting script. Goodbye!" -ForegroundColor Yellow
                }
                Default {
                    Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                    Pause
                }
            }
        }
        catch [AdminRequiredException] {
            # Message already shown by Check-Admin - just redraw the menu.
        }
        catch {
            Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red -BackgroundColor White
            Pause
        }
    }
} # main menu, start from here

function Get-SubMenu01 {
    $loop = $true
    while ($loop) {
        Show-SubMenu01
        $selection = Read-Host "Enter your choice"
        try {
            switch ($selection.ToUpper()) {
                '1' { ClnTemp }
                '2' { WinUpdateReset }
                '3' { DiskClean }
                '4' {
                    Check-Admin
                    DISM /Online /Cleanup-Image /RestoreHealth
                    Pause
                }
                '5' {
                    Check-Admin
                    sfc /scannow
                    Pause
                }
                '6' { notepad C:\Windows\Logs\CBS\CBS.log }
                '7' { Invoke-SystemRepair }
                'Q' { $loop = $false }
                Default {
                    Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                    Pause
                }
            }
        }
        catch [AdminRequiredException] { }
        catch {
            Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red -BackgroundColor White
            Pause
        }
    }
} #System Clean Up

function Get-SubMenu02 {
    $loop = $true
    while ($loop) {
        Show-SubMenu02
        $selection = Read-Host "Enter your choice"
        try {
            switch ($selection.ToUpper()) {
                '1' { vssadmin list shadows; Pause }
                '2' { vssadmin delete shadows /for=c: /all /quiet; Pause }
                '3' { vssadmin delete shadows /for=c: /oldest /quiet; Pause }
                '4' { vssadmin list writers; Pause }
                '5' { vssadmin list providers; Pause }
                '6' {
                    Check-Admin
                    EnableVolShadow -DriveLetter "C:" -MaxSize "10GB"
                }
                '7' {
                    Write-Host "Creating shadow copy..." -ForegroundColor Red
                    (Get-WmiObject -List Win32_ShadowCopy).Create("C:\", "ClientAccessible")
                    Pause
                }
                'Q' { $loop = $false }
                Default {
                    Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                    Pause
                }
            }
        }
        catch [AdminRequiredException] { }
        catch {
            Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red -BackgroundColor White
            Pause
        }
    }
} #Volume Shadow

function Get-SubMenu03 {
    $loop = $true
    while ($loop) {
        Show-SubMenu03
        $selection = Read-Host "Enter your choice"
        try {
            switch ($selection.ToUpper()) {
                '1' { cmd.exe /c 'arp -a'; Pause }
                '2' { Get-NetTCPConnection | more; Pause }
                '3' { cmd.exe /c 'netstat -e'; Pause }
                '4' { Get-NetIPConfiguration; Pause }
                '5' { Get-NetAdapter; Pause }
                '6' {
                    $lookupHost = Read-Host "Enter host DNS Name or IP to test"
                    $remoteHost = Read-Host "Enter Remote Source address (optional)"
                    if (-not [string]::IsNullOrWhiteSpace($lookupHost)) {
                        if ([string]::IsNullOrWhiteSpace($remoteHost)) {
                            Test-Connection -ComputerName $lookupHost
                        }
                        else {
                            Test-Connection -ComputerName $lookupHost -Source $remoteHost
                        }
                        Pause
                    }
                }
                '7' { TestNetwork }
                '8' {
                    $lookupHost = Read-Host "Enter host to lookup"
                    if (-not [string]::IsNullOrWhiteSpace($lookupHost)) {
                        Resolve-DnsName -Name $lookupHost -Type All
                        Pause
                    }
                }
                '9'  { Get-DnsClientCache | Format-Table Data, Entry, Name, TTL | more; Pause }
                '10' { Clear-DnsClientCache }
                '11' { Get-DnsClientServerAddress | Format-Table InterfaceAlias, InterfaceIndex, AddressFamily, ServerAddresses; Pause }
                '12' { DefaultGW }
                '13' { SystemHostname; SystemIPAddresses }
                '14' { Check-Admin; Invoke-NTP ; pause}
                'Q'  { $loop = $false }
                Default {
                    Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                    Pause
                }
            }
        }
        catch [AdminRequiredException] { }
        catch {
            Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red -BackgroundColor White
            Pause
        }
    }
} #Network Tools

function Get-SubMenu04 {
    $loop = $true
    while ($loop) {
        Show-SubMenu04
        $selection = Read-Host "Enter your choice"
        try {
            switch ($selection.ToUpper()) {
                '1' { Get-Service | Format-Table; Pause }
                '2' { ServiceState }
                '5' { ServiceDelete }
                'Q' { $loop = $false }
                Default {
                    Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                    Pause
                }
            }
        }
        catch [AdminRequiredException] { }
        catch {
            Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red -BackgroundColor White
            Pause
        }
    }
} #Services

function Get-SubMenu05 {
    $loop = $true
    while ($loop) {
        Show-SubMenu05
        $selection = Read-Host "Enter your choice"
        try {
            switch ($selection.ToUpper()) {
                '1' {
                    Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe
                    winget upgrade --all
                    Pause
                }
                '2' {
                    WinUpdate
                    Restart-Computer -Force
                    Write-Host "Reboot initiated..."
                    exit
                }
                '3' { WinUpdateSelect }
                '4' { WinUpdate }
                '5' { Check-Admin
                        do {
                            $inputValue = Read-Host "Quick or Aggressive [Q,A]"
                            $valid = $inputValue -match '^[QAqa]$'
                            if (-not $valid) { Write-Host "Invalid, try again." }
                        } until ($valid)

                        if ($inputValue.ToUpper()='Q'){
                            Write-Host "Stopping Services..."
                            net stop wuauserv
                            net stop "Smartlocker Filter Driver"
                            net stop "Application Identity"
                            net stop cryptSvc
                            net stop bits
                            net stop msiserver
                            Write-Host "Deleting Files..."
                            Remove-Item C:\Windows\SoftwareDistribution\* -Recurse -Force -ErrorAction SilentlyContinue
                            Remove-Item C:\Windows\System32\catroot2\* -Recurse -Force -ErrorAction SilentlyContinue
                            Write-Host "Registering DLLs..."
                            regsvr32 /s wuapi.dll
                            regsvr32 /s wuaueng.dll
                            regsvr32 /s wups.dll
                            regsvr32 /s wups2.dll
                            regsvr32 /s wuwebv.dll
                            regsvr32 /s wucltux.dll
                            Write-Host "Restarting Services..."
                            net start msiserver
                            net start bits
                            net start "Application Identity"
                            net start "Smartlocker Filter Driver"
                            net start cryptSvc
                            net start wuauserv
                        } else {                        
                            Invoke-WinUpdatesdefault                        
                        }
                        Pause
                    }
                '6' { write-host "This may take awhile to install..." -ForegroundColor Cyan -BackgroundColor Yellow
                      wsl --install 
                      wsl --list --verbose  
                      pause
                    }
                '7' { write-host "This may take awhile to install..." -ForegroundColor Cyan -BackgroundColor Yellow
                      wsl.exe --install -d kali-linux
                      wsl --list --verbose  
                      pause
                    }
                '8' { wsl.exe --list --online 
                      pause
                    }
                '9' { Check-Admin; Invoke-FixWinUpdate }
                'Q' { $loop = $false }
                Default {
                    Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                    Pause
                }
            }
        }
        catch [AdminRequiredException] { }
        catch {
            Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red -BackgroundColor White
            Pause
        }
    }
} #Windows Update

function Get-SubMenu06 {
    $loop = $true
    while ($loop) {
        Show-SubMenu06
        $selection = Read-Host "Enter your choice"
        try {
            switch ($selection.ToUpper()) {
                '1' {
                        New-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Force | Out-Null
                        Set-Item -Path "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" -Value ""
                        write-host "Restart Explore or reboot to take effect"                    
                        pause
                        write-host "Trying to restart Windows Explorer..."
                        Stop-Process -Name explorer -Force
                        Start-Sleep -Seconds 5
                        if (-not (Get-Process -Name explorer -ErrorAction SilentlyContinue)) {
                            Start-Process explorer
                        } # restart Explore Task
                    }
                '2' { Check-Admin
                      do{
                        $verbose = Read-Host "Enter 1 to enable, 0 to disable"
                        $valid = $verbose -match '^[01]$'
                        if (-not $valid) { Write-Host "Invalid, try again." }
                      } until ($valid)
                      Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "VerboseStatus" $verbose                     
                      pause
                    }
                '3' { Check-Admin                      
                      Set-Reg "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" "EnableFeeds" 0
                      pause 
                    }
                '4' { Check-Admin
                      Set-Reg "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarAl" 0
                      pause 
                    }
                '5' { Check-Admin
                      Set-Reg "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" "NetworkThrottlingIndex" "0xFFFFFFFF" 
                      pause 
                    }
                '6' { Check-Admin
                      Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1 
                      pause
                    }  # No Bing results in Start search 
                '7' { Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' 'LaunchTo' 1 
                      pause
                    }  # Open Explorer to "This PC"
                '9' { explorer "shell:::{ED7BA470-8E54-465E-825C-99712043E01C}" }    
                '10'{ Invoke-Performance
                      pause  
                    }                
                
                'Q' { $loop = $false }
                Default {
                    Write-Host "Invalid selection. Please try again." -ForegroundColor Red
                    Pause
                }
            }
        }
        catch [AdminRequiredException] { }
        catch {
            Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red -BackgroundColor White
            Pause
        }
    }
} #UI Tweaks

# Define Menu items
function ADTools {
    Write-Host "Checking if Tools already installed"
    Get-WindowsCapability -Name RSAT:ActiveDirectory* -Online
    Write-Host "INSTALLING WILL TAKE A VERY LLLLOOONNNGGGG TIME, so only start when computer will be running for a bit."
    Pause
    Add-WindowsCapability -Online -Name "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
    Import-Module ActiveDirectory -ErrorAction SilentlyContinue
    Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
    Add-WindowsCapability -Name Rsat.DHCP.Tools~~~~0.0.1.0 -Online
    Add-WindowsCapability -Name Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0 -Online
    Add-WindowsCapability -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0 -Online
    Get-ADDomain
    Pause
}

function AutoPilot {
    Check-Admin
    $folderPath = "C:\Temp"
    if (Test-Path -Path $folderPath) {
        Write-Host "The folder '$folderPath' exists."
    }
    else {
        Write-Host "The folder '$folderPath' does not exist. Creating it..."
        New-Item -Path $folderPath -ItemType Directory | Out-Null
    }
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Install-Script -Name Get-WindowsAutoPilotInfo -Force -Scope CurrentUser -ErrorAction SilentlyContinue
    Get-WindowsAutoPilotInfo -OutputFile "$folderPath\AutopilotDevices.csv"
    Write-Host "File $folderPath\AutopilotDevices.csv created..."
    Pause
}

function Astronauts {
    Write-Host "Processing, counting people 1,2,3..."
    try {
        $uri = "http://api.open-notify.org/astros.json"
        $response = Invoke-RestMethod -Uri $uri -Method Get
        Write-Host "Message: $($response.message)"
        Write-Host "Number of people in space: $($response.number) (According to NASA anyways)"
    }
    catch {
        Write-Host "Could not reach the astronauts API: $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause
}

function BackupDrivers {
    $path = "C:\Temp\Drivers"
    if (-not (Test-Path -Path $path -PathType Container)) {
        New-Item -Path $path -ItemType Directory | Out-Null
    }
    $pnpPath = "$path\pnp"
    if (-not (Test-Path -Path $pnpPath -PathType Container)) {
        New-Item -Path $pnpPath -ItemType Directory | Out-Null
    }
    pnputil /export-driver * "$pnpPath"
    Write-Host "Files Located in: $pnpPath"
    Pause
}

function BIOS {
    Get-CimInstance -ClassName Win32_BIOS
    Pause
}

function ClnTemp {
    Check-Admin
    $tempPaths = @(
        "$env:TEMP",
        "$env:TMP",
        "C:\Windows\Temp",
        "C:\Temp",
        "C:\Users\*\AppData\Local\Temp\"
    )

    $logFile = "temp_cleanup_log.txt"
    "Temp Cleanup Log - $(Get-Date)" | Out-File -FilePath $logFile -Encoding UTF8

    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            Write-Host "Cleaning: $path" -ForegroundColor Cyan
            try {
                Get-ChildItem -Path $path -File -Recurse -Force -ErrorAction SilentlyContinue |
                    ForEach-Object {
                        try { Remove-Item $_.FullName -Force -ErrorAction Stop }
                        catch { }
                    }

                Get-ChildItem -Path $path -Directory -Recurse -Force -ErrorAction SilentlyContinue |
                    Sort-Object FullName -Descending |
                    ForEach-Object {
                        try { Remove-Item $_.FullName -Force -Recurse -ErrorAction Stop }
                        catch { }
                    }
            }
            catch {
                Write-Warning "Error cleaning $path"
            }
        }
        else {
            Write-Host "Path not found: $path" -ForegroundColor Yellow
        }
    }

    Write-Host "Cleanup complete. Log saved to: $logFile" -ForegroundColor Green
    Pause
}

function DiskClean {
    Check-Admin
    cleanmgr /sagerun:1
    Write-Host "Check App Popup for completion!" -ForegroundColor Green
    Pause
}

function DefaultGW {
    try {
        $defaultRoute = Get-NetRoute -DestinationPrefix "0.0.0.0/0" -ErrorAction Stop |
            Sort-Object RouteMetric |
            Select-Object -First 1

        if (-not $defaultRoute) {
            throw "Default route not found."
        }

        Write-Host "Default Route Found:"
        Write-Host " Gateway:        $($defaultRoute.NextHop)"
        Write-Host " Interface:      $($defaultRoute.InterfaceAlias)"
        Write-Host " Route Metric:   $($defaultRoute.RouteMetric)"
    }
    catch {
        Write-Host "Error retrieving default route: $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause
}

function EnableFinger {
    Check-Admin
    Write-Host "Adding Registry..."
    $path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\Credential Providers\{BEC09223-B018-416D-A0AC-523971B639F5}\"
    New-ItemProperty -LiteralPath $path -Name "(default)" -Value "WinBio Credential Provider" -PropertyType String -Force -ErrorAction SilentlyContinue | Out-Null
    New-ItemProperty -LiteralPath $path -Name 'Disabled' -Value "-" -PropertyType String -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Registry settings added!"
    Pause
}

function EnableVolShadow {
    param (
        [Parameter(Mandatory = $true)]
        [ValidatePattern("^[A-Z]:$")]
        [string]$DriveLetter,

        [Parameter(Mandatory = $true)]
        [ValidatePattern("^\d+(KB|MB|GB|TB)$|^UNBOUNDED$")]
        [string]$MaxSize
    )

    try {
        if (-not (Test-IsAdmin)) {
            throw "This action must be run as Administrator."
        }

        Write-Host "Enabling Volume Shadow Copy on $DriveLetter with max size $MaxSize..." -ForegroundColor Cyan
        cmd.exe /c "vssadmin add shadowstorage /for=$DriveLetter /on=$DriveLetter /maxsize=$MaxSize"

        Write-Host "Creating initial shadow copy..." -ForegroundColor Cyan
        (Get-WmiObject -List Win32_ShadowCopy).Create("$DriveLetter\", "ClientAccessible")

        Write-Host "Volume Shadow Copy enabled successfully on $DriveLetter." -ForegroundColor Green
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }
    Pause
}

function EvntLog {
    Clear-Host
    Write-Host "APPLICATION LOGS" -ForegroundColor Green
    Get-WinEvent -LogName Application -MaxEvents 10 -FilterXPath "*[System[(Level=2)]]" -ErrorAction SilentlyContinue
    Pause
    Clear-Host
    Write-Host "SYSTEM LOGS" -ForegroundColor Green
    Get-WinEvent -LogName System -MaxEvents 10 -FilterXPath "*[System[(Level=2)]]" -ErrorAction SilentlyContinue
    Pause
    Clear-Host
    Write-Host "SECURITY LOGS" -ForegroundColor Green
    Get-WinEvent -LogName Security -MaxEvents 10 -FilterXPath "*[System[(Level=2)]]" -ErrorAction SilentlyContinue
    Pause
}

function Get-EditionIdFromName {
    param([string]$EditionName)

    $normalizedName = ($EditionName -replace '^Windows\s+11\s+', '').Trim()
    switch -Regex ($normalizedName) {
        '^Home Single Language$'      { return 'CoreSingleLanguage' }
        '^Home N$'                    { return 'CoreN' }
        '^Home$'                      { return 'Core' }
        '^Pro for Workstations N$'    { return 'ProfessionalWorkstationN' }
        '^Pro for Workstations$'      { return 'ProfessionalWorkstation' }
        '^Pro Education N$'           { return 'ProfessionalEducationN' }
        '^Pro Education$'             { return 'ProfessionalEducation' }
        '^Pro N$'                     { return 'ProfessionalN' }
        '^Pro$'                       { return 'Professional' }
        '^Education N$'               { return 'EducationN' }
        '^Education$'                 { return 'Education' }
        '^Enterprise LTSC N$'         { return 'EnterpriseSN' }
        '^Enterprise LTSC$'           { return 'EnterpriseS' }
        '^Enterprise N$'              { return 'EnterpriseN' }
        '^Enterprise$'                { return 'Enterprise' }
        default                       { return '' }
    }
}

function Intune-Enroll {
    Check-Admin
    $tenantPath = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\"

    if (-not (Test-Path $tenantPath)) {
        Write-Host "No tenant info registry key found - this device may not be Azure AD joined yet."
        Write-Host "Please Azure AD join the device first (see 'AJ' on the main menu), then retry."
        Pause
        return
    }

    $tenantSubKey = Get-ChildItem -Path $tenantPath -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $tenantSubKey) {
        Write-Host "Tenant ID subkey not found under $tenantPath" -ForegroundColor Red
        Pause
        return
    }

    $path = $tenantSubKey.PSPath
    Write-Host "Found tenant key: $($tenantSubKey.PSChildName)"

    try {
        Get-ItemProperty -Path $path -Name MdmEnrollmentUrl -ErrorAction Stop | Out-Null
        Write-Host "MDM enrollment registry keys already present."
    }
    catch {
        Write-Host "MDM Enrollment registry keys not found. Registering now..."
        New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' -PropertyType String -Force -ErrorAction SilentlyContinue | Out-Null
        New-ItemProperty -LiteralPath $path -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String -Force -ErrorAction SilentlyContinue | Out-Null
        New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType String -Force -ErrorAction SilentlyContinue | Out-Null
    }

    try {
        & "$env:WINDIR\system32\deviceenroller.exe" /c /AutoEnrollMDM
        Write-Host "Device is performing the MDM enrollment!" -ForegroundColor Green
    }
    catch {
        Write-Host "Something went wrong running deviceenroller.exe: $($_.Exception.Message)" -ForegroundColor Red
    }

    Pause
}

function Invoke-NTP {
    <#
    Configures Windows to use pool.ntp.org for NTP synchronization

    Replaces the default Windows NTP server (time.windows.com) with
    pool.ntp.org for improved time synchronization accuracy and reliability.
    #>

    Start-Service w32time
    w32tm /config /update /manualpeerlist:"pool.ntp.org,0x8" /syncfromflags:MANUAL

    Restart-Service w32time
    w32tm /resync

    Write-Host "================================="
    Write-Host "-- NTP Configuration Complete ---"
    Write-Host "================================="
    Write-Host " NTP Set to pool.ntp.org"
    Write-Host "================================="
}

function Invoke-FixWinUpdate {

    <#

    .SYNOPSIS
        Performs various tasks in an attempt to repair Windows Update

    .DESCRIPTION
        1. (Aggressive Only) Scans the system for corruption using the Invoke-WPFSystemRepair function
        2. Stops Windows Update Services
        3. Remove the QMGR Data file, which stores BITS jobs
        4. (Aggressive Only) Renames the DataStore and CatRoot2 folders
            DataStore - Contains the Windows Update History and Log Files
            CatRoot2 - Contains the Signatures for Windows Update Packages
        5. Renames the Windows Update Download Folder
        6. Deletes the Windows Update Log
        7. (Aggressive Only) Resets the Security Descriptors on the Windows Update Services
        8. Reregisters the BITS and Windows Update DLLs
        9. Removes the WSUS client settings
        10. Resets WinSock
        11. Gets and deletes all BITS jobs
        12. Sets the startup type of the Windows Update Services then starts them
        13. Forces Windows Update to check for updates

    .PARAMETER Aggressive
        If specified, the script will take additional steps to repair Windows Update that are more dangerous, take a significant amount of time, or are generally unnecessary

    #>

    param($Aggressive = $false)

    Write-Progress -Id 0 -Activity "Repairing Windows Update" -PercentComplete 0    
    Write-Host "Starting Windows Update Repair..."
    # Wait for the first progress bar to show, otherwise the second one won't show
    Start-Sleep -Milliseconds 200

    if ($Aggressive) {
        Invoke-SystemRepair
    }


    Write-Progress -Id 0 -Activity "Repairing Windows Update" -Status "Stopping Windows Update Services..." -PercentComplete 10
    # Stop the Windows Update Services
    Write-Progress -Id 2 -ParentId 0 -Activity "Stopping Services" -Status "Stopping BITS..." -PercentComplete 0
    Stop-Service -Name BITS -Force
    Write-Progress -Id 2 -ParentId 0 -Activity "Stopping Services" -Status "Stopping wuauserv..." -PercentComplete 20
    Stop-Service -Name wuauserv -Force
    Write-Progress -Id 2 -ParentId 0 -Activity "Stopping Services" -Status "Stopping appidsvc..." -PercentComplete 40
    Stop-Service -Name appidsvc -Force
    Write-Progress -Id 2 -ParentId 0 -Activity "Stopping Services" -Status "Stopping cryptsvc..." -PercentComplete 60
    Stop-Service -Name cryptsvc -Force
    Write-Progress -Id 2 -ParentId 0 -Activity "Stopping Services" -Status "Completed" -PercentComplete 100


    # Remove the QMGR Data file
    Write-Progress -Id 0 -Activity "Repairing Windows Update" -Status "Renaming/Removing Files..." -PercentComplete 20
    Write-Progress -Id 3 -ParentId 0 -Activity "Renaming/Removing Files" -Status "Removing QMGR Data files..." -PercentComplete 0
    Remove-Item "$env:allusersprofile\Application Data\Microsoft\Network\Downloader\qmgr*.dat" -ErrorAction SilentlyContinue


    if ($Aggressive) {
        # Rename the Windows Update Log and Signature Folders
        Write-Progress -Id 3 -ParentId 0 -Activity "Renaming/Removing Files" -Status "Renaming the Windows Update Log, Download, and Signature Folder..." -PercentComplete 20
        Rename-Item $env:systemroot\SoftwareDistribution\DataStore DataStore.bak -ErrorAction SilentlyContinue
        Rename-Item $env:systemroot\System32\Catroot2 catroot2.bak -ErrorAction SilentlyContinue
    }

    # Rename the Windows Update Download Folder
    Write-Progress -Id 3 -ParentId 0 -Activity "Renaming/Removing Files" -Status "Renaming the Windows Update Download Folder..." -PercentComplete 20
    Rename-Item $env:systemroot\SoftwareDistribution\Download Download.bak -ErrorAction SilentlyContinue

    # Delete the legacy Windows Update Log
    Write-Progress -Id 3 -ParentId 0 -Activity "Renaming/Removing Files" -Status "Removing the old Windows Update log..." -PercentComplete 80
    Remove-Item $env:systemroot\WindowsUpdate.log -ErrorAction SilentlyContinue
    Write-Progress -Id 3 -ParentId 0 -Activity "Renaming/Removing Files" -Status "Completed" -PercentComplete 100


    if ($Aggressive) {
        # Reset the Security Descriptors on the Windows Update Services
        Write-Progress -Id 0 -Activity "Repairing Windows Update" -Status "Resetting the WU Service Security Descriptors..." -PercentComplete 25
        Write-Progress -Id 4 -ParentId 0 -Activity "Resetting the WU Service Security Descriptors" -Status "Resetting the BITS Security Descriptor..." -PercentComplete 0
        Start-Process -NoNewWindow -FilePath "sc.exe" -ArgumentList "sdset", "bits", "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" -Wait
        Write-Progress -Id 4 -ParentId 0 -Activity "Resetting the WU Service Security Descriptors" -Status "Resetting the wuauserv Security Descriptor..." -PercentComplete 50
        Start-Process -NoNewWindow -FilePath "sc.exe" -ArgumentList "sdset", "wuauserv", "D:(A;;CCLCSWRPWPDTLOCRRC;;;SY)(A;;CCDCLCSWRPWPDTLOCRSDRCWDWO;;;BA)(A;;CCLCSWLOCRRC;;;AU)(A;;CCLCSWRPWPDTLOCRRC;;;PU)" -Wait
        Write-Progress -Id 4 -ParentId 0 -Activity "Resetting the WU Service Security Descriptors" -Status "Completed" -PercentComplete 100
    }


    # Reregister the BITS and Windows Update DLLs
    Write-Progress -Id 0 -Activity "Repairing Windows Update" -Status "Reregistering DLLs..." -PercentComplete 40
    $oldLocation = Get-Location
    Set-Location $env:systemroot\system32
    $i = 0
    $DLLs = @(
        "atl.dll", "urlmon.dll", "mshtml.dll", "shdocvw.dll", "browseui.dll",
        "jscript.dll", "vbscript.dll", "scrrun.dll", "msxml.dll", "msxml3.dll",
        "msxml6.dll", "actxprxy.dll", "softpub.dll", "wintrust.dll", "dssenh.dll",
        "rsaenh.dll", "gpkcsp.dll", "sccbase.dll", "slbcsp.dll", "cryptdlg.dll",
        "oleaut32.dll", "ole32.dll", "shell32.dll", "initpki.dll", "wuapi.dll",
        "wuaueng.dll", "wuaueng1.dll", "wucltui.dll", "wups.dll", "wups2.dll",
        "wuweb.dll", "qmgr.dll", "qmgrprxy.dll", "wucltux.dll", "muweb.dll", "wuwebv.dll"
    )
    foreach ($dll in $DLLs) {
        Write-Progress -Id 5 -ParentId 0 -Activity "Reregistering DLLs" -Status "Registering $dll..." -PercentComplete ($i / $DLLs.Count * 100)
        $i++
        Start-Process -NoNewWindow -FilePath "regsvr32.exe" -ArgumentList "/s", $dll
    }
    Set-Location $oldLocation
    Write-Progress -Id 5 -ParentId 0 -Activity "Reregistering DLLs" -Status "Completed" -PercentComplete 100


    # Remove the WSUS client settings
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate") {
        Write-Progress -Id 0 -Activity "Repairing Windows Update" -Status "Removing WSUS client settings..." -PercentComplete 60
        Write-Progress -Id 6 -ParentId 0 -Activity "Removing WSUS client settings" -PercentComplete 0
        Start-Process -NoNewWindow -FilePath "REG" -ArgumentList "DELETE", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate", "/v", "AccountDomainSid", "/f" -RedirectStandardError "NUL"
        Start-Process -NoNewWindow -FilePath "REG" -ArgumentList "DELETE", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate", "/v", "PingID", "/f" -RedirectStandardError "NUL"
        Start-Process -NoNewWindow -FilePath "REG" -ArgumentList "DELETE", "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate", "/v", "SusClientId", "/f" -RedirectStandardError "NUL"
        Write-Progress -Id 6 -ParentId 0 -Activity "Removing WSUS client settings" -Status "Completed" -PercentComplete 100
    }

    # Remove Group Policy Windows Update settings
    Write-Progress -Id 0 -Activity "Repairing Windows Update" -Status "Removing Group Policy Windows Update settings..." -PercentComplete 60
    Write-Progress -Id 7 -ParentId 0 -Activity "Removing Group Policy Windows Update settings" -PercentComplete 0
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
    Write-Host "Defaulting driver offering through Windows Update..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontSearchWindowsUpdate" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DriverUpdateWizardWuSearchEnabled" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
    Write-Host "Defaulting Windows Update automatic restart..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -ErrorAction SilentlyContinue
    Write-Host "Clearing ANY Windows Update Policy settings..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "BranchReadinessLevel" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferFeatureUpdatesPeriodInDays" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferQualityUpdatesPeriodInDays" -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Microsoft\WindowsSelfHost" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\Software\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\Microsoft\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\Microsoft\WindowsSelfHost" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\WOW6432Node\Microsoft\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Process -NoNewWindow -FilePath "secedit" -ArgumentList "/configure", "/cfg", "$env:windir\inf\defltbase.inf", "/db", "defltbase.sdb", "/verbose" -Wait
    Start-Process -NoNewWindow -FilePath "cmd.exe" -ArgumentList "/c RD /S /Q $env:WinDir\System32\GroupPolicyUsers" -Wait
    Start-Process -NoNewWindow -FilePath "cmd.exe" -ArgumentList "/c RD /S /Q $env:WinDir\System32\GroupPolicy" -Wait
    Start-Process -NoNewWindow -FilePath "gpupdate" -ArgumentList "/force" -Wait
    Write-Progress -Id 7 -ParentId 0 -Activity "Removing Group Policy Windows Update settings" -Status "Completed" -PercentComplete 100


    # Reset WinSock
    Write-Progress -Id 0 -Activity "Repairing Windows Update" -Status "Resetting WinSock..." -PercentComplete 65
    Write-Progress -Id 7 -ParentId 0 -Activity "Resetting WinSock" -Status "Resetting WinSock..." -PercentComplete 0
    Start-Process -NoNewWindow -FilePath "netsh" -ArgumentList "winsock", "reset"
    Start-Process -NoNewWindow -FilePath "netsh" -ArgumentList "winhttp", "reset", "proxy"
    Start-Process -NoNewWindow -FilePath "netsh" -ArgumentList "int", "ip", "reset"
    Write-Progress -Id 7 -ParentId 0 -Activity "Resetting WinSock" -Status "Completed" -PercentComplete 100


    # Get and delete all BITS jobs
    Write-Progress -Id 0 -Activity "Repairing Windows Update" -Status "Deleting BITS jobs..." -PercentComplete 75
    Write-Progress -Id 8 -ParentId 0 -Activity "Deleting BITS jobs" -Status "Deleting BITS jobs..." -PercentComplete 0
    Get-BitsTransfer | Remove-BitsTransfer
    Write-Progress -Id 8 -ParentId 0 -Activity "Deleting BITS jobs" -Status "Completed" -PercentComplete 100


    # Change the startup type of the Windows Update Services and start them
    Write-Progress -Id 0 -Activity "Repairing Windows Update" -Status "Starting Windows Update Services..." -PercentComplete 90
    Write-Progress -Id 9 -ParentId 0 -Activity "Starting Windows Update Services" -Status "Starting BITS..." -PercentComplete 0
    Get-Service BITS | Set-Service -StartupType Manual -PassThru | Start-Service
    Write-Progress -Id 9 -ParentId 0 -Activity "Starting Windows Update Services" -Status "Starting wuauserv..." -PercentComplete 25
    Get-Service wuauserv | Set-Service -StartupType Manual -PassThru | Start-Service
    Write-Progress -Id 9 -ParentId 0 -Activity "Starting Windows Update Services" -Status "Starting AppIDSvc..." -PercentComplete 50
    # The AppIDSvc service is protected, so the startup type has to be changed in the registry
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\AppIDSvc" -Name "Start" -Value "3" # Manual
    Start-Service AppIDSvc
    Write-Progress -Id 9 -ParentId 0 -Activity "Starting Windows Update Services" -Status "Starting CryptSvc..." -PercentComplete 75
    Get-Service CryptSvc | Set-Service -StartupType Manual -PassThru | Start-Service
    Write-Progress -Id 9 -ParentId 0 -Activity "Starting Windows Update Services" -Status "Completed" -PercentComplete 100


    # Force Windows Update to check for updates
    Write-Progress -Id 0 -Activity "Repairing Windows Update" -Status "Forcing discovery..." -PercentComplete 95
    Write-Progress -Id 10 -ParentId 0 -Activity "Forcing discovery" -Status "Forcing discovery..." -PercentComplete 0
    try {
        (New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
    } catch {        
        Write-Warning "Failed to create Windows Update COM object: $_"
    }
    Start-Process -NoNewWindow -FilePath "wuauclt" -ArgumentList "/resetauthorization", "/detectnow"
    Write-Progress -Id 10 -ParentId 0 -Activity "Forcing discovery" -Status "Completed" -PercentComplete 100
    Write-Progress -Id 0 -Activity "Repairing Windows Update" -Status "Completed" -PercentComplete 100

    
    $ButtonType = [System.Windows.MessageBoxButton]::OK
    $MessageboxTitle = "Reset Windows Update "
    $Messageboxbody = ("Stock settings loaded.`n Please reboot your computer")
    $MessageIcon = [System.Windows.MessageBoxImage]::Information

    [System.Windows.MessageBox]::Show($Messageboxbody, $MessageboxTitle, $ButtonType, $MessageIcon)
    Write-Host "==============================================="
    Write-Host "-- Reset All Windows Update Settings to Stock -"
    Write-Host "==============================================="

    # Remove the progress bars
    Write-Progress -Id 0 -Activity "Repairing Windows Update" -Completed
    Write-Progress -Id 1 -Activity "Scanning for corruption" -Completed
    Write-Progress -Id 2 -Activity "Stopping Services" -Completed
    Write-Progress -Id 3 -Activity "Renaming/Removing Files" -Completed
    Write-Progress -Id 4 -Activity "Resetting the WU Service Security Descriptors" -Completed
    Write-Progress -Id 5 -Activity "Reregistering DLLs" -Completed
    Write-Progress -Id 6 -Activity "Removing Group Policy Windows Update settings" -Completed
    Write-Progress -Id 7 -Activity "Resetting WinSock" -Completed
    Write-Progress -Id 8 -Activity "Deleting BITS jobs" -Completed
    Write-Progress -Id 9 -Activity "Starting Windows Update Services" -Completed
    Write-Progress -Id 10 -Activity "Forcing discovery" -Completed
}

function Invoke-WinUpdatesdefault {
    <#

    .SYNOPSIS
        Resets Windows Update settings to default

    #>
    Write-WinUtilLog -Component "Updates" -Message "Resetting Windows Update settings to default."

    Write-Host "Removing Windows Update settings managed by WinUtil..." -ForegroundColor Green
    Write-WinUtilLog -Component "Updates" -Message "Removing Windows Update registry values managed by WinUtil."

    $registryValues = @(
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
            Names = @("NoAutoUpdate", "AUOptions", "NoAutoRebootWithLoggedOnUsers", "AUPowerManagement")
        },
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
            Names = @("ExcludeWUDriversInQualityUpdate", "DeferFeatureUpdates", "DeferFeatureUpdatesPeriodInDays", "DeferQualityUpdates", "DeferQualityUpdatesPeriodInDays")
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings"
            Names = @("BranchReadinessLevel", "DeferFeatureUpdatesPeriodInDays", "DeferQualityUpdatesPeriodInDays")
        },
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata"
            Names = @("PreventDeviceMetadataFromNetwork")
        },
        @{
            Path = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching"
            Names = @("DontPromptForWindowsUpdate", "DontSearchWindowsUpdate", "DriverUpdateWizardWuSearchEnabled")
        },
        @{
            Path = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config"
            Names = @("DODownloadMode")
        }
    )

    foreach ($registryEntry in $registryValues) {
        foreach ($valueName in $registryEntry.Names) {
            Remove-ItemProperty -Path $registryEntry.Path -Name $valueName -ErrorAction SilentlyContinue
        }
    }

    $explorerPolicyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer"
    $settingsPageVisibility = (Get-ItemProperty -Path $explorerPolicyPath -Name "SettingsPageVisibility" -ErrorAction SilentlyContinue).SettingsPageVisibility
    if ($settingsPageVisibility -eq "hide:windowsupdate") {
        Write-Host "Removing WinUtil's legacy Windows Update page restriction..."
        Write-WinUtilLog -Component "Updates" -Message "Removing the legacy Windows Update settings page restriction."
        Remove-ItemProperty -Path $explorerPolicyPath -Name "SettingsPageVisibility" -ErrorAction SilentlyContinue
    }

    Write-Host "Reenabling Windows Update Services..." -ForegroundColor Green
    Write-WinUtilLog -Component "Updates" -Message "Restoring Windows Update service startup types."

    Write-Host "Restored BITS to Manual."
    Write-WinUtilLog -Component "Updates" -Message "Restoring BITS service to Manual."
    Set-Service -Name BITS -StartupType Manual

    Write-Host "Restored wuauserv to Manual."
    Write-WinUtilLog -Component "Updates" -Message "Restoring wuauserv service to Manual."
    Set-Service -Name wuauserv -StartupType Manual

    Write-Host "Restored UsoSvc to Automatic."
    Write-WinUtilLog -Component "Updates" -Message "Starting UsoSvc service and restoring startup type to Automatic."
    Set-Service -Name UsoSvc -StartupType Automatic
    Start-Service -Name UsoSvc

    Write-Host "Enabling update related scheduled tasks..." -ForegroundColor Green
    Write-WinUtilLog -Component "Updates" -Message "Enabling update related scheduled tasks."

    $Tasks =
        '\Microsoft\Windows\InstallService\*',
        '\Microsoft\Windows\UpdateOrchestrator\*',
        '\Microsoft\Windows\UpdateAssistant\*',
        '\Microsoft\Windows\WaaSMedic\*',
        '\Microsoft\Windows\WindowsUpdate\*',
        '\Microsoft\WindowsUpdate\*'

    foreach ($Task in $Tasks) {
        Get-ScheduledTask -TaskPath $Task -ErrorAction SilentlyContinue | Enable-ScheduledTask -ErrorAction SilentlyContinue
    }

    Write-Host "===================================================" -ForegroundColor Green
    Write-Host "---  Windows Update Settings Reset to Default   ---" -ForegroundColor Green
    Write-Host "===================================================" -ForegroundColor Green

    Write-Host "Note: You must restart your system in order for all changes to take effect." -ForegroundColor Yellow
    Write-WinUtilLog -Component "Updates" -Message "Windows Update default workflow completed. Restart required."
}

function Invoke-Performance ([switch]$Enable) {
    if ($Enable) {
        powercfg /setactive (powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Select-String -Pattern '[A-Fa-f0-9-]{36}').Matches.Value
        Write-Host("Ultimate Power Plan plan installed and activated.")
    } else {
        powercfg /restoredefaultschemes
        Write-Host("Power Plan was reset to defaults.")
    }
}

function Invoke-SystemRepair {
    <#
    .SYNOPSIS
        Checks for system corruption using SFC, and DISM
        Checks for disk failure using Chkdsk

    .DESCRIPTION
        1. Chkdsk - Checks for disk errors, which can cause system file corruption and notifies of early disk failure
        2. SFC - scans protected system files for corruption and fixes them
        3. DISM - Repair a corrupted Windows operating system image
    #>

    Start-Process cmd.exe -ArgumentList "/c chkdsk /scan /perf" -NoNewWindow -Wait
    Start-Process cmd.exe -ArgumentList "/c sfc /scannow" -NoNewWindow -Wait
    Start-Process cmd.exe -ArgumentList "/c dism /online /cleanup-image /restorehealth" -NoNewWindow -Wait

    Write-Host "==> Finished System Repair"    
}

function RunningProcesses {
    Write-Host "Running Processes:" -ForegroundColor Green
    Get-Process | Select-Object ProcessName, Id, CPU, WorkingSet | Sort-Object ProcessName | Format-Table -AutoSize | more
    Pause
}

function ServiceDelete {
    Check-Admin
    $SrvcName = Read-Host "Enter service name to delete"
    if ([string]::IsNullOrWhiteSpace($SrvcName)) { return }

    if (-not (Get-Service -Name $SrvcName -ErrorAction SilentlyContinue)) {
        Write-Host "Invalid service name: '$SrvcName' was not found." -ForegroundColor Red
        Pause
        return
    }

    Write-Host " THIS WILL DELETE THE WINDOWS SERVICE $SrvcName " -ForegroundColor Yellow -BackgroundColor Red
    Write-Host " ONCE EXECUTED, IT CANNOT BE UNDONE " -ForegroundColor Yellow -BackgroundColor Red
    $response = Read-Host "Are you sure you want to proceed? (Y/N)"

    if ($response -match '^[Yy]$') {
        Write-Host "Proceeding..."
        cmd.exe /c "sc delete $SrvcName"
    }
    else {
        Write-Host "Operation cancelled."
    }
    Pause
}

function ServiceState {
    $SrvcName = Read-Host "Enter service name"
    if ([string]::IsNullOrWhiteSpace($SrvcName)) { return }

    while (-not (Get-Service -Name $SrvcName -ErrorAction SilentlyContinue)) {
        Write-Host "Invalid service name: '$SrvcName' was not found." -ForegroundColor Red
        $SrvcName = Read-Host "Enter service name (or press Enter to cancel)"
        if ([string]::IsNullOrWhiteSpace($SrvcName)) { return }
    }

    $loop = $true
    while ($loop) {
        Write-Host " Required Services " -ForegroundColor Black -BackgroundColor Yellow
        Get-Service -Name $SrvcName -RequiredServices -ErrorAction SilentlyContinue | Select-Object Name, Status, DisplayName, StartType

        Write-Host " Dependent Services " -ForegroundColor Black -BackgroundColor Yellow
        Get-Service -Name $SrvcName -DependentServices -ErrorAction SilentlyContinue | Select-Object Name, Status, DisplayName, StartType

        Write-Host " Service Status " -ForegroundColor Black -BackgroundColor Yellow
        Get-Service -Name $SrvcName | Select-Object Name, Status, DisplayName, StartType
        Write-Host ""

        $loop = ServiceState2 -SrvcName $SrvcName
    }
}

function ServiceState2 {
    param([string]$SrvcName)

    Check-Admin
    Write-Host "*********************" -ForegroundColor White -BackgroundColor Red
    Write-Host "1. Stop Service"
    Write-Host "2. Start Service"
    Write-Host "3. Restart Service"
    Write-Host "4. Disable Service"
    Write-Host "5. Autostart Service"
    Write-Host "6. Manual Service"
    Write-Host "*********************" -ForegroundColor White -BackgroundColor Red
    Write-Host "Q. Cancel            " -ForegroundColor White -BackgroundColor Red
    Write-Host "*********************" -ForegroundColor White -BackgroundColor Red
    $SrvcAct = Read-Host "Enter service action"

    switch ($SrvcAct.ToUpper()) {
        '1' { Stop-Service -Name $SrvcName }
        '2' { Start-Service -Name $SrvcName }
        '3' { Restart-Service -Name $SrvcName }
        '4' { Set-Service -Name $SrvcName -StartupType Disabled }
        '5' { Set-Service -Name $SrvcName -StartupType Automatic }
        '6' { Set-Service -Name $SrvcName -StartupType Manual }
        'Q' { return $false }
        Default { Write-Host "Invalid selection." -ForegroundColor Red }
    }

    Clear-Host
    Write-Host "----------------------------------------------------------"
    Get-Service -Name $SrvcName | Select-Object Name, Status, DisplayName, StartType
    Write-Host "----------------------------------------------------------"
    return $true
}

function ServicesDisabled {
    Check-Admin
    $servicesToDisable = @(
        "XboxGipSvc", "XblAuthManager", "XblGameSave", "XboxNetApiSvc",
        "GameInputSvc", "BcastDVRUserService_ecc9e5", "RetailDemo",
        "shpamsvc", "workfolderssvc", "p2psvc", "CscService", "fax",
        "PcaSvc", "lfsvc", "WerSvc", "icssvc"
    )
    foreach ($serviceName in $servicesToDisable) {
        try {
            $service = Get-Service -Name $serviceName -ErrorAction Stop
            if ($service.Status -ne 'Stopped') {
                Write-Host "Stopping service: $serviceName..."
                Stop-Service -Name $serviceName -Force -ErrorAction Stop
            }
            Set-Service -Name $serviceName -StartupType Disabled -ErrorAction Stop
            Write-Host "Service '$serviceName' has been disabled successfully." -ForegroundColor Green
        }
        catch {
            Write-Host "Error processing service '$serviceName': $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    Pause
}

function Set-Reg {
    param($Path, $Name, $Value, $Type = 'DWord')
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $Type
}

function System {
    Get-CimInstance -ClassName Win32_BIOS
    Get-CimInstance -ClassName Win32_ComputerSystem

    $OSInfo         = Get-CimInstance -ClassName Win32_OperatingSystem
    $CIMMemory      = Get-CimInstance -ClassName CIM_PhysicalMemory
    $VirtualMemGB   = [math]::Round($OSInfo.TotalVirtualMemorySize / 1MB, 2)
    $VisibleMemGB   = [math]::Round($OSInfo.TotalVisibleMemorySize / 1MB, 2)
    $PhysicalMemGB  = [Math]::Round((($CIMMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB), 2)

    Write-Host "Physical Memory     : $PhysicalMemGB GB"
    Write-Host "Visible Memory      : $VisibleMemGB GB"
    Write-Host "Virtual Memory      : $VirtualMemGB GB"
    Write-Host ""

    Get-CimInstance -ClassName Win32_ComputerSystem -Property UserName
    Get-CimInstance -ClassName Win32_Processor | Select-Object -ExcludeProperty "CIM*"
    Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -Property SystemType
    Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"

    Write-Host "OPERATING SYSTEM..." -ForegroundColor Green
    Get-ComputerInfo -Property "OsName", "OsVersion"
    $OSInfo | Select-Object -Property BuildNumber, BuildType, OSType, ServicePackMajorVersion, ServicePackMinorVersion
    $OSInfo | Select-Object -Property *user*
    Pause
}

function SystemHostname {
    Write-Host "System Hostname: $(hostname)" -ForegroundColor Green
    systeminfo | findstr "Domain"
}

function SystemIPAddresses {
    Write-Host "System IP Addresses:" -ForegroundColor Green
    Get-NetIPAddress | Where-Object { $_.AddressFamily -eq 'IPv4' -and $_.InterfaceAlias -notmatch 'Loopback|vEthernet' } | Select-Object InterfaceAlias, IPAddress | Format-Table
    Pause
}

function SystemVersion {
    Get-ComputerInfo -Property "OsName", "OsVersion"
    Pause
}

function SystemWeeFeeMac {
    $CIMNetwork = Get-CimInstance Win32_NetworkAdapter
    $WifiMac = $CIMNetwork | Where-Object { $_.Name -match ("Wireless|wifi|wi\-fi") -and ($_.Name -notlike "*virtual*") } |
        Select-Object -ExpandProperty MacAddress
    Write-Host "WiFi Mac  : $WifiMac"
    Pause
}

function TestNetwork {
    Write-Host "Testing Firewall (GATEWAY)"
    try {
        $ActiveNet = Get-NetAdapter -Physical | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1 -ExpandProperty Name
        $Network = Get-NetIPAddress | Where-Object { $_.InterfaceAlias -eq $ActiveNet -and $_.IPv4Address -ne $null }
        $DefaultGateway = Get-NetRoute -InterfaceIndex $Network.InterfaceIndex -DestinationPrefix "0.0.0.0/0" | Select-Object -First 1 -ExpandProperty NextHop
        Test-Connection $DefaultGateway | Format-Table PSComputerName, Address, IPV4Address, IPV6Address, ReplySize, ResponseTime
    }
    catch {
        Write-Host "Could not determine default gateway: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host "Testing Internet Connection"
    Test-Connection 1.1.1.1 | Format-Table PSComputerName, Address, IPV4Address, IPV6Address, ReplySize, ResponseTime
    Pause
}

function Uptime {
    (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
    systeminfo | findstr "Boot Time"
    Pause
}

function WinUpdate {
    Check-Admin
    Write-Output "Running Windows update, this may take some time!"
    Write-Output "We will check, download and install any updates found..."

    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "PSWindowsUpdate module not found, installing..."
        Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope CurrentUser
    }
    Import-Module PSWindowsUpdate

    Get-WindowsUpdate -AcceptAll -Install -Verbose
    Pause
}

function WinUpdateReset {
    Check-Admin
    Stop-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    Stop-Service -Name "bits" -ErrorAction SilentlyContinue
    $folderPath = "c:\windows\SoftwareDistribution"
    try {
        if (Test-Path $folderPath) {
            Remove-Item -Path (Join-Path $folderPath '*') -Recurse -Force -ErrorAction Stop
            Write-Host "Contents of '$folderPath' deleted successfully."
        }
        else {
            Write-Host "Folder '$folderPath' does not exist."
        }
    }
    catch {
        Write-Host "Error deleting contents: $($_.Exception.Message)"
    }
    Start-Service -Name "bits" -ErrorAction SilentlyContinue
    Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
    Pause
}

function WinUpdateSelect {
    Check-Admin
    Write-Host "Collecting Updates..."
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser
    }
    Import-Module PSWindowsUpdate
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
    Write-Host "Available Updates..."
    Get-WindowsUpdate
    Write-Host "Step through Updates and prompt to install"
    Get-WindowsUpdate -Install
    Pause
}

function WhyNot {
    $LastUser = Get-CimInstance Win32_UserProfile -Filter 'Special=FALSE' -ErrorAction SilentlyContinue |
        Sort-Object LastUseTime -Descending |
        Select-Object -First 1 |
        ForEach-Object {
            try { ([System.Security.Principal.SecurityIdentifier]$_.SID).Translate([System.Security.Principal.NTAccount]).Value }
            catch { $_.SID }
        }

    $CIMCS = Get-CimInstance -ClassName Win32_ComputerSystem
    $CPUInfo = $CIMCS.Name
    $MN = $CIMCS.Model

    $OSInfo = Get-CimInstance Win32_OperatingSystem
    $OSInstallDate = $OSInfo.InstallDate

    $CIMMemory = Get-CimInstance CIM_PhysicalMemory
    $OSTotalVirtualMemory = [math]::Round($OSInfo.TotalVirtualMemorySize / 1MB, 2)
    $OSTotalVisibleMemory = [math]::Round(($OSInfo.TotalVisibleMemorySize / 1MB), 2)
    $PhysicalMemory = [Math]::Round((($CIMMemory | Measure-Object -Property Capacity -Sum).Sum / 1GB), 2)

    $CIMBios = Get-CimInstance Win32_BIOS
    $SN = $CIMBios.SerialNumber
    $MF = $CIMBios.Manufacturer

    $CIMDisk = Get-CimInstance Win32_LogicalDisk
    $DISKTOTAL = $CIMDisk | Where-Object { $_.Caption -eq "C:" } | ForEach-Object { "{0:N2} GB" -f ($_.Size / 1GB) }
    $DISKFREE  = $CIMDisk | Where-Object { $_.Caption -eq "C:" } | ForEach-Object { "{0:N2} GB" -f ($_.FreeSpace / 1GB) }

    $CIMNetwork = Get-CimInstance Win32_NetworkAdapter
    $WifiMac = $CIMNetwork | Where-Object { $_.Name -match ("Wireless|wifi|wi\-fi") -and ($_.Name -notlike "*virtual*") } |
        Select-Object -ExpandProperty MacAddress

    $CIMNetCfg = Get-CimInstance Win32_NetworkAdapterConfiguration
    $MAC = $CIMNetCfg | Where-Object { $_.IPEnabled -eq $true } | Select-Object -First 1 -ExpandProperty MacAddress

    $CIMChassis = Get-CimInstance Win32_SystemEnclosure | Select-Object -ExpandProperty ChassisTypes
    $IP = $null
    try { $IP = (Test-Connection $CPUInfo -Count 1 -ErrorAction Stop).IPv4Address.IPAddressToString } catch { }

    $infoObject = [PSCustomObject][ordered]@{
        "Asset: Name"                   = $CPUInfo
        "Asset: Model Number"           = $MN
        "Asset: Manufacturer"           = $MF
        "Asset: Serial Number"          = $SN
        "Inventory: Timestamp"          = $(Get-Date)
        "Inventory: Chassis"            = $CIMChassis
        "OS: Name"                      = $OSInfo.Caption
        "OS: Last Windows Install Date" = $OSInstallDate
        "OS: Last User"                 = $LastUser
        "Specs: Physical RAM"           = $PhysicalMemory
        "Specs: Virtual Memory"         = $OSTotalVirtualMemory
        "Specs: Visible Memory"         = $OSTotalVisibleMemory
        "Specs: Total Disk Space"       = $DISKTOTAL
        "Specs: Free Disk Space"        = $DISKFREE
        "Network: IP Address"           = $IP
        "Network: Wireless MAC Address" = $WifiMac
        "Network: Ethernet MAC Address" = $MAC
    }
    $infoObject    
    Pause
}


##BEGIN HERE ##
# Resize the console window/buffer. Not every host supports this
# (Windows Terminal, ISE, VS Code integrated terminal often don't),
# so wrap it and fail quietly rather than erroring out on launch.
try {
    $H = Get-Host
    $rawUI = $H.UI.RawUI
    $targetWidth  = 140
    $targetHeight = 50

    $newBufferSize = $rawUI.BufferSize
    if ($newBufferSize.Width -lt $targetWidth) { $newBufferSize.Width = $targetWidth }
    if ($newBufferSize.Height -lt $targetHeight) { $newBufferSize.Height = 3000 }
    $rawUI.BufferSize = $newBufferSize

    $rawUI.WindowSize = New-Object System.Management.Automation.Host.Size($targetWidth, $targetHeight)
}
catch {
    # Host does not support resizing - not a fatal problem, just continue.
}

# Display menu
Get-Menu