# SYSTEC SysTool
# Core/Execution.ps1

function Invoke-STSafe {

    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$ScriptBlock,

        [string]$Operation = "Operation"
    )

    Write-STLog "Starting operation: $Operation"

    try {

        $result = & $ScriptBlock

        Write-STLog "Operation completed: $Operation"

        return $result
    }
    catch {

        Write-STLog `
            "Operation failed [$Operation]: $($_.Exception.Message)" `
            "ERROR"

        return $null
    }
}