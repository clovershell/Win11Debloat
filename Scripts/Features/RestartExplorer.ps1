# Restart the Windows Explorer process
function RestartExplorer {
    # Restarting Explorer while running in Sysprep or User context is not necessary
    if ($script:Params.ContainsKey("Sysprep") -or $script:Params.ContainsKey("User")) {
        return
    }

    if ($script:Params.ContainsKey("WhatIf")) {
        Write-Host "[WhatIf] 重启 Windows 资源管理器进程" -ForegroundColor Cyan
        return
    }

    Write-Host "> 正在尝试重启 Windows 资源管理器进程以应用所有更改..."
    
    if ($script:Params.ContainsKey("NoRestartExplorer")) {
        Write-Host "已跳过资源管理器进程重启，请手动重启电脑以应用所有更改" -ForegroundColor Yellow
        return
    }

    foreach ($paramKey in $script:Params.Keys) {
        if ($script:Features.ContainsKey($paramKey) -and $script:Features[$paramKey].RequiresReboot -eq $true) {
            $feature = $script:Features[$paramKey]
            Write-Host "警告：'$($feature.Label)' 需要重启才能完全生效" -ForegroundColor Yellow
        }
    }

    # Only restart if the powershell process matches the OS architecture.
    # Restarting explorer from a 32bit PowerShell window will fail on a 64bit OS
    if ([Environment]::Is64BitProcess -eq [Environment]::Is64BitOperatingSystem) {
        Write-Host "正在重启 Windows 资源管理器进程...（这可能会导致屏幕闪烁）"
        Stop-Process -processName: Explorer -Force
    }
    else {
        Write-Host "无法重启 Windows 资源管理器进程，请手动重启电脑以应用所有更改" -ForegroundColor Yellow
    }
}