# SYSTEC SysTool
# App/Main.ps1

Write-STLog "SYSTEC SysTool V0.1 starting."

# -----------------------------------------
# VALIDATE ENVIRONMENT
# -----------------------------------------

if (-not (Test-STRequirements)) {

    Write-STLog "System requirements validation failed." "ERROR"

    return
}

# -----------------------------------------
# ENVIRONMENT
# -----------------------------------------

$environment = Get-STEnvironment

# -----------------------------------------
# SYSTEM INFORMATION
# -----------------------------------------

$system = Get-STSystemInfo

# -----------------------------------------
# CONSOLE OUTPUT
# -----------------------------------------

Clear-Host

Write-Host ""
Write-Host "============================================="
Write-Host "          SYSTEC SysTool V0.1"
Write-Host "============================================="
Write-Host ""

Write-Host "Equipo       : $($system.ComputerName)"
Write-Host "Fabricante   : $($system.Manufacturer)"
Write-Host "Modelo       : $($system.Model)"
Write-Host "Serial       : $($system.SerialNumber)"
Write-Host "Windows      : $($system.OperatingSystem)"
Write-Host "CPU          : $($system.CPU)"
Write-Host "RAM          : $($system.RAM_GB) GB"
Write-Host "Usuario      : $($system.LoggedUser)"
Write-Host "Administrador: $($system.IsAdmin)"
Write-Host "Uptime       : $($system.Uptime)"

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host "Session ID   : $($environment.SessionId)"
Write-Host "Log          : $($environment.LogPath)"
Write-Host "---------------------------------------------"
Write-Host ""

Write-STLog "SYSTEC SysTool V0.1 completed."