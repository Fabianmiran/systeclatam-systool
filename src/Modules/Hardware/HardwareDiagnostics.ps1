# SYSTEC SysTool
# Modules/Hardware/HardwareDiagnostics.ps1

function Get-STHardwareDiagnostics {

    Write-STLog "Starting hardware diagnostics."

    try {

        # -----------------------------------------
        # COMPUTER SYSTEM
        # -----------------------------------------

        $computer = Get-CimInstance Win32_ComputerSystem `
            -ErrorAction Stop

        # -----------------------------------------
        # PROCESSOR
        # -----------------------------------------

        $processor = Get-CimInstance Win32_Processor `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1

        # -----------------------------------------
        # BIOS
        # -----------------------------------------

        $bios = Get-CimInstance Win32_BIOS `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1

        # -----------------------------------------
        # MEMORY
        # -----------------------------------------

        $memoryModules = Get-CimInstance Win32_PhysicalMemory `
            -ErrorAction SilentlyContinue

        $totalMemoryGB = $null

        if ($memoryModules) {

            $totalMemoryGB = [math]::Round(
                (
                    ($memoryModules |
                        Measure-Object Capacity -Sum).Sum / 1GB
                ),
                2
            )
        }

        # -----------------------------------------
        # DISKS
        # -----------------------------------------

        $disks = Get-CimInstance Win32_LogicalDisk `
            -Filter "DriveType=3" `
            -ErrorAction SilentlyContinue

        $diskInfo = foreach ($disk in $disks) {

            $sizeGB = $null
            $freeGB = $null
            $freePercent = $null

            if ($disk.Size) {

                $sizeGB = [math]::Round(
                    $disk.Size / 1GB,
                    2
                )

                $freeGB = [math]::Round(
                    $disk.FreeSpace / 1GB,
                    2
                )

                $freePercent = [math]::Round(
                    ($disk.FreeSpace / $disk.Size) * 100,
                    1
                )
            }

            [PSCustomObject]@{

                Drive       = $disk.DeviceID
                FileSystem  = $disk.FileSystem
                SizeGB      = $sizeGB
                FreeGB      = $freeGB
                FreePercent = $freePercent
            }
        }

        # -----------------------------------------
        # PHYSICAL DISKS
        # -----------------------------------------

        $physicalDisks = Get-CimInstance Win32_DiskDrive `
            -ErrorAction SilentlyContinue

        $physicalDiskInfo = foreach ($disk in $physicalDisks) {

            [PSCustomObject]@{

                Model        = $disk.Model
                Interface    = $disk.InterfaceType
                MediaType    = $disk.MediaType
                SizeGB       = if ($disk.Size) {
                    [math]::Round($disk.Size / 1GB, 2)
                }
                Status       = $disk.Status
                SerialNumber = $disk.SerialNumber
            }
        }

        # -----------------------------------------
        # BATTERY
        # -----------------------------------------

        $battery = Get-CimInstance Win32_Battery `
            -ErrorAction SilentlyContinue |
            Select-Object -First 1

        $batteryInfo = $null

        if ($battery) {

            $batteryInfo = [PSCustomObject]@{

                Present          = $true
                Status           = $battery.Status
                ChargePercent    = $battery.EstimatedChargeRemaining
                EstimatedRuntime = $battery.EstimatedRunTime
            }
        }
        else {

            $batteryInfo = [PSCustomObject]@{

                Present          = $false
                Status           = "N/A"
                ChargePercent    = $null
                EstimatedRuntime = $null
            }
        }

        # -----------------------------------------
        # DEVICE MANAGER ERRORS
        # -----------------------------------------

        $deviceErrors = Get-CimInstance Win32_PnPEntity `
            -ErrorAction SilentlyContinue |
            Where-Object {
                $_.ConfigManagerErrorCode -ne $null -and
                $_.ConfigManagerErrorCode -ne 0
            } |
            Select-Object Name, DeviceID, ConfigManagerErrorCode

        # -----------------------------------------
        # HARDWARE STATUS
        # -----------------------------------------

        $hardwareStatus = "OK"

        if ($deviceErrors) {
            $hardwareStatus = "WARN"
        }

        if (-not $computer) {
            $hardwareStatus = "FAIL"
        }

        # -----------------------------------------
        # RESULT
        # -----------------------------------------

        $result = [PSCustomObject]@{

            Status = $hardwareStatus

            Computer = [PSCustomObject]@{

                Manufacturer = $computer.Manufacturer
                Model        = $computer.Model
                SystemType   = $computer.SystemType
            }

            Processor = [PSCustomObject]@{

                Name        = $processor.Name
                Cores       = $processor.NumberOfCores
                LogicalCPUs = $processor.NumberOfLogicalProcessors
                MaxClockMHz = $processor.MaxClockSpeed
            }

            Memory = [PSCustomObject]@{

                TotalGB = $totalMemoryGB
                Modules = $memoryModules.Count
            }

            BIOS = [PSCustomObject]@{

                Manufacturer = $bios.Manufacturer
                Version      = $bios.SMBIOSBIOSVersion
                ReleaseDate  = $bios.ReleaseDate
                SerialNumber = $bios.SerialNumber
            }

            LogicalDisks  = @($diskInfo)

            PhysicalDisks = @($physicalDiskInfo)

            Battery = $batteryInfo

            DeviceErrors = @($deviceErrors)
        }

        Write-STLog `
            "Hardware diagnostics completed. Status: $hardwareStatus"

        return $result
    }
    catch {

        Write-STLog `
            "Hardware diagnostics failed: $($_.Exception.Message)" `
            "ERROR"

        return $null
    }
}