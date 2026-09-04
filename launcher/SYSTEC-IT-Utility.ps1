# SYSTEC SysTool
# Local development launcher

$ProjectRoot = Split-Path `
    -Parent `
    (Split-Path -Parent $MyInvocation.MyCommand.Path)

$CorePath = Join-Path $ProjectRoot "src\Core"

$CoreFiles = @(
    "Logger.ps1"
    "Permissions.ps1"
    "Environment.ps1"
    "Execution.ps1"
    "Validation.ps1"
    "SystemInfo.ps1"
    "Cleanup.ps1"
)

foreach ($file in $CoreFiles) {

    $path = Join-Path $CorePath $file

    if (-not (Test-Path $path)) {

        Write-Host "ERROR: Core file not found: $path" -ForegroundColor Red

        exit 1
    }

    . $path
}

$MainPath = Join-Path $ProjectRoot "src\App\Main.ps1"

if (-not (Test-Path $MainPath)) {

    Write-Host "ERROR: Main.ps1 not found." -ForegroundColor Red

    exit 1
}

. $MainPath