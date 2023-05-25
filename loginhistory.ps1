# Specify the event ID for logon events
$LogonEventID = 4624

# Specify the maximum number of logins to retrieve
$MaxLogins = 50

# Define well-known SIDs for system accounts and services to exclude
$SystemSIDs = @(
    'S-1-5-18'    # Local System
    'S-1-5-19'    # Local Service
    'S-1-5-20'    # Network Service
    'S-1-5-83-1'  # NT SERVICE\NetSetupSvc
    'S-1-5-90'    # Hyper-V Administrators
    'S-1-5-96-0'  # Windows Installer
    # Add any other well-known SIDs you want to exclude
)

# Retrieve logon events
$logonEvents = Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    ID = $LogonEventID
}

# Display logon events for human user accounts
Write-Host "Logon events (Human User Accounts):"
if ($logonEvents) {
    $count = 0
    foreach ($event in $logonEvents) {
        $time = Get-Date $event.TimeCreated -Format "ddd, yyyy-MM-dd hh:mm tt"
        $user = $event.Properties[5].Value
        $sid = $null
        try {
            $sid = (New-Object System.Security.Principal.NTAccount($user)).Translate([System.Security.Principal.SecurityIdentifier]).Value
        } catch {
            # Silently continue SID translation error
        }
        $exclude = $false
        foreach ($systemSID in $SystemSIDs) {
            if ($sid -like "$systemSID*") {
                $exclude = $true
                break
            }
        }
        if ($exclude) {
            continue  # Skip logon events associated with system accounts
        }
        if ($sid -and $sid.Length -gt ($SystemSIDs | ForEach-Object { $_.Length } | Measure-Object -Maximum).Maximum) {
            $count++
            Write-Host "Time: $time, User: $user, SID: $sid"
        }
        if ($count -eq $MaxLogins) {
            break  # Limit to $MaxLogins events
        }
    }
    Write-Host "Total logon events for human user accounts found: $count"
} else {
    Write-Host "No logon events found."
}
