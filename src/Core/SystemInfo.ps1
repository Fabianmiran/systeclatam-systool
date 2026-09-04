# SYSTEC SysTool
# Core/SystemInfo.ps1

function Get-STSystemInfo {

    Write-STLog "Collecting system information."

    try {

        $computer = Get-CimInstance Win32_ComputerSystem
        $os = Get-CimInstance Win32_OperatingSystem
        $bios = Get-CimInstance Win32_BIOS
        $cpu = Get-CimInstance Win32_Processor |
            Select-Object -First 1

        $totalRamGB = [math]::Round(
            $computer.TotalPhysicalMemory / 1GB,
            2
        )

        $lastBoot = $os.LastBootUpTime

        $uptime = (Get-Date) - $lastBoot

        $result = [PSCustomObject]@{

            ComputerName = $env:COMPUTERNAME

            Manufacturer = $computer.Manufacturer

            Model = $computer.Model

            SerialNumber = $bios.SerialNumber

            OperatingSystem = $os.Caption

            OSVersion = $os.Version

            Architecture = $os.OSArchitecture

            CPU = $cpu.Name

            RAM_GB = $totalRamGB

            LastBoot = $lastBoot

            Uptime = "{0}d {1}h {2}m" -f `
                $uptime.Days,
                $uptime.Hours,
                $uptime.Minutes

            LoggedUser = $computer.UserName

            IsAdmin = Test-STAdministrator
        }

        Write-STLog "System information collected successfully."

        return $result
    }
    catch {

        Write-STLog `
            "Failed to collect system information: $($_.Exception.Message)" `
            "ERROR"

        return $null
    }
}