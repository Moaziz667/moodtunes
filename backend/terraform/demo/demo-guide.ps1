# =============================================================================
# 🎬 GUIDE DÉMO VIDÉO - AUTOSCALING AWS
# =============================================================================
# Ce script prépare tout pour ta démo et t'affiche les étapes à suivre
# Usage: .\demo-guide.ps1
# =============================================================================

param(
    [Parameter(Mandatory=$false)]
    [switch]$PrepareDemo,
    
    [Parameter(Mandatory=$false)]
    [switch]$StartDemo
)

Clear-Host

Write-Host ""
Write-Host "  ╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "  ║                                                                  ║" -ForegroundColor Green
Write-Host "  ║   🎬 GUIDE DÉMO AUTOSCALING - CAPTURE VIDÉO                      ║" -ForegroundColor Green
Write-Host "  ║                                                                  ║" -ForegroundColor Green
Write-Host "  ╚══════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

# Récupérer les infos Terraform
Write-Host "📡 Récupération des informations de l'infrastructure..." -ForegroundColor Yellow
Write-Host ""

try {
    $albUrl = terraform output -raw alb_dns_name 2>$null
    $asgName = terraform output -raw asg_name 2>$null
    
    if (-not [string]::IsNullOrEmpty($albUrl)) {
        Write-Host "  ✅ ALB URL: http://$albUrl" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  ALB URL non trouvée - assure-toi que Terraform est appliqué" -ForegroundColor Yellow
        $albUrl = "<ton-alb-url>"
    }
    
    if (-not [string]::IsNullOrEmpty($asgName)) {
        Write-Host "  ✅ ASG Name: $asgName" -ForegroundColor Green
    } else {
        $asgName = "tasktodo-asg"
        Write-Host "  ⚠️  ASG Name par défaut: $asgName" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠️  Impossible de récupérer les infos Terraform" -ForegroundColor Yellow
    $albUrl = "<ton-alb-url>"
    $asgName = "tasktodo-asg"
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "  📋 ÉTAPES À SUIVRE POUR LA DÉMO VIDÉO" -ForegroundColor Cyan
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor White
Write-Host "  │  PRÉPARATION (Avant de lancer la capture vidéo)                 │" -ForegroundColor White
Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor White
Write-Host ""
Write-Host "  1️⃣  Ouvre 3 fenêtres PowerShell côte à côte" -ForegroundColor Yellow
Write-Host ""
Write-Host "  2️⃣  Ouvre la console AWS dans ton navigateur:" -ForegroundColor Yellow
Write-Host "      🔗 https://eu-north-1.console.aws.amazon.com/ec2/home?region=eu-north-1#AutoScalingGroups:" -ForegroundColor Gray
Write-Host ""
Write-Host "  3️⃣  Ouvre aussi CloudWatch Alarms:" -ForegroundColor Yellow
Write-Host "      🔗 https://eu-north-1.console.aws.amazon.com/cloudwatch/home?region=eu-north-1#alarmsV2:" -ForegroundColor Gray
Write-Host ""

Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor White
Write-Host "  │  DISPOSITION DES FENÊTRES RECOMMANDÉE                           │" -ForegroundColor White
Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor White
Write-Host ""
Write-Host "      ┌────────────────┬────────────────┐" -ForegroundColor Gray
Write-Host "      │                │                │" -ForegroundColor Gray
Write-Host "      │  AWS Console   │   Monitor      │" -ForegroundColor Gray
Write-Host "      │  (Navigateur)  │   (Terminal)   │" -ForegroundColor Gray
Write-Host "      │                │                │" -ForegroundColor Gray
Write-Host "      ├────────────────┴────────────────┤" -ForegroundColor Gray
Write-Host "      │                                 │" -ForegroundColor Gray
Write-Host "      │         Load Test               │" -ForegroundColor Gray
Write-Host "      │         (Terminal)              │" -ForegroundColor Gray
Write-Host "      │                                 │" -ForegroundColor Gray
Write-Host "      └─────────────────────────────────┘" -ForegroundColor Gray
Write-Host ""

Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Green
Write-Host "  │  🎬 SCRIPT DE LA DÉMO (Ce que tu dis/montres)                   │" -ForegroundColor Green
Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Green
Write-Host ""

Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  PARTIE 1: PRÉSENTATION DE L'ARCHITECTURE (30 secondes)" -ForegroundColor Magenta
Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host '  📢 "Voici notre architecture AWS avec Auto-Scaling et Load Balancer"' -ForegroundColor White
Write-Host ""
Write-Host "  👆 MONTRE dans la console AWS:" -ForegroundColor Yellow
Write-Host "     • L'Auto-Scaling Group avec 1 instance (état initial)" -ForegroundColor Gray
Write-Host "     • Le Load Balancer et sa configuration" -ForegroundColor Gray
Write-Host "     • Les Target Groups avec l'instance healthy" -ForegroundColor Gray
Write-Host ""

Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  PARTIE 2: LANCER LE MONITORING (15 secondes)" -ForegroundColor Magenta
Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host '  📢 "Je lance notre outil de monitoring en temps réel"' -ForegroundColor White
Write-Host ""
Write-Host "  💻 EXÉCUTE dans Terminal #1:" -ForegroundColor Yellow
Write-Host "     cd c:\Users\M S I\flutter\flutterapp\backend\terraform\demo" -ForegroundColor Cyan
Write-Host "     .\monitor-asg.ps1" -ForegroundColor Cyan
Write-Host ""

Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  PARTIE 3: LANCER LE TEST DE CHARGE (20 secondes)" -ForegroundColor Magenta
Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host '  📢 "Maintenant je lance une simulation de charge sur le serveur"' -ForegroundColor White
Write-Host ""
Write-Host "  💻 EXÉCUTE dans Terminal #2:" -ForegroundColor Yellow
Write-Host "     cd c:\Users\M S I\flutter\flutterapp\backend\terraform\demo" -ForegroundColor Cyan
Write-Host "     .\load-test.ps1 -ConcurrentRequests 100 -DurationSeconds 600" -ForegroundColor Cyan
Write-Host ""

Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  PARTIE 4: OBSERVER L'AUTOSCALING (2-5 minutes)" -ForegroundColor Magenta
Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host '  📢 "Observons ce qui se passe..."' -ForegroundColor White
Write-Host ""
Write-Host "  👆 CE QUE TU VAS VOIR:" -ForegroundColor Yellow
Write-Host "     1. Le CPU monte progressivement" -ForegroundColor Gray
Write-Host "     2. L'alarme CloudWatch passe en ALARM (CPU > 70%)" -ForegroundColor Gray
Write-Host "     3. Une nouvelle instance apparaît en 'Pending'" -ForegroundColor Gray
Write-Host "     4. L'instance passe en 'InService'" -ForegroundColor Gray
Write-Host "     5. Le traffic est distribué sur les 2 instances" -ForegroundColor Gray
Write-Host ""
Write-Host '  📢 "L alarme CPU High se déclenche, l ASG lance une nouvelle instance"' -ForegroundColor White
Write-Host '  📢 "On voit l instance passer de Pending à InService"' -ForegroundColor White
Write-Host '  📢 "Le Load Balancer distribue maintenant le trafic sur 2 instances"' -ForegroundColor White
Write-Host ""

Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  PARTIE 5: ARRÊTER LE TEST ET OBSERVER LE SCALE-DOWN (2 min)" -ForegroundColor Magenta
Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host '  📢 "J arrête le test de charge pour observer le scale-down"' -ForegroundColor White
Write-Host ""
Write-Host "  💻 EXÉCUTE: Ctrl+C dans le terminal du load-test" -ForegroundColor Yellow
Write-Host ""
Write-Host "  👆 CE QUE TU VAS VOIR:" -ForegroundColor Yellow
Write-Host "     1. Le CPU redescend" -ForegroundColor Gray
Write-Host "     2. L'alarme CPU Low se déclenche (CPU < 30%)" -ForegroundColor Gray
Write-Host "     3. Une instance passe en 'Terminating'" -ForegroundColor Gray
Write-Host "     4. Retour à 1 instance" -ForegroundColor Gray
Write-Host ""
Write-Host '  📢 "Le CPU redescend, l ASG supprime automatiquement l instance"' -ForegroundColor White
Write-Host ""

Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host "  PARTIE 6: CONCLUSION (15 secondes)" -ForegroundColor Magenta
Write-Host "  ═══════════════════════════════════════════════════════════════" -ForegroundColor Magenta
Write-Host ""
Write-Host '  📢 "Voilà! Notre infrastructure s adapte automatiquement à la charge"' -ForegroundColor White
Write-Host '  📢 "Scale-up quand il y a du trafic, scale-down quand c est calme"' -ForegroundColor White
Write-Host '  📢 "Tout ça géré automatiquement par AWS Auto-Scaling"' -ForegroundColor White
Write-Host ""

Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Red
Write-Host "  │  ⚠️  CONSEILS IMPORTANTS                                        │" -ForegroundColor Red
Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Red
Write-Host ""
Write-Host "  • La création d'instance prend ~2-3 minutes" -ForegroundColor Yellow
Write-Host "  • Le cooldown entre actions est de 5 minutes (300s)" -ForegroundColor Yellow
Write-Host "  • Si ça prend trop de temps, tu peux accélérer la vidéo" -ForegroundColor Yellow
Write-Host "  • Assure-toi d'avoir au moins 1 instance running avant de commencer" -ForegroundColor Yellow
Write-Host ""

Write-Host "  ┌─────────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
Write-Host "  │  🚀 COMMANDES RAPIDES                                           │" -ForegroundColor Cyan
Write-Host "  └─────────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
Write-Host ""
Write-Host "  # Terminal 1 - Monitoring:" -ForegroundColor Gray
Write-Host "  .\monitor-asg.ps1" -ForegroundColor Cyan
Write-Host ""
Write-Host "  # Terminal 2 - Load Test:" -ForegroundColor Gray
Write-Host "  .\load-test.ps1 -ConcurrentRequests 100 -DurationSeconds 600" -ForegroundColor Cyan
Write-Host ""
Write-Host "  # Vérifier l'état actuel:" -ForegroundColor Gray
Write-Host "  aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asgName --region eu-north-1" -ForegroundColor Cyan
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  🎬 BONNE DÉMO! Tu es prêt à capturer ta vidéo!" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
