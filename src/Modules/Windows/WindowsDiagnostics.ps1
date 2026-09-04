# SYSTEC SysTool
# Modules/Windows/WindowsDiagnostics.ps1

function Get-STWindowsDiagnostics {

    Write-STLog "Starting Windows diagnostics."

    try {

        $os = Get-CimInstance Win32_OperatingSystem `
            -ErrorAction Stop

        $computer = Get-CimInstance Win32_ComputerSystem `
            -ErrorAction SilentlyContinue

        $hotFixes = Get-CimInstance Win32_QuickFixEngineering `
            -ErrorAction SilentlyContinue |
            Sort-Object InstalledOn -Descending |
            Select-Object -First 10

        $services = Get-CimInstance Win32_Service `
            -ErrorAction SilentlyContinue

        $stoppedAutoServices = $services |
            Where-Object {
                $_.StartMode -eq "Auto" -and
                $_.State -ne "Running"
            } |
            Select-Object Name, DisplayName, State, StartMode

        $lastBoot = $os.LastBootUpTime

        $uptime = (Get-Date) - $lastBoot

        $disk = Get-CimInstance Win32_LogicalDisk `
            -Filter "DeviceID='C:'" `
            -ErrorAction SilentlyContinue

        $freePercent = $null

        if ($disk.Size) {

            $freePercent = [math]::Round(
                ($disk.FreeSpace / $disk.Size) * 100,
                1
            )
        }

        $pendingReboot = $false

        $rebootPaths = @(
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
        )

        foreach ($path in $rebootPaths) {

            if (Test-Path $path) {
                $pendingReboot = $true
            }
        }

        $status = "OK"

        if ($pendingReboot) {
            $status = "WARN"
        }

        if ($freePercent -ne $null -and $freePercent -lt 15) {
            $status = "WARN"
        }

        $result = [PSCustomObject]@{

            Status = $status

            OperatingSystem = [PSCustomObject]@{

                Caption      = $os.Caption
                Version      = $os.Version
                Build        = $os.BuildNumber
                Architecture = $os.OSArchitecture
                SerialNumber = $os.SerialNumber
            }

            Uptime = [PSCustomObject]@{

                LastBoot = $lastBoot
                Days     = $uptime.Days
                Hours    = $uptime.Hours
                Minutes  = $uptime.Minutes
            }

            WindowsUpdate = [PSCustomObject]@{

                PendingReboot = $pendingReboot
                RecentUpdates = @($hotFixes)
            }

            SystemDisk = [PSCustomObject]@{

                Drive       = "C:"
                SizeGB      = if ($disk.Size) {
                    [math]::Round($disk.Size / 1GB, 2)
                }
                FreeGB      = if ($disk.FreeSpace) {
                    [math]::Round($disk.FreeSpace / 1GB, 2)
                }
                FreePercent = $freePercent
            }

            Services = [PSCustomObject]@{

                StoppedAutomatic = @($stoppedAutoServices)
                Count             = @($stoppedAutoServices).Count
            }
        }

        Write-STLog `
            "Windows diagnostics completed. Status: $status"

        return $result
    }
    catch {

        Write-STLog `
            "Windows diagnostics failed: $($_.Exception.Message)" `
            "ERROR"

        return $null
    }
}