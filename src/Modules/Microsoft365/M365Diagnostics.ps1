# SYSTEC SysTool
# Modules/Microsoft365/M365Diagnostics.ps1

function Get-STM365Diagnostics {

    Write-STLog "Starting Microsoft 365 diagnostics."

    try {

        $office = Get-ItemProperty `
            "HKLM:\Software\Microsoft\Office\ClickToRun\Configuration" `
            -ErrorAction SilentlyContinue

        $outlook = Get-Process `
            -Name OUTLOOK `
            -ErrorAction SilentlyContinue

        $teams = Get-Process `
            -Name ms-teams, Teams `
            -ErrorAction SilentlyContinue

        $onedrive = Get-Process `
            -Name OneDrive `
            -ErrorAction SilentlyContinue

        $result = [PSCustomObject]@{

            Status = "OK"

            Office = [PSCustomObject]@{

                Installed = ($null -ne $office)

                Version = if ($office) {
                    $office.ClientVersionToReport
                }

                Channel = if ($office) {
                    $office.UpdateChannel
                }

                Platform = if ($office) {
                    $office.Platform
                }
            }

            Applications = [PSCustomObject]@{

                OutlookRunning  = ($null -ne $outlook)
                TeamsRunning    = ($null -ne $teams)
                OneDriveRunning = ($null -ne $onedrive)
            }
        }

        Write-STLog `
            "Microsoft 365 diagnostics completed."

        return $result
    }
    catch {

        Write-STLog `
            "Microsoft 365 diagnostics failed: $($_.Exception.Message)" `
            "ERROR"

        return $null
    }
}