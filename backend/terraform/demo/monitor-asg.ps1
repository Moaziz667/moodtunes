# =============================================================================
# 📊 SCRIPT DE MONITORING EN TEMPS RÉEL - DEMO AUTOSCALING
# =============================================================================
# Ce script affiche l'état de ton ASG et des instances en temps réel
# Usage: .\monitor-asg.ps1
# =============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$AsgName = "tasktodo-asg",
    
    [Parameter(Mandatory=$false)]
    [string]$Region = "eu-north-1",
    
    [Parameter(Mandatory=$false)]
    [int]$RefreshSeconds = 5
)

# Vérifier AWS CLI
try {
    aws --version | Out-Null
} catch {
    Write-Host "❌ AWS CLI non installé!" -ForegroundColor Red
    exit 1
}

Clear-Host

while ($true) {
    Clear-Host
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    
    # Banner
    Write-Host ""
    Write-Host "  ╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Magenta
    Write-Host "  ║                                                              ║" -ForegroundColor Magenta
    Write-Host "  ║   📊 AUTOSCALING MONITOR - LIVE DASHBOARD                    ║" -ForegroundColor Magenta
    Write-Host "  ║                                                              ║" -ForegroundColor Magenta
    Write-Host "  ╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "  🕐 Dernière mise à jour: $timestamp  (Rafraîchissement: ${RefreshSeconds}s)" -ForegroundColor Gray
    Write-Host ""
    
    # =========================================================================
    # AUTO-SCALING GROUP STATUS
    # =========================================================================
    Write-Host "  ┌──────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "  │  🎯 AUTO-SCALING GROUP: $AsgName" -ForegroundColor Cyan
    Write-Host "  └──────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
    
    try {
        $asgInfo = aws autoscaling describe-auto-scaling-groups `
            --auto-scaling-group-names $AsgName `
            --region $Region `
            --output json | ConvertFrom-Json
        
        if ($asgInfo.AutoScalingGroups.Count -gt 0) {
            $asg = $asgInfo.AutoScalingGroups[0]
            
            $minSize = $asg.MinSize
            $maxSize = $asg.MaxSize
            $desired = $asg.DesiredCapacity
            $currentInstances = $asg.Instances.Count
            
            # Barre de progression visuelle
            $barLength = 20
            $filledLength = [math]::Floor(($currentInstances / $maxSize) * $barLength)
            $bar = "█" * $filledLength + "░" * ($barLength - $filledLength)
            
            Write-Host ""
            Write-Host "  📈 CAPACITÉ:" -ForegroundColor Yellow
            Write-Host "     Min: $minSize  |  Desired: $desired  |  Max: $maxSize" -ForegroundColor White
            Write-Host ""
            Write-Host "     Instances: [$bar] $currentInstances / $maxSize" -ForegroundColor Green
            Write-Host ""
            
            # =========================================================================
            # INSTANCES DETAILS
            # =========================================================================
            Write-Host "  ┌──────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
            Write-Host "  │  🖥️  INSTANCES EC2" -ForegroundColor Cyan
            Write-Host "  └──────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
            Write-Host ""
            
            if ($asg.Instances.Count -gt 0) {
                $instanceNum = 1
                foreach ($instance in $asg.Instances) {
                    $instanceId = $instance.InstanceId
                    $lifecycleState = $instance.LifecycleState
                    $healthStatus = $instance.HealthStatus
                    $az = $instance.AvailabilityZone
                    
                    # Couleur selon l'état
                    $stateColor = switch ($lifecycleState) {
                        "InService" { "Green" }
                        "Pending" { "Yellow" }
                        "Terminating" { "Red" }
                        "Pending:Wait" { "Yellow" }
                        "Pending:Proceed" { "Yellow" }
                        default { "Gray" }
                    }
                    
                    $healthColor = if ($healthStatus -eq "Healthy") { "Green" } else { "Red" }
                    $healthIcon = if ($healthStatus -eq "Healthy") { "✅" } else { "❌" }
                    
                    # Icône selon l'état
                    $stateIcon = switch ($lifecycleState) {
                        "InService" { "🟢" }
                        "Pending" { "🟡" }
                        "Pending:Wait" { "🟡" }
                        "Pending:Proceed" { "🟡" }
                        "Terminating" { "🔴" }
                        default { "⚪" }
                    }
                    
                    Write-Host "     $stateIcon Instance #$instanceNum" -ForegroundColor White
                    Write-Host "        ID: $instanceId" -ForegroundColor Gray
                    Write-Host "        État: " -NoNewline -ForegroundColor Gray
                    Write-Host "$lifecycleState" -ForegroundColor $stateColor
                    Write-Host "        Santé: $healthIcon $healthStatus" -ForegroundColor $healthColor
                    Write-Host "        Zone: $az" -ForegroundColor Gray
                    Write-Host ""
                    
                    $instanceNum++
                }
            } else {
                Write-Host "     ⚠️  Aucune instance active" -ForegroundColor Yellow
                Write-Host ""
            }
            
            # =========================================================================
            # SCALING ACTIVITIES (Recent)
            # =========================================================================
            Write-Host "  ┌──────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
            Write-Host "  │  📜 ACTIVITÉS RÉCENTES" -ForegroundColor Cyan
            Write-Host "  └──────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
            Write-Host ""
            
            $activities = aws autoscaling describe-scaling-activities `
                --auto-scaling-group-name $AsgName `
                --region $Region `
                --max-items 3 `
                --output json | ConvertFrom-Json
            
            if ($activities.Activities.Count -gt 0) {
                foreach ($activity in $activities.Activities) {
                    $activityTime = $activity.StartTime
                    $cause = $activity.Cause
                    $status = $activity.StatusCode
                    
                    $statusIcon = switch ($status) {
                        "Successful" { "✅" }
                        "InProgress" { "🔄" }
                        "Failed" { "❌" }
                        default { "⏳" }
                    }
                    
                    # Extraire une description courte
                    $shortCause = if ($cause.Length -gt 60) { $cause.Substring(0, 60) + "..." } else { $cause }
                    
                    Write-Host "     $statusIcon [$activityTime]" -ForegroundColor Gray
                    Write-Host "        $shortCause" -ForegroundColor White
                    Write-Host ""
                }
            } else {
                Write-Host "     Aucune activité récente" -ForegroundColor Gray
            }
            
            # =========================================================================
            # CLOUDWATCH ALARMS STATUS
            # =========================================================================
            Write-Host "  ┌──────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
            Write-Host "  │  🚨 ALARMES CLOUDWATCH" -ForegroundColor Cyan
            Write-Host "  └──────────────────────────────────────────────────────────────┘" -ForegroundColor Cyan
            Write-Host ""
            
            $alarms = aws cloudwatch describe-alarms `
                --alarm-names "tasktodo-cpu-high" "tasktodo-cpu-low" "tasktodo-cpu-high-demo" "tasktodo-cpu-low-demo" `
                --region $Region `
                --output json | ConvertFrom-Json
            
            foreach ($alarm in $alarms.MetricAlarms) {
                $alarmName = $alarm.AlarmName
                $alarmState = $alarm.StateValue
                
                $alarmIcon = switch ($alarmState) {
                    "ALARM" { "🔴" }
                    "OK" { "🟢" }
                    "INSUFFICIENT_DATA" { "🟡" }
                    default { "⚪" }
                }
                
                $alarmColor = switch ($alarmState) {
                    "ALARM" { "Red" }
                    "OK" { "Green" }
                    default { "Yellow" }
                }
                
                Write-Host "     $alarmIcon $alarmName : " -NoNewline -ForegroundColor White
                Write-Host "$alarmState" -ForegroundColor $alarmColor
            }
            
        } else {
            Write-Host "  ⚠️  ASG '$AsgName' non trouvé!" -ForegroundColor Red
        }
        
    } catch {
        Write-Host "  ❌ Erreur lors de la récupération des données: $_" -ForegroundColor Red
    }
    
    Write-Host ""
    Write-Host "  ─────────────────────────────────────────────────────────────────" -ForegroundColor Gray
    Write-Host "  💡 Appuyez sur Ctrl+C pour arrêter le monitoring" -ForegroundColor Gray
    Write-Host ""
    
    Start-Sleep -Seconds $RefreshSeconds
}
