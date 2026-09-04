# SYSTEC SysTool
# Core/Permissions.ps1

function Test-STAdministrator {

    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()

        $principal = New-Object Security.Principal.WindowsPrincipal($identity)

        return $principal.IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator
        )
    }
    catch {
        Write-STLog "Unable to determine administrator status: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Assert-STAdministrator {

    if (-not (Test-STAdministrator)) {

        Write-STLog "Administrator privileges are required." "WARN"

        Add-Type -AssemblyName PresentationFramework

        [System.Windows.MessageBox]::Show(
            "SYSTEC SysTool necesita ejecutarse como Administrador.",
            "SYSTEC SysTool",
            "OK",
            "Warning"
        ) | Out-Null

        return $false
    }

    Write-STLog "Administrator privileges confirmed."

    return $true
}