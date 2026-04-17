param (
    [Parameter(Mandatory=$true)]
    [string]$summary,
    
    [string]$details = "",
    
    [int]$tokens = 100
)

$apiUrl = "http://localhost:8080/api/chat"
$body = @{
    sender = "Antigravity"
    summary = $summary
    details = $details
    tokens = $tokens
    kind = "crew_update"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri $apiUrl -Method Post -Body $body -ContentType "application/json"
    Write-Host "Check-in exitoso: Antigravity ha reportado al Command Center." -ForegroundColor Green
} catch {
    Write-Host "Error al reportar al Command Center. ¿Esta el API levantado?" -ForegroundColor Red
}
