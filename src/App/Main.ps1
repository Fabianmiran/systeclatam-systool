# SYSTEC SysTool
# App/Main.ps1

Write-STLog "SYSTEC SysTool V0.1 starting."

Set-STConsoleEncoding

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
# DIAGNOSTICS
# -----------------------------------------

$network = Get-STNetworkDiagnostics

$hardware = Get-STHardwareDiagnostics

$windows = Get-STWindowsDiagnostics

$security = Get-STSecurityDiagnostics

$printers = Get-STPrinterDiagnostics

$applications = Get-STApplicationDiagnostics

$m365 = Get-STM365Diagnostics

# -----------------------------------------
# CONSOLE OUTPUT
# -----------------------------------------

Clear-Host

Write-Host ""
Write-Host "============================================="
Write-Host "          SYSTEC SysTool V0.1"
Write-Host "============================================="
Write-Host ""

# -----------------------------------------
# SYSTEM INFORMATION
# -----------------------------------------

Write-Host "SYSTEM INFORMATION"
Write-Host "---------------------------------------------"

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

# -----------------------------------------
# NETWORK
# -----------------------------------------

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host "NETWORK DIAGNOSTICS"
Write-Host "---------------------------------------------"

if ($network) {

    Write-Host "Estado       : $($network.Status)"
    Write-Host "Adaptador    : $($network.Adapter)"
    Write-Host "Conexion     : $($network.Connection)"
    Write-Host "Link Speed   : $($network.LinkSpeed)"
    Write-Host "IPv4         : $($network.IPv4)"
    Write-Host "Gateway      : $($network.Gateway)"
    Write-Host "DNS          : $($network.DNS)"
    Write-Host "Gateway Test : $(if ($network.GatewayReachable) { 'OK' } else { 'FAIL' })"
    Write-Host "Internet     : $(if ($network.InternetReachable) { 'OK' } else { 'FAIL' })"
    Write-Host "DNS Test     : $(if ($network.DNSResolution) { 'OK' } else { 'FAIL' })"
    Write-Host "Latencia     : $($network.LatencyMs) ms"
}
else {

    Write-Host "Estado       : ERROR"
}

# -----------------------------------------
# HARDWARE
# -----------------------------------------

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host "HARDWARE DIAGNOSTICS"
Write-Host "---------------------------------------------"

if ($hardware) {

    Write-Host "Estado       : $($hardware.Status)"

    Write-Host ""
    Write-Host "Equipo"
    Write-Host "Fabricante   : $($hardware.Computer.Manufacturer)"
    Write-Host "Modelo       : $($hardware.Computer.Model)"
    Write-Host "Tipo         : $($hardware.Computer.SystemType)"

    Write-Host ""
    Write-Host "CPU"
    Write-Host "Modelo       : $($hardware.Processor.Name)"
    Write-Host "Nucleos      : $($hardware.Processor.Cores)"
    Write-Host "Logical CPU  : $($hardware.Processor.LogicalCPUs)"

    Write-Host ""
    Write-Host "RAM"
    Write-Host "Total        : $($hardware.Memory.TotalGB) GB"
    Write-Host "Modulos      : $($hardware.Memory.Modules)"

    Write-Host ""
    Write-Host "BIOS"
    Write-Host "Fabricante   : $($hardware.BIOS.Manufacturer)"
    Write-Host "Version      : $($hardware.BIOS.Version)"

    Write-Host ""
    Write-Host "Discos"

    foreach ($disk in $hardware.LogicalDisks) {

        Write-Host "Drive        : $($disk.Drive)"
        Write-Host "Tamano       : $($disk.SizeGB) GB"
        Write-Host "Libre        : $($disk.FreeGB) GB"
        Write-Host "Libre %      : $($disk.FreePercent)%"
        Write-Host ""
    }

    Write-Host "Errores Device Manager: $(@($hardware.DeviceErrors).Count)"
}
else {

    Write-Host "Estado       : ERROR"
}

# -----------------------------------------
# WINDOWS
# -----------------------------------------

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host "WINDOWS DIAGNOSTICS"
Write-Host "---------------------------------------------"

if ($windows) {

    Write-Host "Estado       : $($windows.Status)"
    Write-Host "Version      : $($windows.OperatingSystem.Caption)"
    Write-Host "Build        : $($windows.OperatingSystem.Build)"
    Write-Host "Arquitectura : $($windows.OperatingSystem.Architecture)"

    Write-Host ""
    Write-Host "Uptime"
    Write-Host "Ultimo Boot  : $($windows.Uptime.LastBoot)"
    Write-Host "Dias         : $($windows.Uptime.Days)"
    Write-Host "Horas        : $($windows.Uptime.Hours)"
    Write-Host "Minutos      : $($windows.Uptime.Minutes)"

    Write-Host ""
    Write-Host "Windows Update"
    Write-Host "Reinicio Req.: $($windows.WindowsUpdate.PendingReboot)"

    Write-Host ""
    Write-Host "Disco C:"
    Write-Host "Tamano       : $($windows.SystemDisk.SizeGB) GB"
    Write-Host "Libre        : $($windows.SystemDisk.FreeGB) GB"
    Write-Host "Libre %      : $($windows.SystemDisk.FreePercent)%"

    Write-Host ""
    Write-Host "Servicios automaticos detenidos: $($windows.Services.Count)"
}
else {

    Write-Host "Estado       : ERROR"
}

# -----------------------------------------
# SECURITY
# -----------------------------------------

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host "SECURITY DIAGNOSTICS"
Write-Host "---------------------------------------------"

if ($security) {

    Write-Host "Estado       : $($security.Status)"

    Write-Host ""
    Write-Host "Microsoft Defender"
    Write-Host "Disponible   : $($security.Defender.Available)"
    Write-Host "Antivirus    : $($security.Defender.AntivirusEnabled)"
    Write-Host "Proteccion   : $($security.Defender.RealTimeProtection)"

    Write-Host ""
    Write-Host "Firewall"

    foreach ($firewall in $security.Firewall) {

        Write-Host "$($firewall.Name): $(if ($firewall.Enabled) { 'Enabled' } else { 'Disabled' })"
    }
}
else {

    Write-Host "Estado       : ERROR"
}

# -----------------------------------------
# PRINTERS
# -----------------------------------------

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host "PRINTER DIAGNOSTICS"
Write-Host "---------------------------------------------"

if ($printers) {

    Write-Host "Estado       : $($printers.Status)"
    Write-Host "Impresoras   : $($printers.Count)"

    foreach ($printer in $printers.Printers) {

        Write-Host ""
        Write-Host "Nombre       : $($printer.Name)"
        Write-Host "Driver       : $($printer.DriverName)"
        Write-Host "Puerto       : $($printer.PortName)"
        Write-Host "Estado       : $($printer.Status)"
        Write-Host "Predetermin. : $($printer.Default)"
    }
}
else {

    Write-Host "Estado       : ERROR"
}

# -----------------------------------------
# APPLICATIONS
# -----------------------------------------

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host "APPLICATION DIAGNOSTICS"
Write-Host "---------------------------------------------"

if ($applications) {

    Write-Host "Estado       : $($applications.Status)"
    Write-Host "Aplicaciones : $($applications.Count)"

    $applications.Applications |
        Select-Object -First 15 |
        ForEach-Object {

            Write-Host "$($_.DisplayName) - $($_.DisplayVersion)"
        }

    if ($applications.Count -gt 15) {

        Write-Host "... mostrando primeras 15 aplicaciones"
    }
}
else {

    Write-Host "Estado       : ERROR"
}

# -----------------------------------------
# MICROSOFT 365
# -----------------------------------------

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host "MICROSOFT 365 DIAGNOSTICS"
Write-Host "---------------------------------------------"

if ($m365) {

    Write-Host "Estado       : $($m365.Status)"

    Write-Host ""
    Write-Host "Office"
    Write-Host "Instalado    : $($m365.Office.Installed)"
    Write-Host "Version      : $($m365.Office.Version)"
    Write-Host "Channel      : $($m365.Office.Channel)"

    Write-Host ""
    Write-Host "Procesos"
    Write-Host "Outlook      : $($m365.Applications.OutlookRunning)"
    Write-Host "Teams        : $($m365.Applications.TeamsRunning)"
    Write-Host "OneDrive     : $($m365.Applications.OneDriveRunning)"
}
else {

    Write-Host "Estado       : ERROR"
}

# -----------------------------------------
# SESSION
# -----------------------------------------

Write-Host ""
Write-Host "---------------------------------------------"
Write-Host "Session ID   : $($environment.SessionId)"
Write-Host "Log          : $($environment.LogPath)"
Write-Host "---------------------------------------------"
Write-Host ""

Write-STLog "SYSTEC SysTool V0.1 completed."