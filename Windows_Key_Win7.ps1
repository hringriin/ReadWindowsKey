function Get-WindowsKey {
    param ($targets = ".")
    $hklm = 2147483650
    $regPath = "Software\Microsoft\Windows NT\CurrentVersion"
    $regValue = "DigitalProductId"
    Foreach ($target in $targets) {
        $productKey = $null
        $win32os = $null
        $wmi = [WMIClass]"\\$target\root\default:stdRegProv"
        $data = $wmi.GetBinaryValue($hklm,$regPath,$regValue)
        $binArray = ($data.uValue)[52..66]
        $charsArray = "B","C","D","F","G","H","J","K","M","P","Q","R","T","V","W","X","Y","2","3","4","6","7","8","9"
        For ($i = 24; $i -ge 0; $i--) {
            $k = 0
            For ($j = 14; $j -ge 0; $j--) {
                $k = $k * 256 -bxor $binArray[$j]
                $binArray[$j] = [math]::truncate($k / 24)
                $k = $k % 24
                Write-Host "k: $k"
            }
            $productKey = $charsArray[$k] + $productKey
            If (($i % 5 -eq 0) -and ($i -ne 0)) {
                $productKey = "-" + $productKey
            }
        }
        $win32os = Get-WmiObject Win32_OperatingSystem -computer $target
        $obj = New-Object Object
        $obj | Add-Member Noteproperty Computer-Name -value $target
        $obj | Add-Member Noteproperty Windows-Edition -value $win32os.Caption
        $obj | Add-Member Noteproperty Windows-Version -value $win32os.CSDVersion
        $obj | Add-Member Noteproperty Bit-Version -value $win32os.OSArchitecture
        $obj | Add-Member Noteproperty Build-Nummer -value $win32os.BuildNumber
        $obj | Add-Member Noteproperty Lizenznehmer -value $win32os.RegisteredUser
        $obj | Add-Member Noteproperty Produkt-ID -value $win32os.SerialNumber
        $obj | Add-Member Noteproperty Produkt-Key -value $productkey
        $obj
    }
}
Get-WindowsKey
