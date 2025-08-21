




<# ===========================================================================
AD-Admin-Console.ps1
A simple, professional, menu-driven “admin console” for common AD tasks.
- Uses Out-GridView for semi-GUI selection when available (WinPS on desktop).
- Falls back to Read-Host prompts if OGV isn’t present.
- Idempotent where possible (existence checks).
- Safe defaults; re-runnable.

Requires: RSAT/ActiveDirectory + GroupPolicy modules on DC01 or an RSAT workstation.
============================================================================ #>

[CmdletBinding(SupportsShouldProcess=$true)]
param()

# ---------------------- Helpers & Prereqs ----------------------
function Test-Module {
    param([string]$Name)
    $m = Get-Module -ListAvailable -Name $Name
    return [bool]$m
}
function Ensure-Modules {
    $missing = @()
    foreach ($m in @('ActiveDirectory','GroupPolicy')) {
        if (-not (Test-Module $m)) { $missing += $m }
    }
    if ($missing.Count -gt 0) {
        throw "Missing modules: $($missing -join ', '). Install RSAT AD & GPMC."
    }
    Import-Module ActiveDirectory -ErrorAction Stop
    Import-Module GroupPolicy -ErrorAction Stop
}
function Get-DomainDN {
    try { (Get-ADDomain).DistinguishedName }
    catch { throw "Cannot query domain. Are you on a DC or RSAT workstation?" }
}
function Use-OGV { Get-Command Out-GridView -ErrorAction SilentlyContinue }

function Select-OU {
    # returns DistinguishedName of selected OU
    $ous = Get-ADOrganizationalUnit -Filter * -Properties Name,DistinguishedName |
           Sort-Object Name
    if ((Use-OGV)) {
        $sel = $ous | Select-Object Name,DistinguishedName | Out-GridView -Title "Select an OU" -PassThru
        if (-not $sel) { throw "No OU selected." }
        return $sel.DistinguishedName
    } else {
        Write-Host "`nAvailable OUs (first 25):"
        $ous | Select-Object -First 25 | ForEach-Object { Write-Host " - $($_.Name)" }
        $name = Read-Host "Type OU name (exact match)"
        $hit = $ous | Where-Object Name -eq $name
        if (-not $hit) { throw "OU not found: $name" }
        return $hit.DistinguishedName
    }
}

function Select-Users {
    $users = Get-ADUser -Filter * -Properties DisplayName,SamAccountName |
             Sort-Object DisplayName
    if ((Use-OGV)) {
        $sel = $users | Select-Object DisplayName,SamAccountName | Out-GridView -Title "Select user(s)" -PassThru -Multiple
        if (-not $sel) { throw "No users selected." }
        return $sel.SamAccountName
    } else {
        $inp = Read-Host "Enter one or more sAMAccountNames (comma-separated)"
        return ($inp -split ',').ForEach({ $_.Trim() }) | Where-Object { $_ }
    }
}

function Select-Groups {
    $groups = Get-ADGroup -Filter * -Properties Name | Sort-Object Name
    if ((Use-OGV)) {
        $sel = $groups | Select-Object Name | Out-GridView -Title "Select group(s)" -PassThru -Multiple
        if (-not $sel) { throw "No groups selected." }
        return $sel.Name
    } else {
        $inp = Read-Host "Enter one or more group names (comma-separated)"
        return ($inp -split ',').ForEach({ $_.Trim() }) | Where-Object { $_ }
    }
}

function Select-Computer {
    $comps = Get-ADComputer -Filter * -Properties Name | Sort-Object Name
    if ((Use-OGV)) {
        $sel = $comps | Select-Object Name | Out-GridView -Title "Select computer" -PassThru
        if (-not $sel) { throw "No computer selected." }
        return $sel.Name
    } else {
        return Read-Host "Enter computer name"
    }
}

# ---------------------- Tasks ----------------------
function New-OU-Interactive {
    $domainDN = Get-DomainDN
    Write-Host "`n[Create OU] Choose mode:"
    Write-Host "  1) Create under domain root  ($domainDN)"
    Write-Host "  2) Create under selected parent OU"
    $mode = Read-Host "Select 1 or 2"
    $parentDN = if ($mode -eq '2') { Select-OU } else { $domainDN }

    $name = Read-Host "Enter OU name (single) OR a hierarchy with / separators (e.g., Departments/Engineering)"
    if ($name -match '[\\/]' ) {
        # Hierarchy
        $current = $parentDN
        $parts = $name -split '[\\/]'
        foreach ($p in $parts) {
            $ou = $p.Trim()
            if (-not $ou) { continue }
            $dn = "OU=$ou,$current"
            $exists = Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$dn)" -ErrorAction SilentlyContinue
            if ($exists) {
                Write-Host "OU exists: $dn" -ForegroundColor Yellow
                $current = $dn
            } else {
                if ($PSCmdlet.ShouldProcess($dn, "Create OU")) {
                    New-ADOrganizationalUnit -Name $ou -Path $current -ProtectedFromAccidentalDeletion $true | Out-Null
                    Write-Host "Created OU: $dn" -ForegroundColor Green
                    $current = $dn
                }
            }
        }
        Write-Host "Final OU: $current"
    } else {
        $ou = $name.Trim()
        if (-not $ou) { throw "OU name cannot be empty." }
        $dn = "OU=$ou,$parentDN"
        $exists = Get-ADOrganizationalUnit -LDAPFilter "(distinguishedName=$dn)" -ErrorAction SilentlyContinue
        if ($exists) {
            Write-Host "OU exists: $dn" -ForegroundColor Yellow
        } else {
            if ($PSCmdlet.ShouldProcess($dn, "Create OU")) {
                New-ADOrganizationalUnit -Name $ou -Path $parentDN -ProtectedFromAccidentalDeletion $true | Out-Null
                Write-Host "Created OU: $dn" -ForegroundColor Green
            }
        }
    }
}

function New-Group-Interactive {
    $parent = Select-OU
    $name = Read-Host "Enter group name"
    if (-not $name) { throw "Group name required." }
    $dn = "CN=$name,$parent"
    $exists = Get-ADGroup -LDAPFilter "(cn=$name)" -SearchBase $parent -ErrorAction SilentlyContinue
    if ($exists) { Write-Host "Group exists: $name" -ForegroundColor Yellow; return }
    if ($PSCmdlet.ShouldProcess($dn, "Create Group")) {
        New-ADGroup -Name $name -GroupScope Global -GroupCategory Security -Path $parent
        Write-Host "Created group $name in $parent" -ForegroundColor Green
    }
}

function New-User-Interactive {
    $parent = Select-OU
    $given = Read-Host "First name"
    $sn    = Read-Host "Last name"
    $sam   = Read-Host "sAMAccountName (e.g., john.ripper)"
    $upn   = Read-Host "UserPrincipalName (e.g., john.ripper@ToonWrld.local)"
    $pwd   = Read-Host "Initial password" -AsSecureString
    if ($PSCmdlet.ShouldProcess("CN=$given $sn,$parent", "Create User")) {
        try {
            New-ADUser -Name "$given $sn" -GivenName $given -Surname $sn `
                -SamAccountName $sam -UserPrincipalName $upn -Path $parent `
                -AccountPassword $pwd -Enabled $true
            Write-Host "Created user $sam in $parent" -ForegroundColor Green
        } catch { Write-Warning $_.Exception.Message }
    }
}

function New-Users-FromCsv {
    $path = Read-Host "CSV path (FirstName,LastName,SamAccountName,UPN,OU,InitialPassword,Groups)"
    if (-not (Test-Path $path)) { throw "CSV not found: $path" }
    $domainDN = Get-DomainDN
    $deptRoot = "OU=Departments,$domainDN"
    Import-Csv $path | ForEach-Object {
        $ouDn = if ($_.OU -match '^OU=') { $_.OU } else { "OU=$($_.OU),$deptRoot" }
        $exists = Get-ADUser -LDAPFilter "(sAMAccountName=$($_.SamAccountName))" -ErrorAction SilentlyContinue
        if (-not $exists) {
            $sec = ConvertTo-SecureString $_.InitialPassword -AsPlainText -Force
            try {
                New-ADUser -Name "$($_.FirstName) $($_.LastName)" `
                    -GivenName $_.FirstName -Surname $_.LastName `
                    -SamAccountName $_.SamAccountName -UserPrincipalName $_.UPN `
                    -Path $ouDn -AccountPassword $sec -Enabled $true
                Write-Host "Created user $($_.SamAccountName) in $ouDn" -ForegroundColor Green
            } catch { Write-Warning "User create failed for $($_.SamAccountName): $($_.Exception.Message)" }
        } else { Write-Host "User exists: $($_.SamAccountName)" -ForegroundColor Yellow }

        if ($_.Groups) {
            ($_.Groups -split '[;, ]+' | Where-Object { $_ }) | ForEach-Object {
                try { Add-ADGroupMember -Identity $_ -Members $_.SamAccountName -ErrorAction Stop; Write-Host " Added to group: $_" }
                catch { Write-Warning " Group add failed: $_" }
            }
        }
    }
}

function Add-Users-ToGroups {
    $users  = Select-Users
    $groups = Select-Groups
    foreach ($u in $users) {
        foreach ($g in $groups) {
            try { Add-ADGroupMember -Identity $g -Members $u -ErrorAction Stop; Write-Host "Added $u -> $g" -ForegroundColor Green }
            catch { Write-Warning "Failed $u -> $g : $($_.Exception.Message)" }
        }
    }
}

function Move-Computer-ToOU {
    $comp = Select-Computer
    $target = Select-OU
    try {
        $obj = Get-ADComputer -Identity $comp -ErrorAction Stop
        Move-ADObject -Identity $obj.DistinguishedName -TargetPath $target
        Write-Host "Moved $comp to $target" -ForegroundColor Green
    } catch { Write-Warning $_.Exception.Message }
}

function Set-LogonBanner-GPO {
    $targetOU = Select-OU
    $gpoName  = Read-Host "GPO name (default: Pied Piper Banner)"
    if (-not $gpoName) { $gpoName = "Pied Piper Banner" }
    $title = Read-Host "Banner title (default: Pied Piper Security Notice)"
    if (-not $title) { $title = "Pied Piper Security Notice" }
    $text  = Read-Host "Banner text (lines allowed). End with Enter."
    if (-not $text) { $text = "Authorized access only.`nAll activity is monitored.`nPied Piper Systems Confidential." }

    $gpo = Get-GPO -Name $gpoName -ErrorAction SilentlyContinue
    if (-not $gpo) { $gpo = New-GPO -Name $gpoName; Write-Host "Created GPO: $gpoName" -ForegroundColor Green }
    New-GPLink -Name $gpoName -Target $targetOU -ErrorAction SilentlyContinue | Out-Null

    Set-GPRegistryValue -Name $gpoName -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "legalnoticecaption" -Type String -Value $title
    Set-GPRegistryValue -Name $gpoName -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "legalnoticetext"    -Type String -Value $text

    Write-Host "Banner configured & linked to $targetOU" -ForegroundColor Green
}

function Delegate-ResetPassword {
    $ou = Select-OU
    $group = Read-Host "Delegate to which group (e.g., BizOps)"
    if (-not $group) { throw "Group name required." }
    $domain = (Get-ADDomain).NetBIOSName
    & dsacls $ou /I:S /G "$domain\$group:CA;Reset Password" | Out-Null
    & dsacls $ou /I:S /G "$domain\$group:WP;lockoutTime;user" | Out-Null
    Write-Host "Delegation applied to $ou for $domain\$group" -ForegroundColor Green
}

function Export-AD-State {
    $stamp = (Get-Date).ToString('yyyyMMdd-HHmm')
    $out = Join-Path $PSScriptRoot "..\artifacts\$stamp"
    New-Item -ItemType Directory -Force -Path $out | Out-Null

    Get-ADOrganizationalUnit -Filter * | Select Name,DistinguishedName |
      Export-Csv (Join-Path $out "OU-Inventory.csv") -NoTypeInformation
    Get-ADGroup -Filter * | Select Name,GroupScope,GroupCategory,DistinguishedName |
      Export-Csv (Join-Path $out "Group-Inventory.csv") -NoTypeInformation
    Get-ADUser -Filter * -Properties DisplayName,Department,Enabled,PasswordLastSet,LastLogonDate |
      Select DisplayName,SamAccountName,UserPrincipalName,Department,Enabled,PasswordLastSet,LastLogonDate,DistinguishedName |
      Export-Csv (Join-Path $out "User-Inventory.csv") -NoTypeInformation
    Get-ADComputer -Filter * -Properties OperatingSystem,LastLogonDate |
      Select Name,OperatingSystem,LastLogonDate,DistinguishedName |
      Export-Csv (Join-Path $out "Computer-Inventory.csv") -NoTypeInformation

    $gpoHtml = Join-Path $out "GPO-Report.html"
    Get-GPOReport -All -ReportType Html -Path $gpoHtml
    Write-Host "Exported artifacts to $out" -ForegroundColor Green
}

# ---------------------- Menu ----------------------
function Show-Menu {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "            Active Directory Admin Console        " -ForegroundColor Cyan
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host " [1] Create OU (single / hierarchy)"
    Write-Host " [2] Create Group"
    Write-Host " [3] Create User (single)"
    Write-Host " [4] Create Users from CSV"
    Write-Host " [5] Add Users to Groups"
    Write-Host " [6] Move Computer to OU"
    Write-Host " [7] Set 'Logon Banner' GPO"
    Write-Host " [8] Delegate 'Reset Password' on an OU"
    Write-Host " [9] Export AD State (CSV + GPO report)"
    Write-Host " [Q] Quit"
    Write-Host "--------------------------------------------------"
}

try {
    Ensure-Modules
    while ($true) {
        Show-Menu
        $choice = Read-Host "Select an option"
        switch ($choice.ToUpper()) {
            '1' { New-OU-Interactive; Pause }
            '2' { New-Group-Interactive; Pause }
            '3' { New-User-Interactive; Pause }
            '4' { New-Users-FromCsv; Pause }
            '5' { Add-Users-ToGroups; Pause }
            '6' { Move-Computer-ToOU; Pause }
            '7' { Set-LogonBanner-GPO; Pause }
            '8' { Delegate-ResetPassword; Pause }
            '9' { Export-AD-State; Pause }
            'Q' { break }
            default { Write-Host "Invalid selection."; Pause }
        }
    }
}
catch {
    Write-Error $_.Exception.Message
}






































































































































