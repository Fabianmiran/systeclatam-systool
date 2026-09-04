# SYSTEC SysTool
# Modules/Security/SecurityDiagnostics.ps1

function Get-STSecurityDiagnostics {

    Write-STLog "Starting security diagnostics."

    try {

        $defender = $null

        try {

            $defender = Get-MpComputerStatus `
                -ErrorAction Stop
        }
        catch {

            Write-STLog `
                "Microsoft Defender information unavailable." `
                "WARN"
        }

        $firewallProfiles = Get-NetFirewallProfile `
            -ErrorAction SilentlyContinue

        $firewallDisabled = $firewallProfiles |
            Where-Object {
                $_.Enabled -eq $false
            }

        $status = "OK"

        if ($firewallDisabled) {
            $status = "WARN"
        }

        if ($defender) {

            if (-not $defender.RealTimeProtectionEnabled) {
                $status = "WARN"
            }
        }

        $result = [PSCustomObject]@{

            Status = $status

            Defender = [PSCustomObject]@{

                Available = ($null -ne $defender)

                AntivirusEnabled = if ($defender) {
                    $defender.AntivirusEnabled
                }

                RealTimeProtection = if ($defender) {
                    $defender.RealTimeProtectionEnabled
                }

                AntivirusVersion = if ($defender) {
                    $defender.AMProductVersion
                }

                EngineVersion = if ($defender) {
                    $defender.AMEngineVersion
                }

                SignatureVersion = if ($defender) {
                    $defender.AntivirusSignatureVersion
                }
            }

            Firewall = @(
                $firewallProfiles |
                Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction
            )
        }

        Write-STLog `
            "Security diagnostics completed. Status: $status"

        return $result
    }
    catch {

        Write-STLog `
            "Security diagnostics failed: $($_.Exception.Message)" `
            "ERROR"

        return $null
    }
}