param(
    [string]$Path = "C:\\Windows\\System32"
)

$drive = (Get-Item -LiteralPath $Path).PSDrive
[PSCustomObject]@{
    Path = $Path
    Drive = $drive.Name
    UsedGB = [math]::Round(($drive.Used / 1GB), 2)
    FreeGB = [math]::Round(($drive.Free / 1GB), 2)
    UsedPercent = [math]::Round(($drive.Used / ($drive.Used + $drive.Free)) * 100, 2)
} | ConvertTo-Json
