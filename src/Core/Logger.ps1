# SYSTEC SysTool
# Core/Logger.ps1

$script:STSessionId = [guid]::NewGuid().ToString("N").Substring(0, 8)
$script:STSessionPath = Join-Path $env:TEMP "SYSTEC-SysTool-$($script:STSessionId)"
$script:STLogPath = Join-Path $script:STSessionPath "systec.log"

if (-not (Test-Path $script:STSessionPath)) {
    New-Item -ItemType Directory -Path $script:STSessionPath -Force | Out-Null
}

function Write-STLog {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [ValidateSet("INFO", "WARN", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

    $line = "[$timestamp] [$Level] $Message"

    Add-Content -Path $script:STLogPath -Value $line -Encoding UTF8

    if ($Level -eq "ERROR") {
        Write-Host $line -ForegroundColor Red
    }
    elseif ($Level -eq "WARN") {
        Write-Host $line -ForegroundColor Yellow
    }
    else {
        Write-Host $line
    }
}

function Get-STLogPath {
    return $script:STLogPath
}

function Get-STSessionPath {
    return $script:STSessionPath
}

Write-STLog "SYSTEC SysTool session started. Session ID: $script:STSessionId"