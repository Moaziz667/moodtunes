# =============================================================================
# 🚀 SCRIPT DE SIMULATION DE CHARGE - DEMO AUTOSCALING
# =============================================================================
# Ce script génère du trafic vers ton ALB pour déclencher l'autoscaling
# Usage: .\load-test.ps1 -AlbUrl "http://ton-alb-dns.amazonaws.com"
# =============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$AlbUrl = "",
    
    [Parameter(Mandatory=$false)]
    [int]$ConcurrentRequests = 50,
    
    [Parameter(Mandatory=$false)]
    [int]$DurationSeconds = 300,  # 5 minutes par défaut
    
    [Parameter(Mandatory=$false)]
    [switch]$StopTest
)

# Couleurs pour affichage
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) { Write-Output $args }
    $host.UI.RawUI.ForegroundColor = $fc
}

# Banner
Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ║   🚀 AUTOSCALING DEMO - LOAD TEST SIMULATOR                  ║" -ForegroundColor Cyan
Write-Host "  ║                                                              ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Si pas d'URL fournie, la récupérer depuis Terraform
if ([string]::IsNullOrEmpty($AlbUrl)) {
    Write-Host "📡 Récupération de l'URL ALB depuis Terraform..." -ForegroundColor Yellow
    try {
        $AlbUrl = (terraform output -raw alb_dns_name 2>$null)
        if ([string]::IsNullOrEmpty($AlbUrl)) {
            Write-Host "❌ Impossible de récupérer l'URL ALB. Spécifie-la manuellement:" -ForegroundColor Red
            Write-Host "   .\load-test.ps1 -AlbUrl 'http://ton-alb-url'" -ForegroundColor Gray
            exit 1
        }
        $AlbUrl = "http://$AlbUrl"
    } catch {
        Write-Host "❌ Erreur Terraform. Spécifie l'URL manuellement." -ForegroundColor Red
        exit 1
    }
}

# Ajouter http:// si pas présent
if (-not $AlbUrl.StartsWith("http")) {
    $AlbUrl = "http://$AlbUrl"
}

Write-Host "🎯 Target URL: $AlbUrl" -ForegroundColor Green
Write-Host "⚡ Requêtes simultanées: $ConcurrentRequests" -ForegroundColor Green
Write-Host "⏱️  Durée: $DurationSeconds secondes" -ForegroundColor Green
Write-Host ""

# Vérifier que l'URL est accessible
Write-Host "🔍 Test de connexion..." -ForegroundColor Yellow
try {
    $testResponse = Invoke-WebRequest -Uri "$AlbUrl/health" -TimeoutSec 10 -UseBasicParsing
    Write-Host "✅ ALB accessible! Status: $($testResponse.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Warning: /health endpoint non accessible, on continue quand même..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🔥 DÉMARRAGE DU TEST DE CHARGE - Ctrl+C pour arrêter" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Compteurs
$script:totalRequests = 0
$script:successRequests = 0
$script:failedRequests = 0
$script:startTime = Get-Date

# Endpoints à tester (ton API)
$endpoints = @(
    "/health",
    "/api/v1/task",
    "/api/v1/user"
)

# Fonction pour afficher les stats
function Show-Stats {
    $elapsed = ((Get-Date) - $script:startTime).TotalSeconds
    $rps = if ($elapsed -gt 0) { [math]::Round($script:totalRequests / $elapsed, 2) } else { 0 }
    $successRate = if ($script:totalRequests -gt 0) { [math]::Round(($script:successRequests / $script:totalRequests) * 100, 1) } else { 0 }
    
    Write-Host "`r📊 Requêtes: $($script:totalRequests) | ✅ Succès: $($script:successRequests) | ❌ Échecs: $($script:failedRequests) | 🚀 RPS: $rps | ⏱️ $([math]::Round($elapsed))s" -NoNewline -ForegroundColor White
}

# Fonction pour envoyer des requêtes
function Send-Request {
    param($Url)
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -UseBasicParsing -Method GET
        $script:successRequests++
    } catch {
        $script:failedRequests++
    }
    $script:totalRequests++
}

# Boucle principale
$endTime = (Get-Date).AddSeconds($DurationSeconds)
$lastStatUpdate = Get-Date

try {
    while ((Get-Date) -lt $endTime) {
        # Envoyer des requêtes en parallèle
        $jobs = @()
        for ($i = 0; $i -lt $ConcurrentRequests; $i++) {
            $endpoint = $endpoints | Get-Random
            $url = "$AlbUrl$endpoint"
            
            # Requêtes synchrones (plus simple et fiable sur Windows)
            Send-Request -Url $url
        }
        
        # Afficher stats toutes les secondes
        if (((Get-Date) - $lastStatUpdate).TotalSeconds -ge 1) {
            Show-Stats
            $lastStatUpdate = Get-Date
        }
        
        # Petite pause pour ne pas surcharger le script
        Start-Sleep -Milliseconds 100
    }
} catch {
    Write-Host "`n⚠️  Test interrompu" -ForegroundColor Yellow
}

# Résumé final
Write-Host ""
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  📈 RÉSUMÉ DU TEST DE CHARGE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
$elapsed = ((Get-Date) - $script:startTime).TotalSeconds
Write-Host "  ⏱️  Durée totale: $([math]::Round($elapsed, 1)) secondes" -ForegroundColor White
Write-Host "  📊 Total requêtes: $($script:totalRequests)" -ForegroundColor White
Write-Host "  ✅ Succès: $($script:successRequests)" -ForegroundColor Green
Write-Host "  ❌ Échecs: $($script:failedRequests)" -ForegroundColor Red
Write-Host "  🚀 Requêtes/seconde: $([math]::Round($script:totalRequests / $elapsed, 2))" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Maintenant, surveille la console AWS pour voir l'autoscaling!" -ForegroundColor Yellow
Write-Host ""
