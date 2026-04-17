param(
    [string]$TargetDir = 'c:\Users\Widox\Desktop\ARGOS\ARGOS_RUNTIME'
)

$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function Strip-BOM {
    param([string]$FilePath)
    $bytes = [System.IO.File]::ReadAllBytes($FilePath)
    if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
        Write-Host "Stripping BOM from: $FilePath"
        $content = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
        [System.IO.File]::WriteAllText($FilePath, $content, $utf8NoBom)
    }
}

Get-ChildItem -Path $TargetDir -Filter "*.md" -Recurse | ForEach-Object { Strip-BOM $_.FullName }
Get-ChildItem -Path $TargetDir -Filter "*.jsonl" -Recurse | ForEach-Object { Strip-BOM $_.FullName }
Get-ChildItem -Path $TargetDir -Filter "*.json" -Recurse | ForEach-Object { Strip-BOM $_.FullName }
