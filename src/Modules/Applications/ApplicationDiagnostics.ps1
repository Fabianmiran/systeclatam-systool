# SYSTEC SysTool
# Modules/Applications/ApplicationDiagnostics.ps1

function Get-STApplicationDiagnostics {

    Write-STLog "Starting application diagnostics."

    try {

        $applications = Get-ItemProperty `
            "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" `
            -ErrorAction SilentlyContinue

        $applications64 = Get-ItemProperty `
            "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
            -ErrorAction SilentlyContinue

        $apps = @(
            $applications
            $applications64
        ) |
        Where-Object {
            $_.DisplayName
        } |
        Select-Object DisplayName, DisplayVersion, Publisher |
        Sort-Object DisplayName -Unique

        $result = [PSCustomObject]@{

            Status = "OK"

            Count = @($apps).Count

            Applications = @($apps)
        }

        Write-STLog `
            "Application diagnostics completed. Applications detected: $($result.Count)"

        return $result
    }
    catch {

        Write-STLog `
            "Application diagnostics failed: $($_.Exception.Message)" `
            "ERROR"

        return $null
    }
}