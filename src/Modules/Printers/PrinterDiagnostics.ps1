# SYSTEC SysTool
# Modules/Printers/PrinterDiagnostics.ps1

function Get-STPrinterDiagnostics {

    Write-STLog "Starting printer diagnostics."

    try {

        $printers = Get-Printer `
            -ErrorAction Stop

        $ports = Get-PrinterPort `
            -ErrorAction SilentlyContinue

        $printerInfo = foreach ($printer in $printers) {

            $port = $ports |
                Where-Object {
                    $_.Name -eq $printer.PortName
                } |
                Select-Object -First 1

            [PSCustomObject]@{

                Name       = $printer.Name
                DriverName = $printer.DriverName
                PortName   = $printer.PortName
                PortType   = if ($port) {
                    $port.PortMonitor
                }
                Status     = $printer.PrinterStatus
                Shared     = $printer.Shared
                Default    = $printer.Default
            }
        }

        $result = [PSCustomObject]@{

            Status = "OK"

            Count = @($printerInfo).Count

            Printers = @($printerInfo)
        }

        Write-STLog `
            "Printer diagnostics completed. Printers detected: $($result.Count)"

        return $result
    }
    catch {

        Write-STLog `
            "Printer diagnostics failed: $($_.Exception.Message)" `
            "ERROR"

        return $null
    }
}