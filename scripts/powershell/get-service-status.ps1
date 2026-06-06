param(
    [string]$Name = "Spooler"
)

$service = Get-Service -Name $Name -ErrorAction SilentlyContinue
if ($null -eq $service) {
    Write-Error "Service not found: $Name"
    exit 1
}

[PSCustomObject]@{
    Name = $service.Name
    DisplayName = $service.DisplayName
    Status = $service.Status.ToString()
    CanStop = $service.CanStop
} | ConvertTo-Json
