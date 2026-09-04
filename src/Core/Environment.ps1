# SYSTEC SysTool
# Core/Environment.ps1

function Set-STConsoleEncoding {

    try {
        [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
        [Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)

        Write-STLog "Console encoding configured to UTF-8."
    }
    catch {
        Write-STLog "Could not configure console encoding: $($_.Exception.Message)" "WARN"
    }
}

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