# SYSTEC SysTool
# Core/Environment.ps1

function Get-STEnvironment {

    $environment = [ordered]@{
        ComputerName = $env:COMPUTERNAME
        UserName     = $env:USERNAME
        Domain       = $env:USERDOMAIN
        PowerShell   = $PSVersionTable.PSVersion.ToString()
        OS           = $null
        IsAdmin      = Test-STAdministrator
        SessionId    = $script:STSessionId
        SessionPath  = $script:STSessionPath
        LogPath      = $script:STLogPath
    }

    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop

        $environment.OS = $os.Caption
    }
    catch {
        Write-STLog "Could not retrieve operating system information." "WARN"
    }

    return [PSCustomObject]$environment
}