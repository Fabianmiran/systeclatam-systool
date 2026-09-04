# SYSTEC SysTool
# Modules/Network/NetworkDiagnostics.ps1

function Get-STNetworkDiagnostics {

    Write-STLog "Starting network diagnostics."

    try {

        $adapters = Get-NetAdapter -ErrorAction Stop |
            Where-Object {
                $_.Status -eq "Up" -and
                $_.HardwareInterface -eq $true
            }

        if (-not $adapters) {

            Write-STLog "No active network adapters detected." "WARN"

            return [PSCustomObject]@{
                Status            = "FAIL"
                Adapter           = $null
                Connection        = "Disconnected"
                IPv4              = $null
                Gateway           = $null
                DNS               = $null
                GatewayReachable  = $false
                InternetReachable = $false
                DNSResolution     = $false
                LatencyMs         = $null
            }
        }

        $adapter = $adapters |
            Select-Object -First 1

        $interface = Get-NetIPConfiguration `
            -InterfaceIndex $adapter.ifIndex `
            -ErrorAction SilentlyContinue

        $ipv4 = $interface.IPv4Address |
            Select-Object -First 1

        $gateway = $interface.IPv4DefaultGateway |
            Select-Object -ExpandProperty NextHop `
            -First 1

        $dnsServers = $interface.DnsServer.ServerAddresses

        # -----------------------------------------
        # GATEWAY TEST
        # -----------------------------------------

        $gatewayReachable = $false
        $gatewayLatency = $null

        if ($gateway) {

            try {

                $gatewayTest = Test-Connection `
                    -ComputerName $gateway `
                    -Count 2 `
                    -ErrorAction Stop

                if ($gatewayTest) {

                    $gatewayReachable = $true

                    $gatewayLatency = [math]::Round(
                        ($gatewayTest |
                            Measure-Object ResponseTime -Average).Average,
                        0
                    )
                }
            }
            catch {

                Write-STLog `
                    "Gateway test failed: $($_.Exception.Message)" `
                    "WARN"
            }
        }

        # -----------------------------------------
        # INTERNET TEST
        # -----------------------------------------

        $internetReachable = $false
        $internetLatency = $null

        try {

            $internetTest = Test-Connection `
                -ComputerName "1.1.1.1" `
                -Count 2 `
                -ErrorAction Stop

            if ($internetTest) {

                $internetReachable = $true

                $internetLatency = [math]::Round(
                    ($internetTest |
                        Measure-Object ResponseTime -Average).Average,
                    0
                )
            }
        }
        catch {

            Write-STLog "Internet connectivity test failed." "WARN"
        }

        # -----------------------------------------
        # DNS TEST
        # -----------------------------------------

        $dnsResolution = $false

        try {

            $dnsTest = Resolve-DnsName `
                -Name "www.microsoft.com" `
                -ErrorAction Stop

            if ($dnsTest) {
                $dnsResolution = $true
            }
        }
        catch {

            Write-STLog "DNS resolution test failed." "WARN"
        }

        # -----------------------------------------
        # FINAL STATUS
        # -----------------------------------------

        $status = "OK"

        if (-not $gatewayReachable) {
            $status = "WARN"
        }

        if (-not $internetReachable) {
            $status = "FAIL"
        }

        if (-not $dnsResolution) {
            $status = "WARN"
        }

        $result = [PSCustomObject]@{

            Status            = $status

            Adapter           = $adapter.Name

            Connection        = $adapter.Status

            LinkSpeed         = $adapter.LinkSpeed

            IPv4              = $ipv4.IPAddress

            Gateway           = $gateway

            DNS               = ($dnsServers -join ", ")

            GatewayReachable  = $gatewayReachable

            InternetReachable = $internetReachable

            DNSResolution     = $dnsResolution

            LatencyMs         = $internetLatency

            GatewayLatencyMs  = $gatewayLatency
        }

        Write-STLog `
            "Network diagnostics completed. Status: $status"

        return $result
    }
    catch {

        Write-STLog `
            "Network diagnostics failed: $($_.Exception.Message)" `
            "ERROR"

        return $null
    }
}