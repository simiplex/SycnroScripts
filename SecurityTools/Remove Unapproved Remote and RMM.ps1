# Import Syncro Module (Required for Create-Syncro-Ticket, Create-Syncro-Ticket-Comment, Send-Email, Rmm-Alert)
Import-Module $env:SyncroModule -WarningAction SilentlyContinue

# ==============================================================================
# CONFIGURATION
# ==============================================================================
$CreateSyncroTicket          = $true         # Open a Syncro Ticket linked to the PC and comment details
$TicketIssueType             = "Security"       # Must match a valid Issue Type in your Syncro Admin settings (e.g., "Other", "Security", "Remote Support")
$TicketStatusOnSuccess       = "Resolved"    # Ticket status if ALL unauthorized tools were removed ("New", "In Progress", or "Resolved")
$TicketStatusOnFailure       = "New"         # Ticket status if any tool failed to uninstall
$CommentHiddenFromClient     = $true         # $true = Private tech note (hidden from end-user portal/emails); $false = Public comment

$SendEmailReport             = $true         # Also send the formatted HTML email report
$TriggerSyncroAlertOnFailure = $true         # Trigger Syncro RMM Alert if removal fails
$DeletePortableExes          = $true         # Delete portable executables found in User/Temp directories

# ==============================================================================
# APPROVED & MONITORED SOFTWARE DEFINITIONS
# ==============================================================================
$ApprovedList = @(
    @{ Label = "Splashtop";  Pattern = "Splashtop|\bSRManager\b|\bSRService\b|\bstrwinclt\b" }
    @{ Label = "Syncro RMM"; Pattern = "\bSyncro\b|RepairTech|\bKabuto\b" }
    @{ Label = "NetBird";    Pattern = "\bNetBird\b|\bnetbird\.exe\b" }
)

$RemoteToolsDB = @(
    # --- Approved Tools ---
    @{ Vendor = "Splashtop";                 Pattern = "Splashtop|\bSRManager\b|\bSRService\b|\bstrwinclt\b" }
    @{ Vendor = "Syncro RMM";                Pattern = "\bSyncro\b|RepairTech|\bKabuto\b" }

    # --- Major Remote Access / Ad-Hoc Tools ---
    @{ Vendor = "ConnectWise ScreenConnect"; Pattern = "ScreenConnect|ConnectWise Control" }
    @{ Vendor = "TeamViewer";                Pattern = "TeamViewer" }
    @{ Vendor = "AnyDesk";                   Pattern = "AnyDesk" }
    @{ Vendor = "LogMeIn / GoTo";            Pattern = "LogMeIn|GoToAssist|GoToMyPC|GoToResolve|\bLMIGuardianSvc\b" }
    @{ Vendor = "RustDesk";                  Pattern = "RustDesk" }
    @{ Vendor = "BeyondTrust / Bomgar";      Pattern = "Bomgar|BeyondTrust" }
    @{ Vendor = "Zoho Assist";               Pattern = "Zoho Assist|ZohoAssist|\bZohoURS\b" }
    @{ Vendor = "Chrome Remote Desktop";     Pattern = "Chrome Remote Desktop|\bremoting_host\b" }
    @{ Vendor = "RealVNC";                   Pattern = "RealVNC|\bvncserver\b|\bwinvnc\b" }
    @{ Vendor = "TightVNC";                  Pattern = "TightVNC|\btvnserver\b" }
    @{ Vendor = "UltraVNC";                  Pattern = "UltraVNC|\buvnc" }
    @{ Vendor = "TigerVNC";                  Pattern = "TigerVNC" }
    @{ Vendor = "Dameware";                  Pattern = "Dameware|\bDWRCS\b" }
    @{ Vendor = "RemotePC";                  Pattern = "RemotePC|\bRPCService\b" }
    @{ Vendor = "Dualmon";                   Pattern = "Dualmon" }
    @{ Vendor = "ISL Online";                Pattern = "ISL Light|ISL AlwaysOn|ISLOnline" }
    @{ Vendor = "SimpleHelp";                Pattern = "SimpleHelp" }
    @{ Vendor = "SupRemo";                   Pattern = "\bSupRemo\b" }
    @{ Vendor = "Ammyy Admin";               Pattern = "\bAmmyy\b" }
    @{ Vendor = "AeroAdmin";                 Pattern = "AeroAdmin" }
    @{ Vendor = "UltraViewer";               Pattern = "UltraViewer" }
    @{ Vendor = "NoMachine";                 Pattern = "NoMachine|\bnxservice\b" }
    @{ Vendor = "Parsec";                    Pattern = "\bParsec\b|\bparsecd\b" }
    @{ Vendor = "HelpWire";                  Pattern = "HelpWire" }
    @{ Vendor = "ShowMyPC";                  Pattern = "ShowMyPC" }
    @{ Vendor = "Mikogo";                    Pattern = "Mikogo" }
    @{ Vendor = "Remote Utilities";          Pattern = "Remote Utilities|\brutserv\b|\brfusclient\b" }
    @{ Vendor = "NetSupport Manager";        Pattern = "NetSupport|\bclient32\b" }
    @{ Vendor = "Radmin";                    Pattern = "\bRadmin\b|\brserver3\b" }
    @{ Vendor = "Jump Desktop";              Pattern = "Jump Desktop|\bJumpConnect\b" }
    @{ Vendor = "Devolutions Remote";        Pattern = "Remote Desktop Manager|Wayk Now|Devolutions" }
    @{ Vendor = "LiteManager";               Pattern = "LiteManager|\bROMServer\b" }
    @{ Vendor = "Distant Desktop";           Pattern = "Distant Desktop" }
    @{ Vendor = "Iperius Remote";            Pattern = "Iperius" }
    @{ Vendor = "DeskRoll";                  Pattern = "DeskRoll" }
    @{ Vendor = "GetScreen.me";              Pattern = "\bGetScreen\b" }
    @{ Vendor = "HopToDesk";                 Pattern = "HopToDesk" }
    @{ Vendor = "Quick Assist (Store)";      Pattern = "Microsoft Corporation\.QuickAssist" }

    # --- Open-Source / Tactical / Self-Hosted RMMs ---
    @{ Vendor = "MeshCentral";               Pattern = "Mesh Agent|MeshCentral|\bMeshAgent\b" }
    @{ Vendor = "Tactical RMM";              Pattern = "Tactical RMM|\btacticalrmm\b" }
    @{ Vendor = "Action1";                   Pattern = "\bAction1\b" }
    @{ Vendor = "Level RMM";                 Pattern = "Level RMM|level\.io" }
    @{ Vendor = "FleetDM / osquery";         Pattern = "FleetDM|\borbit\.exe\b" }
    @{ Vendor = "Gorelo";                    Pattern = "\bGorelo\b" }

    # --- Competing Commercial RMM Agents ---
    @{ Vendor = "ConnectWise Automate";      Pattern = "ConnectWise Automate|LabTech|\bLTService\b|\bLTSvc\b" }
    @{ Vendor = "ConnectWise RMM";           Pattern = "ConnectWise RMM|Continuum|ITSPlatform|\bSAAZ" }
    @{ Vendor = "Datto RMM";                 Pattern = "Datto RMM|CentraStage|\bAEMAgent\b|\bCagService\b" }
    @{ Vendor = "Atera RMM";                 Pattern = "AteraAgent|Atera Networks" }
    @{ Vendor = "NinjaOne / NinjaRMM";       Pattern = "NinjaRMMAgent|NinjaOne|NinjaRMM" }
    @{ Vendor = "Kaseya VSA";                Pattern = "Kaseya|\bAgentMon\b" }
    @{ Vendor = "N-able N-central";          Pattern = "N-central|Windows Agent Service|AutomationManager" }
    @{ Vendor = "N-able N-sight";            Pattern = "Advanced Monitoring Agent|\bwinagent\b" }
    @{ Vendor = "Pulseway";                  Pattern = "Pulseway|\bPCMonitorSrv\b" }
    @{ Vendor = "SuperOps";                  Pattern = "SuperOps" }
    @{ Vendor = "ManageEngine RMM/Endpoint"; Pattern = "ManageEngine.*Agent|DesktopCentral|\bUEMSAgent\b" }
    @{ Vendor = "Barracuda RMM";             Pattern = "Barracuda RMM|LPI Level Platforms" }
    @{ Vendor = "Naverisk";                  Pattern = "Naverisk" }
    @{ Vendor = "Panorama9";                 Pattern = "Panorama9" }
    @{ Vendor = "Domotz";                    Pattern = "Domotz" }
    @{ Vendor = "Addigy / Goverlan";         Pattern = "Goverlan|Addigy" }
    @{ Vendor = "PDQ Connect";               Pattern = "PDQConnectAgent" }
    @{ Vendor = "LogMeIn Central";           Pattern = "LogMeIn Central" }
)

# ==============================================================================
# HELPER FUNCTIONS: DETECTION & SILENT UNINSTALL
# ==============================================================================
function Test-IsApproved ($TextToMatch) {
    foreach ($approved in $ApprovedList) {
        if ($TextToMatch -match $approved.Pattern) { return $true }
    }
    return $false
}

function Get-UnauthorizedRemoteTools {
    $Found = New-Object System.Collections.Generic.List[PSObject]

    # 1. Registry Uninstall Keys
    $UninstallPaths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    Get-ChildItem "Registry::HKEY_USERS" -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "_Classes|S-1-5-18|S-1-5-19|S-1-5-20|\.DEFAULT" } | ForEach-Object {
        $UninstallPaths += "Registry::$($_.Name)\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    }

    $InstalledApps = Get-ItemProperty $UninstallPaths -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName }
    foreach ($app in $InstalledApps) {
        $SearchString = "$($app.DisplayName) $($app.Publisher) $($app.InstallLocation)"
        if (Test-IsApproved $SearchString) { continue }

        foreach ($tool in $RemoteToolsDB) {
            if ($SearchString -match $tool.Pattern) {
                $VerInfo = if ($app.DisplayVersion) { "v$($app.DisplayVersion)" } else { "N/A" }
                $LocInfo = if ($app.InstallLocation) { $app.InstallLocation } elseif ($app.UninstallString) { $app.UninstallString } else { "Registry Uninstall Key" }
                
                $Found.Add([PSCustomObject]@{
                    Id              = "APP::$($app.DisplayName)"
                    Name            = $app.DisplayName
                    Vendor          = $tool.Vendor
                    Pattern         = $tool.Pattern
                    Type            = "Installed Application"
                    Version         = $VerInfo
                    LocationInfo    = $LocInfo
                    UninstallString = $app.UninstallString
                    QuietUninstall  = $app.QuietUninstallString
                    InstallLocation = $app.InstallLocation
                    ServiceName     = $null
                    ExePath         = $null
                })
                break
            }
        }
    }

    # 2. Windows Services (Active or Enabled)
    $Services = Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object {
        $_.PathName -notmatch "\\Windows\\(System32|SysWOW64)\\(svchost|lsass|services|wininit|SearchIndexer|spoolsv|msiexec|lsm)\.exe" -and
        $_.StartMode -ne "Disabled"
    }
    foreach ($svc in $Services) {
        $SearchString = "$($svc.Name) $($svc.DisplayName) $($svc.PathName)"
        if (Test-IsApproved $SearchString) { continue }

        foreach ($tool in $RemoteToolsDB) {
            if ($SearchString -match $tool.Pattern) {
                $Found.Add([PSCustomObject]@{
                    Id              = "SVC::$($svc.Name)"
                    Name            = "$($svc.DisplayName) ($($svc.Name))"
                    Vendor          = $tool.Vendor
                    Pattern         = $tool.Pattern
                    Type            = "Windows Service ($($svc.State))"
                    Version         = "Service"
                    LocationInfo    = $svc.PathName
                    UninstallString = $null
                    QuietUninstall  = $null
                    InstallLocation = $null
                    ServiceName     = $svc.Name
                    ExePath         = $svc.PathName
                })
                break
            }
        }
    }

    # 3. Running Processes
    $Processes = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ExecutablePath -notmatch "\\Windows\\(System32|SysWOW64)\\"
    }
    foreach ($proc in $Processes) {
        $SearchString = "$($proc.Name) $($proc.ExecutablePath) $($proc.CommandLine)"
        if (Test-IsApproved $SearchString) { continue }

        foreach ($tool in $RemoteToolsDB) {
            if ($SearchString -match $tool.Pattern) {
                $Found.Add([PSCustomObject]@{
                    Id              = "PROC::$($proc.Name)"
                    Name            = $proc.Name
                    Vendor          = $tool.Vendor
                    Pattern         = $tool.Pattern
                    Type            = "Running Process (Portable/Active)"
                    Version         = "PID: $($proc.ProcessId)"
                    LocationInfo    = if ($proc.ExecutablePath) { $proc.ExecutablePath } else { "Active in Memory" }
                    UninstallString = $null
                    QuietUninstall  = $null
                    InstallLocation = $null
                    ServiceName     = $null
                    ExePath         = $proc.ExecutablePath
                })
                break
            }
        }
    }

    return ($Found | Sort-Object Id -Unique)
}

function Invoke-SilentUninstall ($Item) {
    $ActionsTaken = @()

    # Step A: Kill matching processes first so files/services aren't locked
    $MatchingProcs = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue | Where-Object {
        $_.ExecutablePath -notmatch "\\Windows\\(System32|SysWOW64)\\" -and
        ("$($_.Name) $($_.ExecutablePath)" -match $Item.Pattern) -and
        (-not (Test-IsApproved "$($_.Name) $($_.ExecutablePath)"))
    }
    foreach ($p in $MatchingProcs) {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
        $ActionsTaken += "Terminated Process ($($p.Name))"
    }

    # Step B: Special Handler for ConnectWise RMM / Continuum (ITSPlatform)
    if ($Item.Vendor -match "ConnectWise RMM" -or $Item.Name -match "ITSPlatform|SAAZ") {
        $ITSUninstallers = @(
            "${env:ProgramFiles(x86)}\ITSPlatform\Setup\Uninstall.exe",
            "$env:ProgramFiles\ITSPlatform\Setup\Uninstall.exe",
            "${env:ProgramFiles(x86)}\ITSPlatform\agent\Uninstall.exe"
        )
        foreach ($uPath in $ITSUninstallers) {
            if (Test-Path $uPath) {
                Start-Process -FilePath $uPath -ArgumentList "/S /quiet /qn" -Wait -NoNewWindow -ErrorAction SilentlyContinue
                $ActionsTaken += "Ran ITSPlatform Native Uninstaller ($uPath)"
            }
        }
    }

    # Step C: Execute Standard Uninstaller if Application
    if ($Item.Type -like "*Application*") {
        $CmdToRun = if ($Item.QuietUninstall) { $Item.QuietUninstall } else { $Item.UninstallString }
        
        if ($CmdToRun) {
            if ($CmdToRun -match "(\{[0-9A-Fa-f]{8}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{4}-[0-9A-Fa-f]{12}\})") {
                $MsiGuid = $Matches[1]
                $MsiArgs = "/x $MsiGuid /qn /norestart REBOOT=ReallySuppress"
                $Proc = Start-Process "msiexec.exe" -ArgumentList $MsiArgs -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
                $ActionsTaken += "MSI Uninstall ($MsiGuid, ExitCode: $($Proc.ExitCode))"
            } else {
                if ($CmdToRun -match '^"([^"]+)"(.*)$') {
                    $Exe = $Matches[1]
                    $Args = $Matches[2].Trim()
                } elseif ($CmdToRun -match '^([^\s]+\.exe)(.*)$') {
                    $Exe = $Matches[1]
                    $Args = $Matches[2].Trim()
                } else {
                    $Exe = $CmdToRun
                    $Args = ""
                }

                if (-not $Item.QuietUninstall) {
                    if ($Item.Vendor -match "AnyDesk") {
                        $Args = "--remove --silent"
                    } elseif ($Item.Vendor -match "RustDesk") {
                        $Args = "--uninstall --silent"
                    } elseif ($Exe -match "unins\d+\.exe") {
                        $Args += " /VERYSILENT /SUPPRESSMSGBOXES /NORESTART"
                    } else {
                        $Args += " /S /quiet /qn /norestart"
                    }
                }

                if (Test-Path $Exe) {
                    $Proc = Start-Process -FilePath $Exe -ArgumentList $Args -Wait -PassThru -NoNewWindow -ErrorAction SilentlyContinue
                    $ActionsTaken += "EXE Uninstaller ($Exe, ExitCode: $($Proc.ExitCode))"
                }
            }
        }
    }

    # Step D: Stop, Disable, and Delete Service
    $MatchingSvcs = Get-CimInstance Win32_Service -ErrorAction SilentlyContinue | Where-Object {
        $_.PathName -notmatch "\\Windows\\(System32|SysWOW64)\\" -and
        ("$($_.Name) $($_.DisplayName) $($_.PathName)" -match $Item.Pattern) -and
        (-not (Test-IsApproved "$($_.Name) $($_.DisplayName) $($_.PathName)"))
    }
    foreach ($s in $MatchingSvcs) {
        if ($s.PathName -match '^"?([^"]+\.exe)"?' -and $Item.Vendor -match "MeshCentral") {
            $MeshExe = $Matches[1]
            if (Test-Path $MeshExe) {
                Start-Process -FilePath $MeshExe -ArgumentList "-fulluninstall" -Wait -NoNewWindow -ErrorAction SilentlyContinue
                $ActionsTaken += "Ran MeshAgent -fulluninstall"
            }
        }

        Stop-Service -Name $s.Name -Force -ErrorAction SilentlyContinue
        Set-Service -Name $s.Name -StartupType Disabled -ErrorAction SilentlyContinue
        & sc.exe stop "$($s.Name)" | Out-Null
        & sc.exe delete "$($s.Name)" | Out-Null
        $ActionsTaken += "Stopped & Deleted Service ($($s.Name))"
    }

    # Step E: Delete Portable Executable if running from User Profile / AppData / Temp
    if ($Item.Type -like "*Process*" -and $DeletePortableExes -and $Item.ExePath) {
        if ($Item.ExePath -match "\\Users\\|\\Temp\\|\\ProgramData\\" -and (Test-Path $Item.ExePath)) {
            Remove-Item -Path $Item.ExePath -Force -ErrorAction SilentlyContinue
            if (-not (Test-Path $Item.ExePath)) {
                $ActionsTaken += "Deleted Portable EXE ($($Item.ExePath))"
            }
        }
    }

    if ($ActionsTaken.Count -eq 0) {
        return "Attempted termination/cleanup (No standard uninstaller registered)"
    }
    return ($ActionsTaken -join " | ")
}

# ==============================================================================
# 1. GATHER SYSTEM METADATA
# ==============================================================================
$ComputerName = $env:COMPUTERNAME
$CheckTime    = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

$LoggedOnUser = "None (Console Idle)"
try {
    $ExplorerProcs = Get-CimInstance Win32_Process -Filter "Name = 'explorer.exe'" -ErrorAction Stop
    if ($ExplorerProcs) {
        $Users = foreach ($proc in $ExplorerProcs) {
            $owner = Invoke-CimMethod -InputObject $proc -MethodName GetOwner -ErrorAction SilentlyContinue
            if ($owner.User) {
                if ($owner.Domain) { "$($owner.Domain)\$($owner.User)" } else { $owner.User }
            }
        }
        if ($Users) { $LoggedOnUser = ($Users | Select-Object -Unique) -join ", " }
    }
} catch { $LoggedOnUser = "Unknown" }

$DomainDisplay = "WORKGROUP"
try {
    $CompSys = Get-CimInstance Win32_ComputerSystem -ErrorAction Stop
    if ($CompSys.PartOfDomain) {
        $FullDomain = $CompSys.Domain
        $ShortDomain = ($FullDomain -split '\.')[0].ToUpper()
        $DomainDisplay = "$ShortDomain ($FullDomain)"
    } else {
        $DomainDisplay = "$($CompSys.Workgroup) (Workgroup)"
    }
} catch {}

# ==============================================================================
# 2. INITIAL SCAN -> ATTEMPT REMOVAL -> POST-REMOVAL VERIFICATION SCAN
# ==============================================================================
Write-Host "Starting security audit scan on $ComputerName..."
$InitialUnauthorized = Get-UnauthorizedRemoteTools

if ($InitialUnauthorized.Count -eq 0) {
    Write-Host "No unauthorized remote access software found on $ComputerName. Exiting cleanly."
    exit 0
}

Write-Host "Found $($InitialUnauthorized.Count) unauthorized item(s). Attempting removal..."

$ActionLog = @{}
foreach ($item in $InitialUnauthorized) {
    Write-Host " -> Remediating: $($item.Name) [$($item.Type)]"
    $ActionResult = Invoke-SilentUninstall -Item $item
    $ActionLog[$item.Id] = $ActionResult
}

# Wait 5 seconds for background uninstallers and service deletions to complete
Start-Sleep -Seconds 5

Write-Host "Running post-removal verification scan..."
$PostScanUnauthorized = Get-UnauthorizedRemoteTools
$RemainingIds = $PostScanUnauthorized | Select-Object -ExpandProperty Id

$VerificationResults = New-Object System.Collections.Generic.List[PSObject]
foreach ($item in $InitialUnauthorized) {
    $StillPresent = $RemainingIds -contains $item.Id
    $VerificationResults.Add([PSCustomObject]@{
        Name          = $item.Name
        Vendor        = $item.Vendor
        Type          = $item.Type
        Version       = $item.Version
        LocationInfo  = $item.LocationInfo
        Status        = if ($StillPresent) { "FAILED - STILL PRESENT" } else { "REMOVED" }
        ActionDetails = $ActionLog[$item.Id]
    })
}

$RemovedCount = ($VerificationResults | Where-Object { $_.Status -eq "REMOVED" } | Measure-Object).Count
$FailedCount  = ($VerificationResults | Where-Object { $_.Status -ne "REMOVED" } | Measure-Object).Count

# ==============================================================================
# 3. OPEN SYNCRO TICKET (LINKED TO PC) & POST DETAILED AUDIT COMMENT
# ==============================================================================
$CreatedTicketNumber = $null

if ($CreateSyncroTicket -and (Get-Command Create-Syncro-Ticket -ErrorAction SilentlyContinue)) {
    $TicketSubject = if ($FailedCount -eq 0) {
        "Security Audit: Unauthorized remote software removed on $ComputerName"
    } else {
        "Security Audit [Action Required]: Unauthorized remote software on $ComputerName"
    }

    $FinalTicketStatus = if ($FailedCount -eq 0) { $TicketStatusOnSuccess } else { $TicketStatusOnFailure }

    # Build the detailed Ticket Comment Body
    $CommentLines = New-Object System.Collections.Generic.List[string]
    $CommentLines.Add("AUTOMATED SECURITY AUDIT & REMEDIATION REPORT SENT TO $ToAddress")
    $CommentLines.Add("====================================================")
    $CommentLines.Add("Unauthorized remote access software was detected on $ComputerName during an automated security audit and removal was attempted.")
    $CommentLines.Add("")
    $CommentLines.Add("Endpoint Details:")
    $CommentLines.Add(" - Computer Name : $ComputerName")
    $CommentLines.Add(" - Logged-on User: $LoggedOnUser")
    $CommentLines.Add(" - Domain/Group  : $DomainDisplay")
    $CommentLines.Add(" - Audit Time    : $CheckTime")
    $CommentLines.Add(" - Summary       : $RemovedCount Removed | $FailedCount Failed")
    $CommentLines.Add("")
    $CommentLines.Add("Detected Remote Software & Remediation Details:")
    $CommentLines.Add("----------------------------------------------------")

    $Index = 1
    foreach ($res in $VerificationResults) {
        $CommentLines.Add("$Index. Software Name   : $($res.Name)")
        $CommentLines.Add("   Vendor / Family : $($res.Vendor)")
        $CommentLines.Add("   Detection Type  : $($res.Type)")
        $CommentLines.Add("   Version / PID   : $($res.Version)")
        $CommentLines.Add("   Path / Location : $($res.LocationInfo)")
        $CommentLines.Add("   Action Taken    : $($res.ActionDetails)")
        $CommentLines.Add("   Post-Check      : $($res.Status)")
        $CommentLines.Add("")
        $Index++
    }

    $TicketCommentBody = $CommentLines -join "`r`n"

    try {
        Write-Host "Creating Syncro Ticket for $ComputerName..."
        $TicketResponse = Create-Syncro-Ticket -Subject $TicketSubject -IssueType $TicketIssueType -Status $FinalTicketStatus
        $CreatedTicketNumber = $TicketResponse.ticket.number

        if ($CreatedTicketNumber) {
            Write-Host "Syncro Ticket #$CreatedTicketNumber created. Posting audit & removal comment..."
            Create-Syncro-Ticket-Comment -TicketIdOrNumber $CreatedTicketNumber -Subject "Security Audit Remediation Details" -Body $TicketCommentBody -Hidden $CommentHiddenFromClient -DoNotEmail $true
            Write-Host "Comment successfully posted to Ticket #$CreatedTicketNumber."
        } else {
            Write-Warning "Create-Syncro-Ticket executed, but no Ticket Number was returned. Verify that `$TicketIssueType ('$TicketIssueType') matches a valid Issue Type in your Syncro Admin settings."
        }
    } catch {
        Write-Warning "Failed to create or update Syncro Ticket: $_"
    }
}

# ==============================================================================
# 4. SEND HTML VERIFICATION EMAIL & TRIGGER RMM ALERT
# ==============================================================================
if ($SendEmailReport) {
    $TableRowsHtml = ""
    foreach ($res in $VerificationResults) {
        if ($res.Status -ne "REMOVED") {
            $RowBg       = "background-color: #fceaea;"
            $StatusStyle = "color: #b91c1c; font-weight: bold;"
        } else {
            $RowBg       = "background-color: #eef7ee;"
            $StatusStyle = "color: #2e7d32; font-weight: bold;"
        }

        $SafeName   = [System.Net.WebUtility]::HtmlEncode("$($res.Name) [$($res.Vendor)]")
        $SafeType   = [System.Net.WebUtility]::HtmlEncode($res.Type)
        $SafeStatus = [System.Net.WebUtility]::HtmlEncode($res.Status)
        $SafeDetail = [System.Net.WebUtility]::HtmlEncode("Path: $($res.LocationInfo) | Action: $($res.ActionDetails)")

        $TableRowsHtml += @"
            <tr style="$RowBg border-bottom: 1px solid #e0e0e0;">
                <td style="padding: 8px 10px; font-size: 13px; color: #111111;">$SafeName</td>
                <td style="padding: 8px 10px; font-size: 13px; color: #111111;">$SafeType</td>
                <td style="padding: 8px 10px; font-size: 13px; $StatusStyle">$SafeStatus</td>
                <td style="padding: 8px 10px; font-size: 11px; color: #555555; font-family: Consolas, monospace;">$SafeDetail</td>
            </tr>
"@
    }

    $TicketBannerRef = if ($CreatedTicketNumber) { " (Syncro Ticket #$CreatedTicketNumber)" } else { "" }

    if ($FailedCount -gt 0) {
        $BannerColor  = "#c42b1c"
        $BannerIcon   = "&#9888;&#65039;"
        $BannerText   = "Remediation Incomplete: $FailedCount failed, $RemovedCount removed on $ComputerName$TicketBannerRef"
        $EmailSubject = "ACTION REQUIRED: Failed to remove unauthorized remote software on $ComputerName$TicketBannerRef"
    } else {
        $BannerColor  = "#2e7d32"
        $BannerIcon   = "&#9989;"
        $BannerText   = "Remediation Successful: $RemovedCount unauthorized remote tool(s) removed on $ComputerName$TicketBannerRef"
        $EmailSubject = "RESOLVED: Removed unauthorized remote software on $ComputerName$TicketBannerRef"
    }

    $ExceptionListText = ($ApprovedList | ForEach-Object { $_.Label }) -join ", "
    $TicketRowHtml = if ($CreatedTicketNumber) {
        @"
        <tr>
            <td style="color: #666666; padding: 6px 24px 6px 4px;">Syncro Ticket</td>
            <td style="font-weight: bold; color: #000000; padding: 6px 4px;">#$CreatedTicketNumber</td>
        </tr>
"@
    } else { "" }

    $HtmlBody = @"
<html>
<body style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; color: #222222; margin: 0; padding: 12px;">
    <div style="background-color: $BannerColor; color: #ffffff; padding: 6px 12px; font-weight: bold; font-size: 14px; margin-bottom: 16px;">
        $BannerIcon $BannerText
    </div>
    <table style="border-collapse: collapse; margin-bottom: 22px; font-size: 13px;">
        <tr>
            <td style="color: #666666; padding: 6px 24px 6px 4px;">Computer</td>
            <td style="font-weight: bold; color: #000000; padding: 6px 4px;">$ComputerName</td>
        </tr>
        <tr>
            <td style="color: #666666; padding: 6px 24px 6px 4px;">Logged-on user</td>
            <td style="color: #000000; padding: 6px 4px;">$LoggedOnUser</td>
        </tr>
        <tr>
            <td style="color: #666666; padding: 6px 24px 6px 4px;">Remediated at</td>
            <td style="color: #000000; padding: 6px 4px;">$CheckTime</td>
        </tr>
        <tr>
            <td style="color: #666666; padding: 6px 24px 6px 4px;">Joined domain</td>
            <td style="color: #000000; padding: 6px 4px;">$DomainDisplay</td>
        </tr>
        $TicketRowHtml
    </table>
    <div style="font-weight: bold; font-size: 13px; margin-bottom: 6px; padding-left: 4px; color: #000000;">
        Post-Removal Verification Results
    </div>
    <table style="border-collapse: collapse; width: 100%; max-width: 900px; text-align: left; border-top: 1px solid #e0e0e0;">
        <thead>
            <tr style="background-color: #f3f3f3; border-bottom: 1px solid #d0d0d0;">
                <th style="padding: 8px 10px; font-size: 13px; color: #000000;">Software / Vendor</th>
                <th style="padding: 8px 10px; font-size: 13px; color: #000000;">Type</th>
                <th style="padding: 8px 10px; font-size: 13px; color: #000000;">Post-Check Status</th>
                <th style="padding: 8px 10px; font-size: 13px; color: #000000;">Path &amp; Remediation Action</th>
            </tr>
        </thead>
        <tbody>
            $TableRowsHtml
        </tbody>
    </table>
    <div style="color: #777777; font-size: 11px; margin-top: 18px; padding-left: 4px;">
        Exception list: $ExceptionListText
    </div>
</body>
</html>
"@

    Send-Email -To $ToAddress -Subject $EmailSubject -Body $HtmlBody
    Write-Host "Remediation verification email sent to $ToAddress."
}

# Trigger Syncro RMM Alert if any removal failed
if ($TriggerSyncroAlertOnFailure -and $FailedCount -gt 0) {
    $FailedNames = ($VerificationResults | Where-Object { $_.Status -ne "REMOVED" } | Select-Object -ExpandProperty Name) -join ", "
    Rmm-Alert -Category "Unauthorized Remote Access - Removal Failed" -Body "Failed to automatically remove unauthorized remote software on ${ComputerName}: $FailedNames"
}
