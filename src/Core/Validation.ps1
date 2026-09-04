# SYSTEC SysTool
# Core/Validation.ps1

function Test-STRequirements {

    $results = [ordered]@{
        Windows       = $false
        PowerShell    = $false
        CIM           = $false
        Administrator = $false
    }

    # Windows
    if ($env:OS -eq "Windows_NT") {
        $results.Windows = $true
    }

    # PowerShell
    if ($PSVersionTable.PSVersion.Major -ge 5) {
        $results.PowerShell = $true
    }

    # CIM
    try {
        Get-CimInstance Win32_OperatingSystem -ErrorAction Stop | Out-Null
        $results.CIM = $true
    }
    catch {
        $results.CIM = $false
    }

    # Administrator
    $results.Administrator = Test-STAdministrator

    $failed = $results.GetEnumerator() |
        Where-Object { $_.Value -eq $false }

    if ($failed) {

        foreach ($item in $failed) {
            Write-STLog "Requirement failed: $($item.Key)" "WARN"
        }

        return $false
    }

    Write-STLog "All system requirements passed."

    return $true
}