# SYSTEC SysTool
# Core/Cleanup.ps1

function Remove-STSession {

    param(
        [switch]$KeepLog
    )

    Write-STLog "Starting session cleanup."

    $sessionPath = Get-STSessionPath

    if (-not (Test-Path $sessionPath)) {
        return
    }

    try {

        if ($KeepLog) {

            Write-STLog "Session cleanup completed. Log preserved at: $sessionPath"

            return
        }

        Remove-Item `
            -Path $sessionPath `
            -Recurse `
            -Force `
            -ErrorAction Stop

    }
    catch {

        Write-STLog `
            "Could not completely remove session directory: $($_.Exception.Message)" `
            "WARN"
    }
}