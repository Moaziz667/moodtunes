# =============================================================================
# 🎬 SCRIPT STRESS CPU - Pour déclencher l'autoscaling rapidement
# =============================================================================
# Ce script fait des requêtes lourdes qui consomment du CPU sur le serveur
# Usage: .\stress-server.ps1
# =============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$AlbUrl = "",
    
    [Parameter(Mandatory=$false)]
    [int]$Threads = 20,
    
    [Parameter(Mandatory=$false)]
    [int]$DurationSeconds = 300
)

# Banner
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ║   🔥 CPU STRESS TEST - AUTOSCALING TRIGGER                   ║" -ForegroundColor Red
Write-Host "  ║                                                              ║" -ForegroundColor Red
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""

# Récupérer l'URL si pas fournie
if ([string]::IsNullOrEmpty($AlbUrl)) {
    Write-Host "📡 Récupération de l'URL ALB..." -ForegroundColor Yellow
    try {
        $AlbUrl = (terraform output -raw alb_dns_name 2>$null)
        if (-not [string]::IsNullOrEmpty($AlbUrl)) {
            $AlbUrl = "http://$AlbUrl"
        }
    } catch { }
    
    if ([string]::IsNullOrEmpty($AlbUrl)) {
        $AlbUrl = Read-Host "Entre l'URL de l'ALB (ex: http://tasktodo-alb-xxx.eu-north-1.elb.amazonaws.com)"
    }
}

if (-not $AlbUrl.StartsWith("http")) {
    $AlbUrl = "http://$AlbUrl"
}

Write-Host "🎯 Target: $AlbUrl" -ForegroundColor Green
Write-Host "🔥 Threads: $Threads" -ForegroundColor Green
Write-Host "⏱️  Durée: $DurationSeconds secondes" -ForegroundColor Green
Write-Host ""

# Compteurs globaux
$script:totalRequests = 0
$script:startTime = Get-Date

Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host "  🔥 STRESS TEST EN COURS - Le CPU va monter!" -ForegroundColor Yellow
Write-Host "  💡 Surveille le monitoring pour voir le scaling" -ForegroundColor Yellow  
Write-Host "  ⏹️  Ctrl+C pour arrêter" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Red
Write-Host ""

# Jobs de stress en parallèle
$jobs = @()

# Script block pour le stress
$stressScript = {
    param($Url, $Duration)
    
    $endTime = (Get-Date).AddSeconds($Duration)
    $count = 0
    
    while ((Get-Date) -lt $endTime) {
        try {
            # Requêtes multiples en boucle serrée
            for ($i = 0; $i -lt 10; $i++) {
                $null = Invoke-WebRequest -Uri "$Url/health" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
                $null = Invoke-WebRequest -Uri "$Url/api/v1/task" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
                $null = Invoke-WebRequest -Uri "$Url/api/v1/user" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
                $count += 3
            }
        } catch { }
    }
    
    return $count
}

# Lancer les jobs
for ($t = 0; $t -lt $Threads; $t++) {
    $jobs += Start-Job -ScriptBlock $stressScript -ArgumentList $AlbUrl, $DurationSeconds
    Write-Host "  🚀 Thread $($t + 1)/$Threads lancé" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "  📊 $Threads threads actifs - Attendez la fin du test..." -ForegroundColor Yellow
Write-Host ""

# Attendre avec affichage de progression
$endTime = (Get-Date).AddSeconds($DurationSeconds)
while ((Get-Date) -lt $endTime) {
    $elapsed = [math]::Round(((Get-Date) - $script:startTime).TotalSeconds)
    $remaining = $DurationSeconds - $elapsed
    $percent = [math]::Round(($elapsed / $DurationSeconds) * 100)
    
    # Barre de progression
    $barLen = 40
    $filled = [math]::Floor($barLen * $percent / 100)
    $bar = "█" * $filled + "░" * ($barLen - $filled)
    
    Write-Host "`r  ⏱️  [$bar] $percent% | Restant: ${remaining}s   " -NoNewline -ForegroundColor White
    
    Start-Sleep -Seconds 2
}

Write-Host ""
Write-Host ""

# Récupérer les résultats
Write-Host "📊 Collecte des résultats..." -ForegroundColor Yellow
$totalCount = 0
foreach ($job in $jobs) {
    $result = Receive-Job -Job $job -Wait
    if ($result) { $totalCount += $result }
    Remove-Job -Job $job -Force
}

$elapsed = ((Get-Date) - $script:startTime).TotalSeconds

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  📈 STRESS TEST TERMINÉ" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  ⏱️  Durée: $([math]::Round($elapsed)) secondes" -ForegroundColor White
Write-Host "  📊 Requêtes totales: ~$totalCount" -ForegroundColor White
Write-Host "  🚀 Requêtes/seconde: ~$([math]::Round($totalCount / $elapsed))" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "💡 Vérifie maintenant le monitoring - tu devrais voir le scaling!" -ForegroundColor Yellow
Write-Host ""
